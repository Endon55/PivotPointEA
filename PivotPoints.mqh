#property strict

class PivotPoints
{
private:

public:
   
   string name;
   int type;
   datetime startingTime;
   datetime endingTime;
   int currentDay;
   double price;
   color objectColor;
   double open;
   double close;
   double high;
   double low;
   double linePrices[7];
   
   double PP;
   
   double R1;
   double R2;
   double R3;
   
   double S1;
   double S2;
   double S3;
   
   color PPColor;
   color RColor;
   color SColor;
   int lineThickness;

   PivotPoints();
  ~PivotPoints();
   void DrawLine(string name, double Price, color Color); 
   datetime BuildDateTime();
   void Draw();
   double GetClosestPivotPoint(double highToCheck, double lowToCheck);
   void GetArraySortedWithAsk(double askPrice, double &array[]);
   double CalculateClosestPivotPoint(double askPrice);
   double GetVolatility();
};

//Constructor
PivotPoints::PivotPoints()
{
   lineThickness = 5;
   PPColor = clrTan;
   RColor = clrGreen;
   SColor = clrRed;
}
PivotPoints::~PivotPoints()
{
   //Print("Destroyed");
}

void PivotPoints::DrawLine(string Name, double Price, color Color)
{

   Print("Hello---------------------------------------------");
   ObjectCreate(ChartID(), Name, OBJ_RECTANGLE, 0, startingTime, Price, endingTime, Price + lineThickness * Point());
   ObjectSetInteger(ChartID(), Name, OBJPROP_WIDTH, lineThickness);
   ObjectSetInteger(ChartID(), Name, OBJPROP_COLOR, Color);
   ObjectSetInteger(ChartID(), Name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(ChartID(), Name, OBJPROP_FILL, false);
}

datetime PivotPoints::BuildDateTime()
{
   string nextDay = "";
   string day = "";
   string month = "";
   string year = "";
   
   day   = (string)Day();
   month = (string)Month();
   year  = (string)Year();
   if(Day() < 10)day = "0" + (day);
   if(Month() < 10) month = "0" + month;
   nextDay = year + ":" + month + ":" + day + " 23:59:59";
   return StringToTime(nextDay);
 };

void PivotPoints::Draw()
{
   startingTime = iTime(Symbol(), PERIOD_D1, 0);
   endingTime = BuildDateTime();
   currentDay = Day();

   open = iOpen(Symbol(), PERIOD_D1, 1);
   close = iClose(Symbol(), PERIOD_D1, 1);
   high = iHigh(Symbol(), PERIOD_D1, 1);
   low = iLow(Symbol(), PERIOD_D1, 1);
   PP = (high + low + close) / 3;
   R1 = PP + PP - low;
   R2 = PP + (high - low);
   R3 = high + (2 * (PP - low));
   S1 = PP + PP - high;
   S2 = PP - (high - low);
   S3 = low - (2 * (high -PP));
   linePrices[0] = R3;
   linePrices[1] = R2;
   linePrices[2] = R1;
   linePrices[3] = PP;
   linePrices[4] = S1;
   linePrices[5] = S2;
   linePrices[6] = S3;

  DrawLine(("PP" + (string)TimeCurrent()), PP, PPColor);
  DrawLine(("R1" + (string)TimeCurrent()), R1, RColor);
  DrawLine(("R2" + (string)TimeCurrent()), R2, RColor);
  DrawLine(("R3" + (string)TimeCurrent()), R3, RColor);
  DrawLine(("S1" + (string)TimeCurrent()), S1, SColor);
  DrawLine(("S2" + (string)TimeCurrent()), S2, SColor);
  DrawLine(("S3" + (string)TimeCurrent()), S3, SColor);
  //Print(TimeCurrent(), " CurrentTime", high, "---------------------------------------");

}

double PivotPoints::CalculateClosestPivotPoint(double askPrice)
{  
   double lowestDifference = 1000000000;
   double difference;
   int closestIndex = 0;
   for(int i = 0; i < 7; i++)
   {
      difference = MathAbs(askPrice - linePrices[i]);
      //Print("Difference: ", difference, " Closest: ", lowestDifference, "---------------------------------------------");
      if(difference < lowestDifference)
      {
         lowestDifference = difference;
         closestIndex = i;
      }
   }
   
   return linePrices[closestIndex];
}

//Sorted array of pivot point lines with the ask price(7) sorted in with the index of the ask price(8) as the last value in the array
void PivotPoints::GetArraySortedWithAsk(double askPrice, double &array[])
{ 
   array[8] = 7;
   array[7] = askPrice;
   
   for(int i = 0; i < 7; i++)
   {
      array[i] = linePrices[i];
   }
   //Print("Start - Ask:  ", askPrice);
   for(int i = 7; i > 0; i--)
   {
      //Print( "Current I Value: ", array[i], " Next I Value: ", array[i - 1]);
      if(array[i] > array[i - 1])
      { 
         double temp = array[i - 1];
         array[i - 1] = array[i];
         array[i] = temp;
         array[8] = i - 1;
      }
      
   }
   //Print("Finish");

}

double PivotPoints::GetClosestPivotPoint(double highToCheck, double lowToCheck)
{
   
   
   return 0.0;
}

double PivotPoints::GetVolatility()
{
   return (MathAbs(high - low) * 100000);
}