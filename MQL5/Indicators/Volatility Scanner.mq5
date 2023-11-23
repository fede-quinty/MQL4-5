//+------------------------------------------------------------------+
//|                                   Bitcoin Volatility Scanner.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.02"
#property indicator_chart_window


//Devo seguire le istruzioni di chat gpt
#include <Controls\Button.mqh>

CButton B;

input string ac="";//Volatility Scanner
input int DEV_Period =20;
input double DEV_Contr = 0.3;
input int Font_Size=9;

// Ho messo in un array tutti i timeframe
ENUM_TIMEFRAMES Timeframe[21] =
  {
   PERIOD_M1,PERIOD_M2,PERIOD_M3,PERIOD_M4,PERIOD_M5,
   PERIOD_M6,PERIOD_M10,PERIOD_M12,PERIOD_M15,PERIOD_M20,
   PERIOD_M30,PERIOD_H1,PERIOD_H2,PERIOD_H3,PERIOD_H4,PERIOD_H6,
   PERIOD_H8,PERIOD_H12,PERIOD_D1,PERIOD_W1,PERIOD_MN1
  };

string Testi_TF[21] =
  {
   "M1","M2","M3","M4","M5","M6","M10","M12","M15","M20","M30","H1","H2",
   "H3","H4","H6","H8","H12","D1","W1","MN1"
  };

//Faccio un array che contiene 21 atr handler per i 21 timeframes differenti
int DEV_Handler[21];
int BarsCount=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

// All'avvio dell'indicatore richiamo la creazione dei pulsanti
   creazione_pulsanti();


//Con questo ciclo assegno ad ogni contenitore dell'array handler il suo atr con il suo tf
   for(int i=0; i<21; i++)
     {

      //In questo array ho messo tutti i 21 handler dell'indicatore deviazione standard ai 21 timeframe differenti
      DEV_Handler[i]=iStdDev(Symbol(),Timeframe[i],DEV_Period,0,MODE_SMA,PRICE_CLOSE);

     }

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
//Vedo qual'è la reason (evento)
   if(reason == REASON_REMOVE)
     {
      ObjectsDeleteAll(0,-1);
     }

//--- The first way to get a deinitialization reason code
//    Print(__FUNCTION__," Deinitialization reason code = ",reason);

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

   contrazione();

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void creazione_pulsanti()
  {

//Metti sulla sinistra in alto 3 linee da 7 ciascuna
//Sono 21 pulsanti

   int larghezza = 50;
   int altezza = 25;

   int posizioney1=30;
   int posizionex1=15;

   int posizioney2=30;
   int posizionex2=65;

   int posizioney3=30;
   int posizionex3=115;

   for(int i=0; i<21; i++)
     {

      if(i<7)
        {
         B.Create(0,IntegerToString(Timeframe[i]),0,0,0,larghezza,altezza);
         B.Shift(posizionex1,posizioney1);
         B.Text(Testi_TF[i]);
         B.ColorBackground(clrWhiteSmoke);
         B.ColorBorder(clrGray);
         B.Pressed(false);
         B.FontSize(Font_Size);

         ObjectSetInteger(0,IntegerToString(Timeframe[i]), OBJPROP_CORNER, CORNER_LEFT_UPPER);

         posizioney1+= altezza;

        }
      if(i>=7 && i<14)
        {
         B.Create(0,IntegerToString(Timeframe[i]),0,0,0,larghezza,altezza);
         B.Shift(posizionex2,posizioney2);
         B.Text(Testi_TF[i]);
         B.ColorBackground(clrWhiteSmoke);
         B.ColorBorder(clrGray);
         B.Pressed(false);
         B.FontSize(Font_Size);

         ObjectSetInteger(0,IntegerToString(Timeframe[i]), OBJPROP_CORNER, CORNER_LEFT_UPPER);

         posizioney2+= altezza;
        }
      if(i>=14 && i<21)
        {
         B.Create(0,IntegerToString(Timeframe[i]),0,0,0,larghezza,altezza);
         B.Shift(posizionex3,posizioney3);
         B.Text(Testi_TF[i]);
         B.ColorBackground(clrWhiteSmoke);
         B.ColorBorder(clrGray);
         B.Pressed(false);
         B.FontSize(Font_Size);

         ObjectSetInteger(0,IntegerToString(Timeframe[i]), OBJPROP_CORNER, CORNER_LEFT_UPPER);

         posizioney3+=altezza;
        }
     }
  }
//+------------------------------------------------------------------+
void  OnChartEvent(const int       id,     // event ID
                   const long&     lparam, // long type event parameter
                   const double&   dparam, // double type event parameter
                   const string&   sparam) // string type event parameter
  {

// L'id dell'evento deve essere un click di un oggetto
   if(id == CHARTEVENT_OBJECT_CLICK)
     {

      // Convert the string sparam to an enumeration value
      ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES) sparam;

      // Set the symbol and period for the chart window using the enumeration value
      ChartSetSymbolPeriod(0,Symbol(),tf);

      //Devo settare a falso lo stato del pulsante cliccato
      ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void contrazione()
  {

//La mia teoria è che devo resettare il max1 e il max2 a fine ciclo del timeframe (quindi si resettano per 21 volte)
//Per poi ripartire da zero al ciclo del nuovo timeframe

   double max1=0;
   double max2=0;
   double max_2_perc=0;

   double dev[];

   ArraySetAsSeries(dev,true);

//Dentro al copybuffer devo richiamare l'array degli handler
//Che si deve aumentare di 1 ad ogni ciclo
   for(int a = 0; a<21; a++)
     {

      if(CopyBuffer(DEV_Handler[a],0,1,20,dev)>0)
        {
         for(int i=0; i<15; i++)
           {
            //Dalla 0 alla 4 = 5 candele, prendiamo il massimo dell'ATR
            if(i>=0 && i<5)
              {

               //Se il max1 è minore al valore atr a posizione 0 1 2 3 4
               if(max1<dev[i])

                  //Allora assegno questo valore alla variabile max1
                  max1=dev[i];
              }

            //Dalla 5 candela iniziamo il conteggio del secondo massimo
            if(i>=5 && i < 15)
              {
               //Stesso procedimento solo che con un'altra variabile
               if(max2<dev[i])
                  max2=dev[i];
              }
           }
        }
      //Prima di andare avanti al prossimo handler=Timeframe devo colorare il pulsante se c'è contrazione
      max_2_perc= max2*DEV_Contr;

      if((max2-max_2_perc)>max1)
        {
         ObjectSetInteger(0,IntegerToString(Timeframe[a]),OBJPROP_BGCOLOR,clrYellow);
        }
      else
         ObjectSetInteger(0,IntegerToString(Timeframe[a]),OBJPROP_BGCOLOR,clrWhiteSmoke);

      //A fine ciclo del timeframe vado a resettare le due variabili per il massimi
      max1=0;
      max2=0;
     }
  }
//+------------------------------------------------------------------+
//
bool Nuova_candela()
  {
// Se il numero delle barre a timeframe 1 minuto è superiore al numero delle barre di barscount
   if(Bars(Symbol(),PERIOD_M1) > BarsCount)
     {
      // Allora BarsCount è uguale al numero di barre
      BarsCount = Bars(Symbol(),PERIOD_M1);
      // Ritorni True
      return true;
     }
// Altrimenti ritorni falso
   else
      return false;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
