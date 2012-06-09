/*
 * BlinkMFactoryReset --
 */

#include "Wire.h"
#include "BlinkM_funcs.h"

byte blinkm_addr = 0x09;

// stolen from blinkm_nonvol_data.h
blinkm_script_line script0_lines[] = {
        {  1, {'f',   10,0x00,0x00}}, 
        {100, {'c', 0xff,0xff,0xff}},
        { 50, {'c', 0xff,0x00,0x00}},
        { 50, {'c', 0x00,0xff,0x00}},
        { 50, {'c', 0x00,0x00,0xff}},
        { 50, {'c', 0x00,0x00,0x00}}
};
    
int script0_len = 6;  // number of script lines above

void setup() 
{
    Serial.begin(19200);

    Serial.println("BlinkMFactoryReset");

    BlinkM_beginWithPower();
    delay(100);

    Serial.println("Setting I2C address to default of 0x09");
    BlinkM_setAddress( blinkm_addr );  // uncomment to set address

    Serial.println("Writing default light script");
    BlinkM_writeScript(blinkm_addr, 0, script0_len, 0, script0_lines);
    
    Serial.println("Setting startup parameters");
    BlinkM_setStartupParams( blinkm_addr, 1, 0,0,8,0);
    delay(20);

    Serial.println("Done!");
    BlinkM_playScript( blinkm_addr, 0,0,0 );
}

void loop() 
{
    digitalWrite(13, HIGH); // flash Arduino LED for fun
    delay(300);
    digitalWrite(13, LOW);
    delay(300);
}


