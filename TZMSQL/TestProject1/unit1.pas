unit Unit1; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  DbCtrls, DBGrids, ZMConnection, ZMQueryDataSet, db;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Datasource1: TDatasource;
    DBGrid1: TDBGrid;
    DBNavigator1: TDBNavigator;
    ZMConnection1: TZMConnection;
    ZMQueryDataSet1: TZMQueryDataSet;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form1: TForm1; 

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  ShowMessage('Data is going to be loaded from: '+ ZMQueryDataset1.ZMConnection.DatabasePathFull+ZMQueryDataset1.TableName+'.csv');
  ZMQueryDataset1.LoadFromTable;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  vOriginalTableName:string;
begin
  try
    vOriginalTableName:=ZMQueryDataset1.TableName;
    ZMQueryDataset1.TableName:='Test';
     ShowMessage('Dataset is going to be saved to: '+ ZMQueryDataset1.ZMConnection.DatabasePathFull+ZMQueryDataset1.TableName+'.csv');
    ZMQueryDataset1.SaveToTable(SysUtils.DecimalSeparator);
  finally
    ZMQueryDataset1.TableName:=vOriginalTableName;
  end;

end;


end.

