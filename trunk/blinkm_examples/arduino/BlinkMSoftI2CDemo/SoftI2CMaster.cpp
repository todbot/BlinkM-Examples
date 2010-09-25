/*
 * SoftI2CMaster.cpp -- Multi-instance software I2C Master library
 * 
 * 
 * 2010 Tod E. Kurt, http://todbot.com/blog/
 *
 * This code takes some tricksk from:
 *  http://codinglab.blogspot.com/2008/10/i2c-on-avr-using-bit-banging.html
 */

#include "WConstants.h"
#include "pins_arduino.h"
#include "SoftI2CMaster.h"

#include <avr/delay.h>
#include <string.h>

#define  i2cbitdelay 50

#define i2c_sda_hi()                            \
    *_sdaPortModeRegister &=~ _sdaBitMask;      \
    *_sdaPortRegister     |=  _sdaBitMask;  

#define i2c_sda_lo()                            \
    *_sdaPortRegister     &=~ _sdaBitMask;      \
    *_sdaPortModeRegister |=  _sdaBitMask;  

#define i2c_scl_hi()                            \
    *_sclPortModeRegister &=~ _sclBitMask;      \
    *_sclPortRegister     |=  _sclBitMask; 

#define i2c_scl_lo()                            \
    *_sclPortRegister     &=~ _sclBitMask;      \
    *_sclPortModeRegister |=  _sclBitMask; 


//
// Constructor
//
SoftI2CMaster::SoftI2CMaster(uint8_t sdaPin, uint8_t sclPin) 
{
  setPins(sdaPin, sclPin);

  i2c_init();

}

//
// Turn Arduino pin numbers into PORTx, DDRx, and PINx
//
void SoftI2CMaster::setPins(uint8_t sdaPin, uint8_t sclPin)
{
  uint8_t port;

  _sdaPin = sdaPin;
  _sclPin = sclPin;

  _sdaBitMask = digitalPinToBitMask(sdaPin);
  _sclBitMask = digitalPinToBitMask(sclPin);

  port = digitalPinToPort(sdaPin);
  _sdaPortRegister     = portOutputRegister(port);
  _sdaPortModeRegister = portModeRegister(port);

  port = digitalPinToPort(sclPin);
  _sclPortRegister     = portOutputRegister(port);
  _sclPortModeRegister = portModeRegister(port);

}

//
//
//
uint8_t SoftI2CMaster::beginTransmission(uint8_t address)
{
  i2c_start();
  uint8_t rc = i2c_write((address<<1));
  return rc;
}

//
uint8_t SoftI2CMaster::beginTransmission(int address)
{
  return beginTransmission((uint8_t)address);
}

//
//
//
uint8_t SoftI2CMaster::endTransmission(void)
{
  i2c_stop();
  //return ret;  // FIXME
}

// must be called in:
// slave tx event callback
// or after beginTransmission(address)
uint8_t SoftI2CMaster::send(uint8_t data)
{
  return i2c_write(data);
}

// must be called in:
// slave tx event callback
// or after beginTransmission(address)
void SoftI2CMaster::send(uint8_t* data, uint8_t quantity)
{
  for(uint8_t i = 0; i < quantity; ++i){
    send(data[i]);
  }
}

// must be called in:
// slave tx event callback
// or after beginTransmission(address)
void SoftI2CMaster::send(char* data)
{
  send((uint8_t*)data, strlen(data));
}

// must be called in:
// slave tx event callback
// or after beginTransmission(address)
void SoftI2CMaster::send(int data)
{
  send((uint8_t)data);
}

//--------------------------------------------------------------------


void SoftI2CMaster::i2c_writebit( uint8_t c )
{
    if ( c > 0 ) {
        i2c_sda_hi();
    } else {
        i2c_sda_lo();
    }

    i2c_scl_hi();
    _delay_us(i2cbitdelay);

    i2c_scl_lo();
    _delay_us(i2cbitdelay);

    if ( c > 0 ) {
        i2c_sda_lo();
    }
    _delay_us(i2cbitdelay);
}

//
uint8_t SoftI2CMaster::i2c_readbit(void)
{
    i2c_sda_hi();
    i2c_scl_hi();
    _delay_us(i2cbitdelay);

    uint8_t port = digitalPinToPort(_sclPin);
    volatile uint8_t* pinReg = portInputRegister(port);
    uint8_t c = *pinReg;  // I2C_PIN;

    i2c_scl_lo();
    _delay_us(i2cbitdelay);

    //return ( c >> I2C_SCL ) & 1;
    return ( c & _sclBitMask) ? 1 : 0;
}

// Inits bitbanging port, must be called before using the functions below
//
void SoftI2CMaster::i2c_init(void)
{
    //I2C_PORT &=~ (_BV( I2C_SDA ) | _BV( I2C_SCL ));
    *_sclPortRegister &=~ (_sdaBitMask | _sclBitMask);
    
    i2c_scl_hi();
    i2c_sda_hi();

    _delay_us(i2cbitdelay);
}

// Send a START Condition
//
void SoftI2CMaster::i2c_start(void)
{
    // set both to high at the same time
    //I2C_DDR &=~ (_BV( I2C_SDA ) | _BV( I2C_SCL ));
    *_sclPortModeRegister &=~ (_sdaBitMask | _sclBitMask);

    _delay_us(i2cbitdelay);
   
    i2c_sda_lo();
    _delay_us(i2cbitdelay);

    i2c_scl_lo();
    _delay_us(i2cbitdelay);
}

// Send a STOP Condition
//
void SoftI2CMaster::i2c_stop(void)
{
    i2c_scl_hi();
    _delay_us(i2cbitdelay);

    i2c_sda_hi();
    _delay_us(i2cbitdelay);
}

// write a byte to the I2C slave device
//
uint8_t SoftI2CMaster::i2c_write( uint8_t c )
{
    for ( uint8_t i=0;i<8;i++)
    {
        i2c_writebit( c & 128 );
   
        c<<=1;
    }

    return i2c_readbit();
}

// read a byte from the I2C slave device
//
uint8_t SoftI2CMaster::i2c_read( uint8_t ack )
{
    uint8_t res = 0;

    for ( uint8_t i=0;i<8;i++)
    {
        res <<= 1;
        res |= i2c_readbit();  
    }

    if ( ack > 0)
        i2c_writebit( 0 );
    else
        i2c_writebit( 1 );

    _delay_us(i2cbitdelay);

    return res;
}
