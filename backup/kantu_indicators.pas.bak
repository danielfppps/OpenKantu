unit kantu_indicators;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus, Grids,
  Buttons,  kantu_definitions, Math, dateUtils,fpexprpars,
  kantu_simulation, kantu_filters, kantu_custom_filter, kantu_multithreading,
  kantu_pricepattern, kantu_portfolioResults,TAGraph, TASeries,
  TAFuncSeries, TAMultiSeries, kantu_simulation_show;

   var
   LoadedIndicatorData: array of TIndicatorGroup;
   LoadedIndiHistoryData: array of TSymbolHistory;
   LoadedIndicatorDataSynthetic: TIndicatorGroup;
   indicatorEntryPatterns: array of TIndicatorPattern;
   indicatorClosePatterns: array of TIndicatorPattern;
   indicatorWFAResults : array of TIndicatorSimulationResults;
   indicatorWFAResultsLineSeries: array of TLineSeries;
   globalAllowLongSignals: boolean;
   globalAllowShortSignals: boolean;
   allPatterns: array of TIndicatorPattern;
   Procedure runSingleSystem(usedSymbol: integer; patternToUse: TIndicatorPattern; closingPatternToUse: TIndicatorPattern);
   Function hasPatternBeenTested(testedPatterns: TIndicatorPatternGroup; randomPattern:TIndicatorPattern): boolean;
   Function generateRandomIndicatorPattern(maxRules, maxCandleShift: Integer): TIndicatorPattern;
   Function isIndicatorPositiveResult(simulationResults: TIndicatorSimulationResults): boolean;
   Function getIndicatorCustomCriteria(simulationResults: TIndicatorSimulationResults): double;
   Function evaluateIndicatorPattern(symbol: integer; testPattern: TIndicatorPattern; currentShift: integer; logic:integer; evaluationType: integer): boolean;
   Procedure getIndicatorStatistics(var simulationResults: TIndicatorSimulationResults);
   Function runIndicatorSimulation(       usedEntryPattern   : TIndicatorPattern;
                                       usedClosePattern   : TIndicatorPattern;
                                       symbol             : integer;
                                       useSL              : Boolean;
                                       useTP              : Boolean;
                                       inSampleStartDate  : TDateTime;
                                       inSampleEndingDate : TDateTime;
                                       onlyInSample       : boolean): TIndicatorSimulationResults;
   Procedure addIndicatorResultToGrid(simulationResults: TIndicatorSimulationResults; SimNumber : integer; outOfSampleEndDate: TDateTime) ;
   function calculateATRIndicator(symbol, timeframe, period,currentShift: integer): double;
   Function  LoadIndicatorsAndHistory(PairDataFile: string): boolean;
   procedure runIndiSimulationFixedQuota( isRandomSimulation: boolean);
   procedure runIndicatorSimulationFixedQuotaMultipleSymbols;
   procedure addIndicatorSimulationResults(simulationResultsInSample: TIndicatorSimulationResults; var simulationResults: TIndicatorSimulationResults; var simulationResultsFinal: TIndicatorSimulationResults);
   procedure mergeIndicatorSimulationResults(var  simulationResultsPortfolio: array of TIndicatorSimulationResults; var simulationResultsFinalPortfolio: TIndicatorSimulationResults; startingTime, endingTime: TDateTime );
   procedure ShowIndicatorPatternDecomposition;
   procedure ShowIndicatorPatternPortfolioResult;
   Function barsBetween(openTime: TDateTime; currentShift, symbol: integer): integer;
   procedure saveIndicatorResultsToFile(filename: string;  simulationResults: TIndicatorSimulationResults);
   function nCr(n,r:integer):double;


implementation
              uses kantu_singleSystem, kantu_main, kantu_regular_simulation, kantu_loadSymbol;


Function nCr(n,r:integer):double;
              var x,y:real;
                  i:integer;
              begin
                if r>n div 2 then r:=n-r;
                x:=1; y:=1;
                for i:=n-r+1 to n do x:=x*i;
                for i:=2 to r do y:=y*i;
                nCr:=x/y;
              End;

procedure saveIndicatorResultsToFile(filename: string;  simulationResults: TIndicatorSimulationResults);
var
  i: integer;
  saveFile: TStringList;
  orderType: string;
begin

 saveFile := TStringList.Create;

 saveFile.Add('Number'+','
                                  +'openTime'+','
                                  +'closeTime'+','
                                  +'openPrice'+','
                                  +'closePrice'+','
                                  +'stopLoss'+','
                                  +'takeProfit'+','
                                  +'Profit'+','
                                  +'orderType'+','
                                  +'Volume'+','
                                  + 'Balance');

             for i:= 1 to Length(simulationResults.balanceCurve)-1 do
             begin

             if simulationResults.trades[i-1].orderType = BUY then
             orderType := 'BUY';

             if simulationResults.trades[i-1].orderType = SELL then
             orderType := 'SELL';

                     saveFile.Add(IntToStr(i)+','
                                  +DateTimeToStr(simulationResults.trades[i-1].openTime)+','
                                  +DateTimeToStr(simulationResults.trades[i-1].closeTime)+','
                                  +FloatToStr(Round(simulationResults.trades[i-1].openPrice*100000)/100000)+','
                                  +FloatToStr(Round(simulationResults.trades[i-1].closePrice*100000)/100000)+','
                                  +FloatToStr(Round(simulationResults.trades[i-1].SL*100000)/100000) + ' (' + FloatToStr(Round(Abs(simulationResults.trades[i-1].openPrice-simulationResults.trades[i-1].SL)*100000)/100000) + ')'+','
                                  +FloatToStr(Round(simulationResults.trades[i-1].TP*100000)/100000) + ' (' + FloatToStr(Round(Abs(simulationResults.trades[i-1].openPrice-simulationResults.trades[i-1].TP)*100000)/100000) + ')'+','
                                  +FloatToStr(Round(simulationResults.trades[i-1].profit*100)/100)+','
                                  +orderType+','
                                  +FloatToStr(Round(simulationResults.trades[i-1].volume*100)/100)+ ','
                                  +FloatToStr(simulationResults.balanceCurve[i]));

             end;

     saveFile.SaveToFile(filename);

     saveFile.Free;

end;

procedure updateIndicatorBalanceChart(simulationResultsFinal, simulationResultsFinalPortfolio: TIndicatorSimulationResults);
var
i: integer;
begin

    MainForm.BalanceCurve.Clear;
    MainForm.BalanceCurveFit.Clear;
    MainForm.BalanceCurvePortfolio.Clear;
    MainForm.BalanceCurveFitPortfolio.Clear;
    MainForm.upperStdDev.Clear;
    MainForm.lowerStdDev.Clear;

   MainForm.Chart1.AxisList[1].Marks.Source := MainForm.BalanceCurve.Source;
   // MainForm.Chart1.AxisList[2].Marks.Source := MainForm.BalanceCurvePortfolio.Source;

    MainForm.TradeGrid.RowCount := 1;

    MainForm.zeroLine.Position := INITIAL_BALANCE;

    MainForm.inSampleEndLine.Position := SimulationForm.EndInSampleCalendar.Date;
    MainForm.OutOfSampleEndLine.Position := SimulationForm.EndOutOfSampleCalendar.Date;


    for i:= 1 to Length(simulationResultsFinal.balanceCurve)-1 do
          begin

          //this line draws the balance curve
          MainForm.BalanceCurve.AddXY(simulationResultsFinal.trades[i-1].closeTime, simulationResultsFinal.balanceCurve[i], FormatDateTime('mm/yyyy', simulationResultsFinal.trades[i-1].closeTime));

          if simulationResultsFinal.linearFitR2 > 0.1 then
          begin
               MainForm.upperStdDev.AddXY(simulationResultsFinal.trades[i-1].closeTime, simulationResultsFinal.linearFitSlope*(simulationResultsFinal.trades[i-1].closeTime-simulationResultsFinal.trades[0].closeTime) + simulationResultsFinal.linearFitIntercept - simulationResultsFinal.standardDeviationResiduals, FormatDateTime('mm/yyyy', simulationResultsFinal.trades[i-1].closeTime)) ;
               MainForm.lowerStdDev.AddXY(simulationResultsFinal.trades[i-1].closeTime, simulationResultsFinal.linearFitSlope*(simulationResultsFinal.trades[i-1].closeTime-simulationResultsFinal.trades[0].closeTime) + simulationResultsFinal.linearFitIntercept - simulationResultsFinal.standardDeviationResiduals*2, FormatDateTime('mm/yyyy', simulationResultsFinal.trades[i-1].closeTime)) ;
               MainForm.BalanceCurveFit.AddXY(simulationResultsFinal.trades[i-1].closeTime, simulationResultsFinal.linearFitSlope*(simulationResultsFinal.trades[i-1].closeTime-simulationResultsFinal.trades[0].closeTime) + simulationResultsFinal.linearFitIntercept, FormatDateTime('mm/yyyy', simulationResultsFinal.trades[i-1].closeTime));
          end;

          end;

    for i:= 1 to Length(simulationResultsFinalPortfolio.balanceCurve)-1 do
          begin

          //this line draws the balance curve

          MainForm.BalanceCurvePortfolio.AddXY(IncMinute(simulationResultsFinalPortfolio.trades[i-1].closeTime, 1), simulationResultsFinalPortfolio.balanceCurve[i], FormatDateTime('mm/yyyy', IncMinute(simulationResultsFinalPortfolio.trades[i-1].closeTime, 1)));

          if simulationResultsFinalPortfolio.linearFitR2 > 0.1 then
          begin
               MainForm.BalanceCurveFitPortfolio.AddXY(IncMinute(simulationResultsFinalPortfolio.trades[i-1].closeTime, 1), simulationResultsFinalPortfolio.linearFitSlope*(simulationResultsFinalPortfolio.trades[i-1].closeTime-simulationResultsFinalPortfolio.trades[0].closeTime) + simulationResultsFinalPortfolio.linearFitIntercept);
          end;

          MainForm.StatusLabel.Visible := false;
          end;

end;

procedure mergeIndicatorSimulationResults(var  simulationResultsPortfolio: array of TIndicatorSimulationResults; var simulationResultsFinalPortfolio: TIndicatorSimulationResults; startingTime, endingTime: TDateTime );
var
i, k, n, systemCount: integer;
initialProgressBarPosition : integer;
initialProgressBarMax      : integer;
initialStatusLabel         : string;
//currentBalance: double;
begin

 systemCount := Length(simulationResultsPortfolio) ;
 initialProgressBarPosition := MainForm.ProgressBar1.Position;
 initialProgressBarMax      := MainForm.ProgressBar1.Max;
 initialStatusLabel         := MainForm.StatusLabel.Caption;

 MainForm.ProgressBar1.Position := 0;
 MainForm.ProgressBar1.Max := HoursBetween(startingTime, endingTime);

 simulationResultsFinalPortfolio.absoluteProfitLongs := 0;
 simulationResultsFinalPortfolio.absoluteProfitShorts := 0;
 simulationResultsFinalPortfolio.startDate := startingTime;
 simulationResultsFinalPortfolio.endDate := endingTime;


//currentBalance := simulationResultsFinalPortfolio.balanceCurve[Length(simulationResultsFinalPortfolio.balanceCurve)-1];

for i:= 0 to HoursBetween(startingTime, endingTime) - 1 do
      begin

           MainForm.ProgressBar1.Position := MainForm.ProgressBar1.Position + 1;
           MainForm.StatusLabel.Caption := 'Merging results ' + IntToStr(simulationResultsFinalPortfolio.totalTrades) +' merged';

           if i Mod 100 = 0 then
           Application.ProcessMessages;

           for k := 0 to Length(simulationResultsPortfolio)-1 do
           begin

                for n:= 0 to Length(simulationResultsPortfolio[k].trades) - 1 do
                begin

                     if  CompareDateTime(simulationResultsPortfolio[k].trades[n].closeTime, IncHour(startingTime, i)) = 0 then
                     begin

                          SetLength(simulationResultsFinalPortfolio.trades, Length(simulationResultsFinalPortfolio.trades) + 1);
                          SetLength(simulationResultsFinalPortfolio.balanceCurve, Length(simulationResultsFinalPortfolio.balanceCurve) + 1);

                          simulationResultsFinalPortfolio.trades[Length(simulationResultsFinalPortfolio.trades) - 1] := simulationResultsPortfolio[k].trades[n] ;
                          simulationResultsFinalPortfolio.trades[Length(simulationResultsFinalPortfolio.trades) - 1].profit := simulationResultsPortfolio[k].trades[n].profit/systemCount ;
                          simulationResultsFinalPortfolio.balanceCurve[Length(simulationResultsFinalPortfolio.balanceCurve) - 1] := simulationResultsFinalPortfolio.balanceCurve[Length(simulationResultsFinalPortfolio.balanceCurve) - 2]+ simulationResultsPortfolio[k].trades[n].profit/systemCount ;

                          if  simulationResultsPortfolio[k].trades[n].orderType = BUY then
                          begin
                          simulationResultsFinalPortfolio.longTrades := simulationResultsFinalPortfolio.longTrades + 1 ;
                          simulationResultsFinalPortfolio.absoluteProfitLongs:=simulationResultsFinalPortfolio.absoluteProfitLongs+ simulationResultsFinalPortfolio.trades[Length(simulationResultsFinalPortfolio.trades) - 1].profit;
                          end;

                          if  simulationResultsPortfolio[k].trades[n].orderType = SELL then
                          begin
                          simulationResultsFinalPortfolio.shortTrades := simulationResultsFinalPortfolio.shortTrades + 1 ;
                          simulationResultsFinalPortfolio.absoluteProfitShorts := simulationResultsFinalPortfolio.absoluteProfitShorts+ simulationResultsFinalPortfolio.trades[Length(simulationResultsFinalPortfolio.trades) - 1].profit;
                          end;

                          simulationResultsFinalPortfolio.totalTrades := simulationResultsFinalPortfolio.totalTrades + 1 ;

                          // erases the trade from possible selection
                          simulationResultsPortfolio[k].trades[n].closeTime := Now+10;

                     //     if simulationResultsFinalPortfolio.balanceCurve[Length(simulationResultsFinalPortfolio.balanceCurve) - 1] < 0.8*currentBalance then
                     //     Exit;

                     end;

                end;

           end;

      end;

SetLength(simulationResultsFinalPortfolio.MFE_Longs, Length(simulationResultsPortfolio[0].MFE_Longs));
SetLength(simulationResultsFinalPortfolio.MUE_Longs, Length(simulationResultsPortfolio[0].MFE_Longs));
SetLength(simulationResultsFinalPortfolio.MFE_Shorts, Length(simulationResultsPortfolio[0].MFE_Longs));
SetLength(simulationResultsFinalPortfolio.MUE_Shorts, Length(simulationResultsPortfolio[0].MFE_Longs));

for n := 0 to Length(simulationResultsPortfolio[0].MFE_Longs)-1 do
    begin
          simulationResultsFinalPortfolio.MFE_Longs[n] :=0;
          simulationResultsFinalPortfolio.MUE_Longs[n] :=0;
          simulationResultsFinalPortfolio.MFE_Shorts[n] :=0;
          simulationResultsFinalPortfolio.MUE_Shorts[n] :=0;
    end;

for i := 0 to Length(simulationResultsPortfolio)-1  do
begin
    for n := 0 to Length(simulationResultsPortfolio[i].MFE_Longs)-1 do
    begin
          simulationResultsFinalPortfolio.MFE_Longs[n] :=simulationResultsFinalPortfolio.MFE_Longs[n]+ simulationResultsPortfolio[i].MFE_Longs[n]/Length(simulationResultsPortfolio);
          simulationResultsFinalPortfolio.MUE_Longs[n] :=simulationResultsFinalPortfolio.MUE_Longs[n]+ simulationResultsPortfolio[i].MUE_Longs[n]/Length(simulationResultsPortfolio);
          simulationResultsFinalPortfolio.MFE_Shorts[n] :=simulationResultsFinalPortfolio.MFE_Shorts[n]+ simulationResultsPortfolio[i].MFE_Shorts[n]/Length(simulationResultsPortfolio);
          simulationResultsFinalPortfolio.MUE_Shorts[n] :=simulationResultsFinalPortfolio.MUE_Shorts[n]+ simulationResultsPortfolio[i].MUE_Shorts[n]/Length(simulationResultsPortfolio);
    end;
end;

 MainForm.ProgressBar1.Position := initialProgressBarPosition ;
 MainForm.ProgressBar1.Max      := initialProgressBarMax      ;
 MainForm.StatusLabel.Caption   := initialStatusLabel ;

end;

procedure addIndicatorSimulationResults(simulationResultsInSample: TIndicatorSimulationResults; var simulationResults: TIndicatorSimulationResults; var simulationResultsFinal: TIndicatorSimulationResults);
var
i, n: integer;
expectedBalance: double;
begin

 SetLength(simulationResultsFinal.MFE_Longs, Length(simulationResults.MFE_Longs));
 SetLength(simulationResultsFinal.MUE_Longs, Length(simulationResults.MFE_Longs));
 SetLength(simulationResultsFinal.MFE_Shorts, Length(simulationResults.MFE_Longs));
 SetLength(simulationResultsFinal.MUE_Shorts, Length(simulationResults.MFE_Longs));

 for i:= 0 to Length(simulationResults.trades)-1 do
      begin

           SetLength(simulationResultsFinal.trades, Length(simulationResultsFinal.trades) + 1);
           SetLength(simulationResultsFinal.balanceCurve, Length(simulationResultsFinal.balanceCurve) + 1);

           expectedBalance := simulationResultsInSample.linearFitSlope*(simulationResults.trades[i].closeTime-simulationResultsInSample.trades[0].closeTime) + simulationResultsInSample.linearFitIntercept;

           simulationResultsFinal.trades[Length(simulationResultsFinal.trades) - 1] := simulationResults.trades[i] ;
           simulationResultsFinal.balanceCurve[Length(simulationResultsFinal.balanceCurve) - 1] := simulationResultsFinal.balanceCurve[Length(simulationResultsFinal.balanceCurve) - 2]+ simulationResults.trades[i].profit ;

           if  simulationResults.trades[i].orderType = BUY then
           begin
           simulationResultsFinal.longTrades := simulationResultsFinal.longTrades + 1 ;
           simulationResultsFinal.absoluteProfitLongs := simulationResultsFinal.absoluteProfitLongs  + simulationResults.trades[i].profit ;
           end;

           if  simulationResults.trades[i].orderType = SELL then
           begin
           simulationResultsFinal.shortTrades := simulationResultsFinal.shortTrades + 1 ;
           simulationResultsFinal.absoluteProfitShorts := simulationResultsFinal.absoluteProfitShorts + simulationResults.trades[i].profit ;
           end;

           simulationResultsFinal.totalTrades := simulationResultsFinal.totalTrades + 1 ;

           {if simulationResults.balanceCurve[i+1]+simulationResultsInSample.absoluteProfit < expectedBalance-simulationResultsInSample.standardDeviationResiduals*3 then
           begin
                SimulationForm.EndOutOfSampleCalendar.Date := simulationResults.trades[i].closeTime;
                break;
           end; }

      end;

 simulationResults := runIndicatorSimulation(      indicatorEntryPatterns[StrToInt(MainForm.ResultsGrid.Cells[IDX_GRID_RESULT_NUMBER , 1])-1],
                                                   indicatorClosePatterns[StrToInt(MainForm.ResultsGrid.Cells[IDX_GRID_RESULT_NUMBER , 1])-1],
                                                   FIRST_SYMBOL,
                                                   SimulationForm.useSLCheck.Checked,
                                                   SimulationForm.useTPCheck.Checked,
                                                   SimulationForm.EndInSampleCalendar.Date,
                                                   SimulationForm.EndOutOfSampleCalendar.Date,
                                                   true);

 simulationResultsFinal.totalLongSignals  := simulationResultsFinal.totalLongSignals+simulationResults.totalLongSignals;
 simulationResultsFinal.totalShortSignals := simulationResultsFinal.totalShortSignals+simulationResults.totalShortSignals;

 for n := 0 to Length(simulationResults.MFE_Longs)-1 do
    begin
        if simulationResultsFinal.totalLongSignals > 0 then
        begin
          simulationResultsFinal.MFE_Longs[n] :=simulationResultsFinal.MFE_Longs[n]*(simulationResultsFinal.totalLongSignals-simulationResults.totalLongSignals)/simulationResultsFinal.totalLongSignals+ simulationResults.MFE_Longs[n]/simulationResultsFinal.totalLongSignals ;
          simulationResultsFinal.MUE_Longs[n] :=simulationResultsFinal.MUE_Longs[n]*(simulationResultsFinal.totalLongSignals-simulationResults.totalLongSignals)/simulationResultsFinal.totalLongSignals+ simulationResults.MUE_Longs[n]/simulationResultsFinal.totalLongSignals;
        end;

        if simulationResultsFinal.totalShortSignals > 0 then
        begin
          simulationResultsFinal.MFE_Shorts[n] :=simulationResultsFinal.MFE_Shorts[n]*(simulationResultsFinal.totalShortSignals-simulationResults.totalShortSignals)/simulationResultsFinal.totalShortSignals+ simulationResults.MFE_Shorts[n]/simulationResultsFinal.totalShortSignals;
          simulationResultsFinal.MUE_Shorts[n] :=simulationResultsFinal.MUE_Shorts[n]*(simulationResultsFinal.totalShortSignals-simulationResults.totalShortSignals)/simulationResultsFinal.totalShortSignals+ simulationResults.MUE_Shorts[n]/simulationResultsFinal.totalShortSignals;
        end;
    end;

end;

Function hasPatternBeenTested(testedPatterns: TIndicatorPatternGroup; randomPattern:TIndicatorPattern): boolean;
var
i,j,k,matchingCount: integer;
totalRules: integer;
begin

 Result := false;

 totalRules := Length(randomPattern.tradingRules) ;

     for i:= 0 to Length(testedPatterns)-1 do
          begin

              if (randomPattern.SL <> testedPatterns[i].SL) then continue;
              if (randomPattern.TP <> testedPatterns[i].TP) then continue;

              matchingCount := 0;

              for j := 0 to  Length(testedPatterns[i].tradingRules)-1 do
                   begin

                       for k:=0 to totalRules-1 do
                            begin

                                if (randomPattern.tradingRules[k][IDX_FIRST_INDICATOR] = testedPatterns[i].tradingRules[j][IDX_FIRST_INDICATOR]) and
                                   (randomPattern.tradingRules[k][IDX_SECOND_INDICATOR] = testedPatterns[i].tradingRules[j][IDX_SECOND_INDICATOR]) and
                                   (randomPattern.tradingRules[k][IDX_FIRST_INDICATOR_SHIFT] = testedPatterns[i].tradingRules[j][IDX_FIRST_INDICATOR_SHIFT]) and
                                   (randomPattern.tradingRules[k][IDX_SECOND_INDICATOR_SHIFT] = testedPatterns[i].tradingRules[j][IDX_SECOND_INDICATOR_SHIFT])
                                   then
                                   begin
                                        matchingCount := matchingCount+1;
                                   end;


                            end;

                   end;

              if matchingCount = Length(testedPatterns[i].tradingRules) then
              begin
                   Result := true;
                   Exit;
              end;

          end;



end;

Function checkedInList(listIndex: integer):boolean;
var
   i: integer;
begin

 Result := false;

       if SimulationForm.UsedInputsList.Checked[listIndex] then
       Result := true;

end;

Function generateRandomIndicatorPattern(maxRules, maxCandleShift: Integer): TIndicatorPattern;
var
  randomPattern: TIndicatorPattern;
  i: integer;
  numberOfIndicators: integer;
  isShiftOne: boolean;
  maxSLTPTLSteps: integer;
  maxShiftSteps: integer;
  maxSLTPTL: double;
  stepSLTPTL: double;
  stepShift: integer;
begin

    numberOfIndicators := Length(LoadedIndicatorData[0]);
    isShiftOne := false;

    SetLength(randomPattern.tradingRules, Random(maxRules)+1);
    maxSLTPTL := StrToFloat(SimulationForm.OptionsGrid.Cells[1,IDX_OPT_MAX_SLTPTL]);


    randomPattern.allowLongSignals := true;
    randomPattern.allowShortSignals := true;

    if SimulationForm.AsymmetryCheck.Checked then
    begin
         randomPattern.allowLongSignals := globalAllowLongSignals;
         randomPattern.allowShortSignals := globalAllowShortSignals;
    end;

    stepShift :=StrToInt(SimulationForm.OptionsGrid.Cells[1,IDX_OPT_SHIFT_STEP ]);
    stepSLTPTL := StrToFloat(SimulationForm.OptionsGrid.Cells[1,IDX_OPT_SLTPTL_STEP]);
    maxShiftSteps := Round(maxCandleShift/stepShift) ;
    maxSLTPTLSteps :=   Round((maxSLTPTL-0.5)/stepSLTPTL) ;

    if SimulationForm.FixComplexityCheck.Checked then SetLength(randomPattern.tradingRules, maxRules);

    for i := 0 to Length(randomPattern.tradingRules)-1 do
    begin

     SetLength(randomPattern.tradingRules[i], INDICATOR_RULES_TOTAL);

     randomPattern.tradingRules[i][IDX_LOGIC_TYPE]  := LOGIC_AND;

     randomPattern.tradingRules[i][IDX_SIZE_COMPARISON]  := 0;

     randomPattern.tradingRules[i][IDX_FIRST_INDICATOR_SHIFT]    := stepShift*RandomRange(0, maxShiftSteps);
     randomPattern.tradingRules[i][IDX_SECOND_INDICATOR_SHIFT]    := stepShift*RandomRange(0, maxShiftSteps);

     randomPattern.tradingRules[i][IDX_FIRST_INDICATOR]  := RandomRange(0, numberOfIndicators);
     randomPattern.tradingRules[i][IDX_SECOND_INDICATOR] := RandomRange(0, numberOfIndicators);

     while (checkedInList(randomPattern.tradingRules[i][IDX_FIRST_INDICATOR])=false) do randomPattern.tradingRules[i][IDX_FIRST_INDICATOR]  := RandomRange(0, numberOfIndicators);

     if  (randomPattern.tradingRules[i][IDX_FIRST_INDICATOR] = 4) or (randomPattern.tradingRules[i][IDX_FIRST_INDICATOR] = 5) then
     begin
          if RandomRange(0, 100) < 50 then
          randomPattern.tradingRules[i][IDX_SECOND_INDICATOR] := 4 else
          randomPattern.tradingRules[i][IDX_SECOND_INDICATOR] := 5 ;
     end;

     if  (randomPattern.tradingRules[i][IDX_FIRST_INDICATOR] <> 4) and (randomPattern.tradingRules[i][IDX_FIRST_INDICATOR] <> 5) then
     begin
          while (randomPattern.tradingRules[i][IDX_SECOND_INDICATOR] = 4) or (randomPattern.tradingRules[i][IDX_SECOND_INDICATOR] = 5) do
          randomPattern.tradingRules[i][IDX_SECOND_INDICATOR] := RandomRange(0, numberOfIndicators);
     end;

     while (randomPattern.tradingRules[i][IDX_FIRST_INDICATOR] = randomPattern.tradingRules[i][IDX_SECOND_INDICATOR]) and
           (randomPattern.tradingRules[i][IDX_FIRST_INDICATOR_SHIFT] = randomPattern.tradingRules[i][IDX_SECOND_INDICATOR_SHIFT]) do
     begin
          randomPattern.tradingRules[i][IDX_SECOND_INDICATOR_SHIFT]    := stepShift*RandomRange(0, maxShiftSteps);
     end;

     if randomPattern.tradingRules[i][IDX_FIRST_INDICATOR_SHIFT] = 0 then isShiftOne := true;
     if randomPattern.tradingRules[i][IDX_SECOND_INDICATOR_SHIFT] = 0 then isShiftOne := true;

     while (checkedInList(randomPattern.tradingRules[i][IDX_SECOND_INDICATOR])=false) do
     begin
          randomPattern.tradingRules[i][IDX_SECOND_INDICATOR]  := RandomRange(0, numberOfIndicators);

          if  (randomPattern.tradingRules[i][IDX_FIRST_INDICATOR] = 4) or (randomPattern.tradingRules[i][IDX_FIRST_INDICATOR] = 5) then
          begin
               if RandomRange(0, 100) < 50 then
               randomPattern.tradingRules[i][IDX_SECOND_INDICATOR] := 4 else
               randomPattern.tradingRules[i][IDX_SECOND_INDICATOR] := 5 ;
          end;

          if  (randomPattern.tradingRules[i][IDX_FIRST_INDICATOR] <> 4) and (randomPattern.tradingRules[i][IDX_FIRST_INDICATOR] <> 5) then
          begin
               while (randomPattern.tradingRules[i][IDX_SECOND_INDICATOR] = 4) or (randomPattern.tradingRules[i][IDX_SECOND_INDICATOR] = 5) do
               randomPattern.tradingRules[i][IDX_SECOND_INDICATOR] := RandomRange(0, numberOfIndicators);
          end;
     end;

    end;


   // while isIndicatorPatternPresent(randomPattern) do
    //randomPattern := generateRandomIndicatorPattern(maxRules, maxCandleShift);


    randomPattern.SL := Max(stepSLTPTL, 0.5) + stepSLTPTL*RandomRange(0,maxSLTPTLSteps);
    randomPattern.TP := Max(stepSLTPTL, 0.5) + stepSLTPTL*RandomRange(0,maxSLTPTLSteps);
    randomPattern.TL := Max(stepSLTPTL, 0.5) + stepSLTPTL*RandomRange(0,maxSLTPTLSteps);

    randomPattern.SLTSLope := -randomPattern.SL/RandomRange(10,50) ;

   // ShowMessage(FloatToStr(  randomPattern.SL ) + ' ' + IntToStr(maxSLTPTLSteps) + FloatToStr(  stepSLTPTL ) );

    randomPattern.hourFilter := RandomRange(0,23);
    if SimulationForm.UseFixedHour.Checked then randomPattern.hourFilter := StrToInt(SimulationForm.OptionsGrid.Cells[1,IDX_OPT_FIXED_HOUR]);

    randomPattern.dayFilter  := RandomRange(2,6);
    randomPattern.timeExit   := RandomRange(1,50);

    if (SimulationForm.useSLCheck.Checked = false) then
    randomPattern.SL := 2;

    if SimulationForm.UseFixedSLTP.Checked then
    begin
    randomPattern.SL := StrToFloat(SimulationForm.OptionsGrid.Cells[1,IDX_OPT_FIXED_SL]);
    randomPattern.TP := StrToFloat(SimulationForm.OptionsGrid.Cells[1,IDX_OPT_FIXED_TP]);
    randomPattern.TL := StrToFloat(SimulationForm.OptionsGrid.Cells[1,IDX_OPT_FIXED_TL]);
    end;

    Result := randomPattern ;

end;

Function isIndicatorPositiveResult(simulationResults: TIndicatorSimulationResults): boolean;
begin

 Result := false ;

 if simulationResults.totalYears = 0 then Exit;


 if  (
     ( simulationResults.balanceCurve[Length(simulationResults.balanceCurve)-1] > INITIAL_BALANCE) and
    // ( Abs(simulationResults.longTrades - simulationResults.shortTrades) < 0.5*Min(simulationResults.longTrades, simulationResults.shortTrades)) and
     ( (simulationResults.totalTrades/simulationResults.totalYears > StrToFloat(FiltersForm.FiltersGrid.Cells[2, IDX_FILTER_TRADES])) or (FiltersForm.FiltersGrid.Cells[1, IDX_FILTER_TRADES] = '0')) and
     ( (simulationResults.rewardToRisk > StrToFloat(FiltersForm.FiltersGrid.Cells[2, IDX_FILTER_RISK_TO_REWARD])) or (FiltersForm.FiltersGrid.Cells[1, IDX_FILTER_RISK_TO_REWARD] = '0')) and
     ( (simulationResults.winningPercent > StrToFloat(FiltersForm.FiltersGrid.Cells[2, IDX_FILTER_WINNING_PERCENT])) or (FiltersForm.FiltersGrid.Cells[1, IDX_FILTER_WINNING_PERCENT]= '0')) and
     ( (simulationResults.absoluteProfit > StrToFloat(FiltersForm.FiltersGrid.Cells[2, IDX_FILTER_PROFIT])) or (FiltersForm.FiltersGrid.Cells[1, IDX_FILTER_PROFIT] = '0')) and
     ( (simulationResults.profitToDD > StrToFloat(FiltersForm.FiltersGrid.Cells[2, IDX_FILTER_PROFIT_TO_DD])) or (FiltersForm.FiltersGrid.Cells[1, IDX_FILTER_PROFIT_TO_DD] = '0')) and
     ( (simulationResults.maximumDrawDown > StrToFloat(FiltersForm.FiltersGrid.Cells[2, IDX_FILTER_DD])) or (FiltersForm.FiltersGrid.Cells[1, IDX_FILTER_DD] = '0')) and
     ( (simulationResults.maximumDrawDownLength > StrToFloat(FiltersForm.FiltersGrid.Cells[2, IDX_FILTER_DD_LENGTH])) or (FiltersForm.FiltersGrid.Cells[1, IDX_FILTER_DD_LENGTH] = '0')) and
     ( (simulationResults.profitFactor  > StrToFloat(FiltersForm.FiltersGrid.Cells[2, IDX_FILTER_PROFIT_FACTOR])) or (FiltersForm.FiltersGrid.Cells[1, IDX_FILTER_PROFIT_FACTOR] = '0')) and
     ( (simulationResults.linearFitR2  > StrToFloat(FiltersForm.FiltersGrid.Cells[2, IDX_FILTER_LINEAR_FIT_R2])) or (FiltersForm.FiltersGrid.Cells[1, IDX_FILTER_LINEAR_FIT_R2] = '0')) and
     ( (simulationResults.systemQualityNumber > StrToFloat(FiltersForm.FiltersGrid.Cells[2, IDX_FILTER_SQN])) or (FiltersForm.FiltersGrid.Cells[1, IDX_FILTER_SQN] = '0')) and
     ( (simulationResults.customFilter > StrToFloat(FiltersForm.FiltersGrid.Cells[2, IDX_FILTER_CUSTOM])) or (FiltersForm.FiltersGrid.Cells[1, IDX_FILTER_CUSTOM] = '0')) and
     ( (simulationResults.skewness > StrToFloat(FiltersForm.FiltersGrid.Cells[2, IDX_FILTER_SKEWNESS])) or (FiltersForm.FiltersGrid.Cells[1, IDX_FILTER_SKEWNESS] = '0')) and
     ( (simulationResults.kurtosis > StrToFloat(FiltersForm.FiltersGrid.Cells[2, IDX_FILTER_KURTOSIS])) or (FiltersForm.FiltersGrid.Cells[1, IDX_FILTER_KURTOSIS] = '0')) and
     ( (simulationResults.standardDeviation > StrToFloat(FiltersForm.FiltersGrid.Cells[2, IDX_FILTER_STD_DEV])) or (FiltersForm.FiltersGrid.Cells[1, IDX_FILTER_STD_DEV] = '0')) and
     ( (simulationResults.modifiedSharpeRatio > StrToFloat(FiltersForm.FiltersGrid.Cells[2, IDX_FILTER_MODIFIED_SHARPE_RATIO])) or (FiltersForm.FiltersGrid.Cells[1, IDX_FILTER_MODIFIED_SHARPE_RATIO] = '0')) and
     ( (simulationResults.ulcerIndex > StrToFloat(FiltersForm.FiltersGrid.Cells[2, IDX_FILTER_ULCER_INDEX])) or (FiltersForm.FiltersGrid.Cells[1, IDX_FILTER_ULCER_INDEX] = '0')) and
     ( (simulationResults.standardDeviationBreach > StrToFloat(FiltersForm.FiltersGrid.Cells[2, IDX_FILTER_STD_DEV_BREACH])) or (FiltersForm.FiltersGrid.Cells[1, IDX_FILTER_STD_DEV_BREACH] = '0')) and
     ( (simulationResults.idealR > StrToFloat(FiltersForm.FiltersGrid.Cells[2, IDX_FILTER_IDEAL_R])) or (FiltersForm.FiltersGrid.Cells[1, IDX_FILTER_IDEAL_R] = '0')) and
     //
     ( (simulationResults.ulcerIndex > StrToFloat(FiltersForm.FiltersGrid.Cells[2, IDX_FILTER_ULCER_INDEX])) or (FiltersForm.FiltersGrid.Cells[1, IDX_FILTER_ULCER_INDEX] = '0')) and
     ( (simulationResults.totalTrades/simulationResults.totalYears < StrToFloat(FiltersForm.FiltersGrid.Cells[4, IDX_FILTER_TRADES])) or (FiltersForm.FiltersGrid.Cells[3, IDX_FILTER_TRADES] = '0')) and
     ( (simulationResults.rewardToRisk < StrToFloat(FiltersForm.FiltersGrid.Cells[4, IDX_FILTER_RISK_TO_REWARD])) or (FiltersForm.FiltersGrid.Cells[3, IDX_FILTER_RISK_TO_REWARD] = '0')) and
     ( (simulationResults.winningPercent < StrToFloat(FiltersForm.FiltersGrid.Cells[4, IDX_FILTER_WINNING_PERCENT])) or (FiltersForm.FiltersGrid.Cells[3, IDX_FILTER_WINNING_PERCENT]= '0')) and
     ( (simulationResults.absoluteProfit < StrToFloat(FiltersForm.FiltersGrid.Cells[4, IDX_FILTER_PROFIT])) or (FiltersForm.FiltersGrid.Cells[3, IDX_FILTER_PROFIT] = '0')) and
     ( (simulationResults.profitToDD < StrToFloat(FiltersForm.FiltersGrid.Cells[4, IDX_FILTER_PROFIT_TO_DD])) or (FiltersForm.FiltersGrid.Cells[3, IDX_FILTER_PROFIT_TO_DD] = '0')) and
     ( (simulationResults.maximumDrawDown < StrToFloat(FiltersForm.FiltersGrid.Cells[4, IDX_FILTER_DD])) or (FiltersForm.FiltersGrid.Cells[3, IDX_FILTER_DD] = '0')) and
     ( (simulationResults.maximumDrawDownLength < StrToFloat(FiltersForm.FiltersGrid.Cells[4, IDX_FILTER_DD_LENGTH])) or (FiltersForm.FiltersGrid.Cells[3, IDX_FILTER_DD_LENGTH] = '0')) and
     ( (simulationResults.profitFactor  < StrToFloat(FiltersForm.FiltersGrid.Cells[4, IDX_FILTER_PROFIT_FACTOR])) or (FiltersForm.FiltersGrid.Cells[3, IDX_FILTER_PROFIT_FACTOR] = '0')) and
     ( (simulationResults.linearFitR2  < StrToFloat(FiltersForm.FiltersGrid.Cells[4, IDX_FILTER_LINEAR_FIT_R2])) or (FiltersForm.FiltersGrid.Cells[3, IDX_FILTER_LINEAR_FIT_R2] = '0')) and
     ( (simulationResults.systemQualityNumber < StrToFloat(FiltersForm.FiltersGrid.Cells[4, IDX_FILTER_SQN])) or (FiltersForm.FiltersGrid.Cells[3, IDX_FILTER_SQN] = '0')) and
     ( (simulationResults.customFilter < StrToFloat(FiltersForm.FiltersGrid.Cells[4, IDX_FILTER_CUSTOM])) or (FiltersForm.FiltersGrid.Cells[3, IDX_FILTER_CUSTOM] = '0')) and
     ( (simulationResults.skewness < StrToFloat(FiltersForm.FiltersGrid.Cells[4, IDX_FILTER_SKEWNESS])) or (FiltersForm.FiltersGrid.Cells[3, IDX_FILTER_SKEWNESS] = '0')) and
     ( (simulationResults.kurtosis < StrToFloat(FiltersForm.FiltersGrid.Cells[4, IDX_FILTER_KURTOSIS])) or (FiltersForm.FiltersGrid.Cells[3, IDX_FILTER_KURTOSIS] = '0')) and
     ( (simulationResults.standardDeviation < StrToFloat(FiltersForm.FiltersGrid.Cells[4, IDX_FILTER_STD_DEV])) or (FiltersForm.FiltersGrid.Cells[3, IDX_FILTER_STD_DEV] = '0')) and
     ( (simulationResults.modifiedSharpeRatio < StrToFloat(FiltersForm.FiltersGrid.Cells[4, IDX_FILTER_MODIFIED_SHARPE_RATIO])) or (FiltersForm.FiltersGrid.Cells[3, IDX_FILTER_STD_DEV] = '0')) and
     ( (simulationResults.ulcerIndex < StrToFloat(FiltersForm.FiltersGrid.Cells[4, IDX_FILTER_ULCER_INDEX])) or (FiltersForm.FiltersGrid.Cells[3, IDX_FILTER_ULCER_INDEX] = '0')) and
     ( (simulationResults.standardDeviationBreach < StrToFloat(FiltersForm.FiltersGrid.Cells[4, IDX_FILTER_STD_DEV_BREACH])) or (FiltersForm.FiltersGrid.Cells[3, IDX_FILTER_STD_DEV_BREACH] = '0')) and
     ( (simulationResults.idealR < StrToFloat(FiltersForm.FiltersGrid.Cells[4, IDX_FILTER_IDEAL_R])) or (FiltersForm.FiltersGrid.Cells[3, IDX_FILTER_IDEAL_R] = '0')) and
     ( (simulationResults.isLastYearProfit and FiltersForm.isLastYearProfitCheck.Checked) or (FiltersForm.isLastYearProfitCheck.Checked = false))
     ) then
     begin
          Result := true;
     end;

end;

Function getIndicatorCustomCriteria(simulationResults: TIndicatorSimulationResults): double;
var
i: integer;
FParser: TFPExpressionParser;
parserResult: TFPExpressionResult;
begin

 Result := 0;

 if CustomFilterForm.CustomFormulaEdit.Text = '0' then Exit;

 FParser := TFpExpressionParser.Create(SimulationForm);
 FParser.BuiltIns := [bcMath];

      for i:= 1 to 20 do
      begin

           case i of
           1: FParser.identifiers.AddFloatVariable('AP', simulationResults.absoluteProfit)  ;
           2: FParser.identifiers.AddFloatVariable('APT', simulationResults.absoluteProfit/simulationResults.totalTrades)  ;
           3: FParser.identifiers.AddFloatVariable('TT', simulationResults.longTrades)  ;
           4: FParser.identifiers.AddFloatVariable('ST', simulationResults.shortTrades)  ;
           5: FParser.identifiers.AddFloatVariable('LT', simulationResults.totalTrades)  ;
           6: FParser.identifiers.AddFloatVariable('MD', simulationResults.maximumDrawDown)  ;
           7: FParser.identifiers.AddFloatVariable('MDL', simulationResults.maximumDrawDownLength)  ;
           8: FParser.identifiers.AddFloatVariable('CL', simulationResults.consecutiveLoses)  ;
           9: FParser.identifiers.AddFloatVariable('CW', simulationResults.consecutiveWins)  ;
          10: FParser.identifiers.AddFloatVariable('PD', simulationResults.profitToDD)  ;
          11: FParser.identifiers.AddFloatVariable('RR', simulationResults.rewardToRisk)  ;
          12: FParser.identifiers.AddFloatVariable('SK', simulationResults.skewness)  ;
          13: FParser.identifiers.AddFloatVariable('KR', simulationResults.kurtosis)  ;
          14: FParser.identifiers.AddFloatVariable('WP', simulationResults.winningPercent)  ;
          15: FParser.identifiers.AddFloatVariable('PF', simulationResults.profitFactor)  ;
          16: FParser.identifiers.AddFloatVariable('R2', simulationResults.linearFitR2)  ;
          17: FParser.identifiers.AddFloatVariable('SQN', simulationResults.systemQualityNumber)  ;
          18: FParser.identifiers.AddFloatVariable('UI', simulationResults.ulcerIndex)  ;
          19: FParser.identifiers.AddFloatVariable('STDDEV', simulationResults.standardDeviation)  ;
          20: FParser.identifiers.AddFloatVariable('MSR', simulationResults.modifiedSharpeRatio)  ;
           end;

      end;

      try

      FParser.Expression := CustomFilterForm.CustomFormulaEdit.Text;
      parserResult := FParser.Evaluate;
      Result := parserResult.ResFloat;

      except on Exception do
             begin
                  ShowMessage('Custom criteria is invalid. Canceling simulation.') ;
                  MainForm.isCancel := true;
                  FParser.Free;
                  Exit;
             end;
      end;

      FParser.Free;

end;

Function evaluateIndicatorPattern(symbol: integer; testPattern: TIndicatorPattern; currentShift: integer; logic:integer; evaluationType: integer): boolean;
var
  i: integer;
  firstIndicator, secondIndicator: integer;
  firstShift, secondShift: integer;
  countAND: integer;
  countOR, totalAND, totalOR: integer;
  currentTime: TDateTime;
  HH,MM,SS,MS: Word;
  logicType: integer;
  firstIndicatorSell: integer;
  secondIndicatorSell: integer;
begin

    Result := false;
    countAND := 0;
    countOR := 0;

    currentTime := LoadedIndiHistoryData[symbol].time[currentShift+1];

    if (SimulationForm.UseHourFilter.Checked) or  (SimulationForm.UseDayFilter.Checked) then
    begin
         DecodeTime(currentTime,HH,MM,SS,MS);

         if (SimulationForm.UseHourFilter.Checked) and ( HH <> testPattern.hourFilter) then
         begin
              Result := false;
              Exit;
              end;

         if (SimulationForm.UseDayFilter.Checked) and ( DayOfWeek(currentTime) <> testPattern.dayFilter) then
         begin
              Result := false;
              Exit;
         end;

    end;

    totalAND := 0;
    totalOR := 0;

    for i:=0 to Length(testPattern.tradingRules)-1 do
    begin

     firstIndicator  := testPattern.tradingRules[i][IDX_FIRST_INDICATOR];
     secondIndicator := testPattern.tradingRules[i][IDX_SECOND_INDICATOR];
     firstShift      := testPattern.tradingRules[i][IDX_FIRST_INDICATOR_SHIFT];
     secondShift     := testPattern.tradingRules[i][IDX_SECOND_INDICATOR_SHIFT];
     logicType       := testPattern.tradingRules[i][IDX_LOGIC_TYPE];

     if logicType = LOGIC_AND then totalAND := totalAND + 1;
     if logicType = LOGIC_OR then totalOR := totalOR + 1;

     if (testPattern.tradingRules[i][IDX_SIZE_COMPARISON] <> 0 ) and
        (Abs(LoadedIndicatorData[symbol][3].data[currentShift-firstShift]-LoadedIndicatorData[symbol][0].data[currentShift-firstShift]) < testPattern.tradingRules[i][IDX_SIZE_COMPARISON]*0.01*LoadedIndiHistoryData[symbol].ATR[currentShift-firstShift])
        then
        continue;

       if
          (LoadedIndicatorData[symbol][firstIndicator].data[currentShift-firstShift] > LoadedIndicatorData[symbol][secondIndicator].data[currentShift-secondShift] ) and
          (logic = BUY)
          then
          begin

               if logicType = LOGIC_AND then
               countAND := countAND + 1;

               if logicType = LOGIC_OR then
               countOR := countOR + 1;
          end;

       firstIndicatorSell := firstIndicator;
       secondIndicatorSell := secondIndicator;

       if firstIndicator = 1 then
       firstIndicatorSell := 2;

       if firstIndicator = 2 then
       firstIndicatorSell := 1;

       if secondIndicator = 1 then
       secondIndicatorSell := 2;

       if secondIndicator = 2 then
       secondIndicatorSell := 1;

       if
          (LoadedIndicatorData[symbol][firstIndicatorSell].data[currentShift-firstShift] < LoadedIndicatorData[symbol][secondIndicatorSell].data[currentShift-secondShift] ) and
          (logic = SELL) and
          (firstIndicatorSell <> 4) and
          (firstIndicatorSell <> 5)
          then
          begin
               if logicType = LOGIC_AND then
               countAND := countAND + 1;

               if logicType = LOGIC_OR then
               countOR := countOR + 1;
          end;

       if
          (LoadedIndicatorData[symbol][firstIndicatorSell].data[currentShift-firstShift] > LoadedIndicatorData[symbol][secondIndicatorSell].data[currentShift-secondShift] ) and
          (logic = SELL) and
          ((firstIndicatorSell = 4) or (firstIndicatorSell = 5))
          then
          begin
               if logicType = LOGIC_AND then
               countAND := countAND + 1;

               if logicType = LOGIC_OR then
               countOR := countOR + 1;
          end;

    end;

    if (countAND = totalAND) and ((countOR > 0) or (totalOR = 0)) then
    Result := true ;

end;

Function barsBetween(openTime: TDateTime; currentShift, symbol: integer): integer;
var
  i: integer;
begin

    Result := 0;
    i := 0;

      while (LoadedIndiHistoryData[symbol].time[currentShift-i] > openTime) or (i >= currentShift) do
      begin

       Result := Result + 1;
       i := i+1;

      end;

end;

Procedure getIndicatorStatistics(var simulationResults: TIndicatorSimulationResults);
var
i, j, skip: integer;
tradeProfits: array of extended;
consecutiveLoses, consecutiveWins: integer;
balanceHigh, maxDrawDown: double;
drawDownStart: TDateTime;
maxDrawDownLength, drawDownLength: integer;
winningTradeCount: integer;
grossProfit, grossLoss: double;
averageProfit, averageLoss: double;
dataForFit: TRealPointArray;
dataforFit2: TRealPointArray;
standardDeviationTrades, averageTrades: extended;
m1, m2, m3, m4, tradeKurtosis, tradeSkewness: extended;
m, b, r: extended;
carriedBalance: double;
SumSquares: double;
tradeEachYear: boolean;
ME_Long, ME_Short: double;
regressionResiduals: array of double;
averageResiduals, standardDeviationResiduals: extended;
idealR, idealRstandardDeviation: extended;
idealRPeriodCorrelations: array of double;
begin

 simulationResults.absoluteProfit         := 0;
 simulationResults.consecutiveLoses       := 0;
 simulationResults.profitFactor           := 0;
 simulationResults.profitToDD             := 0;
 simulationResults.rewardToRisk           := 0;
 simulationResults.winningPercent         := 0;
 simulationResults.consecutiveWins        := 0;
 simulationResults.skewness               := 0;
 simulationResults.maximumDrawDown        := 0;
 simulationResults.kurtosis               := 0;
 simulationResults.maximumDrawDownLength  := 0;
 simulationResults.ulcerIndex             := 0;
 simulationResults.linearFitSlope         := 0;
 simulationResults.linearFitIntercept     := 0;
 simulationResults.linearFitR2            := 0;
 simulationResults.standardDeviation      := 0;
 simulationResults.standardDeviationBreach:= 0;
 simulationResults.customFilter           := 0;
 simulationResults.modifiedSharpeRatio    := 0;
 simulationResults.systemQualityNumber    := 0;
 simulationResults.total_ME               := 0;
 simulationResults.idealR                 := 0;
 consecutiveWins                          := 0;
 consecutiveLoses                         := 0;
 winningTradeCount                        := 0;
 grossProfit                              := 0;
 grossLoss                                := 0;
 SetLength(dataForFit, 0);
 SetLength(dataForFit2, 0);
 simulationResults.ulcerIndex := 0;
 m := 0;
 b := 0;
 r := 0;
 averageProfit := 0;
 averageLoss   := 0;
 standardDeviationTrades := 0;
 averageTrades := 0;
 simulationResults.totalYears := 100000;

 if (simulationResults.totalTrades < 3) then Exit;

 simulationResults.totalYears := DaysBetween( simulationResults.startDate ,  simulationResults.endDate)/365;

 if simulationResults.totalYears = 0 then Exit;

 try // try to calculate statistics

 if length(simulationResults.entryPricePattern.tradingRules) > 0 then
 begin
 simulationResults.lowestLag := simulationResults.entryPricePattern.tradingRules[0][IDX_FIRST_INDICATOR_SHIFT];

 for i:= 0 to Length(simulationResults.entryPricePattern.tradingRules)-1 do
 begin

     if simulationResults.entryPricePattern.tradingRules[i][IDX_FIRST_INDICATOR_SHIFT] < simulationResults.lowestLag then
     simulationResults.lowestLag := simulationResults.entryPricePattern.tradingRules[i][IDX_FIRST_INDICATOR_SHIFT];

     if simulationResults.entryPricePattern.tradingRules[i][IDX_SECOND_INDICATOR_SHIFT] < simulationResults.lowestLag then
     simulationResults.lowestLag := simulationResults.entryPricePattern.tradingRules[i][IDX_SECOND_INDICATOR_SHIFT];

 end;

 end;

  {
    if YearsBetween(simulationResults.startDate, simulationResults.endDate) <> 0 then
    begin

       for j:= 0 to YearsBetween(simulationResults.startDate, simulationResults.endDate)-1 do
       begin

         tradeEachYear := false;

         for i:= 0 to Length(simulationResults.trades)-1 do
         begin
              if YearOf( simulationResults.trades[i].openTime) = YearOf(simulationResults.startDate) + j then
              begin
              tradeEachYear := true;
              break;
              end;
         end;

         if tradeEachYear = false then Exit;

        end;
    end;   }


     simulationResults.absoluteProfit         := simulationResults.balanceCurve[Length(simulationResults.balanceCurve)-1] - INITIAL_BALANCE;
     SetLength(tradeProfits, Length(simulationResults.trades));

     for i:= 0 to Length(simulationResults.trades)-1 do
     begin

        tradeProfits[i] := simulationResults.trades[i].profit ;

        if simulationResults.trades[i].profit > 0 then
        begin
           consecutiveWins := consecutiveWins + 1 ;
           consecutiveLoses := 0;
           winningTradeCount := winningTradeCount + 1;
           grossProfit := grossProfit + simulationResults.trades[i].profit;
           averageProfit := simulationResults.trades[i].profit/(i+1)+ averageProfit*(i)/(i+1) ;
        end;

        if simulationResults.trades[i].profit < 0 then
        begin
           consecutiveLoses := consecutiveLoses + 1 ;
           consecutiveWins := 0;
           grossLoss := grossLoss + simulationResults.trades[i].profit;
           averageLoss := simulationResults.trades[i].profit/(i+1)+ averageLoss*(i)/(i+1) ;
        end;

        if consecutiveLoses > simulationResults.consecutiveLoses then
        simulationResults.consecutiveLoses := consecutiveLoses;

        if consecutiveWins > simulationResults.consecutiveWins then
        simulationResults.consecutiveWins := consecutiveWins;

     end;

     balanceHigh    := INITIAL_BALANCE;
     carriedBalance := INITIAL_BALANCE;
     SumSquares     := 0;
     skip           := 0;

     // ulcer index calculation
     for i:=0 to DaysBetween(simulationResults.startDate, simulationResults.endDate)-1 do
     begin

          for j:= skip to Length(simulationResults.trades)-1 do
          begin

             if CompareDate(simulationResults.trades[j].closeTime, IncDay(simulationResults.startDate, i)) = 0 then
             begin
             carriedBalance := carriedBalance + simulationResults.trades[j].profit;
             skip := j+1;
             end;

             if  DaysBetween(simulationResults.trades[j].closeTime, IncDay(simulationResults.startDate, i)) > 1 then
             Break;

          end;

          if carriedBalance > balanceHigh then balanceHigh := carriedBalance
          else SumSquares := SumSquares + (100 * ((carriedBalance / balanceHigh) -1))*(100 * ((carriedBalance / balanceHigh) -1)) ;

     end;

     simulationResults.ulcerIndex := sqrt(SumSquares / DaysBetween(simulationResults.startDate, simulationResults.endDate)) ;

     maxDrawDown   := 0;
     balanceHigh   := INITIAL_BALANCE;
     maxDrawDownLength := 0;
     drawDownStart := simulationResults.trades[0].closeTime;

     simulationResults.total_ME := 0;

     for i:= 0 to Length(simulationResults.MFE_Longs)-1 do begin
         ME_Long := (simulationResults.MFE_Longs[i]-simulationResults.MUE_Longs[i]);
         ME_Short := (simulationResults.MFE_Shorts[i]-simulationResults.MUE_Shorts[i]);

         simulationResults.total_ME := simulationResults.total_ME + ME_Long + ME_Short;

     end;

     for i:= 1 to Length(simulationResults.balanceCurve)-1 do
     begin

        SetLength(dataForFit, Length(dataForFit)+1);
        dataForFit[ Length(dataForFit)-1].x := simulationResults.trades[i-1].closeTime ;
        dataForFit[ Length(dataForFit)-1].y := simulationResults.balanceCurve[i] ;

        if simulationResults.balanceCurve[i] >= balanceHigh then
        begin
             balanceHigh    := simulationResults.balanceCurve[i];
             drawDownStart := simulationResults.trades[i-1].closeTime;
        end;

        drawDownLength := DaysBetween(simulationResults.trades[i-1].closeTime, drawDownStart);

        if (drawDownLength > maxDrawDownLength) then
        maxDrawDownLength := drawDownLength;

        if (100*(balanceHigh - simulationResults.balanceCurve[i])/INITIAL_BALANCE > maxDrawDown) and (simulationResults.balanceCurve[i] < balanceHigh) then
        maxDrawDown :=  100*(balanceHigh - simulationResults.balanceCurve[i])/INITIAL_BALANCE ;

     end;

     r := 0;

     // fits to y = m*x+b
     try
     MainForm.LinearLeastSquares(dataforFit, m, b, r);
     except on Exception do
     //do nothing if there is an exception
     end;

     if r > 0 then
     simulationResults.linearFitR2             := Round(r*1000)/1000;

     if ((simulationResults.totalTrades-winningTradeCount) <> 0) and (winningTradeCount <> 0) then
     simulationResults.rewardToRisk            := (grossProfit/winningTradeCount)/(grossProfit/(simulationResults.totalTrades-winningTradeCount));

     simulationResults.profitFactor            := 0;

     if (grossLoss <> 0) then
     simulationResults.profitFactor            := Abs(grossProfit/grossLoss);

     simulationResults.winningPercent          := (winningTradeCount/simulationResults.totalTrades)*100 ;
     simulationResults.maximumDrawDown         := maxDrawDown;
     simulationResults.maximumDrawDownLength   := maxDrawDownLength;

     if simulationResults.totalTrades > 10 then
     begin
          momentskewkurtosis(tradeProfits, m1, m2, m3, m4, tradeKurtosis, tradeSkewness);
          simulationResults.skewness     := tradeSkewness;
          simulationResults.kurtosis     := tradeKurtosis;
     end;

     averageTrades := 0;
     standardDeviationTrades := 0;

     if Length(tradeProfits) > 10 then
     meanandstddev(tradeProfits, averageTrades, standardDeviationTrades);

     // calculate standard deviation of residuals.
     for i:= 1 to Length(simulationResults.balanceCurve)-1 do
     begin

        SetLength(regressionResiduals, Length(regressionResiduals)+1);
        regressionResiduals[ Length(regressionResiduals)-1] := (m*(simulationResults.trades[i-1].closeTime-simulationResults.trades[0].closeTime)+b)-simulationResults.balanceCurve[i] ;

     end;

     simulationResults.isLastYearProfit:= false;

     for i:= Length(simulationResults.balanceCurve)-1 downto 1 do
     begin
          if DaysBetween(simulationResults.trades[Length(simulationResults.balanceCurve)-2].closeTime, simulationResults.trades[i-1].closeTime) >= 365 then
          begin
               if (simulationResults.balanceCurve[Length(simulationResults.balanceCurve)-1] > simulationResults.balanceCurve[i]) then
               simulationResults.isLastYearProfit:= true;

               break;
          end;

     end;

     standardDeviationResiduals := 0;
     averageResiduals := 0;

     if Length(regressionResiduals) > 10 then
     meanandstddev(regressionResiduals, averageResiduals, standardDeviationResiduals);

     simulationResults.standardDeviationBreach := 0;

     // check for 2std dev line breach breach

     if standardDeviationResiduals <> 0 then
     begin
          for i:= 1 to Length(simulationResults.balanceCurve)-1 do
          begin

               if ((m*(simulationResults.trades[i-1].closeTime-simulationResults.trades[0].closeTime)+b) - simulationResults.balanceCurve[i])/standardDeviationResiduals > simulationResults.standardDeviationBreach then
               simulationResults.standardDeviationBreach := ((m*(simulationResults.trades[i-1].closeTime-simulationResults.trades[0].closeTime)+b) - simulationResults.balanceCurve[i])/standardDeviationResiduals;

          end;
     end;

     simulationResults.systemQualityNumber := 0;

     if (standardDeviationTrades > 0) then
     simulationResults.systemQualityNumber := Sqrt(simulationResults.totalTrades)*(averageTrades/standardDeviationTrades);

     if (maxDrawDown <> 0) then
     simulationResults.profitToDD              := (simulationResults.absoluteProfit/simulationResults.totalYears)/(simulationResults.maximumDrawDown*INITIAL_BALANCE*0.01);

     simulationResults.standardDeviationResiduals := standardDeviationResiduals;
     simulationResults.linearFitSlope := m;
     simulationResults.linearFitIntercept := b;
     simulationResults.standardDeviation := standardDeviationTrades;

     if standardDeviationTrades <> 0 then
     simulationResults.modifiedSharpeRatio    := averageTrades/standardDeviationTrades;

     simulationResults.customFilter := getIndicatorCustomCriteria(simulationResults);

     // ideal R calculation
     j := 0;
     SetLength(idealRperiodCorrelations, 0);

     for i:= 0 to Round((Length(simulationResults.balanceCurve)-1)/TRADES_FOR_IR_CALCULATION) do
     begin

      SetLength(dataForFit2, 0);
      j := 0;

          while j < TRADES_FOR_IR_CALCULATION do
          begin
             if (i*TRADES_FOR_IR_CALCULATION+j < Length(simulationResults.balanceCurve)-1) then
             begin
             SetLength(dataForFit2, Length(dataForFit2)+1);
             dataForFit2[ Length(dataForFit2)-1].x := simulationResults.trades[i*TRADES_FOR_IR_CALCULATION+j-1].closeTime ;
             dataForFit2[ Length(dataForFit2)-1].y := simulationResults.balanceCurve[i*TRADES_FOR_IR_CALCULATION+j] ;

             end;
          j := j+1;
          end;

          if Length(dataForFit2) >= TRADES_FOR_IR_CALCULATION-5 then
          begin

               r := 0;

               try
               MainForm.LinearLeastSquaresNormal(dataforFit2, m, b, r);
               except on Exception do
               //
               end;

                    SetLength(idealRperiodCorrelations, Length(idealRperiodCorrelations)+1);
                    idealRperiodCorrelations[Length(idealRperiodCorrelations)-1] := r;

                    if (dataForFit[ Length(dataForFit)-1].y < dataForFit[0].y) and (r > 0) then
                    idealRperiodCorrelations[Length(idealRperiodCorrelations)-1] := -r;

          end;
     end;

     if Length(idealRPeriodCorrelations) > 5 then
     begin
          meanandstddev(idealRPeriodCorrelations, idealR, idealRstandardDeviation);
          simulationResults.idealR := Round(100*idealR)/100;
     end;


 except on Exception do
 // do nothing on exception
 end;


 end;

Function runIndicatorSimulation(       usedEntryPattern   : TIndicatorPattern;
                                       usedClosePattern   : TIndicatorPattern;
                                       symbol             : integer;
                                       useSL              : Boolean;
                                       useTP              : Boolean;
                                       inSampleStartDate  : TDateTime;
                                       inSampleEndingDate : TDateTime;
                                       onlyInSample       : boolean): TIndicatorSimulationResults;
var
simulationResults: TIndicatorSimulationResults;
currentCandle: integer;
activeOrder: TOrder;
totalCandles: int64;
offsetCandles: integer;
entryPatternResult: integer;
exitPatternResult: integer;
currentOpen: double;
currentHigh: double;
currentLow: double;
currentTime: TDateTime;
orderNumber: integer;
ATR: double;
spread, slippage: double;
timeFrame: integer;
commission : double;
i, n: integer;
roundLots: integer;
contractSize: double;
isBuySignal, isSellSignal: boolean;
startTime, endTime: TDateTime;
tradeAgeInBars: integer;
limitDistance: double;
MFE, MUE: double;
isNoTradeOpen: boolean;
begin

// set proper formatting to avoid crashes if this got reset somehow.
//DefaultFormatSettings.ShortDateFormat 	 := 'dd/mm/yyyy' ;
//DefaultFormatSettings.DateSeparator 	         := '/' ;
//DefaultFormatSettings.DecimalSeparator 	 := '.' ;

 startTime := Now;

  // this function does a simulation using the input price pattern
 i := symbol;

  timeFrame    := LoadedIndiHistoryData[symbol].timeFrame;
 totalCandles := Length(LoadedIndiHistoryData[symbol].OHLC);
 offsetCandles :=Max(Round(StrToInt(SimulationForm.OptionsGrid.Cells[1, IDX_OPT_MAX_CANDLE_SHIFT])+20), Round((ATR_PERIOD+20)*1440/timeframe));
 exitPatternResult := NONE;
 entryPatternResult := NONE;
 activeOrder.orderType := NONE;
 simulationResults.entryPricePattern := usedEntryPattern;
 simulationResults.closePricePattern  := usedClosePattern;
 simulationResults.totalTrades := 0;
 simulationResults.shortTrades := 0;
 simulationResults.longTrades  := 0;
 SimulationResults.totalLongSignals := 0;
 SimulationResults.totalShortSignals := 0;
 simulationResults.symbol      := symbol;
 SimulationResults.absoluteProfitLongs := 0;
 SimulationResults.absoluteProfitShorts := 0;
 simulationResults.linearFitR2 := 0;
 simulationResults.systemQualityNumber:=0;
 SimulationResults.daysOut := 0;

 SetLength(simulationResults.MFE_Longs, StrToInt(SimulationForm.OptionsGrid.Cells[1, IDX_OPT_BARS_ME]));
 SetLength(simulationResults.MUE_Longs, StrToInt(SimulationForm.OptionsGrid.Cells[1, IDX_OPT_BARS_ME]));
 SetLength(simulationResults.MFE_Shorts, StrToInt(SimulationForm.OptionsGrid.Cells[1, IDX_OPT_BARS_ME]));
 SetLength(simulationResults.MUE_Shorts, StrToInt(SimulationForm.OptionsGrid.Cells[1, IDX_OPT_BARS_ME]));

 for n := 0 to StrToInt(SimulationForm.OptionsGrid.Cells[1, IDX_OPT_BARS_ME])-1 do
 begin
  simulationResults.MFE_Longs[n] := 0;
  simulationResults.MUE_Longs[n] := 0;
  simulationResults.MFE_Shorts[n] := 0;
  simulationResults.MUE_Shorts[n] := 0;
 end;

 simulationResults.startDate := Max(inSampleStartDate, LoadedIndiHistoryData[symbol].time[offsetCandles]);
 simulationResults.endDate   := Min(LoadedIndiHistoryData[symbol].time[totalCandles-1], Now);

 if onlyInSample then  simulationResults.endDate := inSampleEndingDate;

 SetLength(simulationResults.balanceCurve, 1);
 simulationResults.balanceCurve[0] := INITIAL_BALANCE;
 contractSize := LoadedIndiHistoryData[symbol].contractSize*LoadedIndiHistoryData[symbol].pointConversion;
 //ShowMessage(FloatToStr(contractSize));
 ///ShowMessage(FloatToStr(LoadedIndiHistoryData[symbol].pointConversion));
 spread       := LoadedIndiHistoryData[symbol].spread;
 slippage     := LoadedIndiHistoryData[symbol].slippage;
 commission   := LoadedIndiHistoryData[symbol].commission;
 roundLots    := LoadedIndiHistoryData[symbol].roundLots;


 // simulation loop begins
 for currentCandle := offsetCandles to totalCandles - 2 do
 begin

          currentOpen  := LoadedIndiHistoryData[symbol].OHLC[currentCandle].open;
          currentHigh  := LoadedIndiHistoryData[symbol].OHLC[currentCandle].high;
          currentLow   := LoadedIndiHistoryData[symbol].OHLC[currentCandle].low;
          currentTime  := LoadedIndiHistoryData[symbol].time[currentCandle];

          if (currentTime < inSampleStartDate ) then Continue ;

          if activeOrder.orderType <> NONE then isNoTradeOpen := false else isNoTradeOpen := true;

          ATR := LoadedIndiHistoryData[symbol].ATR[currentCandle];

          //ShowMessage(DateTimeToStr(currentTime));
          //ShowMessage(FloatToStr(ATR));

          isBuySignal := evaluateIndicatorPattern(i, usedEntryPattern, currentCandle-1, BUY, EVAL_TYPE_ENTRY );
          isSellSignal:= evaluateIndicatorPattern(i, usedEntryPattern, currentCandle-1, SELL, EVAL_TYPE_ENTRY ) ;

    // if we are past the end of the back-testing date make sure any open trades are closed.
       if (currentTime > inSampleEndingDate) and (onlyInSample) and (activeOrder.orderType <> NONE) then
       begin

            case activeOrder.orderType of
            BUY : begin  isSellSignal := true; isBuySignal := false; end;
            SELL: begin  isBuySignal  := true; isSellSignal := false; end;
            end;

      end;

      // if we went broke then quit the test
      if (SimulationResults.balanceCurve[Length(SimulationResults.balanceCurve)-1] < 0) then break;

      entryPatternResult := NONE;
      exitPatternResult := NONE;

      // if there are contradictory signals then quit
      if isBuySignal and isSellSignal then
      Break;

      if isBuySignal then
      entryPatternResult := BUY;

      if isSellSignal then
      entryPatternResult := SELL;

    // if there is a contradiction between entry and exit patterns then finish the test
       if  ((entryPatternResult = BUY) and (exitPatternResult = SELL )) or
           ((entryPatternResult = SELL) and (exitPatternResult = BUY )) then
           Break;

       // give entry pattern signal execution presedence over exit pattern
          if (entryPatternResult <> NONE) then exitPatternResult := NONE;


          // look for exits related with entry/exit pattern signals
              if  (
                  ((activeOrder.orderType = SELL) and (entryPatternResult = BUY)) or
                  ((activeOrder.orderType = BUY) and (entryPatternResult = SELL))
                  ) then
                  begin

                    SetLength(SimulationResults.balanceCurve, Length( SimulationResults.balanceCurve) + 1);
                    SetLength(SimulationResults.trades, Length( SimulationResults.trades) + 1);

                    orderNumber := Length( SimulationResults.trades) - 1 ;

                     SimulationResults.trades[orderNumber].closeTime := currentTime;
                     SimulationResults.trades[orderNumber].symbol    := LoadedIndiHistoryData[symbol].symbol;
                     SimulationResults.trades[orderNumber].openTime :=  activeOrder.openTime;
                     SimulationResults.trades[orderNumber].openPrice := activeOrder.openPrice;
                     SimulationResults.trades[orderNumber].SL := activeOrder.SL;
                     SimulationResults.trades[orderNumber].TP := activeOrder.TP;
                     SimulationResults.trades[orderNumber].volume := activeOrder.volume;
                     SimulationResults.trades[orderNumber].orderType := activeOrder.orderType;

                     if (activeOrder.orderType = BUY) then
                       SimulationResults.trades[orderNumber].closePrice := currentOpen ;

                     if (activeOrder.orderType = SELL) then
                       SimulationResults.trades[orderNumber].closePrice := currentOpen + spread;

                     if (SimulationResults.trades[orderNumber].orderType = BUY) then
                       begin
                            SimulationResults.trades[orderNumber].profit := contractSize*SimulationResults.trades[orderNumber].volume*(SimulationResults.trades[orderNumber].closePrice - SimulationResults.trades[orderNumber].openPrice)-commission   ;
                            SimulationResults.absoluteProfitLongs:= SimulationResults.absoluteProfitLongs + SimulationResults.trades[orderNumber].profit;
                       end;

                     if (SimulationResults.trades[orderNumber].orderType = SELL) then
                       begin
                            SimulationResults.trades[orderNumber].profit := -contractSize*SimulationResults.trades[orderNumber].volume*(SimulationResults.trades[orderNumber].closePrice - SimulationResults.trades[orderNumber].openPrice)-commission  ;
                            SimulationResults.absoluteProfitShorts:= SimulationResults.absoluteProfitShorts + SimulationResults.trades[orderNumber].profit;
                       end;

                     SimulationResults.balanceCurve[Length(SimulationResults.balanceCurve)-1] := SimulationResults.balanceCurve[Length(SimulationResults.balanceCurve)-2] + SimulationResults.trades[orderNumber].profit;

                     // reset order type, this closes the trade
                     activeOrder.orderType := NONE;

                  end;

       // quit if we are past the back-testing ending date
       if (currentTime > inSampleEndingDate) and (onlyInSample) then break;

       // measure expectancy for entry signal  //
       if (((entryPatternResult = BUY) and (usedEntryPattern.allowLongSignals))  or ((entryPatternResult = SELL))and (usedEntryPattern.allowShortSignals)) and (currentCandle < totalCandles-1-StrToInt(SimulationForm.OptionsGrid.Cells[1, IDX_OPT_BARS_ME])) then
       begin


          if entryPatternResult = BUY  then  SimulationResults.totalLongSignals  := SimulationResults.totalLongSignals+1;
          if entryPatternResult = SELL then  SimulationResults.totalShortSignals := SimulationResults.totalShortSignals+1;

               MFE := 0;
               MUE := 0;

               // measure expectancy values for this trade and average them into the arrays.
               for n := 0 to StrToInt(SimulationForm.OptionsGrid.Cells[1, IDX_OPT_BARS_ME])-1 do
               begin
                    if entryPatternResult = BUY then
                    begin

                      if  (LoadedIndiHistoryData[i].OHLC[currentCandle+n].high-(currentOpen+spread))/ATR > MFE then
                      MFE := (LoadedIndiHistoryData[i].OHLC[currentCandle+n].high-(currentOpen+spread))/ATR;

                      if  ((currentOpen+spread)-LoadedIndiHistoryData[i].OHLC[currentCandle+n].low)/ATR > MUE then
                      MUE := ((currentOpen+spread)-LoadedIndiHistoryData[i].OHLC[currentCandle+n].low)/ATR;

                      SimulationResults.MFE_Longs[n] := SimulationResults.MFE_Longs[n]*(SimulationResults.totalLongSignals-1)/(SimulationResults.totalLongSignals)+MFE/(SimulationResults.totalLongSignals);
                      SimulationResults.MUE_Longs[n] := SimulationResults.MUE_Longs[n]*(SimulationResults.totalLongSignals-1)/(SimulationResults.totalLongSignals)+MUE/(SimulationResults.totalLongSignals);

                    end;

                    if entryPatternResult = SELL then
                    begin

                      if  (currentOpen-(LoadedIndiHistoryData[i].OHLC[currentCandle+n].low+spread))/ATR > MFE then
                      MFE := (currentOpen-(LoadedIndiHistoryData[i].OHLC[currentCandle+n].low+spread))/ATR;

                      if  ((LoadedIndiHistoryData[i].OHLC[currentCandle+n].high+spread)-currentOpen)/ATR > MUE then
                      MUE := ((LoadedIndiHistoryData[i].OHLC[currentCandle+n].high+spread)-currentOpen)/ATR;

                      SimulationResults.MFE_Shorts[n] := SimulationResults.MFE_Shorts[n]*(SimulationResults.totalShortSignals-1)/(SimulationResults.totalShortSignals)+MFE/(SimulationResults.totalShortSignals);
                      SimulationResults.MUE_Shorts[n] := SimulationResults.MUE_Shorts[n]*(SimulationResults.totalShortSignals-1)/(SimulationResults.totalShortSignals)+MUE/(SimulationResults.totalShortSignals);

                    end;
          end;
       end; // finished measuring expectancy for this signal

       // look at order entry pattern and act if necessary

       if ((entryPatternResult = BUY) and (activeOrder.orderType = BUY)) then
       begin
        if (useSL) then activeOrder.SL  := currentOpen + spread  - ATR*usedEntryPattern.SL;
        if (useTP) then activeOrder.TP  := currentOpen + spread  + ATR*usedEntryPattern.TP;
        tradeAgeInBars  := 0;
        activeOrder.lastSignalOpenPrice := currentOpen;
       end;

       if ((entryPatternResult = SELL) and (activeOrder.orderType = SELL)) then
       begin
        if (useSL) then activeOrder.SL  := currentOpen + ATR*usedEntryPattern.SL;
        if (useTP) then activeOrder.TP  := currentOpen - ATR*usedEntryPattern.TP;
        tradeAgeInBars  := 0;
        activeOrder.lastSignalOpenPrice := currentOpen;
       end;

       if ((((entryPatternResult = BUY) and (usedEntryPattern.allowLongSignals))  or (((entryPatternResult = SELL))and (usedEntryPattern.allowShortSignals))) and (activeOrder.orderType = NONE)) then
       begin

      // ShowMessage('should enter!!');

         tradeAgeInBars  := 0;

         simulationResults.totalTrades := simulationResults.totalTrades + 1;

         activeOrder.openTime := currentTime;
         activeOrder.SL := 0;
         activeOrder.TP := 0;
         activeOrder.closePrice := 0;
         activeOrder.closeTime  := 0;

         activeOrder.volume := round2(INITIAL_BALANCE*0.01/(ATR*usedEntryPattern.SL*contractSize), roundLots) ;

         if activeOrder.volume = 0 then
         activeOrder.volume := 1*power(10, -roundLots);

         if (entryPatternResult = BUY) then
         begin

            simulationResults.longTrades := simulationResults.longTrades + 1 ;

            activeOrder.openPrice := currentOpen + spread ;

            activeOrder.orderType := BUY;

            activeOrder.lastSignalOpenPrice := currentOpen;

            if (useSL) then activeOrder.SL  := activeOrder.openPrice - ATR*usedEntryPattern.SL;
            if (useTP) then activeOrder.TP  := activeOrder.openPrice + ATR*usedEntryPattern.TP;

         end;

         if (entryPatternResult = SELL) then
         begin

            simulationResults.shortTrades := simulationResults.shortTrades + 1 ;

            activeOrder.openPrice := currentOpen;

            activeOrder.orderType := SELL;

            activeOrder.lastSignalOpenPrice := currentOpen;

            if (useSL) then activeOrder.SL  := activeOrder.openPrice + ATR*usedEntryPattern.SL;
            if (useTP) then activeOrder.TP  := activeOrder.openPrice - ATR*usedEntryPattern.TP;

         end;

      end; // finish entry conditional

      //exit trade if SL/TP are hit on current candle high/low values

       if  (
           ((activeOrder.orderType = BUY) and (currentLow < activeOrder.SL)  and (useSL)) or
           ((activeOrder.orderType = SELL) and (currentHigh + spread > activeOrder.SL) and (useSL)) or
           ((activeOrder.orderType = BUY) and (LoadedIndiHistoryData[symbol].OHLC[currentCandle+1].open < activeOrder.SL)  and (useSL)) or
           ((activeOrder.orderType = SELL) and (LoadedIndiHistoryData[symbol].OHLC[currentCandle+1].open + spread > activeOrder.SL) and (useSL))
           ) then
           begin

                SetLength(SimulationResults.balanceCurve, Length( SimulationResults.balanceCurve) + 1);
                SetLength(SimulationResults.trades, Length( SimulationResults.trades) + 1);

                orderNumber := Length( SimulationResults.trades) - 1 ;

                SimulationResults.trades[orderNumber].closeTime := currentTime;
                SimulationResults.trades[orderNumber].symbol    := LoadedIndiHistoryData[symbol].symbol;
                SimulationResults.trades[orderNumber].openTime :=  activeOrder.openTime;
                SimulationResults.trades[orderNumber].openPrice := activeOrder.openPrice;
                SimulationResults.trades[orderNumber].SL := activeOrder.SL;
                SimulationResults.trades[orderNumber].TP := activeOrder.TP;
                SimulationResults.trades[orderNumber].volume := activeOrder.volume;
                SimulationResults.trades[orderNumber].orderType := activeOrder.orderType;

                SimulationResults.trades[orderNumber].closePrice := activeOrder.SL;

                // this takes into account gaps on the SL so that we do not underestimate loses
                if ((activeOrder.orderType = BUY) and (currentOpen < activeOrder.SL)  and (useSL) and (activeOrder.openTime <> currentTime)) then
                SimulationResults.trades[orderNumber].closePrice := currentOpen;

                if ((activeOrder.orderType = SELL) and (currentOpen + spread > activeOrder.SL)  and (useSL) and (activeOrder.openTime <> currentTime)) then
                SimulationResults.trades[orderNumber].closePrice := currentOpen+spread;

                 if (SimulationResults.trades[orderNumber].orderType = BUY) then
                    begin
                            SimulationResults.trades[orderNumber].profit := contractSize*SimulationResults.trades[orderNumber].volume*(SimulationResults.trades[orderNumber].closePrice - SimulationResults.trades[orderNumber].openPrice)-commission   ;
                            SimulationResults.absoluteProfitLongs:= SimulationResults.absoluteProfitLongs + SimulationResults.trades[orderNumber].profit;
                    end;

                 if (SimulationResults.trades[orderNumber].orderType = SELL) then
                    begin
                            SimulationResults.trades[orderNumber].profit := -contractSize*SimulationResults.trades[orderNumber].volume*(SimulationResults.trades[orderNumber].closePrice - SimulationResults.trades[orderNumber].openPrice)-commission  ;
                            SimulationResults.absoluteProfitShorts:= SimulationResults.absoluteProfitShorts + SimulationResults.trades[orderNumber].profit;
                    end;

                SimulationResults.balanceCurve[Length(SimulationResults.balanceCurve)-1] := SimulationResults.balanceCurve[Length(SimulationResults.balanceCurve)-2] + SimulationResults.trades[orderNumber].profit;

                // reset order type, this closes the trade
                activeOrder.orderType := NONE;

           end;


       if  (
           ((activeOrder.orderType = SELL) and (currentLow + spread < activeOrder.TP)  and (useTP)) or
           ((activeOrder.orderType = BUY) and (currentHigh > activeOrder.TP) and (useTP))  or
           ((activeOrder.orderType = SELL) and (LoadedIndiHistoryData[symbol].OHLC[currentCandle+1].open  + spread < activeOrder.TP)  and (useTP)) or
           ((activeOrder.orderType = BUY) and (LoadedIndiHistoryData[symbol].OHLC[currentCandle+1].open  > activeOrder.TP) and (useTP))
           ) then
           begin

                SetLength(SimulationResults.balanceCurve, Length( SimulationResults.balanceCurve) + 1);
                SetLength(SimulationResults.trades, Length( SimulationResults.trades) + 1);

                orderNumber := Length( SimulationResults.trades) - 1 ;

                SimulationResults.trades[orderNumber].closeTime := currentTime;
                SimulationResults.trades[orderNumber].symbol    := LoadedIndiHistoryData[symbol].symbol;
                SimulationResults.trades[orderNumber].openTime :=  activeOrder.openTime;
                SimulationResults.trades[orderNumber].openPrice := activeOrder.openPrice;
                SimulationResults.trades[orderNumber].SL := activeOrder.SL;
                SimulationResults.trades[orderNumber].TP := activeOrder.TP;
                SimulationResults.trades[orderNumber].volume := activeOrder.volume;
                SimulationResults.trades[orderNumber].orderType := activeOrder.orderType;

                SimulationResults.trades[orderNumber].closePrice := activeOrder.TP;

                 if (SimulationResults.trades[orderNumber].orderType = BUY) then
                       begin
                            SimulationResults.trades[orderNumber].profit := contractSize*SimulationResults.trades[orderNumber].volume*(SimulationResults.trades[orderNumber].closePrice - SimulationResults.trades[orderNumber].openPrice)-commission   ;
                            SimulationResults.absoluteProfitLongs:= SimulationResults.absoluteProfitLongs + SimulationResults.trades[orderNumber].profit;
                       end;

                 if (SimulationResults.trades[orderNumber].orderType = SELL) then
                       begin
                            SimulationResults.trades[orderNumber].profit := -contractSize*SimulationResults.trades[orderNumber].volume*(SimulationResults.trades[orderNumber].closePrice - SimulationResults.trades[orderNumber].openPrice)-commission  ;
                            SimulationResults.absoluteProfitShorts:= SimulationResults.absoluteProfitShorts + SimulationResults.trades[orderNumber].profit;
                       end;

                SimulationResults.balanceCurve[Length(SimulationResults.balanceCurve)-1] := SimulationResults.balanceCurve[Length(SimulationResults.balanceCurve)-2] + SimulationResults.trades[orderNumber].profit;

                // reset order type, this closes the trade
                activeOrder.orderType := NONE;

           end;

       if activeOrder.orderType <> NONE then tradeAgeInBars  := tradeAgeInBars + 1 ;

       if (activeOrder.orderType = NONE) and (isNoTradeOpen) then
       simulationResults.daysOut := simulationResults.daysOut+1;

   end;

getIndicatorStatistics(SimulationResults);

Result := SimulationResults;

endTime := Now;

MainForm.simulationRuns := MainForm.simulationRuns + 1;
MainForm.simulationTime := Round(MainForm.simulationTime*(MainForm.simulationRuns-1)/MainForm.simulationRuns + MilliSecondsBetween(startTime, endTime)/MainForm.simulationRuns);

end;

Procedure addIndicatorResultToGrid(simulationResults: TIndicatorSimulationResults; SimNumber : integer; outOfSampleEndDate: TDateTime) ;
var
outOfSampleResults : TIndicatorSimulationResults;
begin
      MainForm.ResultsGrid.RowCount := MainForm.ResultsGrid.RowCount + 1;
      MainForm.ResultsGrid.Cells[IDX_GRID_USE_IN_PORTFOLIO, MainForm.ResultsGrid.RowCount-1] := '0' ;
      MainForm.ResultsGrid.Cells[IDX_GRID_SYMBOL, MainForm.ResultsGrid.RowCount-1] := LoadedIndiHistoryData[simulationResults.symbol].symbol ;
      MainForm.ResultsGrid.Cells[IDX_GRID_RESULT_NUMBER, MainForm.ResultsGrid.RowCount-1] := IntToStr(SimNumber) ;
      MainForm.ResultsGrid.Cells[IDX_GRID_PROFIT, MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round(simulationResults.absoluteProfit)) ;
      MainForm.ResultsGrid.Cells[IDX_GRID_LONG_COUNT, MainForm.ResultsGrid.RowCount-1] := IntToStr(simulationResults.longTrades);
      MainForm.ResultsGrid.Cells[IDX_GRID_SHORT_COUNT, MainForm.ResultsGrid.RowCount-1] := IntToStr(simulationResults.shortTrades);
      MainForm.ResultsGrid.Cells[IDX_GRID_TOTAL_COUNT, MainForm.ResultsGrid.RowCount-1] := IntToStr(simulationResults.longTrades + simulationResults.shortTrades);
      MainForm.ResultsGrid.Cells[IDX_GRID_MAX_DRAWDOWN, MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round(simulationResults.maximumDrawDown*100)/100);
      MainForm.ResultsGrid.Cells[IDX_GRID_ULCER_INDEX, MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round(simulationResults.ulcerIndex*100)/100);
      MainForm.ResultsGrid.Cells[IDX_GRID_MAX_DRAWDOWN_LENGTH, MainForm.ResultsGrid.RowCount-1] := IntToStr(simulationResults.maximumDrawDownLength);
      MainForm.ResultsGrid.Cells[IDX_GRID_CONS_LOSS, MainForm.ResultsGrid.RowCount-1] := IntToStr(simulationResults.consecutiveLoses);
      MainForm.ResultsGrid.Cells[IDX_GRID_CONS_WIN, MainForm.ResultsGrid.RowCount-1] := IntToStr(simulationResults.consecutiveWins);
      MainForm.ResultsGrid.Cells[IDX_GRID_PROFIT_TO_DD_RATIO, MainForm.ResultsGrid.RowCount-1] := FloatToStr((Round(simulationResults.profitToDD*100)/100));
      MainForm.ResultsGrid.Cells[IDX_GRID_WINNING_PERCENT, MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round(simulationResults.winningPercent*100)/100);
      MainForm.ResultsGrid.Cells[IDX_GRID_REWARD_TO_RISK, MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round(simulationResults.rewardToRisk*100)/100);
      MainForm.ResultsGrid.Cells[IDX_GRID_SKEWNESS, MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round(simulationResults.skewness*100)/100);
      MainForm.ResultsGrid.Cells[IDX_GRID_KURTOSIS, MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round(simulationResults.kurtosis*100)/100);
      MainForm.ResultsGrid.Cells[IDX_GRID_PROFIT_FACTOR, MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round(simulationResults.profitFactor*100)/100);
      MainForm.ResultsGrid.Cells[IDX_GRID_LINEAR_FIT_R2, MainForm.ResultsGrid.RowCount-1] := FloatToStr(simulationResults.linearFitR2);
      MainForm.ResultsGrid.Cells[IDX_GRID_IDEAL_R, MainForm.ResultsGrid.RowCount-1] := FloatToStr(simulationResults.idealR);
      MainForm.ResultsGrid.Cells[IDX_GRID_SQN, MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round(simulationResults.systemQualityNumber*100)/100);

      if simulationResults.totalTrades > 0 then
      MainForm.ResultsGrid.Cells[IDX_GRID_PROFIT_PER_TRADE, MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round((simulationResults.absoluteProfit/simulationResults.totalTrades)*100)/100) else
      MainForm.ResultsGrid.Cells[IDX_GRID_PROFIT_PER_TRADE, MainForm.ResultsGrid.RowCount-1] := '0';

      MainForm.ResultsGrid.Cells[IDX_GRID_STD_DEV, MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round((simulationResults.standardDeviation)*100)/100);
      MainForm.ResultsGrid.Cells[IDX_GRID_MODIFIED_SHARPE_RATIO, MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round((simulationResults.modifiedSharpeRatio)*100)/100);
      MainForm.ResultsGrid.Cells[IDX_GRID_STD_DEV_BREACH , MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round((simulationResults.standardDeviationBreach)*100)/100);
      MainForm.ResultsGrid.Cells[IDX_GRID_PROFIT_LONGS, MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round(simulationResults.absoluteProfitLongs)) ;
      MainForm.ResultsGrid.Cells[IDX_GRID_PROFIT_SHORTS , MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round(simulationResults.absoluteProfitShorts)) ;
      MainForm.ResultsGrid.Cells[IDX_GRID_TOTAL_ME , MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round(simulationResults.total_ME*10000)/10000) ;
      MainForm.ResultsGrid.Cells[IDX_GRID_DAYS_OUT, MainForm.ResultsGrid.RowCount-1] := IntToStr(simulationResults.daysOut) ;
      MainForm.ResultsGrid.Cells[IDX_GRID_CUSTOM_CRITERIA, MainForm.ResultsGrid.RowCount-1] := FloatToStr(simulationResults.customFilter);
      MainForm.ResultsGrid.Cells[IDX_GRID_LOWEST_LAG, MainForm.ResultsGrid.RowCount-1] := FloatToStr(simulationResults.lowestLag);

      outOfSampleResults := runIndicatorSimulation(         simulationResults.entryPricePattern,
                                                                  simulationResults.closePricePattern,
                                                                  simulationResults.symbol,
                                                                  SimulationForm.useSLCheck.Checked,
                                                                  SimulationForm.useTPCheck.Checked,
                                                                  simulationResults.endDate,
                                                                  outOfSampleEndDate,
                                                                  true);


      //ShowMessage( DateTimeToStr(simulationResults.endDate) + ' - ' + DateTimeToStr(outOfSampleEndDate));

      MainForm.ResultsGrid.Cells[IDX_GRID_OUT_OF_SAMPLE_PROFIT, MainForm.ResultsGrid.RowCount-1] := '0';
      MainForm.ResultsGrid.Cells[IDX_GRID_OSP_PER_TRADE, MainForm.ResultsGrid.RowCount-1] := '0';

      if outOfSampleResults.totalTrades > 0 then
      begin
           MainForm.ResultsGrid.Cells[IDX_GRID_OUT_OF_SAMPLE_PROFIT, MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round((outOfSampleResults.absoluteProfit)*100)/100) ;
           MainForm.ResultsGrid.Cells[IDX_GRID_OSP_PER_TRADE, MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round(100*outOfSampleResults.absoluteProfit/outOfSampleResults.totalTrades)/100) ;
           MainForm.ResultsGrid.Cells[IDX_GRID_OS_LONG_COUNT, MainForm.ResultsGrid.RowCount-1] := IntToStr(outOfSampleResults.longTrades);
           MainForm.ResultsGrid.Cells[IDX_GRID_OS_SHORT_COUNT, MainForm.ResultsGrid.RowCount-1] := IntToStr(outOfSampleResults.shortTrades);
           MainForm.ResultsGrid.Cells[IDX_GRID_OS_TOTAL_COUNT, MainForm.ResultsGrid.RowCount-1] := IntToStr(outOfSampleResults.longTrades + outOfSampleResults.shortTrades);
           MainForm.ResultsGrid.Cells[IDX_GRID_OS_MAX_DRAWDOWN, MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round(outOfSampleResults.maximumDrawDown*100)/100);
           MainForm.ResultsGrid.Cells[IDX_GRID_OS_ULCER_INDEX, MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round(outOfSampleResults.ulcerIndex*100)/100);
           MainForm.ResultsGrid.Cells[IDX_GRID_OS_MAX_DRAWDOWN_LENGTH, MainForm.ResultsGrid.RowCount-1] := IntToStr(outOfSampleResults.maximumDrawDownLength);
           MainForm.ResultsGrid.Cells[IDX_GRID_OS_CONS_LOSS, MainForm.ResultsGrid.RowCount-1] := IntToStr(outOfSampleResults.consecutiveLoses);
           MainForm.ResultsGrid.Cells[IDX_GRID_OS_CONS_WIN, MainForm.ResultsGrid.RowCount-1] := IntToStr(outOfSampleResults.consecutiveWins);
           MainForm.ResultsGrid.Cells[IDX_GRID_OS_PROFIT_TO_DD_RATIO, MainForm.ResultsGrid.RowCount-1] := FloatToStr((Round(outOfSampleResults.profitToDD*100)/100));
           MainForm.ResultsGrid.Cells[IDX_GRID_OS_WINNING_PERCENT, MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round(outOfSampleResults.winningPercent*100)/100);
           MainForm.ResultsGrid.Cells[IDX_GRID_OS_REWARD_TO_RISK, MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round(outOfSampleResults.rewardToRisk*100)/100);
           MainForm.ResultsGrid.Cells[IDX_GRID_OS_SKEWNESS, MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round(outOfSampleResults.skewness*100)/100);
           MainForm.ResultsGrid.Cells[IDX_GRID_OS_KURTOSIS, MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round(outOfSampleResults.kurtosis*100)/100);
           MainForm.ResultsGrid.Cells[IDX_GRID_OS_PROFIT_FACTOR, MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round(outOfSampleResults.profitFactor*100)/100);
           MainForm.ResultsGrid.Cells[IDX_GRID_OS_LINEAR_FIT_R2, MainForm.ResultsGrid.RowCount-1] := FloatToStr(outOfSampleResults.linearFitR2);
           MainForm.ResultsGrid.Cells[IDX_GRID_OS_SQN, MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round(outOfSampleResults.systemQualityNumber*100)/100);
           MainForm.ResultsGrid.Cells[IDX_GRID_OS_STD_DEV, MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round((outOfSampleResults.standardDeviation)*100)/100);
           MainForm.ResultsGrid.Cells[IDX_GRID_OS_MODIFIED_SHARPE_RATIO, MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round((outOfSampleResults.modifiedSharpeRatio)*100)/100);
           MainForm.ResultsGrid.Cells[IDX_GRID_OS_STD_DEV_BREACH , MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round((outOfSampleResults.standardDeviationBreach)*100)/100);
           MainForm.ResultsGrid.Cells[IDX_GRID_OS_PROFIT_LONGS, MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round(outOfSampleResults.absoluteProfitLongs)) ;
           MainForm.ResultsGrid.Cells[IDX_GRID_OS_PROFIT_SHORTS , MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round(outOfSampleResults.absoluteProfitShorts)) ;
           MainForm.ResultsGrid.Cells[IDX_GRID_OS_TOTAL_ME , MainForm.ResultsGrid.RowCount-1] := FloatToStr(Round(outOfSampleResults.total_ME*10000)/10000) ;
           MainForm.ResultsGrid.Cells[IDX_GRID_OS_DAYS_OUT, MainForm.ResultsGrid.RowCount-1] := IntToStr(outOfSampleResults.daysOut) ;
           MainForm.ResultsGrid.Cells[IDX_GRID_OS_CUSTOM_CRITERIA, MainForm.ResultsGrid.RowCount-1] := FloatToStr(outOfSampleResults.customFilter);
      end;

end;

function calculateATRIndicator(symbol, timeframe, period,currentShift: integer): double;
var
i: integer;
sumTrueRange, high, low: Double;
currentHigh, currentLow, previousClose, trueRange: double;
begin

 sumTrueRange := 0;

 if timeframe = 1440 then
 begin

     for i:= 0 to period-1 do
     begin

        currentHigh   :=  LoadedIndiHistoryData[symbol].OHLC[currentShift-i-1].high;
        currentLow    :=  LoadedIndiHistoryData[symbol].OHLC[currentShift-i-1].low;
        previousClose :=  LoadedIndiHistoryData[symbol].OHLC[currentShift-i-2].close;

        trueRange := Max( (currentHigh-currentLow), Max(Abs(currentLow-previousClose), Abs(currentHigh-previousClose)));

        sumTrueRange := sumTrueRange + trueRange;

     end;

     Result := sumTrueRange/period ;
     Exit
 end;

 if timeframe <> 1440 then

 begin

     Result := 0;

     for i := 0 to period - 1 do
     begin
		high   :=  LoadedIndiHistoryData[symbol].OHLC[currentShift-Round(i*((1440/2)/timeframe)+(1440/timeframe))].high;
		low  :=  LoadedIndiHistoryData[symbol].OHLC[currentShift-Round(i*((1440/2)/timeframe)+1)].low;
                Result := Result + Abs(high-low)/period
     end;

end;

end;

Function LoadIndicatorsAndHistory(PairDataFile: string): boolean;
Var
Ts   : tstringlist;
temp : tstringlist;
i, j, n: integer;
typeString1: string;
Begin

  Result := true;
  DefaultFormatSettings.ShortDateFormat 	 := 'yyyy.mm.dd' ;
  DefaultFormatSettings.DateSeparator 	         := '.' ;
  DefaultFormatSettings.DecimalSeparator 	 := '.' ;

  // open progress bar form
  MainForm.StatusLabel.Caption := 'Symbol data loading progress...';
  MainForm.StatusLabel.visible := true;
  MainForm.ProgressBar1.Position := 0;

  Ts := Tstringlist.create;

  Ts.LoadFromFile(PairDataFile);

  SetLength(LoadedIndiHistoryData, Length(LoadedIndiHistoryData)+1);
  SetLength(LoadedIndicatorData, Length(LoadedIndicatorData)+1);

  n := Length(LoadedIndiHistoryData)-1;

  LoadedIndiHistoryData[n].OHLC := nil ;
  LoadedIndiHistoryData[n].Time := nil ;

  SetLength( LoadedIndiHistoryData[n].OHLC, Ts.Count) ;
  SetLength( LoadedIndiHistoryData[n].Time, Ts.Count) ;

  Temp := Tstringlist.create;

  MainForm.ProgressBar1.Max := Ts.Count;

  LoadedIndiHistoryData[n].symbol := loadSymbol.SymbolsGrid.DataSource.DataSet.Fields[0].AsString ;
  LoadedIndiHistoryData[n].spread := loadSymbol.SymbolsGrid.DataSource.DataSet.Fields[4].AsFloat ;
  LoadedIndiHistoryData[n].slippage := loadSymbol.SymbolsGrid.DataSource.DataSet.Fields[3].AsFloat ;
  LoadedIndiHistoryData[n].commission := loadSymbol.SymbolsGrid.DataSource.DataSet.Fields[6].AsFloat ;
  LoadedIndiHistoryData[n].contractSize := loadSymbol.SymbolsGrid.DataSource.DataSet.Fields[5].AsFloat ;
  LoadedIndiHistoryData[n].isVolume := loadSymbol.SymbolsGrid.DataSource.DataSet.Fields[7].AsBoolean ;
  LoadedIndiHistoryData[n].pointConversion := loadSymbol.SymbolsGrid.DataSource.DataSet.Fields[8].AsInteger ;
  LoadedIndiHistoryData[n].timeFrame := loadSymbol.SymbolsGrid.DataSource.DataSet.Fields[2].AsInteger ;
  LoadedIndiHistoryData[n].roundLots := loadSymbol.SymbolsGrid.DataSource.DataSet.Fields[9].AsInteger ;
  LoadedIndiHistoryData[n].MinimumStop:=loadSymbol.SymbolsGrid.DataSource.DataSet.Fields[10].AsFloat ;

  temp.Clear ;
  MainForm.ParseDelimited(temp, Ts[0], ',') ;

  SetLength( LoadedIndicatorData[n], 4);

  SimulationForm.UsedInputsList.Clear;
  SimulationForm2.UsedInputsList.Clear;

  SingleSystem.ComboBox1.Clear;
  SingleSystem.ComboBox2.Clear;

  for j:= 0 to 3 do
  begin

       Case j of
       0 : typeString1 := 'Open';
       1 : typeString1 := 'High';
       2 : typeString1 := 'Low';
       3 : typeString1 := 'Close';
       end;

         SetLength( LoadedIndicatorData[n][j].data, Ts.Count);
         SimulationForm.UsedInputsList.Items.Add(typeString1);
         SimulationForm2.UsedInputsList.Items.Add(typeString1);
         SingleSystem.ComboBox1.Items.Add(typeString1);
         SingleSystem.ComboBox2.Items.Add(typeString1);
         SimulationForm.UsedInputsList.Checked[SimulationForm.UsedInputsList.Count-1] := true;
         SimulationForm2.UsedInputsList.Checked[SimulationForm2.UsedInputsList.Count-1] := true;
  end;

  for i := 0 to Ts.Count - 1 do

  begin

  temp.Clear ;

  if  i Mod 100 = 0 then
  begin
  MainForm.ProgressBar1.Position := i + 100 ;
  Application.ProcessMessages;
  end;

   MainForm.ParseDelimited(temp, Ts[i], ',') ;

   LoadedIndiHistoryData[n].Time[i] := StrToDateTime(temp[0]+' '+temp[1]) ;

   LoadedIndiHistoryData[n].OHLC[i].Open := StrToFloat(temp[2]) ;
   LoadedIndiHistoryData[n].OHLC[i].High := StrToFloat(temp[3]) ;
   LoadedIndiHistoryData[n].OHLC[i].Low := StrToFloat(temp[4]) ;
   LoadedIndiHistoryData[n].OHLC[i].Close := StrToFloat(temp[5]) ;

   if LoadedIndiHistoryData[n].isVolume then
   LoadedIndiHistoryData[n].OHLC[i].Volume := StrToFloat(temp[6]) else
   LoadedIndiHistoryData[n].OHLC[i].Volume := 0    ;

   for j:= 2 to 5 do
   begin
         LoadedIndicatorData[n][j-2].data[i] := StrToFloat(temp[j]);
   end;

  end;

  // check data for corrupt dates
  for i := 1 to Length(LoadedIndiHistoryData[n].Time)-1 do
  begin

       if LoadedIndiHistoryData[n].Time[i] < LoadedIndiHistoryData[n].Time[i-1] then
       begin
            ShowMessage('Data format is valid but data has corrupt dates. Corrupt date found : ' + DateTimeToStr(LoadedIndiHistoryData[n].Time[i]) + ' is after ' + DateTimeToStr(LoadedIndiHistoryData[n].Time[i-1]));
            LoadedIndiHistoryData[n].OHLC := nil;
            LoadedIndiHistoryData[n].Time := nil;
            Result := false;
            Break;
       end;

  end;

  ShowMessage('Loaded data for symbol ' + LoadedIndiHistoryData[n].symbol + IntToStr(LoadedIndiHistoryData[n].Timeframe) + ' from ' +  DateTimeToStr(LoadedIndiHistoryData[n].Time[0]) +  ' to ' + DateTimeToStr(LoadedIndiHistoryData[n].Time[Length(LoadedIndiHistoryData[n].Time)-1]) + '. Contract size = ' + FloatToStr(LoadedIndiHistoryData[n].ContractSize) + ' Spread = ' + FloatToStr(LoadedIndiHistoryData[n].spread) + ' Slippage = ' + FloatToStr(LoadedIndiHistoryData[n].slippage));

  SetLength(LoadedIndiHistoryData[n].ATR, Length(LoadedIndiHistoryData[n].OHLC));

  for i:= 1 to Length(LoadedIndiHistoryData[n].OHLC)-1 do
  begin

    if i < (1440/LoadedIndiHistoryData[n].timeFrame)*(ATR_PERIOD+5) then
    LoadedIndiHistoryData[n].ATR[i] := 0 else
    LoadedIndiHistoryData[n].ATR[i] := calculateATRIndicator(n, LoadedIndiHistoryData[n].timeFrame, ATR_PERIOD, i) ;

  end;

  ts.free;

  temp.free ;

  MainForm.StatusLabel.visible := false;

end;

procedure runIndiSimulationFixedQuota( isRandomSimulation: boolean);
var
simulationResults  : TIndicatorSimulationResults;
entryPattern, closePattern: TIndicatorPattern;
maxCandlesPerPattern, maxRulesPerCandle: integer;
slippagePercent: double;
maxCandleShift: integer;
RunningSimulations : array of TMyIndiThread;
startDate, endDate, endOutOfSampleDate: TDateTime;
i, j, resultQuota: integer;
generationPeriod, walkForwardPeriod: integer;
testedPatterns: TIndicatorPatternGroup;
begin

 maxRulesPerCandle    := StrToInt(SimulationForm.OptionsGrid.Cells[1, IDX_OPT_MAX_RULES_PER_CANDLE]);
 maxCandleShift       := StrToInt(SimulationForm.OptionsGrid.Cells[1, IDX_OPT_MAX_CANDLE_SHIFT]);
 resultQuota          := StrToInt(SimulationForm.OptionsGrid.Cells[1, IDX_OPT_REQUESTED_SYSTEMS]);
 startDate            := SimulationForm.BeginInSampleCalendar.Date;
 endDate              := SimulationForm.EndInSampleCalendar.Date ;
 endOutOfSampleDate   := SimulationForm.EndOutOfSampleCalendar.Date;

 MainForm.ResultsGrid.RowCount := 1;
 MainForm.ResultsGrid.FixedCols := 0;
 simulationsRan := 0;

 indicatorEntryPatterns := nil;
 indicatorClosePatterns := nil;

 MainForm.StatusLabel.Visible := true;
 MainForm.isCancel := false;
 MainForm.ProgressBar1.Position := 0;
 MainForm.ProgressBar1.Max := StrToInt(SimulationForm.OptionsGrid.Cells[1, IDX_OPT_REQUESTED_SYSTEMS]);
 //MainForm.Visible := false;

 validResults := 0;

 if StrToInt(SimulationForm.OptionsGrid.Cells[1, IDX_OPT_NO_OF_CORES]) > 1 then
 begin

 SetLength(RunningSimulations, StrToInt(SimulationForm.OptionsGrid.Cells[1, IDX_OPT_NO_OF_CORES])-1);


      for i:= 0 to Length(RunningSimulations)-1 do
      begin
            RunningSimulations[i] := TMyIndiThread.Create(false);
            RunningSimulations[i].isMultipleSymbols := false;
            RunningSimulations[i].isRandomPeriodSelection := isRandomSimulation;
      end;
 end;


 i := 0;
 j := 0;

 while (validResults < resultQuota) do
      begin

           if (MainForm.isCancel) then
           begin
                if Length(RunningSimulations) <> 0 then
                for i:= 0 to Length(RunningSimulations)-1 do
                RunningSimulations[i].Terminate;
                Exit;
           end;

            entryPattern := generateRandomIndicatorPattern(maxRulesPerCandle, maxCandleShift);
            closePattern := generateRandomIndicatorPattern(maxRulesPerCandle, maxCandleShift);

            simulationResults := runIndicatorSimulation(     entryPattern,
                     closePattern,
                     FIRST_SYMBOL,
                     SimulationForm.useSLCheck.Checked,
                     SimulationForm.useTPCheck.Checked,
                     startDate,
                     endDate,
                     true);

            simulationsRan := simulationsRan + 1;

                     Application.ProcessMessages;
                     MainForm.StatusLabel.Caption := 'Simulation progress: ' + FloatToStr(simulationsRan) + '  runs, valid ' + IntToStr(MainForm.ResultsGrid.RowCount-1) + '/' + SimulationForm.OptionsGrid.Cells[1, IDX_OPT_REQUESTED_SYSTEMS] + ' Avg time/sim : ' + FloatToStr(MainForm.simulationTime/1000);
                     MainForm.ProgressBar1.Position := MainForm.ResultsGrid.RowCount-1 ;


                     if ( isIndicatorPositiveResult(simulationResults))then
                     begin

                           SetLength(indicatorEntryPatterns, Length(indicatorEntryPatterns)+1);
                           SetLength(indicatorClosePatterns, Length(indicatorClosePatterns)+1);

                           indicatorEntryPatterns[ Length(indicatorEntryPatterns)-1] := entryPattern;
                           indicatorClosePatterns[ Length(indicatorClosePatterns)-1] := closePattern;

                           addIndicatorResultToGrid(simulationResults, Length(indicatorEntryPatterns), endOutOfSampleDate );
                           i := i+1;

                           simulationsRan := simulationsRan + j;
                           j := 0;

                           validResults := validResults  + 1;

                     end;

                     j := j + 1;
           end;

 Application.ProcessMessages;

 if StrToInt(SimulationForm.OptionsGrid.Cells[1, IDX_OPT_NO_OF_CORES]) > 1 then
 for i:= 0 to Length(RunningSimulations)-1 do
 begin
 RunningSimulations[i].Terminate;
 end;

 sortResultsGrid;
 MainForm.StatusLabel.Visible := false;

 Application.ProcessMessages;

end;

procedure runIndicatorSimulationFixedQuotaMultipleSymbols;
var
simulationResults  : array of TIndicatorSimulationResults;
entryPattern, closePattern: TIndicatorPattern;
maxRulesPerCandle: integer;
slippagePercent: double;
i, k, resultQuota: integer;
maxCandleShift: integer;
isPositiveCount: integer;
RunningSimulations : array of TMyIndiThread;
testedPatterns: TIndicatorPatternGroup;
begin

 maxRulesPerCandle    := StrToInt(SimulationForm.OptionsGrid.Cells[1, IDX_OPT_MAX_RULES_PER_CANDLE]);
 resultQuota          := StrToInt(SimulationForm.OptionsGrid.Cells[1, IDX_OPT_REQUESTED_SYSTEMS]);
 maxCandleShift       := StrToInt(SimulationForm.OptionsGrid.Cells[1, IDX_OPT_MAX_CANDLE_SHIFT]);

 indicatorEntryPatterns := nil;
 indicatorClosePatterns := nil;

 MainForm.ResultsGrid.RowCount := 1;
 MainForm.ResultsGrid.FixedCols := 0;

 MainForm.StatusLabel.Visible := true;
 MainForm.isCancel := false;
 MainForm.ProgressBar1.Position := 0;
 MainForm.ProgressBar1.Max := resultQuota;
 //MainForm.Visible := false;
 simulationsRan := 0;
 validResults := 0;

 SetLength(simulationResults, Length(LoadedIndiHistoryData));

 if StrToInt(SimulationForm.OptionsGrid.Cells[1, IDX_OPT_NO_OF_CORES]) > 1 then
 begin

 SetLength(RunningSimulations, StrToInt(SimulationForm.OptionsGrid.Cells[1, IDX_OPT_NO_OF_CORES])-1);

      for i:= 0 to Length(RunningSimulations)-1 do
      begin
            RunningSimulations[i] := TMyIndiThread.Create(false);
            RunningSimulations[i].isMultipleSymbols := true;
            RunningSimulations[i].isRandomPeriodSelection := false;
      end;
 end;

 //ShowMessage('start');

 i := 0;

 while validResults < resultQuota  do
 begin

 if (MainForm.isCancel) then
           begin
                if StrToInt(SimulationForm.OptionsGrid.Cells[1, IDX_OPT_NO_OF_CORES]) > 1 then
                for i:= 0 to Length(RunningSimulations)-1 do
                begin
                RunningSimulations[i].Terminate;
                end;
                Exit;
           end;

 entryPattern := generateRandomIndicatorPattern(maxRulesPerCandle, maxCandleShift);
 closePattern := generateRandomIndicatorPattern(maxRulesPerCandle, maxCandleShift);

 isPositiveCount := 0;

 for k := 0 to Length(LoadedIndiHistoryData)-1 do
 begin
 simulationResults[k].trades := nil;

 simulationResults[k] := runIndicatorSimulation(     entryPattern,
                     closePattern,
                     k,
                     SimulationForm.useSLCheck.Checked,
                     SimulationForm.useTPCheck.Checked,
                     SimulationForm.BeginInSampleCalendar.Date,
                     SimulationForm.EndInSampleCalendar.Date,
                     true);

  if ( isIndicatorPositiveResult(simulationResults[k]))then isPositiveCount := isPositiveCount + 1;

  MainForm.StatusLabel.Caption := 'Simulation progress: ' + FloatToStr(simulationsRan) + '  runs, valid ' + IntToStr(validResults) + '/' + SimulationForm.OptionsGrid.Cells[1, IDX_OPT_REQUESTED_SYSTEMS] + ' Avg time/sim : ' + FloatToStr(MainForm.simulationTime/1000) + ', searched: ' + FloatToStr(Round((100*(simulationsRan)/MainForm.totalSystems)*100000)/100000 ) + '%';
  MainForm.ProgressBar1.Position := validResults ;
  Application.ProcessMessages;

  end;

  if ( isPositiveCount = Length(LoadedIndiHistoryData))then
  begin

     SetLength(indicatorEntryPatterns, Length(indicatorEntryPatterns)+1);
     SetLength(indicatorClosePatterns, Length(indicatorClosePatterns)+1);

     indicatorEntryPatterns[ Length(indicatorEntryPatterns)-1] := entryPattern;
     indicatorClosePatterns[ Length(indicatorClosePatterns)-1] := closePattern;

     for k := 0 to Length(LoadedIndiHistoryData)-1 do
     addIndicatorResultToGrid(simulationResults[k], Length(indicatorEntryPatterns), SimulationForm.EndOutOfSampleCalendar.Date );
     validResults := validResults + 1;

     i := i+1;

  end;

  simulationsRan := simulationsRan + 1;

 end;

  if StrToInt(SimulationForm.OptionsGrid.Cells[1, IDX_OPT_NO_OF_CORES]) > 1 then
  for i:= 0 to Length(RunningSimulations)-1 do
  begin
  RunningSimulations[i].Terminate;
  end;

  sortResultsGrid;
  MainForm.StatusLabel.Visible := false;

  Application.ProcessMessages;

end;

procedure ShowIndicatorPatternDecomposition;
var
  selectedPattern: integer;
begin
      selectedPattern :=  StrToInt(MainForm.selectedPatternLabel.Caption);

      PricePatternForm.Memo1.Lines.Clear;

      PricePatternForm.decomposeIndicatorPattern( indicatorEntryPatterns[selectedPattern], ENTRY_PATTERN);

      PricePatternForm.Visible := true;

end;

procedure ShowIndicatorPatternPortfolioResult;
var
  i: integer;
  simulationResultsPortfolio: TIndicatorSimulationResults;
  simulationResults  : array of TIndicatorSimulationResults;
begin

  SetLength(simulationResults, 0);

  for i:= 1 to MainForm.ResultsGrid.RowCount-1 do
  begin
       if MainForm.ResultsGrid.Cells[IDX_GRID_USE_IN_PORTFOLIO, i] = '1' then
       begin
         SetLength(simulationResults, Length( simulationResults ) +1);

         simulationResults[Length( simulationResults )-1] := runIndicatorSimulation(       indicatorEntryPatterns[StrToInt(MainForm.ResultsGrid.Cells[IDX_GRID_RESULT_NUMBER, i])-1],
                                                                                  indicatorClosePatterns[StrToInt(MainForm.ResultsGrid.Cells[IDX_GRID_RESULT_NUMBER, i])-1],
                                                                                  MainForm.findSymbol(MainForm.ResultsGrid.Cells[IDX_GRID_SYMBOL, i]),
                                                                                  SimulationForm.useSLCheck.Checked,
                                                                                  SimulationForm.useTPCheck.Checked,
                                                                                  SimulationForm.BeginInSampleCalendar.Date,
                                                                                  SimulationForm.EndInSampleCalendar.Date,
                                                                                  false);
       end;
  end;

  if Length(simulationResults)=0 then
  begin
    ShowMessage('No systems selected for merging.');
    Exit;
  end;

  simulationResultsPortfolio.longTrades        := 0;
  simulationResultsPortfolio.shortTrades       := 0;
  simulationResultsPortfolio.totalTrades       := 0;
  SetLength(simulationResultsPortfolio.balanceCurve, 1);
  simulationResultsPortfolio.balanceCurve[0]   := INITIAL_BALANCE;

  simulationResultsPortfolio.symbol    := FIRST_SYMBOL;
  simulationResultsPortfolio.startDate := SimulationForm.BeginInSampleCalendar.Date;


  mergeIndicatorSimulationResults(simulationResults, simulationResultsPortfolio, SimulationForm.BeginInSampleCalendar.Date, SimulationForm.EndOutOfSampleCalendar.Date);
  simulationResultsPortfolio.endDate := SimulationForm.EndOutOfSampleCalendar.Date;
  getIndicatorStatistics(simulationResultsPortfolio);
  //ShowMessage(FloatToStr(simulationResultsPortfolio.modifiedSharpeRatio));

  MainForm.BalanceCurve.Clear;
  MainForm.BalanceCurve.Clear;
  MainForm.BalanceCurveFit.Clear;
  MainForm.upperStdDev.Clear;
  MainForm.lowerStdDev.Clear;

  MainForm.Chart1.AxisList[1].Marks.Source := MainForm.BalanceCurve.Source;

  MainForm.TradeGrid.RowCount := 1;

  MainForm.zeroLine.Position := INITIAL_BALANCE;

  MainForm.inSampleEndLine.Position := SimulationForm.EndInSampleCalendar.Date;

  for i:= 1 to 20 do
  begin

       case i of
           IDX_PGRID_PROFIT: PortfolioResultForm.PortfolioResultsGrid.Cells[1,i] := FloatToStr(round2(simulationResultsPortfolio.absoluteProfit  , 2) );
           IDX_PGRID_PROFIT_PER_TRADE: PortfolioResultForm.PortfolioResultsGrid.Cells[1,i] :=FloatToStr(round2(simulationResultsPortfolio.absoluteProfit/simulationResultsPortfolio.totalTrades, 2)) ;
           IDX_PGRID_LONG_COUNT: PortfolioResultForm.PortfolioResultsGrid.Cells[1,i] :=FloatToStr(round2(simulationResultsPortfolio.longTrades  , 2) );
           IDX_PGRID_SHORT_COUNT: PortfolioResultForm.PortfolioResultsGrid.Cells[1,i] := FloatToStr(round2(simulationResultsPortfolio.shortTrades  , 2) );
           IDX_PGRID_TOTAL_COUNT : PortfolioResultForm.PortfolioResultsGrid.Cells[1,i] := FloatToStr(round2(simulationResultsPortfolio.totalTrades  , 2) );
           IDX_PGRID_MAX_DRAWDOWN: PortfolioResultForm.PortfolioResultsGrid.Cells[1,i] :=FloatToStr(round2(simulationResultsPortfolio.maximumDrawDown  , 2) );
           IDX_PGRID_MAX_DRAWDOWN_LENGTH: PortfolioResultForm.PortfolioResultsGrid.Cells[1,i] := FloatToStr(round2(simulationResultsPortfolio.maximumDrawDownLength  , 2) );
           IDX_PGRID_CONS_LOSS: PortfolioResultForm.PortfolioResultsGrid.Cells[1,i] := FloatToStr(round2(simulationResultsPortfolio.consecutiveLoses  , 2) );
           IDX_PGRID_CONS_WIN: PortfolioResultForm.PortfolioResultsGrid.Cells[1,i] := FloatToStr(round2(simulationResultsPortfolio.consecutiveWins  , 2) );
           IDX_PGRID_PROFIT_TO_DD_RATIO: PortfolioResultForm.PortfolioResultsGrid.Cells[1,i] := FloatToStr(round2(simulationResultsPortfolio.profitToDD  , 2) );
           IDX_PGRID_WINNING_PERCENT: PortfolioResultForm.PortfolioResultsGrid.Cells[1,i] :=FloatToStr(round2(simulationResultsPortfolio.rewardToRisk  , 2) );
           IDX_PGRID_REWARD_TO_RISK: PortfolioResultForm.PortfolioResultsGrid.Cells[1,i] := FloatToStr(round2(simulationResultsPortfolio.skewness  , 2) );
           IDX_PGRID_SKEWNESS: PortfolioResultForm.PortfolioResultsGrid.Cells[1,i] := FloatToStr(round2(simulationResultsPortfolio.kurtosis  , 2) );
           IDX_PGRID_KURTOSIS: PortfolioResultForm.PortfolioResultsGrid.Cells[1,i] := FloatToStr(round2(simulationResultsPortfolio.winningPercent  , 2) );
           IDX_PGRID_PROFIT_FACTOR: PortfolioResultForm.PortfolioResultsGrid.Cells[1,i] := FloatToStr(round2(simulationResultsPortfolio.profitFactor  , 2) );
           IDX_PGRID_LINEAR_FIT_R2 : PortfolioResultForm.PortfolioResultsGrid.Cells[1,i] := FloatToStr(round2(simulationResultsPortfolio.linearFitR2  , 2) );
           IDX_PGRID_SQN : PortfolioResultForm.PortfolioResultsGrid.Cells[1,i] := FloatToStr(round2(simulationResultsPortfolio.systemQualityNumber  , 2) );
           IDX_PGRID_ULCER_INDEX: PortfolioResultForm.PortfolioResultsGrid.Cells[1,i] := FloatToStr(round2(simulationResultsPortfolio.ulcerIndex  , 2) );
           IDX_PGRID_STD_DEV: PortfolioResultForm.PortfolioResultsGrid.Cells[1,i] := FloatToStr(round2(simulationResultsPortfolio.standardDeviation  , 2) );
           IDX_PGRID_MODIFIED_SHARPE_RATIO: PortfolioResultForm.PortfolioResultsGrid.Cells[1,i] :=FloatToStr(round2(simulationResultsPortfolio.modifiedSharpeRatio  , 2) );
           end;
  end;



    for i:= 1 to Length(simulationResultsPortfolio.balanceCurve)-1 do
          begin

          //this line draws the balance curve
          MainForm.BalanceCurve.AddXY(simulationResultsPortfolio.trades[i-1].closeTime, simulationResultsPortfolio.balanceCurve[i], FormatDateTime('mm/yyyy', simulationResultsPortfolio.trades[i-1].closeTime));

          if simulationResultsPortfolio.linearFitR2 > 0.1 then
          begin
          MainForm.upperStdDev.AddXY(simulationResultsPortfolio.trades[i-1].closeTime, simulationResultsPortfolio.linearFitSlope*(simulationResultsPortfolio.trades[i-1].closeTime-simulationResultsPortfolio.trades[0].closeTime) + simulationResultsPortfolio.linearFitIntercept - simulationResultsPortfolio.standardDeviationResiduals, FormatDateTime('mm/yyyy', simulationResultsPortfolio.trades[i-1].closeTime)) ;
          MainForm.lowerStdDev.AddXY(simulationResultsPortfolio.trades[i-1].closeTime, simulationResultsPortfolio.linearFitSlope*(simulationResultsPortfolio.trades[i-1].closeTime-simulationResultsPortfolio.trades[0].closeTime) + simulationResultsPortfolio.linearFitIntercept - simulationResultsPortfolio.standardDeviationResiduals*2, FormatDateTime('mm/yyyy', simulationResultsPortfolio.trades[i-1].closeTime)) ;
          MainForm.BalanceCurveFit.AddXY(simulationResultsPortfolio.trades[i-1].closeTime, simulationResultsPortfolio.linearFitSlope*(simulationResultsPortfolio.trades[i-1].closeTime-simulationResultsPortfolio.trades[0].closeTime) + simulationResultsPortfolio.linearFitIntercept, FormatDateTime('mm/yyyy', simulationResultsPortfolio.trades[i-1].closeTime));
          end;

          end;

          PortfolioResultForm.Visible := true;

end;

Procedure runSingleSystem(usedSymbol: integer; patternToUse: TIndicatorPattern; closingPatternToUse: TIndicatorPattern);
var
  simulationResults: TIndicatorSimulationResults;
begin

      SetLength(indicatorEntryPatterns, Length(indicatorEntryPatterns)+1);
      SetLength(indicatorClosePatterns, Length(indicatorClosePatterns)+1);

      simulationResults := runIndicatorSimulation( patternToUse,
                                                   closingPatternToUse,
                                                   usedSymbol,
                                                   SimulationForm.useSLCheck.Checked,
                                                   SimulationForm.useTPCheck.Checked,
                                                   SimulationForm.BeginInSampleCalendar.Date,
                                                   SimulationForm.EndInSampleCalendar.Date,
                                                   true);

     addIndicatorResultToGrid(simulationResults, Length(indicatorEntryPatterns), SimulationForm.EndOutOfSampleCalendar.Date );

     indicatorEntryPatterns[Length(indicatorEntryPatterns)-1] := patternToUse;
     indicatorClosePatterns[Length(indicatorClosePatterns)-1] := patternToUse;

end;

end.

