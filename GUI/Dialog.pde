import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

public class Dialog extends Event{
  
  AudioPlayer ap;
  
  //EVENTUALLY, ASSOCIATE A SOUNDFILE FROM THE CONSTRUCTOR AS WELL!!!
  public Dialog(String sFile, int time, Minim m){
    timeStamp = time;
    type = DIA_TIME;
    ap = m.loadFile("groove.mp3", 2048);
  }
  
  public String toString(){
    return "Dialog";
  }
  
  public void execute(int globalTime){
//    if(globalTime == timeStamp){
//      ap.play(0);
//    }
//    else{
//      ap.play(globalTime-timeStamp);
//    }
    ap.play(0);
  }
  
}
