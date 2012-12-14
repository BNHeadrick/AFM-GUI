import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

public class Dialog extends Event{
  
  AudioPlayer ap;
  
  public Dialog(String sFile, int time, Minim m){
    timeStamp = time;
    type = DIA_TIME;
    ap = m.loadFile(sFile, 2048);
  }
  
  public String toString(){
    return "Dialog of " + timeStamp;
  }
  
  public void execute(int globalTime){
    if(!ap.isPlaying()){
      int playAt = (globalTime - timeStamp)*1000;
      ap.play(playAt);
      println("Sound executed: gTime is " + globalTime + " delTime is " + playAt);
    }
  }
  
  public void pauseAudio(){
    ap.pause();
  }
  

  
}
