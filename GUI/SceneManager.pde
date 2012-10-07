import java.util.Iterator;
import java.util.LinkedList;
import java.util.Queue;

//this class reads in a file that contains scene information, including camera positions, character positions, and dialog timestamps.
public class SceneManager implements Constants {
  
//  LinkedList<Event> camPosList, dialogTimeList, charPosList;  //hold the permanent info
//  Queue<Event> camPosQue, dialogTimeQue, charPosQue;          //queues for execution on timeline

//that was silly; just get one event queue full of events of either campos, dialogtime, or charpos type.

  LinkedList<Event> eventList;
  Queue<Event> eventQueue;
  
  //debug one; eventually read from a JSON or XML file
  public SceneManager(){
    
//    camPosList = new LinkedList<Event>();
//    charPosList = new LinkedList<Event>();
//    dialogTimeList = new LinkedList<Event>();
    
    //TODO; read from input file and populate the List objects;
    //for now, just use addJunk
    createQueues(0);
    addJunk();

  }
  
  public void addJunk(){
    eventQueue.add(new CamPos(10, 10, 10));
  }
  
  //create queue based on where the timeline currently is (destroy current queue, create new queue by getting the current time and
  //finding the appropriate starting point; naive approach
  public void createQueues(int startTime){
    eventQueue = new LinkedList<Event>();
//    camPosQue = new LinkedList<Event>();
//    charPosQue = new LinkedList<Event>();
//    dialogTimeQue = new LinkedList<Event>();

  }
  
  public boolean eventHappened(int time){
    if(eventQueue.peek().getTimeStamp() == time)
      return true;
    else
      return false;
  }
  
}
