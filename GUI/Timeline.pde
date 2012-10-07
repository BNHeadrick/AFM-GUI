/**
  Class that holds the timeline object and manages the scrubber and tick placements; this includes playback.
**/

//TODO: tie the camera data structure with tick management
public class Timeline {
  HScrollbar hs1; //scrollbar
  SceneManager sMan;
  
  //scrollbar attributes
  public int hsXPos = 50, hsYPos = height-(height/8), hsWidth=width-100, hsHeight = 25, looseVal = 1, totalTime = 120;
  ArrayList<Tick> tickArr;
//  ArrayList<Event> eventArr;
  
    
  Timeline() {
    
    hs1 = new HScrollbar(hsXPos, hsYPos, hsWidth, hsHeight, looseVal);
    sMan = new SceneManager();
    
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
    println(hs1.getSliderPos());
    hs1.executePause();
    println(hs1.getSliderPos());
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
      
      if(sMan.eventHappened(getPosInSeconds())) println("yay");
      
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

      if(abs(newspos - spos) > 1 || isPlaying) {
        
        //if playback has collided with the end of the timeline, stop playing
        if(isPlaying){
          if(getPosInSeconds() >= totalTime){
            executePause();
          }
        }
                
        if(isPlaying){
          long estimatedTime = System.nanoTime() - startTime;
          
          if(estimatedTime/1000000000 >= 1){
            //if one second has passed, make a new start time (reset the second timer)
            startTime = System.nanoTime();
//            println("before spos is " + spos + " time is " + getPosInSeconds());
            spos = incrementSposInSeconds();
            println("spos is " + spos + " time is " + getPosInSeconds());
          }
        
        }
        else{
          spos = spos + (newspos-spos)/loose;
        }
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
      rect(spos, ypos, sheight, sheight);
      
      for(int i = 0; i<tickArr.size(); i++){
        tickArr.get(i).displayTick();
      }
      
      prevTick = null;
      nextTick = null;
      
      for(int i = 0; i<tickArr.size(); i++){
        if (tickArr.get(i).getXPos() < spos){
          prevTick = tickArr.get(i);
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
    
    public int incrementSposInSeconds(){
//      println(getPosInSeconds());
//      println("posInSec " + getPosInSeconds() + " swidth+50 " + (swidth+50) + " " + (1/totalTime) + " " + (1.0/totalTime)*swidth*50);

      return (int)(((((float)getPosInSeconds()+ 1.5)/(totalTime))*swidth)+50);
      
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
      
    }
    
  }
  
  
}
