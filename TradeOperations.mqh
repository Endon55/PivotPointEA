#property strict








//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
bool inBounds(int valueToCheck)
{
   if(valueToCheck > 0 && valueToCheck < 8) return true;
   return false;
}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//

int GetTotalOpenTrades(int Magic)
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
void trailStopLoss(int SL, int TP, int TradeID)
{
   if(OrderType() == OP_BUY && OrderStopLoss() < Bid - SL * Point())
   {
      Print(Bid - SL * Point(), "SL--------------------------------");
      OrderModify(TradeID, OrderOpenPrice(), Bid - SL * Point(), 0, 0, clrGreen);
   }
   if(OrderType() == OP_SELL && OrderStopLoss() > Bid + SL * Point())
   {
      OrderModify(TradeID, OrderOpenPrice(), Bid + SL * Point(), 0, 0, clrGreen);
   }
}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
double calculatePositionSize(double price, double PercentMarginUsedPerTrade)
{
      int unitsPerLot = 100000;
      double smallestPosition = .01;
      double leverage = 100 / AccountLeverage();
      double cashToSpendThisTrade = AccountBalance() * PercentMarginUsedPerTrade;
      double lotCost = price * unitsPerLot * leverage;
      double costPerMicro = (unitsPerLot * price / 100) * leverage / 100;
      double positionSize = floor(cashToSpendThisTrade / costPerMicro);  
      return positionSize / 100;
}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
int getVolatility(int ToPips)
{
   int dayOne = (int)((iHigh(Symbol(), PERIOD_D1, 1) - iLow(Symbol(), PERIOD_D1, 1)) * ToPips);
   int dayTwo = (int)((iHigh(Symbol(), PERIOD_D1, 2) - iLow(Symbol(), PERIOD_D1, 2)) * ToPips);
   int dayThree = (int)((iHigh(Symbol(), PERIOD_D1, 3) - iLow(Symbol(), PERIOD_D1, 3)) * ToPips);
   
   //Adding Weights to the days to try emphasize the last day but not too much 436
   return (dayOne * 2  + dayTwo * 3 + dayThree * 5) / 11 ;
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
double getPipSpread(double highValue, double lowValue, int ToPips)
{
   return (highValue - lowValue) * ToPips;
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