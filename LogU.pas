unit LogU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TfmLog = class(TForm)
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Log(const AStr:string);
  end;

var
  fmLog: TfmLog;

implementation

{$R *.DFM}

procedure TfmLog.FormCreate(Sender: TObject);
begin
  memo1.Clear;
end;

procedure TfmLog.Log(const AStr: string);
begin
  memo1.Lines.add(Astr);
end;

end.
