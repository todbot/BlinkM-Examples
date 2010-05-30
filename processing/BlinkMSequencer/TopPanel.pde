// Copyright (c) 2007-2008, ThingM Corporation

/**
 *
 */
public class TopPanel extends JPanel {

  JComboBox durChoice;
  /**
   *
   */
  public TopPanel() {
    durChoice = new JComboBox();
    durChoice.addItem( durations[0]+ " seconds");  
    durChoice.addItem( durations[1]+ " seconds");
    durChoice.addItem( durations[2]+ " seconds");

    // set color of this panel
    setBackground(bgLightGray);
        
    // add space label
    JLabel spc = new JLabel("  ");  // wow, what a hack, but so easy
    this.add(spc);
        
    // add Timeline title
    ImageIcon tlText = new Util().createImageIcon("blinkm_text_timeline.gif",
                                                  "TIMELINE");
    JLabel tlLabel = new JLabel(tlText);
    this.add(tlLabel);
    ImageIcon tlSubText = new Util().createImageIcon("blinkm_text_select.gif",
                                                     "Select time slice");
    JLabel tlSubLabel = new JLabel(tlSubText);
    this.add(tlSubLabel);
        
    // add separator
    ImageIcon sepImg = new Util().createImageIcon("blinkm_separator_vert_small.gif", "vert separator");
    JLabel sep1 = new JLabel(sepImg);
    this.add(sep1);
        
    // add loop label
    ImageIcon loopTxt = new Util().createImageIcon("blinkm_text_loop_speed.gif", "Loop Speed");
    JLabel loopLbl = new JLabel(loopTxt);
    this.add(loopLbl);
        
    // action listener for duration choice pull down
    durChoice.setBackground(bgLightGray);
    durChoice.addItemListener(new ItemListener() {
        public void itemStateChanged(ItemEvent ie) {
          int indx = durChoice.getSelectedIndex();
          durationCurrent = durations[indx];
          blinkmComm.prepareForPreview(durationCurrent);
          //l.debug("duration: " + durationCurrent);
          //tl.reset();
        }        
      }
                              );
    this.add(durChoice);
        
    // add Loop Check Box
    ImageIcon loopCheckIcn = new Util().createImageIcon("blinkm_text_loop.gif",
                                                        "Loop");
    JLabel loopCheckLbl = new JLabel(loopCheckIcn);
    this.add(loopCheckLbl);
    JCheckBox loopCheck = new JCheckBox("", true);
    loopCheck.setBackground(bgLightGray);
    this.add(loopCheck);
    ActionListener actionListener = new ActionListener() {
        public void actionPerformed(ActionEvent actionEvent) {
          AbstractButton abButton = (AbstractButton) actionEvent.getSource();
          boolean selected = abButton.getModel().isSelected();
          tl.setLoop(selected);
                
        }
      };
    loopCheck.addActionListener(actionListener);
        
    // add separator
    JLabel sep2 = new JLabel(sepImg);
    this.add(sep2);
        
    // add Help button
    JButton helpBtn = new Util().makeButton("blinkm_butn_help_on.gif", 
                                            "blinkm_butn_help_hov.gif", 
                                            "Help", bgLightGray);
    this.add(helpBtn);
        
    helpBtn.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent ae) {
          l.debug("help...");
          p.link("http://thingm.com/products/blinkm/help", "_blank"); 
        }    
      }
                              );
        
    // add About button
    JButton aboutBtn = new Util().makeButton("blinkm_butn_about_on.gif", 
                                             "blinkm_butn_about_hov.gif", 
                                             "About", bgLightGray);
    this.add(aboutBtn);
        
    aboutBtn.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent ae) {
          l.debug("help...");
          p.link("http://thingm.com/products/blinkm", "_blank"); 
        }    
      }
                               );
        
    JLabel spc2 = new JLabel("      ");  // FIXME: ???
    this.add(spc2);
  }
    
}
