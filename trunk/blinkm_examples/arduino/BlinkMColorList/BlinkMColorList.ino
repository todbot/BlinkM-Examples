/*
 * BlinkColorList -- 
 *                   
 *
 * BlinkM connections to Arduino
 * PWR - -- gnd -- black -- Gnd
 * PWR + -- +5V -- red   -- 5V
 * I2C d -- SDA -- green -- Analog In 4
 * I2C c -- SCK -- blue  -- Analog In 5
 *
 * Note: This sketch sends to the I2C "broadcast" address of 0, 
 *       so all BlinkMs on the I2C bus will respond.
 *
 * 2008, Tod E. Kurt, ThingM, http://thingm.com/
 */

#include "Wire.h"
#include "BlinkM_funcs.h"

#define blinkm_addr 0x00


int delay_time = 1000; // time betwen colors, 1000 milliseconds = 1 second

int num_colors = 7;  // how many colors are there the list below

byte color_list[][3] = {
  { 0xff, 0xff, 0xff }, // white
  { 0xff, 0x00, 0xff }, // purple
  { 0xff, 0xff, 0x00 }, // orange
  { 0x00, 0xff, 0xff }, // cyan
  { 0xff, 0x00, 0x00 }, // red
  { 0xff, 0x00, 0x00 }, // red
  { 0xff, 0x00, 0x00 }, // red
  { 0x00, 0x00, 0x00 }, // black
};



int i = 0;
byte r,g,b; 

void setup()
{
  BlinkM_beginWithPower();  
  BlinkM_stopScript( blinkm_addr );  // turn off startup script
} 

void loop()
{
  r = color_list[i][0];
  g = color_list[i][1];
  b = color_list[i][2];
  
  BlinkM_fadeToRGB( blinkm_addr, r,g,b );
  
  delay(delay_time);  // wait a bit because we don't need to go fast
  
  i++;
  if( i > num_colors ) {
    i = 0;
  }
} 
