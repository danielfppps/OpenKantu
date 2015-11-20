{**********************************************************************
                PilotLogic Software House.
  
 Package pl_ZMSQL.pkg
 This unit is part of CodeTyphon Studio (http://www.pilotlogic.com/)
***********************************************************************}

unit AllzmsqlRegister;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF UNIX} clocale, cwstring,{$ENDIF}  
  Classes,SysUtils,TypInfo,lresources,PropEdits,ComponentEditors,
  ZMConnection,
  ZMQueryDataSet,
  ZMReferentialKey,
  ZMQueryBuilder,
  DB;


 procedure Register;

implementation

{$R AllzmsqlRegister.res}

//==========================================================
procedure Register;
begin

  RegisterComponents ('ZMSql',[
                                  TZMConnection,
                                  TZMReferentialKey,
                                  TZMQueryDataSet,
                                  TZMQueryBuilder
                                   ]);


end;

end.

