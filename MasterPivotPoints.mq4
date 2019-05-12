#include "PivotPoints.mqh"
#include "TradeOperations.mqh"
#property strict

//Slowdown Speed for use on Visual mode speed 32. Higher the number the slower it will run.
extern int speed = 500;

extern color clrBackground = C'44,44,44';
extern color clrBullCandle = C'38,106,234';
extern color clrGrid = C'55,55,55';

int toPips = 100000;
PivotPoints pPoints[500];//Array for holding a days worth of PivotPoints
int indexPPoints = - 1;//Index of the array we're in

double sortedPricesArray[9];//Array for holding a sorted list of Pivot points with the current price sorted in, also has the index of the ask price as element 9
int indexSortedArray;

int currentDay = Day();//Used to check if the current day has passed and if we should calculate new pivot points.
int currentHour = Hour();
double betweenPivotPointBars;
double askBetweenBars = 1;
int bidAskSpread = 1;
int threeDayVolatility;

int MagicNumber = 1234;

int StopLoss = 50;
int TakeProfit = 50;
double percentMarginUsedPerTrade = 0.5;
int tradeID;
int maxTrades = 1;

/*------------------ TODO -----------------------------------------------------------------------------------------------------------------------------------------------------------/

-Calculate "velocity" of current trend to guess about breakouts.

-Use either RSI or Stoch to try and and find divergences
-Let loose and see how she does





/-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
int OnInit()
{ 
   setChartFormatting();
   pPoints[indexPPoints + 1].Draw();
   indexPPoints++;
   sortPrices();
   return(INIT_SUCCEEDED);
}



//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
void OnTick()
{
   updateVars();
   if(GetTotalOpenTrades(MagicNumber) < maxTrades)
   {
      if(inBounds(indexSortedArray) && shouldGoLong(betweenPivotPointBars, askBetweenBars, sortedPricesArray[indexSortedArray + 1], 0.3)) //Price is above lower line go long
      {
         tradeID = OrderSend(Symbol(), OP_BUY, calculatePositionSize(Ask, percentMarginUsedPerTrade), Ask, 10, Bid - StopLoss * Point, 0, "Buy Order", MagicNumber, 0, clrGreen);
         setTakeProfitLong(betweenPivotPointBars, sortedPricesArray[indexSortedArray - 1], 0.3);
      }
      //else if() //Price is below upper line go short
   }
   else trailStopLoss(StopLoss, TakeProfit, tradeID);
   /*
   else if(inBounds(indexSortedArray) && shouldSellLong(betweenPivotPointBars, askBetweenBars, sortedPricesArray[indexSortedArray - 1], 0.3))
   {
      OrderSelect(tradeID, SELECT_BY_POS);
      OrderClose(tradeID, OrderLots(), Ask, 10, clrRed);
   }
   */
   //start(); 
}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
bool shouldGoLong(double spreadBetweenBars, double askSpreadBetweenbars, double lineValue, double closeToLinePercent)
{
   //Print("Ask: ", Ask, " Line: ", lineValue);
   if(Ask > lineValue)
   {
      
      //Print("Ask: ", askBetweenBars, " Bars: ", betweenPivotPointBars);
      if((askSpreadBetweenbars / spreadBetweenBars) <= closeToLinePercent)
      {
         return true;
      }
   }
   return false;

}

void setTakeProfitLong(double spreadBetweenBars, double lineValue, double closeToLinePercent)
{
   double closeToLinePercent2 = 1 - closeToLinePercent;
   int profitTarget = (int)(closeToLinePercent2 * spreadBetweenBars);
   Print("PT: ", profitTarget, "----------------------------------------");
   OrderModify(tradeID, OrderOpenPrice(), 0, Bid + profitTarget * Point(), 0, clrGreen);
}

bool shouldSellLong(double spreadBetweenBars, double askSpreadBetweenbars, double lineValue, double closeToLinePercent)
{
   double closeToLinePercent2 = 1 - closeToLinePercent;
   
   if(Ask < lineValue)
   {
      //Print("Ask: ", askBetweenBars, " Bars: ", betweenPivotPointBars);
      if((askSpreadBetweenbars / spreadBetweenBars) <= closeToLinePercent2)
      {
         return true;
      }
   }
   return false;
}



//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//




























void setChartFormatting()
{
   ChartSetInteger(ChartID(), CHART_COLOR_BACKGROUND, clrBackground);
   ChartSetInteger(ChartID(), CHART_COLOR_GRID, clrGrid);
   ChartSetInteger(ChartID(), CHART_COLOR_CANDLE_BEAR, clrOrchid);
   ChartSetInteger(ChartID(), CHART_COLOR_CANDLE_BULL, clrBullCandle);
   ChartSetInteger(ChartID(), CHART_COLOR_CHART_UP, clrYellow);
   ChartSetInteger(ChartID(), CHART_COLOR_CHART_DOWN, clrOrchid);
   ChartSetInteger(ChartID(), CHART_MODE, CHART_CANDLES);
   ChartSetInteger(ChartID(), CHART_FOREGROUND, true); 
   ObjectCreate(ChartID(), "Above",  OBJ_HLINE, 0, 0, 0.0);
   ObjectCreate(ChartID(), "Below",  OBJ_HLINE, 0, 0, 0.0);
}



//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
void sortPrices()
{  
   pPoints[indexPPoints].GetArraySortedWithAsk(Ask, sortedPricesArray);
   indexSortedArray = (int)sortedPricesArray[8];
}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
void updateVars()
{
   if(Day() != currentDay)
      {
         pPoints[indexPPoints + 1].Draw();
         currentDay = Day(); 
         indexPPoints++;
      }
      if(inBounds(indexSortedArray))
      { 
         askBetweenBars = MathRound(getPipSpread(Ask, sortedPricesArray[indexSortedArray + 1], toPips));
         betweenPivotPointBars = MathRound(getPipSpread(sortedPricesArray[indexSortedArray - 1], sortedPricesArray[indexSortedArray + 1], toPips));
         ObjectMove("Above", 0, 0, sortedPricesArray[indexSortedArray - 1]);
         ObjectMove("Below", 0, 0, sortedPricesArray[indexSortedArray + 1]);
         
         threeDayVolatility = getVolatility(toPips);
      }
 
      
   sortPrices();
   bidAskSpread = (int)MarketInfo(Symbol(), MODE_SPREAD);
}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
int start()
{
   if(IsVisualMode() == true)
   {
      int Waitloop = 0;
      while(Waitloop < speed)Waitloop++;
   }
   return(0);
}
