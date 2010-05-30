
BlinkM Example Code   
===================
-- 20081101 -- Tod E. Kurt, http://thingm.com/

This zip file "BlinkM_Examples.zip" available from http://blinkm.thingm.com 
contains several examples of how to talk with BlinkMs.  It will be updated 
periodically as new examples are created.  If you have an interesting example
you would like added to this example set, contact me.

Note: in general, the examples will reset the I2C address of the BlinkM 
      to 0x10.  If you don't want this behavior, comment out the 
      "BlinkM_setAddress()" line in setup() and change the variable 
      "blinkm_addr" to match your BlinkM's address.


Arduino Examples
----------------
- BlinkMCommunicator 
  - A simple serial-to-i2c gateway for PC controlling of BlinkM, 
    like via Processing or BlinkM Sequencer

- BlinkMTester
  - A general utility tool to play with a single BlinkM
    Also contains the official version of "BlinkM_funcs.h", 
    the Arduino BlinkM library.

- BlinkMMulti
  - A simple example showing how to communicate with multiple BlinkMs

- BlinkMScriptWriter
  - A demonstration of how to write BlinkM light scripts with Arduino

- BlinkMScriptWriter2
  - Another demonstration of how to write BlinkM light scripts with Arduino

- BlinkMChuck
  - Control the hue & brightness of a BlinkM with a Wii Nunchuck

- BlinkMCylon
  - Control a bus of 13 BlinkMs to make a multi-colored Cylon-like display

- BlinkMColorFader
  - Show how to control a BlinkM from Arduino with potentiometers

- BlinkMColorList
  - A sketch to write a light script with user-definable colors

Processing Examples
-------------------
- BlinkMSequencer
  - The drum machine-like application to program a BlinkM from Mac or Windows
    (needs BlinkMCommunicator installed on an Arduino connected to BlinkM)

- BlinkMScriptTool
  - A tool to let one more easily load/save and read/write BlinkM light scripts
    (needs BlinkMCommunicator installed on an Arduino connected to BlinkM)
    Also contains the official version of "BlinkMComm.pde", 
    the Processing BlinkM library.

Basic Stamp Examples
--------------------
- BlinkMTest.bs2  (in "other-examples/BasicStamp")


Max/MSP Examples
----------------
- Bleything.patch  (in "other-examples/MaxMSP")
  From Ben Bleything, see:
     http://blog.bleything.net/2008/3/23/controlling-a-blinkm-from-max-msp


Other
-----
- blinkm_nonvol_data.h
  - The contents of the BlinkM ROM light scripts



history
-------
- 20080120 - initial version
- 20080125 - included BlinkMChuck that was left out
- 20080203 - updated BlinkM_funcs.h & BlinkMChuck, improved BlinkMMulti
- 20080610 - fixed BlinkMScriptWriter, added BlinkMScriptWriter2
- 20080615 - added other-examples
- 20081101 - fixed BlinkM_funcs.h for Arduino-0012, added better light script
             support in BlinkM_funcs, updated BlinkMTester for MaxM,
             made BlinkMCommunicator faster, added BlinkMScriptTool, 
             added BlinkMColorList, other minor updates

             
