/**
  Class that holds the timeline object and manages the scrubber and tick placements; this includes playback.
**/

//TODO: tie the camera data structure with tick management


public class Timeline {
  HScrollbar hs1; //scrollbar
  SceneManager sMan;
  int curFrame;
  //audio object
  
  
  //scrollbar attributes
  public int hsXPos = 50, hsYPos = height-(height/8), hsWidth=width-100, 
  hsHeight = 25, looseVal = 1, totalTime = 120, fps = 30, disp = 50;
  
  ArrayList<Tick> tickArr;
//  ArrayList<Event> eventArr;
  
    
  Timeline(SceneManager sManager) {

    hs1 = new HScrollbar(hsXPos, hsYPos, hsWidth, hsHeight, looseVal, disp);
    sMan = sManager;
    
    
    tickArr = new ArrayList();
//    eventArr = new ArrayList();  //TODO; EVERYTHING WITH EVENTS!

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
    tickArr.add(new Tick(hs1.getSliderPos(), hsYPos, c, hs1.getPosInSeconds()));
    //set the older ticks to inactive
    for(int i = 0; i<tickArr.size()-1; i++){
      tickArr.get(i).setToInActive();
    }
    //sort the ticks in case one was placed before an existing tick
    Collections.sort(tickArr);
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
  
  //used or scrubbing
  void setFrame(int frameNum){
    hs1.setSposWithFrame(frameNum);
  }
  
  void pause(){
    println(hs1.getSliderPos());
    hs1.executePause();
    println(hs1.getSliderPos());
  }
  
  public int getScrollbarTimeInSecs(){
    return hs1.getPosInSeconds();
  }
  
  
  class HScrollbar {
    int swidth, sheight;    // width and height of bar
    float xpos, ypos;       // x and y position of bar
    float spos, newspos;    // x position of slider
    float sposMin, sposMax; // max and min values of slider
    int loose;              // how loose/heavy
    boolean over;           // is the mouse over the slider?
    boolean locked;
    float ratio;
    Tick prevTick, nextTick, currTick;
    long startTime;
    boolean isPlaying = false;
    int displacement = 0;
  
    HScrollbar (float xp, float yp, int sw, int sh, int l, int dis) {
      displacement = dis;
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
      
      

      if(isPlaying){
        //only plays sound for dialog
        if(sMan.eventHappened(getPosInSeconds())){
          //put sound code here!!!
          sMan.peekNextEvent().execute(getPosInSeconds());
          println(sMan.popEvent());
        }
        
        //find if previous dialog should still be playing, and if so, play it
        if(sMan.getPreviousPoppedDialog(getPosInSeconds()) != null){
          sMan.getPreviousPoppedDialog(getPosInSeconds()).execute(getPosInSeconds());
//          println(sMan.getPreviousPoppedDialog(getPosInSeconds()));
        }
      }
      
      if(overSlide()) {
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

      //if the scrubber has either been moved or the timeline's play function is executing
      if(abs(newspos - spos) > 1 || isPlaying) {
        
        //if playback has collided with the end of the timeline, stop playing
        if(isPlaying){
          if(getPosInSeconds() >= totalTime){
            executePause();
          }
        }
                
        //if the timeline is playing, increment the scrubber one second at a time.
        if(isPlaying){
          long estimatedTime = System.nanoTime() - startTime;
          
          if(estimatedTime/1000000000 >= 1){
            //if one second has passed, make a new start time (reset the second timer)
            startTime = System.nanoTime();
//            println("before spos is " + spos + " time is " + getPosInSeconds());
            spos = incrementSposInSeconds();
            println("spos is " + spos + " time is " + getPosInSeconds() + " frame is " + getPosInFrames());
          }
        
        }
        //snap to nearest (previous) second
        else{
          //neive timeline placement.  Implement snapping below.
          spos = spos + (newspos-spos)/loose;

//          println(getPosInSeconds());
          int lowerLimit = (int)getPosInSeconds()-1;
          float tempPos = spos;
//          println("BEFORE WHILE: lower limit is " + lowerLimit + " if condition is " + (getPosInSeconds(tempPos)) + " spos is " +spos);
          while( getPosInSeconds((int)tempPos) > lowerLimit ){
            tempPos = tempPos-1;
//            println("lower limit is " + lowerLimit + " reduced tempPos is " + tempPos + " spos is " +spos);
          }
          //don't go below 0 seconds
          if(tempPos >displacement){
            spos = tempPos;
          }
        }
      }
      //if the timeline is NOT playing, create the queue for the events to unfold in order
      if(!isPlaying){
        sMan.createQueue(getPosInSeconds()); 
      }
//      println(getPosInSeconds());

    }
  
    float constrain(float val, float minv, float maxv) {
      return min(max(val, minv), maxv);
    }
  
    boolean overSlide() {
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
      //timeline
      rect(xpos, ypos, swidth, sheight);
      if(over || locked) {
        fill(0, 0, 0);
      } else {
        fill(102, 102, 102);
      }
      //scrubber
      //println(spos);
      rect(spos-sheight/2, ypos, sheight, sheight);
      
      for(int i = 0; i<tickArr.size(); i++){
        tickArr.get(i).displayTick();
      }
      
      prevTick = null;
      nextTick = null;
      currTick = null;
      
      for(int i = 0; i<tickArr.size(); i++){
        if (tickArr.get(i).getXPos() < spos){
          if(i>0){
            prevTick = tickArr.get(i-1);
          }
          currTick = tickArr.get(i);
        }
        else{
          break;
        }
      }
      
      for(int i = 0; i<tickArr.size(); i++){
        if (tickArr.get(i).getXPos() > spos){
          nextTick = tickArr.get(i);
          break;
        }
      }
      
      
      if(currTick != null){
        currTick.changeCamColorCurr();
      }
      if(prevTick != null){
        prevTick.changeCamColorPrev();
      }
      if(nextTick != null){
        nextTick.changeCamColorNext();
      }

    }
    
    //todo; this
//    private int incrementSposInFrames(){
//      return 0;
//    }
    
    //does this really work?  Think about the placement relative to the pixel/frame difference.
    public void setSposWithFrame(int frameNum){
      spos = fps*frameNum+displacement;
    }
    
    public int getPosInFrames(){
      return (int)(((spos-displacement)/swidth)*(totalTime))*fps;
    }
    
    public int getPosInSeconds() {
      return (int)(((spos-displacement)/swidth)*totalTime);
    }
    
    public int getPosInSeconds(float curPos){
      return (int)(((curPos-displacement)/swidth)*totalTime);
    }
    
    //EVENTUALLY REMOVE THIS FUNCTION; need to rely on incrementFrame instead
    private int incrementSposInSeconds(){
//      println(getPosInSeconds());
//      println("posInSec " + getPosInSeconds() + " swidth+50 " + (swidth+50) + " " + (1/totalTime) + " " + (1.0/totalTime)*swidth*50);
      return (int)(((((float)getPosInSeconds()+ 1.5)/(totalTime))*swidth)+displacement);
      
    }
    
    public float getSliderPos(){
      return spos;
    }
    public void setSpos(float s){
      spos = s;
    }
    
    public void executePlay(){
      println("play");
      
      isPlaying = true;
      startTime = System.nanoTime();    
      
    }
    
    public void executePause(){
      println("pause");
      isPlaying = false;
      
      //find if previous dialog audio exists, and if so, pause it.
      if(sMan.getPreviousPoppedDialog(getPosInSeconds()) != null){
        sMan.getPreviousPoppedDialog(getPosInSeconds()).pauseAudio();
      }
       
    }
    
  }
  
  
}
