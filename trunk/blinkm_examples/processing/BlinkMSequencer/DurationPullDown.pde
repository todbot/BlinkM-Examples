// Copyright (c) 2007-2008, ThingM Corporation

/**
 *
 */
public class DurationPullDown extends JComboBox {

  /**
   *
   */
  public DurationPullDown() {
    this.addItem( durations[0]+ " seconds");  
    this.addItem( durations[1]+ " seconds");
    this.addItem( durations[2]+ " seconds");
  } 
}
