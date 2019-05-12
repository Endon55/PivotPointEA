#property strict

string BotName = "Demo Bot";
int Magic = 1234;

double LotsToTrade = 2.0;
double StopLoss = -3700;
double ProfitTarget = 280.00;



int OnInit()
{
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{


}
  
  
  
  
  
void OnTick()
{
      double SlowMovingAverage = iMA(NULL, 0, 250, 0, MODE_SMA, PRICE_CLOSE, 0);
      double FastMovingAverage = iMA(NULL, 0, 145, 0, MODE_SMA, PRICE_CLOSE, 0);
}
  
