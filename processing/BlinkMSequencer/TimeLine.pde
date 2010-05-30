// Copyright (c) 2007-2008, ThingM Corporation

/**
 *
 */
public class TimeLine extends JPanel implements MouseListener, MouseMotionListener {
  
  private int scrubHeight = 10;
  private int secSpacerWidth = 2;
  private int w;  
  private int h = 90; 
  private int sx = 18;                 // offset from left edge of screen
  private boolean isMousePressed;
  private Point mouseClickedPt;
  private Point mouseReleasedPt;
  
  private Color playHeadC = new Color(255, 0, 0);
  private float playHeadCurr = sx;
  private int loopEnd;

  private javax.swing.Timer timer;
  private int timerMillis = 25;        // time between timer firings
  
  private boolean isPlayHeadClicked = false;
  private boolean isLoop = true;           // timer, loop or no loop
  private long startTime = 0;             // start time 
  
  public TimeSlice[] timeSlices = new TimeSlice[numSlices];
  
  /**
   *
   */
  public TimeLine(int aWidth) {
    this.w = aWidth;           // overall width of timeline object
    this.loopEnd = w;  // FIXME:
    this.setPreferredSize(new Dimension(this.w, this.h));
    this.setBackground(bgDarkGray);
    addMouseListener(this);
    addMouseMotionListener(this);
    //mf.addKeyListener(this);
        
    // initialize and add numSlices TimeSlice objects
    // draw guide rects
    int xStep = (this.w / numSlices) - secSpacerWidth;
    int xRemaining = this.w % numSlices - secSpacerWidth;
    int xCurr = sx;
    for (int i=1; i<numSlices+1; i++) {
      TimeSlice ts = new TimeSlice(xCurr, scrubHeight, 
                                   xStep, this.h - scrubHeight);
      if (i%8 == 0) {
        ts.isTicked = true; 
      }
      xCurr += xStep + secSpacerWidth;
      timeSlices[i-1] = ts;
    }
    timeSlices[0].isActive = true; // give people a nudge on what to do
  }

  /**
   * @Override
   */
  public void paintComponent(Graphics gOG) {
    Graphics2D g = (Graphics2D) gOG;
    super.paintComponent(g); 

    // paint light gray background
    g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, 
                       RenderingHints.VALUE_ANTIALIAS_ON);
    g.setColor(fgLightGray);
    g.fillRect(0, 0, this.getWidth(), scrubHeight);

    // paint each time slice, check if play head is over timeslice
    for( int i=0; i<numSlices; i++) {
      TimeSlice ts = timeSlices[i];
      if (ts.isCollision((int)playHeadCurr)) {
        // update ColorPreview panel based on current pos of slider
        colorPreview.setColor(ts.c);
        //colorChooser.setColor(ts.c);
      }
      ts.draw(g);
    }

    paintPlayHead(g);
    //paintLoopEnd(g);
  }

  /**
   *
   */
  void paintPlayHead(Graphics2D g) {
    g.setColor(playHeadC);
    g.fillRect((int)playHeadCurr, 0, secSpacerWidth, this.getHeight());
    Polygon p = new Polygon();
    p.addPoint((int)playHeadCurr - 5, 0);
    p.addPoint((int)playHeadCurr + 5, 0);
    p.addPoint((int)playHeadCurr + 5, 5);
    p.addPoint((int)playHeadCurr + 1, 10);
    p.addPoint((int)playHeadCurr - 1, 10);
    p.addPoint((int)playHeadCurr - 5, 5);
    p.addPoint((int)playHeadCurr - 5, 0);    
    g.fillPolygon(p);
  }
  
  void paintLoopEnd(Graphics2D g) {
    g.setColor(playHeadC);
    g.fillRect( loopEnd,0, secSpacerWidth, this.getHeight() );
  }

  /**
   *
   */
  public void setLoop(boolean b) {
    isLoop = b; 
  }
  public boolean getLoop() {
    return isLoop;
  }

  /**
   *
   */
  public void play() {
    l.debug("starting to play for dur: " + durationCurrent);

    timer = new javax.swing.Timer( timerMillis, new TimerListener());
    //timer.setInitialDelay(0);
    //timer.setCoalesce(true);
    timer.start();
    startTime = System.currentTimeMillis();
  }

  /**
   *
   */
  class TimerListener implements ActionListener {
    /** Handle ActionEvent */
    public void actionPerformed(ActionEvent e) {
      int width = getWidth() - sx;
      // not quite sure why need to add one to durationCurrent here
      int durtmp = (durationCurrent>5) ?durationCurrent+1 : durationCurrent;
      float step = width / (durtmp*1000.0/timerMillis);
      playHeadCurr += step;
      repaint();

      if (playHeadCurr > loopEnd) {        // check for end of timeline
        if (isLoop) {
          reset();
          play(); 
        } 
        else {
          reset();
          pb.setToPlay();
        }
      }
    }
  } 

  /**
   *
   */
  public void stop() {
    l.debug("stop"); 
    if (timer != null) 
      timer.stop();
    l.debug("elapsedTime:"+(System.currentTimeMillis() - startTime));
  }

  /**
   *
   */
  public void reset() {
    stop();
    playHeadCurr = sx;
    repaint();
  }

  public void mouseClicked(MouseEvent e) {
    //l.debug("clicked");
  }

  public void mouseEntered(MouseEvent e) {
    //l.debug("entered");
  }

  public void mouseExited(MouseEvent e) {
    //l.debug("exited");
  }

  public void mousePressed(MouseEvent e) {
    Point mp = e.getPoint();
    Polygon p = new Polygon();  // creating bounding box for mouseclick
    p.addPoint((int)playHeadCurr - 5, 0);
    p.addPoint((int)playHeadCurr + 5, 0);
    p.addPoint((int)playHeadCurr + 5, this.getHeight());
    p.addPoint((int)playHeadCurr - 5, this.getHeight());
    if (p.contains(mp)) {       // check if mouseclick inside box
      isPlayHeadClicked = true;
    }

    if (!isPlayHeadClicked) {
      // test for collision w/ timeslice
      for( int i=0; i<numSlices; i++) {
        TimeSlice ts = timeSlices[i];
        if (ts.isCollision(mp.x)) {
          ts.isActive = true;
        } 
        else if ((e.getModifiers() & InputEvent.META_MASK) == 0) {
          ts.isActive = false; 
        }
      }
    }

    isMousePressed = true;
    mouseClickedPt = mp;

    repaint();
  }

  public void mouseReleased(MouseEvent e) {
    mouseReleasedPt = e.getPoint();
    int clickCnt = e.getClickCount();

    isPlayHeadClicked = false;
    // snap playhead to closest time slice
    for( int i=0; i<numSlices; i++) {
      TimeSlice ts = timeSlices[i];
      if( ts.isActive && clickCnt >= 2 )   // double-click to set color
        colorChooser.setColor(ts.getColor());
      if( ts.isCollision((int)playHeadCurr)) {
        // update ColorPreview panel based on current pos. of slider
        playHeadCurr = ts.x - 1;        //break;
      } 
    }
    repaint();
  }

  public void mouseMoved(MouseEvent e) {
  }

  public void mouseDragged(MouseEvent e) {
    // if playhead is selected movie it
    if (isPlayHeadClicked) {
      playHeadCurr = e.getPoint().x;
          
      // bounds check for playhead
      if (playHeadCurr < 5)
        playHeadCurr = sx ;
      else if (playHeadCurr > this.getWidth() - 5)
        playHeadCurr = this.getWidth() - 5;
    } 
    else {
      // make multiple selection of timeslices on mousedrag
      int x = e.getPoint().x;
      for( int i=0;i<numSlices;i++) {
        TimeSlice ts = timeSlices[i];
        if (ts.isCollision(mouseClickedPt.x, x) )
          ts.isActive = true;
      }
    }
      
    repaint();
  }
  
} // TimeLine


/**
 * Represents a single slice of time on the timeline. 
 * There are 'numSlices' time slices, regardless of duration.
 */
public class TimeSlice {
  private int x, y, w, h;
  private boolean isActive;
  private boolean isTicked;
  private Color c = tlDarkGray;

  /**
   *
   */
  public TimeSlice(int x, int y, int w, int h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  /**
   *
   */
  public void draw(Graphics2D g) {
    g.setColor(c);
    g.fillRect(x, y, w, h);
    if (this.isTicked) {
      g.setColor(bgDarkGray);
      g.fillRect(x+w, 5, 2, h);  
    }

    if (this.isActive) {
      BasicStroke wideStroke = new BasicStroke(2.0f);
      g.setStroke(wideStroke);
      g.setColor(highLightC);
      g.drawRect(x, y, w, h-1);
    }
  }

  /**
   *
   */
  public boolean isCollision(int x) {
    return (x <= (this.x + this.w) && x >= this.x); 
  }

  /**
   * ???
   */
  public boolean isCollision(int x1, int x2) {
    if( x2 > x1 ) 
      return (x1 <= (this.x + this.w) && x2 >= this.x);
    else 
      return (x2 <= (this.x + this.w) && x1 >= this.x);
  }

  /**
   *
   */
  public void setColor(Color c) {
    this.c = c;
  }

  /**
   *
   */
  public Color getColor() {
    return this.c; 
  }
}
