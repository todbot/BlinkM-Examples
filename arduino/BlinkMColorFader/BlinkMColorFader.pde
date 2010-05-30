/*
 * BlinkColorFader -- Example of how to select color & brightness
 *                    with two pots
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

#define blinkm_addr 0x00

// analog in pins used for brightness & hue
#define bri_pot_pin 0
#define hue_pot_pin 1

byte bri_val;
byte hue_val;

void setup()
{
  BlinkM_beginWithPower();
  BlinkM_stopScript(blinkm_addr);  // turn off startup script
} 

void loop()
{
  bri_val = analogRead(bri_pot_pin);    // read the brightness pot
  hue_val = analogRead(hue_pot_pin);    // read the hue pot
  
  // set blinkms with hue & bri, saturation is max
  BlinkM_fadeToHSB( blinkm_addr, hue_val, 255, bri_val );
  
  delay(50);  // wait a bit because we don't need to go fast
} 
