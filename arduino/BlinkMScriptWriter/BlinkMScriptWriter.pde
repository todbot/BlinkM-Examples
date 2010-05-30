/*
 * BlinkMScriptWriter -- Example of how to write light scripts
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
 *
 * 2007-8, Tod E. Kurt, ThingM, http://thingm.com/
 */

// so we can see BlinkM_funcs working
#define BLINKM_FUNCS_DEBUG 1 

#include "Wire.h"
#include "BlinkM_funcs.h"

int blinkm_addr = 0x09;


//  the example script we're going to write
blinkm_script_line script1_lines[] = {
 {  1,  {'f', 10,00,00}},
 {  10, {'c', 0x21,0x22,0x23}},  // dim white
 {  10, {'c', 0x41,0x42,0x43}},  // dim white
 {  10, {'c', 0x61,0x62,0x63}},  // dim white
 {  10, {'c', 0x81,0x82,0x83}},  // dim white
 {  50, {'c', 0xa1,0xa2,0xa3}},  // dim white
 {  50, {'c', 0xfd,0xfd,0x01}},  // mostly orange
 {  50, {'c', 0x02,0xfe,0xfe}},  // mostly teal
};
int script1_len = 8;  // number of script lines above


char serInStr[30];  // array that will hold the serial input string


void help()
{
  Serial.println("\r\nBlinkMScriptWriter!\n"
                 "'W' to write the script\n"
                 "'R' to read back the script\n"
                 "'p' to play back the script indefinitely\n"
                 "'o' to stop script playback\n"
                 "'0' to fade to black\n"
                 );
}

void setup()
{
    BlinkM_beginWithPower();

    BlinkM_setAddress( blinkm_addr );
    
    Serial.begin(19200); 
    byte rc = BlinkM_checkAddress( blinkm_addr );
    if( rc == -1 ) 
        Serial.println("\r\nno response");
    else if( rc == 1 ) 
        Serial.println("\r\naddr mismatch");

    help();
    Serial.print("cmd>");
}

void loop()
{
    //read the serial port and create a string out of what you read
    if( readSerialString() ) {
        Serial.println(serInStr);
        char cmd = serInStr[0];
        int num = atoi(serInStr+1);
        if( cmd == 'W' ) {
            Serial.println("Writing new script...");
            BlinkM_writeScript( blinkm_addr, 0, script1_len, 0, script1_lines);
            Serial.println("done.");
        }
        else if( cmd == 'R' ) { 
            Serial.println("Reading back script...");
            
        }
        else if( cmd == 'p' ) {
            Serial.println("Playing Script 0 repeatedly");
            BlinkM_playScript( blinkm_addr, 0,0,0 );
        }
        else if( cmd == 'o' ) {
            Serial.println("Stopping Script 0");
            BlinkM_stopScript( blinkm_addr );
        }
        else if( cmd =='0' ) {
            Serial.println("Fade to black");
            BlinkM_fadeToRGB( blinkm_addr, 0,0,0);
        }
    }
}

//read a string from the serial and store it in an array
//you must supply the array variable
uint8_t readSerialString()
{
  if(!Serial.available()) {
    return 0;
  }
  delay(10);  // wait a little for serial data
  int i = 0;
  while (Serial.available()) {
    serInStr[i] = Serial.read();   // FIXME: doesn't check buffer overrun
    i++;
  }
  serInStr[i] = 0;  // indicate end of read string
  return i;  // return number of chars read
}


