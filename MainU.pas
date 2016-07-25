unit MainU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,  SenderU,
  StdCtrls,SenderMessagesU, ComCtrls, MultiLineListBox,UsersU, ActnList,
  Menus, ToolWin, ImgList;

const
  WM_TRAY = WM_USER+1;

type
  TfmMain = class(TForm)
    Button1: TButton;
    lbContactList: TListBox;
    pmMain: TPopupMenu;
    ActionList1: TActionList;
    acExit: TAction;
    acImportFVR: TAction;
    OpenDialog1: TOpenDialog;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    acTestReceve: TAction;
    acEditUsers: TAction;
    N4: TMenuItem;
    N5: TMenuItem;
    acSettings: TAction;
    N6: TMenuItem;
    acShowLog: TAction;
    N7: TMenuItem;
    testRecive1: TMenuItem;
    ToolBar1: TToolBar;
    ImageList1: TImageList;
    acToggleFavorites: TAction;
    ToolButton1: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure acExitExecute(Sender: TObject);
    procedure acImportFVRExecute(Sender: TObject);
    procedure lbContactListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lbContactListDblClick(Sender: TObject);
    procedure acTestReceveExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure acEditUsersExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure acSettingsExecute(Sender: TObject);
    procedure acShowLogExecute(Sender: TObject);
    procedure acToggleFavoritesExecute(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMTray(var Msg:Messages.TMessage);message WM_TRAY;
  public
    { Public declarations }
    ASender:TSender;
    Users:TUserList;
    CloseAction:TCloseAction;
    procedure LogRecevedMsg(Sender:TObject;const sFrom,sTo,sRealFrom,sMessage:string);
    procedure LogSenderError(sender:TObject;ErrorCode:Byte;const ErrorMsg:string);
    procedure RefreshContact;
    function  GetFormForUser(User:TObject):tForm;
    procedure SendMessage(const sTo,sMessage:string);
    procedure TrayIcon(Add:Boolean);
  end;

var
  fmMain: TfmMain;


implementation
uses
  netbiosU,nb30,OptionsU,DialogFormU,AddUserForm,ShellApi,SettingsU,LogU;

{$R *.DFM}

procedure TfmMain.FormCreate(Sender: TObject);
var
  LanIndex:Byte;
  enum:TLanaEnum;
begin
  acToggleFavorites.Checked := optionsu.options.ShowFavoritesOnly;


  try
    users:=TUserList.Create;
    users.LoadFrom(options.UsersFilename);
    RefreshContact;
  except
    users:=nil;
    raise;
  end;

  if TNetBIOS.EnumerateAdapters(@enum) <> NRC_GOODRET then
    LanIndex:=0
  else
  begin
    LanIndex:=Byte(enum.lana[0])
  end;

  try
    ASender:=TSender.Create(LanIndex);
    ASender.LogReceivedMessage := LogRecevedMsg;
    ASender.SenderErrorEvent := LogSenderError;
  except
    ASender := nil;
    raise;
  end;

  Button1.Width := self.ClientWidth;

  BoundsRect := Optionsu.Options.ContactListPos;

  Closeaction:=caNone;

  TrayIcon(True);


end;

procedure TfmMain.LogRecevedMsg(Sender: TObject; const sFrom, sTo,
  sRealFrom, sMessage: string);
var
  u:TUser;
  i:integer;
begin
{  m:=TMessage.Create(sRealFrom,sMessage,True);
  ml.Add(m);
  lbLog.Items.Add(sMessage);}
//  ShowMessage(Format('От %s (%s)'#13#10'%s',[sRealFrom,TimeToStr(now),sMessage]));
  i:=users.GetUserFromAddress(sRealFrom);
  if i<0 then
  begin
    u:=TUser.Create;
    u.Address := sRealFrom;
    u.Nick := sRealFrom;
    u.AType := 2;
    users.Add(u);
    lbContactList.Items.AddObject(sRealFrom,u);
  end
  else
    u:=users[i];
  with GetFormForUser(u) as TDialogForm do
  begin
    ReceveMessage(srealfrom,sMessage);
  end;
end;

procedure TfmMain.Button1Click(Sender: TObject);
var
  p:TPoint;
begin;
  GetCursorPos(p);
  pmMain.Popup(p.x,p.y);
end;

procedure TfmMain.LogSenderError(sender: TObject; ErrorCode: Byte;
  const ErrorMsg: string);
begin
  logu.fmLog.Log(format('%s'#13#10'Error: 0x%x'#13#10'%s',[Datetimetostr(now),ErrorCode,ErrorMsg]));
end;

procedure TfmMain.acExitExecute(Sender: TObject);
begin
  CloseAction:=caFree;
  close;
end;

procedure TfmMain.acImportFVRExecute(Sender: TObject);
begin
  with OpenDialog1 do
  begin
    Filter:='FVR files (*.fvr)|*.fvr|Все файлы (*.*)|*.*';
    if Execute then
    begin
      users.LoadFromNFR(FileName);
      users.SaveTo(OptionsU.Options.UsersFilename);
      RefreshContact;
    end;
  end;
end;

procedure TfmMain.RefreshContact;
var
  i:integer;
  u:TUser;
begin
  with lbContactList.Items do
  try
    BeginUpdate;
    lbContactList.Clear;
    for i:=0 to users.Count-1 do
    begin
      u:=users[i];
      if Optionsu.options.ShowFavoritesOnly then
      begin
        if u.Enabled then
          AddObject(u.Nick,u);
      end
      else
        AddObject(u.Nick,u);
    end;  
  finally
    EndUpdate;
  end;
end;

procedure TfmMain.lbContactListDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  u:Tuser;
begin
  with lbContactList do
  begin
    Canvas.Brush.Color := Color;
    Canvas.FillRect(rect);
    u:=Tuser(Items.Objects[Index]);
    canvas.Font.color := u.Color;
    Canvas.TextOut(rect.Left,rect.Top,Items[index]);
    Canvas.pen.Color := clGrayText;
  end;
end;

procedure TfmMain.lbContactListDblClick(Sender: TObject);
begin
  GetFormForUser(lbContactList.Items.Objects[lbContactList.ItemIndex]).show;
end;

function TfmMain.GetFormForUser(User: TObject): tForm;
var
  u:TUser absolute User;
begin
  if not Assigned(u.AForm) then
  begin
    Application.CreateForm(TDialogForm,u.Aform);
  end;
  (u.AForm as tDialogForm).user := u;
  result:=u.AForm as tDialogForm;
end;

procedure TfmMain.SendMessage(const sTo, sMessage: string);
begin
//  try
    Asender.SendText(sTo,sMessage);
{  except
    on e:ESenderError do
      logu.fmLog.log(e.Message);
  end;}
end;

procedure TfmMain.acTestReceveExecute(Sender: TObject);
begin
  LogRecevedMsg(Asender,'21-411-4a','21-411-8-s','21-411-4','Test');
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  TrayIcon(false);
  optionsu.options.ContactListPos := BoundsRect;
  users.SaveTo(optionsu.Options.UsersFilename);

  if Assigned(ASender) then
    Asender.Free;
  if Assigned(Users) then
    Users.free;

end;

procedure TfmMain.acEditUsersExecute(Sender: TObject);
begin
  With TfmUsers.Create(Self) do
  try
//    Parent:=Application;
    Users.CopyFrom(self.Users);
    RefreshUsers;
    if ShowModal = mrOk then
    begin
      Self.Users.CopyFrom(Users);
      Self.RefreshContact;
      users.SaveTo(optionsu.Options.UsersFilename);
    end;
  finally
    Free;
  end;
end;

procedure TfmMain.CreateParams(var Params: TCreateParams);
begin
  inherited;
  params.ExStyle := params.ExStyle or WS_EX_TOOLWINDOW;
end;

procedure TfmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:=closeaction;
  if action = caNone then
    self.Hide;
end;

procedure TfmMain.TrayIcon(Add: Boolean);
var
  NID:TNotifyIconData;
const
  ar:array[boolean] of Cardinal = (NIM_DELETE,NIM_ADD);
begin
  fillchar(NID,Sizeof(nid),0);
  nid.cbSize := sizeof(nid);
  nid.Wnd := Self.Handle;
  nid.uID := $0;
  nid.uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
  nid.uCallbackMessage := WM_TRAY;
  nid.hIcon := Application.Icon.Handle;
  StrPLCopy(@nid.szTip,Caption,sizeof(nid.szTip));
  Shell_NotifyIcon(ar[Add],@NID);
end;

procedure TfmMain.WMTray(var Msg: Messages.TMessage);
begin
  if msg.LParam = WM_LBUTTONDBLCLK then
  begin
    if not self.Visible then
          self.show;
   SetForegroundWindow(self.handle);
  end;
end;

procedure TfmMain.acSettingsExecute(Sender: TObject);
begin
  with TfmSettings.Create(Self) do
  try
    if ShowModal = mrOk then
      ApplySettings;
  finally
    Free;
  end;

end;

procedure TfmMain.acShowLogExecute(Sender: TObject);
begin
  logu.fmLog.show;
end;

procedure TfmMain.acToggleFavoritesExecute(Sender: TObject);
begin
  OptionsU.Options.ShowFavoritesOnly := not OptionsU.Options.ShowFavoritesOnly ;
  RefreshContact;  
end;

end.
