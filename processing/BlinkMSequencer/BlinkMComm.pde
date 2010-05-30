// Copyright (c) 2007-2008, ThingM Corporation

/**
 * BlinkMComm -- Simple Processing 'library' to talk to BlinkM 
 *               (via an Arduino programmed with BlinkMCommunicator)
 *
 *
 * Tod E. Kurt, ThingM, http://thingm.com/
 * 
 */

import processing.serial.*;

//import javax.swing.progressbar;

public class BlinkMComm {
  public final boolean fakeIt = false;

  boolean isConnected = false;

  public byte blinkm_addr = 0x09;
  public String portName = null;
  public final int portSpeed = 19200;

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
    String osname = System.getProperty("os.name");
    if( osname.toLowerCase().startsWith("windows") ) {
      // reverse list because Arduino is almost always highest COM port
      for(int i=0;i<a.length/2;i++){
        String t = a[i]; a[i] = a[a.length-(1+i)]; a[a.length-(1+i)] = t;
      }
      //for(int left=0, int right=list.length-1; left<right; left++, right--) {
      //  // exchange the first and last
      //  String tmp = list[left]; list[left] = list[right]; list[right] = tmp;
      //}
    }
    return a;
  }

  public BlinkMComm() {

  }

  /**
   * Connect to the given port
   * Can optionally take a PApplet (the sketch) to get serialEvents()
   * but this is not recommended
   *
   */
  public void connect( PApplet p, String portname ) throws Exception {
    l.debug("BlinkMComm.connect: portname:"+portname);
    try {
      if(port != null)
        port.stop(); 
      port = new Serial(p, portname, portSpeed);
      pause(100);
      
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
    // FIXME: add echo check
    return true;
  }

  public boolean isConnected() {
    return isConnected; // FIXME: this is kinda lame
  }

  // uses global var 'durations'
  public byte getDurTicks(int loopduration) {
    for( int i=0; i<durations.length; i++ ) {
      if( durations[i] == loopduration )
        return durTicks[i];
    }
    return durTicks[0]; // failsafe
  }
  // this is so lame
  public byte getFadeSpeed(int loopduration) {
    for( int i=0; i<durations.length; i++ ) {
      if( durations[i] == loopduration )
        return fadeSpeeds[i];
    }
    return fadeSpeeds[0]; // failsafe
  }

  /**
   * Burn a list of colors to a BlinkM
   * @param colorlist an ArrayList of the Colors to burn (java Color objs)
   * @param nullColor a color in the list that should be treated as nothing
   * @param duration  how long the entire list should last for, in seconds
   * @param loop      should the list be looped or not
   * @param progressbar if not-null, will update a progress bar
   */
  public void burn(ArrayList colorlist, Color nullColor, 
                   int duration, boolean loop, 
                   JProgressBar progressbar) {

    byte[] cmd = new byte[8];
    byte fadespeed = getFadeSpeed(duration);
    byte durticks = getDurTicks(duration);
    byte reps = (byte)((loop) ? 0 : 1);  // sigh, java

    Color c;

    l.debug("BlinkMComm.burn: durticks:"+durticks+" fadespeed:"+fadespeed);

    // build up the byte array to send
    Iterator iter = colorlist.iterator();
    int i=0;
    while( iter.hasNext() ) {
      l.debug("BlinkMComm.burn: writing script line "+i);
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
  public void prepareForPreview(int loopduration) {
    byte fadespeed = getFadeSpeed(loopduration);
    l.debug("BlinkmComm.prepareForPreview: fadespeed:"+fadespeed);
    byte[] cmdstop    = {'o'};
    byte[] cmdsetfade = {'f', fadespeed};
    if( isConnected() ) {
      sendCommand( blinkm_addr, cmdstop );
      pause(40);
      sendCommand( blinkm_addr, cmdsetfade );
      pause(40);
    }
  }

  // stops any playing script
  public void stopPlayingScript() {
    l.debug("BlinkmComm.stopPlayingScript");
    byte[] cmd = {'o'};
    if( isConnected() ) 
      sendCommand( blinkm_addr, cmd );
  }
  
  // plays a blinkm light script
  // note: doesn't check for connectedness first
  public void playScript(int script_id, int reps, int pos) {
    byte[] cmd = { 'p', (byte)script_id, (byte)reps, (byte)pos};
    sendCommand( blinkm_addr, cmd );
  }

  // plays the eeprom script (script id 0)
  public void playScript() {
    if( isConnected() ) {
      playScript(0,0,0);
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
    if( isConnected() ) 
      sendCommand( blinkm_addr, cmd );
    pause(10); // FIXME: hack
    lastColor = aColor;
  }

  /**
   * Send an I2C command to addr, via the BlinkMCommander Arduino sketch
   * Byte array must be correct length
   */
  public synchronized void sendCommand( byte addr, byte[] cmd ) {
    if( fakeIt ) return;        // just pretend
    l.debug("BlinkMComm.sendCommand(): "+(char)cmd[0]+", "+cmd.length);
    byte cmdfull[] = new byte[4+cmd.length];
    cmdfull[0] = 0x01;
    cmdfull[1] = addr;
    cmdfull[2] = (byte)cmd.length;
    cmdfull[3] = 0x00;
    for( int i=0; i<cmd.length; i++) {
      cmdfull[4+i] = cmd[i];
    }
    port.write(cmdfull);
    //port.flush();  // maybe?
  }

  /**
   * A simple delay
   */
  public void pause( int millis ) {
    try { Thread.sleep(millis); } catch(Exception e) { }
  }

}

