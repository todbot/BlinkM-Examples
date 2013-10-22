// Copyright (c) 2007-2008, ThingM Corporation

/**
 * BlinkMComm -- Simple Processing 'library' to talk to BlinkM 
 *               (via an Arduino programmed with BlinkMCommunicator)
 *
 * This is almost 100% Java with few Processing dependencies, 
 * so with a bit of work can be usable in other Java environments
 *
 * 2007-2008, Tod E. Kurt, ThingM, http://thingm.com/
 * 
 *
 * NOTE: you should NOT have a "serialEvent()" method in your sketch,
 *       else the BlinkM reading functions will not work.  For debugging
 *       a "serialEvent()" method is useful, but be sure to comment it out
 *       if you want to read anything back from a BlinkM.
 */

import processing.serial.*;
import javax.swing.*;  // for connect dialog

public class BlinkMComm {
  public final boolean debug = true;
  public final boolean fakeIt = false;

  boolean isConnected = false;

  public byte blinkm_addr = 0x09;
  public String portName = null;
  public final int portSpeed = 19200;

  PApplet papplet; // our owner, owns the GUI window
  Serial port;
  
  // mapping of duration to ticks      (must be same length as 'durations')
  public byte[] durTicks   = { (byte)   1, (byte) 18, (byte) 72 };
  // mapping of duration to fadespeeds (must be same length as 'durations')
  public byte[] fadeSpeeds = { (byte) 100, (byte) 25, (byte)  5 };
    
  Color cBlk = new Color(0,0,0);
  Color lastColor;

  // Return a list of potential ports
  // they should be ordered by best to worst (but are not right now)
  // this can't be static as a .pde, sigh.
  public String[] listPorts() {
      String[] a = Serial.list();
      if( a.length == 0 ) a = new String[]{"-no serial ports-"};
      String osname = System.getProperty("os.name");
      if( osname.toLowerCase().startsWith("windows") && a.length > 1 ) {
          debug("here");
          // reverse list because Arduino is almost always highest COM port
          for(int i=0;i<a.length/2;i++) {
              String t = a[i]; a[i] = a[a.length-(1+i)]; a[a.length-(1+i)] = t;
          }
      }
      return a;
  }

  public BlinkMComm(PApplet p) {
    papplet = p;
  }

  /**
   * Connect to the given port
   * Can optionally take a PApplet (the sketch) to get serialEvents()
   * but this is not recommended
   *
   */
  public void connect( String portname ) throws Exception {
      debug("BlinkMComm.connect: portname:"+portname);
      try {
          if(port != null)
              port.stop(); 
          port = new Serial(papplet, portname, portSpeed); // FIXME: callback 
          pause(500);  // wait for serial port to open

          // FIXME: check address, set it if needed

          isConnected = true;
          portName = portname;
      }
      catch (Exception e) {
          isConnected = false;
          portName = null;
          port = null;
          throw e;
      }
  }

  // disconnect but remember the name
  public void disconnect() {
      if( port!=null )
          port.stop();
      isConnected = false;
  }

  // verifies connection is good
  public boolean checkConnection() {
      return true;        // FIXME: add echo check
  }

  public boolean isConnected() {
      return isConnected; // FIXME: this is kinda lame
  }

  // uses global var 'durations'
  public byte getDurTicks(int[] durations, int loopduration) {
    for( int i=0; i<durations.length; i++ ) {
      if( durations[i] == loopduration )
        return durTicks[i];
    }
    return durTicks[0]; // failsafe
  }
  // this is so lame
  public byte getFadeSpeed(int[] durations, int loopduration) {
      for( int i=0; i<durations.length; i++ ) {
          if( durations[i] == loopduration )
              return fadeSpeeds[i];
      }
      return fadeSpeeds[0]; // failsafe
  }


  /**
   * Send an I2C command to addr, via the BlinkMCommunicator Arduino sketch
   * Byte array must be correct length
   */
  public synchronized void sendCommand( byte addr, byte[] cmd ) {
      if( fakeIt ) return;        // just pretend
      if( !isConnected ) return;
      debug("BlinkMComm.sendCommand(): "+(char)cmd[0]+", "+cmd.length);
      byte cmdfull[] = new byte[4+cmd.length];
      cmdfull[0] = 0x01;                    // sync byte
      cmdfull[1] = addr;                    // i2c addr
      cmdfull[2] = (byte)cmd.length;        // this many bytes to send
      cmdfull[3] = 0x00;                    // this many bytes to receive
      for( int i=0; i<cmd.length; i++) {    // actual command
          cmdfull[4+i] = cmd[i];
      }
      port.write(cmdfull);
      //port.clear();  // just in case
      //port.flush();  // maybe?
  }

  /**
   * Send an I2C command to addr, via the BlinkMCommunicator Arduino sketch
   * Byte array must be correct length
   * returns response (if any) 
   */
  public synchronized byte[] sendCommand( byte addr, byte[] cmd, int respcnt ) {
      if( fakeIt ) return null;        // just pretend
      if( !isConnected ) return null;
      debug("BlinkMComm.sendCommand(): "+(char)cmd[0]+", "+cmd.length);
      byte cmdfull[] = new byte[4+cmd.length];
      cmdfull[0] = 0x01;                    // sync byte
      cmdfull[1] = addr;                    // i2c addr
      cmdfull[2] = (byte)cmd.length;        // this many bytes to send
      cmdfull[3] = (byte)respcnt;           // this many bytes to receive
      for( int i=0; i<cmd.length; i++) {    // actual command
          cmdfull[4+i] = cmd[i];
      }
      port.clear(); // just in case
      port.write(cmdfull);
      pause(10);    // wait for 

      // this bit needs to be cleaned up
      if( respcnt > 0 ) {
          byte[] resp = new byte[respcnt];
          int j = 200;  // time in millis to wait 
          while( port.available() < respcnt ) {
              pause(1); 
              if( j-- == 0 ) { 
                  debug("sendCommand couldn't receive");
                  return null; 
              }
          }
          for( int i=0; i<respcnt; i++ ) 
              resp[i] = (byte)port.read();
          return resp;
      }
      return null;
  }

  /**
   *
   */
  public void writeScriptLine( int pos, BlinkMScriptLine line ) {
      // build up the byte array to send
      debug("BlinkMComm.writeScriptLine: pos:"+pos+" scriptline: "+line);
      byte[] cmd = new byte[8];    // 
      cmd[0] = (byte)'W';          // "Write Script Line" command
      cmd[1] = (byte)0;            // script id (0==eeprom)
      cmd[2] = (byte)pos;          // script line number
      cmd[3] = (byte)line.dur;     // duration in ticks
      cmd[4] = (byte)line.cmd;     // command
      cmd[5] = (byte)line.arg1;    // cmd arg1
      cmd[6] = (byte)line.arg2;    // cmd arg2
      cmd[7] = (byte)line.arg3;    // cmd arg3
      sendCommand( blinkm_addr, cmd );
      pause(20); // must have at least 4.5msec delay between EEPROM writes
    }

  //
  public BlinkMScriptLine readScriptLine(int script_id, int pos ) {
      debug("BlinkMComm.readScriptLine: pos:"+pos);
      //BlinkMScriptLine line = new BlinkMScriptLine();
      byte[] cmd = new byte[3];
      cmd[0] = (byte)'R';           // "Read Script Line" command
      cmd[1] = (byte)script_id;     // script id (0==eeprom)
      cmd[2] = (byte)pos;           // script line number
      byte[] resp = sendCommand( blinkm_addr, cmd, 5 ); // 5 bytes in response
      BlinkMScriptLine line = new BlinkMScriptLine();
      if( !line.fromByteArray(resp) ) return null;
      return line;  // we're bad
  }

  // set the length & repeats for a given script_id (always 0 for now)
  public void setScriptLengthRepeats(int script_id, int len, int reps) {
      //   set script length  cmd          id        length        reps
      byte[] cmdsetlength = { 'L', (byte)script_id, (byte)len, (byte)reps };
    sendCommand( blinkm_addr, cmdsetlength );
    pause(20);
  }

  // play a light script
  public void playScript(int script_id, int reps, int pos) {
      byte[] cmd = { 'p', (byte)script_id, (byte)reps, (byte)pos};
      sendCommand( blinkm_addr, cmd );
  }
  // plays the eeprom script (script id 0) from start, forever
  public void playScript() {
      playScript(0,0,0);
  }
  
  // stops any playing script
  public void stopScript() {
      debug("BlinkmComm.stopPlayingScript");
      byte[] cmd = {'o'};
      sendCommand( blinkm_addr, cmd );
  }

  // set boot params   cmd,mode,id,reps,fadespeed,timeadj
  public void setStartupParams( int mode, int script_id, int reps, 
                                int fadespeed, int timeadj ) {
      byte cmdsetboot[] = { 'B', 1, (byte)script_id, (byte)reps, 
                            (byte)fadespeed, (byte)timeadj };
      sendCommand( blinkm_addr, cmdsetboot );
      pause(20);
  }
  // default values for startup params
  public void setStartupParamsDefault() {
      setStartupParams( 1, 0, 0, 0x08, 0 );
  }
  
  // read the 4 8-bit analog inputs on a MaxM
  public byte[] readInputs() {
      debug("BlinkMComm.readInputs");
      byte[] cmd = new byte[1];
      cmd[0] = (byte)'i';           // "Read Inputs" command
      byte[] resp = sendCommand( blinkm_addr, cmd, 4 ); // 4 bytes in response
      return resp;
  }


  // ------------ old stuff for BlinkMSequencer -------------

  /**
   * Burn a list of colors to a BlinkM
   * @param colorlist an ArrayList of the Colors to burn (java Color objs)
   * @param nullColor a color in the list that should be treated as nothing
   * @param duration  how long the entire list should last for, in seconds
   * @param loop      should the list be looped or not
   * @param progressbar if not-null, will update a progress bar
   */
  public void burnColorList(ArrayList colorlist, Color nullColor, 
                            int[] durations, int duration, boolean loop, 
                            javax.swing.JProgressBar progressbar) {

    byte[] cmd = new byte[8];
    byte fadespeed = getFadeSpeed(durations, duration);
    byte durticks = getDurTicks(durations, duration);
    byte reps = (byte)((loop) ? 0 : 1);  // sigh, java

    Color c;

    debug("BlinkMComm.burn: durticks:"+durticks+" fadespeed:"+fadespeed);

    // build up the byte array to send
    Iterator iter = colorlist.iterator();
    int i=0;
    while( iter.hasNext() ) {
      debug("BlinkMComm.burn: writing script line "+i);
      c = (Color) iter.next();
      if( c == nullColor )
        c = cBlk;
      cmd[0] = (byte)'W';          // "Write Script Line" command
      cmd[1] = (byte)0;            // script id (0==eeprom)
      cmd[2] = (byte)i;            // script line number
      cmd[3] = (byte)durticks;     // duration in ticks
      cmd[4] = (byte)'c';          // fade to rgb color command
      cmd[5] = (byte)c.getRed();   // cmd arg1
      cmd[6] = (byte)c.getGreen(); // cmd arg2
      cmd[7] = (byte)c.getBlue();  // cmd arg3
      sendCommand( blinkm_addr, cmd );
      if( progressbar !=null) progressbar.setValue(i);  // hack
      i++;
      pause(50);
    }
    // set script length   cmd   id         length         reps
    byte[] cmdsetlength = { 'L', 0, (byte)colorlist.size(), reps };
    sendCommand( blinkm_addr, cmdsetlength );
    pause(50);

    // set boot params   cmd,mode,id,reps,fadespeed,timeadj
    byte cmdsetboot[] = { 'B', 1, 0, 0, fadespeed, reps };
    sendCommand( blinkm_addr, cmdsetboot );
    pause(50);

    // set fade speed
    byte[] cmdsetfade = { 'f', fadespeed };
    sendCommand( blinkm_addr, cmdsetfade );
    pause(30);

    // and cause the script to be played 
    //                 cmd,id,reps,pos
    byte[] cmdplay = { 'p', 0, reps, 0 };
    sendCommand( blinkm_addr, cmdplay );
    pause(30);
  }

  // prepare blinkm for playing preview scripts
  public void prepareForPreview(int[] durations, int loopduration) {
      byte fadespeed = getFadeSpeed(durations, loopduration);
      debug("BlinkmComm.prepareForPreview: fadespeed:"+fadespeed);
      byte[] cmdstop    = {'o'};
      byte[] cmdsetfade = {'f', fadespeed};
      if( isConnected() ) {
          sendCommand( blinkm_addr, cmdstop );
          pause(40);
          sendCommand( blinkm_addr, cmdsetfade );
          pause(40);
      }
  }
  
  /**
   *
   */
  public void sendColor( Color aColor, Color nullColor, int duration ) {
      if( aColor.equals( lastColor ) )   // don't clog the pipes!
          return;
      
      Color c = (aColor == nullColor) ? cBlk : aColor;
      byte[] cmd={'c',(byte)c.getRed(),(byte)c.getGreen(),(byte)c.getBlue()};
      sendCommand( blinkm_addr, cmd );
      pause(10); // FIXME: hack
      lastColor = aColor;
  }
  
  // ---------------------------

  //
  // open up a dialog box to select the serial port
  //
  public boolean doConnectDialog() {
      String[] ports = listPorts();
      //String buttons[] = {"Connect", "Cancel"};
      String s = (String)
          JOptionPane.showInputDialog( null,
                                       "Select a serial port:\n",
                                       "Connect to BlinkMCommunicator",
                                       JOptionPane.PLAIN_MESSAGE,
                                       null,
                                       ports,
                                       ports[0]
                                      );
    // if a string was returned, try to connect.
    if ((s != null) && (s.length() > 0)) {
        disconnect(); // just in case
        try { 
            connect( s );
        } catch( Exception e ) {
            JOptionPane.showMessageDialog( null,
                                          "Could not connect\n"+e,
                                          "Connect error",
                                          JOptionPane.ERROR_MESSAGE);
            return false;
        }
        return true;
    }
    
    // otherwise, we failed
    return false;
  }




  // ---------------------

  /**
   * A simple delay
   */
  public void pause( int millis ) {
      try { Thread.sleep(millis); } catch(Exception e) { }
  }

  public void debug( String s ) {
      if(debug) println(s);
  }
  
}




// Java data struct representation of a BlinkM script line
// also includes string rendering
public class BlinkMScriptLine {
    int dur;
    char cmd;
    int  arg1,arg2,arg3;
    String comment;

    public BlinkMScriptLine() {
    }
    public BlinkMScriptLine( int d, char c, int a1, int a2, int a3 ) {
        dur = d;
        cmd = c;
        arg1 = a1; 
        arg2 = a2;
        arg3 = a3;
    }

    // "construct" from a byte array.  could also do other error checking here
    public boolean fromByteArray(byte[] ba) {
        if( ba==null || ba.length != 5 ) return false;
        dur  = ba[0] & 0xff;
        cmd  = (char)(ba[1] & 0xff);
        arg1 = ba[2] & 0xff;
        arg2 = ba[3] & 0xff;
        arg3 = ba[4] & 0xff;  // because byte is stupidly signed
        return true;
    }

    public void addComment(String s) {
        comment = s;
    }

    public String toStringSimple() {
        return "{"+dur+", {'"+cmd+"',"+arg1+","+arg2+","+arg3+"}},";
    }
    public String toFormattedString() {
        return toString();
    }
    // this seems pretty inefficient with all the string cats
    public String toString() {
        String s="{"+dur+", {'"+cmd+"',";
        if( cmd=='n'||cmd=='c'||cmd=='C'||cmd=='h'||cmd=='H' ) {
            s += makeGoodHexString(arg1) +","+
                makeGoodHexString(arg2) +","+
                makeGoodHexString(arg3) +"}},";
        }
        else 
            s += arg1+","+arg2+","+arg3+"}},";
        if( comment!=null ) s += "\t// "+comment;
        return s;
    }
    // convert a byte properly to a hex string
    // why does Java number formatting still suck?
    public String makeGoodHexString(int b) {
        String s = Integer.toHexString(b);
        if( s.length() == 1 ) 
            return "0x0"+s;
        return "0x"+s;
    }


}

