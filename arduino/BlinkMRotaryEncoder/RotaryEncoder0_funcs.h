// RotaryEncoder_funcs.h -- simple set of functions to support a single encoder
//
//  Note: depends on the following being defined:
//        encoder0APin  (must be pin 2)
//        encoder0BPin  (can be any pin)
//

volatile int encoder0Pos = 0;

//
static void RotaryEncoder0_func()
{
  /* If pinA and pinB are both high or both low, it is spinning
   * forward. If they're different, it's going backward.
   *
   * For more information on speeding up this process, see
   * [Reference/PortManipulation], specifically the PIND register.
   */
  if (digitalRead(encoder0APin) == digitalRead(encoder0BPin)) {
    encoder0Pos++;
  } else {
    encoder0Pos--;
  }
  //Serial.println(encoder0Pos, DEC);
}

//
static void RotaryEncoder0_begin()
{
  pinMode(encoder0APin, INPUT); 
  digitalWrite(encoder0APin, HIGH);       // turn on pullup resistor
  pinMode(encoder0BPin, INPUT); 
  digitalWrite(encoder0BPin, HIGH);       // turn on pullup resistor

  //Interrupt 0 is digital pin 2
  attachInterrupt(0, RotaryEncoder0_func, CHANGE);
}

//
static int RotaryEncoder0_pos() 
{
    return encoder0Pos;
}

