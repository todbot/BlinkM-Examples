// Copyright (c) 2007-2008, ThingM Corporation

/**
 *
 */
public class BurnDialog extends JDialog implements ActionListener {

  private String msg_uploading = "Uploading...";
  private String msg_done = "Done";
  private String msg_nowplaying = "Now playing sequence stand-alone";
  private String msg_error = "ERROR: not connected to a BlinkM.";
  private String msg_empty = "     ";

  private JLabel msgtop;
  private JLabel msgbot;
  private JProgressBar progressbar;
  private JButton okbut;

  private JButton burnBtn;

  public BurnDialog(Dialog owner, JButton aBurnBtn) {
    //super(owner, "BlinkM Connect",true);  // modal
    super();
    burnBtn = aBurnBtn;
    burnBtn.setEnabled(false);

    setTitle("BlinkM Upload");

    JPanel panel = new JPanel(new GridLayout(0,1));
    panel.setBorder( BorderFactory.createEmptyBorder(20,20,20,20) );

    msgtop = new JLabel(msg_uploading);
    progressbar = new JProgressBar(0, numSlices-1);
    msgbot = new JLabel(msg_nowplaying);
    msgbot.setVisible(false);
    okbut = new JButton("Ok");
    okbut.setVisible(false);
    okbut.addActionListener(this);

    panel.add( msgtop );
    panel.add( progressbar );
    panel.add( msgbot );
    panel.add( okbut );
    getContentPane().add(panel);

    pack();
    setResizable(false);
    setLocationRelativeTo(null); // center it on the BlinkMSequencer
    setVisible(true);
    
    tl.reset(); // stop preview script
    pb.setToPlay();  // rest play button

    // so dumb we have to spawn a thread for this
    new Thread( new Burner() ).start();

  }

  public void actionPerformed(ActionEvent e) {
    burnBtn.setEnabled(true);  // seems like such a hack
    blinkmComm.prepareForPreview(durationCurrent);
    setVisible(false);
  }
      
  public void isDone() {
    msgbot.setVisible(true);
    okbut.setVisible(true);
  }

  class Burner implements Runnable {
    public void run() {
      // test
      //for( int i=0; i<numSlices; i++ ) {
      //  progressbar.setValue(i);
      //  blinkmComm.pause(3000/48);
      //}
      
      // if we are connected to a port, burn to port
      if (blinkmComm.isConnected()) {
        tl.stop();
        ArrayList colorlist = new ArrayList();
        for( int i=0; i<numSlices; i++) 
          colorlist.add( tl.timeSlices[i].getColor());
        msgtop.setText( msg_uploading );
        
        // burn the list, and saying which colors are 'unused'
        blinkmComm.burn( colorlist, tlDarkGray, durationCurrent,
                         tl.getLoop(), progressbar);
        
        msgtop.setText( msg_uploading + msg_done );
        msgbot.setText( msg_nowplaying );
      } 
      else {
        progressbar.setVisible(false);
        msgtop.setText(msg_error);
        msgbot.setText("");
      }
      
      isDone();
    } // run
  }
}




  /*
  private Choice portChoice;
  private Button closeBtn;
  private Label msg;
  private int w, h;
  private final Dialog confDialog;

  /**
   *
   *
  public BurnDialog() {
    super(new Frame(), "BlinkM Upload", false);
    confDialog = new Dialog(new Frame(), "Burn Confirmation", true);  

    // set layout manager
    this.setLayout(new FlowLayout());

    // listen for window closing events
    this.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
          setVisible(false);
        }
      });

    // if we are connected to a port, burn to port
    if (blinkmComm.isConnected()) {
      tl.stop();
      ArrayList colorlist = new ArrayList();
      for( int i=0; i<numSlices; i++) 
        colorlist.add( tl.timeSlices[i].getColor());
      updateMessage("Uploading....");

      // burn the list, and saying which colors are 'unused'
      blinkmComm.burn( colorlist, tlDarkGray, durationCurrent, tl.getLoop());

      updateMessage("Done.");
      try { Thread.sleep(1000); } catch(Exception e) {} //FIXME: hack
      setVisible(false);
    } 
    else {
      updateMessage("ERROR: Check connection.");
    }

  }

  // this is such a hack
  void updateMessage(String str) {
    msg = new Label(str);
    this.add(msg);
    // center, size, and show dialog
    //this.w = 400;
    //this.h = 200;
    this.setSize(400, 200); // this.w, this.h);
    util.centerComp(this);
    this.show();
  }

  /**
   *
   *
  public void burnConf() {
    // set layout manager
    confDialog.setLayout(new FlowLayout());

    Label msg = new Label("\n\nBurned...\n\n");
    confDialog.add(msg);

    // listen for window closing events
    confDialog.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
          confDialog.setVisible(false);
        }
      }); 

    // add close button
    Button okBtn = new Button("OK");
    okBtn.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent ae) {
          confDialog.setVisible(false);
          l.debug("ok...");
        }    
      });

    confDialog.add(okBtn);

    confDialog.setSize(this.w, this.h);
    util.centerComp(confDialog);
    confDialog.show();
  }

}

  */
