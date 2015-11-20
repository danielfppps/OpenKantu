{*********************************************************}
{                                                         }
{                       ZMSQL                             }
{            SQL enhanced in-memory dataset               }
{                                                         }
{   Original developer: Zlatko Matić, 2011                }
{             e-mail: matalab@gmail.com                   }
{  Milkovićeva 6, Mala Ostrna, 10370 Dugo Selo,  Croatia. }
{                                                         }
{*********************************************************}
{
    This file is copyright (c) 2015 by Zlatko Matić

    This source code is distributed under
    the Library GNU General Public License (see the file
    COPYING) with the following modification:

    As a special exception, the copyright holders of this library give you
    permission to link this library with independent modules to produce an
    executable, regardless of the license terms of these independent modules,
    and to copy and distribute the resulting executable under terms of your choice,
    provided that you also meet, for each linked independent module, the terms
    and conditions of the license of that module. An independent module is a module
    which is not derived from or based on this library. If you modify this
    library, you may extend this exception to your version of the library, but you are
    not obligated to do so. If you do not wish to do so, delete this exception
    statement from your version.

    If you didn't receive a copy of the file COPYING, contact:
          Free Software Foundation
          675 Mass Ave
          Cambridge, MA  02139
          USA

    Modifications are made by Zlatko Matić and contributors for purposes of zmsql package.

 **********************************************************************}

{-----------------------------------------------------------------------------

The original developer of the code is Zlatko Matić
(matalab@gmail.com or matic.zlatko@gmail.com).

Contributor(s):

Last Modified: 08.02.2015

Known Issues:The visual query builder is not adapted to JanSQL non-standard SQL dialect.

History (Change log):global history log is in ZMQueryDataset unit.
-----------------------------------------------------------------------------}

unit ZMQueryBuilder;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs,
  ZMConnection,QBuilder,QBEZmsql;

type

  { TZMQueryBuilder }

  TZMQueryBuilder = class(TComponent)
  private
    FACtive: Boolean;
    FQueryBuilderDialog: TOQBuilderDialog;
    FVisualQueryEngine: TOQBEngineZmsql;
    FZMConnection: TZMConnection;
    procedure SetACtive(AValue: Boolean);
    procedure SetConnection(AValue: TZMConnection);
    procedure SetQueryBuilderDialog(AValue: TOQBuilderDialog);
    procedure SetVisualQueryEngine(AValue: TOQBEngineZmsql);
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    property QueryBuilderDialog:TOQBuilderDialog read FQueryBuilderDialog write SetQueryBuilderDialog;
    property VisualQueryEngine: TOQBEngineZmsql read FVisualQueryEngine write SetVisualQueryEngine;
  published
    { Published declarations }
    property ZMConnection:TZMConnection read FZMConnection write SetConnection;
    property ACtive:Boolean read FACtive write SetACtive;
  end;

implementation

{ TZMQueryBuilder }

procedure TZMQueryBuilder.SetConnection(AValue: TZMConnection);
begin
  if FZMConnection=AValue then Exit;
  FZMConnection:=AValue;
end;

procedure TZMQueryBuilder.SetQueryBuilderDialog(AValue: TOQBuilderDialog);
begin
  if FQueryBuilderDialog=AValue then Exit;
  FQueryBuilderDialog:=AValue;
end;

procedure TZMQueryBuilder.SetVisualQueryEngine(AValue: TOQBEngineZmsql);
begin
  if FVisualQueryEngine=AValue then Exit;
  FVisualQueryEngine:=AValue;
end;

constructor TZMQueryBuilder.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  QueryBuilderDialog := TOQBuilderDialog.Create(nil);
  VisualQueryEngine := TOQBEngineZmsql.Create(nil);
end;

destructor TZMQueryBuilder.Destroy;
begin
  QueryBuilderDialog.Free;
  VisualQueryEngine.Free;
  inherited Destroy;
end;

procedure TZMQueryBuilder.SetACtive(AValue: Boolean);
begin
  if FACtive=AValue then Exit;
  FACtive:=AValue;

  if FActive=True then begin
    try
      VisualQueryEngine.Connection := ZMConnection;
      QueryBuilderDialog.OQBEngine := VisualQueryEngine;
      QueryBuilderDialog.OQBEngine.DatabaseName :=ZMConnection.DatabasePathFull;

      VisualQueryEngine.ShowSystemTables := False;

      QueryBuilderDialog.Execute;
    finally
      VisualQueryEngine.Free;
      QueryBuilderDialog.Free;
    end;
  end;

end;

end.
