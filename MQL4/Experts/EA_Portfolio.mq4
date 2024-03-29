//+------------------------------------------------------------------+
//|                                                    !EA_First.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

enum TipoEntrata
  {

   StopOrders = 0,
   LimitOrders = 1,

  };

input int MagicNumber = 342; // Magic Number
input TipoEntrata Entry = StopOrders; // Tipo Entrata
input double Lotti = 0.1; // Lotti Fissi
input double Take = 100; // Take Profit
input double Stop = 50; // Stop Loss
input int NumeroOreExp =12; //Ore x Cancellazione
input bool orderlimit=false;// Pendenti Limit
input bool orderstop =true; // Pendenti Stop
input int DA = 8; // Trading Start Hour
input int A = 14; // Trading End Hour
input int CandeleM= 10; //Candele per Max/Min
input int OrarioXContatore =23;//Orario Azzeramento Contatore
input string FileName= "Roger.csv"; // Nome File Report


int ticketbuy= 0;
int ticketsell= 0;
double pips = 0;
int contatore=0;

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


   RisultatiGiornalieri();


   if(Ci_Sono_Ordini_Simbolo_Magic(MagicNumber) == false && Hour()>=DA && Hour()<= A)
     {
      switch(Entry)
        {

         case 0:
            InvioPendentiStop();
            break;

         case 1:
            InvioPendentiLimit();
            break;

        }
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

   double EntryLevelSellStop = NormalizeDouble(Low_Min_Price(0,CandeleM),Digits);
   double StopLevelSell= NormalizeDouble(EntryLevelSellStop + Stop*pips,Digits);
   double TakeLevelSell= NormalizeDouble(EntryLevelSellStop - Take*pips,Digits);

   double EntryLevelBuyStop = NormalizeDouble(High_Max_Price(0,CandeleM),Digits);
   double StopLevelBuy=NormalizeDouble(EntryLevelBuyStop - Stop*pips,Digits);
   double TakeLevelBuy=NormalizeDouble(EntryLevelBuyStop + Take*pips,Digits);

   ticketbuy=OrderSend(Symbol(),OP_BUYSTOP,Lotti,EntryLevelBuyStop,0,StopLevelBuy,TakeLevelBuy,"Inserito BUYSTOP",MagicNumber,expirationDateTime,clrGreen);
   if(ticketbuy < 0)
      Print("Errore invio BUYSTOP: " + IntegerToString(GetLastError()));

   ticketsell=OrderSend(Symbol(),OP_SELLSTOP,Lotti,EntryLevelSellStop,0,StopLevelSell,TakeLevelSell,"Inserito SELLSTOP",MagicNumber,expirationDateTime,clrRed);
   if(ticketsell < 0)
      Print("Errore invio SELLSTOP: " + IntegerToString(GetLastError()));
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

   double EntryLevelSellLimit = NormalizeDouble(High_Max_Price(0,CandeleM),Digits);
   double StopLevelSell = NormalizeDouble(EntryLevelSellLimit + Stop*pips,Digits);
   double TakeLevelSell = NormalizeDouble(EntryLevelSellLimit - Take*pips,Digits);

   double EntryLevelBuyLimit = NormalizeDouble(Low_Min_Price(0,CandeleM),Digits);
   double StopLevelBuy= NormalizeDouble(EntryLevelBuyLimit - Stop*pips,Digits);
   double TakeLevelBuy= NormalizeDouble(EntryLevelBuyLimit + Take*pips,Digits);

   ticketbuy=OrderSend(Symbol(),OP_BUYLIMIT,Lotti,EntryLevelBuyLimit,0,StopLevelBuy,TakeLevelBuy,"Inserito BUYLIMIT",MagicNumber,expirationDateTime,clrGreen);
   if(ticketbuy < 0)
      Print("Errore invio BUYLIMIT: " + IntegerToString(GetLastError()));

   ticketsell=OrderSend(Symbol(),OP_SELLLIMIT,Lotti,EntryLevelSellLimit,0,StopLevelSell,TakeLevelSell,"Inserito SELLLIMIT",MagicNumber,expirationDateTime,clrRed);
   if(ticketsell < 0)
      Print("Errore invio SELLLIMIT: " + IntegerToString(GetLastError()));
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

// Funzione che scrive in un file una stringa
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

// Funzione che ritorna il profitto/perdita giornaliere dell'ea
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

// Funzione che richiama le funzioni precedenti e scrive il file a fine giornata con contatore
void RisultatiGiornalieri()
  {
//Stringa che racchiude il profitto/perdita giornaliera
   string risultatogiornaliero = (string) Ritorna_Profitto_Operazioni_Chiuse_Giornata() ;

//Se il contatore è 0 come impostato globale e sono 23 mi printi su file la stringa di poco fa e aumenti contatore
   if(contatore==0 && Hour()==OrarioXContatore)
     {

      WriteSignalToCSV(risultatogiornaliero);
      contatore++;

     }
//Se siamo tra l'1 e le 20 mi azzeri il contatore così che alle 22 23 puoi continuare la scrittura del file
   if(contatore != 0 && Hour() != OrarioXContatore)
     {
      contatore=0;
     }
  }

// Questa funzione ritorna true se ci sono ordini aperti dal nostro EA
bool Ci_Sono_Ordini_Simbolo_Magic(int magic)
  {
   for(int i = 0 ; i < OrdersTotal() ; i++)
     {
      // Selezioniamo il numero dell'ordine in base alla posizione
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         // Pritiamo l'errore se c'è
         Print("Errore Selezine Ordine: " + IntegerToString(GetLastError()));
      // Se l'ordine selezionato ha il nostro simbolo e il nostro magic number
      if(OrderSymbol() == Symbol() && OrderMagicNumber()==magic)
         // Se si vuol dire che ci sono ordini aperti dal nostro expert sul grafico attuale
         return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
