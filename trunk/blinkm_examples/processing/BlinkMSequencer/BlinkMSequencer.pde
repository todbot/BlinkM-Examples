// Copyright (c) 2007-2008, ThingM Corporation

// 11-11 - adding color chooser component - 2 hours
// 11-11 - layout all components using relative layout manager - 4 hours
// 11-29 - added BurnDialog and ConnectDialog - 3 hours
// 11-30 - fixed bug with duplicate zip entry - .5 hours
// 11-30 - added code to hide processing PApplet and parent frame - .5 hours
// 12-05 - update ui to design v0.16 and integrate new images - 4 hours
// 12-07 - development of timeline custom component - 3.5 hours
// 12-15 - integrated new ui images - 1 hours
// 12-15 - added TimeSlice class for TimeLine class - 1 hours
// 12-15 - updated timeline- added selection capabilities, color preview, snapping, and multi-selection - .5
/////// above sent as invoice for first 20 hours

// 12-15 - updated timeline- added selection capabilities, color preview, snapping, and multi-selection - 4.5 hours
// 12-19 - bugfix- bgcolors, sampling rate of playhead, drag selection, play button synch. - 3 hours
//
// Tod's notes:
// ------------
// 12-21 - Added to ThingM SVN repository as "BlinkMSequencer"
//         Directory 'images' not needed, 
//         No source code to com.brunchboy.util.swing.relativelayout.*
//          (but available on the Net)
//         Not seeing need for ColorM class.
// 12-22 - Added "BlinkMComm" class to encapsulate all serial & BlinkM tasks
//         Removed ColorM and used Java's Color class instead
//         Works programming a BlinkM (tho no fade & duration adjustments yet)
//         Changed About & Help URLs to thingm.com/products/blinkm{/help}
//         Changed use flow on Connect & Burn dialogs to be more streamlined
//           (via some lame hacks i did)
// 12-23 - Still many visual differences between Mac & Windows. Why Java why?
//         Trying to figure out why there's a global ColorPreview and 
//           a private one for ColorChooser
//         Removed private ColorPreview in ColorChooser; all ref global one now
//         TimeSlices are now in an array instead of ArrayList; it doesn't grow
//           or shrink so no need for dynamic container
//         Parameterized number of Slices ('numSlices') and set to 48
//         Changed timeline rendering to be inset so it's centered (ish)
//         Added double-click to mean show color in ColorPreview, hopefully
//           will be able to add ColorChooser tracking too.
//         Changed BlinkMComm from entirely static class to one you must 
//           instantiate.  Done mostly because it allows use of Log l.
//         ColorChooser now global and control ColorPreview
//         Double-click on timeline -> color chooser working
//         Fixed tick marks (was tenMarks) to be %8 instead of %10
//         Using Java cross-platform Look-n-Feel to solve discrepancies
//         Fixed non-loop Play button bug by making PlayButton global
// 12-24 - Added real-time BlinkM color updating. it's cool
//           but dunno if we'll keep it.
//         Parameterized durations, since BlinkM might not do 1,10,100
//         Fixed loop speed timing inaccuracies
//         Fixed fast rubber-band multi-select problem
//         Added fading simulator to preview
//         Changed ConnectDialog (and soon BurnDialog) to Swing so its
//           visual style matches the rest (and is more manageable)
//         Add blinkm_thingm_corp.gif footer image in place of text
//           to prevent Windows/Mac layout variations
// 12-25 - Migrated BurnDialog Swing.
//         Added progress bar to BurnDialog, also msg & 'OK' button to
//           hilight to people stand-alone operation vs. real-time preview.
//         Fixed timing for fastest case: 2secs on timeline == 2 secs on blinkm
//         Fixed Windows serial bug by using Serial.print(byte[]) in BlinkMComm
//         Disconnecting now works
//         ConnectDialog now has different modes for connect vs disconnect
//         Parameterized timers.  Timers seem to bog down Windows, need tuning
// 12-26 - Added version number in footer, removed thingm corp image
//         Added connect/disconnect button toggle
// 01-03 - Added 1500 msec delay after connect to wait for Diecimila reset
//         Fixed programming of reps and boot setup in BlinkMComm
//         Since BurnDialog can't be modal, let it enable/disable button to
//           prevent multiple presses
//         Fixed bug where programmed play doesn't stop when doing preview play
//         Tuned programmed timing to be match better preview timing
//         
//
// 
// To-do:
// - tune fade time for both real blinkm & preview
// - tune & test other two loop durations 
// - research why timers on windows are slower (maybe use runnable)
// - need to deal with case of *no* serial ports available
//

/**
 * RelativeLayout is an open-source alternative layout manager
 * Details here:
 * @see: http://www.onjava.com/pub/a/onjava/2002/09/18/relativelayout.html?page=2
 */
//import com.brunchboy.util.swing.relativelayout.*;

import java.awt.*;
import java.awt.event.*;

import javax.swing.*;
import javax.swing.event.*;
import javax.swing.colorchooser.*;
import javax.swing.plaf.metal.*;

String VERSION = "001";

Log l = new Log();

BlinkMComm blinkmComm = new BlinkMComm();

MainFrame mf;
JColorChooser colorChooser;
//ColorChooser colorChooser;
ColorPreview colorPreview;
TimeLine tl;
//RightPanel rp;
PlayButton pb;

JPanel connectPanel;

// number of slices in the timeline == number of script lines written to BlinkM
int numSlices = 48;

// overall dimensions
int mainWidth = 851;
int mainHeight = 455;
int mainHeightAdjForWindows = 12; // fudge factor for Windows layout variation


// the possible durations for the loop
int[] durations = { 3, 30, 120 };
int durationCurrent = durations[0];

PApplet p;
Util util = new Util();

Color fgLightGray = new Color(230, 230, 230);
Color bgLightGray = new Color(200, 200, 200);
Color bgMidGray   = new Color(140, 140, 140);
Color bgDarkGray  = new Color(100, 100, 100);
Color tlDarkGray  = new Color(55, 55, 55);          // dark color for timeline
Color highLightC  = new Color(255, 0, 0);           // used for selections

JTabbedPane tabbedPane;

/**
 * Processing's setup()
 */
void setup() {
  size(10, 10);   // Processing's frame, we'll turn this off in a bit

  try {  // use a Swing look-and-feel that's the same across all OSs
    MetalLookAndFeel.setCurrentTheme(new DefaultMetalTheme());
    UIManager.setLookAndFeel( new MetalLookAndFeel() );
  } catch(Exception e) { 
    l.error("drat: "+e);
  }

  String osname = System.getProperty("os.name");
  if( osname.toLowerCase().startsWith("windows") ) 
    mainHeight += mainHeightAdjForWindows;
  
  mf = new MainFrame(mainWidth, mainHeight, this);
  p = this;

  // layout MainFrameicon
  RelativeLayout layout = new RelativeLayout();
  mf.getContentPane().setLayout(layout);
  //mf.f.requestFocusInWindow();

  // add top control panel
  //tabbedPane = new JTabbedPane();
  //tabbedPane.setOpaque(true); //content panes must be opaque
  //openNewTab();
  //mf.getContentPane().add( tabbedPane, "top_panel");

  TopPanel tp = new TopPanel();
  mf.getContentPane().add( tp, "top_panel");

  layout.addConstraint("top_panel", AttributeType.TOP,
  new AttributeConstraint(DependencyManager.ROOT_NAME, AttributeType.TOP, 0));

  layout.addConstraint("top_panel", AttributeType.LEFT,
  new AttributeConstraint(DependencyManager.ROOT_NAME, AttributeType.LEFT, 0));

  //layout.addConstraint("top_panel", AttributeType.HORIZONTAL_CENTER,
  //new AxisConstraint(DependencyManager.ROOT_NAME, AttributeAxis.HORIZONTAL, 0.5));

  // add TimeLine
  tl = new TimeLine(mainWidth);
  mf.getContentPane().add(tl, "time_line");

  layout.addConstraint("time_line", AttributeType.TOP,
  new AttributeConstraint("top_panel", AttributeType.BOTTOM, 0));

  layout.addConstraint("time_line", AttributeType.HORIZONTAL_CENTER,
  new AttributeConstraint(DependencyManager.ROOT_NAME, AttributeType.HORIZONTAL_CENTER, 0));

  // add Color Preview panel  (must exist before colorChooser)
  colorPreview = new ColorPreview();
  mf.getContentPane().add(colorPreview, "color_preview");

  layout.addConstraint("color_preview", AttributeType.TOP,
  new AttributeConstraint("time_line", AttributeType.BOTTOM, 3));

  layout.addConstraint("color_preview", AttributeType.LEFT,
  new AttributeConstraint("color_chooser", AttributeType.RIGHT, 0));

  // add ColorChooser
  JPanel colorChooserPanel = new JPanel();
  colorChooser = new JColorChooser();
  colorChooser.setBackground(bgLightGray);
  colorChooser.getSelectionModel().addChangeListener( new ChangeListener() {
      public void stateChanged(ChangeEvent e) {
        Color c = colorChooser.getColor();
        colorPreview.setColor(c);          // update ColorPreview panel
        // update selected TimeSlice in TimeLine
        for( int i=0; i<numSlices; i++) {
          TimeSlice ts = tl.timeSlices[i];
          if (ts.isActive)
            ts.setColor(c);
          //ts.isActive = false;
        }
        tl.repaint();
      }      
    });
  colorChooser.setPreviewPanel(colorPreview);
  colorChooser.setBackground(bgLightGray);
  colorChooserPanel.add(colorChooser);
        // add separator
        //ImageIcon sepImg = new Util().createImageIcon("blinkm_separator_vert_large.gif", "vert separator");
        //JLabel sep1 = new JLabel(sepImg);
        //this.add(sep1);
  mf.getContentPane().add(colorChooserPanel, "color_chooser");

  /*
  colorChooser = new ColorChooser();
  mf.getContentPane().add(colorChooser, "color_chooser");
  */

  layout.addConstraint("color_chooser", AttributeType.TOP,
  new AttributeConstraint("time_line", AttributeType.BOTTOM, 3));

  layout.addConstraint("color_chooser", AttributeType.LEFT,
  new AttributeConstraint(DependencyManager.ROOT_NAME, AttributeType.LEFT, 0));

  // add RightPanel
  RightPanel rp = new RightPanel();
  mf.getContentPane().add(rp, "right_panel");

  layout.addConstraint("right_panel", AttributeType.RIGHT,
  new AttributeConstraint(DependencyManager.ROOT_NAME, AttributeType.RIGHT,0));

  layout.addConstraint("right_panel", AttributeType.TOP,
  new AttributeConstraint("time_line", AttributeType.BOTTOM, 0));

  layout.addConstraint("right_panel", AttributeType.BOTTOM,
  new AttributeConstraint("lower_panel", AttributeType.TOP, 0));

  layout.addConstraint("right_panel", AttributeType.LEFT,
  new AttributeConstraint("color_preview", AttributeType.RIGHT, 0));


  // add Lower Panel
  JPanel lp = new JPanel();
  lp.setBackground(bgMidGray);

  //ImageIcon llText = new Util().createImageIcon("blinkm_thingm_corp.gif", "thingm corp");
  //JLabel lowLabel = new JLabel(llText);
  JLabel lowLabel = new JLabel("  version "+VERSION+" \u00a9 ThingM Corporation", JLabel.LEFT);
  lowLabel.setHorizontalAlignment(JLabel.LEFT);
  lp.setPreferredSize(new Dimension(855, 30));
  lp.setLayout(new BorderLayout());
  lp.add(lowLabel, BorderLayout.WEST);
  //ImageIcon lllText = new Util().createImageIcon("blinkm_thingm_logo.gif", "thingm logo");
  //JLabel lowLogo = new JLabel(lllText);
  //lp.add(lowLogo, BorderLayout.EAST);
  mf.getContentPane().add(lp, "lower_panel");

  layout.addConstraint("lower_panel", AttributeType.TOP,
  new AttributeConstraint("color_chooser", AttributeType.BOTTOM, 7));

  layout.addConstraint("lower_panel", AttributeType.LEFT,
  new AttributeConstraint("color_chooser", AttributeType.LEFT, 0));

  mf.setResizable(false);

}

public void openNewTab() {
  int i = tabbedPane.getTabCount();
  if(i < 8) {
    TopPanel tp = new TopPanel();
    //lastTab = lastTab+1;
    tabbedPane.addTab("BlinkM #"+i, null, tp);
    //tabbedPane.setSelectedIndex(lastTab-1);
  }
}

/**
 * Processing's draw()
 */
void draw() {
  super.frame.setVisible(false);  // turn off Processing's frame
  super.frame.toBack();
  mf.setVisible(true);
  mf.toFront();

  if(frameCount > 30) {  // what is this here for?
    noLoop(); 
  }
}

// debug!
void serialEvent(Serial p) {
  print( (char)p.read() );
}

