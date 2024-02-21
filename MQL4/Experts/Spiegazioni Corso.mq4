//+------------------------------------------------------------------+
//|                                            Spiegazioni Corso.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

// Ctrl + rotellina mouse
// Ctlr + ;
// Ctrl + z per annullare un azione (tornarne indietro)
// Ctrl + f per cercare una parola nel codice

//Un enumerazione fatta per decidere che tipo di ordini vogliamo inserire
enum ENUM_Entrata
  {

   pendentistop=0,
   pendentilimit=1,
   mercato=2,

  };

//Un enumerazione per scegliere che tipo di MoneyManagement applicare
enum ENUM_MM
  {

   Fissi=0,
   Percentuale=1,
   Denaro=2,

  };


extern int Magic_Number=321;
extern ENUM_Entrata TipoEntrata = pendentistop;
extern ENUM_MM Lottaggio = Fissi;
extern double Lotti=0.01;
extern int StopLoss = 30;
extern int TakeProfit = 60;
extern int EntrataPips = 30;
extern double RischioPercentuale = 2;
extern int RischioDenaro = 20;
extern int PeriodoSupertrend = 10;
extern int PeriodoMedia= 50;
extern double MoltiplicatoreSupertrend =3;
extern int OreCancellazione= 4;

int BarsCount=0;
double TickValue = 0,TickSize=0;
double ticketbuy=-1,ticketsell=-1;
double LivelloEntrataSell=0,LivelloEntrataBuy=0;
double LivelloStopSell=0,LivelloStopBuy=0;
double LivelloTakeSell=0,LivelloTakeBuy=0;
bool condizionebuy=0,condizionesell=0;
double pips=0, RangeStop=0;
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

//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

   if(Bars > BarsCount)
     {

      if(Ci_Sono_Ordini_Simbolo_Magic(Magic_Number)==False)
        {

         InvioOrdini();

        }

      BarsCount=Bars;
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
//|                                                                  |
//+------------------------------------------------------------------+
void InvioOrdini()
  {

// Define the expiration time in seconds (e.g., 1 hour)
   int expirationTime = 3600 * OreCancellazione;

// Calculate the expiration time in MetaTrader's datetime format
   datetime ExpirationDateTime = TimeCurrent() + expirationTime;

// Richiamiamo due valori dell'indicatore supertrend
   double super_trend_verde1= iCustom(Symbol(),Period(),"super-trend",PeriodoSupertrend,MoltiplicatoreSupertrend,0,1);
   double super_trend_rosso1= iCustom(Symbol(),Period(),"super-trend",PeriodoSupertrend,MoltiplicatoreSupertrend,1,1);

   double mediamobile1 = iMA(Symbol(),Period(),PeriodoMedia,0,MODE_SMA,PRICE_CLOSE,1);

   condizionebuy= (super_trend_rosso1>100 && mediamobile1 < Low[1]);
   condizionesell= (super_trend_verde1>100 && mediamobile1 > High[1]);

//Enumerazione nella condizione switch per il tipo di entrata
   switch(TipoEntrata)
     {

      // caso 0 inseriamo pendenti stop
      case 0:
         if(condizionebuy)
           {
            LivelloEntrataBuy=NormalizeDouble(Bid+EntrataPips*pips,Digits);
            LivelloStopBuy=NormalizeDouble(LivelloEntrataBuy-StopLoss*pips,Digits);
            LivelloTakeBuy=NormalizeDouble(LivelloEntrataBuy+TakeProfit*pips,Digits);
            RangeStop=NormalizeDouble(LivelloEntrataBuy-LivelloStopBuy,Digits);
            Lotti = RitornoLotti(RangeStop/Point());

            ticketbuy=OrderSend(Symbol(),OP_BUYSTOP,Lotti,LivelloEntrataBuy,0,LivelloStopBuy,LivelloTakeBuy,"Invio BUYSTOP",Magic_Number,ExpirationDateTime,clrGreen);
            if(ticketbuy < 0)
               Print("Errore nell'invio del BUYSTOP: "+ IntegerToString(GetLastError()));
           }

         if(condizionesell)
           {
            LivelloEntrataSell=NormalizeDouble(Ask-EntrataPips*pips,Digits);
            LivelloStopSell=NormalizeDouble(LivelloEntrataSell+StopLoss*pips,Digits);
            LivelloTakeSell=NormalizeDouble(LivelloEntrataSell-TakeProfit*pips,Digits);
            RangeStop=NormalizeDouble(LivelloStopSell-LivelloEntrataSell,Digits);
            Lotti = RitornoLotti(RangeStop/Point());

            ticketsell=OrderSend(Symbol(),OP_SELLSTOP,Lotti,LivelloEntrataSell,0,LivelloStopSell,LivelloTakeSell,"Invio SELLSTOP",Magic_Number,ExpirationDateTime,clrRed);
            if(ticketsell<0)
               Print("Errore nell'invio del SELLSTOP: "+ IntegerToString(GetLastError()));
           }

         break;

      // caso 1 inseriamo pendenti limit
      case 1:
         if(condizionebuy)
           {
            LivelloEntrataBuy= NormalizeDouble(Bid-EntrataPips*pips,Digits);
            LivelloStopBuy=NormalizeDouble(LivelloEntrataBuy-StopLoss*pips,Digits);
            LivelloTakeBuy=NormalizeDouble(LivelloEntrataBuy+TakeProfit*pips,Digits);
            RangeStop=NormalizeDouble(LivelloEntrataBuy-LivelloStopBuy,Digits);
            Lotti = RitornoLotti(RangeStop/Point());

            ticketbuy=OrderSend(Symbol(),OP_BUYLIMIT,Lotti,LivelloEntrataBuy,0,LivelloStopBuy,LivelloTakeBuy,"Invio BUYSTOP",Magic_Number,ExpirationDateTime,clrGreen);
            if(ticketbuy < 0)
               Print("Errore nell'invio del BUYLIMIT: "+ IntegerToString(GetLastError()));
           }

         if(condizionesell)
           {
            LivelloEntrataSell=NormalizeDouble(Ask+EntrataPips*pips,Digits);
            LivelloStopSell=NormalizeDouble(LivelloEntrataSell+StopLoss*pips,Digits);
            LivelloTakeSell=NormalizeDouble(LivelloEntrataSell-TakeProfit*pips,Digits);
            RangeStop=NormalizeDouble(LivelloStopSell-LivelloEntrataSell,Digits);
            Lotti = RitornoLotti(RangeStop/Point());

            ticketsell=OrderSend(Symbol(),OP_SELLLIMIT,Lotti,LivelloEntrataSell,0,LivelloStopSell,LivelloTakeSell,"Invio SELLSTOP",Magic_Number,ExpirationDateTime,clrRed);
            if(ticketsell<0)
               Print("Errore nell'invio del SELLLIMIT: "+ IntegerToString(GetLastError()));
           }
         break;

      // caso 2 inseriamo ordini subito
      case 2:
         if(condizionebuy)
           {
            LivelloStopBuy=NormalizeDouble(Ask-StopLoss*pips,Digits);
            LivelloTakeBuy=NormalizeDouble(Ask+TakeProfit*pips,Digits);
            RangeStop=NormalizeDouble(Ask-LivelloStopBuy,Digits);
            Lotti = RitornoLotti(RangeStop/Point());

            ticketbuy=OrderSend(Symbol(),OP_BUY,Lotti,Ask,0,LivelloStopBuy,LivelloTakeBuy,"Invio BUYSTOP",Magic_Number,0,clrGreen);
            if(ticketbuy < 0)
               Print("Errore nell'invio del BUY: "+ IntegerToString(GetLastError()));
           }

         if(condizionesell)
           {

            LivelloStopSell=NormalizeDouble(Bid+StopLoss*pips,Digits);
            LivelloTakeSell=NormalizeDouble(Bid-TakeProfit*pips,Digits);
            RangeStop=NormalizeDouble(Bid-LivelloEntrataSell,Digits);
            Lotti = RitornoLotti(RangeStop/Point());

            ticketsell=OrderSend(Symbol(),OP_SELL,Lotti,Bid,0,LivelloStopSell,LivelloTakeSell,"Invio SELLSTOP",Magic_Number,0,clrRed);
            if(ticketsell<0)
               Print("Errore nell'invio del SELL: "+ IntegerToString(GetLastError()));
           }

         break;

     }
  }

//+------------------------------------------------------------------+
// Questa funzione ritorna i lotti per rischiare un certa percentuale del capitale inserendo un certo numero di punti come stop loss
double RischioPercentuale(double Percentuale_rischio, double Punti_Stop)
  {
// Questa variabile richiama quante vale un tick in € se hai il conto in euro
   TickValue   = MarketInfo(_Symbol, MODE_TICKVALUE);
// Questa variabile richiama quanti tick ci sono in un punto
   TickSize    = MarketInfo(_Symbol, MODE_TICKSIZE);
// In questa variabile calcoliamo il valore di un tick diviso quanti tick ci sono in un punto
   double   DeltaValuePerLot  = TickValue / TickSize;
// In questa variabile facciamo il calcolo che ci da il valore di 1 punto ad 1 lotto sul mercato attuale
   double Valore_un_punto_un_lotto = DeltaValuePerLot*Point();
// Ora calcoliamo la somma che vogliamo rischiare ad ogni operazione, semplice percentuale del capitale
   double Somma_Da_Rischiare = AccountEquity()*(Percentuale_rischio/100.0);
// Ora moltiplichiamo lo stop loss in punti (500) esempio * il valore di 1 punto ad 1 lotto
// Tutto queto diviso per la somma che vogliamo rischiare (ottenuta facendo la percentuale prima)
   double Lotti_Dimensione = Somma_Da_Rischiare/(Punti_Stop *Valore_un_punto_un_lotto);

   return Lotti_Dimensione;
  }

//+------------------------------------------------------------------+
// Questa funzione ritorna il numero di lotti per rischiare una certa somma di denaro per quell'operazione
double RischioDenaro(double Somma_Da_Rischiare, double Punti_Stop)
  {
// Questa variabile richiama quante vale un tick in € se hai il conto in euro
   TickValue   = MarketInfo(_Symbol, MODE_TICKVALUE);
// Questa variabile richiama quanti tick ci sono in un punto
   TickSize    = MarketInfo(_Symbol, MODE_TICKSIZE);
// In questa variabile calcoliamo il valore di un tick diviso quanti tick ci sono in un punto
   double   DeltaValuePerLot  = TickValue / TickSize;
// In questa variabile facciamo il calcolo che ci da il valore di 1 punto ad 1 lotto sul mercato attuale
   double Valore_un_punto_un_lotto = DeltaValuePerLot*Point();
// Ora moltiplichiamo lo stop loss in punti (500) esempio * il valore di 1 punto ad 1 lotto
// Tutto queto diviso per la somma che vogliamo rischiare (ottenuta facendo la percentuale prima)
   double Lotti_Dimensione = Somma_Da_Rischiare/(Punti_Stop *Valore_un_punto_un_lotto);
// Ritorna questo valore che sarebbero i lotti da investire prima di inserire l'ordine
   return Lotti_Dimensione;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double RitornoLotti(double PuntiStopLoss)
  {
   double NumeroLotti=0;

// il tipo di enumerazione selezionata la vediamo globalmente
   switch(Lottaggio)
     {
      // Caso dei Lotti fissi
      case 0:
         NumeroLotti =Lotti;
         break;

      //Caso dei Lotti in percentuale
      case 1:

         NumeroLotti= RischioPercentuale(RischioPercentuale,PuntiStopLoss);
         break;

      //Caso dei Lotti in denaro
      case 2:

         NumeroLotti= RischioDenaro(RischioDenaro,PuntiStopLoss);
         break;
         
     }
   return NumeroLotti;
  }
//+------------------------------------------------------------------+

// Chiusura Parziale a tot pips di profitto
// Trailing Stop
// Inserimento Griglia/Cancellazione Pendenti/Chiusura con mediana/Spostamento o cancellazione pendenti in base a condizione 
// Calcolo profitto/perdita giornaliera con successiva scrittura su file
// Controllo licenza
