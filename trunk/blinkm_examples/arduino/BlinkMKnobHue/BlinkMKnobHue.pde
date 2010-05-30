
/*
 * BlinkKnobHue -- Example of how to use a pot to set BlinkM hue
 *
 * 
 * For more info on how to use pots and analog inputs see:
 *  http://www.arduino.cc/en/Tutorial/AnalogInput
 *
 * BlinkM connections to Arduino
 * PWR - -- gnd -- black -- Gnd
 * PWR + -- +5V -- red   -- 5V
 * I2C d -- SDA -- green -- Analog In 4
 * I2C c -- SCK -- blue  -- Analog In 5
 *
 * Note: This sketch sends to the I2C "broadcast" address of 0, 
 *       so all BlinkMs on the I2C bus will respond.
 */


#include "Wire.h"
#include "BlinkM_funcs.h"

const int blinkm_addr = 0;
const int hue_pot_pin = 0;

void setup()
{
  Serial.begin(19200);
  BlinkM_beginWithPower();
  BlinkM_stopScript(blinkm_addr);  // turn off startup script
  Serial.println("BlinkMKnobHue ready");
}

void loop() 
{
  // read the hue pot,  values range from 0-1023, blinkm's 0-255, thus /4
  int hue_val = analogRead(hue_pot_pin) / 4;  
  Serial.println(hue_val);
  // set blinkms with hue; brightness & saturation is max
  BlinkM_fadeToHSB( blinkm_addr, hue_val, 255, 255 );
  delay(50);  // wait a bit because we don't need to go fast
}


