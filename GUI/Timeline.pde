/**
  Class that holds the timeline object and manages the scrubber and tick placements; this includes playback.
**/

//TODO: tie the camera data structure with tick management

public class Timeline implements Constants{
  HScrollbar hs1; //scrollbar
  SceneManager sMan;
  int curFrame;
  boolean tickEdit = false;
  ControlP5 cp5;
  Textarea pacingTextarea, dialogTextarea;
  
  
  //scrollbar attributes
  public int hsXPos = 50, hsYPos = height-(height/8), hsWidth=width-100, 
  hsHeight = 25, looseVal = 1, fps = 30, disp = 50;

  
  
  ArrayList<Tick> tickArr;
//  ArrayList<Event> eventArr;
  
    
  Timeline(SceneManager sManager, ControlP5 contP5) {
    cp5 = contP5;
    hs1 = new HScrollbar(hsXPos, hsYPos, hsWidth, hsHeight, looseVal, disp);
    sMan = sManager;
    
    
    tickArr = new ArrayList();

    pacingTextarea = cp5.addTextarea("Pacing", "", 100, 590, 1050, 12);
    pacingTextarea.setColorBackground(color(0,100));
    
    
    dialogTextarea = cp5.addTextarea("dialog", "", 100, 660, 1050, 12);
    dialogTextarea.setColorBackground(color(0,100));
                  

//    pacingTextarea.setText("Lorem Ipsum is simply dummy text of the printing and typesetting");

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
    //println("is set the frame-thingie");
    hs1.setSposWithFrame(frameNum);
  }
  
  void pause(){
    //println(hs1.getSliderPos());
    hs1.executePause();
    //println(hs1.getSliderPos());
  }
  
  public int getScrollbarTimeInSecs(){
    return hs1.getPosInSeconds();
  }
  
  public void toggleTickEdit(){
    tickEdit = !tickEdit;
  }
  
  public boolean tickEditIsOn(){
    return tickEdit;
  }
  
  public int getPosInSeconds(){
    return hs1.getPosInSeconds();
  }
  
  public int getPosInFrames(){
    return hs1.getPosInFrames();
  }
  
  //this is only (and should only) be called when the tickEdit toggle is enabled.
  public Cam deleteCurrentTick(){
    Cam retCam = null;
    for(int i = 0; i<tickArr.size(); i++){
      if(tickArr.get(i).getTimeStamp() == hs1.getPosInSeconds()){
        retCam = tickArr.get(i).getCam();
        tickArr.remove(i);
        return retCam;
      }

    }
    return retCam;
    
  }
  
  public void setPacingText(String txt){
    pacingTextarea.setText(txt);
  }
  
  public void setDialogText(String txt){
    dialogTextarea.setText(txt);
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
      //println(spos);
      

      if(isPlaying){
        //only plays sound for dialog
        if(sMan.eventHappened(getPosInSeconds())){
          
          sMan.peekNextEvent().execute(getPosInSeconds());
          //println(sMan.popEvent());
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
            newspos = spos;
            println("spos is " + spos + " time is " + getPosInSeconds() + " frame is " + getPosInFrames());
          }
        
        }
        
        else{
          //snap to nearest (previous) tick
          if(tickEdit){
            
            //neive timeline placement.  Implement snapping below.
            spos = spos + (newspos-spos)/loose;
  
  //          println(getPosInSeconds());
            //get closest (previous) tick
            int lowerLimit = tickArr.get(0).getTimeStamp();
            for(int i = 0; i<tickArr.size(); i++){
              if(tickArr.get(i).getTimeStamp() < getPosInSeconds())
              lowerLimit = tickArr.get(i).getTimeStamp();
            }
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
      
      //display the ticks
      for(int i = 0; i<tickArr.size(); i++){
        tickArr.get(i).displayTick();
        tickArr.get(i).changeCamColorInvis();
        
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
    
    //mostly works; has a weird issue at a certain point.
    public void setSposWithFrame(int frameNum){
      
      //newspos = frameNum;
      //newspos = fps*frameNum+displacement;
      newspos = displacement+((frameNum*swidth)/(fps*totalTime));
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
