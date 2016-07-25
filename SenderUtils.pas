unit SenderUtils;

interface
uses
  Classes,SysUtils;

procedure SplitString(const Astr,ADelimiter:string;AStrings:TStrings);

implementation

procedure SplitString(const Astr,ADelimiter:string;AStrings:TStrings);
var
  bp,p:pchar;
  d:Pchar;
  s:string;
begin
  AStrings.Clear;
  bp:=Pchar(Astr);
  d:=Pchar(ADelimiter);
  repeat
    p:=AnsiStrPos(bp,d);
    if p=nil then
      break;
    SetString(s,bp,p-bp);
    AStrings.Add(s);
    bp:=p+1;
  until false;
  s:=string(bp);
  AStrings.Add(s);
end;

end.
