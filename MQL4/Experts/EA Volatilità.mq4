//+------------------------------------------------------------------+
//|                                                EA Volatilità.mq4 |
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

input int MagicNumber=342;
input TipoEntrata Entry = StopOrders; // Tipo Entrata
input double Lotti = 0.1;
input int PercentualeContrazione= 30;
input int NumeroOreExp =12; //Ore x Cancellazione
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
//---
   RisultatiGiornalieri();

   if(Ci_Sono_Ordini_Simbolo_Magic(MagicNumber) == false && contrazione(PercentualeContrazione)==true)
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
   if(Entry==0)
     {
      Chiudi_Su_Mediana(MagicNumber);
     }

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
      //Dalla 0 alla 4 = 5 candele, prendiamo il massimo deviazione standard
      if(i>=0 && i<5)
        {

         //Se il max1 è minore al valore deviazione standard a posizione 0 1 2 3 4
         if(max1<iStdDev(Symbol(),Period(),20,0,MODE_SMA,PRICE_CLOSE,i))
            //Allora assegno questo valore alla variabile max1
            max1=iStdDev(Symbol(),Period(),20,0,MODE_SMA,PRICE_CLOSE,i);
        }
      //Dalla 5 candela iniziamo il conteggio del secondo massimo
      if(i>=5)
        {
         //Stesso procedimento solo che con un'altra variabile
         if(max2<iStdDev(Symbol(),Period(),20,0,MODE_SMA,PRICE_CLOSE,i))
            max2=iStdDev(Symbol(),Period(),20,0,MODE_SMA,PRICE_CLOSE,i);
        }
     }
//Ora abbiamo il valore massimo della deviazione standard dalla 0 all 4 candela e il massimo dalla 5 alla 14 candela

//Non ci resta che confrontarli per vedere se max1 è minore a max2 di almeno una certa percentuale di max2

   double max_2_perc= max2 * (percentuale_contrazione/100.0);

   if(max1<(max2-max_2_perc))
      return true;

   else
      return false;

  }
//+------------------------------------------------------------------+
void InvioPendentiStop()
  {

// Define the expiration time in seconds (e.g., 1 hour)
   int expirationTime = 3600 * NumeroOreExp;

// Calculate the expiration time in MetaTrader's datetime format
   datetime expirationDateTime = TimeCurrent() + expirationTime;
   double bandasu = iBands(Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_UPPER,1);
   double bandagiu = iBands(Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_LOWER,1);
   double mediana = iBands(Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_MAIN,1);

   double range = NormalizeDouble(bandasu-mediana,Digits);

   double entratasellstop=NormalizeDouble(bandagiu-range,Digits);
   double entratabuystop=NormalizeDouble(bandasu+range,Digits);

   ticketbuy=OrderSend(Symbol(),OP_BUYSTOP,Lotti,entratabuystop,0,mediana,entratabuystop+range*2,"Inserito BUYSTOP",MagicNumber,expirationDateTime,clrGreen);
   if(ticketbuy < 0)
      Print("Errore invio BUYSTOP: " + IntegerToString(GetLastError()));

   ticketsell=OrderSend(Symbol(),OP_SELLSTOP,Lotti,entratasellstop,0,mediana,entratasellstop-range*2,"Inserito SELLSTOP",MagicNumber,expirationDateTime,clrRed);
   if(ticketsell < 0)
      Print("Errore invio SELLSTOP: " + IntegerToString(GetLastError()));
  }

// Chiudi quando l'operazione tocca la mediana
void Chiudi_Su_Mediana(int magic)
  {
   double mediana = iBands(Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_MAIN,0);

   for(int i = 0; i< OrdersTotal(); i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         Print("Errore selezione ordine:", IntegerToString(GetLastError()));

      if(OrderMagicNumber()== magic && OrderSymbol() == Symbol())
        {
         if(OrderType() == OP_SELL && Bid >= mediana)
           {
            Chiudi_Sell(0,0);
           }
         if(OrderType() == OP_BUY && Ask <= mediana)
           {
            Chiudi_Buy(0,0);
           }
        }
     }
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

   double bandasu = iBands(Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_UPPER,1);
   double bandagiu = iBands(Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_LOWER,1);
   double mediana = iBands(Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_MAIN,1);

   double range = NormalizeDouble(bandasu-mediana,Digits);

   ticketbuy=OrderSend(Symbol(),OP_BUYLIMIT,Lotti,bandagiu-range,0,mediana,bandagiu-range*4,"Inserito BUYLIMIT",MagicNumber,expirationDateTime,clrGreen);
   if(ticketbuy < 0)
      Print("Errore invio BUYLIMIT: " + IntegerToString(GetLastError()));

   ticketsell=OrderSend(Symbol(),OP_SELLLIMIT,Lotti,bandasu+range,0,mediana,bandasu+range*4,"Inserito SELLLIMIT",MagicNumber,expirationDateTime,clrRed);
   if(ticketsell < 0)
      Print("Errore invio SELLLIMIT: " + IntegerToString(GetLastError()));
  }
//+------------------------------------------------------------------+

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
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
// Chiudi Tot percentuale(0 = tutto) sell a tot candela (0 = ora)
void Chiudi_Sell(int percentuale,int candela_chiusura)
  {

   for(int i = 0; i<OrdersTotal(); i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         Print(" Error OrderSelect " + IntegerToString(GetLastError()));

      if(candela_chiusura == 0)
        {
         if(OrderType()== OP_SELL)
           {
            if(percentuale == 0)
              {
               if(!OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrRed))
                  Print(" Error OrderClose ", IntegerToString(GetLastError()));
              }
            else
               if(percentuale!= 0)
                 {
                  // Mi chiudi l'ordine solo della percentuale selezionata nella variabile d'ingresso utilizzando
                  // OrderLots()*percentuale/100
                  if(!OrderClose(OrderTicket(),OrderLots()*percentuale/100,OrderClosePrice(),0,clrRed))
                     Print(" Error OrderClose ", IntegerToString(GetLastError()));
                 }
           }
        }

      if(candela_chiusura!= 0 && OrderOpenTime() <= Time[candela_chiusura])
        {
         if(OrderType()== OP_SELL)
           {
            if(percentuale == 0)
              {
               if(!OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrRed))
                  Print(" Error OrderClose ", IntegerToString(GetLastError()));
              }
            else
               if(percentuale!= 0)
                 {
                  // Chiudi la percentuale di quell'ordine dopo tot candele dall'apertura dell'ordine sell
                  if(!OrderClose(OrderTicket(),OrderLots()*percentuale/100,OrderClosePrice(),0,clrRed))
                     Print(" Error OrderClose ", IntegerToString(GetLastError()));
                 }
           }
        }
     }
  }

// Chiudi Tot percentuale(0 = tutto) buy a tot candela (0 = ora)
void Chiudi_Buy(int percentuale, int candela_chiusura)
  {

   for(int i= 0; i<OrdersTotal(); i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         Print("Errore selezione ordine:", IntegerToString(GetLastError()));

      if(candela_chiusura == 0)
        {
         // Se è un BUY
         if(OrderType()== OP_BUY)
           {
            if(percentuale == 0)
              {
               if(!OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrRed))
                  Print(" Error OrderClose ", IntegerToString(GetLastError()));
              }

            else
               if(percentuale!= 0)
                 {
                  if(!OrderClose(OrderTicket(),OrderLots()*percentuale/100,OrderClosePrice(),0,clrRed))
                     Print(" Error OrderClose ", IntegerToString(GetLastError()));
                 }
           }
        }

      if(candela_chiusura != 0 && OrderOpenTime() <= Time[candela_chiusura])
        {
         if(OrderType()== OP_BUY)
           {
            if(percentuale == 0)
              {
               if(!OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrRed))
                  Print(" Error OrderClose ", IntegerToString(GetLastError()));
              }

            else
               if(percentuale!= 0)
                 {
                  if(!OrderClose(OrderTicket(),OrderLots()*percentuale/100,OrderClosePrice(),0,clrRed))
                     Print(" Error OrderClose ", IntegerToString(GetLastError()));
                 }
           }
        }
     }
  }
//+------------------------------------------------------------------+
