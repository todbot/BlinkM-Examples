/*
 * BlinkMMulti -- 
 *
 *
 * BlinkM connections to Arduino
 * PWR - -- gnd -- black -- Gnd
 * PWR + -- +5V -- red   -- 5V
 * I2C d -- SDA -- green -- Analog In 4
 * I2C c -- SCK -- blue  -- Analog In 5
 *
 *
 * 2007, Tod E. Kurt, ThingM, http://thingm.com/
 *
 */


#include "Wire.h"
#include "BlinkM_funcs.h"

#define BLINKM_ARDUINO_POWERED 1

byte cmd;

char serInStr[30];  // array that will hold the serial input string

void help()
{
    Serial.println("\r\nBlinkMMulti!\n"
                   "'A <n>'     -- change address to <n>\n"
                   "'h <n> <h>' -- set hue on <n> to <h>\n"
                   "'o <n>'     -- stop script on <n>\n"
                   "'O <n>'     -- turn off blinkm <n>\n"
                   "'p <n> <p>' -- play script <p> on <n>\n"
                   "'f <n> <f>' -- set fadespeed on <n> to <f>\n"
                   "'t <n> <t>' -- set timeadj on <n> to <t>\n"
                   "Note: address 0 is broadcast address\n"
                   );
}

void setup()
{
    if( BLINKM_ARDUINO_POWERED ) {
        BlinkM_beginWithPower();
    } 
    else {
        BlinkM_begin();
    }

    Serial.begin(19200);

    // if you want to change addr automatically
    //BlinkM_setAddress( blinkm_addr ); 
    /*
      // if you want to check the address took (a way to detect blinkm)
      byte rc = BlinkM_checkAddress( blinkm_addr );
      if( rc == -1 ) 
      Serial.println("\r\nno response");
      else if( rc == 1 ) 
      Serial.println("\r\naddr mismatch");
    */

    help();
    Serial.print("cmd>");
}


void loop()
{
    if( !readSerialString() ) {  // did we read a string?
        return;
    }

    // yes we did. we can has serialz
    Serial.println(serInStr); // echo back string read
    char cmd = serInStr[0];  // first char is command
    char* str = serInStr+1;  // get me a pointer to the first char

    // most commands are of the format "addr num"
    byte addr = (byte) strtol( str, &str, 10 );
    byte num  = (byte) strtol( str, &str, 10 );  // this might contain 0

    Serial.print("addr ");
    Serial.print(addr,DEC);

    switch(cmd) {
    case '?': 
        help();
        break;
    case 'A':  // set Address
        if( addr>0 && addr<0xff ) {
            Serial.println(" setting address");
            BlinkM_setAddress(addr);
        } else { 
            Serial.println("bad address");
        }
        break;
    case 'h':  // set hue
        Serial.print(" to hue "); 
        Serial.println(num,DEC);
        BlinkM_fadeToHSB( addr, num, 0xff, 0xff );
        break;
    case 'f':  // set fade speed
        Serial.print(" to fadespeed "); 
        Serial.println(num,DEC);
        BlinkM_setFadeSpeed( addr, num );
        break;
    case 't':  // set time adj
        Serial.print(" to time adj "); 
        Serial.println(num,DEC);
        BlinkM_setTimeAdj( addr, num );
        break;
    case 'o':   // stop script
        Serial.println(" stopping script");
        BlinkM_stopScript(addr);
        break;
    case 'O':  // off
      Serial.println(" turning off blinkm");
      BlinkM_fadeToRGB(addr, 0,0,0);
      break;
    case 'p':   // play script
        Serial.print(" playing script ");
        Serial.println(num,DEC);
        BlinkM_playScript( addr, num, 0x00,0x00);
        break;
    default: 
        Serial.println(" unknown cmd");
    } // case

    Serial.print("cmd> ");
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

