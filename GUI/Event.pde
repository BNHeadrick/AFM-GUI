/**
An Event is something that occurs on the timeline that is not observable from the timeline.  They are events that are pulled in from
the scene manager, and include character movement times, dialogues, and camera positions.
**/

public class Event{
  int timeStamp;
  
  public Event(){
  }
  
  public Event(String eventType){
    
  }
  
  public int getTimeStamp(){
    return timeStamp; 
  }
  

  
}
