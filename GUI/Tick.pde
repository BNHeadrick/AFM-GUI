
class Tick{
    
    //tick attributes
    float tickXPos, tickYPos, tickWidth, tickHeight;
    final color offCol = color(40,127,80);
    final color onCol = color(255,0,0);
    color col;
    boolean active;
    
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
    
    
}
