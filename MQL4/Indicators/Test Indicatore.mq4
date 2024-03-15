//+------------------------------------------------------------------+
//|                                              Test Indicatore.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 clrGreenYellow
#property indicator_width1 2

extern int Periodo = 20;

double bufferarray[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

   SetIndexBuffer(0,bufferarray);

//---

   return(INIT_SUCCEEDED);
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

   int uncalculatedBar = rates_total - prev_calculated;

   for(int i=uncalculatedBar; i >= 0 ; i--)
     {
     
      if(i < rates_total - Periodo)
        {
        // Qui si richiamano le funzioni che calcolano il valore
        // Ed i valori si assegnano ad i buffer
         bufferarray[i]=calcolaMedia(i,Periodo);
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
double calcolaMedia(int startIndex, double numCandles)
  {
   double somma = 0.0;

   for(int i = startIndex; i < startIndex + numCandles; i++)
     {
      somma += Close[i];
     }
   return somma / numCandles;
  }
//+------------------------------------------------------------------+
