//+--------------------------------------------------------------------+
//| MT4, Kantu generated Strategy                                      |
//| Copyright © 2013, Daniel Fernandez, Asirikuy.com                   |
//| Idea, initial implementation and optimization by Daniel Fernandez, |
//| functional decomposition, code styling, error handling and user    |
//| interface coded in part by Maxim Feinshtein.                       |
//+--------------------------------------------------------------------+

#property copyright "System created using Kantu by, Daniel Fernandez Copyright © 2015"
#property link      "www.asirikuy.com"

#include <stdlib.mqh>
#include <stderror.mqh>

// For double comparisons
#define EPSILON 0.0000001

#define COMPONENT_NAME        "KANTU_GENERATED_SYSTEM"

//addOpenKantuVersion

#define OP_DEPOSITORWITHDRAWAL         6

#define NO_ERROR                        0

#define ERROR_TIME_BUFFER              60

#define SECONDS_IN_DAY                 86400

#define OPERATIONAL_MODE_TRADING    0
#define OPERATIONAL_MODE_MONITORING 1
#define OPERATIONAL_MODE_TESTING    2

#define ALERT_STATUS_NEW                      0
#define ALERT_STATUS_DISPLAYED                     1

//--------------------------------------------------------- Equity track begin -------------------------
#define EQUITY_TRACK_NONE  0
#define EQUITY_TRACK_FILE  1
//--------------------------------------------------------- Equity track end -------------------------


#define STATUS_NONE                    -1
#define STATUS_INVALID_BARS_COUNT       0
#define STATUS_INVALID_TIMEFRAME        1
#define STATUS_DIVIDE_BY_ZERO           2
#define STATUS_LAST_ERROR               3
#define STATUS_ATR_INIT_PROBLEM         4
#define STATUS_TRADE_CONTEXT_BUSY       5
#define STATUS_TRADING_NOT_ALLOWED      6
#define STATUS_DUPLICATE_ID             7
#define STATUS_RUNNING_ON_DEFAULTS      8
#define STATUS_BELOW_MIN_LOT_SIZE       9
#define STATUS_LIBS_NOT_ALLOWED         10
#define STATUS_NOT_ENOUGH_DATA			11

#define QUERY_NONE             0
#define QUERY_LONGS_COUNT      1
#define QUERY_SHORTS_COUNT     2
#define QUERY_BUY_STOP_COUNT   3
#define QUERY_SELL_STOP_COUNT  4
#define QUERY_BUY_LIMIT_COUNT  5
#define QUERY_SELL_LIMIT_COUNT 6
#define QUERY_ALL              7

#define PATTERN_NONE          -1
#define LONG_ENTRY_PATTERN     0
#define SHORT_ENTRY_PATTERN    1
#define LONG_EXIT_PATTERN      2
#define SHORT_EXIT_PATTERN     3

#define SIGNAL_NONE                 -1
#define SIGNAL_ENTER_BUY             0
#define SIGNAL_ENTER_SELL            1
#define SIGNAL_CLOSE_BUY             2
#define SIGNAL_CLOSE_SELL            3
#define SIGNAL_UPDATE_BUY            4
#define SIGNAL_UPDATE_SELL           5

#define BUY_COLOR          DodgerBlue
#define BUY_CLOSE_COLOR    Blue
#define SELL_COLOR         DeepPink
#define SELL_UPDATE_COLOR  Orange
#define BUY_UPDATE_COLOR   Green
#define SELL_CLOSE_COLOR   Red
#define INFORMATION_COLOR  Yellow
#define ERROR_COLOR        Red
#define TRAIL_COLOR        Yellow

// Status management
#define SEVERITY_INFO  0
#define SEVERITY_ERROR 1

extern string Kantu = "This is a trading strategy created using Kantu";
extern int    OPERATIONAL_MODE    = OPERATIONAL_MODE_TRADING;
//insertInstanceID
extern double SLIPPAGE            = 5   ;
extern bool   DISABLE_COMPOUNDING = true;
extern int    ATR_PERIOD          = 20;
extern double RISK                = 1;
extern double TAKE_PROFIT         = 0;
extern double STOP_LOSS           = 0;
extern string TRADE_COMMENT       = "input trade comment";

// EA global variables
string g_symbol;
double g_pipValue;
double g_ATR;
int    g_waitCounter;
double g_instancePL_UI ;  
double g_generatedINSTANCE_ID ;

//Initial balance and balance reset variables
string g_balanceTimeLabel ;
string g_initialBalanceLabel ;
string g_initBalBackupFile ;
int g_balanceBackupTime = 0 ;
double g_initialBalance ;
int g_instanceStartTime ;

int g_alertStatus ;
string g_lastError ;
int g_lastErrorPrintTime ;
int g_indiLibraryStatus;
int g_periodSeconds;
int g_barsAvailable;

double g_maxTradeSize,
       g_minTradeSize,
       g_spreadPIPs,
       g_adjustedSlippage,
       g_instanceBalance,
		 g_tradeSize;
		 
double g_stopLossPIPs,
	   g_takeProfitPIPs;
	   
//defineMaxShiftNeeded

int g_minimalStopPIPs;
int g_contractSize,
	 g_brokerDigits,
	 g_period,
	 g_tradingSignal;

//--------------------------------------------------------- Equity track begin -------------------------
int g_fileEquityLog;
string g_currentDay="",
       g_timeOfEquityMin; 
double g_dailyEquityMin,
       g_prevDailyEquityMin;
//--------------------------------------------------------- Equity track end -------------------------


//-------------------   UI staff   ------------------

// Graphical entities names
string g_objGeneralInfo      = "labelGeneral",
       g_objTradeSize        = "labelTradeSize",
		 g_objStopLoss         = "labelStopLoss",
		 g_objTakeProfit       = "labelTakeProfit",
		 g_objATR              = "labelATR",
		 g_objPL               = "labelPL",
		 g_objStatusPane       = "labelStatusPane",
		 g_objBalance          = "labelBalance";
string g_fontName = "Times New Roman";

int   FontSize = 10;
// The value at index 'i' returns the string
// to be displayed for the error/warning, having ID equal to i.
string g_statusMessages[];

// The value at index 'i' returns the string
// to be displayed for pattern, having ID equal to i.
string g_detectedPatternNames[];

// UI state management
int g_severityStatus,
	 g_lastStatusID          = STATUS_NONE,
	 g_lastDetectedPatternID = PATTERN_NONE;

// The offset, in pixels, of the first information line from the top-left corner.
int g_baseXOffset = 15,
	 g_baseYOffset = 20;

// Controls how far or near are text lines on Y axis
double g_textDensingFactor = 1.5;

// The EA initialization funtion
int init() 
{
   displayWelcomeMessage() ;
   
   g_initialBalance = AccountBalance() ;

	g_symbol = Symbol();
	g_period = Period();
	g_periodSeconds = PeriodSeconds(g_period);
	g_pipValue = Point;	
	generateINSTANCE_ID() ;
		
	// Retrieve the minimum stop loss in PIPs
	g_minimalStopPIPs = MarketInfo( g_symbol, MODE_STOPLEVEL );
	g_maxTradeSize    = MarketInfo( g_symbol, MODE_MAXLOT    );
	g_minTradeSize    = MarketInfo( g_symbol, MODE_MINLOT    );

	g_brokerDigits  = Digits;
	g_tradingSignal = SIGNAL_NONE;
   
   if(OPERATIONAL_MODE != OPERATIONAL_MODE_TESTING )
	initUI();

	// Success
	return (0);
}

//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{   
   if(OPERATIONAL_MODE != OPERATIONAL_MODE_TESTING )
	deinitUI();
	
	return (0);
}

//+------------------------------------------------------------------+
//| Tick handling function                                           |
//+------------------------------------------------------------------+
int start()
{

g_lastStatusID = STATUS_NONE ;
g_severityStatus = SEVERITY_INFO;
g_barsAvailable = iBars(g_symbol, g_period);

checkLibraryUsageAllowed();
	
	if(  STATUS_LIBS_NOT_ALLOWED  == g_lastStatusID )
	{
	     g_severityStatus = SEVERITY_ERROR;
		if( OPERATIONAL_MODE_TESTING != OPERATIONAL_MODE )
			updateStatusUI( true );

		return (0);
	}

	// check if we are running on defaults
	isINSTANCE_IDDefault(INSTANCE_ID);
	
	if(  STATUS_RUNNING_ON_DEFAULTS  == g_lastStatusID )
	{
	     g_severityStatus = SEVERITY_ERROR;
		if( OPERATIONAL_MODE_TESTING != OPERATIONAL_MODE )
			updateStatusUI( true );

		return (0);
	}
	
	verifyINSTANCE_IDUniquiness();
	
	if(  STATUS_DUPLICATE_ID == g_lastStatusID )
	{
	     g_severityStatus = SEVERITY_ERROR;
		if( OPERATIONAL_MODE_TESTING != OPERATIONAL_MODE )
			updateStatusUI( true );

		return (0);
	}

	if(g_barsAvailable < MathMax(g_maxShift, ATR_PERIOD*(SECONDS_IN_DAY/g_periodSeconds)+10)){
	
		g_lastStatusID = STATUS_NOT_ENOUGH_DATA;
	    g_severityStatus = SEVERITY_ERROR;
		if( OPERATIONAL_MODE_TESTING != OPERATIONAL_MODE )
			updateStatusUI( true );
			
	    return (0);
	}
	
	calculateATR();
	
	if( STATUS_DIVIDE_BY_ZERO == g_lastStatusID )
	{  
	   g_severityStatus = SEVERITY_ERROR;  
	   if(OPERATIONAL_MODE != OPERATIONAL_MODE_TESTING )
		updateStatusUI( true );
		return (0);
	}
	if( STATUS_ATR_INIT_PROBLEM == g_lastStatusID )
	{
	   g_severityStatus = SEVERITY_ERROR;
	   if(OPERATIONAL_MODE != OPERATIONAL_MODE_TESTING )
		updateStatusUI( true );
		return (0);
	}
	
	if(OPERATIONAL_MODE != OPERATIONAL_MODE_TESTING )
	{
	calculateInstanceBalance();
	}

	calculateContractSize();
	adjustSlippage();
	calculateSpreadPIPS() ;
	calculateTradeSize();
	calculateStopLossPIPs();
	calculateTakeProfitPIPs();

	g_tradingSignal = checkTradingSignal();

	// Handle already opened trades
	int openedTradesCount = 0;
	for( int cnt = 0; cnt < OrdersTotal(); cnt++ )   
	{
		if( ! OrderSelect( cnt, SELECT_BY_POS, MODE_TRADES ) )
     	{
     		g_severityStatus = STATUS_LAST_ERROR;
     		g_lastStatusID = GetLastError();
     		continue;
		}

		// Filter orders, that were not opened by this instance
		if( ! ( ( OrderSymbol() == g_symbol ) && ( OrderMagicNumber() == INSTANCE_ID ) ) )
		{
			continue;
		}

		handleTrade();
		openedTradesCount++;
	}
	
   if(OPERATIONAL_MODE != OPERATIONAL_MODE_TESTING )
	updateUI();

	if( OPERATIONAL_MODE_MONITORING == OPERATIONAL_MODE )
	{
		// Just handle existing trade
		return (0);
	}
	

	g_tradingSignal = checkTradingSignal();
	
	switch( g_tradingSignal ) {
	case SIGNAL_ENTER_BUY:
		openBuyOrder();
	break;
	case SIGNAL_ENTER_SELL:
		openSellOrder();
	break;
									  } // switch( g_tradingSignal )
									  
   if( ( STATUS_TRADE_CONTEXT_BUSY  == g_lastStatusID ) ||
		 ( STATUS_TRADING_NOT_ALLOWED == g_lastStatusID ) ||
		 ( STATUS_BELOW_MIN_LOT_SIZE == g_lastStatusID ) 
	  )
	{
		g_severityStatus = SEVERITY_ERROR;
		if( OPERATIONAL_MODE != OPERATIONAL_MODE_TESTING )
			updateStatusUI( true );
	}		 
									  
	return (0);
}

void displayWelcomeMessage()
{
	string welcomeMessage = StringConcatenate("You are running ", COMPONENT_NAME, " v.", COMPONENT_VERSION) ;
	Alert( welcomeMessage );
}

void checkLibraryUsageAllowed()
{
   
if (IsLibrariesAllowed() == false) {
      //Library calls must be allowed
      g_lastStatusID = STATUS_LIBS_NOT_ALLOWED ;
   }

}

// This function verifies that we are not running on default settings. 
// If we are then an error is generated which stops trading.
// This is an important feature since several reasons can cause a platform 
// to "reset" back to the EA defaults, something which may be very detrimental
// depending on the systems. 

void isINSTANCE_IDDefault(int ID)
{
   if (ID == -1)
   {
   g_lastStatusID = STATUS_RUNNING_ON_DEFAULTS ;
		return;
   }
}

// Declares the INSTANCE_ID global variable,
// marking it with a unique random number
void generateINSTANCE_ID()
{
	int count;

	// The following if statement creates or increases
	// the "count" variable which is then used as a part of the "seed"
	// for the random number generator, this count ensures that 
	// random numbers remain unique and duplicates identified even if the instances are started
	// at exactly the same time on the same instrument.
	if( GlobalVariableCheck( "rdn_gen_count" ) )
	{
		count = GlobalVariableGet( "rdn_gen_count" );
		g_waitCounter = count ;
		if( count < 100 )
			GlobalVariableSet( "rdn_gen_count", count + 1 );

		if( count >= 100 )
			GlobalVariableSet( "rdn_gen_count", 1 );
	}
	else
	{
		GlobalVariableSet( "rdn_gen_count", 1 );
		count = 1 ;
	}

	// Random number generator seed, current time, Ask and counter are used
	MathSrand( TimeLocal() * Ask * count );
		
	// String for global variable
	string INSTANCE_IDTag = DoubleToStr( INSTANCE_ID, 0 );

	// generate the random number and place it within the tag
	GlobalVariableSet( INSTANCE_IDTag, MathRand() );

	// Assigns the random number to this instance specific global variable
	// this value will be used from now on to check if there are duplicate
	// Instance IDs
	g_generatedINSTANCE_ID = GlobalVariableGet( INSTANCE_IDTag );
}

// Verifies that the tag, generated during initialization, has changed.
// Generates a "duplicate ID" error if this is the case.
void verifyINSTANCE_IDUniquiness()                          
{
	// Retrieve instance ID as string to search for global variable
	string INSTANCE_IDTag = DoubleToStr( INSTANCE_ID, 0 );

	// Assign the value of the global variable
	double retrievedINSTANCE_ID = GlobalVariableGet( INSTANCE_IDTag );
	
	// Check whether the tag has changed from what it had originally been assigned to
	if( MathAbs( g_generatedINSTANCE_ID - retrievedINSTANCE_ID ) >= EPSILON )
	{
		// Gnerates an error if a duplicate instance is found
		g_lastStatusID = STATUS_DUPLICATE_ID;
		return;
	}

	// Reassigning global variable, this does not change the variable's value,
	// however it needs to be done since unmodified variables are deleted
	// after 4 weeks. This "regeneration" avoids deletion.
	GlobalVariableSet( INSTANCE_IDTag, retrievedINSTANCE_ID );
}


bool SetBuyOrderSLAndTP( int tradeTicket, double tradeOpenPrice )
{
	double stopLossPrice   = calculateStopLossPrice( OP_BUY, tradeOpenPrice ),
			 takeProfitPrice = calculateTakeProfitPrice( OP_BUY, tradeOpenPrice );
			 
	if (STOP_LOSS == 0 && TAKE_PROFIT == 0)
	return(true);

	bool res = OrderModify(
	 					tradeTicket,
	 					tradeOpenPrice,
	 					stopLossPrice,
	 					takeProfitPrice,
	 					0,
	 					BUY_COLOR
	 							 );
	if( res )
		return(true);

	logOrderModifyInfo(
						"SetBuyOrderSLAndTP-OrderModify: ",
						tradeTicket,
						tradeOpenPrice,
						stopLossPrice,
						takeProfitPrice,
						GetLastError()
							);
						
	return(false);
}

bool SetSellOrderSLAndTP( int tradeTicket, double tradeOpenPrice )
{
	double stopLossPrice   = calculateStopLossPrice( OP_SELL, tradeOpenPrice ),
			 takeProfitPrice = calculateTakeProfitPrice( OP_SELL, tradeOpenPrice );
			 
	if (STOP_LOSS == 0 && TAKE_PROFIT == 0)
	return(true);		 

	bool res = OrderModify(
	 					tradeTicket,
	 					tradeOpenPrice,
	 					stopLossPrice,
	 					takeProfitPrice,
	 					0,
	 					SELL_COLOR
	 							 );
	if( res )
		return(true);

	logOrderModifyInfo(
						"SetSellOrderSLAndTP-OrderModify: ",
						tradeTicket,
						tradeOpenPrice,
						stopLossPrice,
						takeProfitPrice,
						GetLastError()
						   );
						   
	return(false);
}

void openBuyOrder()
{
	if( ! IsTradeAllowed() )
	{
		g_lastStatusID = STATUS_TRADING_NOT_ALLOWED;
		
		if ((TimeCurrent()- g_lastErrorPrintTime) > ERROR_TIME_BUFFER) 
		{
		Print( "openBuyOrder: Trading is not allowed." );
		g_lastErrorPrintTime = TimeCurrent();
		}
		
		return;
	}

	if( IsTradeContextBusy() )
	{
	   g_lastStatusID = STATUS_TRADE_CONTEXT_BUSY;
	   
	   if ((TimeCurrent()- g_lastErrorPrintTime) > ERROR_TIME_BUFFER) 
		{
		Print( "openBuyOrder: trade context is busy." );
		g_lastErrorPrintTime = TimeCurrent();
		}
		return;
	}
	
	checkMinTradeSize() ;
	
	if( STATUS_BELOW_MIN_LOT_SIZE == g_lastStatusID )
	{
	   if ((TimeCurrent()- g_lastErrorPrintTime) > ERROR_TIME_BUFFER) 
		{
		Print( "openBuyOrder: lot size below minimum broker size on entry signal." );
		g_lastErrorPrintTime = TimeCurrent();
		}
		return;
	}

	double tradeOpenPrice = NormalizeDouble( Ask, g_brokerDigits );

	// Support ECN brokerage
	int tradeTicket = OrderSend(
									g_symbol,
									OP_BUY,
									g_tradeSize,
									tradeOpenPrice,
									g_adjustedSlippage,
									0,
									0,
									TRADE_COMMENT,
									INSTANCE_ID,
									0,
									BUY_COLOR
							  		   );
	if( -1 == tradeTicket )
	{
		logOrderSendInfo(
						"openBuyOrder-OrderSend: ",
						g_tradeSize,
						tradeOpenPrice,
						g_adjustedSlippage,
						0.0,
						0.0,
						GetLastError()
							 );
		return;
	}
	
	SetBuyOrderSLAndTP( tradeTicket, tradeOpenPrice );
	
	string orderGlobalString = StringConcatenate(INSTANCE_ID,  "_LAST_OP");
	string orderTimeGlobalString = StringConcatenate(INSTANCE_ID, "_LAST_OP_TIME");
	GlobalVariableSet(StringConcatenate(INSTANCE_ID,"_TRADE_MOD"), iTime(g_symbol, g_period, 0));
	GlobalVariableSet(orderGlobalString, tradeOpenPrice);
	GlobalVariableSet(orderTimeGlobalString, iTime(Symbol(),0,0));
	
}

void openSellOrder()
{
	if( ! IsTradeAllowed() )
	{
		g_lastStatusID = STATUS_TRADING_NOT_ALLOWED;
		
		if ((TimeCurrent()- g_lastErrorPrintTime) > ERROR_TIME_BUFFER) 
		{
		Print( "openSellOrder: Trading is not allowed." );
		g_lastErrorPrintTime = TimeCurrent();
		}
		
		return;
	}

	if( IsTradeContextBusy() )
	{
	   g_lastStatusID = STATUS_TRADE_CONTEXT_BUSY;
	   
	   if ((TimeCurrent()- g_lastErrorPrintTime) > ERROR_TIME_BUFFER) 
		{
		Print( "openSellOrder: trade context is busy." );
		g_lastErrorPrintTime = TimeCurrent();
		}
		return;
	}
	
	
	checkMinTradeSize() ;
	
	if( STATUS_BELOW_MIN_LOT_SIZE == g_lastStatusID )
	{
	   if ((TimeCurrent()- g_lastErrorPrintTime) > ERROR_TIME_BUFFER) 
		{
		Print( "openSellOrder: lot size below minimum broker size on entry signal." );
		g_lastErrorPrintTime = TimeCurrent();
		}
		return;
	}

	double tradeOpenPrice = NormalizeDouble( Bid, g_brokerDigits );
	

	// Support ECN brokerage
	int tradeTicket = OrderSend(
									g_symbol,
									OP_SELL,
									g_tradeSize,
									tradeOpenPrice,
									g_adjustedSlippage,
									0,
									0,
									TRADE_COMMENT,
									INSTANCE_ID,
									0,
									SELL_COLOR
							  		   );
	if( -1 == tradeTicket )
	{
		logOrderSendInfo(
						"openSellOrder-OrderSend: ",
						g_tradeSize,
						tradeOpenPrice,
						g_adjustedSlippage,
						0.0,
						0.0,
						GetLastError()
							 );
		return;
	}

	SetSellOrderSLAndTP( tradeTicket, tradeOpenPrice );
	
	string orderGlobalString = StringConcatenate(INSTANCE_ID,  "_LAST_OP");
	string orderTimeGlobalString = StringConcatenate(INSTANCE_ID, "_LAST_OP_TIME");
	GlobalVariableSet(StringConcatenate(INSTANCE_ID,"_TRADE_MOD"), iTime(g_symbol, g_period, 0));
	GlobalVariableSet(orderGlobalString, tradeOpenPrice);
	GlobalVariableSet(orderTimeGlobalString, iTime(Symbol(),0,0));

}

void handleTrade()
{
	switch( OrderType() ) {
	case OP_BUY:
		handleBuyTrade();
	break;
	case OP_SELL:
		handleSellTrade();
	break;
								 } // switch( OrderType() )
}

void handleBuyTrade()
{

int tradeTicket = OrderTicket() ; 
string orderGlobalString = StringConcatenate(INSTANCE_ID, "_LAST_OP");
double tradeOpenPrice = GlobalVariableGet(orderGlobalString);
double stopLossPrice = OrderStopLoss() ;

//Remodify order if it wasn't adequately modified on entry
  
  if( (     OrderMagicNumber()   == INSTANCE_ID ) && 
		 ( MathAbs( stopLossPrice ) <  EPSILON    )
	  )
	{	 
		SetBuyOrderSLAndTP( tradeTicket, tradeOpenPrice );
	}
  
//Close trade if signal to close long is triggered 
  
	if( SIGNAL_CLOSE_BUY == g_tradingSignal ) 
	{
	  if(OrderMagicNumber() == INSTANCE_ID)
	  {
	  
		OrderClose( tradeTicket, OrderLots(), NormalizeDouble( Bid, g_brokerDigits ), g_adjustedSlippage, BUY_CLOSE_COLOR );
		logOrderCloseInfo(
						"handleBuyTrade: ",
						tradeTicket,
						GetLastError()
							  );
		}
	}
	
	if( SIGNAL_UPDATE_BUY == g_tradingSignal && TimeCurrent()-GlobalVariableGet(StringConcatenate(INSTANCE_ID,"_TRADE_MOD")) > g_period*60-1) 
	{
	  if(OrderMagicNumber() == INSTANCE_ID)
	  {
	  
	  	     if (SetBuyOrderSLAndTP( tradeTicket, Ask ))
		     {
            GlobalVariableSet(StringConcatenate(INSTANCE_ID,"_TRADE_MOD"), iTime(g_symbol, g_period, 0));
            GlobalVariableSet(orderGlobalString, Ask);
           }
		}
	}
	
}

void handleSellTrade()
{

int tradeTicket = OrderTicket();
string orderGlobalString = StringConcatenate(INSTANCE_ID, "_LAST_OP");
double tradeOpenPrice = GlobalVariableGet(orderGlobalString);
double stopLossPrice = OrderStopLoss() ;

// Update the order if it wasn't adequately modified on entry
	if( (     OrderMagicNumber()   == INSTANCE_ID ) && 
		 ( MathAbs( stopLossPrice ) <  EPSILON    )
	  )
	{
		SetSellOrderSLAndTP( tradeTicket, tradeOpenPrice );
	}


	// Close the trade if close long signal has been triggered

	if( SIGNAL_CLOSE_SELL == g_tradingSignal ) 
	{
	  if(OrderMagicNumber() == INSTANCE_ID)
	  {
	  
		OrderClose( tradeTicket, OrderLots(), NormalizeDouble( Ask, g_brokerDigits) , g_adjustedSlippage, SELL_CLOSE_COLOR );
		logOrderCloseInfo(
						"handleSellTrade: ",
						tradeTicket,
						GetLastError()
							  );
	  }
	}
	
	if( SIGNAL_UPDATE_SELL == g_tradingSignal && TimeCurrent()-GlobalVariableGet(StringConcatenate(INSTANCE_ID,"_TRADE_MOD")) > g_period*60-1) 
	{
	  if(OrderMagicNumber() == INSTANCE_ID)
	  {
	  
		   if (SetSellOrderSLAndTP( tradeTicket, Bid))
		   {
            GlobalVariableSet(StringConcatenate(INSTANCE_ID,"_TRADE_MOD"), iTime(g_symbol, g_period, 0));
            GlobalVariableSet(orderGlobalString, Bid);
         }
		}
	}

}

int checkTradingSignal()
{
	int pattern_status = detectPattern(),
		 signal = SIGNAL_NONE;

	switch( pattern_status ) {
	case PATTERN_NONE:
	break;
	case LONG_ENTRY_PATTERN:
	   if (queryOrdersCount(QUERY_ALL) == 0)
		signal = SIGNAL_ENTER_BUY;
	   if (queryOrdersCount(OP_BUY) > 0)
		signal = SIGNAL_UPDATE_BUY;
		if (queryOrdersCount(OP_SELL) > 0)
		signal = SIGNAL_CLOSE_SELL;
	break;
	case SHORT_ENTRY_PATTERN:
		if (queryOrdersCount(QUERY_ALL) == 0)
		signal = SIGNAL_ENTER_SELL;
	   if (queryOrdersCount(OP_SELL) > 0)
		signal = SIGNAL_UPDATE_SELL;
		if (queryOrdersCount(OP_BUY) > 0)
		signal = SIGNAL_CLOSE_BUY;
	break;
	case LONG_EXIT_PATTERN:
		signal = SIGNAL_CLOSE_BUY;
	break;
	case SHORT_EXIT_PATTERN:
		signal = SIGNAL_CLOSE_SELL;
	break;

							} // switch( pattern )
	return (signal);
}

int detectPattern()
{

//insertDayFilter
	
//insertHourFilter

	if(queryOrdersCount(OP_BUY) > 0 ){
 
   int pattern_status_ID = detectLongExitPattern();
	if( PATTERN_NONE != pattern_status_ID )
		return (pattern_status_ID);
		}
 
   if(queryOrdersCount(OP_SELL) > 0 ){
   
	pattern_status_ID = detectShortExitPattern();
	if( PATTERN_NONE != pattern_status_ID )
		return (pattern_status_ID);
		}

	pattern_status_ID = detectLongEntryPattern();
	if( PATTERN_NONE != pattern_status_ID )
		return (pattern_status_ID);

	pattern_status_ID = detectShortEntryPattern();
	if( PATTERN_NONE != pattern_status_ID )
		return (pattern_status_ID);
		
	return (PATTERN_NONE);		
}

int detectLongEntryPattern()
{

   int longEntryPattern = PATTERN_NONE;

    if (
//insertLongEntryLogic
       )
       longEntryPattern = LONG_ENTRY_PATTERN;

   return(longEntryPattern);
}

int detectShortEntryPattern()
{
int shortEntryPattern = PATTERN_NONE;

    if (
//insertShortEntryLogic
       )
       shortEntryPattern = SHORT_ENTRY_PATTERN;

return(shortEntryPattern);
}

int detectLongExitPattern()
{
int longExitPattern = (PATTERN_NONE);

//noExitPatternInsertReturn

}

int detectShortExitPattern()
{
int shortExitPattern = (PATTERN_NONE);

//noExitPatternInsertReturn

}

void calculateATR()
{
	// Use the current ATR value, taking
	// into account sunday candle existence.
	
	double currentHigh, currentLow, previousClose, trueRange, sumTrueRange = 0;
	g_ATR = 0;
	
	if(g_period == 1440)
	{
     for (int i= 0; i < ATR_PERIOD; i++)
     {
        currentHigh   =  High[i+1];
        currentLow    =  Low[i+1];
        previousClose =  Close[i+2];
        trueRange = MathMax( (currentHigh-currentLow), MathMax(MathAbs(currentLow-previousClose), MathAbs(currentHigh-previousClose)));
        sumTrueRange += trueRange;
     }

     g_ATR = sumTrueRange/ATR_PERIOD ;
	 } else {
	 
	 for (i=0; i< ATR_PERIOD; i++)
	{
	    int currentHighIndex = MathRound(((1440/2)/g_period)*i+(1440/g_period));
	    int currentLowIndex = MathRound(((1440/2)/g_period)*i+1);
		currentHigh  =  High[currentHighIndex];
		currentLow  =   Low[currentLowIndex];

		g_ATR += MathAbs(currentHigh-currentLow)/ATR_PERIOD;
	}
	 
	 
	 }
	 
	if( MathAbs( g_ATR ) < EPSILON )
	{
		g_lastStatusID = STATUS_DIVIDE_BY_ZERO;
		return;
	}

	// The ATR is 0.0001 when initialization failure occurs.
	// See the EA setup video (26.09.10) for more details.
	if( ( MathAbs( g_ATR ) - 0.0001 ) < EPSILON )
	{
		g_lastStatusID = STATUS_ATR_INIT_PROBLEM;
		return;
	}
	
}

void calculateContractSize()
{
	g_contractSize = MarketInfo( Symbol(),  MODE_LOTSIZE );
}


void calculateTradeSize()
{
	double atrForCalculation = g_ATR;
	if( isInstrumentJPY() )
		atrForCalculation /= 100;

      if (STOP_LOSS != 0) 
		g_tradeSize = ( RISK * 0.01 * AccountBalance() ) / ( g_contractSize * STOP_LOSS * atrForCalculation );

      if (STOP_LOSS == 0) 
		g_tradeSize = ( RISK * 0.01 * AccountBalance() ) / ( g_contractSize * 2 * atrForCalculation );
		
		if(DISABLE_COMPOUNDING && STOP_LOSS != 0)
		g_tradeSize = ( RISK * 0.01 * g_initialBalance ) / ( g_contractSize * STOP_LOSS * atrForCalculation );
		
		if(DISABLE_COMPOUNDING && STOP_LOSS == 0)
		g_tradeSize = ( RISK * 0.01 * g_initialBalance ) / ( g_contractSize * 2 * atrForCalculation );


	if( g_tradeSize > g_maxTradeSize )
		g_tradeSize = g_maxTradeSize;
	
	g_tradeSize = roundDouble(g_tradeSize);
	
}

void checkMinTradeSize()
{

	if (g_tradeSize < g_minTradeSize)
	{
	g_lastStatusID = STATUS_BELOW_MIN_LOT_SIZE ; 
	}

}

double calculateStopLossPrice( int orderType, double openPrice )
{
	double price = 0;
	switch( orderType ) {
	case OP_BUY:
		price = openPrice - pipsToPrice( g_stopLossPIPs );
	break;
	case OP_SELL:
		price = openPrice + pipsToPrice( g_stopLossPIPs );
	break;
							  } // switch( orderType )

	price = NormalizeDouble( price, g_brokerDigits );
	
	if ( g_stopLossPIPs == 0 )
	return(0);

	return (price);
}

double calculateTakeProfitPrice( int orderType, double openPrice )
{
	double price = 0.0;

	switch( orderType ) {
	case OP_BUY:
		price = openPrice + pipsToPrice( g_takeProfitPIPs );
	break;
	case OP_SELL:
		price = openPrice - pipsToPrice( g_takeProfitPIPs );
	break;
							  } // switch( orderType )

	price = NormalizeDouble( price, g_brokerDigits );
	
	if ( g_takeProfitPIPs == 0 )
	return(0);

	return (price);
}

void calculateSpreadPIPS()
{
	g_spreadPIPs = MathAbs(Ask-Bid)*100 ;
	
	if( ( 5 == g_brokerDigits ) ||
		 ( 4 == g_brokerDigits )
	  )
	{
		g_spreadPIPs *= 100;
	}
	
}

void calculateStopLossPIPs()
{
	g_stopLossPIPs = 10000 * STOP_LOSS * g_ATR;
	if( g_stopLossPIPs < g_minimalStopPIPs )
	{
		g_stopLossPIPs = g_minimalStopPIPs;
	}
	
	if( isInstrumentJPY() )
	{
		g_stopLossPIPs /= 100;
	}
}

void adjustSlippage() 
{
   g_adjustedSlippage = SLIPPAGE;
   
   // Support 5 digit brokers
   if( ( 3 == g_brokerDigits ) ||
       ( 5 == g_brokerDigits )
     )
   {
      g_adjustedSlippage *= 10;
   }

}

void calculateTakeProfitPIPs()
{
	g_takeProfitPIPs = 10000 * TAKE_PROFIT * g_ATR;
	if( isInstrumentJPY() )
	{
		g_takeProfitPIPs /= 100;
	}
}

double pipsToPrice( double pips )
{
	double calculationPIPs = pips;
	
	// Support 5 digit brokers
	if( ( 3 == g_brokerDigits ) ||
		 ( 5 == g_brokerDigits )
	  )
	{
		calculationPIPs *= 10;
	}

	return (calculationPIPs * g_pipValue);
}

bool isInstrumentJPY()
{
	int found = StringFind( Symbol(), "JPY", 0 );
	if( found == -1 )
		return (false);

	return (true);
}

int queryOrdersCount( int orderType ) 
{
// The query function is used for counting particular sets of orders
// for different purposes. It allows us to calculate amount of open longs,
// shorts or pending orders. It also allows to retrieve the amount of all
// the orders, opened by the expert by calling it with the QUERY_ALL argument.
	int query = QUERY_NONE,
		 ordersCount = 0;

	switch( orderType ) {
	case OP_BUY:
		query = QUERY_LONGS_COUNT;
	break;
	case OP_SELL:
		query = QUERY_SHORTS_COUNT;
	break;
	case OP_BUYSTOP:
		query = QUERY_BUY_STOP_COUNT;
	break;
	case OP_SELLSTOP:
		query = QUERY_SELL_STOP_COUNT;
	break;
	case OP_SELLLIMIT:
		query = QUERY_SELL_LIMIT_COUNT;
	break;
	case OP_BUYLIMIT:
		query = QUERY_BUY_LIMIT_COUNT;
	break;
	case QUERY_ALL:
		// A case to count all orders
		query = QUERY_ALL ;
	break;
							  } // switch( orderType )

	int total = OrdersTotal() ;
	for ( int i = 0 ; i < total+1; i++) 
	{
		 if (!OrderSelect( i, SELECT_BY_POS, MODE_TRADES )) continue;
		
		if( (        OrderType() ==  OP_SELL   ) &&
			 ( OrderMagicNumber() == INSTANCE_ID ) &&
			 ( ( QUERY_SHORTS_COUNT == query ) || ( query == QUERY_ALL ) )
		  )
		{
			ordersCount++;
		}

		if( (       OrderType() ==   OP_BUY   ) &&
			 ( OrderMagicNumber()== INSTANCE_ID ) &&
			 ( ( query == QUERY_LONGS_COUNT ) || ( query == QUERY_ALL ) )	
		  )
		{
			ordersCount++;
		}

		if( (       OrderType() == OP_SELLSTOP ) &&
			 ( OrderMagicNumber()==  INSTANCE_ID ) &&
			 ( ( query == QUERY_SELL_STOP_COUNT ) || ( query == QUERY_ALL ) )	
		  )
		{
			ordersCount++;
		}

		if( (       OrderType() == OP_BUYSTOP ) &&
			 ( OrderMagicNumber()== INSTANCE_ID ) &&
			 ( ( query == QUERY_BUY_STOP_COUNT ) || ( query == QUERY_ALL ) )	
		  )
		{
			ordersCount++;
		}

		if( (       OrderType() == OP_SELLLIMIT ) &&
			 ( OrderMagicNumber()== INSTANCE_ID   ) &&
			 ( ( query == QUERY_SELL_LIMIT_COUNT ) || ( query == QUERY_ALL ) )	
		  )
		{
			ordersCount++;
		}

		if( (       OrderType()  == OP_BUYLIMIT ) &&
			 ( OrderMagicNumber() == INSTANCE_ID  ) &&
			 ( ( query == QUERY_BUY_LIMIT_COUNT ) || ( query == QUERY_ALL ) )	
		  )
		{
      	ordersCount++;
		}
	}

	return(ordersCount);
}

double roundDouble( double value  )
{
	double roundedValue = 0.0;
	int roundingDigits = 0;

	double minimal_lot_step = MarketInfo(Symbol(), MODE_LOTSTEP) ;
	
	 
	if (minimal_lot_step == 0.01)
		roundedValue = NormalizeDouble( value, 2 );
	if (minimal_lot_step == 0.05)
		roundedValue = NormalizeDouble( MathFloor(value * 20 + 0.5) / 20, 2 );
	if (minimal_lot_step == 0.1)
		roundedValue = NormalizeDouble( value, 1 );
									 									  	
	return (roundedValue);
}

void calculateInstanceBalance()
{

   g_instanceBalance = g_initialBalance;
   g_instancePL_UI = 0 ;
	
	int closedOrdersCount =  OrdersHistoryTotal();
	
	for( int i = 0; i < closedOrdersCount; i++ )
	{
		OrderSelect( i, SELECT_BY_POS, MODE_HISTORY );
	
		if( OrderMagicNumber() == INSTANCE_ID  )	
		{
			g_instanceBalance += OrderProfit() + OrderSwap() ;
			g_instancePL_UI += OrderProfit() + OrderSwap() ;
		}
		
   }
   
}


int initUI()
{
	// Displayed in the main chart window
	ObjectCreate( g_objGeneralInfo,OBJ_LABEL, 0, 0, 0 );
	ObjectCreate( g_objTradeSize,  OBJ_LABEL, 0, 0, 0 );
	ObjectCreate( g_objStopLoss,   OBJ_LABEL, 0, 0, 0 );
	ObjectCreate( g_objTakeProfit, OBJ_LABEL, 0, 0, 0 );
	ObjectCreate( g_objATR,        OBJ_LABEL, 0, 0, 0 );
	ObjectCreate( g_objPL,         OBJ_LABEL, 0, 0, 0 );
	ObjectCreate( g_objBalance,           OBJ_LABEL, 0, 0, 0 );
	ObjectCreate( g_objStatusPane, OBJ_LABEL, 0, 0, 0 );


	// Bind to top left corner
	ObjectSet( g_objGeneralInfo,OBJPROP_CORNER, 0 );
	ObjectSet( g_objTradeSize,  OBJPROP_CORNER, 0 );
	ObjectSet( g_objBalance,           OBJPROP_CORNER, 0 );
	ObjectSet( g_objStopLoss,   OBJPROP_CORNER, 0 );
	ObjectSet( g_objTakeProfit, OBJPROP_CORNER, 0 );
   ObjectSet( g_objATR,        OBJPROP_CORNER, 0 );
	ObjectSet( g_objPL,         OBJPROP_CORNER, 0 );


	// Bind to bottom left corner
	ObjectSet( g_objStatusPane, OBJPROP_CORNER, 2 );
	
	// Set X offset
	ObjectSet( g_objGeneralInfo,OBJPROP_XDISTANCE, g_baseXOffset );
	ObjectSet( g_objTradeSize,  OBJPROP_XDISTANCE, g_baseXOffset );
	ObjectSet( g_objStopLoss,   OBJPROP_XDISTANCE, g_baseXOffset );
	ObjectSet( g_objTakeProfit, OBJPROP_XDISTANCE, g_baseXOffset );
	ObjectSet( g_objBalance,           OBJPROP_XDISTANCE, g_baseXOffset );
	ObjectSet( g_objATR,        OBJPROP_XDISTANCE, g_baseXOffset );
	ObjectSet( g_objPL,         OBJPROP_XDISTANCE, g_baseXOffset );
	ObjectSet( g_objStatusPane, OBJPROP_XDISTANCE, g_baseXOffset );


	// Prepare patterns name table
	ArrayResize( g_detectedPatternNames, 6 );
	g_detectedPatternNames[ 0 ] = "Long entry pattern detected";
	g_detectedPatternNames[ 1 ] = "Short entry pattern detected";
	g_detectedPatternNames[ 2 ] = "Long exit pattern detected";
	g_detectedPatternNames[ 3 ] = "Short exit pattern detected";

	ArrayResize( g_statusMessages, 10);
	g_statusMessages[ STATUS_INVALID_BARS_COUNT ] = "Invalid bars count";
	g_statusMessages[ STATUS_INVALID_TIMEFRAME  ] = "Invalid timeframe, trading suspended";
	g_statusMessages[ STATUS_DIVIDE_BY_ZERO     ] = "ATR not initialized correctly (zero divide)";
   g_statusMessages[ STATUS_ATR_INIT_PROBLEM   ] = "ATR not initialized correctly";
   g_statusMessages[ STATUS_TRADE_CONTEXT_BUSY ] = "Trade context busy (server issue)";
   g_statusMessages[ STATUS_TRADING_NOT_ALLOWED] = "Trading not allowed (server issue)";
   g_statusMessages[ STATUS_DUPLICATE_ID       ] = "Trading Stopped, Duplicate ID" ;
   g_statusMessages[ STATUS_RUNNING_ON_DEFAULTS] = "Change to defaults, Instance IDs cannot be -1" ;
   g_statusMessages[ STATUS_BELOW_MIN_LOT_SIZE ] = "Lot size is below minimum (capital too low)" ;
   g_statusMessages[ STATUS_LIBS_NOT_ALLOWED ]   = "Please allow external lib usage" ;
   g_statusMessages[ STATUS_NOT_ENOUGH_DATA ]   = "Not enough data present on chart" ;
	// Set severity status to default
	g_severityStatus = SEVERITY_INFO;

	return (0);
}

void updateUI()
{
	updateStatusUI( false );
	
	
	// General Info
	string text = "System created using Kantu, made by Daniel Fernandez, Asirikuy.com (C) 2013" ;
	ObjectSet( g_objGeneralInfo, OBJPROP_YDISTANCE, g_baseYOffset );
   ObjectSetText( g_objGeneralInfo, text, FontSize, g_fontName, INFORMATION_COLOR );

	// Trade size
	text = StringConcatenate( "Trade size: ", g_tradeSize );
	ObjectSet( g_objTradeSize, OBJPROP_YDISTANCE, g_baseYOffset + FontSize * g_textDensingFactor );
   ObjectSetText( g_objTradeSize, text, FontSize, g_fontName, INFORMATION_COLOR );

	// Stop loss
	text = StringConcatenate( "Stop loss: ", g_stopLossPIPs );
	ObjectSet( g_objStopLoss, OBJPROP_YDISTANCE, g_baseYOffset + FontSize * g_textDensingFactor*2 );
	ObjectSetText( g_objStopLoss, text, FontSize, g_fontName, INFORMATION_COLOR );

	// Take profit
	text = StringConcatenate( "Take profit: ", g_takeProfitPIPs );
	ObjectSet( g_objTakeProfit, OBJPROP_YDISTANCE, g_baseYOffset + FontSize * g_textDensingFactor * 3 );
	ObjectSetText( g_objTakeProfit, text, FontSize, g_fontName, INFORMATION_COLOR );
	
	// ATR
	text = StringConcatenate( "ATR: ", g_ATR );
	ObjectSet( g_objATR, OBJPROP_YDISTANCE, g_baseYOffset + FontSize * g_textDensingFactor * 4 );
	ObjectSetText( g_objATR, text, FontSize, g_fontName, INFORMATION_COLOR );
	
	// Profit/loss
	text = StringConcatenate( "Profit up until now is: ", g_instancePL_UI);
	ObjectSet( g_objPL, OBJPROP_YDISTANCE, g_baseYOffset + FontSize * g_textDensingFactor * 5 );
	ObjectSetText( g_objPL, text, FontSize, g_fontName, INFORMATION_COLOR );
	
	text = StringConcatenate( "Balance is: ", AccountBalance());
	ObjectSet( g_objBalance, OBJPROP_YDISTANCE, g_baseYOffset + FontSize * g_textDensingFactor * 6 );
	ObjectSetText( g_objBalance, text, FontSize, g_fontName, INFORMATION_COLOR );
	
   
	// Update the window content
	WindowRedraw();
}

void updateStatusUI( bool doRedraw )
{
	// The purpose of setting message to empty string
	// is to clean the screen from irrelevant info.
	string statusMessage = "";
	color clr = CLR_NONE;
	switch( g_severityStatus ) {
	case SEVERITY_INFO:
		clr = INFORMATION_COLOR;
		if ( g_lastDetectedPatternID >= 0 )
		statusMessage = g_detectedPatternNames[ g_lastDetectedPatternID ];
	break;
	case SEVERITY_ERROR:
		switch( g_lastStatusID ) {
		case STATUS_INVALID_BARS_COUNT:
		case STATUS_INVALID_TIMEFRAME:
			statusMessage = g_statusMessages[ g_lastStatusID ];
		break;
		case STATUS_LAST_ERROR:
			statusMessage = ErrorDescription( g_lastStatusID );
		break;
		case STATUS_ATR_INIT_PROBLEM  :
			statusMessage = g_statusMessages[ g_lastStatusID ];
			break;
		case STATUS_DIVIDE_BY_ZERO :
			statusMessage = g_statusMessages[ g_lastStatusID ];	
	    	break;
	    case STATUS_TRADE_CONTEXT_BUSY :
			statusMessage = g_statusMessages[ g_lastStatusID ];
			break;
		case STATUS_DUPLICATE_ID :
			statusMessage = g_statusMessages[ g_lastStatusID ];
			break;
		case STATUS_TRADING_NOT_ALLOWED :
			statusMessage = g_statusMessages[ g_lastStatusID ];
			break;
		case STATUS_RUNNING_ON_DEFAULTS :
			statusMessage = g_statusMessages[ g_lastStatusID ];
			break;
		case STATUS_BELOW_MIN_LOT_SIZE :
			statusMessage = g_statusMessages[ g_lastStatusID ];
			break;
		case STATUS_LIBS_NOT_ALLOWED :
			statusMessage = g_statusMessages[ g_lastStatusID ];
			break;
		case STATUS_NOT_ENOUGH_DATA :
			statusMessage = g_statusMessages[ g_lastStatusID ];
			break;
										 } // switch( g_lastStatusID )
										 
		if( g_lastError != statusMessage)
		{
		g_alertStatus = ALERT_STATUS_NEW ;
		}
	
		if(ALERT_STATUS_NEW == g_alertStatus)
		{
		
		Alert( statusMessage );
			
		g_alertStatus = ALERT_STATUS_DISPLAYED ;
		g_lastError = statusMessage ;
		}
		
		clr = ERROR_COLOR;
	break;
										} // switch( g_severityStatus )

	ObjectSet( g_objStatusPane, OBJPROP_YDISTANCE, g_baseYOffset );
   ObjectSetText( g_objStatusPane, statusMessage, FontSize * 1.2, g_fontName, clr );
   
   if( doRedraw )
   {
  		// Update the window content
		WindowRedraw();
	}
}

void deinitUI()
{
   ObjectDelete( g_objBalance );
   ObjectDelete( g_objGeneralInfo );
	ObjectDelete( g_objTradeSize );
	ObjectDelete( g_objStopLoss );
	ObjectDelete( g_objTakeProfit );
	ObjectDelete( g_objATR );
	ObjectDelete( g_objPL );
	ObjectDelete( g_objStatusPane );
}

void logOrderSendInfo(
               string commonInfo,
               double orderSize,
               double openPrice,
                  int slippage,
               double stopLoss,
               double takeProfit,
                  int errorCode
                     )
{
   string info = StringConcatenate(
                      commonInfo,
                      "instrument: ",   g_symbol,
                      " order size: ",  orderSize,
                      " open price: ",  openPrice,
                      " slippage: ",    slippage,
                      " stop loss: ",   stopLoss,
                      " take profit: ", takeProfit
                                  );
   Print( info );
   if( ERR_NO_ERROR == errorCode )
      return;
    
   Print( "Error info: ", errorCode, " description: ", ErrorDescription( errorCode ) );
}

void logOrderModifyInfo(
                 string commonInfo,
                    int tradeTicket,
                 double openPrice,
                 double stopLoss,
                 double takeProfit,
                    int errorCode
                       )
{
   string info = StringConcatenate(
                      commonInfo,
                      "instrument: ",   g_symbol,
                      " ticket: ",      tradeTicket,
                      " open price: ",  openPrice,
                      " stop loss: ",   stopLoss,
                      " take profit: ", takeProfit
                                  );
   Print( info );
   if( ERR_NO_ERROR == errorCode )
      return;
    
   Print( "Error info: ", errorCode, " description: ", ErrorDescription( errorCode ) );
}

void logOrderCloseInfo(
                 string commonInfo,
                    int orderTicket,
                    int errorCode
                       )
{
   string info = StringConcatenate(
                      commonInfo,
                      "instrument: ", g_symbol,
                      " ticket: ",    orderTicket
                                  );
   Print( info );
   if( ERR_NO_ERROR == errorCode )
      return;
    
   Print( "Error info: ", errorCode, " description: ", ErrorDescription( errorCode ) );
}



