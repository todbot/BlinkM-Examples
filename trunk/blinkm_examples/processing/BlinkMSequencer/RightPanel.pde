// Copyright (c) 2007-2008, ThingM Corporation

/**
 *
 */
public class RightPanel extends JPanel {
  JButton connectBtn;
  JButton burnBtn;
  private ImageIcon iconConn;
  private ImageIcon iconConnHov;
  private ImageIcon iconDisc;
  private ImageIcon iconDiscHov;
  public boolean showConnect = true;

  /**
   *
   */
  public RightPanel() {
    this.setPreferredSize(new Dimension(310, 250));
    this.setBackground(bgDarkGray);

    // add play button
    pb = new PlayButton();
    this.add(pb.b);

    // add upload button
    burnBtn = new Util().makeButton("blinkm_butn_upload_on.gif", 
                                    "blinkm_butn_upload_hov.gif",
                                    "Upload to BlinkM", bgDarkGray);
    // action listener for burn button
    burnBtn.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent ae) {
          new BurnDialog(mf,burnBtn);
        }
      });
    this.add(burnBtn);

    // add separator
    ImageIcon connImg = new Util().createImageIcon("blinkm_separator_horiz_larg.gif", "separator horizontal");
    this.add(new JLabel(connImg));

    // add connect button
    iconConn    = new Util().createImageIcon("blinkm_butn_settings_on.gif", 
                                             "Connect"); 
    iconConnHov = new Util().createImageIcon("blinkm_butn_settings_hov.gif", 
                                             "Connect"); 
    iconDisc    = new Util().createImageIcon("blinkm_butn_disconnect_on.gif", 
                                             "Disconnect"); 
    iconDiscHov = new Util().createImageIcon("blinkm_butn_disconnect_hov.gif", 
                                             "Disconnect"); 
    
    // it's so lame one has to do all this
    connectBtn = new JButton();
    connectBtn.setOpaque( true );
    connectBtn.setBorderPainted( false );
    connectBtn.setBackground(bgDarkGray);
    connectBtn.setRolloverEnabled( true );
    setIcon();

    // action listener for connect button
    connectBtn.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent ae) {
          new ConnectDialog(mf);
          if( showConnect && blinkmComm.isConnected() ) {
            showConnect = false; // FIXME: sorta confusing
          }
          else if( !showConnect && !blinkmComm.isConnected() ) {
            showConnect = true;
          }
          setIcon();  // show the (potentially) new icon
        }
      });

    this.add(connectBtn);

  }

  public void setIcon() {
    if( showConnect ) {
      connectBtn.setIcon( iconConn );
      connectBtn.setRolloverIcon( iconConnHov );
    }
    else { 
      connectBtn.setIcon( iconDisc );
      connectBtn.setRolloverIcon( iconDiscHov );
    }
  }

}
