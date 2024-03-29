//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "FQ Trading"
#property version   "1.00"
#property strict

#import "StandardLibs.ex4"
#import

#include <Controls\Panel.mqh>
#include <Controls\Label.mqh>
#include <Controls\Button.mqh>
#include <Controls\Edit.mqh>
#include <Include_Completo.mqh>
#include <ChartObjects\ChartObjectsFibo.mqh>

CPanel P1,P2,P3;
CLabel L1,L2,L3,L4,L5,L6,L7,L8,L9;
CButton B1,B2,B3,B4,B5,B6,B7,B8,B9;
CEdit E1,E2,E3,E4,E5,E6,E7,E8,E9;

double Lottaggio_Iniziale=0;
int MagicNumber=0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   Panel();
   EventSetTimer(1);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectsDeleteAll(0,0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   L4.Text((string)Seconds());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   closing_deleting_Trade();
   
   double spread=(Ask-Bid)/Point();

   L5.Text(DoubleToStr(spread,0));

   if(IsTesting())
      backtest();
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Panel()
  {
   P1.Create(0, "P1", 0, 18, 18, 380, 200);
   P1.ColorBackground(clrWhite);
   P1.ColorBorder(clrGray);

   P2.Create(0, "P2", 0, 0, 0, 90, 182);
   P2.Shift(290,18);
   P2.ColorBackground(clrWhite);
   P2.ColorBorder(clrGray);

   P3.Create(0, "P3", 0, 0, 0, 273, 50);
   P3.Shift(18,150);
   P3.ColorBackground(clrWhite);
   P3.ColorBorder(clrGray);

   B1.Create(0, "B1", 0, 0, 0, 70, 30);
   B1.Shift(215,110);
   B1.Text("DELETE BUY");
   B1.ColorBackground(clrWhiteSmoke);
   B1.ColorBorder(clrGreen);
   B1.Pressed(false);
   B1.FontSize(9);

   B2.Create(0, "B2", 0, 0, 0, 70, 30);
   B2.Shift(215,70);
   B2.Text("DELETE SELL");
   B2.ColorBackground(clrWhiteSmoke);
   B2.ColorBorder(clrRed);
   B2.Pressed(false);
   B2.FontSize(9);

   B3.Create(0, "B3", 0, 0, 0, 70, 30);
   B3.Shift(215,160);
   B3.Text("DELETE ALL");
   B3.ColorBackground(clrLinen);
   B3.Pressed(false);
   B3.FontSize(9);

   B4.Create(0, "B4", 0, 0, 0, 70, 30);
   B4.Shift(125,110);
   B4.Text("CLOSE BUY");
   B4.ColorBackground(clrSnow);
   B4.ColorBorder(clrGreen);
   B4.Pressed(false);
   B4.FontSize(9);

   B5.Create(0, "B5", 0, 0, 0, 70, 30);
   B5.Shift(125,70);
   B5.Text("CLOSE SELL");
   B5.ColorBackground(clrSnow);
   B5.ColorBorder(clrRed);
   B5.Pressed(false);
   B5.FontSize(9);

   B6.Create(0, "B6", 0, 0, 0, 70, 30);
   B6.Shift(125,160);
   B6.Text("CLOSE ALL");
   B6.ColorBackground(clrWheat);
   B6.Pressed(false);
   B6.Pressed(9);

   B7.Create(0, "B7", 0, 0, 0, 70, 30);
   B7.Shift(35,110);
   B7.Text("BUY");
   B7.ColorBackground(clrLimeGreen);
   B7.Pressed(false);
   B7.FontSize(9);

   B8.Create(0, "B8", 0, 0, 0, 70, 30);
   B8.Shift(35,70);
   B8.Text("SELL");
   B8.ColorBackground(clrRed);
   B8.Pressed(false);
   B8.FontSize(9);

   B9.Create(0, "B9", 0, 0, 0, 70, 30);
   B9.Shift(35,160);
   B9.Text("BOTH");
   B9.ColorBackground(clrTurquoise);
   B9.Pressed(false);
   B9.FontSize(9);

//Lotti
   E1.Create(0,"E1",0,0,0,30,20);
   E1.Shift(70,35);
   E1.Text("0.5");
   L1.Create(0,"L1",0,0,0,30,30);
   L1.Shift(35,35);
   L1.Text("Lots:");
   L1.FontSize(10);

//Magic Number
   E2.Create(0,"E2",0,0,0,30,20);
   E2.Shift(165,35);
   E2.Text("777");
   L2.Create(0,"L2",0,0,0,30,30);
   L2.Shift(125,35);
   L2.Text("Magic:");
   L2.FontSize(10);

//Numero punti entrata ordini
   E8.Create(0,"E8",0,0,0,30,20);
   E8.Shift(334,35);
   E8.Text("100");
   E8.FontSize(8);
   L8.Create(0,"L8",0,0,0,30,30);
   L8.Shift(295,35);
   L8.Text("Entry:");
   L8.FontSize(10);

//Numero punti stop
   E7.Create(0,"E7",0,0,0,30,20);
   E7.Shift(334,95);
   E7.Text("10");
   E7.FontSize(8);
   L7.Create(0,"L7",0,0,0,30,30);
   L7.Shift(295,95);
   L7.Text("Loss:");
   L7.FontSize(10);

//Numero punti stop
   E9.Create(0,"E9",0,0,0,30,20);
   E9.Shift(334,65);
   E9.Text("100");
   E9.FontSize(8);
   L9.Create(0,"L9",0,0,0,30,30);
   L9.Shift(295,65);
   L9.Text("Stop:");
   L9.FontSize(10);

//Timer Candela
   L4.Create(0,"L4",0,0,0,30,30);
   L4.Shift(300,120);
   L4.FontSize(20);
   L4.Color(clrDarkBlue);

//Spread
   L6.Create(0,"L6",0,0,0,30,30);
   L6.Shift(215,35);
   L6.Text("Spread:");
   L6.FontSize(10);
   L6.Color(clrBlack);

   L5.Create(0,"L5",0,0,0,30,30);
   L5.Shift(265,35);
   L5.FontSize(10);
   L5.Color(clrDarkRed);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void griglia_sell_volatility(double Lottaggio,int magic)
  {

   double Livello_entrata=0;
   double Livello_stop=0;

   int Entry=(int)ObjectGetString(0,"E8",OBJPROP_TEXT,0);
   int Stop=(int)ObjectGetString(0,"E9",OBJPROP_TEXT,0);

   Livello_entrata = NormalizeDouble(Ask-Entry*Point(),Digits);
   Livello_stop = NormalizeDouble(Livello_entrata+Stop*Point(),Digits);

   ticketsellstop=OrderSend(Symbol(),OP_SELLSTOP,Lottaggio,Livello_entrata,0,Livello_stop,NULL,"Inserisco SELLSTOP",MagicNumber,0,clrRed);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void griglia_buy_volatility(double Lottaggio,int magic)
  {

   double Livello_entrata=0;
   double Livello_stop=0;

   int Entry=(int)ObjectGetString(0,"E8",OBJPROP_TEXT,0);
   int Stop=(int)ObjectGetString(0,"E9",OBJPROP_TEXT,0);

   Livello_entrata = NormalizeDouble(Bid+Entry*Point(),Digits);
   Livello_stop = NormalizeDouble(Livello_entrata-Stop*Point(),Digits);

   ticketbuystop=OrderSend(Symbol(),OP_BUYSTOP,Lottaggio,Livello_entrata,0,Livello_stop,NULL,"Inserisco BUYSTOP",MagicNumber,0,clrGreen);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // Event ID
                  const long& lparam,   // Parameter of type long event
                  const double& dparam, // Parameter of type double event
                  const string& sparam  // Parameter of type string events
                 )
  {

   if(id== CHARTEVENT_OBJECT_CLICK)
     {
      Lottaggio_Iniziale=NormalizeDouble(StringToDouble(ObjectGetString(0,"E1",OBJPROP_TEXT,0)),2);
      MagicNumber=(int)ObjectGetString(0,"E2",OBJPROP_TEXT,0);

      if(sparam=="B9")
        {
         //Apri griglia sia BUY che SELL
         griglia_buy_volatility(Lottaggio_Iniziale,MagicNumber);
         griglia_sell_volatility(Lottaggio_Iniziale,MagicNumber);
         B9.Pressed(false);
        }
      if(sparam=="B8")
        {
         //Apri griglia SELL
         griglia_sell_volatility(Lottaggio_Iniziale,MagicNumber);
         B8.Pressed(false);
        }
      if(sparam=="B7")
        {
         //Apri griglia BUY
         griglia_buy_volatility(Lottaggio_Iniziale,MagicNumber);
         B7.Pressed(false);
        }
      if(sparam=="B6")
        {
         //Chiudo tutti gli ordini aperti
         Chiudi_Buy(0,0);
         Chiudi_Sell(0,0);
         B6.Pressed(false);
        }
      if(sparam=="B5")
        {
         //Chiudo tutti i SELL aperti
         Chiudi_Sell(0,0);
         B5.Pressed(false);
        }
      if(sparam=="B4")
        {
         //Chiudo tutti i BUY aperti
         Chiudi_Buy(0,0);
         B4.Pressed(false);
        }
      if(sparam=="B3")
        {
         //Cancello tutti gli ordini pendenti
         Cancella(true,true,0);
         B3.Pressed(false);
        }
      if(sparam=="B2")
        {
         //Cancello tutti gli ordini pendenti SELL
         Cancella(false,true,0);
         B2.Pressed(false);
        }
      if(sparam=="B1")
        {
         //Cancello tutti gli ordini pendenti BUY
         Cancella(true,false,0);
         B1.Pressed(false);
        }
     }
  };
//+------------------------------------------------------------------+
void backtest()
  {

   Lottaggio_Iniziale=NormalizeDouble(StringToDouble(ObjectGetString(0,"E1",OBJPROP_TEXT,0)),2);
   MagicNumber=(int)ObjectGetString(0,"E2",OBJPROP_TEXT,0);

   if(B9.Pressed())
     {
      //Apri griglia sia BUY che SELL
      griglia_buy_volatility(Lottaggio_Iniziale,MagicNumber);
      griglia_sell_volatility(Lottaggio_Iniziale,MagicNumber);
      B9.Pressed(false);
     }
   if(B8.Pressed())
     {
      //Apri griglia SELL
      griglia_sell_volatility(Lottaggio_Iniziale,MagicNumber);
      B8.Pressed(false);
     }

   if(B7.Pressed())
     {
      //Apri griglia BUY
      griglia_buy_volatility(Lottaggio_Iniziale,MagicNumber);
      B7.Pressed(false);
     }

   if(B6.Pressed())
     {
      //Chiudo tutti gli ordini aperti
      Chiudi_Buy(0,0);
      Chiudi_Sell(0,0);
      B6.Pressed(false);
     }
   if(B5.Pressed())
     {
      //Chiudo tutti i SELL aperti
      Chiudi_Sell(0,0);
      B5.Pressed(false);
     }
   if(B4.Pressed())
     {
      //Chiudo tutti i BUY aperti
      Chiudi_Buy(0,0);
      B4.Pressed(false);
     }
   if(B3.Pressed())
     {
      //Cancello tutti gli ordini pendenti
      Cancella(true,true,0);
      B3.Pressed(false);
     }
   if(B2.Pressed())
     {
      //Cancello tutti gli ordini pendenti SELL
      Cancella(false,true,0);
      B2.Pressed(false);
     }
   if(B1.Pressed())
     {
      //Cancello tutti gli ordini pendenti BUY
      Cancella(true,false,0);
      B1.Pressed(false);
     }
  }
//+------------------------------------------------------------------+
void closing_deleting_Trade()
  {

   double variabile_perdita= NormalizeDouble(StringToDouble(ObjectGetString(0,"E7",OBJPROP_TEXT,0)),2);

//Selezioniamo l'ultimo ordine attualmente aperto
   if(!OrderSelect(Ritorna_Numero_Ticket_Ordine_Aperto(MagicNumber,0),SELECT_BY_TICKET))
      Print_Error();

//Se c'è una perdita di tot euro (variabile perdita)
   if(OrderProfitFull()<= -variabile_perdita)
     {
     //Chiudi l'ordine 
      if(OrderType()==OP_SELL)
        {
         Chiudi_Sell(0,0);
        }
      if(OrderType()==OP_BUY)
        {
         Chiudi_Buy(0,0);
        }
     }

  }
//+------------------------------------------------------------------+

// Notizia NFP 
/*
La registrazione mi mostra che solo per 3 secondi si sono fermati i tick
e poi hanno continuato a scorrere.
Quindi tecnicamente il codice che controlla la perdita in denaro dovrebbe girare
ugualmente.

15:29:59 = Bid 1.05372 Ask 1.05373
15:30:00 = Bid 1.05362 Ask 1.05363
15:30:01 fino a 15:30:03 = Bid 1.05381 Ask 1.05382
15:30:04 = Bid 1.04945 Ask 1.04946
*/