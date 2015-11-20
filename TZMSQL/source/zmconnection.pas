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
    This file is copyright (c) 2011 by Zlatko Matić    
    
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

Known Issues:

History (Change log):global history log is in ZMQueryDataset unit.
-----------------------------------------------------------------------------}
unit ZMConnection;

{$mode objfpc}{$H+}

interface

uses
  {$ifdef unix}clocale, cwstring,{$endif}
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs,
  jansql;

type

  { TZMConnection }

  TZMConnection = class(TComponent)
  private
    FConnected: Boolean;
    FDatabasePath: String;
    FDatabasePathFull:String;
    FFloatDisplayFormat: String;
    FFloatPrecision: Integer;
    procedure SetConnected(const AValue: Boolean);
    procedure SetDatabasePath(const AValue: String);
    procedure SetDatabasePathFull(const AValue: String);
    procedure SetFloatDisplayFormat(AValue: String);
    procedure SetFloatPrecision(AValue: Integer);
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    procedure Connect;
    procedure Disconnect;
    constructor Create(AOwner: TComponent);override;
    destructor Destroy;override;
    property DatabasePathFull:String read FDatabasePathFull write SetDatabasePathFull;
    procedure GetTableNames(FileList: TStrings);
  published
    { Published declarations }
    property DatabasePath:String read FDatabasePath write SetDatabasePath;
    property Connected:Boolean read FConnected write SetConnected;
    property FloatDisplayFormat:String read FFloatDisplayFormat write SetFloatDisplayFormat;
    property FloatPrecision:Integer read FFloatPrecision write SetFloatPrecision;
  end;


implementation

{ TZMConnection }

procedure TZMConnection.SetDatabasePath(const AValue: String);
begin
  if FDatabasePath=AValue then exit;
  FDatabasePath:=AValue;
end;

procedure TZMConnection.SetDatabasePathFull(const AValue: String);
begin
  if FDatabasePathFull=AValue then exit;
  FDatabasePathFull:=AValue;
end;

procedure TZMConnection.SetFloatDisplayFormat(AValue: String);
begin
  if FFloatDisplayFormat=AValue then Exit;
  FFloatDisplayFormat:=AValue;
end;

procedure TZMConnection.SetFloatPrecision(AValue: Integer);
begin
  if FFloatPrecision=AValue then Exit;
  FFloatPrecision:=AValue;
end;

procedure TZMConnection.Connect;
var
  vSqlResult:Integer;
  vSqlText:String;
  vApplicationPath, vLastDelimiter:String;
  vLastDelimiterPosition:Integer;
begin
  //Determine the full path
  //Set the path
  vApplicationPath:=extractfiledir(application.exename);
  //Derermine last delimiter in path.
  //If full path
  if LastDelimiter('/\', FDatabasePath)<>0 then
   begin
     vLastDelimiterPosition:=LastDelimiter('/\',FDatabasePath);
     {vLastDelimiter:=Copy(FDatabasePath,vLastDelimiterPosition,1);}
     vLastDelimiter:=DirectorySeparator;
     FDatabasePathFull:=FDatabasePath+vLastDelimiter;
   end
  else //if relative path
   begin
     vLastDelimiterPosition:=LastDelimiter('/\',vApplicationPath);
     {vLastDelimiter:=Copy(vApplicationPath,vLastDelimiterPosition,1);}
     vLastDelimiter:=DirectorySeparator;
     FDatabasePathFull:=vApplicationPath+vLastDelimiter
           +FDatabasePath +vLastDelimiter;
   end;
end;

procedure TZMConnection.Disconnect;
begin
  FConnected:=False;
end;

constructor TZMConnection.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TZMConnection.Destroy;
begin
  inherited Destroy;
end;

procedure TZMConnection.SetConnected(const AValue: Boolean);
begin
  if FConnected=AValue then exit;
  if AValue=True then
    begin
      try
        Connect;
        FConnected:=AValue;
      except
        Disconnect;
        FConnected:=False;
      end;
    end;
  if AValue=False then
    begin
      Disconnect;
      FConnected:=AValue;
    end;
end;

procedure TZMConnection.GetTableNames(FileList: TStrings);
var
  SR: TSearchRec;
  Path: string;
begin
  Path:=FDatabasePathFull;
  if FindFirst(Path + '*.csv', faAnyFile, SR) = 0 then
  begin
    repeat
      if (SR.Attr <> faDirectory) then
      begin
        FileList.Add(ChangeFileExt(SR.Name, ''));
      end;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
end;

end.
