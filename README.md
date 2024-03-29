
BlinkM Example Code   
===================
-- 20111201 -- Tod E. Kurt, http://thingm.com/

![BlinkM Familyt](docs/blinkm_imgs.jpg)

The repo is the contents of the file "blinkm_examples.zip" available from
https://github.com/todbot/BlinkM-Examples and
http://blinkm.thingm.com

It contains several examples of how to talk with BlinkMs.  It will be updated 
periodically as new examples are created.  If you have an interesting example
you would like added to this example set, contact us!



Arduino Examples
----------------

**Note: A more up-to-date and useful BlinkM Arduino library that includes these examples is available at https://github.com/todbot/BlinkM-Arduino**

- BlinkMCommunicator 
  - A simple serial-to-i2c gateway for PC controlling of BlinkM,
    like via Processing or BlinkMSequencer

- BlinkMTester
  - A general utility tool to play with a single BlinkM via Serial Monitor.
    Also contains the official version of "BlinkM_funcs.h", 
    the Arduino BlinkM library.

- BlinkMFactoryReset
  - Restore the BlinkM's startup behavior to default

- BlinkMSetStartupScript
  - Change what startup script the BlinkM will play

- BlinkMSensor0
  - Control one parameter of a BlinkM with a single sensor

- BlinkMColorFader
  - Show how to control a BlinkM from Arduino with potentiometers

- BlinkMColorList
  - Write a startup light script with user-definable colors

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

- WiFiBlinkM
  - Control a BlinkM using a YellowJacket or WiShield WiFi module

- TweetM
  - The code and design docs for <a href="http://tweetm.thingm.com/">TweetM</a> gadget
    as seen on <a href="http://www.colbertnation.com/the-colbert-report-videos/311944/june-08-2010/mark-frauenfelder">The Colbert Report</a> live here.



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

- docs/blinkm_nonvol_data.h
  - The contents of the BlinkM ROM light scripts



             
