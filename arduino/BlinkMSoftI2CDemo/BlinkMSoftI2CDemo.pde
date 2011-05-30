/* 
 * BlinkMSoftI2CDemo -- very simply demonstrate Softi2CMaster library
 *
 *
 *
 * 2010 Tod E. Kurt, http://todbot.com/blog/
 *  
 */

const byte sdaPin = 7;  // digital pin 7 wired to 'd' on BlinkM
const byte sclPin = 6;  // digital pin 6 wired to 'c' on BlinkM

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
  delay(500);
  
  BlinkM_off(0);

  for( int i=0; i< 100; i++ ) {  // flash the blinkms
    BlinkM_setRGB( blinkm_addr, 255,255,255 );
    delay(10);
    BlinkM_setRGB( blinkm_addr, 0,0,0 );
    delay(10);
  }
}

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


