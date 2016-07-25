unit OptionsU;

interface
uses
  Windows;

type

  TOption=(opShowFavoritesOnly,opAutoStart,opUsersFilename,opContactListPos);
  TStringOptions=array[TOption] of string;

  TOptions=class
  private
    FIniFilename: string;
    FStringOptions:TStringOptions;
    procedure SetStringOption(const Index:tOption;const Value: string);
    function GetStringOption(const Index:TOption):string;
    procedure SetIntOption(const Index:tOption;Value: integer);
    function GetIntOption(const Index:TOption):integer;
    procedure SetIniFilename(const Value: string);
    function GetContactListPos: TRect;
    procedure SetContactListPos(const Value: TRect);
    function GetBoolOption(Index:TOption): boolean;
    procedure SetBoolOption(const Index:tOption; const Value: boolean);
    procedure SetAutoStart(const Index: TOption; const Value: boolean);
  protected
    function ExpandVariables(const S:string):string;
  public
    property iniFilename:string read FIniFilename write SetIniFilename;
    property UsersFilename:string index opUsersFilename read GetStringOption write SetStringOption;
    property ContactListPos:TRect read GetContactListPos write SetContactListPos;
    property AutoStart:boolean index opAutoStart read GetBoolOption write SetAutoStart;
    property ShowFavoritesOnly:boolean index opShowFavoritesOnly read GetBoolOption write SetBoolOption;
    constructor Create;
    destructor Destroy;override;
    procedure LoadFrom(const Filename:string);
    procedure SaveTo(const Filename:string);
  end;

  TOptionSections=(osGeneral,osContactList);
  TStringOptionRec=record
    Section:TOptionSections;
    Name:string;
    Default:string;
  end;


var
 Options:TOptions;

const
  sAppName='FreeTalk';
  sRegOptions='\Software\AZ\FreeTalk';

  OptDefinition:array[Toption] of TStringOptionRec = (
    (Section:osGeneral;Name:'ShowFavoritesOnly';Default:'1'),
    (Section:osGeneral;Name:'AutoStart';Default:'1'),
    (Section:osGeneral;Name:'UsersFileName';Default:'%USERPROFILE%\Application Data\FreeTalk\users.ini'),
    (Section:osContactList;Name:'Pos';Default:'100,100,300,400')
  );

  SectNames:array[TOptionSections] of string = (
     'General','ContactList'
  );

implementation
uses
  Sysutils,IniFiles,Registry,Classes,SenderUtils;

{ TOption }

constructor TOptions.Create;
var
  Reg:TRegistry;
begin
  inherited Create;
  Reg:=TRegistry.Create(KEY_READ);
  FIniFilename := '';
  try
    if reg.OpenKeyReadOnly(sRegOptions) then
    begin
      FiniFilename:=ExpandVariables(reg.ReadString('IniFilename'));
    end
  finally
    reg.free;
  end;
  if FIniFilename = '' then
    FiniFilename:=ExtractFilepath(ParamStr(0))+'options.ini';
  LoadFrom(FIniFilename);
end;


destructor TOptions.Destroy;
begin
  SaveTo(FIniFilename);
  inherited;
end;

function TOptions.ExpandVariables(const S: string): string;
var
  d:dword;
  p:pchar;
begin
//  SetLength(result,length(s));
  d:=ExpandEnvironmentStrings(Pchar(s),nil,0);
  getmem(p,d);
  try
    ExpandEnvironmentStrings(pchar(s),P,d);
    result:=string(p);
  finally
    freemem(p);
  end;
end;


function TOptions.GetBoolOption(Index: TOption): boolean;
begin
  result:=boolean(GetIntOption(Index));
end;

function TOptions.GetContactListPos: TRect;
var
  s:string;
  sl:tStringList;
begin
  s:=FStringOptions[opContactListPos];
  sl:=TStringList.Create;
  try
    SplitString(s,',',sl);
    with result,sl do
    begin
      Left := StrToInt(strings[0]);
      top := StrToInt(strings[1]);
      Right := StrToInt(strings[2]);
      Bottom := StrToInt(strings[3]);
    end;
  finally
    sl.free;
  end;
end;

function TOptions.GetIntOption(const Index: TOption): integer;
begin
  result:=StrToInt(FStringOptions[Index]);
end;

function TOptions.GetStringOption(const Index: TOption): string;
begin
  result:=ExpandVariables(FStringOptions[Index]);
end;

procedure TOptions.LoadFrom(const Filename: string);
var
  ini:TMemIniFile;
  i:toption;
begin
  ini:=TmemIniFile.Create(Filename);
  try
    for i:=Low(TOption) to High(TOption) do
      Fstringoptions[i]:=ini.readString(
        Sectnames[OptDefinition[i].Section],
        Optdefinition[i].Name,
        Optdefinition[i].Default
      );
  finally
    ini.free;
  end;
end;

procedure TOptions.SaveTo(const Filename: string);
var
  ini:TiniFile;
  i:toption;
begin
  ini:=TIniFile.Create(Filename);
  try
    for i:=Low(TOption) to High(TOption) do
      ini.WriteString(
        Sectnames[OptDefinition[i].Section],
        Optdefinition[i].Name,
        Fstringoptions[i]
      );
  finally
    ini.free;
  end;
end;


procedure TOptions.SetAutoStart(const Index: TOption;
  const Value: boolean);
var
  r:TRegistry;
begin
  SetBoolOption(Index,Value);
  r:=TRegistry.Create;
  try
    if r.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run',true) then
      if value then
        r.WriteString(sAppName,ParamStr(0))
      else
        r.DeleteValue(sAppName);  
  finally
    r.free;
  end;

end;

procedure TOptions.SetBoolOption(const Index: tOption;
  const Value: boolean);
begin
  SetIntOption(Index,Integer(value));
end;

procedure TOptions.SetContactListPos(const Value: TRect);
begin
  with value do
    FStringOptions[opContactListPos]:=format('%d,%d,%d,%d',[left,top,right,bottom]);
end;

procedure TOptions.SetIniFilename(const Value: string);
var
  Reg:TRegistry;
begin
  FIniFilename := Value;
  Reg:=TRegistry.Create(KEY_ALL_ACCESS);
  try
    if reg.OpenKey(sRegOptions,True) then
    begin
      reg.WriteString('IniFilename',Value);
    end
  finally
    reg.free;
  end;
end;

procedure TOptions.SetIntOption(const Index: tOption; Value: integer);
begin
  FStringOptions[Index]:=IntTostr(Value);;
end;

procedure TOptions.SetStringOption(const Index: tOption; const Value: string);
begin
  FStringOptions[Index]:=value;
end;

initialization
  Options:=TOptions.Create;
finalization
  Options.Free;  
end.
