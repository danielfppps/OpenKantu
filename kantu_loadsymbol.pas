unit kantu_loadSymbol;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, FileUtil, Forms, Controls, Graphics, Dialogs, CheckLst,
  StdCtrls, DbCtrls, DBGrids, ZMConnection, ZMQueryDataSet, kantu_definitions, kantu_simulation, kantu_singleSystem;

type

  { TloadSymbol }

  TloadSymbol = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    OpenDialog1: TOpenDialog;
    updateLoadedButton: TButton;
    SymbolsList: TCheckListBox;
    Datasource1: TDatasource;
    SymbolsGrid: TDBGrid;
    DBNavigator1: TDBNavigator;
    Label1: TLabel;
    ZMConnection1: TZMConnection;
    ZMQueryDataSet1: TZMQueryDataSet;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure DBNavigator1BeforeAction(Sender: TObject; Button: TDBNavButtonType
      );
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    { private declarations }
  public
    { public declarations }
    procedure updateIndicatorLoadedSymbols;
  end;

var
  loadSymbol: TloadSymbol;

implementation

{$R *.lfm}

{ TloadSymbol }
uses kantu_main, kantu_indicators;

procedure TloadSymbol.updateIndicatorLoadedSymbols;
var
  i: integer;
begin

  LoadedIndiHistoryData := nil ;
  SingleSystem.SymbolsCombo.Clear;

  for i:= 0 to SymbolsList.Count -1 do
  begin

       if SymbolsList.Checked[i] then
       begin
         loadSymbol.ZMQueryDataSet1.SQL.Clear;
         loadSymbol.ZMQueryDataSet1.SQL.Add('SELECT * FROM symbols');
         loadSymbol.ZMQueryDataSet1.SQL.Add('WHERE Symbol = ' + SymbolsList.Items[i]);
         loadSymbol.ZMQueryDataSet1.QueryExecute;
         if FileExists(SymbolsGrid.DataSource.DataSet.Fields[1].AsString) = false then
         begin
           ShowMessage('Selected history file does not exist. Please check path to be valid.');
           Exit;
         end;

         LoadIndicatorsAndHistory(SymbolsGrid.DataSource.DataSet.Fields[1].AsString);
         SingleSystem.SymbolsCombo.Items.Add(SymbolsGrid.DataSource.DataSet.Fields[0].AsString);

       end;

  end;

  if Length(LoadedIndiHistoryData) = 0 then
  ShowMessage('No instruments were selected for loading. Make sure you check the checkbox for the instruments you wish to load');


  loadSymbol.ZMQueryDataSet1.SQL.Clear;
  loadSymbol.ZMQueryDataSet1.SQL.Add('SELECT * FROM symbols');
  loadSymbol.ZMQueryDataSet1.QueryExecute;

end;


procedure TloadSymbol.Button1Click(Sender: TObject);
begin
    ZMQueryDataset1.TableName:='symbols';
     ShowMessage('Dataset is going to be saved to: '+ ZMQueryDataset1.ZMConnection.DatabasePathFull+ZMQueryDataset1.TableName+'.csv');
    ZMQueryDataset1.SaveToTable(';');

    loadSymbol.SymbolsList.Clear;

   loadSymbol.Datasource1.Enabled:=False; //Manual refresh of linked DBGrid
   loadSymbol.Datasource1.Enabled:=True;
   loadSymbol.ZMQueryDataSet1.SQL.Clear;
   loadSymbol.ZMQueryDataSet1.SQL.Add('SELECT * FROM symbols');
   loadSymbol.ZMQueryDataSet1.QueryExecute;

    with loadSymbol.SymbolsGrid.DataSource.DataSet do
 // begin
   // first;
     while not loadSymbol.SymbolsGrid.DataSource.DataSet.EOF do
     begin
        loadSymbol.SymbolsList.Items.Add(loadSymbol.SymbolsGrid.Columns[0].Field.AsString) ;
        loadSymbol.SymbolsGrid.DataSource.DataSet.Next;
     end ;
end;

procedure TloadSymbol.Button2Click(Sender: TObject);
var
  symbol,datafile,timeframe,minStop,slippage,spread,contractSize,commission,isVolume,pointConversion,roundLots: string;
  database: TStringList;
begin
  symbol       :=  InputBox('Symbol', 'Please enter the desired symbol name', '') ;

  ShowMessage('Please now select the data file that you want to use.');

  datafile := '';

  If OpenDialog1.Execute then
  datafile := OpenDialog1.FileName;

  if datafile = '' then
  begin
    ShowMessage('No valid data file selected. Aborting new instrument addition');
    Exit;
  end;

  timeframe    :=  InputBox('Timeframe', 'Please enter the time frame for the data in minutes', '') ;
  slippage     :=  InputBox('Slippage', 'Please enter the maximum slippage desired', '') ;
  spread       :=  InputBox('Spread', 'Please enter the spread used', '') ;
  contractSize :=  InputBox('Contract size', 'Please enter the dollar values per pip when trading the standard contract size (1 lot)', '') ;
  commission   :=  InputBox('Commission', 'Please enter the commission charger per trade in USD', '') ;
  isVolume     :=  InputBox('Volume', 'Does the data contain volume information ? (0=no, 1=yes))', '') ;
  pointConversion       :=  InputBox('Point Conversion', 'Please enter the multiplication factor to convert from absolute price value to pips', '') ;
  roundLots :=  InputBox('Lot size rounding', 'To how many decimal places do you want to round lot sizes?', '') ;
  minStop :=  InputBox('Min stop size', 'How many price units do you want to have as a minimum SL/TP distance? (Should be number with decimal, if you want 0 type 0.0)', '') ;

  database := TStringList.Create;

  {$IFDEF DARWIN}
  database.LoadFromFile(GetCurrentDir + '/kantu.app/Contents/MacOS/symbols/symbols.csv');
  {$ELSE}
  database.LoadFromFile(GetCurrentDir + '/symbols/symbols.csv');
  {$ENDIF}

  database.Add(symbol+';'+datafile+';'+timeframe+';'+slippage+';'+spread+';'+contractSize+';'+commission+';'+isVolume+';'+pointConversion+';'+roundLots+';'+minStop);

  {$IFDEF DARWIN}
  database.SaveToFile(GetCurrentDir + '/kantu.app/Contents/MacOS/symbols/symbols.csv');
  {$ELSE}
  database.SaveToFile(GetCurrentDir + '/symbols/symbols.csv');
  {$ENDIF}

  database.Free;

  loadSymbol.SymbolsList.Clear;

   loadSymbol.Datasource1.Enabled:=False; //Manual refresh of linked DBGrid
   loadSymbol.Datasource1.Enabled:=True;
   loadSymbol.ZMQueryDataSet1.SQL.Clear;
   loadSymbol.ZMQueryDataSet1.SQL.Add('SELECT * FROM symbols');
   loadSymbol.ZMQueryDataSet1.QueryExecute;

    with loadSymbol.SymbolsGrid.DataSource.DataSet do
 // begin
   // first;
     while not loadSymbol.SymbolsGrid.DataSource.DataSet.EOF do
     begin
        loadSymbol.SymbolsList.Items.Add(loadSymbol.SymbolsGrid.Columns[0].Field.AsString) ;
        loadSymbol.SymbolsGrid.DataSource.DataSet.Next;
     end ;



end;

procedure TloadSymbol.Button3Click(Sender: TObject);
begin

  updateIndicatorLoadedSymbols;
  MainForm.simulationTime := 0;
  MainForm.simulationRuns := 0;
  MainForm.simulationType := SIMULATION_TYPE_INDICATORS;

end;

procedure TloadSymbol.DBNavigator1BeforeAction(Sender: TObject;
  Button: TDBNavButtonType);
begin

end;

procedure TloadSymbol.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

end;

end.

