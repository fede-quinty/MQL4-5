//+------------------------------------------------------------------+
//|                                                   My_Include.mqh |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CInfo
  {
protected:
   int               BarsCount;
   int               contatore;
   double              pips;

public:
                     CInfo(void)
     {
      this.BarsCount=0;
      this.contatore=0;
      this.pips=0.0;
     };
                    ~CInfo(void) {};

   bool              Nuova_Candela();
   double            Pips();
   void              Print_Errore(string cosa_printare);
   void              Scrivi_Risultati_Daily(int magic, string FileName, int OrarioScrittura);
   bool              Ci_Sono_Ordini(int magic);
   double            Ritorna_Profitto_Ordini_Aperti(int magic_number,int Tipo_operazione);
   int               Ritorna_Ultimo_Ticket_Chiuso(int magic);
   int               Ritorna_Ultimo_Ticket_Aperto(int magic);
   double            Ritorna_Profitto_Operazioni_Chiuse_Giornata(int magic);


  };
//+------------------------------------------------------------------+
class CModifica:CInfo
  {

public:
                     CModifica(void) {};
                    ~CModifica(void) {};

   void              Trailing_Stop(int magic_number);
   void              Trailing_Stop_ATR(int magic_number, int Periodo_ATR,int Moltiplicatore_ATR);

  };

//+------------------------------------------------------------------+
class CChiusura:CInfo
  {

public:
                     CChiusura(void) {};
                    ~CChiusura(void) {};

   void              Chiudi_Sell(int magic);
   void              Chiudi_Buy(int magic);
   bool              Chiusura_Max_Daily(int magic, int Massimo_Profitto, int Massima_Perdita);

  };
//+------------------------------------------------------------------+
class CMoneyManagement:public CInfo
  {

public:
                     CMoneyManagement(void)
     {

     };
                    ~CMoneyManagement(void) {};

   double            Rischio_Denaro(double Somma_Da_Rischiare, double Punti_Stop);
   double            Rischio_Percentuale(double Percentuale_rischio, double Punti_Stop);

  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGrid:public CInfo
  {
private:
   int               ticketbuystop,ticketsellstop;

public:
                     CGrid(void)
     {
      this.ticketbuystop=0;
      this.ticketsellstop=0;
     };
                    ~CGrid(void) {};

   void              Griglia_Sell(int tot_pips,
                                  int aumento_pips,
                                  int numero_ordini_da_inserire,
                                  double Lottaggio,
                                  int Take_in_pips,
                                  int Stop_in_pips,
                                  int magic,
                                  int Ore);

   void              Griglia_Buy(int tot_pips,
                                 int aumento_pips,
                                 int numero_ordini_da_inserire,
                                 double Lottaggio,
                                 int Take_in_pips,
                                 int Stop_in_pips,
                                 int magic,
                                 int Ore);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//Questa funzione ritorna true se c'è nuova candela nel grafico attuale
bool CInfo::Nuova_Candela()
  {
// Se il numero di barre è maggiore alla variabile Barscount
   if(Bars > BarsCount)
     {
      // Allora BarsCount è uguale al numero di barre e ritorni true
      BarsCount = Bars;
      return true;
     }
   else
      return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CInfo::Pips()
  {

   if(Digits>=3)
      return pips = Point()*10;

   else
      return pips = Point();

  }
//+------------------------------------------------------------------+
void CInfo::Print_Errore(string cosa_printare)
  {

   Print(cosa_printare + ": " + IntegerToString(GetLastError()));

  }

// Funzione che scrive in un file CSV i profitti/perdite giornaliere
void CInfo::Scrivi_Risultati_Daily(int magic, string FileName, int OrarioScrittura)
  {
// Open the file
   int handle = FileOpen(FileName, FILE_READ | FILE_WRITE | FILE_CSV);
   string risultatogiornaliero = (string) Ritorna_Profitto_Operazioni_Chiuse_Giornata(magic) ;

   if(contatore == 0 && Hour()==OrarioScrittura)
     {
      if(handle != INVALID_HANDLE)
        {
         // Move to the end of the file
         FileSeek(handle, 0, SEEK_END);

         // Write a new line
         FileWrite(handle, risultatogiornaliero);

         // Close the file
         FileClose(handle);

         contatore++;

        }
      else
        {
         Print("Failed to open ", FileName, ". Error code = ", GetLastError());
        }
     }

   if(contatore!=0 && Hour() != OrarioScrittura)
      contatore=0;

  }

// Questa funzione ritorna true se ci sono ordini aperti dal nostro EA
bool CInfo::Ci_Sono_Ordini(int magic)
  {
   for(int i = 0 ; i < OrdersTotal() ; i++)
     {
      // Selezioniamo il numero dell'ordine in base alla posizione
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         Print_Errore("Errore Selezione Ordine 'Ci_Sono_Ordini'");
         continue;
        }
      // Se l'ordine selezionato ha il nostro simbolo e il nostro magic number
      if(OrderSymbol() == Symbol() && OrderMagicNumber()==magic)
         // Se si vuol dire che ci sono ordini aperti dal nostro expert sul grafico attuale
         return(true);
     }
   return(false);
  }

//+------------------------------------------------------------------+
int CInfo::Ritorna_Ultimo_Ticket_Chiuso(int magic)
  {
//Creo variabili per i calcoli successivi
   datetime counter = 0;
   int ticketNumber = 0;

//Faccio un ciclo di tutti gli ordini chiusi (OrdersHistoryTotal)
   for(int i=0; i<OrdersHistoryTotal(); i++)
     {
      // Seleziono l'ordine in base alla posizione dalla HISTORY
      if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         Print_Errore("Errore Selezione Ordine 'Ritorna_Ultimo_Ticket_Chiuso'");
         continue;
        }

      //Selezionato l'ordine controllo che sia un buy o un sell, il simbolo e il magic
      //Inoltre controllo se è stato l'ultimo a essere chiuso fra tutti gli ordini del ciclo
      if(OrderType() < 2 &&
         OrderSymbol() == Symbol() &&
         OrderMagicNumber()== magic &&
         OrderCloseTime()>counter)
        {
         //Se il tempo di chiusura è maggiore alla mia variabile la aggiorno, stessa cosa con il ticket
         counter=OrderCloseTime();
         ticketNumber = OrderTicket();
        }
     }
//Ritorno il ticket che sarà l'ultimo ordine chiuso
   return ticketNumber;
  }

//+------------------------------------------------------------------+
int CInfo::Ritorna_Ultimo_Ticket_Aperto(int magic)
  {
   datetime counter = 0;
   int ticketNumber = 0;

   for(int i = 0; i<OrdersTotal(); i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         Print_Errore("Errore Selezione Ordine 'Ritorna_Ultimo_Ticket_Aperto'");
         continue;
        }

      if(OrderType() < 2 &&
         OrderSymbol() == Symbol() &&
         OrderMagicNumber()== magic &&
         OrderOpenTime()>counter)
        {
         counter=OrderOpenTime();
         ticketNumber = OrderTicket();
        }

     }
   return ticketNumber;
  }
// Questa funzione ritorna il profitto o perdita totale degli ordini aperti
double CInfo::Ritorna_Profitto_Ordini_Aperti(int magic_number,int Tipo_operazione)
  {
   double Profitti_totali = 0;
   double ProfittoPerdita=0;

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         Print_Errore("Errore Selezione Ordine 'Ritorna_Profitto_Ordine_Aperto'");
         continue;
        }

      if(OrderMagicNumber() == magic_number &&
         OrderSymbol() == Symbol()&&
         OrderType()==Tipo_operazione &&
         OrderType()<2
        )
        {
         ProfittoPerdita= OrderProfit()+ OrderSwap()+ OrderCommission();
         Profitti_totali += ProfittoPerdita;
        }
     }
   return Profitti_totali;
  }

// Questa funzione ritorna il profitto delle operazioni chiuse in giornata sul simbolo del expert advisor
double CInfo::Ritorna_Profitto_Operazioni_Chiuse_Giornata(int magic)
  {
   double Total_profit =0;
   double ProfittoPerdita= 0;

   for(int i=0; i<OrdersHistoryTotal(); i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         Print_Errore("Errore Selezione Ordine 'Ritorna_Profitto_Operazioni_Chiuse_Giornata'");
         continue;
        }

      // Questa variabile ci immagazzina la data della giornata attuale
      datetime TodayTime = TimeCurrent()-(TimeCurrent()%86400);

      if(OrderCloseTime() >= TodayTime && OrderMagicNumber()==magic && OrderSymbol()==Symbol())
        {
         ProfittoPerdita= OrderProfit()+ OrderSwap()+ OrderCommission();
         Total_profit+= ProfittoPerdita;
        }
     }
   return (Total_profit);
  }

// Trailing stop che sposta lo stop loss bid-atr(buy) o ask+atr(sell)
void CModifica::Trailing_Stop_ATR(int magic_number, int Periodo_ATR,int Moltiplicatore_ATR)
  {

   double ATR = iATR(Symbol(),Period(),Periodo_ATR,1);

   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         Print_Errore("Errore Selezione Ordine 'Trailing_Stop_ATR'");
         continue;
        }

      if(OrderSymbol() == Symbol() && OrderMagicNumber() == magic_number)
        {
         if(OrderType() == OP_BUY)
           {
            // Bid - valore atr*2
            double Nuovo_stop_loss_buy = NormalizeDouble(Bid-(ATR*Moltiplicatore_ATR),Digits);

            if((OrderStopLoss() < Nuovo_stop_loss_buy || OrderStopLoss()==NULL) && Bid > OrderOpenPrice())
              {

               if(!OrderModify(OrderTicket(), OrderOpenPrice(), Nuovo_stop_loss_buy, OrderTakeProfit(), Red))
                  Print_Errore("Errore Modifica Ordine con Trailing ATR");

              }
           }
         if(OrderType() == OP_SELL)
           {
            // Il nuovo livello di stop loss calcolato sommando il valore atr*2 ad ask
            double Nuovo_stop_loss_sell = NormalizeDouble(Ask+(ATR*Moltiplicatore_ATR),Digits);

            if((OrderStopLoss() > Nuovo_stop_loss_sell || OrderStopLoss()==NULL)  && Ask < OrderOpenPrice())
              {
               if(!OrderModify(OrderTicket(), OrderOpenPrice(), Nuovo_stop_loss_sell, OrderTakeProfit(), Red))
                  Print_Errore("Errore modifica Ordine con Trailing ATR");
              }
           }
        }
     }
  }

// Trailing stop che si attiva subito, sposta lo stop (Bid-Range_stop, per i buy) (Sell+ Range_Stop, per i sell)
void CModifica::Trailing_Stop(int magic_number)
  {
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         Print_Errore("Errore Selezione Ordine 'Trailing_Stop'");
         continue;
        }

      if(OrderSymbol() == Symbol()&& OrderMagicNumber() == magic_number)
        {
         if(OrderType() == OP_BUY)
           {
            // Facciamo una variabile di tipo static double che immagazzinerà il range dello stop loss in punti
            static double Ampiezza_stop_buy = NormalizeDouble(OrderOpenPrice()-OrderStopLoss(),Digits);
            // Variabile per spostare lo stop loss = Prezzo attuale - il range in punti dello stop
            double Nuovo_stop_loss_buy = NormalizeDouble(Bid-Ampiezza_stop_buy,Digits);
            // Variabile per caclolare la distanza dello stop loss da bid (prezzo attuale)
            double distanza_da_bid_buy = NormalizeDouble(Bid - OrderStopLoss(),Digits);

            if(OrderStopLoss() == NULL)
               Print("Il livello dello stop non è stato settato ad avvio ordine");

            if(OrderStopLoss()<Nuovo_stop_loss_buy && Bid > OrderOpenPrice()&& distanza_da_bid_buy >= Ampiezza_stop_buy)
              {
               if(!OrderModify(OrderTicket(), OrderOpenPrice(), Nuovo_stop_loss_buy, OrderTakeProfit(), Red))
                  Print_Errore("Errore modifica con Trailing Stop");
              }
           }
         if(OrderType() == OP_SELL)
           {
            // Stop loss - Prezzo di apertura per ottenere la grandezza dello stop
            static double Ampiezza_stop_sell = NormalizeDouble(OrderStopLoss()-OrderOpenPrice(),Digits);
            // Ask + la grandezza dello stop in punti per ottenere il livello nuovo dello stop loss
            double Nuovo_stop_loss_sell = NormalizeDouble(Ask + Ampiezza_stop_sell,Digits);
            // Stoploss - Ask per ottenere per ottenere la distanza da ask allo stop loss
            double distanza_da_ask_sell = NormalizeDouble(OrderStopLoss()-Ask,Digits);

            if(OrderStopLoss() == NULL)
               Print("Il livello dello stop non è stato settato ad avvio ordine");

            if(OrderStopLoss()>Nuovo_stop_loss_sell && Ask < OrderOpenPrice() && distanza_da_ask_sell >= Ampiezza_stop_sell)
              {
               if(!OrderModify(OrderTicket(), OrderOpenPrice(), Nuovo_stop_loss_sell, OrderTakeProfit(), Red))
                  Print_Errore("Errore modifica con Trailing Stop");
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CChiusura::Chiudi_Sell(int magic)
  {

   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         Print_Errore("Errore Selezione Ordine 'Chiudi Sell'");
         continue;
        }
      if(OrderType() == OP_SELL && OrderMagicNumber() == magic && OrderSymbol()==Symbol())
        {

         if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0, clrRed))
           {
            Print_Errore("Errore chiusura Sell");
           }

        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CChiusura::Chiudi_Buy(int magic)
  {
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         Print_Errore("Errore Selezione Ordine 'Chiudi_Buy'");
         continue;
        }

      if(OrderType() == OP_BUY && OrderMagicNumber()== magic && OrderSymbol()==Symbol())
        {

         if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0, clrRed))
           {
            Print_Errore("Errore chiusura Buy");
           }

        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CChiusura::Chiusura_Max_Daily(int magic, int Massimo_Profitto, int Massima_Perdita)
  {
   double Profitto_Perdita_Totale_Giornarliera =
      Ritorna_Profitto_Ordini_Aperti(magic,OP_SELL)+
      Ritorna_Profitto_Ordini_Aperti(magic,OP_BUY)+
      Ritorna_Profitto_Operazioni_Chiuse_Giornata(magic);

   if(Profitto_Perdita_Totale_Giornarliera >= Massimo_Profitto ||
      Profitto_Perdita_Totale_Giornarliera <= -(Massima_Perdita))
     {
      Chiudi_Buy(magic);
      Chiudi_Sell(magic);
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
// Questa funzione ritorna i lotti per rischiare un certa percentuale del capitale inserendo un certo numero di punti come stop loss
double CMoneyManagement::Rischio_Percentuale(double riskPercentage, double stopLossPoints)
  {

// Retrieve the tick value and tick size for the current symbol
   double tickValue = MarketInfo(_Symbol, MODE_TICKVALUE);
   double tickSize = MarketInfo(_Symbol, MODE_TICKSIZE);

// Check if the market info was retrieved successfully
   if(tickValue == 0 || tickSize == 0)
     {
      Print_Errore("Market data errore");
      return 0;
     }

// Calculate the value of one tick per lot
   double ticksPerLot = tickValue / tickSize;

// Calculate the value of one point in terms of lots
   double pointValuePerLot = ticksPerLot * Point();

// Calculate the capital to risk
   double capitalToRisk = AccountEquity() * (riskPercentage / 100);

// Calculate the number of lots based on the stop loss points and the capital to risk
   double lotsForRisk = capitalToRisk / ((stopLossPoints/Point())* pointValuePerLot);

   return lotsForRisk;
  }

// Questa funzione ritorna il numero di lotti per rischiare una certa somma di denaro per quell'operazione
double CMoneyManagement::Rischio_Denaro(double riskAmount, double stopLossPoints)
  {
// Retrieve the tick value and tick size for the current symbol
   double tickValue = MarketInfo(_Symbol, MODE_TICKVALUE);
   double tickSize = MarketInfo(_Symbol, MODE_TICKSIZE);

// Check if the market info was retrieved successfully
   if(tickValue == 0 || tickSize == 0)
     {
      Print_Errore("Market data errore");
      return 0;
     }

// Calculate the value of one tick per lot
   double ticksPerLot = tickValue / tickSize;

// Calculate the value of one point in terms of lots
   double pointValuePerLot = ticksPerLot * Point();

// Calculate the number of lots based on the stop loss points and the risk amount
   double lotsForRisk = riskAmount / ((stopLossPoints/Point()) * pointValuePerLot);

// Return the number of lots to invest before placing the order
   return lotsForRisk;
  }

// Invia una griglia di ordini BUYSTOP
void CGrid::Griglia_Buy(int tot_pips,
                        int aumento_pips,
                        int numero_ordini_da_inserire,
                        double Lots,
                        int Take_in_pips,
                        int Stop_in_pips,
                        int magic,
                        int Ore)
  {

   double Livello_entrata = 0;

// D3600 sono i secondi in un ora
   int expirationTime = 3600 * Ore;

// Calculate the expiration time in MetaTrader's datetime format
   datetime ExpirationDateTime = TimeCurrent() + expirationTime;

   for(int i = 0; i<numero_ordini_da_inserire ; i ++)
     {
      // Livello per il primo ordine
      Livello_entrata = Bid + tot_pips*Pips();

      ticketbuystop = OrderSend(
                         Symbol(),
                         OP_BUYSTOP,
                         Lots,
                         Livello_entrata,
                         0,
                         Livello_entrata - Stop_in_pips*Pips(),
                         Livello_entrata + Take_in_pips*Pips(),
                         " Inserisco BUYSTOP Griglia ",
                         magic,
                         ExpirationDateTime,
                         clrGreen
                      );

      if(ticketbuystop<0)
         Print_Errore("Errore inserimento griglia Buy");

      tot_pips += aumento_pips ;

     }
  }
// Invia una griglia di ordini SELLSTOP
void CGrid::Griglia_Sell(int tot_pips,
                         int aumento_pips,
                         int numero_ordini_da_inserire,
                         double Lots,
                         int Take_in_pips,
                         int Stop_in_pips,
                         int magic,
                         int Ore)
  {

   double Livello_entrata = 0;
   
// D3600 sono i secondi in un ora
   int expirationTime = 3600 * Ore;

// Calculate the expiration time in MetaTrader's datetime format
   datetime ExpirationDateTime = TimeCurrent() + expirationTime;

   for(int i = 0; i<numero_ordini_da_inserire ; i ++)
     {
      // Livello per il primo ordine
      Livello_entrata = Ask - tot_pips*Pips();

      ticketsellstop = OrderSend(
                          Symbol(),
                          OP_SELLSTOP,
                          Lots,
                          Livello_entrata,
                          0,
                          Livello_entrata + Stop_in_pips*Pips(),
                          Livello_entrata - Take_in_pips*Pips(),
                          " Inserisco SELLSTOP Griglia ",
                          magic,
                          ExpirationDateTime,
                          clrRed
                       );
      if(ticketsellstop<0)
         Print_Errore("Errore inserimento griglia Sell");

      tot_pips += aumento_pips ;

     }
  }
//+------------------------------------------------------------------+
