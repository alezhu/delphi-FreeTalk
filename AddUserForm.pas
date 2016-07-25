unit AddUserForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons,UsersU, CheckLst, ActnList;

type
  TFakeShape=class(TShape)
  published
    property OnDblClick;
  end;


  TfmUsers = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    edAddress: TEdit;
    Label2: TLabel;
    edNick: TEdit;
    Label3: TLabel;
    Shape1: TShape;
    bbAddr: TBitBtn;
    ColorDialog1: TColorDialog;
    lbUsers: TCheckListBox;
    Button1: TButton;
    Button2: TButton;
    btAddUser: TButton;
    Button4: TButton;
    ActionList1: TActionList;
    acAddUser: TAction;
    acDelUser: TAction;
    acUp: TAction;
    acDown: TAction;
    procedure FormDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lbUsersDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lbUsersClick(Sender: TObject);
    procedure acAddUserExecute(Sender: TObject);
    procedure acDelUserUpdate(Sender: TObject);
    procedure acDelUserExecute(Sender: TObject);
    procedure edNickChange(Sender: TObject);
    procedure edAddressChange(Sender: TObject);
  private
    FActiveUser: TUser;
    procedure SetActiveUser(const Value: TUser);
    { Private declarations }
  public
    { Public declarations }
    Users:TUserList;
    property ActiveUser:TUser read FActiveUser write SetActiveUser;
    procedure RefreshUsers;
  end;

implementation

{$R *.DFM}

procedure TfmUsers.FormDblClick(Sender: TObject);
begin
  if Not Assigned(ActiveUser) then
    Exit;
  ColorDialog1.Color:=ActiveUser.Color;
  if ColorDialog1.Execute then
  begin
    Shape1.Brush.Color := ColorDialog1.Color;
    ActiveUser.Color:=ColorDialog1.Color;
    lbusers.Invalidate;
  end;

end;

procedure TfmUsers.FormCreate(Sender: TObject);
begin
  TFakeShape(Shape1).ondblClick := formDblClick;
  Users:=TUserList.Create;
  lbUsers.Align:=alClient;
end;

procedure TfmUsers.SetActiveUser(const Value: TUser);
begin
  FActiveUser := Value;
  edAddress.Text := value.Address;
  edNick.Text := value.Nick;
  Shape1.brush.color := value.Color;
end;

procedure TfmUsers.FormDestroy(Sender: TObject);
begin
  if Assigned(Users) then
    Users.free;
end;

procedure TfmUsers.RefreshUsers;
var
  i:integer;
  lastIndex:integer;
begin
  with lbUsers do
  try
    lastindex:=ItemIndex;
    items.BeginUpdate;
    for i:=0 to Users.count -1 do
    begin
      Items.AddObject(users.Items[i].Nick,users[i]);
      Checked[i]:=users[i].Enabled;
    end;
  finally
    if lastIndex<0 then
      lastIndex:=0;
    if lastIndex>=Items.Count then
      lastIndex:=Items.Count-1;
    ItemIndex:=LastIndex;
    lbUsersClick(Self);
    items.EndUpdate;
  end;

end;

type
  TFakeCheckListBox=class(TCheckListBox);

procedure TfmUsers.lbUsersDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  Saveproc:TDrawItemEvent;
begin
  SaveProc:=lbUsers.OnDrawItem;
  try
    lbUsers.OnDrawItem := nil;
    lbusers.Canvas.Font.Color := TUser(lbUsers.Items.Objects[Index]).Color;
    lbusers.canvas.brush.color:=lbUsers.color;
    TFakeCheckListBox(lbUsers).DrawItem(Index,Rect,State);
  finally
    lbUsers.OnDrawItem := saveproc;
  end;
end;

procedure TfmUsers.lbUsersClick(Sender: TObject);
begin
  if (lbusers.ItemIndex<0) or (lbusers.ItemIndex > lbusers.Items.count) then
    exit;
  ActiveUser:=TUser(lbUsers.Items.Objects[lbUsers.ItemIndex]);
end;

procedure TfmUsers.acAddUserExecute(Sender: TObject);
var
  u:tUser;
begin
  u:=TUser.Create;
  users.Add(u);
  lbusers.ItemIndex := lbusers.Items.AddObject(u.Nick,u);
  ActiveUser := u;
//  lbusers.Selected[lbusers.ItemIndex] := true;
end;

procedure TfmUsers.acDelUserUpdate(Sender: TObject);
begin
  acDelUser.Enabled :=lbUsers.ItemIndex >=0;
end;

procedure TfmUsers.acDelUserExecute(Sender: TObject);
var
  u:Tuser;
  i:integer;
begin
  i:=lbusers.ItemIndex;
  if  i< 0 then
    exit;

  u:=TUser(lbusers.Items.Objects[i]);
  if assigned(u) then
  begin
    lbusers.items.Delete(i);
    users.Remove(u);
    lbusers.ItemIndex := i;
    lbUsersClick(self);
  end;

end;

procedure TfmUsers.edNickChange(Sender: TObject);
begin
  if assigned(ActiveUser ) then
  begin
    ActiveUser.Nick := edNick.Text;
    lbusers.items[lbusers.Items.IndexOfObject(ActiveUser)] := edNick.Text; 
  end;
end;

procedure TfmUsers.edAddressChange(Sender: TObject);
begin
  if assigned(ActiveUser) then
    ActiveUser.Address := edAddress.text;
end;

end.
