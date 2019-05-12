#include "PivotPoints.mqh"
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

int Magic = 1234;

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
   pPoints[indexPPoints + 1].Draw();
   indexPPoints++;
   sortPrices();
   return(INIT_SUCCEEDED);
}

int start()
{
   if(IsVisualMode() == true)
   {
      int Waitloop = 0;
      while(Waitloop < speed)Waitloop++;
   }
   return(0);
}

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
void OnTick()
{
   updateVars();
   if(GetTotalOpenTrades() < maxTrades)
   {
      Print("Index: ", indexSortedArray);
      if(inBounds(indexSortedArray) && shouldGoLong(betweenPivotPointBars, askBetweenBars, sortedPricesArray[indexSortedArray + 1], 0.3)) //Price is above lower line go long
      {
         tradeID = OrderSend(Symbol(), OP_BUY, calculatePositionSize(Ask), Ask, 10, Bid - StopLoss * Point, 0, "Buy Order", Magic, 0, clrGreen);
         setTakeProfitLong(betweenPivotPointBars, sortedPricesArray[indexSortedArray - 1], 0.3);
      }
      //else if() //Price is below upper line go short
   }
   //else trailStopLoss();
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
   int profitTarget = (int)(closeToLinePercent2 * spreadBetweenBars * toPips);
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
int strength(double distanceBetweenPoints)
{
   if(iOpen(Symbol(), PERIOD_H1, 1) > iClose(Symbol(), PERIOD_H1, 0))
   {
      //Bid for going short
   }
   else if(iOpen(Symbol(), PERIOD_H1, 1) < iClose(Symbol(), PERIOD_H1, 1))
   {
      //Ask for going long
   }
   else return 0;
   return 1;
}

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
double getPipSpread(double highValue, double lowValue)
{
   return (highValue - lowValue) * toPips;
}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
int sentiment()
{
   if(iClose(Symbol(), PERIOD_H1, 1) > iOpen(Symbol(), PERIOD_H1, 1) && iClose(Symbol(), PERIOD_H1, 0) > iOpen(Symbol(), PERIOD_H1, 0))
   {
      return 1;
   }
   return 0;

}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//Calls the pivot point sort function and passes it an array to be filled with the pivot points sorted from highest to lowest with the current market price sorted in
void sortPrices()
{ 
   
   pPoints[indexPPoints].GetArraySortedWithAsk(Ask, sortedPricesArray);
   indexSortedArray = (int)sortedPricesArray[8];
}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//If trend strength is a 0, take a small bounce position, 5 strong bounce, 10 assume breakout
int getTrendStrength()
{
   return 0;
}


//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
int getVolatility()
{
   int dayOne = (int)((iHigh(Symbol(), PERIOD_D1, 1) - iLow(Symbol(), PERIOD_D1, 1)) * toPips);
   int dayTwo = (int)((iHigh(Symbol(), PERIOD_D1, 2) - iLow(Symbol(), PERIOD_D1, 2)) * toPips);
   int dayThree = (int)((iHigh(Symbol(), PERIOD_D1, 3) - iLow(Symbol(), PERIOD_D1, 3)) * toPips);
   
   //Adding Weights to the days to try emphasize the last day but not too much 436
   return (dayOne * 2  + dayTwo * 3 + dayThree * 5) / 11 ;
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
         askBetweenBars = MathRound(getPipSpread(Ask, sortedPricesArray[indexSortedArray + 1]));
         betweenPivotPointBars = MathRound(getPipSpread(sortedPricesArray[indexSortedArray - 1], sortedPricesArray[indexSortedArray + 1]));
         ObjectMove("Above", 0, 0, sortedPricesArray[indexSortedArray - 1]);
         ObjectMove("Below", 0, 0, sortedPricesArray[indexSortedArray + 1]);
         
         threeDayVolatility = getVolatility();
      }
 
      
   sortPrices();
   bidAskSpread = (int)MarketInfo(Symbol(), MODE_SPREAD);
}

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
int GetTotalOpenTrades()
{
   int TotalTrades = 0;
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() != Symbol()) continue;
         if(OrderMagicNumber() != Magic) continue;
         if(OrderCloseTime() != 0) continue;
         
         TotalTrades = TotalTrades + 1;
      }
   }
   return TotalTrades;
}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
double calculatePositionSize(double price)
{
      int unitsPerLot = 100000;
      double smallestPosition = .01;
      double leverage = 100 / AccountLeverage();
      double cashToSpendThisTrade = AccountBalance() * percentMarginUsedPerTrade;
      double lotCost = price * unitsPerLot * leverage;
      double costPerMicro = (unitsPerLot * price / 100) * leverage / 100;
      double positionSize = floor(cashToSpendThisTrade / costPerMicro);  
      return positionSize / 100;
}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
bool inBounds(int valueToCheck)
{
   if(valueToCheck > 0 && valueToCheck < 8) return true;
   return false;
}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//

void trailStopLoss()
{
   if(OrderType() == OP_BUY && OrderStopLoss() < Bid - StopLoss * Point())
   {
      OrderModify(tradeID, OrderOpenPrice(), Bid - StopLoss * Point(), 0, 0, clrGreen);
   }
   if(OrderType() == OP_SELL && OrderStopLoss() > Bid + StopLoss * Point())
   {
      OrderModify(tradeID, OrderOpenPrice(), Bid + StopLoss * Point(), 0, 0, clrGreen);
   }
}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
