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

Last Modified: 05.02.2012

Known Issues:

History (Change log):
ZMSQL version 0.1.0, 13.07.2011 :
      ZMSQL released as free software
ZMSQL version 0.1.1, 26.07.2011
ZMSQL version 0.1.2, 28.07.2011
ZMSQL version 0.1.3, 02.08.2011
      - Freeing and recreating FJanSQLInstance in procedure Connect added.
        It seems that this is neccessary when changing "database".
ZMSQL version 0.1.4, 08.08.2011
ZMSQL version 0.1.5, 12.08.2011
      - Added property DecimalSeparator:Char read FDecimalSeparator write SetDecimalSeparator;
      If left empty, default format settings will be used (SysUtils.DefaultFormatSettings).
      CAUTION: Changing this property will affect the whole application - functions such as: StrToFloat, FloatToStr, FormatFloat etc.
      - clocale added to uses clause.--> this should initialize localized default format settings for Unixoid OSs.
ZMSQL commit, 16 December: by Zlatko Matić
      - Bug in Disconnect procedure solved.
ZMSQL version 0.1.11, 05.02.2012
      * property FloatDisplayFormat added.
-----------------------------------------------------------------------------}
unit ZMConnection;

{$mode objfpc}{$H+}

interface

uses
  {$ifdef unix}clocale,{$endif}
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs,
  JanSQL;

type

  { TZMConnection }

  TZMConnection = class(TComponent)
  private
    FConnected: Boolean;
    FDatabasePath: String;
    FDatabasePathFull:String;
    FDecimalSeparator: Char;
    FFloatDisplayFormat: String;
    FJanSQLInstance:TjanSQL;
    procedure SetConnected(const AValue: Boolean);
    procedure SetDatabasePath(const AValue: String);
    procedure SetDatabasePathFull(const AValue: String);
    procedure SetDecimalSeparator(const AValue: Char);
    procedure SetFloatDisplayFormat(AValue: String);
    procedure SetJanSQLInstance(const AValue: TjanSQL);
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
  published
    { Published declarations }
    property DatabasePath:String read FDatabasePath write SetDatabasePath;
    property Connected:Boolean read FConnected write SetConnected;
    property DecimalSeparator:Char read FDecimalSeparator write SetDecimalSeparator;
    property FloatDisplayFormat:String read FFloatDisplayFormat write SetFloatDisplayFormat;
    property JanSQLInstance:TjanSQL read FJanSQLInstance write SetJanSQLInstance;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('ZMSql',[TZMConnection]);
end;

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

procedure TZMConnection.SetDecimalSeparator(const AValue: Char);
begin
  if FDecimalSeparator=AValue then exit;
  if ((AValue='.') or (AValue=',') or (AValue=#0)) then
    begin
      FDecimalSeparator:=AValue;
    end;
  case FDecimalSeparator of
    '.':
        begin
          SysUtils.DefaultFormatSettings.DecimalSeparator:='.';
          SysUtils.DefaultFormatSettings.ThousandSeparator:=',';
        end;
    ',':
        begin
          SysUtils.DefaultFormatSettings.DecimalSeparator:=',';
          SysUtils.DefaultFormatSettings.ThousandSeparator:='.';
        end;
  end;
end;

procedure TZMConnection.SetFloatDisplayFormat(AValue: String);
begin
  if FFloatDisplayFormat=AValue then Exit;
  FFloatDisplayFormat:=AValue;
end;

procedure TZMConnection.SetJanSQLInstance(const AValue: TjanSQL);
begin
  if FJanSQLInstance=AValue then exit;
  FJanSQLInstance:=AValue;
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
     vLastDelimiter:=Copy(FDatabasePath,vLastDelimiterPosition,1);
     FDatabasePathFull:=FDatabasePath+vLastDelimiter;
   end
  else //if relative path
   begin
     vLastDelimiterPosition:=LastDelimiter('/\',vApplicationPath);
     vLastDelimiter:=Copy(vApplicationPath,vLastDelimiterPosition,1);
     FDatabasePathFull:=vApplicationPath+vLastDelimiter
           +FDatabasePath +vLastDelimiter;
   end;
  //Free existing and create new JanSQL database -->It seems that this is neccessary when changing connection.
  FJanSQLInstance.Free;
  FJanSQLInstance:=TJanSQL.Create;
  //Connect to "database".
  vSqlText:='connect to '''+FDatabasePathFull+'''';
  vSqlResult:=FJanSQLInstance.SQLDirect(vSqlText);
  FConnected:=True;
  if vSqlResult<>0 then
    {ShowMessage('Successfully connected to database:'+FDatabasePath)}
  else
    ShowMessage('Connection to database: '+ FDatabasePath
      +' failed! Error: '+FJanSQLInstance.Error);
end;

procedure TZMConnection.Disconnect;
begin
  FJanSQLInstance.Free;
  FJanSQLInstance:=TJanSQL.Create;
  FConnected:=False;
end;

constructor TZMConnection.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  //Create JanSQL database
  FJanSQLInstance:=TJanSQL.Create;
end;

destructor TZMConnection.Destroy;
begin
  //Destroy JanSQL database
  FJanSQLInstance.Free;
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

initialization
{$I zmconnection.lrs}

end.
