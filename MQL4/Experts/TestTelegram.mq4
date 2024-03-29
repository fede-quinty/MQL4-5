//+------------------------------------------------------------------+
//|                                                 TestTelegram.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <Telegram.mqh>
#include <My_Include_Classi.mqh>

extern int MagicNumber =342;
extern int StopLoss = 30;
extern int TakeProfit =60;
extern double Lotti =0.1;

bool chiusura_buy=false,chiusura_sell=false;

CInfo Info;
CChiusura Chiusura;

// -1002059752852 Chat id Canale
//+------------------------------------------------------------------+
//|   CMyBot                                                         |
//+------------------------------------------------------------------+
class CMyBot: public CCustomBot
  {
public:
   void              ProcessMessages(void)
     {

      for(int i=0; i<m_chats.Total(); i++)
        {
         CCustomChat *chat=m_chats.GetNodeAtIndex(i);

         //--- if the message is not processed
         if(!chat.m_new_one.done)
           {
            chat.m_new_one.done=true;
            string text=chat.m_new_one.message_text;

            //--- start
            if(text=="/Start")
               SendMessage(chat.m_id,"Ciao, sono il bot . \xF680");

            //--- help
            if(text=="/Help")

               SendMessage
               (
                  chat.m_id,
                  "Lista Comandi: "
                  "\n/Start"
                  "\n/Help"
                  "\n/Buy"
                  "\n/Sell"
                  "\n/ChiudiBuy"
                  "\n/ChiudiSell"
                  "\n/OrdiniTotali"
                  "\n/RisultatiGiornata"
               );

            if(text=="/Buy")
              {
               int ticketbuy = OrderSend(Symbol(),OP_BUY,Lotti,Ask,0,Ask-StopLoss*pips,Ask+TakeProfit*pips,"Invio Buy",MagicNumber,0,clrGreen);
               Info.Print_Errore("Errore invio Buy");
              }
            if(text=="/Sell")
              {
               int ticketsell=OrderSend(Symbol(),OP_SELL,Lotti,Bid,0,Bid+StopLoss*pips,Bid-TakeProfit*pips,"Invio Sell",MagicNumber,0,clrRed);
               Info.Print_Errore("Errore invio Sell");
              }
            if(text=="/ChiudiBuy")
              {
               chiusura_buy=true;
               SendMessage(chat.m_id,"Sto chiudendo i BUY");
              }
            if(text=="/ChiudiSell")
              {
               chiusura_sell=true;
               SendMessage(chat.m_id,"Sto chiudendo i SELL");
              }
            if(text=="/OrdiniTotali")
              {
               SendMessage(chat.m_id,StringFormat("Ci sono %s ordini inseriti a mercato", (string)OrdersTotal()));
              }
            if(text=="/RisultatiGiornata")
              {
               double totale = NormalizeDouble(
                                  Info.Ritorna_Profitto_Operazioni_Chiuse_Giornata(MagicNumber)+
                                  Info.Ritorna_Profitto_Ordini_Aperti(MagicNumber,OP_SELL)+
                                  Info.Ritorna_Profitto_Ordini_Aperti(MagicNumber,OP_BUY),
                                  2);

               SendMessage(chat.m_id,StringFormat("Il risultato giornaliero è di: %s ", (string)totale));
              }
           }
        }
     }
  };

//---
input string InpToken="6417920418:AAFMDsGH-N6lkhodxQ70V6PpTqudCZas8xg";//Token
//---
CMyBot bot;

int getme_result;
double pips=0;
bool medias=false;
//+------------------------------------------------------------------+
//|   OnInit                                                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   pips = Info.Pips();
//--- set token
   bot.Token(InpToken);
//--- check token
   getme_result=bot.GetMe();
//--- run timer
   EventSetTimer(1);
   OnTimer();
//--- done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|   OnDeinit                                                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {

  //mediasotto();

   if(chiusura_buy)
     {
      Chiusura.Chiudi_Buy(MagicNumber);
     }

   if(chiusura_sell)
     {
      Chiusura.Chiudi_Sell(MagicNumber);
     }

   if(CiSonoOrdini(MagicNumber,OP_BUY)==false)
      chiusura_buy=false;
   if(CiSonoOrdini(MagicNumber,OP_SELL)==False)
      chiusura_sell=false;

  }
//+------------------------------------------------------------------+
//|   OnTimer                                                        |
//+------------------------------------------------------------------+
void OnTimer()
  {
//--- show error message end exit
   if(getme_result!=0)
     {
      Comment("Error: ",GetErrorDescription(getme_result));
      return;
     }
//--- show bot name
   Comment("Bot name: ",bot.Name());
//--- reading messages
   bot.GetUpdates();
//--- processing messages
   bot.ProcessMessages();

  }
//+------------------------------------------------------------------+

// Questa funzione ritorna true se ci sono ordini aperti dal nostro EA
bool CiSonoOrdini(int magic, ENUM_ORDER_TYPE tipo_ordine)
  {
   for(int i = 0 ; i < OrdersTotal() ; i++)
     {
      // Selezioniamo il numero dell'ordine in base alla posizione
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         Info.Print_Errore("Errore Selezione Ordine");
         continue;
        }
      // Se l'ordine selezionato ha il nostro simbolo e il nostro magic number
      if(OrderSymbol() == Symbol() && OrderMagicNumber()==magic && OrderType()== tipo_ordine)
         // Se si vuol dire che ci sono ordini aperti dal nostro expert sul grafico attuale
         return(true);
     }
   return(false);
  }

//+------------------------------------------------------------------+
bool mediasotto()
  {
   double media = iMA(Symbol(),Period(),14,0,MODE_SMA,PRICE_CLOSE,0);

   if(media < Close[0])
     {
      bot.SendMessage(-1002059752852,"Il trend è rialzista");
      return true;
     }
   else
      return false;
  }
//+------------------------------------------------------------------+
