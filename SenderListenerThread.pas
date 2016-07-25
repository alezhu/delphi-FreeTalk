unit SenderListenerThread;

interface

uses
  Classes;

type
  TSenderListenerThread = class(TThread)
  private
    fSender: TObject;
    { Private declarations }
    TL:TThreadList;
  protected
    sLocalMachine:string;
    sError:string;
    iErrorCode:byte;
    procedure Execute; override;
    procedure OnThreadTerminate(Sender: TObject);
    procedure SendError;
  public
    property Sender:TObject read fSender;
    constructor Create(ASender:TObject);
    destructor Destroy;override;
  end;

implementation
uses
  SenderU,SenderReceveThread,netbiosU,Windows,nb30,SysUtils;

{ Important: Methods and properties of objects in VCL can only be used in a
  method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure SenderListenerThread.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ SenderListenerThread }

constructor TSenderListenerThread.Create(ASender: TObject);
begin
  inherited Create(True);
  FSender := Asender;
  TL:=TThreadList.Create;
  FreeOnTerminate:=false;
//  resume;
end;

destructor TSenderListenerThread.Destroy;
var
  t:TThread;
  i,c:integer;

begin
  repeat
    with tl.LockList do
    try
      c:=Count;
      for i:=Count-1 downto 0 do
      begin
        t := TObject(Items[i]) as TThread;
        if assigned(t) then
          t.Terminate;
      end;
    finally
      tl.UnlockList;
    end;
  until c = 0;
  tl.free;
  inherited;
end;

procedure TSenderListenerThread.Execute;
var
  nb:TNetBIOS;
  res:byte;
  Session:Byte;
  dwTimeOut:DWORD;
  t:TSenderReceveThread;
begin
  nb:=TNetBIOS.Create((sender as TSender).AdapterIndex);
  try
    try
      res := nb.Reset(0,0);
      if res <> NRC_GOODRET then
        raise ESenderError.CreateFmt(res,'Can''t reset netbios (err. $%x)',[Res]);
      sLocalMachine :=(sender as tSender).Alias;
      sLocalMachine:=GetNetBIOSName(sLocalMachine,3);
      res:=nb.AddName(sLocalMachine);
      if res <> NRC_GOODRET then
        raise ESenderError.CreateFmt(res,'Can''t add network alias (''%s'')! Netbios messages unaviable now (err. $%x)',[sLocalMachine,Res]);
      dwtimeout := 5000;
      while not Terminated do
      begin
        res := nb.Listen(Pchar(sLocalMachine),
        {Pchar(getNetBIOSNAME('*',3))}'*              '+#0,dwtimeout,dwtimeout);
        if res = NRC_GOODRET then
        begin
          Session:=nb.LSN;
          sError := Format('SessionNum: %d',[Session]);
          Synchronize(SendError);
          t:=TSenderReceveThread.Create(sender,Session);
          t.OnTerminate :=  OnThreadTerminate;
          with tl.LockList do
          try
            Add(t);
          finally
            tl.UnlockList;
          end;
          t.Resume;
        end
        else
          if not Terminated then
            raise ESenderError.CreateFmt(res,'Can''t listen for messages, err. $%x (alias ''%s'')',[Res,sLocalMachine]);
      end;
    except
      on e:ESenderError do
      begin
        sError:=e.Message;
        iErrorCode := e.ErrorCode;
        Synchronize(SendError);
      end;
    end;
  finally
    nb.free;
  end;

end;

procedure TSenderListenerThread.OnThreadTerminate(Sender: TObject);
begin
  with tl.LockList do
  try
    remove(Sender);
  finally
    tl.UnlockList;
  end;
end;

procedure TSenderListenerThread.SendError;
begin
  (Sender as TSender).DoError(iErrorCode,sError);
end;

end.
