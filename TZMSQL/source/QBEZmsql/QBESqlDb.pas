{*******************************************************}
{                                                       }
{       Open QBuilder Engine for SQLDB Sources          }
{                Lazarus / Free Pascal                  }
{                                                       }
{ Created by Reinier Olislagers                         }
{ Data: October 2014                                    }
{                                                       }
{*******************************************************}

unit QBESqlDb;
{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, DB, sqldb, QBuilder;

type

  { TOQBEngineSqlDB }

  TOQBEngineSqlDB = class(TOQBEngine)
    procedure FResultQueryAfterOpen(DataSet: TDataSet);
    procedure GridMemoFieldGetText(Sender: TField; var aText: string;
      {%H-}DisplayText: Boolean);
  private
    FResultQuery: TSQLQuery;
    FSqlDBConnection : TSQLConnection;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ClearQuerySQL; override;
    procedure CloseResultQuery; override;
    procedure OpenResultQuery; override;
    procedure ReadFieldList(const ATableName: string); override;
    procedure ReadTableList; override;
    procedure SaveResultQueryData; override;
    procedure SetConnection(Value: TSQLConnection);
    procedure SetQuerySQL(const Value: string); override;
    function ResultQuery: TDataSet; override;
    function SelectDatabase: Boolean; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  published
    property Connection: TSQLConnection read FSqlDBConnection write SetConnection;
  end;

implementation

{ TOQBEngineSqlDB }

procedure TOQBEngineSqlDB.FResultQueryAfterOpen(DataSet: TDataSet);
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

procedure TOQBEngineSqlDB.GridMemoFieldGetText(Sender: TField;
  var aText: string; DisplayText: Boolean);
begin
  // Show memo fields
  aText := TField(Sender).AsString;
end;

constructor TOQBEngineSqlDB.Create(AOwner: TComponent);
begin
  inherited;
  FResultQuery := TSQLQuery.Create(Self);
  FResultQuery.AfterOpen := @FResultQueryAfterOpen;
end;

destructor TOQBEngineSqlDB.Destroy;
begin
  FResultQuery.Free;
  inherited;
end;

procedure TOQBEngineSqlDB.SetConnection(Value: TSQLConnection);
begin
  FSqlDBConnection := Value;
  FResultQuery.Database := Value;
end;

function TOQBEngineSqlDB.SelectDatabase: Boolean;
begin
  Result := True;
end;

procedure TOQBEngineSqlDB.ReadTableList;
begin
  TableList.Clear;
  TSQLConnection(FResultQuery.Database).GetTableNames(TableList, ShowSystemTables);
end;

procedure TOQBEngineSqlDB.ReadFieldList(const ATableName: string);
begin
  FieldList.Clear;
  TSQLConnection(FResultQuery.Database).GetFieldNames(ATableName, FieldList);
  FieldList.Insert(0, '*');
end;

procedure TOQBEngineSqlDB.ClearQuerySQL;
begin
  FResultQuery.SQL.Clear;
end;

procedure TOQBEngineSqlDB.SetQuerySQL(const Value: string);
begin
  FResultQuery.SQL.Text := Value;
end;

function TOQBEngineSqlDB.ResultQuery: TDataSet;
begin
  Result := FResultQuery;
end;

procedure TOQBEngineSqlDB.OpenResultQuery;
begin
  try
    FResultQuery.Open;
  finally
  end;
end;

procedure TOQBEngineSqlDB.CloseResultQuery;
begin
  FResultQuery.Close;
end;

{$WARNINGS OFF}
procedure TOQBEngineSqlDB.SaveResultQueryData;
begin
  //
end;
{$WARNINGS ON}

procedure TOQBEngineSqlDB.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (AComponent = FSqlDBConnection) and (Operation = opRemove) then
  begin
    FSqlDBCOnnection := nil;
    FResultQuery.Database := nil;
  end;
end;

end.
