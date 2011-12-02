/*
 * BlinkMCommunicator -- Communication gateway between a computer and a BlinkM
 *                       Essentially turns an Arduino to an I2C<->serial adapter
 *
 * Command format is:
 * pos description
 *  0   <startbyte>
 *  1   <i2c_addr>
 *  2   <num_bytes_to_send>
 *  3   <num_bytes_to_receive>
 *  4   <send_byte0>
 *  5..n [<send_byte1>...]
 *
 * Thus minimum command length is 5 bytes long, for reading back a color, e.g.:
 *   {0x01,0x09,0x01,0x01, 'g'}
 * Most commands will be 8 bytes long, say to fade to an RGB color, e.g.:
 *   {0x01,0x09,0x04,0x00, 'f',0xff,0xcc,0x33}
 * The longest command is to write a script line, at 12 bytes long, e.g.:
 *   {0x01,0x09,0x08,0x00, 'W',0x00,0x01,50,'f',0xff,0xcc,0x33}
 * 
 * BlinkM connections to Arduino
 * -----------------------------
 * PWR - -- gnd -- black -- Gnd
 * PWR + -- +5V -- red   -- 5V
 * I2C d -- SDA -- green -- Analog In 4
 * I2C c -- SCK -- blue  -- Analog In 5
 * 
 *
 * 2007-11, Tod E. Kurt, ThingM, http://thingm.com/
 *
 */



#include "Wire.h"
#include "BlinkM_funcs.h"

//#define DEBUG 1

// set this if you're plugging a BlinkM directly into an Arduino,
// into the standard position on analog in pins 2,3,4,5
// otherwise you can set it to false or just leave it alone
const boolean BLINKM_ARDUINO_POWERED = true;

const int CMD_START_BYTE = 0x01;

//int blinkm_addr = 0x09;

const int serBufLen = 32;
byte serInBuf[serBufLen];  // array that will hold the serial input string

int ledPin = 13;

void setup()
{
  Serial.begin(19200); 
  Serial.println("BlinkMCommunicator starting up...");

  pinMode(ledPin, OUTPUT);
  if( BLINKM_ARDUINO_POWERED ) {
    BlinkM_beginWithPower();
  } 
  else {
    BlinkM_begin();
  }
  delay(100);  // wait for power to stabilize

  lookForBlinkM();

  /*  
  byte rc = BlinkM_checkAddress( blinkm_addr );
  if( rc == -1 ) 
    Serial.println("No response");  // FIXME: make this an interogator loop?
  else if( rc == 1 ) 
    Serial.println("I2C address mismatch");
  */

  Serial.println("BlinkMCommunicator ready");
#ifdef DEBUG
  Serial.println("DEBUG MODE: will not allow proper functionality");
#endif
}

void lookForBlinkM()
{
  Serial.print("Looking for a BlinkM: ");
  int a = BlinkM_findFirstI2CDevice();
  if( a == -1 ) {
    Serial.println("No I2C devices found");
  } else { 
    Serial.print("Device found at addr ");
    Serial.println( a, DEC);
    //blinkm_addr = a;
  }
}

// called when address is found in BlinkM_scanI2CBus()
void i2cScanResult( byte addr, byte result )
{
    Serial.write(addr); 
    Serial.write(result);
}

void loop()
{
  int num;
  //read the serial port and create a string out of what you read
  num = readCommand(serInBuf);
  if( num == 0 )   // see if we got a proper command string yet
    return;
  
  digitalWrite(ledPin,HIGH);  // say we're working on it

    byte addr    = serInBuf[1];
    byte sendlen = serInBuf[2];
    byte recvlen = serInBuf[3];
    byte* cmd    = serInBuf+4;

  if( addr == 128 ) { // 128 == i2c scan command
    BlinkM_scanI2CBus( cmd[0], cmd[1], i2cScanResult);
    Serial.write(128);
  }
  else { // normal transaction
    
#ifdef DEBUG
    Serial.print(" addr:"); Serial.print(addr,HEX);
    Serial.print(" sendlen:"); Serial.print(sendlen,HEX);
    Serial.print(" recvlen:"); Serial.print(recvlen,HEX);
    Serial.print(" cmd[0..7]:"); Serial.print(cmd[0],HEX);
    Serial.print(","); Serial.print(cmd[1],HEX); 
    Serial.print(","); Serial.print(cmd[2],HEX);
    Serial.print(","); Serial.print(cmd[3],HEX);
    Serial.print(","); Serial.print(cmd[4],HEX);
    Serial.print(","); Serial.print(cmd[5],HEX);
    Serial.print(","); Serial.print(cmd[6],HEX);
    Serial.print(","); Serial.println(cmd[7],HEX);
#endif

    BlinkM_sendCmd(addr, cmd, sendlen);
      
    // if looking for a response, get it
    if( recvlen!=0 ) {
        byte resp[16];
        int rc = BlinkM_receiveBytes(addr, resp, recvlen);
        for( int i=0; i<recvlen; i++) 
            Serial.write(resp[i]);
    }
    
    for(int i=0; i< serBufLen; i++) {
        serInBuf[i] = 0;  // say we've used the string (not needed really)
    }

  } // normal transaction

  digitalWrite(ledPin,LOW); // show we're done
    
}   

//read a string from the serial and store it in an array
//you must supply the str array variable
//returns number of bytes read, or zero if fail
uint8_t readCommand(byte *str)
{
  uint8_t b,i;
  if( ! Serial.available() ) return 0;  // wait for serial

  b = Serial.read();
  if( b != CMD_START_BYTE )         // check to see we're at the start
    return 0;
#ifdef DEBUG
  Serial.println("startbyte");
#endif

  str[0] = b;
  i = 100;
  while( Serial.available() < 3 ) {   // wait for the rest
    delay(1); 
    if( i-- == 0 ) return 0;        // get out if takes too long
  }
  for( i=1; i<4; i++)
    str[i] = Serial.read();       // fill it up
#ifdef DEBUG
  Serial.println("header");
#endif

  uint8_t sendlen = str[2];
#ifdef DEBUG
  Serial.print("cmdlen:");  Serial.println( sendlen, DEC);
#endif
  if( sendlen == 0 ) return 0;
  i = 100;
  while( Serial.available() < sendlen ) {  // wait for the final part
    delay(1); if( i-- == 0 ) return 0;
  }
  for( i=4; i<4+sendlen; i++ ) 
    str[i] = Serial.read();       // fill it up

#ifdef DEBUG
  Serial.println("got all");
#endif
  return 4+sendlen;
}


