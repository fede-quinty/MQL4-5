//+------------------------------------------------------------------+
//|                                    A simple Bitcoin Strategy.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>
#include <Trade/PositionInfo.mqh>
#include <MyInclude.mqh>

input group "Input EA";
input int MagicNumber = 421;
input double Lotti=0.01;
input group "Inputs Bollinger Bands";
input int MA_period=20;
input double _deviation = 2;
input group "Inputs ATR Indicator";
input int ATR_Period=14;
input int ins_contrazione=30;

//Si crea una variabile per contenere l'handler dell'indicatore
int Bollinger_bands = 0;

//Variabile per handler atr
int ATR_Handler = 0;

CTrade trade;
CPositionInfo pinfo;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

// Assegnamo l'handle dell'indicatore alla variabile creata globalmente
   Bollinger_bands = iBands(Symbol(),PERIOD_CURRENT,MA_period,0,_deviation,PRICE_CLOSE);

//Assegnamo l'handler dell'atr alla variabile handler
   ATR_Handler=iATR(Symbol(),PERIOD_CURRENT,ATR_Period);

   Calcolo_pips();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(!pinfo.SelectByMagic(Symbol(),MagicNumber))
     {
      invio_ordini();
     }
   if(Nuova_candela())
     {
      chiudi_banda_opposta();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void invio_ordini()
  {

   double range=0;
   double Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   double Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);

   range = NormalizeDouble(banda_giu(1)-banda_su(1),Digits());
   Print(DoubleToString(range,0));

   double Low_1= iLow(Symbol(),PERIOD_CURRENT,1);
   double Low_2= iLow(Symbol(),PERIOD_CURRENT,2);
   double Low_3= iLow(Symbol(),PERIOD_CURRENT,3);
   double Low_4= iLow(Symbol(),PERIOD_CURRENT,4);

   double High_1= iHigh(Symbol(),PERIOD_CURRENT,1);
   double High_2= iHigh(Symbol(),PERIOD_CURRENT,2);
   double High_3= iHigh(Symbol(),PERIOD_CURRENT,3);
   double High_4= iHigh(Symbol(),PERIOD_CURRENT,4);

   trade.SetExpertMagicNumber(MagicNumber);

//Contrazione di tot in percentuale + tocco di banda giu per buy e su per sell

//Se c'è una contrazione di un 30% allora esaminiamo se ci sono tocchi banda
   if(contrazione(ins_contrazione))
     {
      //Condizioni BUY
      if(Low_1 < banda_giu(1))
        {
         trade.Buy(Lotti,Symbol(),Bid,NULL,NULL,"Send BUY Position");
        }

      //Condizioni SELL
      if(High_1 > banda_su(1))
        {
         trade.Sell(Lotti,Symbol(),Ask,NULL,NULL,"Send SELL Position");
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void chiudi_banda_opposta()
  {
   for(int i = 0; i<PositionsTotal(); i++)
     {

      if(!PositionSelect(Symbol()))
         Print(GetLastError());

      long magic= PositionGetInteger(POSITION_MAGIC);
      long Type = PositionGetInteger(POSITION_TYPE);

      if(magic == MagicNumber)
        {

         // Se è un BUY
         if(Type == POSITION_TYPE_BUY && iHigh(Symbol(),PERIOD_CURRENT,1) >= banda_su(1))
           {

            if(!trade.PositionClose(Symbol(),-1))
               Print(GetLastError());
           }

         // Se è un SELL
         if(Type == POSITION_TYPE_SELL && iLow(Symbol(),PERIOD_CURRENT,1) <= banda_giu(1))
           {
            if(!trade.PositionClose(Symbol(),-1))
               Print(GetLastError());
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double banda_su(int posizione)
  {

   double _Bup[];

// Settare gli array come una serie dinamica
   ArraySetAsSeries(_Bup, true);

// Con la funzione CopyBuffer prendiamo i valori dell'indicatore(handle) e li copiamo dentro all'array dinamico
// CopyBuffer(indicator handle,indicator buffer number,start position,amount to copy,target array to copy)

   if(CopyBuffer(Bollinger_bands,1,0,20,_Bup) < 0)
     {
      Print("CopyBuffer Banda Su Error =",GetLastError());
     }

   return _Bup[posizione];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double banda_giu(int posizione)
  {

   double _Bdown[];

// Settare gli array come una serie dinamica
   ArraySetAsSeries(_Bdown, true);

// Con la funzione CopyBuffer prendiamo i valori dell'indicatore(handle) e li copiamo dentro all'array dinamico
// CopyBuffer(indicator handle,indicator buffer number,start position,amount to copy,target array to copy)

   if(CopyBuffer(Bollinger_bands,2,0,20,_Bdown) < 0)
     {
      Print("CopyBuffer Banda Giu Error =",GetLastError());
     }

   return _Bdown[posizione];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool contrazione(int percentuale_contrazione)
  {

//Massima volatilità dalla 5 alla 15
   double max2 = 0;
//Massima volatilità dalla 0 alla 5
   double max1 = 0;

//Un ciclo for di 5 candele dalla 0 alla 5
//Un ciclo for di 10 candele dalla 5 alla 15

   for(int i=0; i<15; i++)
     {
      //Dalla 0 alla 4 = 5 candele, prendiamo il massimo dell'ATR
      if(i>=0 && i<5)
        {
         //Se il max1 è minore al valore atr a posizione 0 1 2 3 4
         if(max1<ATR(i))
            //Allora assegno questo valore alla variabile max1
            max1=ATR(i);
        }
      //Dalla 5 candela iniziamo il conteggio del secondo massimo
      if(i>=5)
        {
         //Stesso procedimento solo che con un'altra variabile
         if(max2<ATR(i))
            max2=ATR(i);
        }
     }
//Ora abbiamo il valore massimo dell'atr dalla 0 all 4 candela e il massimo dalla 5 alla 14 candela

//Non ci resta che confrontarli per vedere se max1 è minore a max2 di almeno una certa percentuale di max2

   double max_2_perc=max2*(percentuale_contrazione/100);

   if(max1<(max2-max_2_perc))
      return true;

   else
      return false;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ATR(int posizione)
  {

   double atr[];

   ArraySetAsSeries(atr,true);;


   if(CopyBuffer(ATR_Handler,0,0,30,atr)<0)
     {

      Print("Errore nella creazione ATR " + IntegerToString(GetLastError()));

     }

   return atr[posizione];

  }
