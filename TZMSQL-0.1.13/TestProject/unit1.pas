unit Unit1; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, DBGrids,
  StdCtrls, DbCtrls, ZMConnection, ZMQueryDataSet, ZMReferentialKey, db;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Datasource1: TDatasource;
    Datasource2: TDatasource;
    Datasource3: TDatasource;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    DBGrid3: TDBGrid;
    DBNavigator1: TDBNavigator;
    DBNavigator2: TDBNavigator;
    ZMConnection1: TZMConnection;
    ZMQueryDataSet1: TZMQueryDataSet;
    ZMQueryDataSet2: TZMQueryDataSet;
    ZMQueryDataSet3: TZMQueryDataSet;
    ZMReferentialKey1: TZMReferentialKey;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);

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
  ShowMessage('Query for master dataset: '+ZMQueryDataset1.SQL.Text);
  ShowMessage('Query for detail dataset: '+ZMQueryDataset2.SQL.Text);
  ShowMessage('Please, wait...');
  ZMQueryDataset1.QueryExecute;
  ZMQueryDataset1.First;
  ZMQueryDataset2.QueryExecute;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  ShowMessage('Parameterized query: '+ZMQueryDataset3.SQL.Text);
  ShowMessage('Parameter: '+ZMQueryDataset3.Parameters[0].Name);
  ZMQueryDataset3.Parameters.ParamByName('Order').AsString:=ZMQueryDataset2.FieldByName('ProductionOrder').AsString;
  ShowMessage('Parameter''s value:'+ ZMQueryDataset3.Parameters.ParamByName('Order').AsString);
  ZMQueryDataset3.QueryExecute;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  ShowMessage('Hello. This simple demo project that demonstrates new features in zmsql 0.1.3 and 0.1.4.'
  + ' First, press the first button to execute queries to populate upper two dbgrids.'
  + ' Those two datasets are in master/detail synchronization. Scroll through records in master dataset and detail dataset will show only corresponding records.'
  + ' These two dataset are also in referential integrity relationship (insert, update, delete).'
  + ' If you change a Product or a ProductDescription in master dataset, records in detail dataset will be updated.'
  + ' If you insert a record in detail dataset, it will copy values for Product and ProductDescription from the master dataset.');
  ShowMessage(' Second, if you press the second button, it will execute a parameterized query for the third dbgrid.'
  + 'The query looks for the value in the detail dataset as parameter. '
  + 'Of course, don''t use it for the records that you have changed, since it will not be able to find the value of parameters....');
  ShowMessage('Third, pay attention that first two datasets have predefined FieldDefs, '
  + 'while the third dataset creates FieldDefs of ftString type on the fly.');
end;

end.

