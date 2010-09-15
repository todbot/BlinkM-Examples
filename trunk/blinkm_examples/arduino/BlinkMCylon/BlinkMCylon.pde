/*
 * BlinkMCylon -- Create a multi-colored Cylon-like light show with a
 *                chain of several BlinkMs. 
 *                Demonstrates how to communicate with multiple BlinkMs 
 *                on a single I2C bus.
 *
 * BlinkM connections to Arduino
 * PWR - -- gnd -- black -- Gnd
 * PWR + -- +5V -- red   -- 5V
 * I2C d -- SDA -- green -- Analog In 4
 * I2C c -- SCK -- blue  -- Analog In 5
 *
 * There are 13 BlinkMs are addressed from 10..22.
 *
 * 2008 Tod E. Kurt, http://thingm.com/
 *
 * Hello Crash Space
 */

#include "Wire.h"
#include "BlinkM_funcs.h"

int ledPin = 13;

//#define num_blinkms 13
#define num_blinkms 3
#define blinkm_start_addr 9

//#define max_t2  1500
#define max_t2  100

byte curr_blinkm = 0;
int incdec = 1;  // only +1 or -1
byte t1;         // t1 runs from 0-255,0-255,... rolls over
int t2 = max_t2; // t2 is the number of t1s to wait before doing cylon thing
byte debug = 1;

// a little status thing to show it's doing something
void toggleLed() {
    digitalWrite( ledPin, digitalRead(ledPin)==HIGH ? LOW : HIGH );
}

void setup()
{
    Serial.begin(19200);

    //Use ledPin to flash when we get stuff
    pinMode(ledPin, OUTPUT);
    digitalWrite(ledPin, HIGH);

    BlinkM_begin();
  
    // set all BlinkMs to known state
    for( int i=0; i<num_blinkms; i++) {
        BlinkM_stopScript( blinkm_start_addr + i );
        BlinkM_fadeToRGB( blinkm_start_addr + i, 0,0,0); // fade to black
    }
    Serial.print("BlinkMCylon ready\n");
    delay(300);
}

byte h;

// every loop poll knobs
// when t1 rolls over, update blinkm
// when t2 rolls over, move to next blinkm 
void loop()
{

    t1++;
    if( t1==0 ) {     // t1 has rolled over, update LED

        // this is where sensor reading would go

        // move to next LED
        t2--;
        if( t2==0 ) {   // t2 has rolled over, do cylon thing
            t2 = max_t2;
            toggleLed();
            h = h + 20;
            byte blinkm_addr = blinkm_start_addr + curr_blinkm;
            byte r = 255;
            byte g = 10;
            byte b = 10;
            //BlinkM_setFadeSpeed( blinkm_addr, 255);
            //BlinkM_fadeToRGB( blinkm_addr, r,g,b );
            //delay(50); // to allow fade to work
            BlinkM_stopScript( blinkm_addr ); // just in case
            BlinkM_setRGB( blinkm_addr, r,g,b );   // set to color
            //BlinkM_fadeToHSB( blinkm_addr, h,255,255 );
            BlinkM_setFadeSpeed( blinkm_addr, 10);
            BlinkM_fadeToRGB( blinkm_addr, 0,0,0); // fade to black

            // debug
            if( debug ) {
                Serial.print("r,g,b:");
                Serial.print(r,HEX);Serial.print(",");
                Serial.print(g,HEX);Serial.print(",");
                Serial.print(b,HEX);Serial.print(":");
                Serial.print("curr_blinkm:"); Serial.print(curr_blinkm,DEC);
                Serial.print(", addr:"); Serial.println(blinkm_addr,HEX);
            }

            // prepare to move to the next cylon eye element
            curr_blinkm = curr_blinkm + incdec;
            if( incdec == 1 && curr_blinkm == num_blinkms-1 )
                incdec = -1;
            else if( incdec == -1 && curr_blinkm == 0 )
                incdec = 1;
        }

    }
}

