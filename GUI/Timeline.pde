//This class holds the timeline object as well as manage the currently active "Tick" in the application

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
  
  void addTick(float xPos){
      tickArr.add(new Tick(xPos, hsYPos));
  }
  
  void addTick(){
      tickArr.add(new Tick());
//      tickArr.get(tickArr.size()-1).setToActive();
      for(int i = 0; i<tickArr.size()-1; i++){
        tickArr.get(i).setToInActive();
      }
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
  
    HScrollbar (float xp, float yp, int sw, int sh, int l) {
      swidth = sw;
      sheight = sh;
      int widthtoheight = sw - sh;
      ratio = (float)sw / (float)widthtoheight;
      xpos = xp;
      ypos = yp-sheight/2;
      spos = xpos + swidth/2 - sheight/2;
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
        spos = spos + (newspos-spos)/loose;
      }
      
      
      //addTick(15);
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
        //println(i);
        //println(tickArr.get(i));
//        displayTick(tickArr.get(i));
        tickArr.get(i).displayTick();
      }
      
      println(getPos());
    }
  
    float getPos() {
      // Convert spos to be values between
      // 0 and the total width of the scrollbar
//      return spos * ratio;
      return spos%(hsWidth - hsXPos);
    }
    
//    void displayTick(Tick t){
////      fill(40, 127, 80);
////      ellipse(xPos, hsYPos, tickWidth, tickHeight);
//        fill(40, 127, 80);
//      ellipse(t.getXPos(), t.getYPos(), t.getWidth(), t.getHeight());
//    }
    
    
    
  }
  
  
}
