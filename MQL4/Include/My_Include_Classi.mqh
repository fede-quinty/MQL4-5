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
   datetime          variabile_memorizzatrice;
   int               chiusure_parziali;
   string            contatore_parziale_sell;
   string            contatore_parziale_buy;
   int               Parziale_sell;
   int               Parziale_buy;

public:
                     CInfo(void)
     {
      this.BarsCount=0;
      this.variabile_memorizzatrice=0;
      this.chiusure_parziali=0;
      this.contatore_parziale_sell="";
      this.contatore_parziale_buy="";
      this.Parziale_sell=0;
      this.Parziale_buy=0;
     };
                    ~CInfo(void) {};

   bool              Nuova_Candela();
   bool              Ci_Sono_Ordini_Simbolo_Magic(int magic);
   bool              Sono_Passate_Tot_Candele(bool condizione,int Numero_di_candele_passate);
   void              Info(string Frase_da_aggiungere, int magic);
   int               Ritorna_Ultimo_Ticket_Chiuso(int magic);
   double            Range_Stop(int magic_number);
   double            Range_Take(int magic_number);
   double            Profitto_Operazione_Aperta_Magic(int magic_number,int Tipo_operazione);
   int               Ritorna_Numero_Ticket_Ordine_Aperto(int magic,int numero_ticket_ordine);
   double            Order_Profit_Full();
   double            Perdita_Operazione_In_Denaro(int Magic);
   int               Numero_Ordini_Aperti_Simbolo_Magic(int magic);
   double            Ritorna_Profitto_Operazioni_Aperte_Simbolo();
   double            Ritorna_Profitto_Operazioni_Chiuse_Giornata();
   int               Numero_Chiusure_Parziali_BUY(int magic);
   int               Numero_Chiusure_Parziali_SELL(int magic);
   bool              Order_Is_Partial_Profit();

  };
//+------------------------------------------------------------------+
class CModifica
  {

public:
                     CModifica(void) {};
                    ~CModifica(void) {};

   void              Trailing_Stop_Range_Stop_Now(int magic_number);
   void              Trailing_Stop_Doppio(int magic_number, double Punti_Azzeramento, double Punti_Attivazione_Trailing);
   void              Trailing_Stop_Loss_ATR(int magic_number, int Periodo_ATR,int Moltiplicatore_ATR);
   void              Trailing_Stop_Loss__Livello_Attivazione(int magic_number, double Punti_Attivazione_Trailing,double Punti_Movimento);

  };
//+------------------------------------------------------------------+
class CCancellazione
  {

public:
                     CCancellazione(void) {};
                    ~CCancellazione(void) {};

   void              Cancella_Pendenti(bool close_buy, bool close_sell, int candela_chiusura);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CCheck
  {

public:

                     CCheck(void) {};
                    ~CCheck(void) {};

   virtual bool              Controllo_Licenza(string input_Password_Licenza,string Password, string Nome_Conto, int Numero_Conto, datetime Scadenza);

   bool              Check_Lots(double Lotti_Operazione);

  };
//+------------------------------------------------------------------+
class CChiusura:public CInfo
  {

public:
                     CChiusura(void) {};
                    ~CChiusura(void) {};

   void              Chiudi_Sell(int percentuale,int candela_chiusura);
   void              Chiudi_Buy(int percentuale,int candela_chiusura);
   void              Chiudi_Su_Mediana(int magic);
   void              Chiudi_Perdita_Tutto(int Perdita, int magic);
   void              Chiudi_Profitto_Tutto(int Perdita, int magic);
   void              Chiusura_Max_Perdita_Max_Profitto_Day(int Massimo_Profitto_Simbolo, int Massima_Perdita_Simbolo);

  };
//+------------------------------------------------------------------+
class CMoneyManagement:public CInfo
  {
private:
   double            TickSize;
   double            TickValue;

public:
                     CMoneyManagement(void)
     {
      this.TickSize=0;
      this.TickValue=0;
     };
                    ~CMoneyManagement(void) {};

   double            Ritorna_Lotti(double Perdita, int Take_Profit_in_punti,int Magic);
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

   void              Griglia_Sell(int tot_punti, int aumento_punti, int numero_ordini_da_inserire, double Lottaggio,int Take_in_punti,int Stop_in_punti,int magic);
   void              Griglia_Buy(int tot_punti, int aumento_punti, int numero_ordini_da_inserire, double Lottaggio,int Take_in_punti,int Stop_in_punti,int magic);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//Questa funzione ritorna true se c'è nuova candela nel grafico attuale
bool CInfo::Nuova_Candela(void)
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
// Questa funzione ritorna true se ci sono ordini aperti dal nostro EA
bool CInfo::Ci_Sono_Ordini_Simbolo_Magic(int magic)
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
// Questa funzione ci serve per analizzare se sono passate tot candele da un evento inteso come vero o falso(condizione)
bool CInfo::Sono_Passate_Tot_Candele(bool condizione,int Numero_di_candele_passate)
  {
//Se c'è la condizione immagazziniamo il tempo di adesso in una variabile
   if(condizione == true)
     {
      variabile_memorizzatrice = Time[0];
     }
//Se il tempo immagazzinato prima corrisponde al tempo di tot candele vuol dire che sono passate tot candele e ritorni true
   if(variabile_memorizzatrice == Time[Numero_di_candele_passate])
     {
      return true;
     }
   else
      return false;
  }
//+------------------------------------------------------------------+
void CInfo::Info(string Frase_da_aggiungere, int magic)
  {

//Creo variabili per immagazzinare dettagli sul simbolo
   double Lotti_Max = MarketInfo(Symbol(),MODE_MAXLOT);
   double Lotti_Min = MarketInfo(Symbol(),MODE_MINLOT);
   double Spread = MarketInfo(Symbol(),MODE_SPREAD);
   double Punto = MarketInfo(Symbol(),MODE_POINT);

//Seleziono tramite ticket l'ultimo ordine richiamando la funzione (Ritorna_Ultimo_Ticket_Chiuso)
   if(!OrderSelect(Ritorna_Ultimo_Ticket_Chiuso(magic),SELECT_BY_TICKET))
      Print("Errore selezione ordine numero: "+IntegerToString(GetLastError()));

//Creo delle variabili per assegnare prezzo di chiusura e prezzo di apertura dell'ordine chiuso selezionato
   double Prezzo_Chiusura_Ultimo=NormalizeDouble(OrderClosePrice(),Digits);
   double Prezzo_Apertura_Ultimo=NormalizeDouble(OrderOpenPrice(),Digits);

//Commento sul grafico tutti questi dettagli + una frase a piacere esterna
   Comment(" Lotti Min = " + DoubleToStr(Lotti_Min,2) +
           "\n" + " Lotti Max = " + DoubleToString(Lotti_Max,0) +
           "\n" + " Spread = " + DoubleToString(Spread,0) +
           "\n" + " Punto = " +DoubleToString(Punto,Digits) +
           "\n" + " Apertura Ultimo Ordine Chiuso = " + DoubleToStr(Prezzo_Apertura_Ultimo,Digits)+
           "\n" + " Chiusura Ultimo Ordine Chiuso = " + DoubleToStr(Prezzo_Chiusura_Ultimo,Digits)+
           "\n" + Frase_da_aggiungere);
  }
//+------------------------------------------------------------------+
int CInfo::Ritorna_Ultimo_Ticket_Chiuso(int magic)
  {
//Creo variabili per i calcoli successivi
   int Ordini_Totali_Storia=OrdersHistoryTotal();
   datetime counter = 0;
   int ticketNumber = 0;

//Faccio un ciclo di tutti gli ordini chiusi (OrdersHistoryTotal)
   for(int i=0; i<Ordini_Totali_Storia; i++)
     {
      // Seleziono l'ordine in base alla posizione dalla HISTORY
      if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
         Print(" Errore in OrderSelect n = " + IntegerToString(GetLastError()));

      //Selezionato l'ordine controllo che sia un buy o un sell, il simbolo e il magic
      //Inoltre controllo se è stato l'ultimo a essere chiuso fra tutti gli ordini del ciclo
      if(OrderType() < 2 && OrderSymbol() == Symbol() && OrderMagicNumber()== magic && OrderCloseTime()>counter)
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
// Questa funzione ritorna il valore dello Stop Loss in punti
double CInfo::Range_Stop(int magic_number)
  {

   double Spread= NormalizeDouble(Ask-Bid,Digits);

   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      //Seleziono ordine
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         Print(" Error OrderSelect " + IntegerToString(GetLastError()));

      //Check che sia l'ordine aperto dall'ea
      if(OrderMagicNumber() == magic_number && OrderSymbol() == Symbol())
        {
         //Se è di tipo buy
         if(OrderType()== OP_BUY || OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP)
           {
            //Prendo il suo stop loss in punti e gli tolgo lo spread
            static double StopLoss_buy = NormalizeDouble(OrderOpenPrice()-OrderStopLoss(),Digits);
            return StopLoss_buy-Spread;
           }
         else
            //Stessa cosa con calcolo inverso
            if(OrderType()== OP_SELL|| OrderType()== OP_SELLLIMIT || OrderType() == OP_SELLSTOP)
              {
               static double StopLoss_sell = NormalizeDouble(OrderStopLoss()-OrderOpenPrice(),Digits);
               return StopLoss_sell-Spread;
              }
        }
     }
   return 0;
  }
//+------------------------------------------------------------------+
//Funzione che ritorna il take profit quindi il calcolo è come la funzione precedente solo che inverso
double CInfo::Range_Take(int magic_number)
  {
   double Spread= NormalizeDouble(Ask-Bid,Digits);
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         Print(" Error OrderSelect " + IntegerToString(GetLastError()));
      if(OrderMagicNumber() == magic_number && OrderSymbol() == Symbol())
        {
         if(OrderType()== OP_BUY || OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP)
           {

            static double TakeProfit_buy = NormalizeDouble(OrderTakeProfit()-OrderOpenPrice(),Digits);

            return TakeProfit_buy-Spread;
           }
         else
            if(OrderType()== OP_SELL|| OrderType()== OP_SELLLIMIT || OrderType() == OP_SELLSTOP)
              {

               static double TakeProfit_sell = NormalizeDouble(OrderOpenPrice()-OrderTakeProfit(),Digits);
               return TakeProfit_sell-Spread;
              }

        }

     }
   return 0;
  }

// Questa funzione ritorna in double il profitto/perdita del tipo di operazione selezionata BUY O SELL
double CInfo::Profitto_Operazione_Aperta_Magic(int magic_number,int Tipo_operazione)
  {
   double Profitti_totali = 0;
   for(int i = OrdersTotal()-1; i>= 0 ; i--)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         Print(" Error OrderSelect " + IntegerToString(GetLastError()));

      if(OrderMagicNumber() == magic_number && OrderSymbol() == Symbol())
        {
         if(OrderType() == Tipo_operazione)
            Profitti_totali += Order_Profit_Full();
         else
            if(OrderType() < 0)
               return 0;
        }
     }
   return Profitti_totali;
  }
//+------------------------------------------------------------------+
int CInfo::Ritorna_Numero_Ticket_Ordine_Aperto(int magic,int numero_ticket_ordine)
  {
   int i=0;
   int Ordini_Totali=OrdersTotal();
   datetime counter = 0;
   int ticketNumber = 0;

   for(i = 0; i<Ordini_Totali; i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         Print(" Error OrderSelect " + IntegerToString(GetLastError()));

      if(OrderType() < 2 && OrderSymbol() == Symbol() && OrderMagicNumber()== magic && OrderOpenTime()>counter)
        {
         counter=OrderOpenTime();
         ticketNumber = OrderTicket()-numero_ticket_ordine;
        }

     }
   return ticketNumber;
  }


// Funzione che ritorna il vero Profitto di un ordine ovviamente va selezionato con OrderSelect()
double CInfo::Order_Profit_Full()
  {
   return OrderProfit()+ OrderSwap()+ OrderCommission();
  }


// Questa funzione mi ritorna la perdita in denaro dell'ultima operazione chiusa
double CInfo::Perdita_Operazione_In_Denaro(int Magic)
  {
   double Perdita_in_denaro = 0;
   if(OrdersHistoryTotal()>=1)
     {
      if(!OrderSelect(Ritorna_Ultimo_Ticket_Chiuso(Magic),SELECT_BY_TICKET))
         Print(" Error OrderSelect " + IntegerToString(GetLastError()));

      if(Order_Profit_Full()< 0)
        {
         Perdita_in_denaro = Order_Profit_Full();
         return Perdita_in_denaro;
        }
     }
   return 0;
  }

// Questa funzione conta il numero degli ordini sul simbolo attuale aperti dall'expert attualmente inserito e ci ritorna il risultato (integer)
int CInfo::Numero_Ordini_Aperti_Simbolo_Magic(int magic)
  {
   int contatore_ordini_simbolo = 0;
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         Print(" Error OrderSelect " + IntegerToString(GetLastError()));

      if(OrderSymbol() == Symbol() && OrderMagicNumber()==magic)
        {
         contatore_ordini_simbolo++;
        }
     }
   return (contatore_ordini_simbolo);
  }

// Ritorna il numero di chiusure parziali dell'ordine BUY
int CInfo::Numero_Chiusure_Parziali_BUY(int magic)
  {

   if(!OrderSelect(Ritorna_Ultimo_Ticket_Chiuso(magic),SELECT_BY_TICKET))
      Print("Errore Selezine Ordine: " + IntegerToString(GetLastError()));

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
int CInfo::Numero_Chiusure_Parziali_SELL(int magic)
  {

   if(!OrderSelect(Ritorna_Ultimo_Ticket_Chiuso(magic),SELECT_BY_TICKET))
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
bool CInfo::Order_Is_Partial_Profit()
  {
// Per vedere se un ordine è stato chiuso parzialmente dobbiamo analizzare il suo commento.
// Avrà queste due stringhe "from #" e "to #" sempre nella stessa posizione
   return StringSubstr(OrderComment(),0,6) == "from #" || StringSubstr(OrderComment(),0,4)== "to #";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// Questa funzione ci ritorna il profitto delle operazioni aperte nel simbolo attuale
double CInfo::Ritorna_Profitto_Operazioni_Aperte_Simbolo()
  {

   double Total_profit= 0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         Print(" Error OrderSelect " + IntegerToString(GetLastError()));

      if(OrderMagicNumber()!=0 && OrderSymbol()==Symbol())
         Total_profit+= Order_Profit_Full();
     }
   return Total_profit;
  }

// Questa funzione ritorna il profitto delle operazioni chiuse in giornata sul simbolo del expert advisor
double CInfo::Ritorna_Profitto_Operazioni_Chiuse_Giornata()
  {
   int Ordini_Totali_Storia = OrdersHistoryTotal();
   double Total_profit =0;
   for(int i=0; i<Ordini_Totali_Storia; i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
         Print(" Error OrderSelect " + IntegerToString(GetLastError()));

      // % ritorna il resto (Non è divisione)
      datetime TodayTime = TimeCurrent()-(TimeCurrent()%86400);

      if(OrderCloseTime() >= TodayTime)
        {
         if(OrderMagicNumber()!=0 && OrderSymbol()==Symbol())
            Total_profit+= Order_Profit_Full();
        }
     }
   return (Total_profit);
  }

// Trailing stop che sposta lo stop loss a tot punti da Ask (sell) o Bid (buy)
void CModifica::Trailing_Stop_Loss__Livello_Attivazione(int magic_number, double Punti_Attivazione_Trailing,double Punti_Movimento)
  {
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         Print("Errore nella selezione dell'ordine: ",IntegerToString(GetLastError()));

      if(OrderSymbol() == Symbol() && OrderMagicNumber() == magic_number)
        {
         if(OrderType() == OP_BUY)
           {
            // Il nuovo stop loss per il buy è BID - i Punti di movimento (variabile di ingresso)
            double Nuovo_stop_loss_buy = NormalizeDouble(Bid - Punti_Movimento *Point(),Digits);

            // Prezzo di apertura + i punti di attivazione trailing è il livello al quale si attiverà il nostro trailing stop
            double livello_attivazione_buy = NormalizeDouble(OrderOpenPrice()+ Punti_Attivazione_Trailing*Point(),Digits);

            if((OrderStopLoss() < Nuovo_stop_loss_buy || OrderStopLoss()==NULL) && Bid >= livello_attivazione_buy)
              {
               if(!OrderModify(OrderTicket(), OrderOpenPrice(), Nuovo_stop_loss_buy, OrderTakeProfit(), Red))
                  Print("Errore nella modifica dell'ordine: ", IntegerToString(GetLastError()));
              }
           }
         if(OrderType() == OP_SELL)
           {
            // Il nuovo stop loss per il sell è ASK + i punti movimento(variabile di ingresso)
            double Nuovo_stop_loss_sell = NormalizeDouble(Ask+Punti_Movimento*Point(),Digits);

            // Il livello ottenuto sottraendo al prezzo d'entrata dell'ordini i punti attivazione trailing(variabile di ingresso)
            double livello_attivazione_sell = NormalizeDouble(OrderOpenPrice()- Punti_Attivazione_Trailing*Point(),Digits);

            if((OrderStopLoss() > Nuovo_stop_loss_sell || OrderStopLoss()==NULL)  && Ask <= livello_attivazione_sell)
              {
               if(!OrderModify(OrderTicket(), OrderOpenPrice(), Nuovo_stop_loss_sell, OrderTakeProfit(), Red))
                  Print("Errore nella modifica dell'ordine: ", IntegerToString(GetLastError()));
              }
           }
        }
     }
  }

// Trailing stop che sposta lo stop loss bid-atr(buy) o ask+atr(sell)
void CModifica::Trailing_Stop_Loss_ATR(int magic_number, int Periodo_ATR,int Moltiplicatore_ATR)
  {

   double ATR = iATR(Symbol(),Period(),Periodo_ATR,0);

   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         Print("Errore nella selezione dell'ordine: ", IntegerToString(GetLastError()));

      if(OrderSymbol() == Symbol() && OrderMagicNumber() == magic_number)
        {
         if(OrderType() == OP_BUY)
           {
            // Bid - valore atr*2
            double Nuovo_stop_loss_buy = NormalizeDouble(Bid-(ATR*Moltiplicatore_ATR),Digits);

            if((OrderStopLoss() < Nuovo_stop_loss_buy || OrderStopLoss()==NULL) && Bid > OrderOpenPrice())
              {

               if(!OrderModify(OrderTicket(), OrderOpenPrice(), Nuovo_stop_loss_buy, OrderTakeProfit(), Red))
                  Print("Errore nella modifica dell'ordine: ", IntegerToString(GetLastError()));
              }
           }
         if(OrderType() == OP_SELL)
           {
            // Il nuovo livello di stop loss calcolato sommando il valore atr*2 ad ask
            double Nuovo_stop_loss_sell = NormalizeDouble(Ask+(ATR*Moltiplicatore_ATR),Digits);

            if((OrderStopLoss() > Nuovo_stop_loss_sell || OrderStopLoss()==NULL)  && Ask < OrderOpenPrice())
              {
               if(!OrderModify(OrderTicket(), OrderOpenPrice(), Nuovo_stop_loss_sell, OrderTakeProfit(), Red))
                  Print("Errore nella modifica dell'ordine: ", IntegerToString(GetLastError()));
              }
           }
        }
     }
  }

// Trailing stop subito che si ferma quando il prezzo raggiunge tot punti in profitto ( Punti Azzeramento )
// Poi parte un altro trailing stop dopo che il prezzo raggiunge tot punti in profitto
void CModifica::Trailing_Stop_Doppio(int magic_number, double Punti_Azzeramento, double Punti_Attivazione_Trailing)
  {
   for(int i = 0; i < OrdersTotal(); i++)
     {

      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         Print(" Error OrderSelect = " + IntegerToString(GetLastError()));

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

            if((OrderStopLoss()<Nuovo_stop_loss_buy|| OrderStopLoss()==NULL)&& Bid > OrderOpenPrice()&& distanza_da_bid_buy >= Ampiezza_stop_buy)
              {
               // Vedi se non è stato raggiunto il livello di stop del primo trailing
               if(OrderStopLoss()<= OrderOpenPrice()+Punti_Azzeramento*Point())
                 {
                  if(!OrderModify(OrderTicket(), OrderOpenPrice(), Nuovo_stop_loss_buy, OrderTakeProfit(), Red))
                     Print(" Error OrderModify = " + IntegerToString(GetLastError()));
                 }
               // Vedi se è stato raggiunto il livello di attivazione del secondo trailing
               if(OrderStopLoss()>=OrderOpenPrice()+Punti_Azzeramento*Point() && distanza_da_bid_buy > Punti_Attivazione_Trailing*Point())
                 {
                  if(!OrderModify(OrderTicket(), OrderOpenPrice(), Nuovo_stop_loss_buy, OrderTakeProfit(), Red))
                     Print("Errore nella modifica dell'ordine: ", IntegerToString(GetLastError()));
                 }
              }
           }
         // Procedimento opposto per il sell
         if(OrderType() == OP_SELL)
           {
            // Stop loss - Prezzo di apertura per ottenere la grandezza dello stop
            static double Ampiezza_stop_sell = NormalizeDouble(OrderStopLoss()-OrderOpenPrice(),Digits);
            // Ask + la grandezza dello stop in punti per ottenere il livello nuovo dello stop loss
            double Nuovo_stop_loss_sell = NormalizeDouble(Ask + Ampiezza_stop_sell,Digits);
            // Stoploss - Ask per ottenere per ottenere la distanza da ask allo stop loss
            double distanza_da_ask_sell = NormalizeDouble(OrderStopLoss()-Ask,Digits);

            if((OrderStopLoss()>Nuovo_stop_loss_sell || OrderStopLoss()==NULL)&& Ask < OrderOpenPrice() && distanza_da_ask_sell >= Ampiezza_stop_sell)
              {
               // Vedi se non è stato raggiunto il livello di stop del primo trailing
               if(OrderStopLoss()>= OrderOpenPrice()-Punti_Azzeramento*Point())
                 {
                  if(!OrderModify(OrderTicket(), OrderOpenPrice(), Nuovo_stop_loss_sell, OrderTakeProfit(), Red))
                     Print("Errore nella modifica dell'ordine: ", IntegerToString(GetLastError()));
                 }

               // Vedi se è stato raggiunto il livello di attivazione del secondo trailing
               if(OrderStopLoss()<=OrderOpenPrice()-Punti_Azzeramento*Point() && distanza_da_ask_sell > Punti_Attivazione_Trailing*Point())
                 {
                  if(!OrderModify(OrderTicket(), OrderOpenPrice(), Nuovo_stop_loss_sell, OrderTakeProfit(), Red))
                     Print("Errore nella modifica dell'ordine: ", IntegerToString(GetLastError()));
                 }
              }
           }
        }
     }
  }

// Trailing stop che si attiva subito, sposta lo stop (Bid-Range_stop, per i buy) (Sell+ Range_Stop, per i sell)
void CModifica::Trailing_Stop_Range_Stop_Now(int magic_number)
  {
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         Print(" Error OrderSelect = " + IntegerToString(GetLastError()));

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
                  Print(" Error OrderModify = " + IntegerToString(GetLastError()));
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
                  Print("Errore nella modifica dell'ordine: ", IntegerToString(GetLastError()));
              }
           }
        }
     } 
  }
//+------------------------------------------------------------------+
// Cancella ordini pendenti subito (candela_chiusura = 0) o dopo un certo numero di candele
void CCancellazione::Cancella_Pendenti(bool close_buy, bool close_sell, int candela_chiusura)
  {
   for(int i = OrdersTotal()-1; i>=0; i--)
     {

      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         Print(" Error OrderSelect " + IntegerToString(GetLastError()));

      if((OrderType() == OP_BUYSTOP || OrderType() == OP_BUYLIMIT) && close_buy == true)
        {
         if(candela_chiusura == 0)
           {
            if(!OrderDelete(OrderTicket(),clrRed))
               Print(" Error OrderDelete " + IntegerToString(GetLastError()));
           }

         else
            if(candela_chiusura != 0 && OrderOpenTime()<= Time[candela_chiusura])
              {
               if(!OrderDelete(OrderTicket(),clrRed))
                  Print(" Error OrderDelete " + IntegerToString(GetLastError()));
              }
        }
      if((OrderType() == OP_SELLSTOP || OrderType() == OP_SELLLIMIT)&& close_sell == true)
        {
         if(candela_chiusura == 0)
           {
            if(!OrderDelete(OrderTicket(),clrRed))
               Print(" Error OrderDelete " + IntegerToString(GetLastError()));
           }
         else
            if(candela_chiusura != 0 && OrderOpenTime()<= Time[candela_chiusura])
              {
               if(!OrderDelete(OrderTicket(),clrRed))
                  Print(" Error OrderDelete " + IntegerToString(GetLastError()));
              }
        }
     }
  }
//+------------------------------------------------------------------+


// Chiudi Tot percentuale(0 = tutto) sell a tot candela (0 = ora)
void CChiusura::Chiudi_Sell(int percentuale,int candela_chiusura)
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
void CChiusura::Chiudi_Buy(int percentuale, int candela_chiusura)
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

// Chiudi quando l'operazione tocca la mediana
void CChiusura::Chiudi_Su_Mediana(int magic)
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

// Questa funzione chiude l'ordine aperto se raggiunge una certa perdita in denaro (-Perdita) Segno '-' davanti alla variabile Perdita (-50)
void CChiusura::Chiudi_Perdita_Tutto(int Perdita, int magic)
  {
   if(!OrderSelect(Ritorna_Numero_Ticket_Ordine_Aperto(magic,0),SELECT_BY_TICKET))
      Print("Errore selezione ordine:", IntegerToString(GetLastError()));

// Se il profitto di quest'ordine è minore o uguale a (Perdita)
   if(Order_Profit_Full() <= Perdita)
     {
      // Mi richiamo le due funzioni per chiudere l'ordine sia buy che sell
      Chiudi_Buy(0,0);
      Chiudi_Sell(0,0);
     }
  }

// Questa funzione fa lo stesso della precedente solo che per il profitto
void CChiusura::Chiudi_Profitto_Tutto(int Profitto,int magic)
  {
   if(!OrderSelect(Ritorna_Numero_Ticket_Ordine_Aperto(magic,0),SELECT_BY_TICKET))
      Print("Errore selezione ordine:", IntegerToString(GetLastError()));

   if(Order_Profit_Full() >= Profitto)
     {
      Chiudi_Buy(0,0);
      Chiudi_Sell(0,0);
     }
  }
// Questa funzione chiude le operazioni sul simbolo dell'ea se in giornata si raggiunge un massimo profitto o massima perdita
void CChiusura::Chiusura_Max_Perdita_Max_Profitto_Day(int Massimo_Profitto_Simbolo, int Massima_Perdita_Simbolo)
  {

   double Profitto_Perdita_Totale_Giornarliera = Ritorna_Profitto_Operazioni_Aperte_Simbolo()+Ritorna_Profitto_Operazioni_Chiuse_Giornata();

   if(Profitto_Perdita_Totale_Giornarliera >= Massimo_Profitto_Simbolo || Profitto_Perdita_Totale_Giornarliera <= Massima_Perdita_Simbolo)
     {

      for(int i = 0; i< OrdersTotal(); i++)
        {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
            Print("Errore selezione ordine: ", IntegerToString(GetLastError()));

         if(OrderSymbol()==Symbol())
           {
            if(!OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrRed))
               Print(" Error OrderClose ", IntegerToString(GetLastError()));

           }
        }
     }

  }
//+------------------------------------------------------------------+
// Questa funzione ritorna i lotti per rischiare un certa percentuale del capitale inserendo un certo numero di punti come stop loss
double CMoneyManagement::Rischio_Percentuale(double Percentuale_rischio, double Punti_Stop)
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
   double Somma_Da_Rischiare = AccountEquity()*(Percentuale_rischio/100);
// Ora moltiplichiamo lo stop loss in punti (500) esempio * il valore di 1 punto ad 1 lotto
// Tutto queto diviso per la somma che vogliamo rischiare (ottenuta facendo la percentuale prima)
   double Lotti_Dimensione = Somma_Da_Rischiare/(Punti_Stop *Valore_un_punto_un_lotto);

   return Lotti_Dimensione;
  }

// Questa funzione ritorna il numero di lotti per rischiare una certa somma di denaro per quell'operazione
double CMoneyManagement::Rischio_Denaro(double Somma_Da_Rischiare, double Punti_Stop)
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

// Questa funzione di tipo double ritorna il numero di lotti per recuperare l'operazione precedente chiusa in perdita
double CMoneyManagement::Ritorna_Lotti(double Perdita, int Take_Profit_in_punti,int Magic)
  {
   double Lots= 0 ;

// Se l'ultima operazione ha chiuso in perdita di un certa somma (Perdita_in_denaro)
// Ci deve essere un take profit fisso per fare questo calcolo(variabile d'ingresso)
// Se c'è stato almeno un ordine chiuso
   if(OrdersHistoryTotal()>=1)
     {
      if(!OrderSelect(Ritorna_Ultimo_Ticket_Chiuso(Magic),SELECT_BY_TICKET))
         Print(" Errore in selezione n. + ",IntegerToString(GetLastError()));
     }
// Se l'operazione è in perdita di un certo numero (perdita in denaro = variabile d'ingresso)
   if(Order_Profit_Full() <= Perdita)
     {
      // I lotti saranno calcolati con la funzione precedente Rischio_denaro
      // Che ci fornirà quanti lotti dobbiamo investire per vincere o perdere quella somma(che vogliamo recuperare)
      // Raggiungendo i punti del take profit
      Lots = Rischio_Denaro(-(Perdita),Take_Profit_in_punti);
      return Lots;
     }
   else
      return 0 ;
  }
// Invia una griglia di ordini BUYSTOP
void CGrid::Griglia_Buy(int tot_punti, int aumento_punti, int numero_ordini_da_inserire, double Lottaggio,int Take_in_punti,int Stop_in_punti,int magic)
  {

   double Livello_entrata = 0;

   for(int i = 0; i<numero_ordini_da_inserire ; i ++)
     {
      // Livello per il primo ordine
      Livello_entrata = Bid + tot_punti*Point();

      ticketbuystop = OrderSend(Symbol(),OP_BUYSTOP,Lottaggio,Livello_entrata,0,Livello_entrata - Stop_in_punti*Point(),Livello_entrata + Take_in_punti*Point()," Inserisco BUYSTOP Griglia ",magic,0,clrGreen);
      if(ticketbuystop<0)
         Print("Errore nell'invio ordine BUYSTOP: ", IntegerToString(GetLastError()));

      tot_punti += aumento_punti ;

     }
  }
// Invia una griglia di ordini SELLSTOP
void CGrid::Griglia_Sell(int tot_punti, int aumento_punti, int numero_ordini_da_inserire, double Lottaggio,int Take_in_punti,int Stop_in_punti,int magic)
  {

   double Livello_entrata = 0;

   for(int i = 0; i<numero_ordini_da_inserire ; i ++)
     {
      // Livello per il primo ordine
      Livello_entrata = Ask - tot_punti*Point();

      ticketsellstop = OrderSend(Symbol(),OP_SELLSTOP,Lottaggio,Livello_entrata,0,Livello_entrata + Stop_in_punti*Point(),Livello_entrata - Take_in_punti*Point()," Inserisco SELLSTOP Griglia ",magic,0,clrRed);
      if(ticketsellstop<0)
         Print("Errore nell'invio ordine SELLSTOP: ", IntegerToString(GetLastError()));

      tot_punti += aumento_punti ;

     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CCheck::Check_Lots(double Lotti_Operazione)
  {

   double max = MarketInfo(Symbol(),MODE_MAXLOT);
   double min = MarketInfo(Symbol(),MODE_MINLOT);

// Se i lotti sono minori al massimo +1 o sono minori al minimo -1
// Vuol dire che il lottaggio è oltre i limiti e mi ritorna falso
   if(Lotti_Operazione > max+1 || Lotti_Operazione < min-0.01)
      return false;
   else
      return true;
  }

// Questa funzione va richiamata dentro OnInit (Se questa funzione torna falso OnInit non parte o richiami ExpertRemove)
// L'utente inserisce l'input della password e che viene confrotato con la password e le altre variabili scritte qui dentro
bool CCheck::Controllo_Licenza(string input_Password_Licenza, string Password, string Nome_Conto, int Numero_Conto, datetime Scadenza)
  {

   if(input_Password_Licenza == Password && AccountNumber() == Numero_Conto  && AccountName()==Nome_Conto && TimeCurrent() < Scadenza)
      return true;
   else
      if(input_Password_Licenza != Password)
        {
         Alert(" La Password inserita è sbagliata ");
         return false;
        }
      else
         if(AccountNumber() != Numero_Conto)
           {
            Alert(" Il Numero del Conto è sbagliato ");
            return false;
           }
         else
            if(AccountName()!=Nome_Conto)
              {
               Alert(" Il Nome del conto è sbagliato ");
               return false;
              }
            else
               if(TimeCurrent()>= Scadenza)
                 {
                  Alert(" La Scadenza è stata raggiunta, rinnovare la licenza ");
                  return false;
                 }
               else
                  return false;
  }
//+------------------------------------------------------------------+
