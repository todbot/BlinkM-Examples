/*
 * BlinkMSensor0 -- read a sensor no analog pin out and 
 *                  change the green amount of color 
 * 
 */

#include "Wire.h"
#include "BlinkM_funcs.h"


int sensorPin = 0;    // select the input pin for the potentiometer
int ledPin = 13;      // select the pin for the LED
int sensorValue = 0;  // variable to store the value coming from the sensor

int blinkm_addr = 0;

int redVal = 0;
int grnVal = 0;
int bluVal = 0;

void setup() {
  // declare the ledPin as an OUTPUT:
  pinMode(ledPin, OUTPUT);
  // uncomment this hack to enable internal pull-up on analogIn 0
  // PORTC |= (1<<PORTC0);
  BlinkM_beginWithPower();
  BlinkM_stopScript(blinkm_addr);  // turn off startup script

  Serial.begin(19200);
  Serial.println("BlinkMSensor0 ready");
}

void loop() {
    // read the value from the sensor:
    sensorValue = analogRead(sensorPin); 
    Serial.println(sensorValue);
    //grnVal = sensorValue/4;  // sensor ranges from 0-1023, colors from 0-255
    BlinkM_fadeToHSB( blinkm_addr, sensorValue, 255, 255);
    delay(100);                  
}
