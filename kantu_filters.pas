unit kantu_filters;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Grids;

type

  { TFiltersForm }

  TFiltersForm = class(TForm)
    Button1: TButton;
    isLastYearProfitCheck: TCheckBox;
    FiltersGrid: TStringGrid;
    procedure Button1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FiltersForm: TFiltersForm;

implementation

{$R *.lfm}

{ TFiltersForm }

procedure TFiltersForm.Button1Click(Sender: TObject);
begin
  FiltersForm.Visible := False;
end;

end.

