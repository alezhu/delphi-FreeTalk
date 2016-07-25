unit SenderMessagesU;

interface
uses
  Windows,Contnrs;

type

  TMessage=class
  public
    Address:string;
    Text:string;
    Incoming:boolean;
    AForm:TObject;
    constructor Create(const Address,Text:string;Incoming:boolean);
  end;

  TMessageList=class(TObjectList)
  private
    function GetItem(Index: Integer): TMessage;
    procedure SetItem(Index: Integer; const Value: TMessage);
  public
    function Add(AM:TMessage):integer;
    function Remove(AM:TMessage):Integer;
    function IndexOf(AM:TMessage):Integer;
    property Items[Index: Integer]: TMessage read GetItem write SetItem; default;
  end;

implementation

{ TMessageList }

function TMessageList.Add(AM: TMessage): integer;
begin
  result:=inherited Add(am);
end;

function TMessageList.GetItem(Index: Integer): TMessage;
begin
  result:=inherited Items[index] as tMessage;
end;

function TMessageList.IndexOf(AM: TMessage): Integer;
begin
  result:=inherited IndexOf(am);
end;

function TMessageList.Remove(AM: TMessage): Integer;
begin
  result:=inherited Remove(am);
end;

procedure TMessageList.SetItem(Index: Integer; const Value: TMessage);
begin
  inherited Items[Index] := Value;
end;

{ TMessage }

constructor TMessage.Create(const Address,Text:string;Incoming:boolean);
begin
  inherited Create;
  self.Address := Address;
  self.Text := text;
  self.Incoming := Incoming;
  AForm:=nil;
end;

end.
