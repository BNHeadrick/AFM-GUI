public class CamPos extends Event{
  
  int xPos;
  int yPos;
  
  public CamPos(int x, int y, int time){
    xPos = x;
    yPos = y;
    timeStamp = time;
    type = CAM_POS;
  }
  
  public String toString(){
    return "CamPos";
  }
}
