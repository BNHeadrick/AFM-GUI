
class Tick{
    
    //tick attributes
    float tickXPos, tickYPos, tickWidth, tickHeight;
    final color offCol = color(40,127,80);
    final color onCol = color(255,0,0);
    color col;
    boolean active;
    Cam cam;
    
    //default constructor is only used for testing; do NOT use for normal use yet.
    Tick(){
      float r = random(50, width-100);
      tickXPos = r;
      tickYPos = height-(height/8);
      tickWidth = 15;
      tickHeight = tickWidth;
      active = true;
      col = onCol;
    }
    
    Tick(float tXPos, float tYPos){
      tickXPos = tXPos;
      tickYPos = tYPos;
      tickWidth = 15;
      tickHeight = tickWidth;
      col = onCol;
    }
    
    Tick(float tXPos, float tYPos, Cam c){
      this(tXPos, tYPos);
      cam = c;
      
    }
    
    void displayTick(){
      fill(col);
      ellipse(tickXPos, tickYPos, tickWidth, tickHeight);
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
      cam.changeToColor( color(100,100,100, 40));
    }
    
    void changeCamColorNext(){
      cam.changeToColor( color(0,255,10, 80));
    }
    
}
