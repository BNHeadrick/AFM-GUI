public class CharPos extends Event{
  
  FloatBuffer fb;
  Character ch;
  
  public CharPos(FloatBuffer f, Character c, int time){
    fb = f;
    ch = c;
    timeStamp = time;
    type = CHAR_POS;
  }
  
  public String toString(){
    return "CharPos of " + timeStamp;
  }
  
  //move camera to new position
  public void execute(int time){
    println("char move executed");
    ch.setModelViewMatrix(fb);
  }
  
}
