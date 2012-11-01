public class CharPos extends Event{
  
  int xPos;
  int yPos;
  
  public CharPos(int x, int y, int time){
    xPos = x;
    yPos = y;
    timeStamp = time;
    type = CHAR_POS;
  }
  
  public String toString(){
    return "CharPos";
  }
}
