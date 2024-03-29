//+------------------------------------------------------------------+
//|                                       Test Chiusure Parziali.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <My_Include_Classi.mqh>

extern int MagicNumber = 321;
extern double Lotti=0.01;
extern int Takeprofit=60;
extern int Stoploss=30;

string contatore_parziale_sell="",contatore_parziale_buy="";
int Parziale_sell=0,Parziale_buy=0;
double pips=0.0;
int ticketbuy=-1,ticketsell=-1;

CInfo info;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   pips= info.Pips();
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
   if(info.Nuova_Candela())
     {

      ChiudiParzialmente(20,MagicNumber);
      Print(Numero_Chiusure_Parziali_SELL(MagicNumber));

      if(info.Ci_Sono_Ordini(MagicNumber)==false)
        {
         invioordini();
        }
     }
  }
//+------------------------------------------------------------------+
void invioordini()
  {

   if(Close[1]>Close[2])
      ticketbuy=OrderSend(Symbol(),OP_BUY,Lotti,Ask,0,Ask-Stoploss*pips,Ask+Takeprofit*pips,"Invio BUY",MagicNumber,0,clrGreen);


   if(Close[1]<Close[2])
      ticketsell=OrderSend(Symbol(),OP_SELL,Lotti,Bid,0,Bid+Stoploss*pips,Bid-Takeprofit*pips,"Invio SELL",MagicNumber,0,clrRed);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//Ricordati che un operazione può rompere tutto se il tipo è integer ma il risultato
//Dell'operazione è un double

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChiudiParzialmente(double percentuale, int magic)
  {

   for(int i =0; i<OrdersTotal(); i++)
     {

      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         info.Print_Errore("Errore selezione ordine");

      //Quali info mi servono dell'ordine?

      if(OrderMagicNumber()==magic && OrderSymbol()==Symbol())
        {

         Print(OrderComment());

         double lotsToClose = OrderLots() * (percentuale / 100.0); // Convert percentage to floating-point

         if(!OrderClose(OrderTicket(),lotsToClose,OrderClosePrice(),0,clrMagenta))
            info.Print_Errore("Errore chiusura parziale");

        }
     }
  }
// Ritorna il numero di chiusure parziali dell'ordine BUY
int Numero_Chiusure_Parziali_BUY(int magic)
  {

   if(!OrderSelect(info.Ritorna_Ultimo_Ticket_Chiuso(magic),SELECT_BY_TICKET))
      Print("Errore Selezione Ordine: " + IntegerToString(GetLastError()));

   if(OrderType()== OP_BUY)
     {
      // Utilizziamo delle funzioni predefinite di mql4 per analizzare il commento dell'ordine chiuso
      // Se un ordine viene chiuso parzialmente, la parte chiusa dell'ordine avrà un commento particolare che implica il "from" numero ordine "to" numero ordine
      // Se l'ordine è un parziale e la variabile globale Parziale_buy = 0
      if(StringSubstr(OrderComment(),4) != "" && Order_Is_Partial_Profit()==true && Parziale_buy == 0)
        {
         // La variabile stringa contatore_parziale_buy assumerà il valore di questa stringa estratta dal commento dell'ordine chiuso
         contatore_parziale_buy = StringSubstr(OrderComment(),4);
         // E la variabile per contare quante volte l'ordine è stato chiuso parzialmente avrà 1 come valore
         Parziale_buy = 1;
        }
      // Se la variabile dove abbiamo memorizzato la stringa estratta dal commento dell'ordine chiuso parzialmente è diversa da quella dell'ultimo ordine chiuso
      // Vuol dire che c'è stata un altra chiusura parziale
      if(contatore_parziale_buy != StringSubstr(OrderComment(),4))
        {
         // La stringa contatore_parziale_buy assumerà il nuovo valore stringa
         contatore_parziale_buy = StringSubstr(OrderComment(),4);
         // La variabile per contare le chiusure parziale aumenterà di 1
         Parziale_buy++;
        }
      // Controlliamo se l'ordine ha chiuso in take o in stop
      if(OrderClosePrice()== OrderTakeProfit() || OrderClosePrice()== OrderStopLoss())
        {
         // Quindi azzeriamo il contatore delle chiusure parziali perchè l'ordine ha raggiunto il suo take/stop iniziali
         // DA NOTARE: Se non inserisci Take o Stop ad invio ordine c'è da modificare questo passaggio
         Parziale_buy= 0;
        }
     }
   return Parziale_buy;
  }

// Ritorna il numero di chiusure parziali dell'ordine SELL
int Numero_Chiusure_Parziali_SELL(int magic)
  {

   if(!OrderSelect(info.Ritorna_Ultimo_Ticket_Chiuso(magic),SELECT_BY_TICKET))
      Print("Errore Selezine Ordine: " + IntegerToString(GetLastError()));

   if(OrderType()== OP_SELL)
     {
      if(StringSubstr(OrderComment(),4) != "" && Order_Is_Partial_Profit()==true && Parziale_sell == 0)
        {
         contatore_parziale_sell = StringSubstr(OrderComment(),4);
         Parziale_sell = 1;
        }

      if(contatore_parziale_sell != StringSubstr(OrderComment(),4))
        {
         contatore_parziale_sell = StringSubstr(OrderComment(),4);
         Parziale_sell++;
        }

      if(OrderClosePrice()== OrderTakeProfit() || OrderClosePrice()== OrderStopLoss())
        {
         Parziale_sell= 0;
        }
     }
   return Parziale_sell;
  }

// Questa funzione che abbiamo richiamato nelle funzioni precedenti controlla se l'ordine selezionato è stato chiuso parzialmente
bool Order_Is_Partial_Profit()
  {
// Per vedere se un ordine è stato chiuso parzialmente dobbiamo analizzare il suo commento.
// Avrà queste due stringhe "from #" e "to #" sempre nella stessa posizione
   return StringSubstr(OrderComment(),0,6) == "from #" || StringSubstr(OrderComment(),0,4)== "to #";
  }
//+------------------------------------------------------------------+
