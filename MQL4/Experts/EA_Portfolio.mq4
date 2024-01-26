//+------------------------------------------------------------------+
//|                                                    !EA_First.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <My_Include_Classi.mqh>

input int MagicNumber = 342;
//input int TakeMoltiplier = 2;
input double Lotti = 0.1;
input double Take = 100;
input double Stop = 50;
input int NumeroOreExp =12;
input int PipsEntry= 15;
input bool orderlimit=false;
input bool orderstop =true;

input string FileName= "Roger.csv";

int ticketbuy= 0;
int ticketsell= 0;

double pips = 0;
int contatore=0;


CInfo ObInfo;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

   if(Digits>=3)
      pips = Point()*10;

   else
      pips = Point();

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

   if(ObInfo.Nuova_Candela())
     {

      RisultatiGiornalieri();

     }

   if(ObInfo.Ci_Sono_Ordini_Simbolo_Magic(MagicNumber) == false)
     {

      if(orderlimit==true)
         InvioPendentiLimit();


      if(orderstop==true)
         InvioPendentiStop();

     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InvioPendentiStop()
  {

// Define the expiration time in seconds (e.g., 1 hour)
   int expirationTime = 3600 * NumeroOreExp;

// Calculate the expiration time in MetaTrader's datetime format
   datetime expirationDateTime = TimeCurrent() + expirationTime;

   double EntryLevelSellStop = Low_Min_Price(0,10) - PipsEntry*pips;
   double EntryLevelBuyStop = High_Max_Price(0,10) + PipsEntry*pips;

   ticketbuy=OrderSend(Symbol(),OP_BUYSTOP,Lotti,EntryLevelBuyStop,0,EntryLevelBuyStop-Stop*pips,EntryLevelBuyStop+Take*pips,"Inserito BUYSTOP",MagicNumber,expirationDateTime,clrGreen);

   ticketsell=OrderSend(Symbol(),OP_SELLSTOP,Lotti,EntryLevelSellStop,0,EntryLevelSellStop+Stop*pips,EntryLevelSellStop-Take*pips,"Inserito SELLSTOP",MagicNumber,expirationDateTime,clrRed);


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InvioPendentiLimit()
  {

// Define the expiration time in seconds (e.g., 1 hour)
   int expirationTime = 3600 * NumeroOreExp;

// Calculate the expiration time in MetaTrader's datetime format
   datetime expirationDateTime = TimeCurrent() + expirationTime;

   double EntryLevelSellLimit = High_Max_Price(0,24) + PipsEntry*pips;
   double EntryLevelBuyLimit = Low_Min_Price(0,24) - PipsEntry*pips;

   ticketbuy=OrderSend(Symbol(),OP_BUYLIMIT,Lotti,EntryLevelBuyLimit,0,EntryLevelBuyLimit-Stop*pips,EntryLevelBuyLimit+Take*pips,"Inserito BUYLIMIT",MagicNumber,expirationDateTime,clrGreen);

   ticketsell=OrderSend(Symbol(),OP_SELLLIMIT,Lotti,EntryLevelSellLimit,0,EntryLevelSellLimit+Stop*pips,EntryLevelSellLimit-Take*pips,"Inserito SELLLIMIT",MagicNumber,expirationDateTime,clrRed);

  }

// Ritorna massimo prezzo da candela a candela
double High_Max_Price(int partenza, int target)
  {

   double highestHigh = 0;

// Find the highest high among the last 'candele' candles
   for(int i = partenza; i < target; i++)
     {
      double high = iHigh(NULL, 0, i);
      if(high > highestHigh)
        {
         highestHigh = high;
        }
     }

   return highestHigh;
  }
//+------------------------------------------------------------------+

// Ritorna minimo prezzo da candela a candela
double Low_Min_Price(int partenza, int target)
  {

   double LowestLow = 100;

// Find the highest high among the last 'candele' candles
   for(int i = partenza; i < target; i++)
     {
      double low = iLow(NULL, 0, i);
      if(low < LowestLow)
        {
         LowestLow = low;
        }
     }

   return LowestLow;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteSignalToCSV(string stringadaprintare)
  {
// Open the file
   int handle = FileOpen(FileName, FILE_READ | FILE_WRITE | FILE_CSV);

   if(handle != INVALID_HANDLE)
     {
      // Move to the end of the file
      FileSeek(handle, 0, SEEK_END);

      // Write a new line
      FileWrite(handle, stringadaprintare);

      // Close the file
      FileClose(handle);
     }
   else
     {
      Print("Failed to open ", FileName, ". Error code = ", GetLastError());
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Ritorna_Profitto_Operazioni_Chiuse_Giornata()
  {
   int Ordini_Totali_Storia = OrdersHistoryTotal();
   double Total_profit =NULL;
   for(int j=0; j<Ordini_Totali_Storia; j++)
     {

      // Mi selezioni gli ordini chiusi
      if(!OrderSelect(j,SELECT_BY_POS,MODE_HISTORY))
         Print(IntegerToString(GetLastError()));

      datetime TodayTime = TimeCurrent()-TimeCurrent()%86400;

      // Se gli l'ordine chiuso selezionato è di oggi allora prendi il suo profitto o perdita
      if(OrderCloseTime() >= TodayTime)
        {
         // Se il simbolo dell'ordine chiuso è uguale al simbolo dove sta l'ea
         if(OrderMagicNumber()==MagicNumber && OrderSymbol()==Symbol())
            Total_profit+= OrderProfit() + OrderSwap() + OrderCommission();

        }

     }
   return (Total_profit);
  }
//+------------------------------------------------------------------+
void RisultatiGiornalieri()
  {
//Stringa che racchiude il profitto/perdita giornaliera
   string risultatogiornaliero = (string) Ritorna_Profitto_Operazioni_Chiuse_Giornata() ;

//Se il contatore è 0 come impostato globale e sono tra le 22 e le 23 mi printi su file la stringa di poco fa e aumenti contatore
   if(contatore==0 && Hour()>=22 && Hour()<=23)
     {

      WriteSignalToCSV(risultatogiornaliero);
      contatore++;

     }
//Se siamo tra l'1 e le 20 mi azzeri il contatore così che alle 22 23 puoi continuare la scrittura del file
   if(Hour()>= 1 && Hour()<= 20)
     {
      contatore=0;
     }
  }
//+------------------------------------------------------------------+
