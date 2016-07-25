unit UsersU;

interface
uses
  Windows,Contnrs,Classes;

type

  TUser=class
  public
    Address:string;
    Nick:string;
    AForm:TObject;
    Color:integer;
    Enabled:boolean;
    AType:integer;
    constructor Create;
    procedure Assign(Source:TUser);virtual;
  end;


  TUserList=class(TObjectList)
  private
    function GetItem(Index: Integer): TUser;
    procedure SetItem(Index: Integer; const Value: TUser);
  public
    property Items[Index: Integer]: TUser read GetItem write SetItem; default;
    function Add(AM:TUser):integer;
    function Remove(AM:TUser):Integer;
    function IndexOf(AM:TUser):Integer;
    function GetUserFromAddress(const Address:string):integer;
    function GetUserFromNick(const Nick:string):integer;
    procedure LoadFromNFR(const Filename:string);
    procedure SaveTo(const Filename:string);
    procedure LoadFrom(const Filename:string);
    procedure Assign(Source:TUserList);
    procedure CopyFrom(Source:TUserList);
  end;

  TUserGroup=class(TUser)
  private
    FUserList:TList;
    function GetItem(Index: Integer): Integer;
    procedure SetItem(Index: Integer; const Value: Integer);
  public
    constructor Create;
    destructor Destroy;override;
    property Items[Index: Integer]: Integer read GetItem write SetItem; default;
    function Add(Index:Integer):integer;
    function Remove(Index:Integer):Integer;
    function IndexOf(Index:Integer):Integer;
    function Count:integer;
    procedure Assign(Source:TUser);override;
  end;


implementation
uses
  SysUtils,IniFiles,Filectrl;

{ TUserList }

function TUserList.Add(AM: TUser): integer;
begin
  result:=inherited Add(am);
end;

procedure TUserList.Assign(Source: TUserList);
var
  i:integer;
begin
  Clear;
  for i:=0 to Source.Count-1 do
    Add(Source[i]);
end;

procedure TUserList.CopyFrom(Source: TUserList);
var
  u:tuser;
  i:integer;
begin
  clear;
  for i:=0 to Source.Count-1 do
  begin
    if Source.Items[i] is TUserGroup then
      u:=TUserGroup.Create
    else
      u:=TUser.Create;
    u.Assign(Source.Items[i]);
    Add(u);
  end;    
end;

function TUserList.GetItem(Index: Integer): TUser;
begin
  result:=inherited Items[index] as TUser;
end;

function TUserList.GetUserFromAddress(const Address: string): integer;
begin
  result:= count-1;
  while result>=0 do
    if Uppercase(Items[result].Address) = UpperCase(Address) then
      break
    else
      dec(result);
end;

function TUserList.GetUserFromNick(const Nick: string): integer;
begin
  result:= count-1;
  while result>=0 do
    if Items[result].Nick = Nick then
      break
    else
      dec(result);
end;

function TUserList.IndexOf(AM: TUser): Integer;
begin
  result:=inherited IndexOf(am);
end;

procedure TUserList.LoadFrom(const Filename: string);
var
  ini:TInifile;
  i:integer;
  u:TUser;
  Sect:string;
  SectList:TStringList;
  t,j:integer;
  s:string;
begin
  Clear;
  ini:=TIniFile.Create(Filename);
  try
    SectList:=TStringList.Create;
    ini.ReadSections(SectList);
    for i:=0 to SectList.Count-1 do
    begin
      Sect:=SectList[i];
      t:=ini.ReadInteger(Sect,'Type',2);
      if t<>4 then
        u:=TUser.Create
      else
        u:=TUserGroup.Create;
      Add(u);
      u.AType := t;
      u.Address:=sect;
      u.Nick:=ini.readString(Sect,'Nick',Sect);
      u.Color:=ini.ReadInteger(sect,'Color',0);
      u.Enabled := ini.readBool(Sect,'Enabled',true);
      if t=4 then
      begin
        t:=0;
        repeat
          s:='User'+Inttostr(t);
          if not ini.ValueExists(Sect,s) then
            break;

          j:=ini.ReadInteger(Sect,s,0);
          (u as tUserGroup).Add(j);
          Inc(t);
        until false;
      end;
    end;
  finally
    ini.free;
  end;
end;

procedure TUserList.LoadFromNFR(const Filename: string);
var
  line:string;
  p,bp:pchar;
  U:TUser;
  s:string;
  t:integer;
  Address,Nick:string;
  Color:Integer;
  Enabled:boolean;
  sl:TStringList;
  i:integer;
begin
  Clear;
  if not FileExists(Filename) then
    exit;
  U:=nil;
  sl:=TStringList.Create;
  try
    sl.LoadFromFile(Filename);
    for i:=0 to sl.count-1 do
    begin
      line:=sl[i];
      if Length(line) =0 then
        continue;
      bp:=Pchar(line);
      p:=StrScan(bp,';');
      if p<>nil then
        SetString(s,bp,p-bp);
      if bp^ = #9 then
      begin
        t:=StrToInt(trim(s));
        if assigned(U) then
          (U as tUserGroup).Add(t);
        continue;
      end;
      bp:=p+1;
      Address:=s;
      p:=StrScan(bp,';');
      // IP - skip
  //    if p<>nil then
    //    SetString(s,bp,p-bp);
      bp:=p+1;

      p:=StrScan(bp,';');
      if p<>nil then
        SetString(s,bp,p-bp);
      bp:=p+1;
      Enabled := s='1';

      p:=StrScan(bp,';');
      if p<>nil then
        SetString(s,bp,p-bp);
      bp:=p+1;
      color:=StrToInt('$'+s);

      p:=StrScan(bp,';');
      if p<>nil then
        SetString(s,bp,p-bp);
      bp:=p+1;
      t:=StrtoInt(s);

      p:=StrScan(bp,';');
      if p<>nil then
        SetString(s,bp,p-bp);
      Nick := s;

      if t = 4 then
        U:=TUserGroup.Create
      else
        U:=TUser.Create;
      add(u);

      u.Address := address;
      u.Nick := nick;
      if nick ='' then
        u.nick := Address;
      u.Color := color;
      u.Enabled := Enabled;
      u.AType := t;

    end;
  finally
    sl.free;
  end;
end;

function TUserList.Remove(AM: TUser): Integer;
begin
  result:=inherited Remove(am);
end;

procedure TUserList.SaveTo(const Filename: string);
var
  ini:TMemInifile;
  i,t:integer;
  u:TUser;
  Sect:string;
begin
  ForceDirectories(ExtractFileDir(Filename));
  if fileexists(Filename) then
    DeleteFile(Filename);
  ini:=TMemIniFile.Create(Filename);
  try
    for i:=0 to Count-1 do
    begin
      u:=Items[i];
      Sect:=u.Address;
      ini.WriteString(Sect,'Nick',u.Nick);
      ini.WriteInteger(sect,'Color',u.Color);
      ini.WriteBool(Sect,'Enabled',u.Enabled);
      ini.WriteInteger(Sect,'Type',u.AType);
      if u.AType = 4 then
      begin
        for t:=0 to (u as tUserGroup).Count-1 do
          ini.WriteInteger(sect,'User'+Inttostr(t),TUserGroup(u).Items[t]);
      end;
    end;
  finally
    ini.UpdateFile;
    ini.free;
  end;

end;

procedure TUserList.SetItem(Index: Integer; const Value: TUser);
begin
  inherited Items[Index] := Value;
end;

{ TUserGroup }

function TUserGroup.Add(Index: Integer): integer;
begin
  result:=Fuserlist.Add(Pointer(Index));
end;

procedure TUserGroup.Assign(Source: TUser);
var
  i:integer;
begin
  inherited;
  with Source as TUserGroup do
  begin
    self.FUserList.Clear;
    for i:=0 to FUserList.Count-1 do
      self.Add(Integer(FUserList.Items[i]));
  end;
end;

function TUserGroup.Count: integer;
begin
  result:=FUserList.count;
end;

constructor TUserGroup.Create;
begin
  inherited;
  FuserList:=TList.Create;
end;

destructor TUserGroup.Destroy;
begin
  Fuserlist.free;
  inherited;
end;


function TUserGroup.GetItem(Index: Integer): Integer;
begin
  result:=integer(FUserList.items[index]);
end;

function TUserGroup.IndexOf(Index: Integer): Integer;
begin
  result:=integer(Fuserlist.IndexOf(pointer(Index)));
end;

function TUserGroup.Remove(Index: Integer): Integer;
begin
  result:=integer(Fuserlist.Remove(Pointer(Index)));
end;

procedure TUserGroup.SetItem(Index: Integer; const Value: Integer);
begin
  FUserList.Items[index]:=Pointer(Value);
end;

{ TUser }

procedure TUser.Assign(Source: TUser);
begin
  Address := Source.Address;
  Nick := Source.Nick;
  AForm := source.AForm;
  Color := Source.Color;
  Enabled := Source.Enabled;
  AType := Source.AType; 
end;

constructor TUser.Create;
begin
  inherited;
  Address:='';
  Nick:='';
  AForm:=nil;
  Color:=0;
  Enabled:=false;
  AType:=0;
end;

end.
