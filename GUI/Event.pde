/**
An Event is something that occurs on the timeline that is not observable from the timeline.  They are events that are pulled in from
the scene manager, and include character movement times, dialogues, and camera positions.
**/

public class Event implements Constants{
  int timeStamp;
  int type;
  
  public Event(){
  }
  
  public Event(String eventType){
    
  }
  
  public int getTimeStamp(){
    return timeStamp; 
  }
  
  public int getType(){
    return type; 
  }

  
}
