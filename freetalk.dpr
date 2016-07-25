program freetalk;

uses
  Windows,
  Forms,
  MainU in 'MainU.pas' {fmMain},
  netbiosU in 'netbiosU.pas',
  SenderU in 'SenderU.pas',
  SenderListenerThread in 'SenderListenerThread.pas',
  SenderReceveThread in 'SenderReceveThread.pas',
  SenderMessagesU in 'SenderMessagesU.pas',
  UsersU in 'UsersU.pas',
  OptionsU in 'OptionsU.pas',
  DialogFormU in 'DialogFormU.pas' {DialogForm},
  SenderUtils in 'SenderUtils.pas',
  AddUserForm in 'AddUserForm.pas' {fmUsers},
  SettingsU in 'SettingsU.pas' {fmSettings},
  LogU in 'LogU.pas' {fmLog};

{$R *.RES}

begin
  Application.Initialize;
  SetWindowLOng(Application.Handle, GWL_EXSTYLE , GetWindowLongA(Application.Handle,GWL_EXSTYLE) or WS_EX_TOOLWINDOW); 
  Application.CreateForm(TfmMain, fmMain);
  Application.CreateForm(TfmLog, fmLog);
  Application.Run;
end.
