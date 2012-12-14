public class CharPos extends Event{
  
  FloatBuffer movedFB, defFB, currFB;
  Character ch;
  
  
  public CharPos(FloatBuffer f, Character c, int time, FloatBuffer def){
    movedFB = f;
    ch = c;
    timeStamp = time;
    defFB = def;
    type = CHAR_POS;
  }
  /*
  public CharPos(int x, int y, Character c, int time){
    fb = f;
    ch = c;
    timeStamp = time;
    type = CHAR_POS;
  }
  */
  
  public String toString(){
    return "CharPos of " + timeStamp;
  }
  
  //move camera to new position
  public void execute(int time){
    println("char move executed");
    ch.setModelViewMatrix(movedFB);
  }
  
  public void setToPos(FloatBuffer fBuff){
    ch.setModelViewMatrix(fBuff);
  }
  
  public void reset(){
    ch.setModelViewMatrix(defFB);
  }
  
}
