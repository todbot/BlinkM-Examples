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
 * 1. Be sure to copy the "WiShield" library in the "libraries" directory
 * into your {sketchbook}/libraries directory and restart the Arduino IDE
 *
 * 2. Edit WiShield/apps-conf.h to have "#define APP_WISERVER" uncommented
 * 
 * 3. Edit the values is this sketch's "wifi_conf.h" to match your network.
 *
 */

#include "WiServer.h"
#include "Wire.h"
#include "BlinkM_funcs.h"

// all the parameters needed to join your wifi network go in here
#include "wifi_config.h"

// if all else fails, set this to 1 to produce life-like behavior
byte offline = 0; 

// setting this to 1 will show the actual page contents on the serial console
#define DEBUG 0



// The URL we're fetching.  Need to do DNS lookup by hand
char hostname[] = "todbot.com";
uint8 ipaddr[]  = {70,32,68,89};  // comma-separated, not dot
char uri[]      = "/colberttweets/";
const int port  = 80;
const int updateSecs = 10;  // update rate, every N seconds

// A request that gets the latest METAR weather data for LAX
GETrequest myRequest(ipaddr, port, hostname, uri);

// the last color counts received 
uint8_t lastR, lastG, lastB;

// Function that prints data from the server
void parseData(char* data, int len)
{
    char colorcode[7];
    char codestart = -1;

    // Deal with the data returned by the server
    // Note that the data is not null-terminated, may be broken up
    // into smaller packets, and includes the HTTP header. 
    while (len-- > 0) {
        char c = *(data++);
#if DEBUG > 0
        Serial.print(c); //*(data++));
#endif
        // look for "#123456"
        if( codestart >= 0 && codestart < 7 ) {
            colorcode[codestart++] = c;
        }
        if( c=='#' ) {
            codestart=0;
        }
    } 
    // we have a colorcode string, so let's parse it
    if( codestart != -1 ) {
        colorcode[6] = 0;  // null-terminate the string
        Serial.print("color code: ");
        Serial.println( colorcode );

        long colorVal = strtol(colorcode,NULL,16);
        lastR = (colorVal&0xff0000) >>16;
        lastG = (colorVal&0x00ff00) >> 8;
        lastB = (colorVal&0x0000ff) >> 0;
    }
}

// ---------------------------------------------------------------------

const int swPin = 6;   // pin where button is  

byte swPinCount;

byte swPressed() 
{
    return (digitalRead(swPin)==0); // button pressed 
}

void goOffline(void)
{
    Serial.println("offline mode");
    offline = 1;
    for( int i=0;i<3;i++) {          // waggle to show off
        BlinkM_setRGB(0, 44,44,44 ); // mm love fours 
        delay(100);
        BlinkM_setRGB(0, 00,00,00 );
        delay(100);
    }
}

void setup() 
{
    pinMode(swPin, INPUT);
    digitalWrite(swPin, HIGH); // turn on internal pullup

    Serial.begin(57600);
    Serial.println("WifiBlinkM");

    // setup blinkm
    BlinkM_beginWithPower();
    delay(300);  // let the power stabilize
    BlinkM_stopScript( 0 );
    BlinkM_setRGB( 0, 0,0,0); 
    BlinkM_setFadeSpeed(0, 30);
    BlinkM_setTimeAdj(0, -10);
    // play a little red-white-blue
    BlinkM_fadeToRGB( 0, 0x66,0x00,0x00 );
    delay(400);
    BlinkM_fadeToRGB( 0, 0x66,0x66,0x66 );
    delay(400);
    BlinkM_fadeToRGB( 0, 0x00,0x00,0x66 );
    delay(400);
    BlinkM_fadeToRGB( 0, 0x00,0x00,0x00 );

    if( swPressed() ) {
        goOffline();
    }

    if( offline ) { 
        Serial.println("offline");
        return;
    }

    // Initialize WiServer (NULL for page serving function since not serving)
    WiServer.init(NULL);

#if DEBUG > 0
    WiServer.enableVerboseMode(true);
#endif
    // Have the processData function called when data is returned by the server
    myRequest.setReturnFunc(parseData);
    Serial.println("online");
}


// Time (in millis) when the data should be retrieved 
long updateTime = 0;
long colorUpdateTime = 0;

void loop()
{
    // Check if it's time to get an update
    if (millis() >= updateTime) {
        updateTime += 1000 * updateSecs;  // N secs from now
        if( offline ) {
            Serial.println("offline");
            lastR = rand() % 5;
            lastG = rand() % 5;
            lastB = rand() % 5;
        } else {
            Serial.println("fetching");
            myRequest.submit();
        }
    }
    
    if( millis() >= colorUpdateTime ) {
        colorUpdateTime += 500;

        Serial.print("r,g,b:");
        Serial.print(lastR, HEX);  Serial.print(',');
        Serial.print(lastG, HEX);  Serial.print(',');
        Serial.print(lastB, HEX);  Serial.print('\n');

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


/*
 * state machine idea
 * 

enum {
    off0 = 0,
    red_on,
    red_off,
    off1,
    grn_on,
    grn_off,
    off2,
    blu_on,
    blu_off,
    off3,
    done,
};
uint8_t colorstate = off0;
long colorUpdateTime = 0;

    // okay so we've got lastR,lastG,lastB
    // we want to flash them, one for N msecs, off for N msecs
    // but we don't want to block 
    // state red_on, red_off, off, grn_on, grn_off, off, 
    // state ticker happens every N-ish msecs
    if( millis() >= colorUpdateTime ) {
        colorUpdateTime += 250;
        if( colorstate == done ) {
            colorstate = off0;
        }
        
        if( colorstate == red_on ) {
            if( lastR>0 ) {
                Serial.println("red_on");
                BlinkM_fadeToRGB( 0, 0xff,0x22,0x22 );
            }
        }
        else if( colorstate == red_off ) {
            Serial.println("red_off");
            BlinkM_fadeToRGB( 0, 0x00,0x00,0x00 );
            if( --lastR > 0 ) colorstate = red_on;
        }
        else if( colorstate == grn_on ) {
            if( lastG>0 ) {
                Serial.println("grn_on");
                BlinkM_fadeToRGB( 0, 0x22,0xff,0x22 );
            }
        }
        else if( colorstate == grn_off ) {
            Serial.println("grn_off");
            BlinkM_fadeToRGB( 0, 0x00,0x00,0x00 );
            if( --lastG > 0 ) colorstate = grn_on;
        }
        else if( colorstate == blu_on ) {
            if( lastB>0 ) {
                Serial.println("blu_on");
                BlinkM_fadeToRGB( 0, 0x22,0x22,0xff );
            }
        }
        else if( colorstate == blu_off ) {
            Serial.println("blu_off");
            BlinkM_fadeToRGB( 0, 0x00,0x00,0x00 );
            if( --lastB > 0 ) colorstate = blu_on;
        }
        colorstate++;  // advance to next state

    }    
*/
