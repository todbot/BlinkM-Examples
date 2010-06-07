/*
 * BlinkMSetStartupScript -- Set the startup script of a BlinkM
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


int blinkmaddr;  // 0 == broadcast, addresses all blinkms

int script_id = 0;
int script_fadespeed = 0;
int script_timeadj = 0;

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

    Serial.println("Done");
}


void loop()
{
    Serial.println("Flashing BlinkM");

    BlinkM_fadeToRGB( blinkmaddr, 0xff,0xff,0xff );
    delay(1000);
    BlinkM_fadeToRGB( blinkmaddr, 0x00,0x00,0x00 );
    delay(1000);
}
