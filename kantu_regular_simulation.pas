unit kantu_regular_simulation;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus, Grids,
  Buttons,  kantu_definitions, Math, dateUtils,fpexprpars, kantu_main, kantu_loadSymbol,
  kantu_simulation, kantu_filters, kantu_custom_filter, kantu_multithreading,
  kantu_pricepattern, kantu_portfolioResults;

    var
    priceEntryPatterns: array of TPricePattern;
    priceClosePatterns: array of TPricePattern;
    simulationsRan : double;
    validResults   : integer;
    procedure sortResultsGrid;
    procedure ArrayRandomizer(const MaxValue: Integer; var Values: array of Integer) ;
    function  round2(const Number: extended; const Places: longint): extended;
    procedure QuickSort(var A: array of Integer; iLo, iHi: Integer) ;
    procedure saveResultsToFile(filename: string;  simulationResults: TSimulationResults);

implementation


function round2(const Number: extended; const Places: longint): extended;
var t: extended;
begin
   t := power(10, places);
   round2 := round(Number*t)/t;
end;

procedure sortResultsGrid;
begin

 case SimulationForm.OptTargetComboBox.ItemIndex of
        0: begin MainForm.ResultsGrid.SortOrder := soDescending; MainForm.ResultsGrid.SortColRow(true, IDX_GRID_PROFIT); end;
        1: begin MainForm.ResultsGrid.SortOrder := soAscending; MainForm.ResultsGrid.SortColRow(true, IDX_GRID_MAX_DRAWDOWN);  end;
        2: begin MainForm.ResultsGrid.SortOrder := soAscending; MainForm.ResultsGrid.SortColRow(true, IDX_GRID_MAX_DRAWDOWN_LENGTH);  end;
        3: begin MainForm.ResultsGrid.SortOrder := soDescending; MainForm.ResultsGrid.SortColRow(true, IDX_GRID_PROFIT_TO_DD_RATIO); end;
        4: begin MainForm.ResultsGrid.SortOrder := soDescending; MainForm.ResultsGrid.SortColRow(true, IDX_GRID_PROFIT_FACTOR); end;
        5: begin MainForm.ResultsGrid.SortOrder := soDescending; MainForm.ResultsGrid.SortColRow(true, IDX_GRID_LINEAR_FIT_R2); end;
        6: begin MainForm.ResultsGrid.SortOrder := soDescending; MainForm.ResultsGrid.SortColRow(true, IDX_GRID_SQN); end;
        7: begin MainForm.ResultsGrid.SortOrder := soDescending; MainForm.ResultsGrid.SortColRow(true, IDX_GRID_WINNING_PERCENT); end;
        8: begin MainForm.ResultsGrid.SortOrder := soDescending; MainForm.ResultsGrid.SortColRow(true, IDX_GRID_REWARD_TO_RISK); end;
        9: begin MainForm.ResultsGrid.SortOrder := soDescending; MainForm.ResultsGrid.SortColRow(true, IDX_GRID_SKEWNESS); end;
        10: begin MainForm.ResultsGrid.SortOrder := soDescending; MainForm.ResultsGrid.SortColRow(true, IDX_GRID_KURTOSIS); end;
        11: begin MainForm.ResultsGrid.SortOrder := soAscending; MainForm.ResultsGrid.SortColRow(true, IDX_GRID_ULCER_INDEX); end;
        12: begin MainForm.ResultsGrid.SortOrder := soAscending; MainForm.ResultsGrid.SortColRow(true, IDX_GRID_STD_DEV); end;
        13: begin MainForm.ResultsGrid.SortOrder := soAscending; MainForm.ResultsGrid.SortColRow(true, IDX_GRID_STD_DEV_BREACH); end;
        14: begin MainForm.ResultsGrid.SortOrder := soDescending; MainForm.ResultsGrid.SortColRow(true, IDX_GRID_TOTAL_ME); end;
        15: begin MainForm.ResultsGrid.SortOrder := soDescending; MainForm.ResultsGrid.SortColRow(true, IDX_GRID_CUSTOM_CRITERIA); end;
        end;

end;

procedure updateBalanceChart(simulationResultsFinal, simulationResultsFinalPortfolio: TSimulationResults);
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
    MainForm.Chart1.AxisList[2].Marks.Source := MainForm.BalanceCurvePortfolio.Source;

    MainForm.TradeGrid.RowCount := 1;

    MainForm.zeroLine.Position := INITIAL_BALANCE;

    MainForm.inSampleEndLine.Position := SimulationForm.EndInSampleCalendar.Date;


    for i:= 1 to Length(simulationResultsFinal.balanceCurve)-1 do
          begin

          //this line draws the balance curve
          MainForm.BalanceCurve.AddXY(simulationResultsFinal.trades[i-1].closeTime, simulationResultsFinal.balanceCurve[i], FormatDateTime('mm/yyyy', simulationResultsFinal.trades[i-1].closeTime));

          if simulationResultsFinal.linearFitR2 > 0.1 then
          begin
          MainForm.upperStdDev.AddXY(simulationResultsFinal.trades[i-1].closeTime, simulationResultsFinal.linearFitSlope*(simulationResultsFinal.trades[i-1].closeTime-simulationResultsFinal.trades[0].closeTime) + simulationResultsFinal.linearFitIntercept - 0.01*INITIAL_BALANCE*simulationResultsFinal.maximumDrawDown, FormatDateTime('mm/yyyy', simulationResultsFinal.trades[i-1].closeTime)) ;
          MainForm.lowerStdDev.AddXY(simulationResultsFinal.trades[i-1].closeTime, simulationResultsFinal.linearFitSlope*(simulationResultsFinal.trades[i-1].closeTime-simulationResultsFinal.trades[0].closeTime) + simulationResultsFinal.linearFitIntercept - 0.01*INITIAL_BALANCE*simulationResultsFinal.maximumDrawDown*2, FormatDateTime('mm/yyyy', simulationResultsFinal.trades[i-1].closeTime)) ;
          MainForm.BalanceCurveFit.AddXY(simulationResultsFinal.trades[i-1].closeTime, simulationResultsFinal.linearFitSlope*(simulationResultsFinal.trades[i-1].closeTime-simulationResultsFinal.trades[0].closeTime) + simulationResultsFinal.linearFitIntercept, FormatDateTime('mm/yyyy', simulationResultsFinal.trades[i-1].closeTime));
          end;

          end;

    for i:= 1 to Length(simulationResultsFinalPortfolio.balanceCurve)-1 do
          begin

          //this line draws the balance curve
          MainForm.BalanceCurvePortfolio.AddXY(IncMinute(simulationResultsFinalPortfolio.trades[i-1].closeTime, 1), simulationResultsFinalPortfolio.balanceCurve[i], FormatDateTime('mm/yyyy', IncMinute(simulationResultsFinalPortfolio.trades[i-1].closeTime, 1)));

          //if simulationResultsFinalPortfolio.linearFitR2 > 0.1 then
          //MainForm.BalanceCurveFitPortfolio.AddXY(simulationResultsFinalPortfolio.trades[i-1].closeTime, simulationResultsFinalPortfolio.linearFitSlope*simulationResultsFinalPortfolio.trades[i-1].closeTime + simulationResultsFinalPortfolio.linearFitIntercept, FormatDateTime('mm/yyyy', simulationResultsFinalPortfolio.trades[i-1].closeTime));


          end;

          MainForm.StatusLabel.Visible := false;

end;

procedure saveResultsToFile(filename: string;  simulationResults: TSimulationResults);
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

Function getCustomCriteria(simulationResults: TSimulationResults): double;
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

procedure ArrayRandomizer( const maxValue : integer; var values: array of integer ) ;
 var cnt: integer;
     i_random: int64;
     ab_table: array of boolean;
 begin
   SetLength( ab_table, maxValue ) ;
   for cnt := Low(values) to High(values) do
   begin
     while true do
     begin
       i_random := Random(maxValue);
       if not ab_table[i_random] then
       begin
         values[cnt] := i_random;
         ab_table[i_random] := true;
         break;
       end;
     end;
   end;
 end;

procedure QuickSort(var A: array of Integer; iLo, iHi: Integer) ;
 var
   Lo, Hi, Pivot, T: Integer;
 begin
   Lo := iLo;
   Hi := iHi;
   Pivot := A[(Lo + Hi) div 2];
   repeat
     while A[Lo] < Pivot do Inc(Lo) ;
     while A[Hi] > Pivot do Dec(Hi) ;
     if Lo <= Hi then
     begin
       T := A[Lo];
       A[Lo] := A[Hi];
       A[Hi] := T;
       Inc(Lo) ;
       Dec(Hi) ;
     end;
   until Lo > Hi;
   if Hi > iLo then QuickSort(A, iLo, Hi) ;
   if Lo < iHi then QuickSort(A, Lo, iHi) ;
 end;

end.


