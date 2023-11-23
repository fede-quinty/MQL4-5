//+------------------------------------------------------------------+
//|                                             Include_Completo.mqh |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

// L'include lo devo fare io imparando mql5 e poi chiedo consiglio all'ai'
// Partire da zero invece di cercare di convertire il codice mql4

double pips,BarsCount;

//Calcolo Pip
double Calcolo_pips()
  {
// If there are 3 or fewer digits (JPY, for example), then return 0.01, which is the pip value.
   if(Digits() <= 3)
     {
      pips=0.01;
     }
// If there are 4 or more digits, then return 0.0001, which is the pip value.
   else
      if(Digits() >= 4)
        {
         pips=0.0001;
        }
      // In all other cases, pips = Point
      else
         pips = Point();

   return pips; 
  }

//
bool Nuova_candela()
  {
// Se il numero di barre è maggiore alla variabile Barscount(all'inzio vale 0)
   if(Bars(Symbol(),PERIOD_CURRENT) > BarsCount)
     {
      // Allora BarsCount è uguale al numero di barre
      BarsCount = Bars(Symbol(),PERIOD_CURRENT);
      // Ritorni True
      return true;
     }
// Altrimenti ritorni falso
   else
      return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void seleziono_posizioni(int magic_number)
  {

   for(int i = 0; i<PositionsTotal(); i++)
     {

      if(!PositionSelect(Symbol()))
         Print(GetLastError());

      long magic= PositionGetInteger(POSITION_MAGIC);

      if(magic != magic_number)
        {

         Print("Il magic number è diverso");

        }
      else
         if(magic == magic_number)
           {

            Print("Il magic number è lo stesso dell'input: " + IntegerToString(magic_number));
           }
     }
  }
//+------------------------------------------------------------------+
