/*
 * WiFiBlinkM - using WiServer on YellowJacket arduino board (or similar),
 *              periodically fetch a 3-channel color count from a URL
 *              and flash those colors on a BlinkM
 *
 * 2010 Tod E. Kurt, http://todbot.com/blog/
 *
 * Based off of SimpleClient in the WiShield library examples
 *
 * Notes:
 * - It takes ~10 seconds for WiFi module to come online (no security)
 * - It takes ~30 seconds for WiFi module to come online using WPA 
 * - it a single 6-digit hex number that looks like a color code ("#FF33cc")
 * - this number is actually a set of 3 counts
 * - these 3 numbers are used as number of flashes to do, for 3 "channels"
 * - they are labelled 'r', 'g', 'b', even though the colors they do may not be
 * - hold down button on pin "swPin" to enable offline mode, or set "offline=1"
 * 
 * Installation:
 * 1. Be sure to copy the "WiShield" library located in the "libraries" 
 *    directory into your computer's {sketchbook}/libraries directory 
 *    and restart the Arduino IDE
 *
 * 2. Edit WiShield/apps-conf.h to have "#define APP_WISERVER" uncommented
 *    (this is already done for you in "libraries/WiShield" in this dir)
 * 
 * 3. Edit the values is this sketch's "wifi_conf.h" to match your network.
 *
 *
 * Sending Twitter Streaming API requests:
 * - You can see the exact request you need to send by doing:
 *     curl -v 'http://blinkmlive:redgreenblue@stream.twitter.com/1/statuses/filter.json?track=colbert'
 * - which is:
 *     GET /1/statuses/filter.json?track=colbert HTTP/1.1
 *     Authorization: Basic YmxpbmttbGl2ZTpyZWRncmVlbmJsdWU=
 *     User-Agent: TweetM
 *     Host: stream.twitter.com
 *     Accept: * / *
 *     (the Accept header has spaces removed betwen * and /)
 *
 */

#include <string.h>
#include <avr/pgmspace.h>

#include "WiServer.h"
#include "Wire.h"
#include "BlinkM_funcs.h"

// all the parameters needed to join your wifi network go in here
#include "wifi_config.h"

// if all else fails, set this to 1 to produce life-like behavior
byte offline = 0; 

// setting this to 1 will show the actual page contents on the serial console
// debug levels:
// 0 -- debugging off
// 1 -- basic info, connections, keywords found, etc.
// 2 -- full text of web responses
// 3 -- color flash counts
#define DEBUG 1


// FIXME: need to compute auth
//char twuser[] = "blinkmlive";
//char twpass[] = "redgrnblu";
char twauth[] = "YmxpbmttbGl2ZTpyZWRncmVuYmx1ZQ==";

// The URL we're fetching.  Need to do DNS lookup by hand
char hostname[] = "stream.twitter.com";
uint8 ipaddr[]  = {168,143,162,55};  // comma-separated, not dot
const char baseurl[] PROGMEM  = "/1/statuses/filter.json?track=";
const int port  = 80;

const int updateSecs = 10;         // fetch update rate, every N seconds
const int colorUpdateMillis = 500; // color update rate, every N millisecs

// IDEA: instead of making it array of arrays,
// make it a linear list: "one,two,three,four+five,six"
// and do split on-the-fly
// because this takes up 160 bytes even if you use only 1 keyword
// e.g. char keywords[160] =  "one,two,three,..."
// oh no wait, that would only save for compile-time keywords
// we eventually want run-time.  maybe if we use malloc() (egads!)
const int keywords_max = 10;
const int keywords_len = 16;

char endtweet[] = "}\r\n";  // this marks the end of tweet data

// the keywords you can choose
char keywords[keywords_max][keywords_len] = 
    {//  0123456789012345  <--- max size of each keyword
        "stephen+colbert",
        "colbert", 
        "usa",
        "freedom",
        "tomato",
        "salsa",
    };
// the color to flash 
long keycolors[keywords_max] = 
    {
        0x333333,
        0xffffff,
        0x0000ff,
        0x0000ff,
        0xff0000,
        0xff0000,
    };

int counts[keywords_max];
int tmpcnts[keywords_max];

const int urllen = 100;
char url[urllen];

// create a request object with most of the data (fill URL in later)
GETrequest myRequest(ipaddr, port, hostname, NULL);

// the last color counts received 
uint8_t lastR, lastG, lastB;

// string processing in C, laa da dee da dee!
void buildQueryURL()
{
    int l;
    strcpy_P( url, baseurl );            // get the start of it
    for( int i=0; i< keywords_max; i++ ) {
        l = strlen( url );
        if( strlen(keywords[i]) == 0 ) continue;
        strcpy( url+l, keywords[i] );   // add each keyword to it
        l = strlen( url );
        strcpy( url+l, ","); // FIXME:
    }
    url[strlen(url)-1] = 0;  // remove trailing ','  (yeah wasteful)
}

// Function that prints data from the server
void parseData(char* data, int len)
{
    data[len] = 0;  // null terminate, does kill last char tho
    strlwr(data);   // convert to lower case
#if DEBUG > 1
    Serial.println(data); // print out the server's response (slows down things)
#endif
    // go through the keywords, looking for a match
    for( int i=0; i< keywords_max; i++ ) {
        if( strlen(keywords[i]) == 0 ) continue;
        if( strstr( data, keywords[i] ) != NULL ) {
            tmpcnts[i]++;
#if DEBUG > 0
            SerialPrintPStr(PSTR("** FOUND keyword: "));
            Serial.println( keywords[i] );
#endif
        }
    }
    // see if we're at the end of a tweet
    if( strstr( data, endtweet ) != NULL ) {
        for( int i=0; i< keywords_max; i++ ) {
            if( tmpcnts[i] ) counts[i]++;
            tmpcnts[i] = 0;
        }
#ifdef DEBUG > 0
        SerialPrintPStr(PSTR("--------endtweet------\n"));
#endif
    }
}


// ---------------------------------------------------------------------

// Time (in millis) when the data should be retrieved 
long updateTime;
long colorUpdateTime;

const int swPin = 6;   // pin where button is  

byte swPinCount;

//
byte swPressed() 
{
    return (digitalRead(swPin)==0); // button pressed 
}

//
void goOffline(void)
{
    SerialPrintPStr(PSTR("offline mode\n"));
    offline = 1;
    for( int i=0;i<3;i++) {          // waggle to show off
        BlinkM_setRGB(0, 44,44,44 ); // mm love fours 
        delay(100);
        BlinkM_setRGB(0, 00,00,00 );
        delay(100);
    }
}

//
void setup() 
{
    pinMode(swPin, INPUT);
    digitalWrite(swPin, HIGH); // turn on internal pullup

    Serial.begin(57600);
    SerialPrintPStr( PSTR("WifiBlinkM\n") );

    buildQueryURL();        // construct URL
    Serial.println( url );  // always print this

    myRequest.setURL( url );
    myRequest.setAuth( twauth );
    myRequest.setReturnFunc(parseData);

    // setup blinkm
    BlinkM_beginWithPower();
    delay(300);  // let the power stabilize
    BlinkM_stopScript( 0 );
    BlinkM_setRGB( 0, 0,0,0); 
    BlinkM_setFadeSpeed(0, 30);
    BlinkM_setTimeAdj(0, -10);
    // play a little red-white-blue
    BlinkM_setRGB( 0, 0x66,0x00,0x00 );
    delay(400);
    BlinkM_setRGB( 0, 0x66,0x66,0x66 );
    delay(400);
    BlinkM_setRGB( 0, 0x00,0x00,0x66 );
    delay(400);
    BlinkM_setRGB( 0, 0x00,0x00,0x00 );

    if( swPressed() ) {
        goOffline();
    }
    if( offline ) { 
        SerialPrintPStr( PSTR("offline\n") );
        return;
    }

    // Initialize WiServer (NULL for page serving function since not serving)
    WiServer.init(NULL);

#if DEBUG > 1
    WiServer.enableVerboseMode(true);
#endif

    colorUpdateTime = millis() + colorUpdateMillis;

    SerialPrintPStr(PSTR("online\n"));
}
    //
void loop()
{
    // Check if it's time to get an update
    if (millis() >= updateTime) {
        updateTime += 1000 * updateSecs;  // N secs from now
        if( offline ) {
            SerialPrintPStr(PSTR("offline\n"));
            lastR = rand() % 5;
            lastG = rand() % 5;
            lastB = rand() % 5;
        } 
        else {
            lastR = counts[0];
            lastG = counts[1];
            lastB = counts[2];
            for( int i=0; i< keywords_max; i++) {
                if( counts[i] > 0 ) {     // transfer over to flashing leds
                    //lastR += counts[i];   // FIXME:    
                }
                tmpcnts[i] = counts[i] = 0;  // reset
            }
            if( myRequest.isActive() ) {
                SerialPrintPStr(PSTR("query still active\n"));
            } 
            else {
                SerialPrintPStr(PSTR("fetching\n"));
                myRequest.submit();
            }
        }
    }
    
    if( millis() >= colorUpdateTime ) {
        colorUpdateTime += colorUpdateMillis;
#if DEBUG > 2        
        SerialPrintPStr(PSTR("r,g,b:"));
        Serial.print(lastR, HEX);  Serial.print(',');
        Serial.print(lastG, HEX);  Serial.print(',');
        Serial.print(lastB, HEX);  Serial.print('\n');
#endif
        if( swPressed() ) {
            swPinCount++;
            if( swPinCount > 10 ) {  // 10*500 = 5000
                goOffline();
            }
        }
        else {
            swPinCount = 0;  // reset counter
        }

        uint8_t n = rand() % 3; // give a little randomness to the color play

        if( n==0 && lastR ) {
            BlinkM_playScript( 0, 3, 1, 0); // script #3 is red flashing
            lastR--;
        }
        else if( n==1 && lastG ) {
            BlinkM_playScript( 0, 2, 1, 0); // script #2 is white flashing
            lastG--;
        }
        else if( n==2 && lastB ) {
            BlinkM_playScript( 0, 5, 1, 0); // script #5 is blu flashing
            lastB--;
        }
    }
 
    if( !offline ) 
        WiServer.server_task();      // Run WiServer

    delay(1);
}

// given a PROGMEM string, use Serial.print() to send it out
void SerialPrintPStr(const prog_char str[])
{
  char c;
  if(!str) return;
  while((c = pgm_read_byte(str++)))
    Serial.print(c,BYTE);
}


