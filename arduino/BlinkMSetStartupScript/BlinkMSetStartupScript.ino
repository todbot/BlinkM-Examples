/*
 * BlinkMSetStartupScript -- Set the startup script of a BlinkM
 *
 * How to use:
 * 1. Set the following variables to match your desired behavior:
 *      'script_id', 'script_reps', 'script_fadespeed', script_time_adj'
 *    If you don't know what all these mean, just change 'script_id' to one
 *    of the numbers in the "Script_id List" below.
 * 2. With your Aruino unplugged, plug your BlinkM to your Arduino
 * 3. Plug your Arduino back into your computer
 * 4. Upload the sketch
 * 5. After a second, it should start playing the script you chose
 * 6. If you want, open the Serial Montior at 19200bps and see status messags
 *
 * Script_id List
 * -------------- 
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

int script_id        = 11;   // 0 = programmable, 1-18 = ROM scripts
int script_reps      = 0;   // 0 = repeat infinitely
int script_fadespeed = 5;  // 1 = slowest fade, 255 = fastest fade
int script_timeadj   = 0;   // 0 = play back normally, + slower, - faster

void setup()
{
    Serial.begin(19200);
    Serial.println("BlinkMSetStartupScript");
    
    Serial.println("Looking for BlinkM");

    BlinkM_beginWithPower();
    BlinkM_stopScript( blinkmaddr );
    
    blinkmaddr = BlinkM_findFirstI2CDevice();
    if( blinkmaddr == -1 ) {
        Serial.println("No I2C devices found");
        return;
    }
    Serial.print("Device found at addr ");
    Serial.println( blinkmaddr, DEC);

    Serial.println("Setting startup params:");
    Serial.print("  script_id:        "); Serial.println(script_id);
    Serial.print("  script_reps:      "); Serial.println(script_reps);
    Serial.print("  script_fadespeed: "); Serial.println(script_fadespeed);
    Serial.print("  script_timeadj:   "); Serial.println(script_timeadj);

    BlinkM_setStartupParams( blinkmaddr, 1, // always 1 unless you know better
                             script_id, script_reps, 
                             script_fadespeed, script_timeadj );

    Serial.println("Done. Now doing a victory flash.");
    for( int i=0;i<3;i++) {
        BlinkM_setRGB( blinkmaddr, 0x44,0x44,0x44 );
        delay(100);
        BlinkM_setRGB( blinkmaddr, 0x00,0x00,0x00 );
        delay(100);
    }
    delay(500);

    Serial.println("Playing the script ");
    BlinkM_stopPower();
    delay(500);
    BlinkM_startPower();
}


void loop()
{
    Serial.println("just loopin'");
    delay(2000);
}
