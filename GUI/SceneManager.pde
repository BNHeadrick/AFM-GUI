/**

here's the input file stuff:

0.7f 0.0f 0.7f 0.0f 0.0f 1.0f 0.0f 0.0f 0.7f 0.0f -0.7f 0.0f 100.0f 000.0f -100.0f 1f
1.0f 0.0f 0.0f 0.0f 0.0f 1.0f 0.0f 0.0f 0.0f 0.0f 1.0f 0.0f 450.0f 000.0f -550.0f 1f
-0.7f 0.0f 0.7f 0.0f 0.0f 1.0f 0.0f 0.0f 0.7f 0.0f 0.7f 0.0f 100.0f 000.0f -550.0f 1f
1.0f 0.0f 0.0f 0.0f 0.0f 1.0f 0.0f 0.0f 0.0f 0.0f -1.0f 0.0f 450.0f 000.0f -100.0f 1f

I need to put this information into a json thingie

char info: 
1.0f 0.0f 0.0f 0.0f 0.0f 1.0f 0.0f 0.0f 0.0f 0.0f 1.0f 0.0f 240.0f 000.0f -350.0f 1f
-1.0f 0.0f 0.0f 0.0f 0.0f 1.0f 0.0f 0.0f 0.0f 0.0f -1.0f 0.0f 800.0f 000.0f -350.0f 1f

**/


import java.util.Iterator;
import java.util.LinkedList;
import java.util.ListIterator;
import java.util.Queue;

//this class reads in a file that contains scene information, including camera positions, character positions, and dialog timestamps.
public class SceneManager implements Constants {
  
  LinkedList<Event> eventList;
  Queue<Event> eventQueue;
  Iterator<Event> queueIt;
  ListIterator<Event> listIt;
  
  ArrayList<FloatBuffer> camFloatBuffers, charFloatBuffers, charMoveBuffers;
  ArrayList<Character> charArr;
  
  //debug one; eventually read from a JSON or XML file
  public SceneManager(){
    
    
    camFloatBuffers = new ArrayList<FloatBuffer>();
    float[] matrix1 = {0.7f, 0.0f, 0.7f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.7f, 0.0f, -0.7f, 0.0f, 100.0f, 000.0f, -100.0f, 1f};
    camFloatBuffers.add(FloatBuffer.wrap(matrix1));
    
    
    charFloatBuffers = new ArrayList<FloatBuffer>();
    
//    float[] matrix2 = {1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 240.0f, 000.0f, -350.0f, 1f};
    float[] matrix2 = {1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 30.0f, 000.0f, -23.8f, 1f};
    charFloatBuffers.add(FloatBuffer.wrap(matrix2));
    
//    float[] matrix3 = {1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 800.0f, 000.0f, -350.0f, 1f};
    float[] matrix3 = {1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 53.0f, 000.0f, -23.8f, 1f};
    charFloatBuffers.add(FloatBuffer.wrap(matrix3));
    
    
    
    
//    camPosList = new LinkedList<Event>();
//    charPosList = new LinkedList<Event>();
//    dialogTimeList = new LinkedList<Event>();
    
    //TODO; read from input file and populate the List objects;
    //for now, just use addJunk; later use populateList() instead
//    addJunkWithAudio(m);
//    addJunk();
    //createQueue(0);

  }
  
//  public void addJunkWithAudio(Minim mn){
//    eventList = new LinkedList<Event>();
////    eventList.add(new CamPos(10,10,2));
//
//    eventList.add(new Dialog("groove.mp3", 2, mn));
//    eventList.add(new Dialog("groove2.mp3", 3, mn));
//    
////    charMoveBuffers = new ArrayList<FloatBuffer>();
//    
//    
//    
//    
////    eventList.add(new CharPos(50,50,5));
//    
//    
//    
//  }
  
  //TODO: everything; make it read from a file.
  public void populateList(){
  }
  //create queue based on where the timeline currently is (destroy current queue, create new queue by getting the current time and
  //finding the appropriate starting point; naive approach
  public void createQueue(int startTime){
    
    
    
    listIt = eventList.listIterator();
    eventQueue = new LinkedList<Event>();
    while(listIt.hasNext()){
      Event temp = listIt.next();
      temp.reset();
      eventQueue.add(temp);
      
    }
    
    //HACKY WAY TO RESET THE CHAR POSITION AFTER IF THE SCRUBBER IS PLACED BEFORE IT'S EXECUTION AFTER IT EXECUTES
    /*
    for(int i = 0; i<charFloatBuffers.size(); i++){
      resetPos()
    }
    */
    
    
    
    
  }
  
  public boolean eventHappened(int time){
    if(eventQueue.peek() != null){
      if(eventQueue.peek().getTimeStamp() == time){
        return true;  
      }
    }
    return false;
  }
  
  public LinkedList<Event> getCurrentEvents(int time){
     return null;
  }
  
  public Event peekNextEvent(){
    return eventQueue.peek();
  }
  
  public Event popEvent(){
    return eventQueue.poll();
  }
  
  public LinkedList<Event> getEventList(){
    return eventList; 
  }
  
  public Dialog getPreviousPoppedDialog(int time){
    
    Dialog d = null;
    
    listIt = eventList.listIterator();
    while(listIt.hasNext()){
      Event temp = listIt.next();
      if(temp.getTimeStamp() > time){
        break;
      }
      if(temp.getType()==DIA_TIME){
        d=(Dialog)temp;
      }
    }
    return d;
    
  }
  
  public ArrayList<FloatBuffer> getCamFloatBuffers(){
    return camFloatBuffers;
  }
  
  public ArrayList<FloatBuffer> getCharFloatBuffers(){
    return charFloatBuffers;
  }
  
  //kinda hacky for now.  Eventually, make this take in which exact char to associate this with from the input JSON
  public void junkSetData(ArrayList<Character> chars, Minim mn){
    
    eventList = new LinkedList<Event>();
    //eventList.add(new CharPos(10,10,3));

    eventList.add(new Dialog("groove.mp3", 4, mn));
    
    //float[] matrix2 = {1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 240.0f, 000.0f, -350.0f, 1f};
    float[] matrix1 = {1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 500.0f, 000.0f, -350.0f, 1f};
//    charMoveBuffers.add(FloatBuffer.wrap(matrix1));

    eventList.add(new CharPos(FloatBuffer.wrap(matrix1), chars.get(0), 5, charFloatBuffers.get(0)));
    
    eventList.add(new Dialog("groove2.mp3", 60, mn));
    
    sm.createQueue(0);
    
  }
  
}
