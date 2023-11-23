//+------------------------------------------------------------------+
//|                                  Volatility Multi TF Scanner.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#include <Controls\Button.mqh>

CButton B;

extern int DEV_Period=20;
extern double DEV_Contrazione=0.3;

ENUM_TIMEFRAMES Timeframe[9]=
  {
   PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1
  };

string Testi_TF[9]=
  {
   "M1","M5","M15","M30","H1","H4","D1","W1","MN1"
  };

int BarsCount=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

   creazione_pulsanti();

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(reason== REASON_REMOVE)
     {

      ObjectsDeleteAll(0,-1);

     }
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
//Ad ogni nuovo minuto mi esegui la funzione di calcolo contrazione
   if(Nuova_Candela_m1())
      contrazione();

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
void creazione_pulsanti()
  {
   int posizioney=10;
   int posizionex=1300;

   for(int i=0; i<9; i++)
     {

      B.Create(0,IntegerToString(Timeframe[i]),0,0,0,50,30);
      B.Shift(posizionex,posizioney);
      B.Text(Testi_TF[i]);
      B.ColorBackground(clrWhiteSmoke);
      B.ColorBorder(clrGray);
      B.Pressed(false);
      B.FontSize(10);

      ObjectSetInteger(0,IntegerToString(Timeframe[i]),OBJPROP_CORNER,CORNER_RIGHT_UPPER);

      ObjectSetInteger(0,IntegerToString(Timeframe[i]),OBJPROP_XDISTANCE,60);

      posizioney=posizioney+35;

     }
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
  {

   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES) sparam;
      ChartSetSymbolPeriod(0,Symbol(),tf);
      ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void contrazione()
  {
   double max1=0;
   double max2=0;
   double max_2_perc=0;
   double dev=0;

   for(int a=0; a<9; a++)
     {
      for(int i=0; i<15; i++)
        {

         dev=iStdDev(Symbol(),Timeframe[a],DEV_Period,0,MODE_SMA,PRICE_CLOSE,i);

         if(i>=0&&i<5)
           {
            if(max1<dev)
               max1=dev;
           }
         if(i>=5 && i<15)
           {
            if(max2<dev)
               max2=dev;
           }
        }
      max_2_perc=NormalizeDouble(max2*DEV_Contrazione,Digits);

      if((max2-max_2_perc)>max1)
        {
         ObjectSetInteger(0,IntegerToString(Timeframe[a]),OBJPROP_BGCOLOR,clrYellow);
        }
      else
         ObjectSetInteger(0,IntegerToString(Timeframe[a]),OBJPROP_BGCOLOR,clrWhiteSmoke);

      max1=0;
      max2=0;

     }
  }
//+------------------------------------------------------------------+
bool Nuova_Candela_m1()
  {

   if(iBars(Symbol(),PERIOD_M1)>BarsCount)
     {
      BarsCount=iBars(Symbol(),PERIOD_M1);
      return true;
     }
   else
      return false;
  }
//+------------------------------------------------------------------+
