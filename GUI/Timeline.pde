//This class holds the timeline object as well as manage the currently active "Tick" in the application

/*
so to recap: I'm going to ask Freidrich how MSB handles time. Specifically, it is possible to query the position of a camera and of characters at specific points in time (I think each and all of these are called "actors").

Here's that Box2D library from Daniel Shiffman. 
http://www.shiffman.net/teaching/nature/box2d-processing/
I've used it in Processing (the examples are great to play around with!), and it's well documented. Looks like it also has some "mouse interaction" that we could hook into but use the Kinect input instead.

And this is me on github: https://github.com/ashtonyves/

So what we're doing is implementing playback functionality in Processing.
the playback functions will allow the user to scrub to a point in time.
For each point in time, there will be a corresponding camera that's active.
Show this active camera in view for the selected point in time.
If you want, show the camera that also comes before and after, but show them in a different color (leading up to our "faded" look).

(Once we query time from MSB, we can collect the positions of these cameras in from MSB and map that position onto the GUI screen.)

I'll work on sketching up series of interfaces to communicate how they work together and what sort of information each holds/needs.
*/

//TODO: tie the camera data structure with tick management
public class Timeline {
  HScrollbar hs1; //scrollbar
  
  //scrollbar attributes
  public int hsXPos = 50, hsYPos = height-(height/8), hsWidth=width-100, hsHeight = 25, looseVal = 1;
  ArrayList<Tick> tickArr;
  
    
  Timeline() {
    
    hs1 = new HScrollbar(hsXPos, hsYPos, hsWidth, hsHeight, looseVal);
    
    tickArr = new ArrayList();

  }
  
  void draw() {
    fill(255);

    hs1.update();

    hs1.display();
    
    stroke(0);
    line(hsXPos, hsYPos, hsWidth+hsXPos, hsYPos);
  }
  
  //legacy code; don't use
  void addTick(float xPos){
      tickArr.add(new Tick(xPos, hsYPos));
  }
  
  void addTick(Cam c){
//      tickArr.add(new Tick());
////      tickArr.get(tickArr.size()-1).setToActive();
//      for(int i = 0; i<tickArr.size()-1; i++){
//        tickArr.get(i).setToInActive();
//      }

    tickArr.add(new Tick(hs1.getSliderPos(), hsYPos, c));
    //set the older ticks to inactive
    for(int i = 0; i<tickArr.size()-1; i++){
      tickArr.get(i).setToInActive();
    }
  }
  
  ArrayList<Tick> getTickArr(){
    return tickArr;
  }
  
  Tick getActiveTick(){
    for(int i = 0; i<tickArr.size()-1; i++)
    {
      if(tickArr.get(i).isActive()){
        return tickArr.get(i);
      }
    }
    return null;
  }
  
  void play(){
    hs1.executePlay();
  }
  
  void pause(){
    hs1.executePause();
  }
  
  
  class HScrollbar {
    public int totalTime = 120;    //the total time for the timeline.
    int swidth, sheight;    // width and height of bar
    float xpos, ypos;       // x and y position of bar
    float spos, newspos;    // x position of slider
    float sposMin, sposMax; // max and min values of slider
    int loose;              // how loose/heavy
    boolean over;           // is the mouse over the slider?
    boolean locked;
    float ratio;
    Tick prevTick, nextTick;
    long startTime;
    boolean isPlaying = false;
  
    HScrollbar (float xp, float yp, int sw, int sh, int l) {
      swidth = sw;
      sheight = sh;
      int widthtoheight = sw - sh;
      ratio = (float)sw / (float)widthtoheight;
      xpos = xp;
      ypos = yp-sheight/2;
      spos = xpos;
      newspos = spos;
      sposMin = xpos;
      sposMax = xpos + swidth - sheight;
      loose = l;
    }
  
    void update() {
      if(overEvent()) {
        over = true;
      } else {
        over = false;
      }
      
      if(mousePressed && over) {
        locked = true;
      }
      if(!mousePressed) {
        locked = false;
      }
      if(locked) {
        newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
      }
      
      if(abs(newspos - spos) > 1) {
        
        if(isPlaying){
          long estimatedTime = System.nanoTime() - startTime;
          
          if(estimatedTime/1000000000 >= 1){
            startTime = System.nanoTime();
            spos = spos + 10;
            println(spos);
          }
        
        }
        else{
          spos = spos + (newspos-spos)/loose;
        }
      }

    }
  
    float constrain(float val, float minv, float maxv) {
      return min(max(val, minv), maxv);
    }
  
    boolean overEvent() {
      if(mouseX > xpos && mouseX < xpos+swidth &&
         mouseY > ypos && mouseY < ypos+sheight) {
        return true;
      } else {
        return false;
      }
    }
  
    //displays the timeline box and the ticks.
    void display() {
      noStroke();
      fill(204);
      rect(xpos, ypos, swidth, sheight);
      if(over || locked) {
        fill(0, 0, 0);
      } else {
        fill(102, 102, 102);
      }
      rect(spos, ypos, sheight, sheight);
      
      for(int i = 0; i<tickArr.size(); i++){
        tickArr.get(i).displayTick();
      }
      
      prevTick = null;
      nextTick = null;
      
      for(int i = 0; i<tickArr.size(); i++){
        if (tickArr.get(i).getXPos() < spos){
          prevTick = tickArr.get(i);
//          prevInd = i;
        }
        else{
          break;
        }
      }
      
      for(int i = 0; i<tickArr.size(); i++){
        if (tickArr.get(i).getXPos() > spos){
          nextTick = tickArr.get(i);
//          nextInd = i;
          break;
        }
      }
      
      
      if(prevTick != null){
        prevTick.changeCamColorPrev();
      }
      if(nextTick != null){
        nextTick.changeCamColorNext();
      }

    }
    public int getPosInSeconds() {
      return (int)(((spos-50)/swidth)*totalTime);
    }
    
    public float getSliderPos(){
      return spos;
    }
    
    public void executePlay(){
      println("play");
      
      isPlaying = true;
      startTime = System.nanoTime();    
      update();
      
    }
    
    public void executePause(){
      println("pause");
      //long estimatedTime = System.nanoTime() - startTime;
      //println(estimatedTime/1000000);    //convert it to milliseconds
      isPlaying = false;
    }
    
  }
  
  
}
