//
// BlinkMScriptTool.pde --  Load/Save BlinkM light scripts in text format
//
//   This Processing sketch assumes it is communicating to a BlinkM 
//   via an Arduino "BlinkMCommunicator" sketch.
//   
//   You can use this download the BlinkMSequencer-creatd light scripts
//   from a BlinkM.  Or to reset a BlinkM to its default light script.
//
//   Note: it only loads files with .txt extensions, so be sure to save your
//         files as that.
//
// 2008, Tod E. Kurt, ThingM, http://thingm.com/
//
//

import java.util.regex.*;
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;  // even tho most of the stuff we're doing is AWT
import javax.swing.border.*;      // for silly borders on buttons
import javax.swing.plaf.metal.*;  // for look-n-feel stuff

boolean debug = true;

String strToParse =  
  "// Edit your BlinkM light script here. \n"+
  "// Or load one up from a text file.  \n"+
  "// Or read the one stored on a BlinkM.\n"+
  "// Then save your favorite scripts to a text files\n"+
  "// Several example scripts are stored in this sketch's 'data' directory.\n"+
  "// Make sure you have BlinkMCommunicator installed on your Arduino.\n"+
  "//\n"+
  "// Here's an example light script. It's the default BlinkM script.\n\n"+
  "{  // dur, cmd,  arg1,arg2,arg3\n"+
  "    {  1, {'f',   10,0x00,0x00}},  // set color_step (fade speed) to 10\n"+
  "    {100, {'c', 0xff,0xff,0xff}},  // bright white\n"+
  "    { 50, {'c', 0xff,0x00,0x00}},  // red \n"+
  "    { 50, {'c', 0x00,0xff,0x00}},  // green\n"+
  "    { 50, {'c', 0x00,0x00,0xff}},  // blue \n"+
  "    { 50, {'c', 0x00,0x00,0x00}},  // black (off)\n"+
  "}\n\n";

ArrayList scriptLines;     // contains a list of BlinkMScriptLine objects
int maxScriptLength = 49;  // max the EEPROM on BlinkM can hold
BlinkMScriptLine nullScriptLine = new BlinkMScriptLine( 0,(char)0x00,0,0,0);

BlinkMComm blinkmComm;

ScriptToolFrame stf;
JFileChooser fc;
JButton disconnectButton;
JTextArea editArea;  // contains the raw text of the script
JTextField posText;

int mainWidth = 740;
int mainHeight = 480;
Font monoFont = new Font("Monospaced", Font.PLAIN, 14); // all hail fixed width
Font monoFontSm = new Font("Monospaced", Font.PLAIN, 9); 
Color backColor = new Color(150,150,150);


//
// Processing's setup()
//
void setup() {
  size(100, 100);   // Processing's frame, we'll turn this off in a bit
  blinkmComm = new BlinkMComm(this);
  setupGUI();
}

//
// Processing's draw()
// Here we're using it as a cheap way to finish setting up our other window
// and as a simple periodic loop to deal with disconnectButton state
// (could write a handler for that, but i'm lazy)
//
void draw() {
  // we can only do this after setup
  if( frameCount < 60 ) {
    super.frame.setVisible(false);  // turn off Processing's frame
    super.frame.toBack();
    stf.setVisible(true);
    stf.toFront();
  }
  // auto-toggle disconnect button's clickability based on connectedness
  disconnectButton.setEnabled( blinkmComm.isConnected() );
}

// super debug!  destroys receive functionality
/*
void serialEvent(Serial p) {
  
  int c = p.read();
  if( c>=' ' || c==0x0a || c==0x0d )
    print( (char) c );
  else 
    print( "0x"+hex(c,2) );
}
*/


// this class is bound to the GUI buttons below
// it triggers the four main functions
class MyActionListener implements ActionListener{
  public void actionPerformed(ActionEvent e) {
    String cmd = e.getActionCommand();
    if( cmd == null ) return;
    if( cmd.equals("stopScript")) {
      if( !connectIfNeeded() ) return;
      blinkmComm.stopScript();
    }
    else if( cmd.equals("playScript")) {
      int pos = 0;
      String s = posText.getText().trim();
      try { pos = Integer.parseInt(s);} catch(Exception nfe){}
      if( pos < 0 ) pos = 0;
      println("playing at position "+pos);
      if( !connectIfNeeded() ) return;
      blinkmComm.playScript(0,0,pos);
    }
    else if( cmd.equals("saveFile") ) {
      saveFile();
    }
    else if( cmd.equals("loadFile") ) {
      loadFile();
    }
    else if( cmd.equals("sendBlinkM") ) {
      sendToBlinkM();
    }
    else if( cmd.equals("recvBlinkM") ) {
      receiveFromBlinkM();
    }
    else if( cmd.equals("disconnect") ) { 
      blinkmComm.disconnect();
    }
    else if( cmd.equals("inputs") ) {
      showInputs();
    }
  }
}

// pop up the connect dialog box if we need to
boolean connectIfNeeded() {
  if( !blinkmComm.isConnected() ) {
    if( blinkmComm.doConnectDialog() == false ) 
      return false;
    blinkmComm.pause(2000);  // wait for things to settle after connect
  }
  return true; // connect successful?
}

// set a script to blinkm
void sendToBlinkM() {
  String[] rawlines = editArea.getText().split("\n");
  scriptLines = parseScript(rawlines);
  if(debug) println( scriptLinesToString(scriptLines) );
    
  if( !connectIfNeeded() ) return;

  // update the text area with the parsed script
  String str = scriptLinesToString(scriptLines);
  str = "// Uploaded to BlinkM on "+(new Date())+"\n" + str;
  editArea.setText( str );
    
  println("sending!...");
  int len = scriptLines.size();
  for( int i=0; i< len; i++ ) {
    blinkmComm.writeScriptLine( i, (BlinkMScriptLine)scriptLines.get(i));
  }
  // hack to get around fact we can't read back length
  if( len < maxScriptLength ) {  
    blinkmComm.writeScriptLine( len, nullScriptLine );
  }
  blinkmComm.setScriptLengthRepeats( 0, len, 0 );
  blinkmComm.setStartupParamsDefault();
  blinkmComm.playScript();
}

// download a script from a blinkm
void receiveFromBlinkM() {
  if( !connectIfNeeded() ) return;
  println("receiving!...");
  BlinkMScriptLine line;
  String str = "{\n";
  int i;
  for( i = 0; i< maxScriptLength; i++ ) {
    line = blinkmComm.readScriptLine( 0, i );
    if( line==null || (line.dur == 0xff && line.cmd == 0xff ) || 
        (line.dur == 0 && line.cmd == 0) ) {
      println("bad script line at pos "+i+", assuming end of script.");
      break;
    }
    println("script line #"+i+": "+line);
    str += "\t"+ line.toFormattedString() + "\n";
  }
  str += "}\n";
  str = "// Downloaded from BlinkM at "+(new Date())+"\n" + 
    "// script length: "+ i + "\n" + str;
  editArea.setText(str); // copy it all to the edit textarea
  editArea.setCaretPosition(0);
}

// take a String and turn it into a list of BlinkMScriptLine objects
ArrayList parseScript( String[] lines ) {
  BlinkMScriptLine bsl;  // little holder
  ArrayList sl = new ArrayList();  // array of scriptlines
  String linepat = "\\{(.+?),\\{'(.+?)',(.+?),(.+?),(.+?)\\}\\}";
  Pattern p = Pattern.compile(linepat);

  for (int i = 0; i < lines.length; i++) {
    String l = lines[i];
    String[] lineparts = l.split("//");  // in case there's a comment
    l = l.replaceAll("\\s+","");  // squash all spaces to zero
    //if(debug) println("l:"+l); 
    Matcher m = p.matcher( l );
    while( m.find() ) {
      if( m.groupCount() == 5 ) { // matched everything
        int dur = parseHexDecInt( m.group(1) );
        char cmd = m.group(2).charAt(0);
        int a1 = parseHexDecInt( m.group(3) );
        int a2 = parseHexDecInt( m.group(4) );
        int a3 = parseHexDecInt( m.group(5) );
        if(debug)println("d:"+dur+",c:"+cmd+",a123:"+a1+","+a2+","+a3);
        bsl = new BlinkMScriptLine( dur, cmd, a1,a2,a3);
        if( lineparts.length > 1 ) 
          bsl.addComment( lineparts[1] );
        sl.add( bsl );
      }
    }
  }
  return sl;
}

// Load a text file containing a light script and turn it into BlinkMScriptLines
// Note: uses Procesing's "loadStrings()"
void loadFile() {
  int returnVal = fc.showOpenDialog(stf);  // this does most of the work
  if (returnVal != JFileChooser.APPROVE_OPTION) {
    println("Open command cancelled by user.");
    return;
  }
  File file = fc.getSelectedFile();
  // see if it's a txt file
  // (better to write a function and check for all supported extensions)
  if( file!=null ) {
    String lines[] = loadStrings(file); // loadStrings can take File obj too
    StringBuffer sb = new StringBuffer();
    for( int i=0; i<lines.length; i++) {
      sb.append(lines[i]); 
      sb.append("\n");
    }
    editArea.setText(sb.toString()); // copy it all to the edit textarea
    editArea.setCaretPosition(0);
    scriptLines = parseScript( lines ); // and parse it
    // FIXME: should do error checking here
  }
}

// Save a text file of BlinkMScriptLines
// Note: uses Processing's "saveStrings()"
void saveFile() {
  int returnVal = fc.showSaveDialog(stf);  // this does most of the work
  if( returnVal != JFileChooser.APPROVE_OPTION) {
    println("Save command cacelled by user.");
    return;
  }
  File file = fc.getSelectedFile();
  if (file.getName().endsWith("txt") ||
      file.getName().endsWith("TXT")) {
    String lines[] = editArea.getText().split("\n");
    saveStrings(file, lines);  // actually write the file
  }
}

// Utility: 'serialize' to String
// not strictly needed since we can just read/write the editArea
public String scriptLinesToString(ArrayList scriptlines) {
  String str = "{\n";
  BlinkMScriptLine line;
  for( int i=0; i< scriptLines.size(); i++ ) {
    line = (BlinkMScriptLine)scriptLines.get(i);
    str += "\t"+ line.toFormattedString() +"\n";
  }
  str += "}\n";
  return str;
}

// Utility: parse a hex or decimal integer
int parseHexDecInt(String s) {
  int n=0;
  try { 
    if( s.indexOf("0x") != -1 ) // it's hex
      n = Integer.parseInt( s.replaceAll("0x",""), 16 ); // yuck
    else 
      n = Integer.parseInt( s, 10 );
  } catch( Exception e ) {}
  return n;
}

// -------------------------------------------------------------------------

//  The nuttiness below is to do the "Inputs" dialog. Jeez what a mess.
JTextField inputText;
JDialog inputDialog;
boolean watchInput;

class InputWatcher implements Runnable {
  public void run() {
    while( watchInput ) { 
      try { Thread.sleep(333); } catch(Exception e) {} 
      byte[] inputs = blinkmComm.readInputs();
      String s = "inputs: ";
      if( inputs == null ) {
        s += "error reading";
      } else {
        for( int i=0; i<inputs.length; i++) {
          s += "0x" + Integer.toHexString( inputs[i] & 0xff) + ", ";
        }
      }
      inputText.setText(s);
      println(s);
    }
    inputDialog.hide();
  }
}

// man this seems messier than it should be
// all I want is a Dialog with a single line of text and an OK button
// where I can dynamically update the line of text
void showInputs() {
  if( !connectIfNeeded() ) return;
  println("watching inputs!...");
  inputDialog = new JDialog(stf, "Inputs", false);
  inputDialog.addWindowListener( new WindowAdapter() {
      public void windowClosing(WindowEvent e) {
        watchInput = false;
      }});
  inputDialog.setLocationRelativeTo(stf);
  Container cp = inputDialog.getContentPane();
  //cp.setLayout(new BorderLayout());
  JPanel panel = new JPanel(new BorderLayout());
  panel.setBorder(new EmptyBorder(10,10,10,10));
  cp.add(panel);
  
  inputText = new JTextField("inputs",20);
  JButton btn = new JButton("Done");
  btn.addActionListener( new ActionListener() {
      public void actionPerformed(ActionEvent ae) {
        watchInput = false;
      }});
  panel.add( inputText, BorderLayout.CENTER );
  panel.add( btn, BorderLayout.SOUTH );
  inputDialog.pack();
  inputDialog.show();

  watchInput = true;
  new Thread( new InputWatcher() ).start();
  // this exits, and thread shoud quit when Done is clikd or window closed
}

// ---------------------------------------------------------------------

//
// do all the nasty gui stuff that's all Java and not very Processingy
//
void setupGUI() {
  try {  // use a Swing look-and-feel that's the same across all OSs
    MetalLookAndFeel.setCurrentTheme(new DefaultMetalTheme());
    UIManager.setLookAndFeel( new MetalLookAndFeel() );
  } catch(Exception e) { 
    println("drat: "+e);
  }

  fc = new JFileChooser( super.sketchPath ); 
  fc.setFileFilter( new javax.swing.filechooser.FileFilter() {
      public boolean accept(File f) {
        if (f.isDirectory()) 
          return true;
        if (f.getName().endsWith("txt") ||
            f.getName().endsWith("TXT")) 
          return true;
        return false;
      }
      public String getDescription() {
        return "TXT files";
      }
    }
    );
  
  stf = new ScriptToolFrame(mainWidth, mainHeight, this);
  stf.createGUI();

  stf.setResizable(false);

}

//
// A new window that holds all the Swing GUI goodness
//
public class ScriptToolFrame extends JFrame {

  public Frame f = new Frame();
  private int width, height;
  private PApplet appletRef;     

  //
  public ScriptToolFrame(int w, int h, PApplet appRef) {
    super("BlinkMScriptTool");
    setBackground( backColor );
    setFocusable(true);
    width = w;
    height = h;
    appletRef = appRef;

    // handle window close events
    addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
          dispose();            // close mainframe
          appletRef.destroy();  // close processing window as well
          appletRef.frame.setVisible(false);
          System.exit(0);
        }
      }); 

    // center on the screen and show it
    setSize(this.width, this.height);
    //this.pack();
    Dimension scrnSize = Toolkit.getDefaultToolkit().getScreenSize();
    this.setLocation(scrnSize.width/2 - this.width/2, 
                     scrnSize.height/2 - this.height/2);
  }

  //
  public void createGUI() {
    setLayout( new BorderLayout() );
    JPanel editPanel = new JPanel(new BorderLayout());
    JPanel ctrlPanel = new JPanel();    // contains all controls
    JPanel filePanel = new JPanel();    // contains load/save file
    JPanel blinkmPanel  = new JPanel(); // contains all blinkm ctrls
    ctrlPanel.setLayout( new BoxLayout(ctrlPanel,BoxLayout.X_AXIS) );
    filePanel.setLayout( new BoxLayout(filePanel,BoxLayout.X_AXIS) );
    blinkmPanel.setLayout( new BoxLayout(blinkmPanel,BoxLayout.X_AXIS) );

    ctrlPanel.add(filePanel);
    ctrlPanel.add(blinkmPanel);

    getContentPane().add( editPanel, BorderLayout.CENTER);
    getContentPane().add( ctrlPanel, BorderLayout.SOUTH);

    ctrlPanel.setBorder(new EmptyBorder(5,5,5,5));
    //ctrlPanel.setAlignmentX(Component.RIGHT_ALIGNMENT);

    filePanel.setBorder( new CompoundBorder
                         (BorderFactory.createTitledBorder("file"),
                          new EmptyBorder(5,5,5,5)));
    blinkmPanel.setBorder( new CompoundBorder
                           (BorderFactory.createTitledBorder("blinkm"),
                            new EmptyBorder(5,5,5,5)));

    editArea = new JTextArea(strToParse);
    editArea.setFont( monoFont );
    editArea.setLineWrap(false);
    JScrollPane scrollPane = new JScrollPane(editArea);
    editPanel.add( scrollPane, BorderLayout.CENTER);
  
    MyActionListener mal = new MyActionListener();

    JButton loadButton = addButton("Load", "loadFile", mal, filePanel);
    JButton saveButton = addButton("Save", "saveFile", mal, filePanel);

    JButton sendButton = addButton("Send",    "sendBlinkM", mal, blinkmPanel); 
    JButton recvButton = addButton("Receive", "recvBlinkM", mal, blinkmPanel); 

    blinkmPanel.add(Box.createRigidArea(new Dimension(5,5)));;
    disconnectButton   = addButton("disconnect","disconnect", mal,blinkmPanel);
    disconnectButton.setEnabled(false);
    blinkmPanel.add(Box.createRigidArea(new Dimension(5,5)));;

    JButton stopButton = addButton("Stop", "stopScript", mal, blinkmPanel);
    JButton playButton = addButton("Play", "playScript", mal, blinkmPanel);
    
    JLabel posLabel = new JLabel("<html>play <br>pos:</html>", JLabel.RIGHT);
    posText = new JTextField("0");
    posLabel.setFont(monoFontSm);
    posText.setFont(monoFontSm);
    blinkmPanel.add(posLabel);
    blinkmPanel.add(posText);

    JButton inputsButton = addButton("inputs", "inputs", mal, blinkmPanel);

  }

  //
  private JButton addButton( String text, String action, ActionListener al,
                            Container container ) {
    JButton button = new JButton(text);
    button.setActionCommand(action);
    button.addActionListener(al);
    button.setAlignmentX(Component.LEFT_ALIGNMENT);
    container.add(Box.createRigidArea(new Dimension(5,5)));;
    container.add(button);
    return button;
  }

} // ScriptToolFrame

