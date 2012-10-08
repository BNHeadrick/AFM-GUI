import java.util.Iterator;
import java.util.LinkedList;
import java.util.ListIterator;
import java.util.Queue;

//this class reads in a file that contains scene information, including camera positions, character positions, and dialog timestamps.
public class SceneManager implements Constants {
  
//  LinkedList<Event> camPosList, dialogTimeList, charPosList;  //hold the permanent info
//  Queue<Event> camPosQue, dialogTimeQue, charPosQue;          //queues for execution on timeline

//that was silly; just get one event queue full of events of either campos, dialogtime, or charpos type.

  LinkedList<Event> eventList;
  Queue<Event> eventQueue;
  Iterator<Event> queueIt;
  ListIterator<Event> listIt;
  
  //debug one; eventually read from a JSON or XML file
  public SceneManager(){
    
//    camPosList = new LinkedList<Event>();
//    charPosList = new LinkedList<Event>();
//    dialogTimeList = new LinkedList<Event>();
    
    //TODO; read from input file and populate the List objects;
    //for now, just use addJunk; later use populateList() instead
    addJunk();
    //createQueue(0);

  }
  
  public void addJunk(){
    eventList = new LinkedList<Event>();
    eventList.add(new CamPos(10,10,2));
    eventList.add(new Dialog(null, 3));
    eventList.add(new CharPos(50,50,4));
    eventList.add(new CharPos(50,50,5));
    
    createQueue(0);
    
  }
  
  //TODO: everything; make it read from a file.
  public void populateList(){
  }
  //create queue based on where the timeline currently is (destroy current queue, create new queue by getting the current time and
  //finding the appropriate starting point; naive approach
  public void createQueue(int startTime){
    listIt = eventList.listIterator();
    eventQueue = new LinkedList<Event>();
    while(listIt.hasNext()){
      eventQueue.add(listIt.next());
    }
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
  
}
