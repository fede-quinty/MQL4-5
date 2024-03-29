//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.03"
#property strict

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1  clrBlue
#property indicator_color2  clrRed
#property indicator_color3  clrDeepSkyBlue
#property indicator_color4  clrMagenta
#property indicator_color5  clrLightSalmon
#property indicator_color6  clrPurple
#property indicator_color7  clrDarkGreen
#property indicator_color8  clrSpringGreen
#property indicator_width1  1
#property indicator_width2  1
#property indicator_width3  1
#property indicator_width4  1
#property indicator_width5  1
#property indicator_width6  1
#property indicator_width7  1
#property indicator_width8  1


#include <Controls\Button.mqh>

CButton B;

int cont = 0;
string primo_click="",secondo_click="";

string comment_2="";                    //Calculation Options
int ROCPeriod=5;                        //ROC Period (if using ROC Mode)

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input string IndicatorName="Currency Strenght ";      //Name
input int RSIPeriod=14;                //Oscillator Period
input int SmoothingPeriod=5;           //Slowing

ENUM_TIMEFRAMES LinesTimeFrame=PERIOD_CURRENT;   //Strength Lines Time Frame

input string av="";   //Lines Options
input bool DrawAllCurrencies=true;    //Draw All Currency

input string bv="";//Button Options
input int fontsize = 9; //Font_size

bool LimitBars=true;                   //Limit the number of bars to calculate
int MaxBars=1000;                 //Number of bars to calculate

string CurrPrefix="";           //Pairs Prefix
string CurrSuffix="";           //Pairs Suffix

bool UseEUR=true;                //EUR
bool UseUSD=true;                //USD
bool UseGBP=true;                //GBP
bool UseJPY=true;                //JPY
bool UseAUD=true;                //AUD
bool UseNZD=true;                //NZD
bool UseCAD=true;                //CAD
bool UseCHF=true;                //CHF

color LabelColor=clrBlack;       //Label Color
color EURColor=clrLightSlateGray;//EUR
color USDColor=clrRed;           //USD
color GBPColor=clrDeepSkyBlue;   //GBP
color JPYColor=clrMagenta;       //JPY
color AUDColor=clrLightSalmon;   //AUD
color NZDColor=clrPurple;        //NZD
color CADColor=clrDarkGreen;     //CAD
color CHFColor=clrMediumSeaGreen;//CHF

int NormalWidth=1;               //Width for Currencies not on chart
int SelectedWidth=3;             //Width for Currencies on chart


//--- indicator buffers
double EUR[];
double GBP[];
double USD[];
double JPY[];
double AUD[];
double NZD[];
double CAD[];
double CHF[];

double PreChecks=false;

string AllPairs[]=
  {
   "AUDCAD",
   "AUDCHF",
   "AUDJPY",
   "AUDNZD",
   "AUDUSD",
   "CADCHF",
   "CADJPY",
   "CHFJPY",
   "EURAUD",
   "EURCAD",
   "EURCHF",
   "EURGBP",
   "EURJPY",
   "EURNZD",
   "EURUSD",
   "GBPAUD",
   "GBPCAD",
   "GBPCHF",
   "GBPJPY",
   "GBPNZD",
   "GBPUSD",
   "NZDCAD",
   "NZDCHF",
   "NZDJPY",
   "NZDUSD",
   "USDCAD",
   "USDCHF",
   "USDJPY"
  };

//List all the currencies
string AllCurrencies[]=
  {
   "EUR",
   "USD",
   "GBP",
   "JPY",
   "AUD",
   "NZD",
   "CAD",
   "CHF"
  };

color Colori_Currencies[]=
  {
   clrLightSlateGray,
   clrRed,
   clrDeepSkyBlue,
   clrMagenta,
   clrLightSalmon,
   clrPurple,
   clrDarkGreen,
   clrMediumSeaGreen,
  };

string EUR_Pairs[7];
string USD_Pairs[7];
string GBP_Pairs[7];
string JPY_Pairs[7];
string CAD_Pairs[7];
string AUD_Pairs[7];
string NZD_Pairs[7];
string CHF_Pairs[7];

string CurrBase;
string CurrQuote;

double Base[];
double Quote[];

int CurrenciesUsed=0;
int RefreshCount=0;

datetime LastTotalRefresh=TimeCurrent();

int TotalRefreshInterval=40;
int LinesTF=LinesTimeFrame;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   creazione_pulsanti();

   IndicatorSetString(INDICATOR_SHORTNAME,IndicatorName);

   if(LinesTF==PERIOD_CURRENT || (LinesTF!=PERIOD_CURRENT && LinesTF<Period()))
      LinesTF=Period();
   else
      LinesTF=LinesTimeFrame;

   IndicatorDigits(4);
   DetectCurrencies();
   LastTotalRefresh=TimeCurrent();
   ChartSetInteger(ChartID(),CHART_EVENT_OBJECT_CREATE,true);

   IndicatorShortName(IndicatorName);

   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,0);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DOT);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrGray);

   int Width=NormalWidth;
   int DrawStyle=DRAW_LINE;
   if(StringFind(Symbol(),"EUR",0)>=0)
     {
      Width=SelectedWidth;
     }
   else
     {
      Width=NormalWidth;
     }
   if(StringFind(Symbol(),"EUR",0)>=0 || DrawAllCurrencies)
     {
      DrawStyle=DRAW_LINE;
     }
   else
     {
      DrawStyle=DRAW_NONE;
     }
   SetIndexStyle(0,DrawStyle,STYLE_SOLID,Width,EURColor);
   SetIndexBuffer(0,EUR);
   SetIndexLabel(0,"EUR");

   if(StringFind(Symbol(),"GBP",0)>=0)
     {
      Width=SelectedWidth;
     }
   else
     {
      Width=NormalWidth;
     }
   if(StringFind(Symbol(),"GBP",0)>=0 || DrawAllCurrencies)
     {
      DrawStyle=DRAW_LINE;
     }
   else
     {
      DrawStyle=DRAW_NONE;
     }
   SetIndexStyle(1,DrawStyle,STYLE_SOLID,Width,GBPColor);
   SetIndexBuffer(1,GBP);
   SetIndexLabel(1,"GBP");

   if(StringFind(Symbol(),"USD",0)>=0)
     {
      Width=SelectedWidth;
     }
   else
     {
      Width=NormalWidth;
     }
   if(StringFind(Symbol(),"USD",0)>=0 || DrawAllCurrencies)
     {
      DrawStyle=DRAW_LINE;
     }
   else
     {
      DrawStyle=DRAW_NONE;
     }
   SetIndexStyle(2,DrawStyle,STYLE_SOLID,Width,USDColor);
   SetIndexBuffer(2,USD);
   SetIndexLabel(2,"USD");

   if(StringFind(Symbol(),"JPY",0)>=0)
     {
      Width=SelectedWidth;
     }
   else
     {
      Width=NormalWidth;
     }
   if(StringFind(Symbol(),"JPY",0)>=0 || DrawAllCurrencies)
     {
      DrawStyle=DRAW_LINE;
     }
   else
     {
      DrawStyle=DRAW_NONE;
     }
   SetIndexStyle(3,DrawStyle,STYLE_SOLID,Width,JPYColor);
   SetIndexBuffer(3,JPY);
   SetIndexLabel(3,"JPY");

   if(StringFind(Symbol(),"AUD",0)>=0)
     {
      Width=SelectedWidth;
     }
   else
     {
      Width=NormalWidth;
     }
   if(StringFind(Symbol(),"AUD",0)>=0 || DrawAllCurrencies)
     {
      DrawStyle=DRAW_LINE;
     }
   else
     {
      DrawStyle=DRAW_NONE;
     }
   SetIndexStyle(4,DrawStyle,STYLE_SOLID,Width,AUDColor);
   SetIndexBuffer(4,AUD);
   SetIndexLabel(4,"AUD");

   if(StringFind(Symbol(),"NZD",0)>=0)
     {
      Width=SelectedWidth;
     }
   else
     {
      Width=NormalWidth;
     }
   if(StringFind(Symbol(),"NZD",0)>=0 || DrawAllCurrencies)
     {
      DrawStyle=DRAW_LINE;
     }
   else
     {
      DrawStyle=DRAW_NONE;
     }
   SetIndexStyle(5,DrawStyle,STYLE_SOLID,Width,NZDColor);
   SetIndexBuffer(5,NZD);
   SetIndexLabel(5,"NZD");

   if(StringFind(Symbol(),"CAD",0)>=0)
     {
      Width=SelectedWidth;
     }
   else
     {
      Width=NormalWidth;
     }
   if(StringFind(Symbol(),"CAD",0)>=0 || DrawAllCurrencies)
     {
      DrawStyle=DRAW_LINE;
     }
   else
     {
      DrawStyle=DRAW_NONE;
     }
   SetIndexStyle(6,DrawStyle,STYLE_SOLID,Width,CADColor);
   SetIndexBuffer(6,CAD);
   SetIndexLabel(6,"CAD");

   if(StringFind(Symbol(),"CHF",0)>=0)
     {
      Width=SelectedWidth;
     }
   else
     {
      Width=NormalWidth;
     }
   if(StringFind(Symbol(),"CHF",0)>=0 || DrawAllCurrencies)
     {
      DrawStyle=DRAW_LINE;
     }
   else
     {
      DrawStyle=DRAW_NONE;
     }
   SetIndexStyle(7,DrawStyle,STYLE_SOLID,Width,CHFColor);
   SetIndexBuffer(7,CHF);
   SetIndexLabel(7,"CHF");

   PopulatePairs();
   CalculateBuffers(MaxBars);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {

   int limit;
//---

   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
     {
      limit++;
     }

   if(TimeCurrent()>(LastTotalRefresh+TotalRefreshInterval))
     {
      limit=MaxBars;
      LastTotalRefresh=TimeCurrent();
     }

   if(LimitBars && limit>MaxBars)
      limit=MaxBars;

   if(Bars<(limit+RSIPeriod))
      limit=Bars;

   CalculateBuffers(limit);

   if(IsNewCandle())
     {
      CalculateBuffers(2);
     }

   return rates_total;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//Bisogna checkare che il primo click sia diverso dal secondo click
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(cont==0)
        {

         primo_click=sparam;
         cont++;

        }
      if(cont>=1)
        {

         secondo_click=sparam;

         if(secondo_click != primo_click)
           {

            ChartSetSymbolPeriod(0,primo_click+secondo_click,Period());
            ChartSetSymbolPeriod(0,secondo_click+primo_click,Period());

            ObjectSetInteger(0,primo_click,OBJPROP_STATE,false);
            ObjectSetInteger(0,secondo_click,OBJPROP_STATE,false);

            cont=0;
            primo_click="";
            secondo_click="";

           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateBuffers(int limit)
  {
   if(limit>ArraySize(EUR))
      limit=ArraySize(EUR);

   for(int i=0; i<limit; i++)
     {

      CalculateRSITotMA(i);

     }

   CopyBaseQuote();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime NewMinute=TimeCurrent();
bool IsNewMinute()
  {
   if(NewMinute==iTime(Symbol(),PERIOD_M1,0))
      return false;
   else
     {
      NewMinute=iTime(Symbol(),PERIOD_M1,0);
      return true;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime NewCandleTime=TimeCurrent();

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewCandle()
  {
   if(NewCandleTime==iTime(Symbol(),0,0))
      return false;
   else
     {
      NewCandleTime=iTime(Symbol(),0,0);
      return true;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DetectCurrencies()
  {
   string Curr1="";
   string Curr2="";
   int Curr1Pos = -1, Curr2Pos = -1;
   for(int i=0; i<ArraySize(AllCurrencies); i++)
     {
      int Curr1PosTmp=StringFind(Symbol(),AllCurrencies[i],0);
      int Curr2PosTmp=StringFind(Symbol(),AllCurrencies[i],0);
      if(Curr1=="" && Curr1PosTmp!=-1)
        {
         Curr1=AllCurrencies[i];
         Curr1Pos=Curr1PosTmp;
        }
      if(Curr1!="" && Curr2PosTmp!=-1)
        {
         Curr2=AllCurrencies[i];
         Curr2Pos=Curr2PosTmp;
        }
     }
   if(Curr1Pos<Curr2Pos)
     {
      CurrBase=Curr1;
      CurrQuote=Curr2;
     }
   else
     {
      CurrBase=Curr2;
      CurrQuote=Curr1;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DetectPrefixSuffix()
  {
   for(int i=0; i<ArraySize(AllPairs); i++)
     {
      if(StringFind(Symbol(),AllPairs[i],0)>=0)
        {
         string SymbTemp=Symbol();
         int res=StringReplace(SymbTemp,AllPairs[i]," ");
         string PrSuTemp[];
         res=StringSplit(SymbTemp,StringGetCharacter(" ",0),PrSuTemp);
         CurrPrefix=PrSuTemp[0];
         CurrSuffix=PrSuTemp[1];
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PopulatePairs()
  {
   if(StringLen(CurrPrefix)==0 && StringLen(CurrSuffix)==0)
     {
      DetectPrefixSuffix();
     }
   CurrenciesUsed=0;
   if(UseEUR)
     {
      CurrenciesUsed++;
      int j=0;
      for(int i=0; i<ArraySize(AllPairs); i++)
        {
         if(StringFind(AllPairs[i],"EUR",0)!=-1)
           {
            if(UseAUD && StringFind(AllPairs[i],"AUD",0)!=-1)
              {
               EUR_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseGBP && StringFind(AllPairs[i],"GBP",0)!=-1)
              {
               EUR_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseUSD && StringFind(AllPairs[i],"USD",0)!=-1)
              {
               EUR_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseNZD && StringFind(AllPairs[i],"NZD",0)!=-1)
              {
               EUR_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseCAD && StringFind(AllPairs[i],"CAD",0)!=-1)
              {
               EUR_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseCHF && StringFind(AllPairs[i],"CHF",0)!=-1)
              {
               EUR_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseJPY && StringFind(AllPairs[i],"JPY",0)!=-1)
              {
               EUR_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
           }
        }
     }
   if(UseUSD)
     {
      CurrenciesUsed++;
      int j=0;
      for(int i=0; i<ArraySize(AllPairs); i++)
        {
         if(StringFind(AllPairs[i],"USD",0)!=-1)
           {
            if(UseAUD && StringFind(AllPairs[i],"AUD",0)!=-1)
              {
               USD_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseGBP && StringFind(AllPairs[i],"GBP",0)!=-1)
              {
               USD_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseEUR && StringFind(AllPairs[i],"EUR",0)!=-1)
              {
               USD_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseNZD && StringFind(AllPairs[i],"NZD",0)!=-1)
              {
               USD_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseCAD && StringFind(AllPairs[i],"CAD",0)!=-1)
              {
               USD_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseCHF && StringFind(AllPairs[i],"CHF",0)!=-1)
              {
               USD_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseJPY && StringFind(AllPairs[i],"JPY",0)!=-1)
              {
               USD_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
           }
        }
     }
   if(UseGBP)
     {
      CurrenciesUsed++;
      int j=0;
      for(int i=0; i<ArraySize(AllPairs); i++)
        {
         if(StringFind(AllPairs[i],"GBP",0)!=-1)
           {
            if(UseAUD && StringFind(AllPairs[i],"AUD",0)!=-1)
              {
               GBP_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseUSD && StringFind(AllPairs[i],"USD",0)!=-1)
              {
               GBP_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseEUR && StringFind(AllPairs[i],"EUR",0)!=-1)
              {
               GBP_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseNZD && StringFind(AllPairs[i],"NZD",0)!=-1)
              {
               GBP_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseCAD && StringFind(AllPairs[i],"CAD",0)!=-1)
              {
               GBP_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseCHF && StringFind(AllPairs[i],"CHF",0)!=-1)
              {
               GBP_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseJPY && StringFind(AllPairs[i],"JPY",0)!=-1)
              {
               GBP_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
           }
        }
     }
   if(UseJPY)
     {
      CurrenciesUsed++;
      int j=0;
      for(int i=0; i<ArraySize(AllPairs); i++)
        {
         if(StringFind(AllPairs[i],"JPY",0)!=-1)
           {
            if(UseAUD && StringFind(AllPairs[i],"AUD",0)!=-1)
              {
               JPY_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseGBP && StringFind(AllPairs[i],"GBP",0)!=-1)
              {
               JPY_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseEUR && StringFind(AllPairs[i],"EUR",0)!=-1)
              {
               JPY_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseNZD && StringFind(AllPairs[i],"NZD",0)!=-1)
              {
               JPY_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseCAD && StringFind(AllPairs[i],"CAD",0)!=-1)
              {
               JPY_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseCHF && StringFind(AllPairs[i],"CHF",0)!=-1)
              {
               JPY_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseUSD && StringFind(AllPairs[i],"USD",0)!=-1)
              {
               JPY_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
           }
        }
     }
   if(UseCAD)
     {
      CurrenciesUsed++;
      int j=0;
      for(int i=0; i<ArraySize(AllPairs); i++)
        {
         if(StringFind(AllPairs[i],"CAD",0)!=-1)
           {
            if(UseAUD && StringFind(AllPairs[i],"AUD",0)!=-1)
              {
               CAD_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseGBP && StringFind(AllPairs[i],"GBP",0)!=-1)
              {
               CAD_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseEUR && StringFind(AllPairs[i],"EUR",0)!=-1)
              {
               CAD_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseNZD && StringFind(AllPairs[i],"NZD",0)!=-1)
              {
               CAD_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseUSD && StringFind(AllPairs[i],"USD",0)!=-1)
              {
               CAD_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseCHF && StringFind(AllPairs[i],"CHF",0)!=-1)
              {
               CAD_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseJPY && StringFind(AllPairs[i],"JPY",0)!=-1)
              {
               CAD_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
           }
        }
     }
   if(UseCHF)
     {
      CurrenciesUsed++;
      int j=0;
      for(int i=0; i<ArraySize(AllPairs); i++)
        {
         if(StringFind(AllPairs[i],"CHF",0)!=-1)
           {
            if(UseAUD && StringFind(AllPairs[i],"AUD",0)!=-1)
              {
               CHF_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseGBP && StringFind(AllPairs[i],"GBP",0)!=-1)
              {
               CHF_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseEUR && StringFind(AllPairs[i],"EUR",0)!=-1)
              {
               CHF_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseNZD && StringFind(AllPairs[i],"NZD",0)!=-1)
              {
               CHF_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseCAD && StringFind(AllPairs[i],"CAD",0)!=-1)
              {
               CHF_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseUSD && StringFind(AllPairs[i],"USD",0)!=-1)
              {
               CHF_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseJPY && StringFind(AllPairs[i],"JPY",0)!=-1)
              {
               CHF_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
           }
        }
     }
   if(UseAUD)
     {
      CurrenciesUsed++;
      int j=0;
      for(int i=0; i<ArraySize(AllPairs); i++)
        {
         if(StringFind(AllPairs[i],"AUD",0)!=-1)
           {
            if(UseUSD && StringFind(AllPairs[i],"USD",0)!=-1)
              {
               AUD_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseGBP && StringFind(AllPairs[i],"GBP",0)!=-1)
              {
               AUD_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseEUR && StringFind(AllPairs[i],"EUR",0)!=-1)
              {
               AUD_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseNZD && StringFind(AllPairs[i],"NZD",0)!=-1)
              {
               AUD_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseCAD && StringFind(AllPairs[i],"CAD",0)!=-1)
              {
               AUD_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseCHF && StringFind(AllPairs[i],"CHF",0)!=-1)
              {
               AUD_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseJPY && StringFind(AllPairs[i],"JPY",0)!=-1)
              {
               AUD_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
           }
        }
     }
   if(UseNZD)
     {
      CurrenciesUsed++;
      int j=0;
      for(int i=0; i<ArraySize(AllPairs); i++)
        {
         if(StringFind(AllPairs[i],"NZD",0)!=-1)
           {
            if(UseAUD && StringFind(AllPairs[i],"AUD",0)!=-1)
              {
               NZD_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseGBP && StringFind(AllPairs[i],"GBP",0)!=-1)
              {
               NZD_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseEUR && StringFind(AllPairs[i],"EUR",0)!=-1)
              {
               NZD_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseUSD && StringFind(AllPairs[i],"USD",0)!=-1)
              {
               NZD_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseCAD && StringFind(AllPairs[i],"CAD",0)!=-1)
              {
               NZD_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseCHF && StringFind(AllPairs[i],"CHF",0)!=-1)
              {
               NZD_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
            if(UseJPY && StringFind(AllPairs[i],"JPY",0)!=-1)
              {
               NZD_Pairs[j]=StringConcatenate(CurrPrefix,AllPairs[i],CurrSuffix);
               j++;
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateRSITotMA(int i)
  {
   if(UseEUR)
      EUR[i]=RSITotMA("EUR",EUR_Pairs,i);
   if(UseGBP)
      GBP[i]=RSITotMA("GBP",GBP_Pairs,i);
   if(UseUSD)
      USD[i]=RSITotMA("USD",USD_Pairs,i);
   if(UseJPY)
      JPY[i]=RSITotMA("JPY",JPY_Pairs,i);
   if(UseAUD)
      AUD[i]=RSITotMA("AUD",AUD_Pairs,i);
   if(UseNZD)
      NZD[i]=RSITotMA("NZD",NZD_Pairs,i);
   if(UseCAD)
      CAD[i]=RSITotMA("CAD",CAD_Pairs,i);
   if(UseCHF)
      CHF[i]=RSITotMA("CHF",CHF_Pairs,i);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double RSITotMA(string Curr, string& Pairs[],int j)
  {
   double Tot=0;
   for(int i=0; i<ArraySize(Pairs); i++)
     {
      if(Pairs[i]!=NULL)
        {
         double SValue=0;
         for(int h=0; h<SmoothingPeriod; h++)
           {
            int k=j;

            if(LinesTF!=Period())
               k=iBarShift(Pairs[i],LinesTF,Time[j],false);

            SValue+=iRSI(Pairs[i],LinesTF,RSIPeriod,PRICE_CLOSE,k+h);
           }

         SValue=SValue/SmoothingPeriod;

         if(StringFind(Pairs[i],Curr,0)<3)
           {
            Tot+=(SValue-50);
           }
         else
           {
            Tot+=((100-SValue)-50);
           }
        }
     }
   return (Tot/CurrenciesUsed);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CopyBaseQuote()
  {
   if(StringFind(CurrBase,"EUR")>=0)
      ArrayCopy(Base,EUR);
   if(StringFind(CurrBase,"USD")>=0)
      ArrayCopy(Base,USD);
   if(StringFind(CurrBase,"GBP")>=0)
      ArrayCopy(Base,GBP);
   if(StringFind(CurrBase,"JPY")>=0)
      ArrayCopy(Base,JPY);
   if(StringFind(CurrBase,"AUD")>=0)
      ArrayCopy(Base,AUD);
   if(StringFind(CurrBase,"NZD")>=0)
      ArrayCopy(Base,NZD);
   if(StringFind(CurrBase,"CAD")>=0)
      ArrayCopy(Base,CAD);
   if(StringFind(CurrBase,"CHF")>=0)
      ArrayCopy(Base,CHF);
   if(StringFind(CurrQuote,"EUR")>=0)
      ArrayCopy(Quote,EUR);
   if(StringFind(CurrQuote,"USD")>=0)
      ArrayCopy(Quote,USD);
   if(StringFind(CurrQuote,"GBP")>=0)
      ArrayCopy(Quote,GBP);
   if(StringFind(CurrQuote,"JPY")>=0)
      ArrayCopy(Quote,JPY);
   if(StringFind(CurrQuote,"AUD")>=0)
      ArrayCopy(Quote,AUD);
   if(StringFind(CurrQuote,"NZD")>=0)
      ArrayCopy(Quote,NZD);
   if(StringFind(CurrQuote,"CAD")>=0)
      ArrayCopy(Quote,CAD);
   if(StringFind(CurrQuote,"CHF")>=0)
      ArrayCopy(Quote,CHF);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void creazione_pulsanti()
  {
//AllCurrencies array che contiene i nomi delle currency
   int posizione_x_prima_fila = 15;

   for(int i=0; i<8; i++)
     {
      B.Create(0,AllCurrencies[i], 1, 0, 0, 60, 25);
      ObjectSetInteger(0,AllCurrencies[i],OBJPROP_CORNER,CORNER_LEFT_LOWER);
      B.Shift(posizione_x_prima_fila,35);
      B.Text(AllCurrencies[i]);
      B.FontSize(fontsize);
      B.ColorBackground(Colori_Currencies[i]);
      B.ColorBorder(clrGray);
      B.Pressed(false);
      posizione_x_prima_fila+=65;
     }
  }
//+------------------------------------------------------------------+
