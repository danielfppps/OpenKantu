unit kantu_definitions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TRealPoint = record
    x,y:extended;
  end;

type TRealPointArray=array of TRealPoint;
type TPointArray = array of TPoint;

type
   TOrder = record
     orderType   : integer;
     lastSignalOpenPrice : double;
     openPrice   : double;
     closePrice  : double;
     volume      : double;
     SL          : double;
     TP          : double;
     openTime    : TDateTime;
     closeTime   : TDateTime;
     profit      : double;
     symbol      : string;
   end;



type
   Tohlc = record
     open  : double;
     high  : double;
     low   : double;
     close : double;
     volume: double;
   end;

type
   TSymbolHistory = record
     time           : array of TDateTime;
     OHLC           : array of Tohlc;
     ATR            : array of double;
     symbol         : string;
     spread         : double;
     contractSize   : double;
     timeFrame      : integer;
     slippage       : double;
     commission     : double;
     isVolume       : boolean;
     pointConversion: integer;
     roundLots      : integer;
     MinimumStop    : double;
   end;



type
   TCandleObject = record
     rules      : array of array of integer;
     direction  : integer;
     shift      : integer;
   end;

type
   TPricePattern = record
   candles : array of TCandleObject;
   SL: double;
   TP: double;
   hourFilter: integer;
   dayFilter : integer;
   timeExit  : integer;
   end;

type
   TIndicator = record
   data: array of double;
   indiType: integer;
   name: string;
end;

type
   TIndicatorPattern = record
   tradingRules: array of array of integer;
   allowLongSignals: boolean;
   allowShortSignals: boolean;
   SL: double;
   TP: double;
   TL: double;
   SLTSLope: double;
   hourFilter: integer;
   dayFilter : integer;
   timeExit  : integer;
end;

type TIndicatorGroup = array of TIndicator;
type TIndicatorPatternGroup = array of TIndicatorPattern;

   type
   TSimulationResults = record
     balanceCurve             : array of double;
     trades                   : array of TOrder;
     symbol                   : integer;
     totalTrades              : integer;
     shortTrades              : integer;
     longTrades               : integer;
     consecutiveWins          : integer;
     consecutiveLoses         : integer;
     maximumDrawDown          : double;
     maximumDrawDownLength    : integer;
     absoluteProfit           : double;
     rewardToRisk             : double;
     winningPercent           : double;
     profitFactor             : double;
     profitToDD               : double;
     linearFitR2              : double;
     systemQualityNumber      : double;
     totalYears               : double;
     customFilter             : double;
     skewness                 : double;
     kurtosis                 : double;
     ulcerIndex               : double;
     standardDeviation        : double;
     linearFitSlope           : double;
     linearFitIntercept       : double;
     modifiedSharpeRatio      : double;
     standardDeviationResiduals : double;
     standardDeviationBreach : double;
     startDate                : TDateTime;
     endDate                  : TDateTime;
     entryPricePattern        : TPricePattern;
     closePricePattern        : TPricePattern;
     isInconsistentLogic      : boolean;
   end;

   type
   TIndicatorSimulationResults = record
     balanceCurve             : array of double;
     trades                   : array of TOrder;
     MFE_Longs                : array of double;
     MUE_Longs                : array of double;
     MFE_Shorts               : array of double;
     MUE_Shorts               : array of double;
     lowestLag                : integer;
     total_ME                 : double;
     totalLongSignals         : integer;
     totalShortSignals        : integer;
     symbol                   : integer;
     totalTrades              : integer;
     shortTrades              : integer;
     longTrades               : integer;
     consecutiveWins          : integer;
     consecutiveLoses         : integer;
     maximumDrawDown          : double;
     maximumDrawDownLength    : integer;
     absoluteProfit           : double;
     absoluteProfitLongs      : double;
     absoluteProfitShorts     : double;
     rewardToRisk             : double;
     winningPercent           : double;
     profitFactor             : double;
     profitToDD               : double;
     linearFitR2              : double;
     systemQualityNumber      : double;
     totalYears               : double;
     customFilter             : double;
     skewness                 : double;
     kurtosis                 : double;
     ulcerIndex               : double;
     standardDeviation        : double;
     linearFitSlope           : double;
     linearFitIntercept       : double;
     modifiedSharpeRatio      : double;
     standardDeviationResiduals : double;
     standardDeviationBreach  : double;
     startDate                : TDateTime;
     endDate                  : TDateTime;
     entryPricePattern        : TIndicatorPattern;
     closePricePattern        : TIndicatorPattern;
     daysOut                  : integer;
     isLastYearProfit         : boolean;
     idealR                   : double;
     isInconsistentLogic      : boolean;
   end;

const
  // order constants

  NONE     =  0 ;
  BUY      =  1 ;
  SELL     =  2 ;
  EVAL_TYPE_ENTRY    =  0;
  EVAL_TYPE_EXIT     =  1;

  // simulation types

  SIMULATION_TYPE_PRICE_PATTERN = 0;
  SIMULATION_TYPE_INDICATORS    = 1;

  // indicator pattern

  IDX_FIRST_INDICATOR           = 0;
  IDX_SECOND_INDICATOR          = 1;
  IDX_FIRST_INDICATOR_SHIFT     = 2;
  IDX_SECOND_INDICATOR_SHIFT    = 3;
  INDICATOR_RULES_TOTAL         = 4;
  LESS_THAN                     = 0;
  GREATER_THAN                  = 1;

  // price pattern
  ENTRY_PATTERN        = 1;
  EXIT_PATTERN         = 2;
  DIRECTION_NORMAL     = 1;
  DIRECTION_REVERSE    = 2;

  // statistics
  IDX_ABSOLUTE_PROFIT   = 0;
  IDX_MAX_DRAWDOWN      = 1;
  IDX_CONSECUTIVE_WIN   = 2;
  IDX_CONSECUTIVE_LOSS  = 3;
  IDX_AAR_TO_DD_RATIO   = 4;

  //rules
  IDX_CHOSEN_RULE       = 0;
  IDX_CANDLE_TO_COMPARE = 1;
  TOTAL_CANDLE_RULES    = 42;
  TOTAL_VOLUME_RULES    = 2;

  // back-testing

  INITIAL_BALANCE       = 100000;
  ATR_PERIOD            = 20;
  MINIMUM_TRADE_NUMBER  = 150;
  LONG_ENTRY            = 1;
  SHORT_ENTRY           = 2;
  SHORT_EXIT            = 3;
  LONG_EXIT             = 4;

  // result grid

  IDX_GRID_USE_IN_PORTFOLIO     = 0;
  IDX_GRID_RESULT_NUMBER        = 1;
  IDX_GRID_SYMBOL               = 2;
  IDX_GRID_PROFIT               = 3;
  IDX_GRID_PROFIT_PER_TRADE     = 4;
  IDX_GRID_PROFIT_LONGS         = 5;
  IDX_GRID_PROFIT_SHORTS        = 6;
  IDX_GRID_LONG_COUNT           = 7;
  IDX_GRID_SHORT_COUNT          = 8;
  IDX_GRID_TOTAL_COUNT          = 9;
  IDX_GRID_MAX_DRAWDOWN         = 10;
  IDX_GRID_IDEAL_R              = 11;
  IDX_GRID_LINEAR_FIT_R2        = 12;
  IDX_GRID_ULCER_INDEX          = 13;
  IDX_GRID_MAX_DRAWDOWN_LENGTH  = 14;
  IDX_GRID_CONS_LOSS            = 15;
  IDX_GRID_CONS_WIN             = 16;
  IDX_GRID_PROFIT_TO_DD_RATIO   = 17;
  IDX_GRID_WINNING_PERCENT      = 18;
  IDX_GRID_REWARD_TO_RISK       = 19;
  IDX_GRID_SKEWNESS             = 20;
  IDX_GRID_KURTOSIS             = 21;
  IDX_GRID_PROFIT_FACTOR        = 22;
  IDX_GRID_STD_DEV              = 23;
  IDX_GRID_STD_DEV_BREACH       = 24;
  IDX_GRID_TOTAL_ME             = 25;
  IDX_GRID_SQN                  = 26;
  IDX_GRID_MODIFIED_SHARPE_RATIO= 27;
  IDX_GRID_CUSTOM_CRITERIA      = 28;
  IDX_GRID_DAYS_OUT             = 29;
  IDX_GRID_OUT_OF_SAMPLE_PROFIT = 30;
  IDX_GRID_OSP_PER_TRADE        = 31;
  IDX_GRID_OS_PROFIT_LONGS         = 32;
  IDX_GRID_OS_PROFIT_SHORTS        = 33;
  IDX_GRID_OS_LONG_COUNT           = 34;
  IDX_GRID_OS_SHORT_COUNT          = 35;
  IDX_GRID_OS_TOTAL_COUNT          = 36;
  IDX_GRID_OS_MAX_DRAWDOWN         = 37;
  IDX_GRID_OS_ULCER_INDEX          = 38;
  IDX_GRID_OS_MAX_DRAWDOWN_LENGTH  = 39;
  IDX_GRID_OS_CONS_LOSS            = 40;
  IDX_GRID_OS_CONS_WIN             = 41;
  IDX_GRID_OS_PROFIT_TO_DD_RATIO   = 42;
  IDX_GRID_OS_WINNING_PERCENT      = 43;
  IDX_GRID_OS_REWARD_TO_RISK       = 44;
  IDX_GRID_OS_SKEWNESS             = 45;
  IDX_GRID_OS_KURTOSIS             = 46;
  IDX_GRID_OS_PROFIT_FACTOR        = 47;
  IDX_GRID_OS_STD_DEV              = 48;
  IDX_GRID_OS_STD_DEV_BREACH       = 49;
  IDX_GRID_OS_TOTAL_ME             = 50;
  IDX_GRID_OS_LINEAR_FIT_R2        = 51;
  IDX_GRID_OS_SQN                  = 52;
  IDX_GRID_OS_MODIFIED_SHARPE_RATIO= 53;
  IDX_GRID_OS_CUSTOM_CRITERIA      = 54;
  IDX_GRID_OS_DAYS_OUT             = 55;
  IDX_GRID_LOWEST_LAG              = 56;





   // portfolio result grid

  IDX_PGRID_PROFIT               = 1;
  IDX_PGRID_PROFIT_PER_TRADE     = 2;
  IDX_PGRID_LONG_COUNT           = 3;
  IDX_PGRID_SHORT_COUNT          = 4;
  IDX_PGRID_TOTAL_COUNT          = 5;
  IDX_PGRID_MAX_DRAWDOWN         = 6;
  IDX_PGRID_MAX_DRAWDOWN_LENGTH  = 7;
  IDX_PGRID_CONS_LOSS            = 8;
  IDX_PGRID_CONS_WIN             = 9;
  IDX_PGRID_PROFIT_TO_DD_RATIO   = 10;
  IDX_PGRID_WINNING_PERCENT      = 11;
  IDX_PGRID_REWARD_TO_RISK       = 12;
  IDX_PGRID_SKEWNESS             = 13;
  IDX_PGRID_KURTOSIS             = 14;
  IDX_PGRID_PROFIT_FACTOR        = 15;
  IDX_PGRID_LINEAR_FIT_R2        = 16;
  IDX_PGRID_SQN                  = 17;
  IDX_PGRID_ULCER_INDEX          = 18;
  IDX_PGRID_STD_DEV              = 19;
  IDX_PGRID_MODIFIED_SHARPE_RATIO= 20;


  //options grid

  IDX_OPT_MAX_RULES_PER_CANDLE           =1;
  IDX_OPT_MAX_CANDLE_SHIFT               =2;
  IDX_OPT_SHIFT_STEP                     =3;
  IDX_OPT_FIXED_SL                       =4;
  IDX_OPT_FIXED_TP                       =5;
  IDX_OPT_FIXED_TL                       =6;
  IDX_OPT_FIXED_HOUR                     =7;
  IDX_OPT_SLTPTL_STEP                    =8;
  IDX_OPT_MAX_SLTPTL                     =9;
  IDX_OPT_NO_OF_CORES                    =10;
  IDX_OPT_BARS_ME                        =11;
  IDX_OPT_REQUESTED_SYSTEMS              =12;

  // filters grid

  IDX_FILTER_TRADES                      = 1;
  IDX_FILTER_RISK_TO_REWARD              = 2;
  IDX_FILTER_WINNING_PERCENT             = 3;
  IDX_FILTER_PROFIT                      = 4;
  IDX_FILTER_PROFIT_TO_DD                = 5;
  IDX_FILTER_DD                          = 6;
  IDX_FILTER_DD_LENGTH                   = 7;
  IDX_FILTER_PROFIT_FACTOR               = 8;
  IDX_FILTER_IDEAL_R                     = 9;
  IDX_FILTER_LINEAR_FIT_R2               = 10;
  IDX_FILTER_SQN                         = 11;
  IDX_FILTER_CUSTOM                      = 12;
  IDX_FILTER_SKEWNESS                    = 13;
  IDX_FILTER_KURTOSIS                    = 14;
  IDX_FILTER_ULCER_INDEX                 = 15;
  IDX_FILTER_STD_DEV                     = 16;
  IDX_FILTER_MODIFIED_SHARPE_RATIO       = 17;
  IDX_FILTER_STD_DEV_BREACH              = 18;
  IDX_FILTER_TOTAL_ME                    = 19;

  TRADES_FOR_IR_CALCULATION              = 20;

  // genetics
  TOP_PERFORMERS_SAVED                   = 5;

  // symbol selection
  FIRST_SYMBOL                           = 0;

  // program version

  KANTU_VERSION         = '2.40';

implementation

end.

