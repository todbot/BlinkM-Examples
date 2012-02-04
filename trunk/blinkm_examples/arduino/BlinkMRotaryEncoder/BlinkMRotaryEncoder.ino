/*
 * BlinkMRotaryEncoder
 *
 * Rotary encoder on pins 2 & 3, rotary encoer button on pin 4
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

const int encoder0APin = 2;           // must be pin 2
const int encoder0BPin = 3;           // can be any pin
const int encoder0Button = 4;


#include "Wire.h"
#include "BlinkM_funcs.h"
#include "RotaryEncoder0_funcs.h"     // defines "encoder0Pos"



const int blinkm_addr = 0;
int hue_val;

//
void setup()
{
  Serial.begin(19200);

  BlinkM_beginWithPower();
  BlinkM_stopScript(blinkm_addr);  // turn off startup script

  RotaryEncoder0_begin();

  pinMode(encoder0Button, INPUT);
  digitalWrite(encoder0Button, HIGH); // turn on internal pullup

  Serial.println("RotaryEncoderTest ready!");
}

//
void loop()
{

  if( digitalRead(encoder0Button) == LOW ) {  // button pressed
    hue_val = encoder0Pos % 255; // make it wrap 0-255
    Serial.print("SET hue=");
    Serial.println(hue_val);
    BlinkM_fadeToHSB( blinkm_addr, hue_val, 255, 255 );
  }

  Serial.print("encoder position: ");
  Serial.println( encoder0Pos );

  delay(100);  // wait a bit because we don't need to go fast

}



