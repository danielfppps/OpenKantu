unit kantu_status;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls;

type

  { TStatusForm }

  TStatusForm = class(TForm)
    Button1: TButton;
    extraLabel: TLabel;
    ProgressBar1: TProgressBar;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    isCancel: boolean;
  end; 

var
  StatusForm: TStatusForm;

implementation

{$R *.lfm}

{ TStatusForm }

procedure TStatusForm.FormCreate(Sender: TObject);
begin

end;

procedure TStatusForm.Button1Click(Sender: TObject);
begin
  isCancel := true;
  StatusForm.Visible := false;
end;

end.

