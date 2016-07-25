
{.$DEFINE DEBUG}
unit SenderReceveThread;

interface

uses
  Classes,Windows,SysUtils;

type
  TSenderReceveThread = class(TThread)
  private
    fSender: TObject;
    { Private declarations }
  protected
    sFrom,sTo,sReal,sText:string;
    FSession:Byte;
    sError:string;
    iErrorCode:byte;
    procedure Execute; override;
    procedure LogReceivedMessage;
    procedure SendError;
  public
    property Session:Byte read FSession;
    property Sender:TObject read fSender;
    constructor Create(ASender:TObject;ASession:Byte);
  end;

implementation
uses
  netbiosU,SenderU,NB30;

{ Important: Methods and properties of objects in VCL can only be used in a
  method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure TSenderReceveThread.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ TSenderReceveThread }

constructor TSenderReceveThread.Create(ASender: TObject;ASession:Byte);
begin
  inherited Create(true);
  fSender := ASender;
  FreeOnTerminate := true;
  FSession:=ASession;
//  resume;
end;

procedure TSenderReceveThread.Execute;
var
  nb:TNetBIOS;
  res:Byte;
  smb:TSMBCommand;
  reply:TSMBCommand;
  dwReaded:DWORD;
  dwLen:dword;
  p:pchar;
  sTemp:string;
  {$IFDEF DEBUG}
  fs:TFileStream;
  sLog:string;
  i:integer;
  {$ENDIF}
begin
  { Place thread code here }
  nb:=TNetBIOS.Create((Sender as TSender).AdapterIndex);
  {$IFDEF DEBUG}
  fs:=TFileStream.Create(ExtractFilePath(ParamStr(0))+'log'+DateToStr(Now)+'.log',fmCreate);
  i:=1;
  {$ENDIF}
  try
    try
      while not Terminated do
      begin
        smb.Init(0);
        //FillChar(smb,sizeof(smb),0);
        res := nb.Receive(Session,Pchar(@smb),sizeof(smb));
        if res <> NRC_GOODRET then
          raise ESenderError.CreateFmt(res,'Error while receiving netbios data block, err. $%x',[Res]);
        dwReaded := nb.Length;
        {$IFDEF DEBUG}
        sLog:=Format('Message #%d:'#13#10,[i]);
        inc(i);
        fs.WriteBuffer(Pchar(sLog)^,length(sLog));
        fs.WriteBuffer(smb,sizeof(smb));
        {$ENDIF}

        // Смотрим что к нам пришло - сообщение или что-то неизвестное
        if not (smb.Command in [$d0,$d5, $d6,$d7]) then
          raise ESenderError.CreateFmt(res,'Unknown message type: $%x',[smb.command]);
        reply.Init(smb.Command);
        dwlen:=smb.GetHeaderSize+3;
        if smb.Command = $d5 then
        begin
          reply.Data[0] := char(random(4) +1);
          reply.Data[1] := char(random(4) +1);
          inc(dwLen,2);
        end;
        res := nb.Send(Session,Pchar(@reply),dwLen);
        {$IFDEF DEBUG}
        sLog:=Format('Reply #%d:'#13#10,[i]);
        inc(i);
        fs.WriteBuffer(Pchar(sLog)^,length(sLog));
        fs.WriteBuffer(reply,dwLen);
        {$ENDIF}
        if res <> NRC_GOODRET then
          raise ESenderError.CreateFmt(res,'Error while replying. $%x',[Res]);
        case smb.Command of
          $d0 : begin
                  // Короткое сообщение, вытаскиваем данные и выходим...
                  p:=@(smb.Data[4]);
                  sFrom:=string(p);
                  inc(p, Length(sFrom)+2);
                  sTo:=string(p);
                  inc(p,length(sTo)+4);
                  sText:=string(p);
                  break;
                end;
          $d5 : begin
                  // Кусочковое сообщение, начало, Смотрим от кого и кому
                  p:=@(smb.Data[4]);
                  sFrom:=string(p);
                  inc(p, Length(sFrom)+2);
                  sTo:=string(p);
                  sText:='';
                end;
           $d6 : break; // Кусочковое сообщение, конец, Все получено, выходим
           $d7: begin
                  SetString(sTemp,Pchar(@(smb.Data[8])),dwReaded-smb.GetHeaderSize-8);
                  sText := stext + stemp;
                end;
        end;
      end;
      sReal := GetRealSender((sender as tSender).Alias,Session,nb);
      stext := ToAnsi(stext);
      Synchronize(LogReceivedMessage);
    except
      on e:ESenderError do
      begin
        iErrorCode:=e.ErrorCode;
        sError := e.Message;
        Synchronize(SendError);
      end;
      on e:Exception do
      begin
        iErrorcode:=0;
        sError := e.Message;
        Synchronize(SendError);
      end;
    end;  
  finally
    nb.HangUp(Session);
    nb.Free;
    {$IFDEF DEBUG}
    fs.free;
    {$ENDIF}
  end;
end;

procedure TSenderReceveThread.LogReceivedMessage;
begin
  (sender as tSender).DoLogReceivedMessage(sFrom,sTo,sReal,sText);
end;

procedure TSenderReceveThread.SendError;
begin
  if Assigned(Sender) and (sender is tSender) then
    (sender as Tsender).DoError(iErrorcode,sError);
end;

end.

