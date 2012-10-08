public class Dialog extends Event{
  
  int xPos;
  int yPos;
  
  //EVENTUALLY, ASSOCIATE A SOUNDFILE FROM THE CONSTRUCTOR AS WELL!!!
  public Dialog(String sFile, int time){
    timeStamp = time;
  }
  
  public String toString(){
    return "Dialog";
  }
}
