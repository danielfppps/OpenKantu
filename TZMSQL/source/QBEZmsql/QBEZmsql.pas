{*******************************************************}
{                                                       }
{       Open QBuilder Engine for SQLDB Sources          }
{                Lazarus / Free Pascal                  }
{                                                       }
{ Created by Reinier Olislagers                         }
{ Data: October 2014                                    }
{                                                       }
{*******************************************************}

unit QBEZmsql;
{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, DB, sqldb, QBuilder,
  ZMConnection,ZMQueryDataSet;

type

  {  TOQBEngineZmsql }

  TOQBEngineZmsql = class(TOQBEngine)
    procedure FResultQueryAfterOpen(DataSet: TDataSet{TZMQueryDataSet});
    procedure GridMemoFieldGetText(Sender: TField; var aText: string;
      {%H-}DisplayText: Boolean);
  private
    FResultQuery: TDataset{TZMQueryDataSet};
    FZmsqlConnection : TZMConnection;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ClearQuerySQL; override;
    procedure CloseResultQuery; override;
    procedure OpenResultQuery; override;
    procedure ReadFieldList(const ATableName: string); override;
    procedure ReadTableList; override;
    procedure SaveResultQueryData; override;
    procedure SetConnection(Value: TZMConnection);
    procedure SetQuerySQL(const Value: string); override;
    function ResultQuery: TDataSet{TZMQueryDataset}; override;
    function SelectDatabase: Boolean; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  published
    property Connection: TZMConnection read FZmsqlConnection write SetConnection;
  end;

implementation

{ TOQBEngineSqlDB }

procedure TOQBEngineZmsql.FResultQueryAfterOpen(DataSet: TDataSet{ZMQueryDataset});
var
  i: Integer;
begin
  for i := 0 to DataSet.Fields.Count - 1 do
  begin
    if DataSet.Fields[i].DataType = ftMemo then
    begin
      DataSet.Fields[i].OnGetText := @GridMemoFieldGetText;
    end;
  end;
end;

procedure TOQBEngineZmsql.GridMemoFieldGetText(Sender: TField;
  var aText: string; DisplayText: Boolean);
begin
  // Show memo fields
  aText := TField(Sender).AsString;
end;

constructor TOQBEngineZmsql.Create(AOwner: TComponent);
begin
  inherited;
  FResultQuery := TZMQueryDataSet.Create(Self);
  FResultQuery.AfterOpen := @FResultQueryAfterOpen;
end;

destructor TOQBEngineZmsql.Destroy;
begin
  FResultQuery.Free;
  inherited;
end;

procedure TOQBEngineZmsql.SetConnection(Value: TZMConnection);
begin
  FZmsqlConnection := Value;
  (FResultQuery as TZMQueryDataSet).ZMConnection:=Value;{FResultQuery.Database := Value;}
end;

function TOQBEngineZmsql.SelectDatabase: Boolean;
begin
  Result := True;
end;

procedure TOQBEngineZmsql.ReadTableList;
begin
  TableList.Clear;
  (FResultQuery as TZMQueryDataSet).ZMConnection.GetTableNames(TableList);
end;

procedure TOQBEngineZmsql.ReadFieldList(const ATableName: string);
begin
  FieldList.Clear;
  try
    (FResultQuery as TZMQueryDataSet).TableName:=ATableName;
    (FResultQuery as TZMQueryDataSet).LoadTableSchema;
    (FResultQuery as TZMQueryDataSet).GetFieldNames(FieldList);
  finally
    (FResultQuery as TZMQueryDataSet).Close;
  end;

  FieldList.Insert(0, '*');
end;

procedure TOQBEngineZmsql.ClearQuerySQL;
begin
  (FResultQuery as TZMQueryDataset).SQL.Clear;
end;

procedure TOQBEngineZmsql.SetQuerySQL(const Value: string);
begin
  (FResultQuery as TZMQueryDataset).SQL.Text := Value;
end;

function TOQBEngineZmsql.ResultQuery: TDataSet{TZMQueryDataSet};
begin
  Result := FResultQuery;
end;

procedure TOQBEngineZmsql.OpenResultQuery;
begin
  try
    (FResultQuery as TZMQueryDataSet).QueryExecute;
  finally
  end;
end;

procedure TOQBEngineZmsql.CloseResultQuery;
begin
  FResultQuery.Close;
end;

{$WARNINGS OFF}
procedure TOQBEngineZmsql.SaveResultQueryData;
begin
  //
end;
{$WARNINGS ON}

procedure TOQBEngineZmsql.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (AComponent = FZmsqlConnection) and (Operation = opRemove) then
  begin
    FZmsqlConnection := nil;
    (FResultQuery as TZMQueryDataSet).ZMConnection:=nil;
  end;
end;

end.
