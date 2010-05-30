// Copyright (c) 2007-2008, ThingM Corporation

/**
 * A holder for the various dialogs to deal with serial port connecting
 *
 */
public class ConnectDialog extends JDialog implements ActionListener {

  private JComboBox portChoices;
  private JLabel msg;
  private String msg_intro        = "Please select a port";
  private String msg_andclickconn = "and click 'connect'";
  private String msg_intro_disc   = "Always quit or disconnect before";
  private String msg_andclickdisc = "removing Arduino and BlinkM";
  private String msg_connecting   = "connecting...";
  private String msg_connected    = "connected";
  private String butlbl_connect   = "  connect  ";
  private String butlbl_disconnect= "disconnect";

  boolean wasConnected;

  /**
   *
   */
  public ConnectDialog(Dialog owner) {
    super(owner, "BlinkM Connect",true);
    //setTitle("BlinkM Connect");
    
    JPanel panel = new JPanel(new BorderLayout());
    panel.setBorder( BorderFactory.createEmptyBorder(20,20,20,20) );

    String[] portNames = blinkmComm.listPorts();
    String lastPortName = blinkmComm.portName;
    
    if( lastPortName == null ) 
      lastPortName = (portNames.length!=0) ? portNames[0] : null;

    // FIXME: need to catch case of *no* serial ports (setSelectedIndex fails)
    int idx = 0;
    for( int i=0; i<portNames.length; i++) 
      if( portNames[i].equals(lastPortName) ) idx = i;

    JPanel chooserPanel = new JPanel();
    JLabel msgtop = new JLabel("");
    portChoices = new JComboBox(portNames);
    portChoices.setSelectedIndex( idx );
    JButton connectButton = new JButton();
    msg = new JLabel();

    wasConnected = blinkmComm.isConnected();

    if( !wasConnected ) {
      msgtop.setText( msg_intro );
      connectButton.setText(butlbl_connect);
      connectButton.setActionCommand("connect");
      msg.setText(msg_andclickconn);
      chooserPanel.add(portChoices);
    }
    else {
      msgtop.setText( msg_intro_disc );
      connectButton.setText(butlbl_disconnect);
      connectButton.setActionCommand("disconnect");
      msg.setText(msg_andclickdisc);
    }

    connectButton.addActionListener(this);

    chooserPanel.add(connectButton);
    panel.add( msgtop, BorderLayout.NORTH );
    panel.add( chooserPanel, BorderLayout.CENTER );
    panel.add( msg, BorderLayout.SOUTH);
    getContentPane().add(panel);  // jdialog has limited container 

    pack();
    setResizable(false);
    setLocationRelativeTo(null); // center it on the BlinkMSequencer
    setVisible(true);

    // Handle window closing correctly.
    //setDefaultCloseOperation(DO_NOTHING_ON_CLOSE);
    // not sure diff btwn windowDeactivated vs windowClosing
    addWindowListener( new WindowAdapter() {
        public void windowDeactivated(WindowEvent event) {
          if( !wasConnected && !blinkmComm.isConnected() )
            JOptionPane.showMessageDialog(null, "No port chosen");
        }
      });
  }
  

  // Implement ActionListener
  public void actionPerformed(ActionEvent event) {
    String action = event.getActionCommand();
    println("action: "+action);

    if( "connect".equals(action) ) {
      String portname = (String) portChoices.getSelectedItem();
      msg.setText( msg_connecting );  // why doesn't this refresh?
      try {
        blinkmComm.connect( p, portname );
        blinkmComm.pause(1500); // FIXME: wait for diecimila
        blinkmComm.prepareForPreview(durationCurrent);
      } 
      catch( Exception e ) {
        msg.setText("ERROR getting port: " + e.getMessage());
        e.printStackTrace();
        return;
      }
      msg.setText( msg_connected );  // no one will likely see this
      setVisible(false);
    }
    else if( "disconnect".equals(action) ) { // unused as of yet
      blinkmComm.playScript();
      blinkmComm.disconnect();
      setVisible(false);
    }
  }

}


