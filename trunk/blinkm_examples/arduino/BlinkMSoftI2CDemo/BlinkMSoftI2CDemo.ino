/* 
 * BlinkMSoftI2CDemo -- very simply demonstrate Softi2CMaster library
 *
 *
 *
 * 2010 Tod E. Kurt, http://todbot.com/blog/
 *  
 */

const boolean testingI2CReads = true;

// Choose any pins you want.  The pins below let you plug a BlinkM directly in
const byte sclPin = 7;  // digital pin 7 wired to 'c' on BlinkM
const byte sdaPin = 6;  // digital pin 6 wired to 'd' on BlinkM
const byte pwrPin = 5;  // digital pin 5 wired to '+' on BlinkM
const byte gndPin = 4;  // digital pin 4 wired to '-' on BlinkM

#include "./SoftI2CMaster.h"
SoftI2CMaster i2c = SoftI2CMaster( sdaPin,sclPin );
// or if you want to use your own external pullup resistors
//SoftI2CMaster i2c = SoftI2CMaster( sdaPin,sclPin, false );

// must define "i2c" before including BlinkM_funcs_soft.h
#include "BlinkM_funcs_soft.h"


byte blinkm_addr = 9;

//
void setup()
{
  Serial.begin( 19200 );
  Serial.println("BlinkMSoftI2CDemo");
  
  BlinkM_beginWithPower( pwrPin, gndPin );
  delay(100);
 
  BlinkM_off(0);
  BlinkM_setFadeSpeed( blinkm_addr, 5);

  for( int i=0; i< 10; i++ ) {  // flash the blinkms
    BlinkM_setRGB( blinkm_addr, 255,255,255 );
    delay(20);
    BlinkM_setRGB( blinkm_addr, 0,0,0 );
    delay(20);
  }
  
  if( testingI2CReads ) { 
    Serial.print("BlinkM version: ");
    int num = BlinkM_getVersion( blinkm_addr );
    Serial.print( (char)(num>>8) ); 
    Serial.println( (char)(num&0xff) );
  }
}

void loop()
{
  byte r = random(255);
  byte g = random(255);
  byte b = random(255);
  
  Serial.print("Setting r,g,b:"); Serial.print(r,HEX);
  Serial.print(",");      Serial.print(g,HEX);
  Serial.print(",");      Serial.println(b,HEX);
  
  BlinkM_setRGB( blinkm_addr, r,g,b );
  delay(50);
  BlinkM_fadeToRGB( blinkm_addr, 0,0,0 );

  if( testingI2CReads ) {
    for( int i=0; i<10; i++ ) {
      showCurrentColor();
      delay(100);
    }
  } 
  else {
    delay(1000);
  }
}

//
void showCurrentColor()
{
  byte r,g,b;
  BlinkM_getRGBColor( blinkm_addr, &r,&g,&b);

  Serial.print("        r,g,b:"); Serial.print(r,HEX);
  Serial.print(",");      Serial.print(g,HEX);
  Serial.print(",");      Serial.println(b,HEX);
}



