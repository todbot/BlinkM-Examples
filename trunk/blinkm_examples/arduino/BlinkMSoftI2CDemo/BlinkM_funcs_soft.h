/**
 * BlinkM_funcs_soft.h -- an extremely cut-down version of BlinkM_funcs.h 
 *                        for use with SoftI2CMaster library
 *                        
 *
 * 2010 Tod E. Kurt, http://todbot.com/blog/
 * 
 */

int errcnt;

static void BlinkM_begin() 
{
    // nothing to do here yet
}


static void BlinkM_beginWithPower(byte pwrpin, byte gndpin) 
{
    pinMode(pwrpin, OUTPUT);
    pinMode(gndpin, OUTPUT);
    digitalWrite(pwrpin, HIGH);
    digitalWrite(gndpin, LOW);
}


// -----------------------------------------------------------------------------
static void BlinkM_sendCmd3( uint8_t addr, uint8_t c, uint8_t a1, uint8_t a2, uint8_t a3 )
{
    if( i2c.beginTransmission( addr ) == 0 ) {
        ++errcnt;
        //Serial.println( errcnt);  // FIXME
    }    
    i2c.send( c );
    i2c.send( a1 );
    i2c.send( a2 );
    i2c.send( a3 );
    i2c.endTransmission();
}

static void BlinkM_sendCmd1( uint8_t addr, uint8_t c, uint8_t a1)
{
    if( i2c.beginTransmission( addr ) == 0 ) {
        ++errcnt;
        //Serial.println( errcnt); // FIXME
    }    
    i2c.send( c );
    i2c.send( a1 );
}

static void BlinkM_stopScript(uint8_t addr)
{
    i2c.beginTransmission( addr );
    i2c.send( 'o' );
    i2c.endTransmission();
}

static void BlinkM_setFadeSpeed( uint8_t addr, uint8_t f)
{
    BlinkM_sendCmd1( addr, 'f', f );
}

static void BlinkM_fadeToRGB( uint8_t addr, uint8_t r, uint8_t g, uint8_t b )
{
    BlinkM_sendCmd3( addr, 'c', r,g,b );
}

static void BlinkM_setRGB( uint8_t addr, uint8_t r, uint8_t g, uint8_t b )
{
    BlinkM_sendCmd3( addr, 'n', r,g,b );
}

static void BlinkM_off(uint8_t addr)
{
    BlinkM_stopScript( addr );
    BlinkM_setFadeSpeed(addr,10);
    BlinkM_setRGB(addr, 0,0,0 );
}

// Gets the BlinkM firmware version
static int BlinkM_getVersion(byte addr)
{
    i2c.beginTransmission( addr );
    i2c.send( 'Z' );
    i2c.endTransmission();

    i2c.requestFrom( addr );  
    uint8_t major_ver = i2c.receive();
    uint8_t minor_ver = i2c.receiveLast();
    i2c.endTransmission();
    return (major_ver<<8) + minor_ver;
}

static void BlinkM_getRGBColor(byte addr, byte* r, byte* g, byte* b)
{
    i2c.beginTransmission(addr);
    i2c.send('g');
    i2c.endTransmission();
    
    i2c.requestFrom( addr );
    *r = i2c.receive();
    *g = i2c.receive();
    *b = i2c.receiveLast();
    i2c.endTransmission();
}




