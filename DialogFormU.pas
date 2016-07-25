unit DialogFormU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, MultiLineListBox, ImgList;

type
  TDialogForm = class(TForm)
    lbLog: TMultiLineListBox;
    Panel1: TPanel;
    Splitter1: TSplitter;
    meText: TMemo;
    btSend: TButton;
    ImageList1: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btSendClick(Sender: TObject);
    procedure lbLogGetImageIndex(Control: TWinControl; ItemIndex: Integer;
      State: TOwnerDrawState; var ImageIndex: Integer);
    procedure meTextKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    Fuser: TObject;
    procedure Setuser(const Value: TObject);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public declarations }
    property user:TObject read Fuser write Setuser;
    procedure SendMessage;
    procedure ReceveMessage(const sFrom,sText:string);
  end;


implementation
uses
  UsersU,MainU;

{$R *.DFM}

procedure TDialogForm.FormCreate(Sender: TObject);
begin
  lblog.Align:=alClient;
end;

procedure TDialogForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action:=caHide;
end;

procedure TDialogForm.Setuser(const Value: TObject);
begin
  Fuser := Value;
  with user as tUser do
    caption := Format('%s (%s)',[Nick,Address]);
end;

procedure TDialogForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
end;

procedure TDialogForm.btSendClick(Sender: TObject);
begin
  SendMessage;
end;

procedure TDialogForm.SendMessage;
begin
  Mainu.fmMain.SendMessage(TUser(user).Address,meText.Text);
  lbLog.Items.AddObject(Format('Äëÿ %s (%s)'+#13#10+'%s',[TUser(user).Nick,Timetostr(Now),meText.Text]),TObject(Pointer(0)));
  lblog.ItemIndex := lbLog.Items.Count-1;
  metext.Clear;
end;

procedure TDialogForm.ReceveMessage(const sFrom, sText: string);
begin
  lbLog.Items.AddObject(Format('Îò %s (%s)'+#13#10+'%s',[sFrom,Timetostr(Now),sText]),TObject(Pointer(1)));
  Show;
  if Visible then
    FlashWindow(Handle,true)
  else
    Show;
  lblog.ItemIndex := lbLog.Items.Count-1;
  meText.SetFocus;
end;

procedure TDialogForm.lbLogGetImageIndex(Control: TWinControl;
  ItemIndex: Integer; State: TOwnerDrawState; var ImageIndex: Integer);
begin
  ImageIndex:=Integer(lbLog.Items.Objects[ItemIndex]);
end;

procedure TDialogForm.meTextKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (Key = VK_RETURN) then
    SendMessage;
end;

end.
