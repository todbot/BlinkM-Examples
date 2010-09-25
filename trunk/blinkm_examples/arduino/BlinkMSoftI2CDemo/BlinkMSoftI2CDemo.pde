/* 
 * BlinkMSoftI2CDemo -- demonstrate Softi2CMaster
 *
 *
 *
 *  
 */

const int debug     = 1;
const int debug_bus = 0;  // set to zero to debug the bus

const byte addr_max = 17;

const byte sdaPin = 7;
const byte sclPin = 6;

#include "SoftI2CMaster.h"
SoftI2CMaster i2c = SoftI2CMaster( sdaPin,sclPin );

// must define "i2c" before including BlinkM_funcs_soft.h
#include "BlinkM_funcs_soft.h"


byte blinkm_addr = 9;

//
void setup()
{
  Serial.begin( 19200 );

  Serial.println("BlinkMSoftI2CDemo");

  BlinkM_off(0);

  // flash them all in sync
  blinkm_addr = 0;
  for( int i=0; i< 1000; i++ ) {
    BlinkM_setRGB( blinkm_addr, 255,255,255 );
    delay(10);
    BlinkM_setRGB( blinkm_addr, 0,0,0 );
    delay(10);
    //Serial.print('.');
  }
  
}

//
void loop()
{

  byte r = random(255);
  byte g = random(255);
  byte b = random(255);
  
  BlinkM_setRGB( blinkm_addr, r,g,b );
  delay(10);
  BlinkM_fadeToRGB( blinkm_addr, 0,0,0 );
  delay(1000);
  
}



void BlinkM_off(byte addr)
{
  BlinkM_stopScript( addr );
  BlinkM_setFadeSpeed(addr,20);
  BlinkM_setRGB(addr, 0,0,0 );
}

