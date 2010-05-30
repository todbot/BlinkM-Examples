/*
 * BlinkMScriptWriter2 -- Example of how to write a light script
 *
 * Adapted from conversation started by aspitz:
 *   http://getsatisfaction.com/thingm/topics/scripting_the_blinkm
 *
 * BlinkM connections to Arduino
 * PWR - -- gnd -- black -- Gnd
 * PWR + -- +5V -- red   -- 5V
 * I2C d -- SDA -- green -- Analog In 4
 * I2C c -- SCK -- blue  -- Analog In 5
 *
 * Note: This sketch resets the I2C address of the BlinkM.
 *       If you don't want this behavior, comment out "BlinkM_setAddress()"
 *       in setup() and change the variable "blink_addr" to your BlinkM's addr.
 *
 */

#include "Wire.h"
#include "BlinkM_funcs.h"

void setup()
{ 
  byte blinkm_addr = 0x09;

  blinkm_script_line script_lines[] = { 
    { 1, {'f', 20,0x00,0x00 }}, // set fade speed 
    { 1, {'C', 0xff,0xff,0xff }}, // randomly alter 
  };
  byte script_id = 0; // can only write to script 0 
  byte script_len = 2; // number of lines in script 
  byte script_rep = 20; 
  
  BlinkM_beginWithPower();
  
  // comment this out if you don't want to reset the address of your BlinkM
  BlinkM_setAddress( blinkm_addr );
  
  Serial.begin(19200); 
  byte rc = BlinkM_checkAddress( blinkm_addr );
  if( rc == -1 ) 
      Serial.println("\r\nno response");
  else if( rc == 1 ) 
      Serial.println("\r\naddr mismatch");
  
  Serial.println("writing script...");
  
  BlinkM_writeScript( blinkm_addr, script_id, script_len ,script_rep,
                     script_lines ); 
} 

void loop()
{

} 
