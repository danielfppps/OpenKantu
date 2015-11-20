program kantu;

{$mode objfpc}{$H+}

uses
  {$DEFINE UseCThreads}
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  cmem,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, tachartlazaruspkg, kantu_main, kantu_definitions,
  kantu_simulation, kantu_pricepattern, kantu_filters, kantu_custom_filter,
  SysUtils, FileUtil, Controls, Graphics, Dialogs, Menus, Grids, StdCtrls,
  ComCtrls, Buttons, Classes, kantu_loadSymbol, zmsql,
  kantu_multithreading, kantu_portfolioResults, kantu_indicators,
  kantu_regular_simulation, kantu_simulation_show, kantu_singleSystem;

{$R *.res}

procedure assignMainCaption();
begin
  MainForm.Caption := 'OpenKantu v' + KANTU_VERSION + '- Parameterless system generator. by Daniel Fernandez, Copyright Asirikuy.com 2013-2014. This version is licensed under the GPL v2.';
end;

function slash(value:string):string;
begin
if (value='') then result:=''
              else begin
                   {$IFDEF WINDOWS}
                   if (value[length(value)]<>'\') then result:=value+'\'
                   {$ELSE}
                   if (value[length(value)]<>'/') then result:=value+'/'
                   {$ENDIF}
                                                  else result:=value;
                   end;
end;

function getinstalldir:string;
begin
result:=slash(extractfiledir(paramstr(0)));
end;

procedure setMainFolder;
var
  authenticationLoad: TStringList;
begin

     MainForm.mainProgramFolder:= GetCurrentDir;

     {$IFDEF DARWIN}
     MainForm.mainProgramFolder:= copy(getinstalldir,1,pos(extractfilename(paramstr(0)),getinstalldir)-1);
     SetCurrentDir(copy(getinstalldir,1,pos(extractfilename(paramstr(0))+'.app/Contents/MacOS',getinstalldir)-1));
     {$ENDIF}
end;


begin
  Application.Title:='OpenKantu - Price Pattern Parameter-lessTrading System '
    +'Generator';
  Application.Initialize;
  Randomize;
  //CheckValidity();
  Application.CreateForm(TMainForm, MainForm);
  setMainFolder;
  Application.CreateForm(TSimulationForm, SimulationForm);
  Application.CreateForm(TPricePatternForm, PricePatternForm);
  assignMainCaption;
  Application.CreateForm(TFiltersForm, FiltersForm);
  Application.CreateForm(TCustomFilterForm, CustomFilterForm);
  Application.CreateForm(TloadSymbol, loadSymbol);
  // set proper formatting
  DefaultFormatSettings.ShortDateFormat 	 := 'dd/mm/yyyy' ;
  DefaultFormatSettings.DateSeparator 	         := '/' ;
  DefaultFormatSettings.DecimalSeparator 	 := '.' ;
  MainForm.Enabled := true;

  Application.CreateForm(TPortfolioResultForm, PortfolioResultForm);
  Application.CreateForm(TSimulationForm2, SimulationForm2);
  Application.CreateForm(TSingleSystem, SingleSystem);

  // Please do not remove these messages //
  ShowMessage('OpenKantu provides a framework for the automatic generation of trading systems using price action based patterns. The program does NOT contain any tools for the evaluation of curve-fitting or data-mining bias. Using it without proper knowledge about these sources of bias can lead to financial loses. To learn more about these sources of bias and get access to more advanced system generators please visit Asirikuy.com');
  //

  setMainFolder;
  Application.Run;
end.

