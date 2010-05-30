// Copyright (c) 2007-2008, ThingM Corporation

/**
 * A pseudo-LED 
 *
 */
public class ColorPreview extends JPanel {
  private Color colorCurrent = new Color(100, 100, 100);
  private Color colorTarget = new Color(100, 100, 100);
  private javax.swing.Timer fadetimer;

  // turning this off makes it more time-accurate on slower computers? wtf
  private static final boolean dofade = true;

  public int fadeMillis = 25;
  public int fadespeed  = 25;
  
  /**
   *
   */
  public ColorPreview() {
    super();
    this.setPreferredSize(new Dimension(105, 250));
    this.setBackground(bgLightGray);
    ImageIcon tlText = new Util().createImageIcon("blinkm_text_preview.gif", "Preview");
    JLabel tlLabel = new JLabel(tlText);
    this.add(tlLabel);
    if( dofade ) {
      fadetimer = new javax.swing.Timer(fadeMillis, new ColorFader());
      fadetimer.start();
    }
  }

  /**
   * @Override
   */
  public void paintComponent(Graphics g) {
    Graphics2D g2 = (Graphics2D) g;
    super.paintComponent(g2); 
    g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING, 
                        RenderingHints.VALUE_ANTIALIAS_ON);
    g2.setColor(colorCurrent);
    g2.fillRect(10, 70, 80, 160);
  }

  /**
   *
   */
  public void setColor(Color c) {
    if( dofade ) {
      fadespeed = getFadeSpeed(durationCurrent,numSlices,fadeMillis);
      colorTarget = c;
    } else {
      colorCurrent = c;
    }
    // make BlinkM color match preview color
    blinkmComm.sendColor(c, tlDarkGray, durationCurrent);
      
    repaint();
  }

  /**
   *
   */
  public Color getColor() {
    return this.colorCurrent; 
  }


  public int getFadeSpeed(int loopduration,int numsteps,int fadeMillis) {
    float time_per_step = ((float)loopduration / numsteps);
    float time_half_millis = (time_per_step / 2) * 1000;
    int f =  fadeMillis / (int)time_half_millis;
    //l.debug("ColorPreview: fadeMillis:"+fadeMillis+" time_half:"+time_half_millis+", fadespeed:"+f);
    return 25; // (int)time_half_millis;
  }

  /**
   * Somewhat replicates how BlinkM does color fades
   * called by the fadetimer every tick
   *
   * NOTE: this is constant rate, not constant time
   */
  class ColorFader implements ActionListener {
    public void actionPerformed(ActionEvent e) {
      int r = colorCurrent.getRed();
      int g = colorCurrent.getGreen();
      int b = colorCurrent.getBlue();
          
      int rt = colorTarget.getRed();
      int gt = colorTarget.getGreen();
      int bt = colorTarget.getBlue();
          
      r = color_slide(r,rt, fadespeed);
      g = color_slide(g,gt, fadespeed);
      b = color_slide(b,bt, fadespeed);
      colorCurrent = new Color( r,g,b );

      repaint();
    }

    int color_slide(int curr, int dest, int step) {
      int diff = curr - dest;
      if(diff < 0)  diff = -diff;
          
      if( diff <= step ) return dest;
      if( curr == dest ) return dest;
      else if( curr < dest ) return curr + step;
      else                   return curr - step;
    }
  }

}
