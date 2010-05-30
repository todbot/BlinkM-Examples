//
// BlinkMTinyToy.pde --  Play with a BlinkM in Processing, in a stripped down way
//
//  This is a stripped down example to communicate with a BlinkM in Processing.
//  For more complex examples, see BlinkMSequencer and BlinkMScriptTool.
//
//  This Processing sketch assumes it is communicating to a BlinkM 
//  via an Arduino "BlinkMCommunicator" sketch.
//   
//  2009, Tod E. Kurt, ThingM, http://thingm.com/
//
//

import processing.serial.*;

// Set the serial port to be the one your Arduino is connected to
// Find this in the Arduino "Tools -> Serial Port" menu
// This sketch will choose the first serial port if you don't set this
String portName = null;  // usually like "/dev/tty.usbserial..." or "COM3"
int portSpeed = 19200;
Serial port;

byte blinkmAddr = 0x09;  // the default I2C addr of a BlinkM

PFont font = createFont("Monospaced", 14); // all hail fixed width

int hue=0, bri=255;  // hue & brightness with arrow keys

// Processing's setup()
void setup() {
    size(320, 240); 
    frameRate(20);

    if( portName == null ) {
        portName = (Serial.list())[0]; // choose first port if none spec'd
    }
    println("BlinkMTinyToy: opening port "+portName);
    port = new Serial(this, portName, portSpeed);
    if( port.output == null ) {
        println("ERROR: Could not open serial port: "+portName);
        exit();
    }
}

/**
 * Send an I2C command to addr, via the BlinkMCommunicator Arduino sketch
 * Byte array must be correct length
 * For details on the format of the data to send to BlinkMCommunicator,
 * See to top of the BlinkMCommunicator sketch
 */
public synchronized void sendCommand( byte addr, byte[] cmd ) {
    println("sendCommand: "+(char)cmd[0]);
    byte cmdfull[] = new byte[4+cmd.length];
    cmdfull[0] = 0x01;                    // sync byte
    cmdfull[1] = addr;                    // i2c addr
    cmdfull[2] = (byte)cmd.length;        // this many bytes to send
    cmdfull[3] = 0x00;                    // this many bytes to receive
    for( int i=0; i<cmd.length; i++) {    // and actual command
        cmdfull[4+i] = cmd[i];
    }
    port.write(cmdfull);
}
// a common task, fade to an rgb color
public void fadeToColor( int r, int g, int b ) {
    byte[] cmd = {'c', (byte)r, (byte)g, (byte)b};
    sendCommand( blinkmAddr, cmd );
}

// Processing's draw()
void draw() {
    background( 180 );
    fill( 50 ); 
    textFont( font, 12 );
    text("Press keys to play with BlinkM:",10,20);
    text("'o'     - stop playing light script",10,40);
    text("'0'-'9' - play specified light script", 10,60);
    text("'r'     - turn BlinkM red",10,80);
    text("'g'     - turn BlinkM green",10,100);
    text("'b'     - turn BlinkM blue",10,120);
    text("'w'     - turn BlinkM white",10,140);
    text("arrows  - set hue/brightness",10,160);
    text("(Do 'o' first to stop startup script)", 10,210);

    if( keyPressed ) { 
        if( key == 'o' ) {                     // stop playing script
            byte[] cmd = { 'o' };
            sendCommand( blinkmAddr, cmd );
        }
        else if( key == 'r' ) {                // turn blinkm red
            fadeToColor( 0xff, 0x00, 0x00 );
        }
        else if( key == 'g' ) {                // turn blinkm green
            fadeToColor( 0x00, 0xff, 0x00 );
        }
        else if( key == 'b' ) {                // turn blinkm blue
            fadeToColor( 0x00, 0x00, 0xff );
        }
        else if( key == 'w' ) {                // turn blinkm white
            fadeToColor( 0xff, 0xff, 0xff );
        }
        else if( key >= '0' && key <= '9' ) {  // play script 0-9
            byte num = (byte)(key - '0');   // easy ascii-to-num conversion
            byte[] cmd = {'p', num, 0, 0 };
            sendCommand( blinkmAddr, cmd );
        }
        else if( key == CODED ) {   // deal with arrow keys
            if( keyCode == UP ) {
                bri++;
            } else if( keyCode == DOWN ) {
                bri--;
            }
            else if( keyCode == RIGHT ) {
                hue++;
            } 
            else if( keyCode == LEFT ) {
                hue--;
            }
            byte[] cmd = {'h', (byte)hue, (byte)255, (byte)bri };
            sendCommand( blinkmAddr, cmd );
            text("h,b: "+(hue&0xff)+","+(bri&0xff), 10,230);  //show hue/bri vals
        }
    }
}

