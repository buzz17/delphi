// John Main added dewpoint code from : http://playground.arduino.cc/main/DHT11Lib
// Also added DegC output for Heat Index.
// dewPoint function NOAA
// reference (1) : http://wahiduddin.net/calc/density_algorithms.htm
// reference (2) : http://www.colorado.edu/geography/weather_station/Geog_site/about.htm
//
double dewPoint(double celsius, double humidity)
{
  double RATIO = 373.15 / (273.15 + celsius);
  double RHS = -7.90298 * (RATIO - 1);
  RHS += 5.02808 * log10(RATIO);
  RHS += -1.3816e-7 * (pow(10, (11.344 * (1 - 1 / RATIO ))) - 1) ;
  RHS += 8.1328e-3 * (pow(10, (-3.49149 * (RATIO - 1))) - 1) ;
  RHS += log10(1013.246);
  double VP = pow(10, RHS - 3) * humidity;
  double T = log(VP / 0.61078); // temp var
  return (241.88 * T) / (17.558 - T);
}

// Example testing sketch for various DHT humidity/temperature sensors
// Written by ladyada, public domain
#include <Wire.h>
#include <SPI.h>
#include <Adafruit_Sensor.h>
#include "DHT.h"
#include "Adafruit_BMP280.h"

#define DHTPIN 2 // what pin we're connected to
#define DHTTYPE DHT22 // DHT 22 (AM2302)

#define BMP_SCK 13 // scl = clock
#define BMP_MISO 12 // sdo
#define BMP_MOSI 11 // sda
#define BMP_CS 10 // csb



#define Bucket_Size 0.01   // bucket size to trigger tip count
#define RG11_Pin 3         // digital pin RG11 connected to
#define TX_Pin 8           // used to indicate web data tx
#define DS18B20_Pin 9      // DS18B20 Signal pin on digital 9 

#define WindSensor_Pin (2)      // The pin location of the anemometer sensor
#define WindVane_Pin (A2)       // The pin the wind vane sensor is connected to
#define VaneOffset 0 

DHT dht(DHTPIN, DHTTYPE);
Adafruit_BMP280 bme(BMP_CS, BMP_MOSI, BMP_MISO,  BMP_SCK);

volatile unsigned long tipCount;    
volatile unsigned long contactTime; 

volatile bool isSampleRequired;       
volatile unsigned int  timerCount;    
volatile unsigned long rotations;     
volatile unsigned long contactBounceTime;  
volatile float windSpeed;
volatile float totalRainfall;       

bool txState;        
int vaneValue;       
int vaneDirection;   
int calDirection;    
int lastDirValue;    

char temperatureCString[6];
char heatindexString[6];
char temperatureFString[6];
char dpString[6];
char humidityString[6];
char pressureStringQNH[7];
char pressureStringQFE[7];
char pressureInchQNH[6];
char pressureInchQFE[6];
char pressureALT[6];


void setup() { 
  Serial.begin(9600); 
  dht.begin();
  bme.begin();
  
} 

void loop() 
{
  delay(2000);
  getDHT();
  getBMP();
    

    Serial.print("97142"); Serial.print(";"); 
    Serial.print(humidityString); Serial.print(";");
    Serial.print(temperatureCString); Serial.print(";"); 
    Serial.print(dpString); Serial.print(";"); 
    Serial.print(heatindexString); Serial.print(";");
    
    Serial.print(pressureStringQNH); Serial.print(";"); 
    Serial.print(pressureStringQFE); Serial.print(";"); 
    Serial.print(pressureALT); Serial.print(";");
    
    //Serial.print(totalRainfall); Serial.print(";"); 
    
    //Serial.print(windSpeed); Serial.print(";"); 
    //Serial.print(calDirection); Serial.print(";"); 
    Serial.println( " " );
    
 // }
  
}

void isr_timer() { 
  timerCount++;
  if(timerCount == 5) 
  {
    // convert to mp/h using the formula V=P(2.25/T)
    // V = P(2.25/2.5) = P * 0.9
    windSpeed = rotations * 0.9;
    rotations = 0;
    txState = !txState;         // toggle the led state
    digitalWrite(TX_Pin,txState);
    isSampleRequired = true;
    timerCount = 0;
  }
}

void isr_rotation()   
{
  if ((millis() - contactBounceTime) > 15 ) 
  {  
    rotations++;
    contactBounceTime = millis();
  }
}

void isr_rg() 
{  
  if((millis() - contactTime) > 15 ) 
  { 
    tipCount++;
    totalRainfall = tipCount * Bucket_Size;
    contactTime = millis();
  }
}

void getBMP() 
{
  float qnh = (bme.readPressure()/100) ;
  float qfe = qnh - 1.5;
  float qnhInch = 0.02953*qnh;
  float qfeInch = 0.02953*qfe;
  int alt = (bme.readAltitude(1020.25)); 

  dtostrf(qnh, 6, 1, pressureStringQNH);
  dtostrf(qfe, 6, 1, pressureStringQFE);
  dtostrf(qnhInch, 5, 2, pressureInchQNH);
  dtostrf(qfeInch, 5, 2, pressureInchQFE);
  dtostrf(alt, 5, 1, pressureALT);
  delay(100);
}

void getDHT()
{ 
  float t = dht.readTemperature(); 
  float f = dht.readTemperature(true);
  float h = dht.readHumidity();
  float hi = dht.computeHeatIndex(f, h);
  float hic = ((hi - 32.0)/1.8);
  float dp = dewPoint(t, h);

  dtostrf(t, 5, 2, temperatureCString);
  dtostrf(t, 5, 2, temperatureFString);
  dtostrf(h, 5, 2, humidityString);
  dtostrf(dp, 5, 2, dpString);
  dtostrf(hic, 5, 2, heatindexString);

  delay(100);  
}

void getWindDirection() 
{
  vaneValue = analogRead(WindVane_Pin);
  vaneDirection = map(vaneValue, 0, 1023, 0, 360);
  calDirection = vaneDirection + VaneOffset;  
  if(calDirection > 360)
    calDirection = calDirection - 360;    
  if(calDirection < 0)
    calDirection = calDirection + 360;
}
