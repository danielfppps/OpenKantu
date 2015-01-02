unit kantu_portfolioResults;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids;

type

  { TPortfolioResultForm }

  TPortfolioResultForm = class(TForm)
    PortfolioResultsGrid: TStringGrid;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  PortfolioResultForm: TPortfolioResultForm;

implementation

{$R *.lfm}

end.

