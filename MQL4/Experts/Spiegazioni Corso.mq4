//+------------------------------------------------------------------+
//|                                            Spiegazioni Corso.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <My_Include_Classi.mqh>

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


extern int MagicNumber=321;
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
extern string NomeFile="Report";
extern int OrarioReport=23;
extern bool Trailing = false;
extern string password = "123456";

double TickValue = 0,TickSize=0;
double ticketbuy=-1,ticketsell=-1;
double LivelloEntrataSell=0,LivelloEntrataBuy=0;
double LivelloStopSell=0,LivelloStopBuy=0;
double LivelloTakeSell=0,LivelloTakeBuy=0;
bool condizionebuy=0,condizionesell=0;
double pips=0, RangeStop=0;
int contatore=0;

CInfo ObInfo;
CChiusura ObChiusura;
CModifica ObModifica;
CMoneyManagement ObMM;
CGrid ObGrid;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   pips = ObInfo.Pips();

   if(Controllo_Licenza(password)==false)
      ExpertRemove();

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

   datiultimoordine();

   ObChiusura.Chiusura_Max_Daily(MagicNumber,30,20);

   if(ObInfo.Nuova_Candela() == true)
     {

      if(ObInfo.Ci_Sono_Ordini(MagicNumber)==False && ObChiusura.Chiusura_Max_Daily(MagicNumber,30,20) == false)
        {

         //InvioOrdini();
         ObGrid.Griglia_Buy(10,10,5,0.1,20,30,MagicNumber,5);
         ObGrid.Griglia_Sell(10,10,5,0.1,20,30,MagicNumber,5);


        }
     }
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
            Lotti = RitornoLotti(RangeStop);

            ticketbuy=OrderSend(Symbol(),OP_BUYSTOP,Lotti,LivelloEntrataBuy,0,LivelloStopBuy,LivelloTakeBuy,"Invio BUYSTOP",MagicNumber,ExpirationDateTime,clrGreen);
            if(ticketbuy < 0)
               Print("Errore nell'invio del BUYSTOP: "+ IntegerToString(GetLastError()));
           }

         if(condizionesell)
           {
            LivelloEntrataSell=NormalizeDouble(Ask-EntrataPips*pips,Digits);
            LivelloStopSell=NormalizeDouble(LivelloEntrataSell+StopLoss*pips,Digits);
            LivelloTakeSell=NormalizeDouble(LivelloEntrataSell-TakeProfit*pips,Digits);
            RangeStop=NormalizeDouble(LivelloStopSell-LivelloEntrataSell,Digits);
            Lotti = RitornoLotti(RangeStop);

            ticketsell=OrderSend(Symbol(),OP_SELLSTOP,Lotti,LivelloEntrataSell,0,LivelloStopSell,LivelloTakeSell,"Invio SELLSTOP",MagicNumber,ExpirationDateTime,clrRed);
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
            Lotti = RitornoLotti(RangeStop);

            ticketbuy=OrderSend(Symbol(),OP_BUYLIMIT,Lotti,LivelloEntrataBuy,0,LivelloStopBuy,LivelloTakeBuy,"Invio BUYLIMIT",MagicNumber,ExpirationDateTime,clrGreen);
            if(ticketbuy < 0)
               Print("Errore nell'invio del BUYLIMIT: "+ IntegerToString(GetLastError()));
           }

         if(condizionesell)
           {
            LivelloEntrataSell=NormalizeDouble(Ask+EntrataPips*pips,Digits);
            LivelloStopSell=NormalizeDouble(LivelloEntrataSell+StopLoss*pips,Digits);
            LivelloTakeSell=NormalizeDouble(LivelloEntrataSell-TakeProfit*pips,Digits);
            RangeStop=NormalizeDouble(LivelloStopSell-LivelloEntrataSell,Digits);
            Lotti = RitornoLotti(RangeStop);

            ticketsell=OrderSend(Symbol(),OP_SELLLIMIT,Lotti,LivelloEntrataSell,0,LivelloStopSell,LivelloTakeSell,"Invio SELLLIMIT",MagicNumber,ExpirationDateTime,clrRed);
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
            Lotti = RitornoLotti(RangeStop);

            ticketbuy=OrderSend(Symbol(),OP_BUY,Lotti,Ask,0,LivelloStopBuy,LivelloTakeBuy,"Invio BUY",MagicNumber,0,clrGreen);
            if(ticketbuy < 0)
               Print("Errore nell'invio del BUY: "+ IntegerToString(GetLastError()));
           }

         if(condizionesell)
           {

            LivelloStopSell=NormalizeDouble(Bid+StopLoss*pips,Digits);
            LivelloTakeSell=NormalizeDouble(Bid-TakeProfit*pips,Digits);
            RangeStop=NormalizeDouble(LivelloStopSell-Bid,Digits);
            Lotti = RitornoLotti(RangeStop);

            ticketsell=OrderSend(Symbol(),OP_SELL,Lotti,Bid,0,LivelloStopSell,LivelloTakeSell,"Invio SELL",MagicNumber,0,clrRed);
            if(ticketsell<0)
               Print("Errore nell'invio del SELL: "+ IntegerToString(GetLastError()));
           }

         break;

     }
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

         NumeroLotti= ObMM.Rischio_Percentuale(RischioPercentuale,PuntiStopLoss);
         break;

      //Caso dei Lotti in denaro
      case 2:

         NumeroLotti= ObMM.Rischio_Denaro(RischioDenaro,PuntiStopLoss);
         break;

     }
   return NumeroLotti;
  }
//+------------------------------------------------------------------+
// Questa funzione va richiamata dentro OnInit (Se questa funzione torna falso OnInit non parte o richiami ExpertRemove)
// L'utente inserisce l'input della password che viene confrotato con la password e le altre variabili scritte qui dentro
bool Controllo_Licenza(string input_Password)
  {

   string Password = "123456";
   string Nome_Conto = "Federico";
   int Numero_Conto = 61394208;
   datetime Scadenza = D'2024.03.01 00:00:00';

   if(input_Password == Password &&
      AccountNumber() == Numero_Conto  &&
      AccountName()==Nome_Conto &&
      TimeCurrent() < Scadenza)
      return true;

   if(input_Password != Password)
     {
      Alert(" La Password inserita è sbagliata ");
      return false;
     }

   if(AccountNumber() != Numero_Conto)
     {
      Alert(" Il Numero del Conto è sbagliato ");
      return false;
     }

   if(AccountName()!=Nome_Conto)
     {
      Alert(" Il Nome del conto è sbagliato ");
      return false;
     }

   if(TimeCurrent()>= Scadenza)
     {
      Alert(" La Scadenza è stata raggiunta, rinnovare la licenza ");
      return false;
     }

   return false;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void datiultimoordine()
  {


   if(!OrderSelect(ObInfo.Ritorna_Ultimo_Ticket_Chiuso(MagicNumber),SELECT_BY_TICKET))
      ObInfo.Print_Errore("errore selezione ordine ultimo ticket");



  }
//+------------------------------------------------------------------+
