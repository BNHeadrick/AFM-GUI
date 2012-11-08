/**
A tick is an event on a timeline that specifically represents a change in the selected camera for that specific time.
**/

class Tick implements Comparable{
    
    //tick attributes
    float tickXPos, tickYPos, tickWidth, tickHeight;
    final color offCol = color(40,127,80);
    final color errorCol = color(255,0,0);
    final color onCol = offCol;
    color col;
    boolean active;
    Cam cam;
    int time;
    boolean pacingViolation;
    boolean cutViolation;
    int pacingCluster;
    
    //default constructor is only used for testing; do NOT use for normal use yet.
//    Tick(){
//      float r = random(50, width-100);
//      tickXPos = r;
//      tickYPos = height-(height/8);
//      tickWidth = 15;
//      tickHeight = tickWidth;
//      active = true;
//      col = onCol;
//      
//    }
    
    Tick(float tXPos, float tYPos){
      tickXPos = tXPos;
      tickYPos = tYPos;
      tickWidth = 15;
      tickHeight = tickWidth;
      col = onCol;
      pacingViolation = false;
      cutViolation = false;
      pacingCluster = -1;
    }
    
    Tick(float tXPos, float tYPos, Cam c, int t){
      this(tXPos, tYPos);
      cam = c;
      time = t;
      
    }
    
    void displayTick(){
      fill(col);
      ellipse(tickXPos, tickYPos, tickWidth, tickHeight);
      
      //draw the arrows for all active violations
      if(pacingViolation){
        
        float x1 = tickXPos, y1=tickYPos-30, x2=tickXPos, y2=tickYPos-13;
        stroke(255);
        //float x1 = 400, y1=400, x2=800, y2=800;
        // draw the line
        line(x1, y1, x2, y2);
        pushMatrix();
        translate(x2, y2);
        float a = atan2(x1-x2, y2-y1);
        rotate(a);
        line(0, 0, -10, -10);
        line(0, 0, 10, -10);
        popMatrix();
      }
      if(cutViolation){
        float x1 = tickXPos, y1=tickYPos+30, x2=tickXPos, y2=tickYPos+13;
        stroke(255);
        //float x1 = 400, y1=400, x2=800, y2=800;
        // draw the line
        line(x1, y1, x2, y2);
        pushMatrix();
        translate(x2, y2);
        float a = atan2(x1-x2, y2-y1);
        rotate(a);
        line(0, 0, -10, -10);
        line(0, 0, 10, -10);
        popMatrix();
      }
    }
    
    float getXPos(){
      return tickXPos;
    }
    float getYPos(){
      return tickYPos;
    }
    float getWidth(){
      return tickWidth;
    }
    float getHeight(){
      return tickHeight;
    }
    
    boolean isActive(){
      return active;
    }
    
    void setToActive(){
      active = true;
      col = onCol;
    }
    
    void setToInActive(){
      active = false;
      col = offCol;
    }
    
    void toggleActive(){
      active = !active;
      if(col==onCol)
        col=offCol;
      else
        col=onCol;  
    }
    
    color getCol(){
      return col;
    }
    
    Cam getCam(){
      return cam;
    }
    
    void setCam(Cam c){
      cam = c;
    }
    
    void changeCamColor(){
      cam.changeToColor( color(100,100,100));
    }
    
    void changeCamColorPrev(){
      //keep the same color, just change opacity
      color c = cam.getColor();
      
      int r=(c>>16)&255;
      int g=(c>>8)&255;
      int b=c&255; 

//      cam.changeToColor( color(r,g,b, 10));
      cam.changeToColor( color(255, 0, 0, 255));
    }
    
    void changeCamColorCurr(){
      //keep the same color, just change opacity
      color c = cam.getColor();
      
      int r=(c>>16)&255;
      int g=(c>>8)&255;
      int b=c&255; 

//      cam.changeToColor( color(r,g,b, 100));
      cam.changeToColor( color(0, 255, 0, 255));

    }
    
    void changeCamColorNext(){
      color c = cam.getColor();
      
      int r=(c>>16)&255;
      int g=(c>>8)&255;
      int b=c&255; 
      
//      cam.changeToColor( color(r,g,b, 200));
      cam.changeToColor( color(255, 0, 255, 255));

      //below is legacy code crap
      //cam.setNextShapeActive();
      
//      cam.changeToColor( color(0,255,0, 250));
    }
    
    int getTimeStamp(){
      return time;
    }
    
    public void setPacingViolation(boolean b){
      pacingViolation = b;
      if(!b){ col = offCol;}
      else{col = errorCol;}
    }
    
    public void setPacingCluster(int n){
      pacingCluster = n;
    }
    
    public boolean getPacingViolation(){
      return pacingViolation;
    }
    
    public int getPacingCluster(){
      return pacingCluster;
    }
    
    public void setCutViolation(boolean b){
      cutViolation = b;
      if(!b){ col = offCol;}
      else{col = errorCol;}
    }
    
    public boolean getCutViolation(){
      return cutViolation;
    }
    
    public int compareTo(Object otherTick){
      if(!(otherTick instanceof Tick)){
        throw new ClassCastException("Not a valid Tick object!");
      }
      
      Tick tempTick = (Tick)otherTick;
      
      if(this.getTimeStamp() > tempTick.getTimeStamp()){
        return 1;
      }
      else if(this.getTimeStamp() < tempTick.getTimeStamp()){
        return -1;
      }
      else{
        return 0;
      }

    }
    
}
