unit SettingsU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TfmSettings = class(TForm)
    cbAutoStart: TCheckBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadSettings;
    procedure ApplySettings;
  end;


implementation
uses
  OptionsU;

{$R *.DFM}

procedure TfmSettings.ApplySettings;
begin
  Options.AutoStart := cbAutoStart.Checked;
end;

procedure TfmSettings.FormCreate(Sender: TObject);
begin
  LoadSettings;
end;

procedure TfmSettings.LoadSettings;
begin
  cbAutoStart.Checked := Options.AutoStart;
end;

end.
