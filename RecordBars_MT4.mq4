
#property copyright "Copyright 2012, Daniel Fernandez"
#property link      "mailto: ekans_@hotmail.com"

int handle;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
handle=FileOpen(StringConcatenate(Symbol(), "_", Period(), ".csv"), FILE_CSV|FILE_WRITE, ',');
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   FileClose(handle);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----

   if(handle>0)
    {
     FileWrite(handle,StringConcatenate(TimeDay(Time[1]), "/", TimeMonth(Time[1]), "/", TimeYear(Time[1]), " ", TimeHour(Time[1]), ":", TimeMinute(Time[1])), Open[1], High[1], Low[1], Close[1], Volume[1]);
    }
//----
   return(0);
  }
//+------------------------------------------------------------------+