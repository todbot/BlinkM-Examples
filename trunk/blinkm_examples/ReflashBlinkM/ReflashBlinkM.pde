/**
 * ReflashBlinkM  -- Reflash a BlinkM using ArduinoISP sketch on Arduino
 * -------------
 *
 * Steps to build application:
 *  1. "Export Application" from within Processing
 *  2. Run "./package-after-export.sh" on command-line
 *
 *
 * 2010, Tod E. Kurt, http://thingm.com/
 *
 * 
 * Avrdude commands for BlinkM when using Arduino w/ "ArduinoISP" sketch:
 * 1. avrdude -p attiny45 -b 19200 -c stk500v1 -P /dev/tty.usbserial-A6008hXg \
 *  -U flash:w:/Users/tod/projects/projects_todbot/blinkm/blinkmv1/blinkmv1.hex
 * 2. avrdude -p attiny45 -b 19200 -c stk500v1 -P /dev/tty.usbserial-A6008hXg \
 *  -U eeprom:w:/Users/tod/projects/projects_todbot/blinkm/blinkmv1/blinkmv1.eep
 * 3. avrdude  -p attiny45 -b 19200 -c stk500v1 -P /dev/tty.usbserial-A6008hXg \
 *  -U lfuse:w:0xDD:m
 *
 * and that can all be one command.
 *
 * Avrdude commands for BlinkM when using AVR-ISP:
 * 1. avrdude -p attiny45 -P usb -c avrispmkii -U flash:w:...
 *
 *
 *
 */

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.border.*;      // for silly borders on buttons
import javax.swing.plaf.metal.*;
import java.util.*;

import processing.serial.*;

boolean debug = true;


public static class Firmware  {
  public String name;    // name of firmware
  public String mcu;     //
  public String hex;     // filename of firmware hex 
  public String eep;     // filename of EEPROM 
  public String lfuse;   // fuse settings
  public String hfuse;   // fuse settings
  public String efuse;   // fuse settings
  public Firmware(String n, String m, String h, String e, 
                  String lf, String hf, String ef) {
    name = n; mcu = m; hex = h; eep = e; lfuse = lf; hfuse = hf; efuse = ef;
  }
}

static Firmware firmwareCustom85 = 
  new Firmware( "Custom ATtiny85 firmware...",
                "attiny85",
                "",
                "",
                "0xE2",
                "0xDD",
                "0xFE"
                );
static Firmware firmwareCustom45 = 
  new Firmware( "Custom ATtiny45 firmware...",
                "attiny45",
                "",
                "",
                "0xE2",
                "0xDD",
                "0xFE"
                );

static Firmware firmwareCustom84 = 
  new Firmware( "Custom ATtiny84 firmware...",
                "attiny84",
                "",
                "",
                "0xE2",
                "0xDD",
                "0xFE"
                );

// the supported track durations
public static Firmware[] firmwares = new Firmware [] {
  new Firmware( "BlinkM new (ATtiny85)", 
                "attiny85", 
                "blinkm_attiny85.hex", 
                "blinkm_attiny85.eep",
                "0xE2",
                "0xDD",
                "0xFE"
                ),
  new Firmware( "BlinkM MinM (ATtiny85)", 
                "attiny85", 
                "blinkm_attiny85.hex", 
                "blinkm_attiny85.eep", 
                "0xE2",
                "0xDD",
                "0xFE"
                ),
  new Firmware( "BlinkM MaxM new (ATtiny 84)",
                "attiny84", 
                "blinkm_maxm_attiny84.hex",
                "blinkm_maxm_attiny84.eep",
                "0xE2",
                "0xDD",
                "0xFE"
                ),
  new Firmware( "BlinkM orig (ATtiny45)", 
                "attiny45",
                "blinkmv1.hex",
                "blinkmv1.eep",
                "0xE2",
                "0xDD",
                "0xFE"
                ),
  new Firmware( "BlinkM MaxM orig (ATtiny44)",
                "attiny44", 
                "blinkmv2.hex",
                "blinkmv2.eep",
                "0xE2",
                "0xDD",
                "0xFE"
                ),
  firmwareCustom85,
  firmwareCustom45,
  firmwareCustom84,
};

Firmware fw = firmwares[0];
String portName;
String ispType;     // can be: "avrispmkii", "usbtiny", "arduinoisp"
boolean customFw;   // is this a standard firmware, or a custom one?

JFileChooser fc;
JLabel firmFileStr;
JRadioButton ispButtonAvrIspMkII;
JRadioButton ispButtonUsbTiny;
JRadioButton ispButtonArduinoIsp;

ReflashDialog reflashDialog;

// Processing's setup()
void setup() {
}

// Procesing's draw()
void draw() {
  //
  if( frameCount==1  ) {
    super.frame.setVisible(false);  // turn off Processing's frame
    super.frame.toBack();

    javax.swing.SwingUtilities.invokeLater(new Runnable() {
        public void run() {
          try{ Thread.sleep(500); } catch(Exception e){} // wait to avoid assert
          reflashDialog = new ReflashDialog();
        }
      } );
  }

}


// 
// Runs a thread separate from the Swing GUI or Processing's draw()
//
class Programmer implements Runnable {

  public void run() {
    reflashBlinkM();
  }

  //
  //
  //
  String runAvrdudeCmd( String[] cmd  ) {
    String rc = "";

    String s = "";
    for( int i=0; i< cmd.length;i++)
      s += cmd[i]+" ";
    println("avrdude cmd:\n"+s);// always print out avrdude command to console
    
    try { 
      Process process=new ProcessBuilder(cmd).redirectErrorStream(true).start();
      InputStream is = process.getInputStream();
      BufferedReader br = new BufferedReader(new InputStreamReader(is));
      
      //System.out.printf("Output of running %s is:", Arrays.toString(cmd));
      
      String line;
      while ((line = br.readLine()) != null) {
        rc += line;
        if( line.indexOf("writing flash") != -1 ) {
          reflashDialog.updateMsg("Writing flash...");
        } else if( line.indexOf("reading on-chip flash") != -1 ) { 
          reflashDialog.updateMsg("Verifying flash...");
        } else if( line.indexOf("writing eeprom") != -1 ) { 
          reflashDialog.updateMsg("Writing eeprom...");
        } else if( line.indexOf("reading on-chip eeprom") != -1 ) {
          reflashDialog.updateMsg("Verifying eeprom...");
        } else if( line.indexOf("writing lfuse") != -1 ) {
          reflashDialog.updateMsg("Writing lfuse...");
        } else if( line.indexOf("verifying lfuse") != -1 ) {
          reflashDialog.updateMsg("Verifying lfuse...");
        } else if( line.indexOf("writing hfuse") != -1 ) {
          reflashDialog.updateMsg("Writing hfuse...");
        } else if( line.indexOf("verifying hfuse") != -1 ) {
          reflashDialog.updateMsg("Verifying hfuse...");
        } else if( line.indexOf("writing efuse") != -1 ) {
          reflashDialog.updateMsg("Writing efuse...");
        } else if( line.indexOf("verifying efuse") != -1 ) {
          reflashDialog.updateMsg("Verifying efuse...");
        }
        if( debug ) println(":"+line);

      }
    } catch( IOException ioe ) { 
      ioe.printStackTrace();
    }
    
    return rc;
  }


  //
  // This is run outside the normal Swing GUI thread
  //
  void reflashBlinkM() {
    String firmName = fw.name;
    reflashDialog.setReflashing(true);
    reflashDialog.updateMsg("Reflashing '"+firmName+"' on "+portName+"...");
    
    String cmdpath = sketchPath;
    String binpath = "";
    String confpath = "";
    String sep = File.separator;

    if( platform == MACOSX ) { 
      cmdpath += "/ReflashBlinkM.app/Contents/Resources/Java/tools";
      File f = new File(cmdpath);
      if( !f.exists() ) {              // in a sketch, not an exported app
        cmdpath = sketchPath + "/tools";
      }
      binpath = cmdpath + "/bin-macosx/avrdude";
    }
    else if( platform == WINDOWS ) {
      cmdpath += "\\tools";  // FIXME: verify this
      binpath = cmdpath + "\\bin-windows\\avrdude.exe";
    }
    
    confpath = cmdpath + sep + "etc" + sep + "avrdude.conf";
    
    // build up command string
    ArrayList<String> cmd = new ArrayList<String>();
    cmd.add( binpath );
    cmd.add("-C");  cmd.add(confpath);
    cmd.add("-p");  cmd.add(fw.mcu);

    String hexpath = fw.hex;
    String eeppath = fw.eep;
    if( !customFw ) {
      hexpath = cmdpath +sep+ "firmwares" +sep+ hexpath;
      eeppath = cmdpath +sep+ "firmwares" +sep+ eeppath;
    }

    cmd.add("-U");  cmd.add("flash:w:"+hexpath+":i");
    if( fw.eep != null && !fw.eep.equals("") ) {
      cmd.add("-U");  cmd.add("eeprom:w:"+eeppath+":i");
    }

    cmd.add("-U");  cmd.add("lfuse:w:"+fw.lfuse+":m");
    cmd.add("-U");  cmd.add("hfuse:w:"+fw.hfuse+":m");

    if( ispType.equals("arduinoisp")  ) {
      cmd.add("-c");  cmd.add("stk500v1");
      cmd.add("-b");  cmd.add("19200");
      cmd.add("-P");  cmd.add(portName);
    }
    else if( ispType.equals("avrispmkii") ) {
      cmd.add("-c");  cmd.add("avrispmkii");
      cmd.add("-P");  cmd.add("usb");
    }
    else if( ispType.equals("usbtiny") ) {
      cmd.add("-c");  cmd.add("usbtiny");
    }

    // run the actual avrdude command
    String output = runAvrdudeCmd( cmd.toArray(new String[0]) );
    
    if( output.indexOf("can't open device") != -1 ) {
      reflashDialog.updateMsg("Can't open serial device, try another.");
    }
    else if( output.indexOf("Device is not responding") != -1 ) {
      reflashDialog.updateMsg("Programmer not responding. Check connections.");
    }
    else if( output.indexOf("programmer is not responding") != -1 ) {
      reflashDialog.updateMsg("Programmer not responding.");
    }
    else if( output.indexOf("Expected signature") != -1 ) { 
      reflashDialog.updateMsg("Wrong chip type detected. Use other firmware.");
    }
    else if( output.indexOf("verification error") != -1 ) {
      reflashDialog.updateMsg("Verification error, bad wiring?");
    }
    else if( output.indexOf("Yikes!  Invalid device signature.") != -1 ){
      reflashDialog.updateMsg("No chip detected. Check connections.");
    }
    else if( output.indexOf("initialization failed") != -1 ) { 
      reflashDialog.updateMsg("Programmer init failure. Bad connection?");
    }
    else if( output.indexOf("protocol error") != -1 ) { 
      reflashDialog.updateMsg("Programmer protocol error. Bad connection?");
    }
    else if( output.indexOf("not in sync") != -1 ) { 
      reflashDialog.updateMsg("Programmer sync error. Bad connection?");
    }
    else if( output.indexOf("Could not find USB device") != -1 ) { 
      reflashDialog.updateMsg("Could not find USB programmer.");
    }
    else if( output.indexOf("No such file or directory") != -1 ) { 
      reflashDialog.updateMsg("Could not find HEX firmware file.");
    }
    else if( output.indexOf("done.") != -1 ) {
      reflashDialog.updateMsg("Reflashing Done!");
    }

    reflashDialog.setReflashing(false);
  }

} // class Programmer


//
// Sets up the GUI
//
public class ReflashDialog extends JDialog { 

  JComboBox portChoices;
  JComboBox firmChoices;
  JLabel msgbText;
  JButton reflashButton;

  boolean reflashing = false;

  //
  public ReflashDialog() {
    super();

    try {  // use a Swing look-and-feel that's the same across all OSs
      MetalLookAndFeel.setCurrentTheme(new DefaultMetalTheme());
      UIManager.setLookAndFeel( new MetalLookAndFeel() );
    } catch(Exception e) { }  // don't really care if it doesn't work
    
    fc = new JFileChooser( System.getProperty("user.home")  ); 
    fc.setFileFilter( new javax.swing.filechooser.FileFilter() {
        public boolean accept(File f) {
          if(f.isDirectory()) return true;
          if (f.getName().toLowerCase().endsWith("hex") ) return true;
          return false;
        }
        public String getDescription() { return "HEX files";  }
      }
      );

    openReflashDialog();
  }

  //
  // Build GUI for the ISP 
  //
  public void makeIspPanel(JPanel isppPanel) {
    String[] portNames = listPorts();

    String lastPortName = portName;
    int pidx = 0;

    for( int i=0; i<portNames.length; i++) 
      if( portNames[i].equals(lastPortName) ) pidx = i;

    JLabel portText = new JLabel("Select type of ISP programmer:");

    ispButtonAvrIspMkII = new JRadioButton("AVR-ISP mkII");
    ispButtonUsbTiny    = new JRadioButton("USBtiny");
    ispButtonArduinoIsp = new JRadioButton("ArduinoISP on Arduino, on port:");

    ButtonGroup group = new ButtonGroup();
    group.add( ispButtonAvrIspMkII );
    group.add( ispButtonUsbTiny );
    group.add( ispButtonArduinoIsp );
    ispButtonAvrIspMkII.setSelected(true);

    portChoices = new JComboBox(portNames);
    portChoices.setSelectedIndex( pidx );

    JPanel butpanel = new JPanel(new GridLayout(0,1));
    butpanel.add( ispButtonAvrIspMkII );
    butpanel.add( ispButtonUsbTiny );

    JPanel arduinoPanel = new JPanel(new GridLayout(1,0));
    arduinoPanel.add( ispButtonArduinoIsp );
    arduinoPanel.add( portChoices );
    butpanel.add(arduinoPanel);

    isppPanel.add( portText, BorderLayout.NORTH );
    isppPanel.add( butpanel );

  }

  //
  //
  public String getFirmFile( String title ) { 
    fc.setDialogTitle( title );
    if(fc.showOpenDialog(reflashDialog) != JFileChooser.APPROVE_OPTION) 
      return null;
    return fc.getSelectedFile().getAbsolutePath();
  }

  //
  //
  public void openReflashDialog() {

    String[] firmNames = getFirmwareNames();

    String lastFirmName = fw.name; //firmName;

    int fidx = 0;
    for( int i=0; i<firmNames.length; i++)
      if( firmNames[i].equals(lastFirmName) ) fidx = i;

    firmChoices = new JComboBox(firmNames);
    firmChoices.setSelectedIndex( fidx );

    firmChoices.addActionListener( new ActionListener() {
        public void actionPerformed(ActionEvent e) { 
          String selstr = (String)firmChoices.getSelectedItem();
          int seli = firmChoices.getSelectedIndex();

          customFw = false; // default

          if( selstr.startsWith("Custom ATtiny85") ) {      // FIXME: hack
            firmwareCustom85.hex = getFirmFile("Open Hex file for ATiny85");
            customFw = true;
          }
          else if( selstr.startsWith("Custom ATtiny45") ) { // FIXME: hack
            firmwareCustom45.hex = getFirmFile("Open Hex file for ATiny45");
            customFw = true;
          }
          else if( selstr.startsWith("Custom ATtiny84") ) { // FIXME: hack
            firmwareCustom84.hex = getFirmFile("Open Hex file for ATiny84");
            customFw = true;
          }
          
          fw = firmwares[seli];
          firmFileStr.setText( "using: "+ fw.hex );

        } // actionPerformed
      }
      );

    JPanel msgtPanel = new JPanel();
    JPanel msgbPanel = new JPanel();
    JPanel ctrlPanel = new JPanel();
    JPanel firmPanel = new JPanel();
    JPanel isppPanel = new JPanel();
    JPanel statPanel = new JPanel();
    JPanel buttPanel = new JPanel();
    JPanel mainPanel = new JPanel();

    //ctrlPanel.setLayout( new BorderLayout() );
    msgtPanel.setLayout( new BorderLayout() );
    msgbPanel.setLayout( new BorderLayout() );
    ctrlPanel.setLayout( new BoxLayout(ctrlPanel,BoxLayout.Y_AXIS) );
    firmPanel.setLayout( new BorderLayout() );
    isppPanel.setLayout( new BorderLayout() );
    mainPanel.setLayout( new BorderLayout() );

    ctrlPanel.setBorder(new EmptyBorder(15,15,15,15));
    firmPanel.setBorder(new EmptyBorder(15,15,15,15));
    isppPanel.setBorder(new EmptyBorder(15,15,15,15));
    mainPanel.setBorder(new EmptyBorder(15,15,15,15));
    

    JLabel msgtText = new JLabel("Welcome to BlinkM Reflasher Tool");
    msgbText = new JLabel("<html>For ArduinoISP, load sketch onto Arduino before continuing.</html>");
    JLabel firmText = new JLabel("Select BlinkM firmware");
    firmFileStr = new JLabel("");

    reflashButton = new JButton("  Reflash  ");

    msgtPanel.add( msgtText );
    msgbPanel.add( msgbText );

    firmPanel.add( firmText, BorderLayout.NORTH );
    firmPanel.add( firmChoices );
    firmPanel.add( firmFileStr, BorderLayout.SOUTH );

    makeIspPanel( isppPanel );

    buttPanel.add( reflashButton );

    ctrlPanel.add( firmPanel );
    ctrlPanel.add( isppPanel );
    ctrlPanel.add( buttPanel );

    mainPanel.add( msgtPanel, BorderLayout.NORTH );
    mainPanel.add( ctrlPanel, BorderLayout.CENTER );
    mainPanel.add( msgbPanel, BorderLayout.SOUTH );

    reflashButton.addActionListener( new ActionListener() { 
        public void actionPerformed(ActionEvent e) {
          
          fw = firmwares[ firmChoices.getSelectedIndex() ];
          
          if( ispButtonAvrIspMkII.isSelected() ) {
            ispType = "avrispmkii";
            portName = "avrispmkII";
          }
          else if( ispButtonUsbTiny.isSelected() ) {
            ispType = "usbtiny";
            portName = "usbtiny";
          } 
          else if( ispButtonArduinoIsp.isSelected() ) { 
            ispType = "arduinoisp";
            portName = (String) portChoices.getSelectedItem();
          }   

          setReflashing(true);
          new Thread( new Programmer() ).start();
          
        }
      });
    
    JDialog dialog = new JDialog();
    dialog.setTitle("ReflashBlinkM!");

    // handle window close events
    dialog.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
          dispose();            // close mainframe
          //appletRef.destroy();  // close processing window as well
          //appletRef.frame.setVisible(false);
          System.exit(0);
        }
      }); 

    dialog.getContentPane().add(mainPanel); // jdialog has limited container 
    dialog.pack();
    dialog.setResizable(false);
    dialog.setLocationRelativeTo(null); // center it on BlinkMSequencer
    dialog.setVisible(true);

  }

  //
  void updateMsg(String s) {
    if(debug) println(s);
    msgbText.setText("<html>"+s+"</html>");
  }

  //
  void setReflashing(boolean b) { 
      reflashing = b;
      reflashButton.setEnabled( !b );
  }

  //
  boolean isReflashing() {
      return reflashing;
  }

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
    }
    if( debug ) { 
      for( int i=0;i<a.length;i++){
        println(i+":"+a[i]);
      }
    }
    return a;
  }

  public String[] getFirmwareNames() {
    String[] names = new String[firmwares.length];
    for( int i=0; i< firmwares.length; i++) {  
      names[i] = firmwares[i].name;
    }
    return names;
  }

} // ReflashDialog




// -------------------------------------------------------------------
// unused, but perhaps useful to reflect upon
//

          //firmName = (String) firmChoices.getSelectedItem();

          //int fwid = -1;
          //for( int i = 0; i<firmwares.length; i++ ) 
          //  if( firmwares[i].name.equals(firmName) ) fwid = i;
          //fw = firmwares[fwid];  // FIXME: check fwid not -1

    /*
    String[] cmd = new String[] { binpath, 
                                  "-C", confpath,
                                  "-c", "stk500v1", 
                                  "-b", "19200",
                                  "-P", portName,
                                  "-p", fw.mcu,
                                  "-U", "flash:w:"+hexpath+":i",
                                  "-U", "eeprom:w:"+eeppath+":i",
                                  "-U", "lfuse:w:"+fw.lfuse+":m",
                                  "-U", "hfuse:w:"+fw.hfuse+":m",
                                  "-U", "efuse:w:"+fw.efuse+":m",
    };
    */

    /*
    // open the port so the Arduino resets (and keep it open)
    Serial tmpport = new Serial(papplet, portName, 19200);
    reflashDialog.updateMsg("opening port '"+portName+"'...");
    delay(3000);
    */

/**
 * will not use this, but it shows how static hashmaps are done
 *
public static class OSstuff { 
  public String avrdude; // name of avrdude
  public String sep;     // file separator
  public OSstuff( String a, String s ) { 
    avrdude = a; sep = s;
  }
}
//public final HashMap<OSstuff> osdeets = new HashMap<OSstuff>();
public static final HashMap osdeets = new HashMap();
static {
  osdeets.put( "macosx",  new OSstuff("avrdude","/") );
  osdeets.put( "windows", new OSstuff("avrdude.exe","\\") );
}
*/


/*
//
void debug(String s) {
  debug( s,null);
}
//
void debug(String s1, Object s2) {
  String s = s1;
  if( s2!=null ) s = s1 + " : " + s2;
  if(debug) println(s);
  //lastMsg = s1;
}


*/
