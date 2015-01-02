unit kantu_multithreading;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, Forms,kantu_definitions,  LCLProc, dateutils, kantu_simulation, math;

Type
    TMyIndiThread = class(TThread)
    private

    protected
      simulationResults  : array of TIndicatorSimulationResults;
      entryPattern, closePattern: TIndicatorPattern;
      maxRulesPerCandle: integer;
      slippagePercent: double;
      i, j: integer;
      maxCandleShift: integer;
      singleCycleSystems: double;
      resultQuota: integer;
      useSL, useTP, useClose: Boolean;
      startDate, endDate, endOutOfSample: TDateTime;
      generationPeriod, walkForwardPeriod, strategiesRequested: integer;
      testedPatterns: TIndicatorPatternGroup;
      procedure Execute; override;
      procedure syncSimulation;
    public
      isRandomPeriodSelection : boolean;
      isMultipleSymbols       : boolean;
      isSingleCycle           : boolean;
      Constructor Create(CreateSuspended : boolean);
    end;

implementation

uses kantu_regular_simulation, kantu_main, kantu_indicators  ;

  constructor TMyIndiThread.Create(CreateSuspended : boolean);
  begin
    maxRulesPerCandle    := StrToInt(SimulationForm.OptionsGrid.Cells[1, IDX_OPT_MAX_RULES_PER_CANDLE]);
    maxCandleShift       := StrToInt(SimulationForm.OptionsGrid.Cells[1, IDX_OPT_MAX_CANDLE_SHIFT]);
    resultQuota          := StrToInt(SimulationForm.OptionsGrid.Cells[1, IDX_OPT_REQUESTED_SYSTEMS]);
    useSL                := SimulationForm.useSLCheck.Checked;
    useTP                := SimulationForm.useTPCheck.Checked;
    startDate            := SimulationForm.BeginInSampleCalendar.Date;
    endDate              := SimulationForm.EndInSampleCalendar.Date ;
    endOutOfSample       := SimulationForm.EndOutOfSampleCalendar.Date;
    SetLength(simulationResults, 1);
    SetLength(testedPatterns, 0);

    FreeOnTerminate := True;
    inherited Create(CreateSuspended);
  end;

  procedure TMyIndiThread.syncSimulation;
  var
    k: integer;
  begin

    SetLength(indicatorEntryPatterns, Length(indicatorEntryPatterns)+1);
    SetLength(indicatorClosePatterns, Length(indicatorClosePatterns)+1);
    indicatorEntryPatterns[ Length(indicatorEntryPatterns)-1] := entryPattern;
    indicatorClosePatterns[ Length(indicatorClosePatterns)-1] := closePattern;

    for k := 0 to strategiesRequested-1 do
    addIndicatorResultToGrid(simulationResults[k], Length(indicatorEntryPatterns), endOutOfSample );


    validResults := validResults + 1;

    MainForm.StatusLabel.Caption := 'Simulation progress: ' + FloatToStr(simulationsRan) + '  runs, valid ' + IntToStr(MainForm.ResultsGrid.RowCount-1) + '/' +  IntToStr(strategiesRequested) + ' Avg time/sim : ' + FloatToStr(MainForm.simulationTime/1000);
    MainForm.ProgressBar1.Position := MainForm.ResultsGrid.RowCount-1 ;

    j := 0;
    i := 1 + i;

  end;

  procedure TMyIndiThread.Execute;
  var
    isPositiveCount: integer;
    k: integer;
  begin

 i := 0;
 j := 0;
 strategiesRequested := 1;

    while (((validResults < resultQuota) and (isSingleCycle = False)) or
           ((simulationsRan < singleCycleSystems) and (isSingleCycle = True)))
           and (MainForm.isCancel = false) do
      begin

            if isMultipleSymbols then
            begin
            strategiesRequested := Length(LoadedIndiHistoryData);
            SetLength(simulationResults, strategiesRequested);
            end;

            if isRandomPeriodSelection then
            begin
            startDate := Now;

              while IncDay(startDate, walkForwardPeriod+generationPeriod) > LoadedIndiHistoryData[0].time[Length(LoadedIndiHistoryData[0].time)-1] do
              startDate               := LoadedIndiHistoryData[0].time[RandomRange(50, Length(LoadedIndiHistoryData[0].time)-1)] ;
              endDate                 := IncDay(startDate, generationPeriod);
              endOutOfSample          := IncDay(endDate, walkForwardPeriod);

            end;

            entryPattern := generateRandomIndicatorPattern(maxRulesPerCandle, maxCandleShift);
            closePattern := generateRandomIndicatorPattern(maxRulesPerCandle, maxCandleShift);

            isPositiveCount := 0;

            for k := 0 to strategiesRequested -1 do
            begin

            simulationResults[k].trades := nil;

            simulationResults[k] := runIndicatorSimulation(     entryPattern,
                     closePattern,
                     k,
                     useSL,
                     useTP,
                     startDate,
                     endDate,
                     true);


                    if ( isIndicatorPositiveResult(simulationResults[k]))then isPositiveCount := isPositiveCount + 1;

            end;

            if ( isPositiveCount = Length(LoadedIndiHistoryData))then
            Synchronize(@syncSimulation);

            j := j + 1;
            simulationsRan := simulationsRan + 1;

      end;


  end;

end.

