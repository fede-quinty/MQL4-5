//+------------------------------------------------------------------+
//|                                              Forex Scanner 2.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#include <Controls\Button.mqh>

//Enumerazione per il tipo di condizione del segnale
enum condizione_segnali
  {
   rsi=0,// RSI
   ma=1,// Moving Average
  };

enum price_field
  {
   LH=0,// Low/High
   CC=1,// Close/Close
  };

input string ja="";//Forex Scanner
input condizione_segnali input_condition = 0; //Signal Condition

input string ba="";//RSI
input int RSI_period=14;
input ENUM_APPLIED_PRICE RSI_applied_price=0;

input string aa="";//Moving Average
input int MA_fast_period=20;
input int MA_fast_shift=0;
input ENUM_MA_METHOD MA_fast_method=0;
input ENUM_APPLIED_PRICE MA_fast_applied_price=0;
input int MA_slow_period=60;
input int MA_slow_shift=0;
input ENUM_MA_METHOD MA_slow_method=0;
input ENUM_APPLIED_PRICE MA_slow_applied_price=0;

input string la="";//Button Options
input int fontsize = 9; //Font_size

//Array di 28 stringhe che contiene i nostri 28 mercati Forex
string buttonNames[28] =
  {
   "AUDJPY","AUDUSD","AUDCAD","AUDCHF","AUDNZD","CADCHF","CADJPY","EURAUD","EURCAD","EURCHF","EURGBP",
   "EURJPY","EURUSD","EURNZD","GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPUSD","GBPNZD","CHFJPY","NZDJPY",
   "NZDUSD","NZDCAD","NZDCHF","USDCAD","USDCHF","USDJPY",
  };

//Creazione oggetti per le classi button e label
CButton B;
int BarsCount=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   Creazione_Pulsanti();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectsDeleteAll();
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
   ridimensionamento();

//Operatore Switch per il tipo di enumerazione (segnali) (int) selezionata
   if(Bars > BarsCount)
     {

      Csegnali signal;

      switch(input_condition)
        {
         case 0:
            signal.Rsi();
            break;

         case 1:
            signal.Incrocio_Medie();
            break;
        };

      BarsCount=Bars;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ridimensionamento()
  {


   int larghezza= 70;

   int altezza=30;

   double posizione_y_prima_fila=30;
   double posizione_x_prima_fila=25;

   double posizione_y_seconda_fila=30;
   double posizione_x_seconda_fila=95;

   double posizione_y_terza_fila=30;
   double posizione_x_terza_fila=165;

   double posizione_y_quarta_fila=30;
   double posizione_x_quarta_fila=235;

   for(int i=0; i<28; i++)
     {

      ObjectSet(buttonNames[i],OBJPROP_XSIZE,larghezza);
      ObjectSet(buttonNames[i],OBJPROP_YSIZE,altezza);
      ObjectSet(buttonNames[i],OBJPROP_FONTSIZE,fontsize);

      if(i < 7)
        {
         ObjectSet(buttonNames[i],OBJPROP_YDISTANCE,posizione_y_prima_fila);
         ObjectSet(buttonNames[i],OBJPROP_XDISTANCE,posizione_x_prima_fila);
         posizione_y_prima_fila+=altezza;
        }
      if(i >= 7 && i < 14)
        {
         ObjectSet(buttonNames[i],OBJPROP_YDISTANCE,posizione_y_seconda_fila);
         ObjectSet(buttonNames[i],OBJPROP_XDISTANCE,posizione_x_seconda_fila);
         posizione_y_seconda_fila+=altezza;
        }
      if(i >= 14 && i < 21)
        {
         ObjectSet(buttonNames[i],OBJPROP_YDISTANCE,posizione_y_terza_fila);
         ObjectSet(buttonNames[i],OBJPROP_XDISTANCE,posizione_x_terza_fila);
         posizione_y_terza_fila+=altezza;
        }
      if(i >= 21 && i < 28)
        {
         ObjectSet(buttonNames[i],OBJPROP_YDISTANCE,posizione_y_quarta_fila);
         ObjectSet(buttonNames[i],OBJPROP_XDISTANCE,posizione_x_quarta_fila);
         posizione_y_quarta_fila+=altezza;
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Creazione_Pulsanti()
  {

   for(int i=0; i<28; i++)
     {
      if(i < 7)
        {
         B.Create(0, buttonNames[i], 0, 0, 0, 0, 0);
         B.Text(buttonNames[i]);
         B.Locking(CORNER_LEFT_UPPER);
         B.ColorBackground(clrWhiteSmoke);
         B.ColorBorder(clrGray);
         B.Pressed(false);

        }

      if(i >= 7 && i < 14)
        {
         B.Create(0, buttonNames[i], 0, 0, 0, 0, 0);
         B.Text(buttonNames[i]);
         B.Locking(CORNER_LEFT_UPPER);
         B.ColorBackground(clrWhiteSmoke);
         B.ColorBorder(clrGray);
         B.Pressed(false);
        }

      if(i >= 14 && i < 21)
        {

         B.Create(0, buttonNames[i], 0, 0, 0, 0, 0);
         B.Text(buttonNames[i]);
         B.Locking(CORNER_LEFT_UPPER);
         B.ColorBackground(clrWhiteSmoke);
         B.ColorBorder(clrGray);
         B.Pressed(false);

        }
      if(i >= 21 && i < 28)
        {

         B.Create(0, buttonNames[i], 0, 0, 0, 0, 0);
         B.Text(buttonNames[i]);
         B.Locking(CORNER_LEFT_UPPER);
         B.ColorBackground(clrWhiteSmoke);
         B.ColorBorder(clrGray);
         B.Pressed(false);

        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // Event ID
                  const long& lparam,   // Parameter of type long event
                  const double& dparam, // Parameter of type double event
                  const string& sparam  // Parameter of type string events
                 )
  {
   if(id== CHARTEVENT_OBJECT_CLICK)
     {
      ChartSetSymbolPeriod(0,sparam,Period());
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Csegnali
  {

   //Inserisco le variabili per i miei metodi
protected:
   double            media_piccola_1,media_grande_1;
   double            media_piccola_2,media_grande_2;
   double            rsi;

public:

                     Csegnali()
     {
      media_piccola_1=0;
      media_piccola_2=0;
      media_grande_1=0;
      media_grande_2=0;
      rsi=0;

     };

                    ~Csegnali() {};

   //Metodi per i segnali

   void              Incrocio_Medie();
   void              Rsi();

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Csegnali::Incrocio_Medie()
  {
//Incrocio media lenta con media veloce
   for(int i=0; i<28; i++)
     {
      media_piccola_1=iMA(buttonNames[i],Period(),MA_fast_period,MA_fast_shift,MA_fast_method,MA_fast_applied_price,1);
      media_grande_1=iMA(buttonNames[i],Period(),MA_slow_period,MA_slow_shift,MA_slow_method,MA_slow_applied_price,1);
      media_piccola_2=iMA(buttonNames[i],Period(),MA_fast_period,MA_fast_shift,MA_fast_method,MA_fast_applied_price,2);
      media_grande_2=iMA(buttonNames[i],Period(),MA_slow_period,MA_slow_shift,MA_slow_method,MA_slow_applied_price,2);

      if(media_grande_1 > media_piccola_1 && media_grande_2 < media_piccola_2)
        {
         //Segnale sell = rosso
         ObjectSetInteger(0,buttonNames[i],OBJPROP_BGCOLOR,clrRed);
         Alert("Moving Average Sell Signal: ", buttonNames[i]);
        }
      else
         if(media_grande_1 < media_piccola_1 && media_grande_2 > media_piccola_2)
           {
            //Segnale buy = verde
            ObjectSetInteger(0,buttonNames[i],OBJPROP_BGCOLOR,clrGreen);
            Alert("Moving Average Buy Signal: ", buttonNames[i]);
           }
         else
            ObjectSetInteger(0,buttonNames[i],OBJPROP_BGCOLOR,clrWhiteSmoke);
     }
  }
//+------------------------------------------------------------------+
void Csegnali::Rsi(void)
  {
//Superamento livello 70 sell e 30 per un buy
   for(int i=0; i<28; i++)
     {
      rsi=iRSI(buttonNames[i],Period(),RSI_period,RSI_applied_price,1);

      //Sell signal
      if(rsi>=70)
        {
         ObjectSetInteger(0,buttonNames[i],OBJPROP_BGCOLOR,clrRed);
         Alert("Rsi Sell Signal: ", buttonNames[i]);

        }
      //Buy signal
      else
         if(rsi <=30)
           {
            ObjectSetInteger(0,buttonNames[i],OBJPROP_BGCOLOR,clrGreen);
            Alert("Rsi Buy Signal: ", buttonNames[i]);

           }
         else
            ObjectSetInteger(0,buttonNames[i],OBJPROP_BGCOLOR,clrWhiteSmoke);
     }
  }
