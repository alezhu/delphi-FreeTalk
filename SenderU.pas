{.$DEFINE DEBUG}
unit SenderU;

interface
uses
  Windows,netbiosU,SenderListenerThread,SysUtils;

type

  TSenderLogReceivedMessage=procedure(Sender:TObject;const sFrom,sTo,sRealFrom,sMessage:string) of object;
  TSenderErrorEvent=procedure(Sender:TObject;ErrorCode:Byte;const ErrorMsg:string) of object;

  TSender=class
  private
    Thr:TSenderListenerThread;
    FAlias: string;
    FAdapterIndex: byte;
    FLogReceivedMessage: TSenderLogReceivedMessage;
    FSenderErrorEvent: TSenderErrorEvent;
  protected
    function CopyStringToSMB(const S:string;Addr:PChar):PChar;
    function PrepareNBSession(ANCB:TNetBIOS;const AFrom,ATo:string):byte;
  public
    property Alias:string read FAlias;
    property AdapterIndex:byte read FAdapterIndex write FAdapterIndex;
    property LogReceivedMessage:TSenderLogReceivedMessage read FLogReceivedMessage write FLogReceivedMessage;
    property SenderErrorEvent:TSenderErrorEvent read FSenderErrorEvent write FSenderErrorEvent;
    constructor Create(AAdapterIndex:Byte);
    destructor Destroy;override;
    function GetRealSender(ASession:Byte;ANetBIOS:TNetBIOS):string;
    function SendText(const ATo,AText:string):boolean;
    procedure DoLogReceivedMessage(const sFrom,sTo,sRealFrom,sMessage:string);
    procedure DoError(ErrorCode:byte;const ErrorMsg:string);
  end;

  TSMBCommand=packed object
    Signature:DWORD;
    Command:Byte;
    Chars:packed array[0..26] of Char;
    Data:packed array[0..255] of Char;
    procedure Init(ACommand:Byte);
    function GetHeaderSize:DWORD;
  end;
  PSMBCommand = ^TSMBCommand;

  ESenderError=class(EXception)
  public
    ErrorCode:byte;
    constructor CreateFmt(ErrorCode:Byte;const Msg: string; const Args: array of const);
  end;



implementation
uses
  {$IFDEF DEBUG}Classes,{$ENDIF}nb30;

function TSMBCommand.GetHeaderSize: DWORD;
begin
  result:=DWORD(sizeof(self)-sizeof(self.Data));
end;

procedure TSMBCommand.Init(ACommand:Byte);
begin
  FillChar(self,sizeof(TSMBCommand),0);
//  ZeroMemory(@self,sizeof(TSMBCommand));
  self.Signature:=$424D53FF;
  self.Command := ACommand;
end;


{ TSender }

function TSender.CopyStringToSMB(const S: string; Addr: PChar):PChar;
begin
  Addr^ := #04;
  Inc(addr);
//  StrLCopy(Addr,Pchar(s),Length(S)+1);
  move(Pchar(s)^,Addr^,Length(s)+1);
  Inc(Addr,length(s)+1);
  result:=Addr;
end;

constructor TSender.Create(AAdapterIndex:Byte);
var
  cn:array [0..MAX_COMPUTERNAME_LENGTH] of char;
  dwLen:dword;
begin
  inherited Create;
  dwLen := sizeof(cn);
  GetComputerName(@cn,dwLen);
  Setstring(fAlias,cn,dwLen);
  fAlias:=UpperCase(fAlias);
  FAdapterIndex := AAdapterIndex;
  Thr:=TSenderListenerThread.Create(self);
  with thr do
  begin
    FreeOnTerminate := true;
    Resume;
  end;
end;

destructor TSender.Destroy;
begin
  thr.Terminate;
  inherited;
end;

procedure TSender.DoError(ErrorCode: byte;const ErrorMsg:string);
begin
  if Assigned(FSenderErrorEvent) then
    FSenderErrorEvent(self,ErrorCode,ErrorMsg);
end;

procedure TSender.DoLogReceivedMessage(const sFrom, sTo,
  sRealFrom, sMessage: string);
begin
  if Assigned(FLogReceivedMessage) then
    LogReceivedMessage(self,sFrom,sTo,sRealFrom,sMessage);
end;

function TSender.GetRealSender(ASession: Byte; ANetBIOS: TNetBIOS): string;
begin
  result:=NetbiosU.GetRealSender(Alias,ASession,ANetBIOS);
end;


function TSender.PrepareNBSession(ANCB: TNetBIOS; const AFrom,
  ATo: string): byte;
var
  szTo,szFrom:array[0..MAXMACHINENAME-1] of Char;
begin
  MakeNetBIOSName(Pchar(ATo),szTo,3);
  MakeNetBIOSName(Pchar(AFrom),szFrom,3);
  result:=ANCB.Call(szFrom,szTo,5000,5000);
//  result:=ANCB.Call(GetNetBIOSNAme(Afrom,3),GetNetBIOSName(ATo,3),5000,5000);

end;

function TSender.SendText(const ATo, AText: string): boolean;
Var
  sMessage:string;
  pMessage:Pchar;
  dwMessageLen:DWORD;
  NB:TNetBIOS;
  Res:Byte;
  Session:Byte;
  smb:TSMBCommand;
  dwFromLen,dwToLen:DWORD;
  cHiMsgCode,cLoMsgCode:char;
  dwD5ALength,dwD7Length:DWORD;
  dwSended:DWORD;
  {$IFDEF DEBUG}
  fs:tFileStream;
  {$ENDIF}
begin
  result := false;
  sMessage := ToOem(Atext);
  dwMessageLen := Length(sMessage);
  pMessage:=Pchar(sMessage);
  Session := 0;
  {$IFDEF DEBUG}
  fs:=TFileStream.Create(ExtractFilePath(ParamStr(0))+'send'+DateTostr(Now)+'.txt',fmOpenWrite or fmCreate or fmShareCompat);
  fs.Position := fs.Size;
  try
  {$ENDIF}
  Nb:=TNetBIOS.Create(Self.AdapterIndex);
  try
    Res := PrepareNBSession(nb,Alias,ATo);
    if Res <> NRC_GOODRET then
      raise ESenderError.CreateFmt(res,'NB: Can''t open session (err. $%x)',[Res]);
    Session := nb.LSN;
    dwFromLen := Length(Alias);
    dwToLen := Length(ATo);
    try
      // 1 Шлем заголовок
      smb.Init($D5);
      dwD5ALength := dwFromLen+2+dwToLen+2; //04+From+00+04+To+00
      smb.Data[1] := char(dwD5ALength);
      CopyStringToSMB(Ato,CopyStringToSMB(Alias,@smb.Data[3]));
      inc(dwD5ALength,3+smb.GetHeaderSize);
      res := nb.Send(Session,Pchar(@smb),dwD5ALength);
      {$IFDEF DEBUG}
      fs.Write(smb,dwD5ALength);
      {$ENDIF}
      if res <> NRC_GOODRET then
        raise ESenderError.CreateFmt(res,'NB: Can''t start session (err. $%x)',[Res]);
      // Ждем подтверждения
      res := nb.Receive(Session,Pchar(@smb),sizeof(smb));
      {$IFDEF DEBUG}
      fs.Write(smb,sizeof(smb));
      {$ENDIF}
      if res <> NRC_GOODRET then
        raise ESenderError.CreateFmt(res,'NB: No reply (err. $%x)',[Res]);
      cHiMsgCode := smb.Data[0];
      cLoMsgCode := smb.Data[1];

      // 2 Шлем сообщение кусочками

      dwSended := 0;
      while dwSended < dwMessageLen do
      begin
        smb.Init($D7);
        dwD7Length := 136 - 3 -5;
        if (dwSended+dwD7Length)>dwMessageLen then
          dwD7Length := dwMessageLen - dwSended;
        smb.Data[0] := cHiMsgCode;
        smb.Data[1] := cLoMsgCode;
        smb.Data[3] := char(dwD7Length+3);
        smb.Data[5] := #1;
        smb.Data[6] := char(dwD7Length);
        //StrLCopy(@smb.data[8],pMessage,dwD7Length);
        move(PMessage^,smb.data[8],dwD7Length);

        res := nb.Send(Session,Pchar(@smb),smb.GetHeaderSize+dwD7Length+5+3);
        {$IFDEF DEBUG}
        fs.Write(smb,smb.GetHeaderSize+dwD7Length+5+3);
        {$ENDIF}
        if Res <> NRC_GOODRET then
          raise ESenderError.CreateFmt(res,'NB: Can`t use session (err. $%x)',[Res]);
        inc(dwSended,dwD7Length);
        // Ждем подтверждения
        res := nb.Receive(Session,Pchar(@smb),sizeof(smb));
        {$IFDEF DEBUG}
        fs.Write(smb,sizeof(smb));
        {$ENDIF}
        if res <> NRC_GOODRET then
          raise ESenderError.CreateFmt(res,'NB: No reply (err. $%x)',[Res]);
      end;

      // 3 Шлем извещение что все отослано
      smb.Init($d6);
      smb.Data[0] := cHiMsgCode;
      smb.Data[1] := cLoMsgCode;
      res := nb.Send(Session,Pchar(@smb),smb.GetHeaderSize+5);
      {$IFDEF DEBUG}
      fs.Write(smb,smb.GetHeaderSize+5);
      {$ENDIF}
      if Res <> NRC_GOODRET then
        raise ESenderError.CreateFmt(res,'NB: Can`t close session (err. $%x)',[Res]);
      // Ждем подтверждения
      res := nb.Receive(Session,Pchar(@smb),sizeof(smb));
      {$IFDEF DEBUG}
      fs.Write(smb,sizeof(smb));
      {$ENDIF}
      if res <> NRC_GOODRET then
        raise ESenderError.CreateFmt(res,'NB: No reply (err. $%x)',[Res]);
      // 4 все!!!
      result := true;
    except
      result:=false;
      raise;
    end;
  finally
    nb.HangUp(Session);
    nb.free;
  end;
  {$IFDEF DEBUG}
  finally
    fs.free;
  end;  
  {$ENDIF}
end;

{ ESenderError }

constructor ESenderError.CreateFmt(ErrorCode: Byte; const Msg: string;
  const Args: array of const);
begin
  inherited CreateFmt(Msg,Args);
  Self.ErrorCode := Errorcode;
end;

end.
