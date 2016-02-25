//
//Obstacle Sensor and display
//
//Author: Seth Stoothoff
//

/*Module Description:*/
/************************************************************************
  This code uses Digilent's MAXSonar and LCDS library functions to take 
  distance information and display it on the lcd screen.
*************************************************************************/
  
/*Revision History:*/
/************************************************************************
  2016-02-12:  Created (Seth S.)
  2016-02-21:  Working version (Seth S.)
*************************************************************************/
  

/*Include Files*/
/************************************************************************/
#include <p32xxxx.h>
#include <MAXSonar.h>
#include <LCDS.h>
#include <DSPI.h>
#include <Bounce.h>


/*Local Type Definitions*/
/************************************************************************
  PmodMAXSonar pins:          Corresponding MX4 pins:
      Pin 1: AN                  U2CTS  JH-01
      Pin 2: RX                  U2TX   JH-02
      Pin 3: TX                  
      Pin 4: PW                  U2RTS  JH-04
*************************************************************************/
#define ANpin  48  // U2CTS  JH-01
#define RXpin  49  // U2TX   JH-02
#define PWpin  50  // U2RTS  JH-04


/*Global Variables*/
/************************************************************************/
uint16_t  data;
uint16_t  data_div;
MAXSonar  sensor;
LCDS      MyLCDS;
char      szInfo1[0x27];
char      szInfo2[0x27];
//custom characters
uint8_t   defChar[] = {0x1F, 0x1F, 0x1F, 0x1F, 0x1F, 0x1F, 0x1F, 0x1F};
byte      charsToDisp[] = {0, 1, 2, 3};
// cursor setting
boolean   fCursor = false;

/*Local Variables*/
/************************************************************************/
/*      units: INCH: returns measurement in inches              */
/*             CM: returns measurement in centimeters           */
/*             MM: returns measurement in millimeters           */
/* ------------------------------------------------------------ */
const UNIT units = INCH;

/*Procedure Definitions*/
/*  setup ()
  Description:
  Initialization for the LCD screen and the MAXSonar sensor.
*/
void setup()
{
  //select SPI port and configure the SPI interface
  MyLCDS.Begin(PAR_ACCESS_DSPI0);
  //default settings for display
  MyLCDS.DisplaySet(true, true);
  MyLCDS.DisplayMode(0);
  // set cursor setting
  MyLCDS.CursorModeSet(fCursor, false);
  // define the custom character
  MyLCDS.DefineUserChar(defChar, 0);
  delay(5);
  
  //Make sensor's RX pin an output from the uC
  pinMode(RXpin, OUTPUT);
  //write sensor's RX pin low to stop sensor activity
  digitalWrite(RXpin, LOW);
  pinMode(PWpin, INPUT);
  
  //wait for powerup before sending RX command
  delay(250);
  digitalWrite(RXpin, HIGH);
  //wait for calibration to finish
  delay(49);
  //wait for first reading to finish
  delay(49);
}

/*  loop ()
  Description:
  Main application loop. Retreives sensor data every 500ms
*/
void loop()
{
  sensor.begin(UART, Serial1, RXpin);
  data = sensor.getDistance(Serial1, units);
  //End Serial communication so that PmodUS doesn't buffer readings
  sensor.end(Serial1, RXpin);
  
  if(units == INCH){
    sprintf(szInfo1, "%3u inches", data);
  }
  else if(units == CM){
    sprintf(szInfo1, "%3u centimeters", data);
  }
  else if(units == MM){
    sprintf(szInfo1, "%4u millimeters", data);
  }
  
  MyLCDS.DisplayClear();
  MyLCDS.WriteStringAtPos(0, 0, szInfo1);
  
  data_div = data / 16;
  for (int i = 0; i < data_div; i++) {
    MyLCDS.DispUserChar(charsToDisp, 1, 1, i);
    delay(5);
  }
  
  delay(500);
}

