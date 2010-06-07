/*
 * BlinkMSetStartupScript -- Set the startup script of a BlinkM
 *
 * script_id   description
 *     1     - R,G,B,R,G,B,....
 *     2     - white blink on & off
 *     3     - red blink on & off
 *     4     - green blink on & off
 *     5     - blue blink on & off
 *     6     - cyan blink on & off
 *     7     - magenta blink on & off
 *     8     - yellow blink on & off
 *     9     - black (off)
 *    10     - hue cycle
 *    11     - random color mood light
 *    12     - virtual candle
 *    13     - virtual water
 *    14     - old neon
 *    15     - the seasons
 *    16     - thunderstorm
 *    17     - stop light
 *    18     - SOS morse code 
 *
 *
 * BlinkM connections to Arduino
 * PWR - -- gnd -- black -- Gnd
 * PWR + -- +5V -- red   -- 5V
 * I2C d -- SDA -- green -- Analog In 4
 * I2C c -- SCK -- blue  -- Analog In 5
 *
 *
 * 2010, Tod E. Kurt, ThingM, http://thingm.com/
 *
 */


#include "Wire.h"
#include "BlinkM_funcs.h"


int blinkmaddr;            // 0 == broadcast, addresses all blinkms

int script_id        = 0;  // 0 = programmable, 1-18 = ROM scripts
int script_reps      = 0;  // 0 = repeat infinitely
int script_fadespeed = 0;  // 1 = slowest fade, 255 = fastest fade
int script_timeadj   = 0;  // 0 = play back normally

void setup()
{
    Serial.begin(19200);
    Serial.println("BlinkMSetStartupScript");
    
    BlinkM_beginWithPower();
    BlinkM_stopScript( blinkmaddr );
    
    Serial.println("looking for BlinkM");
    blinkmaddr = BlinkM_findFirstI2CDevice();
    if( blinkmaddr == -1 ) {
        Serial.println("No I2C devices found");
        return;
    }

    
    Serial.print("Device found at addr ");
    Serial.println( blinkmaddr, DEC);

    BlinkM_setStartupParams( blinkmaddr, 1, 
                             script_id, script_reps, 
                             script_fadespeed, script_timeadj );

    Serial.println("Done. Now doing a victory flash.");
    for( int i=0;i<3;i++) {
        BlinkM_fadeToRGB( blinkmaddr, 0xff,0xff,0xff );
        delay(250);
        BlinkM_fadeToRGB( blinkmaddr, 0x00,0x00,0x00 );
        delay(250);
    }

    BlinkM_stopPower();
    delay(500);
    Serial.println("Playing the script ");
    BlinkM_startPower();
}


void loop()
{
    Serial.println("just loopin'");
    delay(1000);
}
