public class Dialog extends Event{
  
  int xPos;
  int yPos;
  
  //EVENTUALLY, ASSOCIATE A SOUNDFILE FROM THE CONSTRUCTOR AS WELL!!!
  public Dialog(String sFile, int time){
    timeStamp = time;
    type = DIA_TIME;
  }
  
  public String toString(){
    return "Dialog";
  }
}
