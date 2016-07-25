unit netbiosU;

interface
uses
  Windows,nb30,SysUtils;

const
  MAXMACHINENAME = 16;

type

  TAdapterStatusSingle=packed record
    AdapterStatus:TAdapterStatus;
    NameBuffers:array [0..NCBNAMSZ-1] of TNameBuffer;
  end;
  PAdapterStatusSingle = ^ TAdapterStatusSingle;

  TSessionStatus=packed record
    Header:TSessionHeader;
    Buffers:array [0..NCBNAMSZ-1] of TSessionBuffer;
  end;
  PSessionStatus = ^TSessionStatus; 


  TNetBIOS=class
  private
    FLanAdapterIndex: Byte;
    FPNCB:pNCB;
    function GetLSN: Byte;
    function GetLength: Word;
    function GetBuffer: Pchar;
    function GetCommand: Byte;
  protected
    function InitNCB(ACommand:Byte):PNCB;
    function NetBios:Byte;
  public
    property LanAdapterIndex:Byte read FLanAdapterIndex;
    property LSN:Byte read GetLSN;
    property Length:Word read GetLength;
    property Buffer:Pchar read GetBuffer;
    property Command:Byte read GetCommand;
    constructor Create(ALanAdapterIndex:integer);
    destructor Destroy;override;
    procedure Clear;
    function Assign(const Source:TNetBios):TNetBIOS;
    function Fill(const Source:TNetBios):TNetBIOS;
    function AddName(const AName:string):Byte;
    function AddNameEx(Aname:PChar):Byte;
    function AddGroupName(const AName:string):Byte;
    function AddGroupNameEx(Aname:PChar):Byte;
    function DeleteName(const AName:string):Byte;
    function DeleteNameEx(Aname:PChar):Byte;
    // Data Transfer Services
    function Call(AFrom,ATo:Pchar;ASendTimeOutMSec,ARecvTimeOutMSec:DWORD):Byte;overload;
    function Call(const AFrom,ATo:string;ASendTimeOutMSec,ARecvTimeOutMSec:DWORD):Byte;overload;
    function Listen(AFrom,ATo:Pchar;ASendTimeOutMSec,ARecvTimeOutMSec:DWORD):Byte;overload;
    function Listen(const AFrom,ATo:string;ASendTimeOutMSec,ARecvTimeOutMSec:DWORD):Byte;overload;
    function HangUp(ASession:Byte):Byte;
    // Connectionless Data Transfer
    function Cancel:Byte;
    function Send(ASession:Byte;Packet:PChar;Size:DWORD):byte;
    function SendNoAck(ASession:Byte;Packet:PChar;Size:DWORD):byte;
    function SendDatagram(ASession:Byte;Packet:PChar;Size:DWORD):byte;
    function Receive(ASession:Byte;Packet:PChar;Size:DWORD):byte;
    function ReceiveDatagram(ASession:Byte;Packet:PChar;Size:DWORD):byte;
    // General Purpose Services
    function Reset(Asession:Byte;NCBS:Byte):Byte;
    function GetAdapterStatus(Name:Pchar):byte;overload;
    function GetAdapterStatus(Name:string):byte;overload;
    function GetSessionStatus(Name:Pchar):byte;overload;
    function GetSessionStatus(Name:string):byte;overload;
    class function EnumerateAdapters(Enum:PLanaEnum):Byte;
  end;

procedure MakeNetBIOSName(Src,Dest:Pchar; LastChar: Byte);
function GetNetBIOSName(Name:string;LastChar:Byte):string;
function GetRealSender(const Alias:string; ASession: Byte; NetBIOS: TNetBIOS): string;


function ToOem(const S:string):string;
function ToAnsi(const S:string):string;



implementation


function ToOem(const S:string):string;
begin
  SetLength(result,Length(s));
  CharToOem(Pchar(s),Pchar(result));
end;

function ToAnsi(const S:string):string;
begin
  SetLength(result,Length(s));
  OemToChar(Pchar(s),Pchar(result));
end;


function GetRealSender(const Alias:string; ASession: Byte; NetBIOS: TNetBIOS): string;
var
  p:PSessionStatus;
  pc:pchar absolute p;
  i:integer;
begin
  result := '';
  if NetBIOS.GetSessionStatus(Getnetbiosname(Alias,3)) = NRC_GOODRET then
  begin
    pc := NetBIOS.Buffer;
    for i:=0 to p.header.num_sess-1 do
     if p.Buffers[i].lsn = ASession then
     begin
       SetString(result,p.Buffers[i].remote_name,StrLen(p.Buffers[i].remote_name)-2);
       result:=Trim(result);
       break;
     end;
  end;
end;


procedure MakeNetBIOSName(Src,Dest:Pchar; LastChar: Byte);
var
  dwLen:DWORD;
begin
  Fillchar(Dest^,MAXMACHINENAME,0);
  if Src <> nil then StrCopy(Dest,Src);
  dwLen:=StrLen(Dest);
  StrUpper(Dest);
  while (dwLen < MAXMACHINENAME) do
  begin
    Dest[dwLen] := ' ';
    inc(dwLen);
  end;
  Dest[ MAXMACHINENAME -1] := Char(LastChar);
end;

function GetNetBIOSName(Name:string;LastChar:Byte):string;
begin
  Setlength(result,MAXMACHINENAME);
  MakeNetBIOSName(Pchar(Name),Pchar(result),LastChar);
end;


{ TNetBIOS }

function TNetBIOS.AddGroupName(const AName: string): Byte;
begin
  result:=AddGroupNameEx(Pchar(Aname));
end;

function TNetBIOS.AddGroupNameEx(Aname: PChar): Byte;
begin
  with InitNCB(NCBADDGRNAME)^ do
  begin
    //StrLCopy(@ncb_name,Aname,sizeof(ncb_name));
    move(Aname^,ncb_name,sizeof(ncb_name));
  end;
  result := NetBios;
end;

function TNetBIOS.AddName(const AName:string): Byte;
begin
  result:=AddNameEx(Pchar(Aname));
end;

function TNetBIOS.AddNameEx(AName: PChar): Byte;
begin
  with Initncb(NCBADDNAME)^ do
//    StrLCopy(@ncb_name,Aname,sizeof(ncb_name));
    move(Aname^,ncb_name,sizeof(ncb_name));
  result := NetBios;
end;

function TNetBIOS.Assign(const Source: TNetBios): TNetBIOS;
begin
  CopyMemory(FPNCB,Source.FPNCB,sizeof(Tncb));
  result := self;
end;

function TNetBIOS.Call(AFrom, ATo: Pchar; ASendTimeOutMSec,
  ARecvTimeOutMSec: DWORD): Byte;
begin
  with Initncb(NCBCALL)^ do
  begin
//    StrLCopy(ncb_name,AFrom,sizeof(ncb_name));
//    StrLCopy(ncb_callname,ATo,sizeof(ncb_callname));
    Move(AFrom^,ncb_name,sizeof(ncb_name));
    Move(ATo^,ncb_callname,sizeof(ncb_callname));
    ncb_rto := ArecvTimeoutMSec div 500;
    ncb_sto := ASendTimeOutMSec div 500;
  end;
  result := NetBios;
end;

function TNetBIOS.Call(const AFrom, ATo: string; ASendTimeOutMSec,
  ARecvTimeOutMSec: DWORD): Byte;
begin
  result := Call(pchar(Afrom),pchar(Ato),AsendtimeoutMSec,arecvtimeoutMSec);
end;

function TNetBIOS.Cancel: Byte;
begin
  FpNCB.ncb_lsn := FLanAdapterIndex;
  with TNetBIOS.Create(FLanAdapterIndex) do
  try
    With InitNCB(NCBCANCEL)^ do
    begin
      ncb_buffer := Pchar(Self.FpNCB);
      ncb_length := sizeof(TNCB);
    end;
    result:= NetBios;
  finally
    Free;
  end;

end;

procedure TNetBIOS.Clear;
begin
  FillChar(FPNCB^,SizeOf(TNCB),0);
//  ZeroMemory(@NCB,sizeof(NCB));
end;

constructor TNetBIOS.Create(ALanAdapterIndex: integer);
begin
  inherited Create;
  New(FPNCB);
  Clear;
  FLanAdapterIndex := ALanAdapterIndex;
end;

function TNetBIOS.DeleteName(const AName: string): Byte;
begin
  result := DeleteNameEx(Pchar(Aname));
end;

function TNetBIOS.DeleteNameEx(Aname: PChar): Byte;
begin
  with Initncb(NCBDELNAME)^ do
    //StrLCopy(@ncb_name,Aname,sizeof(ncb_name));
    move(Aname^,ncb_name,sizeof(ncb_name));
  result := NetBios;
end;

destructor TNetBIOS.Destroy;
begin
  Dispose(FpNCB);
  inherited;
end;

class function TNetBIOS.EnumerateAdapters(Enum: PLanaEnum): Byte;
var
  ANCB:TNCB;
begin
  ZeroMemory(@ANCB,sizeof(ANCB));
  ZeroMemory(Enum,sizeof(TlanaEnum));
  with Ancb do
  begin
    ncb_command := NCBENUM;
    ncb_buffer := Pchar(Enum);
    ncb_length := sizeof(TLanaEnum);
  end;
  result := nb30.Netbios(@ANCB);
end;

function TNetBIOS.Fill(const Source: TNetBios): TNetBIOS;
begin
  result := Assign(Source);
end;

function TNetBIOS.GetAdapterStatus(Name: Pchar): byte;
var
  a:TAdapterStatusSingle;
begin
  ZeroMemory(@a,sizeof(a));
  with InitNCB(NCBASTAT)^ do
  begin
//    StrLCopy(ncb_callname,Name,sizeof(ncb_callname));
    move(name^,ncb_callname,sizeof(ncb_callname));
    ncb_length := sizeof(a);
    ncb_buffer := @a;
  end;
  result:=NetBios;
end;

function TNetBIOS.GetAdapterStatus(Name: string): byte;
begin
  result := GetAdapterStatus(Pchar(Name));
end;

function TNetBIOS.GetBuffer: Pchar;
begin
  result := FPncb.ncb_buffer;
end;

function TNetBIOS.GetCommand: Byte;
begin
  result := FPncb.ncb_command;
end;


function TNetBIOS.GetLength: Word;
begin
  result := FPncb.ncb_length;
end;

function TNetBIOS.GetLSN: Byte;
begin
  result:=FPncb.ncb_lsn;
end;

function TNetBIOS.GetSessionStatus(Name: Pchar): byte;
var
  a:TSessionStatus;
begin
  ZeroMemory(@a,sizeof(a));
  with InitNCB(NCBSSTAT)^ do
  begin
    //StrLCopy(ncb_name,Name,sizeof(ncb_name));
    move(name^,ncb_name,sizeof(ncb_name));
    ncb_length := sizeof(a);
    ncb_buffer := @a;
  end;
  result:=NetBios;
end;

function TNetBIOS.GetSessionStatus(Name: string): byte;
begin
  result:=GetSessionStatus(Pchar(Name));
end;

function TNetBIOS.HangUp(ASession: Byte): Byte;
begin
  With InitNCB(NCBHANGUP)^ do
    ncb_lsn := ASession;
  result := NetBios;
end;

function TNetBIOS.InitNCB(ACommand: Byte): PNCB;
begin
  Clear;
  with FPncb^ do
  begin
    ncb_command := Acommand;
    ncb_lana_num := LanAdapterIndex;
  end;
  result := FPncb;
end;

function TNetBIOS.Listen(AFrom, ATo: Pchar; ASendTimeOutMSec,
  ARecvTimeOutMSec: DWORD): Byte;
begin
  with Initncb(NCBLISTEN)^ do
  begin
//    StrLCopy(ncb_name,AFrom,sizeof(ncb_name));
//    StrLCopy(ncb_callname,ATo,sizeof(ncb_callname));
    move(AFrom^,ncb_name,sizeof(ncb_name));
    move(ATo^,ncb_callname,sizeof(ncb_callname));
    ncb_rto := ArecvTimeoutMSec div 500;
    ncb_sto := ASendTimeOutMSec div 500;
  end;
  result := NetBios;
end;

function TNetBIOS.Listen(const AFrom, ATo: string; ASendTimeOutMSec,
  ARecvTimeOutMSec: DWORD): Byte;
begin
  result := Listen(pchar(Afrom),pchar(Ato),AsendtimeoutMSec,arecvtimeoutMSec);
end;

function TNetBIOS.NetBios: Byte;
begin
  Result:=nb30.Netbios(FpNCB);
end;

function TNetBIOS.Receive(ASession: Byte; Packet: PChar;
  Size: DWORD): byte;
begin
  with InitNCB(NCBRECV)^ do
  begin
    ncb_lsn := ASession;
    if Size > $FFFF then
      ncb_length := $FFFF
    else
      ncb_length := Size;
    ncb_buffer := Packet;
  end;
  result := Netbios;
end;

function TNetBIOS.ReceiveDatagram(ASession: Byte; Packet: PChar;
  Size: DWORD): byte;
begin
  with InitNCB(NCBDGRECV)^ do
  begin
    ncb_lsn := ASession;
    ncb_length := Size;
    ncb_buffer := Packet;
  end;
  result := NetBios;
end;

function TNetBIOS.Reset(Asession:Byte; NCBS: Byte): Byte;
begin
  with InitNCB(NCBRESET)^ do
  begin
    ncb_lsn := Asession;
    ncb_num := ncbs;
    ncb_callname[0] := #20;
    ncb_callname[2] := #20;
  end;
  result := Netbios;
end;

function TNetBIOS.Send(ASession: Byte; Packet: PChar; Size: DWORD): byte;
begin
  Assert(Size<$FFFF,'Size of packet must be less $FFFF');
  with InitNCB(NCBSEND)^ do
  begin
    ncb_lsn := ASession;
    ncb_length := Size;
    ncb_buffer := Packet;
  end;
  result := NetBios;
end;

function TNetBIOS.SendDatagram(ASession: Byte; Packet: PChar;
  Size: DWORD): byte;
begin
  with InitNCB(NCBDGSEND)^ do
  begin
    ncb_lsn := ASession;
    ncb_length := Size;
    ncb_buffer := Packet;
  end;
  result := NetBios;
end;

function TNetBIOS.SendNoAck(ASession: Byte; Packet: PChar;
  Size: DWORD): byte;
begin
  Assert(Size<$FFFF,'Size of packet must be less $FFFF');
  with InitNCB(NCBSENDNA)^ do
  begin
    ncb_lsn := ASession;
    ncb_length := Size;
    ncb_buffer := Packet;
  end;
  result := NetBios;
end;

end.
