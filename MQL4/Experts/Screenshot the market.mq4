//+------------------------------------------------------------------+
//|                                        Screenshot the market.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


input string a="Year Month Day Hours Minutes Seconds";// Date
input string String_0="Name_0";// Name Screenshot 0
input datetime Screenshot_0 = D'2010.01.01 15:30:00' ;// Date Screenshot 0
input string String_1="Name_1";// Name Screenshot 1
input datetime Screenshot_1 = D'2010.01.02 15:30:00' ;// Date Screenshot 1
input string String_2="Name_2";// Name Screenshot 2
input datetime Screenshot_2 = D'2010.01.03 15:30:00' ;// Date Screenshot 2
input string String_3="Name_3";// Name Screenshot 3
input datetime Screenshot_3 = D'2010.01.04 15:30:00' ;// Date Screenshot 3
input string String_4="Name_4";// Name Screenshot 4
input datetime Screenshot_4 = D'2010.01.05 15:30:00' ;// Date Screenshot 4
input string String_5="Name_5";// Name Screenshot 5
input datetime Screenshot_5 = D'2010.01.06 15:30:00' ;// Date Screenshot 5
input string String_6="Name_6";// Name Screenshot 6
input datetime Screenshot_6 = D'2010.01.07 15:30:00' ;// Date Screenshot 6
input string String_7="Name_7";// Name Screenshot 7
input datetime Screenshot_7 = D'2010.01.08 15:30:00' ;// Date Screenshot 7
input string String_8="Name_8";// Name Screenshot 8
input datetime Screenshot_8 = D'2010.01.09 15:30:00' ;// Date Screenshot 8
input string String_9="Name_9";// Name Screenshot 9
input datetime Screenshot_9 = D'2010.01.10 15:30:00' ;// Date Screenshot 9

// Define an array to store the input dates and times
datetime datesAndTimes[10];

// Define an array to store the input names
string names[10];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Initialize the arrays with the input values
   datesAndTimes[0] = Screenshot_0;
   datesAndTimes[1] = Screenshot_1;
   datesAndTimes[2] = Screenshot_2;
   datesAndTimes[3] = Screenshot_3;
   datesAndTimes[4] = Screenshot_4;
   datesAndTimes[5] = Screenshot_5;
   datesAndTimes[6] = Screenshot_6;
   datesAndTimes[7] = Screenshot_7;
   datesAndTimes[8] = Screenshot_8;
   datesAndTimes[9] = Screenshot_9;

   names[0] = String_0;
   names[1] = String_1;
   names[2] = String_2;
   names[3] = String_3;
   names[4] = String_4;
   names[5] = String_5;
   names[6] = String_6;
   names[7] = String_7;
   names[8] = String_8;
   names[9] = String_9;

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{

}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Call the function to screen the chart
   ScreenTheChart();
}

//+------------------------------------------------------------------+
//| Function to screen the chart                                     |
//+------------------------------------------------------------------+
void ScreenTheChart()
{
   // Iterate through the dates and times array
   for (int i = 0; i < 10; i++)
   {
      // Check if the current time matches the input date and time
      if (TimeCurrent() == datesAndTimes[i])
      {
         // Take a screenshot with the corresponding name
         if (!WindowScreenShot(StringFormat("shots\\%s.jpg", names[i]), 1920, 1080))
         {
            // Get and print the error message if the screenshot failed
            int lasterror = GetLastError();
            Print(IntegerToString(lasterror));
         }
      }
   }
}
//+------------------------------------------------------------------+