
import java.util.ArrayList;
import processing.opengl.*;

public int threshhold;
public class RulesChecker implements Constants{
  
  public RulesChecker(){
    threshhold = (int)(.15*totalTime);
  }
  
  public void checkLineOfAction(ArrayList<Cam> cameras, ArrayList<Character> characters, int selectedIdx) {
    if (cameras == null || cameras.isEmpty()) {
      println("No cameras in the scene!");
    }
    
    if (characters.size() != 2) {
      println("Only two characters supported for now");
     //TODO (sanjeet): Hack! Fix this once more characters are allowed
    }    
    
    Cam selectedCamera = cameras.get(selectedIdx);
    
    //TODO The characters.get results in a runtime error because there aren't currently any characters allocated in the input file.
    Character ch1 = characters.get(0);
    Character ch2 = characters.get(1);
    
    // Obtaining (x,y,z) for characters and selected camera
    PVector ch1Location = ch1.getTranslation();
    PVector ch2Location = ch2.getTranslation();
    
    line(ch1Location.x, ch1Location.y, ch1Location.z, ch2Location.x, ch2Location.y, ch2Location.z);
    
    PVector selectedCameraLocation = selectedCamera.getTranslation();
    
    // Iterate through other cameras in the scene and check for line of action rule
    for (int i=0; i<cameras.size(); i++) {
      if (i == selectedIdx) {
        continue;
      }
      PVector currCamLocation = cameras.get(i).getTranslation();
      if (!isInSameHalfPlane(selectedCameraLocation, currCamLocation, ch1Location, ch2Location)) {
        // If the Selected Camera and current camera are not in the same half plane its a violation
        cameras.get(i).setColor(255,0,0);
      }
      else{
        cameras.get(i).setColor(0,0,255);
      } 
    }
  }
  
  /**
   * Given two points p1, p2 and a line passing through a,b check whether p1 and p2 are on the same
   * side of the line. In our case a,b are characters and p1, p2 are cameras
   */
  public boolean isInSameHalfPlane(PVector p1, PVector p2, PVector a, PVector b) {
    PVector copyP1 = new PVector(p1.x, p1.y, p1.z);
    PVector copyP2 = new PVector(p2.x, p2.y, p2.z);
    PVector copyA = new PVector(a.x, a.y, a.z);
    PVector copyB = new PVector(b.x, b.y, b.z);
    copyB.sub(copyA);
    copyP1.sub(copyA);
    copyP2.sub(copyA);
    PVector p1a = copyB.cross(copyP1);
    PVector p2a = copyB.cross(copyP2);
    if (p1a.dot(p2a) > 0) {
     return true;
    } 
    return false;
  }
  
  public void checkThirtyDegreeRule(ArrayList<Cam> cameras, ArrayList<Character> characters, int selectedIdx) {
    if (cameras == null || cameras.isEmpty()) {
      println("No cameras in the scene!");
    }
    
    if (characters.size() != 2) {
      println("Only two characters supported for now");
     //TODO (sanjeet): Hack! Fix this once more characters are allowed
    }    
    
    Cam selectedCamera = cameras.get(selectedIdx);
    
    //TODO The characters.get results in a runtime error because there aren't currently any characters allocated in the input file.
    Character ch1 = characters.get(0);
    Character ch2 = characters.get(1);
    
    // Obtaining (x,y,z) for characters and selected camera
    PVector ch1Location = ch1.getTranslation();
    PVector ch2Location = ch2.getTranslation();
    PVector selectedCameraLocation = selectedCamera.getTranslation();
    
    PVector cameraPoint = new PVector();
    cameraPoint.add(selectedCameraLocation);
    for (int i=0; i<100; i++) {
      cameraPoint.add(selectedCamera.getZAxis());
    }
    PVector intersection = getTwoLinesIntersection(
      new PVector(ch1Location.x, ch1Location.z), 
      new PVector(ch2Location.x, ch2Location.z), 
      new PVector(selectedCameraLocation.x, selectedCameraLocation.z), 
      new PVector(cameraPoint.x, cameraPoint.z)); 
    
    PVector diff = PVector.sub(selectedCameraLocation, intersection);
    diff.normalize();
    FloatBuffer fb = selectedCamera.modelViewMatrix;
    float[] mat = fb.array();
    float[] fbMatrix = new float[mat.length];
    for (int i=0; i<fbMatrix.length; i++) {
      fbMatrix[i] = mat[i];
    }
    fbMatrix[0] = -diff.x;
    fbMatrix[1] = diff.y;
    fbMatrix[2] = -diff.z;
    fbMatrix[9] = diff.x;
    fbMatrix[10] = diff.y;
    fbMatrix[11] = diff.z;
    fbMatrix[13] = intersection.x;
    fbMatrix[14] = intersection.y;
    fbMatrix[15] = intersection.z;
    PMatrix3D matrix = new PMatrix3D();
    matrix.set(fbMatrix);
    matrix.transpose();
    pushMatrix();
    applyMatrix(matrix);
    rotateY(radians(30));
    line(0,0,0,0,0,1000);
    rotateY(radians(-2*30));
    line(0,0,0,0,0,1000);
    popMatrix();   
    
    for (int i=0; i<cameras.size(); i++) {
      if (i == selectedIdx) {
        continue;
      }

      if (!cameras.get(i).isInView(ch1Location) && !cameras.get(i).isInView(ch2Location)) {
        continue;
      }
      PVector currCamLocation = cameras.get(i).getTranslation();
      PVector vect1 = PVector.sub(currCamLocation, intersection);
      PVector vect2 = PVector.sub(selectedCameraLocation, intersection);
      float dotP = vect1.dot(vect2)/(vect1.mag() * vect2.mag());
      if (acos(dotP) <= PI/6) {
        cameras.get(i).setColor(255,0,0);
      } else {
        cameras.get(i).setColor(0,0,255);
      }
    }
    
  } 
  
  // 2D Line Line Seg intersection
  public PVector getTwoLinesIntersection(PVector p1, PVector p2, PVector p3, PVector p4) {
    float det = (p1.x - p2.x) * (p3.y - p4.y) - (p1.y - p2.y) * (p3.x - p4.x);
    float x = (p1.x*p2.y - p1.y*p2.x)*(p3.x - p4.x) - (p1.x - p2.x)*(p3.x*p4.y - p3.y*p4.x);
    float y = (p1.x*p2.y - p1.y*p2.x)*(p3.y - p4.y) - (p1.y - p2.y)*(p3.x*p4.y - p3.y*p4.x);
    
    float finX = x/det;
    float finY = y/det;
    //Bound the intersection point to the line segment
    if (p1.x < p2.x) {
      if (finX > p2.x) {
        finX = p2.x;
        finY = p2.y;
      } else if (finX < p1.x) {
        finX = p1.x;
        finY = p1.y;
      }
    } else if (p2.x < p1.x) {
      if (finX > p1.x) {
        finX = p1.x;
        finY = p1.y;
      } else if (finX < p2.x) {
        finX = p2.x;
        finY = p2.y;
      }    
    }
    return new PVector(finX, 0, finY);
  }
  
  public void checkCuttingOnAction(SceneManager sm, Timeline tl){
    tl.setDialogText("");
    LinkedList<Event> eList = sm.getEventList();
    ArrayList<Tick> tArr = tl.getTickArr();
    ListIterator<Event> listIt;
  
    for(int i = 0; i<tArr.size(); i++){
//      println("here");
      listIt = eList.listIterator();
      while(listIt.hasNext()){
        Event tempEvent = listIt.next();
        //check for time colisions.
//        println("event " + tempEvent.getTimeStamp() + " tick time " + tArr.get(i).getTimeStamp() + " " + tempEvent.type);
        
        if((tempEvent.getType()==DIA_TIME) && (tempEvent.getTimeStamp()==tArr.get(i).getTimeStamp())){
          println("CUTTING ON ACTION ERROR!");
          tArr.get(i).setCutViolation(true);
          tl.setDialogText("Cutting On Action Violation");
        }
        else{
          tArr.get(i).setCutViolation(false);
        }
        
      }
    }

  }
  
  //This now only checks for cameras spaced beyond the input threshhold of the total time. (var threshhold in this class)
  public void checkPacing(SceneManager sm, Timeline tl){
    ArrayList<Tick> tArr = tl.getTickArr();
    int[] delTimeArr= new int[tArr.size()-1]; 
    
    int total = 0;
//    int count = 0;
    if(tArr.size()>1){
      for(int i = 1; i<tArr.size(); i++){
        delTimeArr[i-1] = tArr.get(i).getTimeStamp()-tArr.get(i-1).getTimeStamp();
        total = total + delTimeArr[i-1];
      }
      
      //what the average would be for camera placement would be if a uniform distribution is desired.
      int average = total/(tArr.size()-1);
      //println("totalAverage is " + average + " threshhold is " + threshhold);
      
      tl.setPacingText("");
      //compare the average to the actual distribution of tick events
      /*
      for(int i = 0; i<delTimeArr.length; i++){
        if(!(delTimeArr[i] < (average+threshhold) && delTimeArr[i] > (average-threshhold)) || delTimeArr[i]<3){
          tArr.get(i+1).setPacingViolation(true);
          tl.setPacingText("Pacing Violation");
        }
        else{
          if(tArr.get(i+1).getPacingViolation()){
            tArr.get(i+1).setPacingViolation(false);
          }
        }
      }
      */
      int clusterCount=-1;
      boolean startClusterCheck = false;
      
      //search for close-together clusters of cameras
      for(int i = 0; i<delTimeArr.length; i++){
        //if something is within the threshhold to violate the pacing rule, then flag it and check for clusters.
        //if(!(delTimeArr[i] < (average+threshhold) && delTimeArr[i] > (average-threshhold)) || delTimeArr[i]<(int)(.03*totalTime)){
          //only checking for clusters, NOT spaced out ticks.
          if(!(delTimeArr[i] > (average-threshhold)) || delTimeArr[i]<(int)(.03*totalTime)){
            if(!startClusterCheck){
              clusterCount++;
              tArr.get(i).setPacingViolation(true);
              tArr.get(i+1).setPacingViolation(true);
              tl.setPacingText("Pacing Violation");
              startClusterCheck=true;
              tArr.get(i).setPacingCluster(clusterCount);
              tArr.get(i+1).setPacingCluster(clusterCount);
              //println("staring check " + i + " " + clusterCount);
            }
            else{
              //if the i+1st is in a cluster, and if the previous was not set to a cluster, ensure it was set.
              if(tArr.get(i).getPacingCluster()<0){
                tArr.get(i).setPacingCluster(clusterCount);
              }
              
              tArr.get(i+1).setPacingViolation(true);
              tArr.get(i+1).setPacingCluster(clusterCount);
              
              tl.setPacingText("Pacing Violation");
            }
          }
        
          else{
            if(tArr.get(i+1).getPacingViolation()){
              tArr.get(i+1).setPacingViolation(false);
              tArr.get(i+1).setPacingCluster(-1);
            }
            //println("stopedcheck " + i + " " + clusterCount);
            startClusterCheck = false;
          }
        }
        //print("start ");
        for(int i = 0; i<tArr.size(); i++){
          //println(tArr.get(i).getPacingCluster());
        }
        //print("end ");
      
    }
    
  }
}
