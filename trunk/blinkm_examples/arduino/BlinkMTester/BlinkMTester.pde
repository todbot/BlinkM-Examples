/*
 * BlinkMTester -- Simple "command-line" tool to play with BlinkMs
 *
 *  Once you load this sketch on to your Arduino, open the Serial Monitor
 *  and you'll see a menu of things to do.
 *
 *
 * BlinkM connections to Arduino
 * PWR - -- gnd -- black -- Gnd
 * PWR + -- +5V -- red   -- 5V
 * I2C d -- SDA -- green -- Analog In 4
 * I2C c -- SCK -- blue  -- Analog In 5
 *
 * Note: This sketch DOES NOT reset the I2C address of the BlinkM.
 *       If you want to change the I2C address use the 'A<n>' command.
 *
 * 2007-10, Tod E. Kurt, ThingM, http://thingm.com/
 *
 */


#include "Wire.h"
#include "BlinkM_funcs.h"

#include <avr/pgmspace.h>  // for progmem stuff

#define BLINKM_ARDUINO_POWERED 1

byte blinkm_addr = 0x09; // the default address of all BlinkMs

char serInStr[30];  // array that will hold the serial input string

const char helpstr[] PROGMEM = 
  "\nBlinkMTester!\n"
  "'c<rrggbb>'  fade to an rgb color\n"
  "'h<hhssbb>'  fade to an hsb color\n"
  "'C<rrggbb>'  fade to a random rgb color\n"
  "'H<hhssbb>'  fade to a random hsb color\n"
  "'p<n>'  play a script\n"
  "'o'  stop a script\n"
  "'f<nn>'  change fade speed\n"
  "'t<nn>'  set time adj\n"
  "'g'  get current color\n"
  "'a'  get I2C address\n"
  "'A<n>'  set I2C address\n"
  "'B'  set startup params to default\n"
  "'Z'  get BlinkM version\n"
  "'i'  get input values\n"
  "'s'/'S'  scan i2c bus for 1st BlinkM / search for devices\n"
  "'?'  for this help msg\n\n"
  ;
//const char badAddrStr[] PROGMEM = 
//  "BlinkM not at expected address.  Reset address with 'A' command\n";

// There are cases where we can't use the obvious Serial.println(str) because
// the string is PROGMEM and Serial doesn't know how to deal with that
// (we store strings in PROGMEM instead of normal RAM to save RAM space)
void printProgStr(const prog_char str[])
{
  char c;
  if(!str) return;
  while((c = pgm_read_byte(str++)))
    Serial.print(c,BYTE);
}

void help()
{
  printProgStr( helpstr );
}

// called when address is found in BlinkM_scanI2CBus()
void scanfunc( byte addr, byte result ) {
  Serial.print("addr: ");
  Serial.print(addr,DEC);
  Serial.print( (result==0) ? " found!":"       ");
  Serial.print( (addr%4) ? "\t":"\n");
}

void lookForBlinkM() {
  Serial.print("Looking for a BlinkM: ");
  int a = BlinkM_findFirstI2CDevice();
  if( a == -1 ) {
    Serial.println("No I2C devices found");
  } else { 
    Serial.print("Device found at addr ");
    Serial.println( a, DEC);
    blinkm_addr = a;
  }
}

// arduino setup func
void setup()
{
  if( BLINKM_ARDUINO_POWERED )
    BlinkM_beginWithPower();
  else
    BlinkM_begin();

  delay(1000); // wait a bit for things to stabilize

  //BlinkM_setAddress( blinkm_addr );  // uncomment to set address
    
  Serial.begin(19200);

  help();
  
  lookForBlinkM();

  /*
  byte addr = BlinkM_getAddress(blinkm_addr);
  if( addr != blinkm_addr ) {
    if( addr == -1 ) 
      Serial.println("\r\nerror: no response");
    else if( addr != blinkm_addr ) {
      Serial.print("\r\nerror: addr mismatch, addr received: ");
      Serial.println(addr, HEX);
    }
  }
  */
  Serial.print("cmd>");
}

// arduino loop func
void loop()
{
  int num;
  //read the serial port and create a string out of what you read
  if( readSerialString() ) {
    Serial.println(serInStr);
    char cmd = serInStr[0];  // first char is command
    char* str = serInStr;
    while( *++str == ' ' );  // got past any intervening whitespace
    num = atoi(str);         // the rest is arguments (maybe)
    if( cmd == '?' ) {
      help();
    }
    else if( cmd == 'c' || cmd=='h' || cmd == 'C' || cmd == 'H' ) {
      byte a = toHex( str[0],str[1] );
      byte b = toHex( str[2],str[3] );
      byte c = toHex( str[4],str[5] );
      if( cmd == 'c' ) {
        Serial.print("Fade to r,g,b:");
        BlinkM_fadeToRGB( blinkm_addr, a,b,c);
      } else if( cmd == 'h' ) {
        Serial.print("Fade to h,s,b:");
        BlinkM_fadeToHSB( blinkm_addr, a,b,c);
      } else if( cmd == 'C' ) {
        Serial.print("Random by r,g,b:");
        BlinkM_fadeToRandomRGB( blinkm_addr, a,b,c);
      } else if( cmd == 'H' ) {
        Serial.print("Random by h,s,b:");
        BlinkM_fadeToRandomHSB( blinkm_addr, a,b,c);
      }
      Serial.print(a,HEX); Serial.print(",");
      Serial.print(b,HEX); Serial.print(",");
      Serial.print(c,HEX); Serial.println();
    }
    else if( cmd == 'f' ) {
      Serial.print("Set fade speed to:"); Serial.println(num,DEC);
      BlinkM_setFadeSpeed( blinkm_addr, num);
    }
    else if( cmd == 't' ) {
      Serial.print("Set time adj:"); Serial.println(num,DEC);
      BlinkM_setTimeAdj( blinkm_addr, num);
    }
    else if( cmd == 'p' ) {
      Serial.print("Play script #");
      Serial.println(num,DEC);
      BlinkM_playScript( blinkm_addr, num,0,0 );
    }
    else if( cmd == 'o' ) {
      Serial.println("Stop script");
      BlinkM_stopScript( blinkm_addr );
    }
    else if( cmd == 'g' ) {
      Serial.print("Current color: ");
      byte r,g,b;
      BlinkM_getRGBColor( blinkm_addr, &r,&g,&b);
      Serial.print("r,g,b:"); Serial.print(r,HEX);
      Serial.print(",");      Serial.print(g,HEX);
      Serial.print(",");      Serial.println(b,HEX);
    }
    /*
      else if( cmd == 'W' ) { 
      Serial.println("Writing new eeprom script");
      for(int i=0; i<6; i++) {
      blinkm_script_line l = script_lines[i];
      BlinkM_writeScriptLine( blinkm_addr, 0, i, l.dur,
      l.cmd[0],l.cmd[1],l.cmd[2],l.cmd[3]);
      }
      }
    */
    else if( cmd == 'A' ) {
      if( num>0 && num<0xff ) {
        Serial.print("Setting address to: ");
        Serial.println(num,DEC);
        BlinkM_setAddress(num);
        blinkm_addr = num;
      } else if ( num == 0 ) {
        Serial.println("Resetting address to default 9: ");
        blinkm_addr = 9;
        BlinkM_setAddress(blinkm_addr);
      }
    }
    else if( cmd == 'a' ) {
      Serial.print("Address: ");
      num = BlinkM_getAddress(0); 
      Serial.println(num);
    }
    else if( cmd == '@' ) {
      Serial.print("Will now talk on BlinkM address: ");
      Serial.println(num,DEC);
      blinkm_addr = num;
    }
    else if( cmd == 'Z' ) { 
      Serial.print("BlinkM version: ");
      num = BlinkM_getVersion(blinkm_addr);
      if( num == -1 )
        Serial.println("couldn't get version");
      Serial.print( (char)(num>>8), BYTE ); 
      Serial.println( (char)(num&0xff),BYTE );
    }
    else if( cmd == 'B' ) {
      Serial.print("Set startup mode:"); Serial.println(num,DEC);
      BlinkM_setStartupParams( blinkm_addr, num, 0,0,1,0);
    }
    else if( cmd == 'i' ) {
      Serial.print("get Inputs: ");
      byte inputs[4];
      BlinkM_getInputs(blinkm_addr, inputs); 
      for( byte i=0; i<4; i++ ) {
        Serial.print(inputs[i],HEX);
        Serial.print( (i<3)?',':'\n');
      }
    }
    else if( cmd == 's' ) { 
      lookForBlinkM();
    }
    else if( cmd == 'S' ) {
      Serial.println("Scanning I2C bus from 1-100:");
      BlinkM_scanI2CBus(1,100, scanfunc);
      Serial.println();
    }
    else { 
      Serial.println("Unrecognized cmd");
    }
    serInStr[0] = 0;  // say we've used the string
    Serial.print("cmd>");
  } //if( readSerialString() )
  
}

//read a string from the serial and store it in an array
//you must supply the array variable
uint8_t readSerialString()
{
  if(!Serial.available()) {
    return 0;
  }
  delay(10);  // wait a little for serial data

  memset( serInStr, 0, sizeof(serInStr) ); // set it all to zero
  int i = 0;
  while (Serial.available()) {
    serInStr[i] = Serial.read();   // FIXME: doesn't check buffer overrun
    i++;
  }
  //serInStr[i] = 0;  // indicate end of read string
  return i;  // return number of chars read
}

// -----------------------------------------------------
// a really cheap strtol(s,NULL,16)
#include <ctype.h>
uint8_t toHex(char hi, char lo)
{
  uint8_t b;
  hi = toupper(hi);
  if( isxdigit(hi) ) {
    if( hi > '9' ) hi -= 7;      // software offset for A-F
    hi -= 0x30;                  // subtract ASCII offset
    b = hi<<4;
    lo = toupper(lo);
    if( isxdigit(lo) ) {
      if( lo > '9' ) lo -= 7;  // software offset for A-F
      lo -= 0x30;              // subtract ASCII offset
      b = b + lo;
      return b;
    } // else error
  }  // else error
  return 0;
}


