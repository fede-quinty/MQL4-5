//+------------------------------------------------------------------+
//|                                              Forex Scanner 2.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "2.05"
#property strict
#property indicator_chart_window

#include <Controls\Button.mqh>

//Enumerazione per il tipo di condizione del segnale
enum condizione_segnali
  {
   rsi=0,// RSI
   ma=1,// Moving Average
   st=2,// Stochastic
   macd=3,// MACD
   ichimoku=4,// Ichimoku
   band_ri=5,// Bands Riding
   band_re=6,// Bands Reversal
   squeeze=7,// Bands Squeeze
   cci=8,// CCI
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

input string ca="";//Stochastic
input int Kperiod=5;
input int Dperiod=3;
input int slowing=3;
input ENUM_MA_METHOD Stochastic_metod=0;
input price_field Stochastic_price_field=0;

input string da="";//MACD
input int fast_ema_period=12;
input int slow_ema_period=26;
input int signal_period=9;
input ENUM_APPLIED_PRICE MACD_applied_price=0;

input string ea="";//Ichimoku
input int tenkan_sen=9;
input int kijun_sen=26;
input int senkou_span=52;

input string fa="";//Bollinger Bands
input int Bands_period=20;
input double Bands_deviation=2.0;
input int Bands_shift=0;
input ENUM_APPLIED_PRICE Bands_applied_price=0;

input string ga="";//Squeeze
input int Std_period=20;
input int Std_shift=0;
input ENUM_MA_METHOD Std_method=0;
input ENUM_APPLIED_PRICE Std_applied_price=0;
input double Percentuale=0.3;//% Contraction

input string ha="";//CCI
input int CCI_period=12;
input ENUM_APPLIED_PRICE CCI_applied_price=0;

input string la="";//Button Options
input int fontsize = 9; //Font_size

//Array di 28 stringhe che contiene i nostri 28 mercati Forex
string buttonNames[28] =
  {
   "AUDJPY","AUDUSD","AUDCAD","AUDCHF","AUDNZD","CADCHF","CADJPY","EURAUD","EURCAD","EURCHF","EURGBP",
   "EURJPY","EURUSD","EURNZD","GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPUSD","GBPNZD","CHFJPY","NZDJPY",
   "NZDUSD","NZDCAD","NZDCHF","USDCAD","USDCHF","USDJPY",
  };

//CHFJPY apposto di NZDJPY
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

         case 2:
            signal.Stochastic();
            break;

         case 3:
            signal.Macd();
            break;

         case 4:
            signal.Ichimoku();
            break;

         case 5:
            signal.Bands_Riding();
            break;

         case 6:
            signal.Bands_Reversal();
            break;

         case 7:
            signal.Squeeze();
            break;

         case 8:
            signal.CCI();
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
   double            stoc;
   double            macd_isto_1,macd_signal_1;
   double            macd_isto_2,macd_signal_2;
   double            tenkan_1,tenkan_2,kijun_1,kijun_2,senkou_span_a_1,senkou_span_b_1;
   double            banda_up_1,banda_down_1;
   double            deviation,primo_massimo,secondo_massimo,contrazione;
   double            cci;

public:

                     Csegnali()
     {
      media_piccola_1=0;
      media_piccola_2=0;
      media_grande_1=0;
      media_grande_2=0;
      rsi=0;
      stoc=0;
      macd_isto_1=0;
      macd_isto_2=0;
      macd_signal_1=0;
      macd_signal_2=0;
      tenkan_1=0;
      tenkan_2=0;
      kijun_1=0;
      kijun_2=0;
      senkou_span_a_1=0;
      senkou_span_b_1=0;
      banda_up_1=0;
      banda_down_1=0;
      deviation=0;
      primo_massimo=0;
      secondo_massimo=0;
      contrazione=0;
      cci=0;
     };

                    ~Csegnali() {};

   //Metodi per i segnali

   void              Incrocio_Medie();
   void              Rsi();
   void              Stochastic();
   void              Macd();
   void              Ichimoku();
   void              Bands_Riding();
   void              Bands_Reversal();
   void              Squeeze();
   void              CCI();

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
//+------------------------------------------------------------------+
void Csegnali::Stochastic(void)
  {
// La linea main dello stocastico supera 80 per il sell e 20 per il buy
   for(int i=0; i<28; i++)
     {
      stoc=iStochastic(buttonNames[i],Period(),Kperiod,Dperiod,slowing,Stochastic_metod,(int)Stochastic_price_field,MODE_MAIN,1);

      //Sell signal
      if(stoc>=80)
        {
         ObjectSetInteger(0,buttonNames[i],OBJPROP_BGCOLOR,clrRed);
         Alert("Stochastic Sell Signal: ", buttonNames[i]);

        }
      //Buy signal
      else
         if(stoc <=20)
           {
            ObjectSetInteger(0,buttonNames[i],OBJPROP_BGCOLOR,clrGreen);
            Alert("Stochastic Buy Signal: ", buttonNames[i]);

           }
         else
            ObjectSetInteger(0,buttonNames[i],OBJPROP_BGCOLOR,clrWhiteSmoke);
     }
  }
//+------------------------------------------------------------------+
void Csegnali::Macd(void)
  {
// Cross Linea Segnale con istogramma sotto lo 0 è un buy (Istogramma maggiore a linea segnale)
// Cross Linea Segnale con istogramma sopra lo 0 è un sell (Istogramma minore a linea segnale)

   for(int i=0; i<28; i++)
     {
      macd_isto_1=iMACD(buttonNames[i],Period(),fast_ema_period,slow_ema_period,signal_period,MACD_applied_price,MODE_MAIN,1);
      macd_signal_1=iMACD(buttonNames[i],Period(),fast_ema_period,slow_ema_period,signal_period,MACD_applied_price,MODE_SIGNAL,1);
      macd_isto_2=iMACD(buttonNames[i],Period(),fast_ema_period,slow_ema_period,signal_period,MACD_applied_price,MODE_MAIN,2);
      macd_signal_2=iMACD(buttonNames[i],Period(),fast_ema_period,slow_ema_period,signal_period,MACD_applied_price,MODE_SIGNAL,2);

      if(macd_signal_1>macd_isto_1 && macd_signal_2 < macd_isto_2 && macd_isto_1 > 0)
        {
         //Segnale sell = rosso
         ObjectSetInteger(0,buttonNames[i],OBJPROP_BGCOLOR,clrRed);
         Alert("MACD Sell Signal: ", buttonNames[i]);

        }
      else
         if(macd_signal_1<macd_isto_1 && macd_signal_2 > macd_isto_2 && macd_isto_1 < 0)
           {
            //Segnale buy = verde
            ObjectSetInteger(0,buttonNames[i],OBJPROP_BGCOLOR,clrGreen);
            Alert("MACD Buy Signal: ", buttonNames[i]);

           }
         else
            ObjectSetInteger(0,buttonNames[i],OBJPROP_BGCOLOR,clrWhiteSmoke);
     }

  }
//+------------------------------------------------------------------+
void Csegnali::Ichimoku(void)
  {
//Incrocio tenkan e kijun (le due medie mobili dell'ichimoku
//Senkoun span a > alla b per buy
//Senkoun span a < alla b per sell

   for(int i=0; i<28; i++)
     {
      tenkan_1=iIchimoku(buttonNames[i],Period(),tenkan_sen,kijun_sen,senkou_span,MODE_TENKANSEN,1);
      tenkan_2=iIchimoku(buttonNames[i],Period(),tenkan_sen,kijun_sen,senkou_span,MODE_TENKANSEN,2);
      kijun_1=iIchimoku(buttonNames[i],Period(),tenkan_sen,kijun_sen,senkou_span,MODE_KIJUNSEN,1);
      kijun_2=iIchimoku(buttonNames[i],Period(),tenkan_sen,kijun_sen,senkou_span,MODE_KIJUNSEN,2);
      senkou_span_a_1=iIchimoku(buttonNames[i],Period(),tenkan_sen,kijun_sen,senkou_span,MODE_SENKOUSPANA,1);
      senkou_span_b_1=iIchimoku(buttonNames[i],Period(),tenkan_sen,kijun_sen,senkou_span,MODE_SENKOUSPANB,1);

      if(tenkan_1<kijun_1 && tenkan_2 > kijun_2 && senkou_span_a_1 < senkou_span_b_1)
        {
         //Segnale sell = rosso
         ObjectSetInteger(0,buttonNames[i],OBJPROP_BGCOLOR,clrRed);
         Alert("Ichimoku Sell Signal: ", buttonNames[i]);
        }
      else
         if(tenkan_1>kijun_1 && tenkan_2 < kijun_2 && senkou_span_a_1 > senkou_span_b_1)
           {
            //Segnale buy = verde
            ObjectSetInteger(0,buttonNames[i],OBJPROP_BGCOLOR,clrGreen);
            Alert("Ichimoku Buy Signal: ", buttonNames[i]);
           }
         else
            ObjectSetInteger(0,buttonNames[i],OBJPROP_BGCOLOR,clrWhiteSmoke);
     }
  }
//+------------------------------------------------------------------+
void Csegnali::Bands_Riding(void)
  {
//Candela precedente chiude sopra banda superiore (BUY) e sotto banda inferiore (SELL)

   for(int i=0; i<28; i++)
     {
      banda_down_1=iBands(buttonNames[i],Period(),Bands_period,Bands_deviation,Bands_shift,Bands_applied_price,MODE_LOWER,1);
      banda_up_1=iBands(buttonNames[i],Period(),Bands_period,Bands_deviation,Bands_shift,Bands_applied_price,MODE_UPPER,1);

      if(iClose(buttonNames[i],Period(),1)<banda_down_1)
        {
         //Segnale sell = rosso
         ObjectSetInteger(0,buttonNames[i],OBJPROP_BGCOLOR,clrRed);
         Alert("Band Riding Sell Signal: ", buttonNames[i]);

        }
      else
         if(iClose(buttonNames[i],Period(),1)>banda_up_1)
           {
            //Segnale buy = verde
            ObjectSetInteger(0,buttonNames[i],OBJPROP_BGCOLOR,clrGreen);
            Alert("Band Riding Buy Signal: ", buttonNames[i]);

           }
         else
            ObjectSetInteger(0,buttonNames[i],OBJPROP_BGCOLOR,clrWhiteSmoke);
     }
  }
//+------------------------------------------------------------------+
void Csegnali::Bands_Reversal(void)
  {
//Max precedente rompre banda superiore (SELL) e Min precedente rompe banda inferiore (BUY) ma chiude dentro le bande
   for(int i=0; i<28; i++)
     {
      banda_down_1=iBands(buttonNames[i],Period(),Bands_period,Bands_deviation,Bands_shift,Bands_applied_price,MODE_LOWER,1);
      banda_up_1=iBands(buttonNames[i],Period(),Bands_period,Bands_deviation,Bands_shift,Bands_applied_price,MODE_UPPER,1);

      if(iClose(buttonNames[i],Period(),1)<banda_up_1 && iHigh(buttonNames[i],Period(),1)>banda_up_1)
        {
         //Segnale sell = rosso
         ObjectSetInteger(0,buttonNames[i],OBJPROP_BGCOLOR,clrRed);
         Alert("Band Reversal Sell Signal: ", buttonNames[i]);

        }
      else
         if(iClose(buttonNames[i],Period(),1)>banda_down_1 && iLow(buttonNames[i],Period(),1)<banda_down_1)
           {
            //Segnale buy = verde
            ObjectSetInteger(0,buttonNames[i],OBJPROP_BGCOLOR,clrGreen);
            Alert("Band Reversal Buy Signal: ", buttonNames[i]);

           }
         else
            ObjectSetInteger(0,buttonNames[i],OBJPROP_BGCOLOR,clrWhiteSmoke);
     }
  }
//+------------------------------------------------------------------+
void Csegnali::Squeeze(void)
  {

//Contrazione di tot percentuale rispetto ad esplosione precedente di volatilità

//Un ciclo è per i simboli
   for(int z=0; z<28; z++)
     {

      //Un ciclo è per il calcolo di massimo_1 e massimo_2
      for(int f=1; f<30; f++)
        {
         deviation=iStdDev(buttonNames[z],Period(),Std_period,Std_shift,Std_method,Std_applied_price,f);

         //Calcoliamo il primo massimo di volatilità
         if(f <= 5)
           {
            if(deviation > primo_massimo)
               primo_massimo=deviation;
           }
         if(f >5)
           {
            if(deviation > secondo_massimo)
               secondo_massimo=deviation;
           }
        }

      //Il secondo massimo meno il suo 30%
      contrazione=secondo_massimo*Percentuale;

      //Se la contrazione è maggiore al primo massimo c'è una squezze
      if((secondo_massimo-contrazione)>primo_massimo)
        {
         ObjectSetInteger(0,buttonNames[z],OBJPROP_BGCOLOR,clrYellow);
         Alert("Squeeze Signal: ", buttonNames[z]);

        }
      else
         ObjectSetInteger(0,buttonNames[z],OBJPROP_BGCOLOR,clrWhiteSmoke);

      primo_massimo=0;
      secondo_massimo=0;
      contrazione=0;
      deviation=0;

     }
  }
//+------------------------------------------------------------------+
void Csegnali::CCI(void)
  {
//Sell se superiore a 100  e buy se minore a -100
   for(int i=0; i<28; i++)
     {
      cci=iCCI(buttonNames[i],Period(),CCI_period,CCI_applied_price,1);

      //Sell signal
      if(cci>=100)
        {
         ObjectSetInteger(0,buttonNames[i],OBJPROP_BGCOLOR,clrRed);
         Alert("CCI Sell Signal: ", buttonNames[i]);

        }
      //Buy signal
      else
         if(cci <=-100)
           {
            ObjectSetInteger(0,buttonNames[i],OBJPROP_BGCOLOR,clrGreen);
            Alert("CCI Buy Signal: ", buttonNames[i]);

           }
         else
            ObjectSetInteger(0,buttonNames[i],OBJPROP_BGCOLOR,clrWhiteSmoke);
     }

  }
//+------------------------------------------------------------------+
