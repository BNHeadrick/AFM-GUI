import processing.core.*; 
import processing.xml.*; 

import ddf.minim.*; 
import ddf.minim.signals.*; 
import ddf.minim.analysis.*; 
import ddf.minim.effects.*; 
import controlP5.*; 
import Jama.*; 
import javax.media.opengl.*; 
import processing.opengl.*; 
import java.nio.FloatBuffer; 
import java.util.ArrayList; 
import oscP5.*; 
import controlP5.*; 
import picking.*; 
import java.nio.FloatBuffer; 
import Jama.*; 
import Jama.*; 
import java.nio.FloatBuffer; 
import Jama.*; 
import controlP5.*; 
import ddf.minim.*; 
import ddf.minim.signals.*; 
import ddf.minim.analysis.*; 
import ddf.minim.effects.*; 
import java.util.ArrayList; 
import processing.opengl.*; 
import java.util.Iterator; 
import java.util.LinkedList; 
import java.util.ListIterator; 
import java.util.Queue; 

import Jama.util.*; 
import controlP5.*; 
import Jama.*; 
import picking.*; 
import oscP5.*; 
import netP5.*; 
import Jama.test.*; 
import Jama.examples.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class GUI extends PApplet {

















ControlP5 controlP5;
DropdownList ruleChoiceList;
GL gl;
//Picker camPicker, charPicker;
Picker picker;
int bGround = color(70, 70, 70);
int prevID;
ArrayList<Cam> cameras = new ArrayList<Cam>(); // List of Cameras
ArrayList<Character> characters = new ArrayList<Character>(); // List of Characters
OscP5 oscP5;
//int port = 31842; AG - changed port to match KinectFingerTracking
int port = 31842;
NetAddress interfaceAddr;
String[] lines;
int selectedRule;
int selectedCamera;

float globalCameraX = 0;
float globalCameraY = 0;//-200;
float globalCameraZ = 0;

int winHeight = 720, winWidth = 1280;

RulesChecker rulesChecker;
Timeline timeline;
SceneManager sm;

Debug debug;
Minim minim;


// current frame of the scene - set by KinectFingerTracker
int currentFrame;

public void setup() {
  minim = new Minim(this);
  size(winWidth, winHeight, OPENGL);
  background(bGround);
  sm = new SceneManager(minim);
  rulesChecker = new RulesChecker();

  controlP5 = new ControlP5(this);
  //ruleChoiceList = controlP5.addDropdownList("ruleChoiceList",850,100,100,100);
  //customize(ruleChoiceList);
  selectedRule = 0;
  selectedCamera=0;
  gl = ((PGraphicsOpenGL)g).gl;

  picker = new Picker(this);
  oscP5 = new OscP5(this, port);
  // TODO(sanjeet): Change the address
  interfaceAddr = new NetAddress("127.0.0.1", port);

  noStroke();
  lines = loadStrings("fileFriedrich.txt"); // Hardcoded input file name
  String[] tokens = split(lines[0], " ");
  if (tokens.length != 1) {
    println("Incorrect file format for number of cameras");
    return;
  }
  int numOfCams = PApplet.parseInt(tokens[0]);
  for (int i=1; i<numOfCams+1; i++) {

    tokens = split(lines[i], " ");
    float[] matrix = new float[16];
    for (int j=0; j<tokens.length; j++) {
      matrix[j] = PApplet.parseFloat(tokens[j]);
    }

    cameras.add(new Cam(FloatBuffer.wrap(matrix))); // add all the cameras
  }

  tokens = split(lines[1 + numOfCams], " ");
  if (tokens.length != 1) {
    println("Incorrect file format for number of characters");
    return;
  }
  int numOfChars = PApplet.parseInt(tokens[0]);
  for (int i= 2 + numOfCams; i<lines.length; i++) {
    tokens = split(lines[i], " ");
    float[] matrix = new float[16];
    for (int j=0; j<tokens.length; j++) {
      matrix[j] = PApplet.parseFloat(tokens[j]);
    }

    characters.add(new Character(FloatBuffer.wrap(matrix))); // add all the characters
  }

    characters.get(0).col=color(255,255,0);
    characters.get(1).col=color(255,0,255);
    
    timeline = new Timeline(sm);
    //add initial tick to the begining of the timeline
    timeline.addTick(cameras.get(0));
    
    debug = new Debug(controlP5);
    
    //title, start, end, initVal, xpos, ypos, width, height
    //controlP5.addSlider("Timeline", 0,120,0,100,winHeight-50,winWidth-200,30);

}

public void draw() { // display things

  //execute sceneManager stuff
  resetMatrix();
  //beginCamera();
  camera();
  rotateX(HALF_PI);
  translate(globalCameraX, globalCameraY, globalCameraZ);


  /* rotation using a and d
   PMatrix3D foRealCameraMatrix=new PMatrix3D();
   getMatrix(foRealCameraMatrix);
   */
  //translate(0,-100, -400 );
  //translate(0,0, 0 );
  //rotate(sin(millis() * 0.001), 1,0,0);

  background(bGround);

  for (int i=0; i<cameras.size(); i++) {
    //    camPicker.start(i);  //add picker to each cam
    picker.start(i);
    cameras.get(i).display();
  }
  //  camPicker.stop();



  for (int i=cameras.size(); i<cameras.size()+characters.size(); i++) {
    //    charPicker.start(i);
    picker.start(i);
    characters.get(i-cameras.size()).display();
  }
  //  charPicker.stop();
  picker.stop();


  //endCamera();

  //  int id = camPicker.get(mouseX, mouseY);
  //  if (id > -1) {
  //    for (int i=0; i<cameras.size(); i++) {
  //      if (i == id) {
  //        cameras.get(id).changeToSelectedColor();
  //        cameras.get(id).isSelected = true;
  //      } else {
  //        cameras.get(i).setDefaultColor();
  //        cameras.get(i).isSelected = false;        
  //      }
  //    }
  //  }

  //checks for rule violations
  int id = -1;
  for (int i = 0; i<cameras.size(); i++) {
    if (cameras.get(i).isSelected) {
      if (selectedRule==0)
        rulesChecker.checkLineOfAction(cameras, characters, i);
      else if (selectedRule == 1)
        rulesChecker.checkThirtyDegreeRule(cameras, characters, i);
      else
        resetAllCams();
    }
  }
  
  rulesChecker.checkCuttingOnAction(sm, timeline);
  rulesChecker.checkPacing(sm, timeline);

  /* This is for camera rotation using a and d
   resetMatrix();
   pushMatrix();
   setMatrix(myCamera);
   rotate(angle);
   getMatrix();
   popMatrix;
   */

  //have to rotate back to original orientation in order to properly display the drop-down menu

  rotateX(PI);
  rotateX(HALF_PI);

  controlP5.draw();
  timeline.draw();
  
}

//used for debugging
public void resetAllCams() {
  for (int i = 0; i<cameras.size(); i++) {
    cameras.get(i).setDefaultColor();
  }
}

public void mouseClicked() {

  //  int id = camPicker.get(mouseX, mouseY);
  int id = picker.get(mouseX, mouseY);
  if (id > -1) {
    for (int i=0; i<cameras.size(); i++) {
      if (i == id) {
        cameras.get(id).changeToSelectedColor();
        cameras.get(id).isSelected = true;
      } 
      else {
        cameras.get(i).setDefaultColor();
        cameras.get(i).isSelected = false;
      }
    }
  }
}

public void mouseDragged() {

  //  int id = camPicker.get(mouseX, mouseY);
  int id = picker.get(mouseX, mouseY);
  /*
  //keep objects from being selected while dragging other objects; DOESN'T FIX ANYTHING YET
   if(id > -1 && id == prevID){
   //    cameras.get(id).changeToDragColor();
   println("indragged same");
   cameras.get(id).drag(mouseX, mouseY);
   }
   */
  if (id > -1) {
    for (int i=0; i<cameras.size(); i++) {
      if (i == id) {
        //        println("indragged diff " + " x is " + mouseX + " y is " + mouseY);
        //cameras.get(id).changeToDragColor();
        cameras.get(id).drag(mouseX, mouseY);
        prevID = id;
        break;
      }
    }

    //    int id = camPicker.get(mouseX, mouseY);

    for (int i=cameras.size(); i<cameras.size()+characters.size(); i++) {
      //        println(i + " hi " + " camSize is " + cameras.size() + " charSize is" + characters.size() + " both together are " + cameras.size() + characters.size());
      if (i == id) {
        //          characters.get(id).changeToDragColor();

        characters.get(id - cameras.size()).drag(mouseX, mouseY);
        //          println("char is " + id);
        break;
      }
    }
  }
}

/*
 * Q - Up, E - Down, A - Left, D - Right, W - Forward, S - Backward
 */
public void keyPressed() {
  if (key == 'q' || key == 'Q') {
    globalCameraY --;
  } 
  if (key == 'e' || key == 'E') {
    globalCameraY ++;
  }
  if (key == 'w' || key == 'W') {
    globalCameraZ --;
  }
  if (key == 'a' || key == 'A') {
    globalCameraX ++;
  }
  if (key == 's' || key == 'S') {
    globalCameraZ ++;
  }
  if (key == 'd' || key == 'D') {
    globalCameraX --;
  }
  if (key == ' ') {
    if (selectedRule == 0)
      selectedRule =1;
    else
      selectedRule =0;
  }
  if (key == 't' || key == 'T') {
    //if a camera is active, add tick
    for(int i =0; i<cameras.size(); i++){
      if(cameras.get(i).camIsSelected()){
        
        //need to find which tick is before/after the one that would be placed here
        //TODO above
        timeline.addTick(cameras.get(i));
      }
    }
  }
  if (key == 'l' || key == 'L') {
    timeline.play();
  }
  if (key == 'p' || key == 'P') {
    timeline.pause();
  }
}

/*
void mouseReleased(){
 int id = camPicker.get(mouseX, mouseY);
 if (id > -1) {
 for (int i=0; i<cameras.size(); i++) {
 if (i == id) {
 cameras.get(id).changeToDefaultColor();
 }
 }
 }
 
 id = charPicker.get(mouseX, mouseY);
 if (id > -1) {
 for (int i=0; i<characters.size(); i++) {
 if (i == id) {
 characters.get(id).changeToDefaultColor();
 }
 }
 }
 
 }
 */

/*
 * Method used to receive messages from Kinnect or MSB in the future
 */
public void oscEvent(OscMessage theOscMessage) {

  //Friedrich added this select camera event
  if (theOscMessage != null && theOscMessage.checkAddrPattern("/selectActorByName")) {
    println("select Actor!");
    String myNewCamera=theOscMessage.get(0).stringValue();

    println(myNewCamera);

    //RAFACTOR THIS PART; MAYBE MAKE A DYNAMIC ENUM IN THE CAM DATA STRUCTURE?
    if (myNewCamera.compareTo("Camera1")==0)
      selectedCamera=0;
    if (myNewCamera.compareTo("Camera2")==0)
      selectedCamera=1;
    if (myNewCamera.compareTo("Camera3")==0)
      selectedCamera=2;
    if (myNewCamera.compareTo("Camera4")==0)
      selectedCamera=3;

    //Friedrich changed the coloring code here    
    for (int i=0; i<cameras.size(); i++) {
      cameras.get(i).changeToDefaultColor();
      cameras.get(i).isSelected = false;
    }

    cameras.get(selectedCamera).isSelected = true; 
    cameras.get(selectedCamera).changeToSelectedColor();
//    println(""  + timeline.getTickArr());
    timeline.getActiveTick().setCam(cameras.get(selectedCamera));
  }

  //Friedrich changed the AddressPattern for the submitted package - we can ignore the first string part of the message
  if (theOscMessage != null && theOscMessage.checkAddrPattern("/setPropertyForSelected/string/matrix4f")) {
    float[] matrix = new float[16];

    //we do not need to use this in Processing, but let's pop it off the stack anyway
    String propertyName = theOscMessage.get(0).stringValue();

    for (int i=1; i<=16; i++) {
      if (i > 12 && i <= 15) {
        matrix[i-1] = theOscMessage.get(i).floatValue() * 10;
      } 
      else {
        matrix[i-1] = theOscMessage.get(i).floatValue();
      }
    }

    matrix[2]=-matrix[2];
    matrix[8]=-matrix[8];
    
    //Friedrich - manual scaling adjustments
    matrix[12]=(700-matrix[12])*2.0f;
    matrix[14]=matrix[14] * 1.5f;
    //println (matrix[12]);

    FloatBuffer fb = FloatBuffer.allocate(16);
    fb = FloatBuffer.wrap(matrix);
    // TODO(sanjeet): Currently using only camera 5
    // Change this variable based on the data received from OSC
    //    int selectedCamera = 5;
    cameras.get(selectedCamera).modelViewMatrix = fb;
  }
  
  // receive the currentFrame from kinect
  // this is where the playhead is on the timeline
  // currentFrame is global
   if (theOscMessage != null && theOscMessage.checkAddrPattern("/setPlayheadFrame/int")) {
   currentFrame = theOscMessage.get(0).intValue();
    println("Current Frame: " + currentFrame);
  }
}

public void customize(DropdownList ddl) {
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(15);
  ddl.captionLabel().set("pulldown");
  ddl.captionLabel().style().marginTop = 3;
  ddl.captionLabel().style().marginLeft = 3;
  ddl.valueLabel().style().marginTop = 3;
  //  for(int i=0;i<2;i++) {
  ddl.addItem("180 deg", 0);
  ddl.addItem("30 deg", 1);
  //  }
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}

public void controlEvent(ControlEvent theEvent) {
  // PulldownMenu is if type ControlGroup.
  // A controlEvent will be triggered from within the ControlGroup.
  // therefore you need to check the originator of the Event with
  // if (theEvent.isGroup())
  // to avoid an error message from controlP5.
  if (theEvent.isGroup()) {
    if (theEvent.group().name() == "ruleChoiceList") {
      //    println(theEvent.group().value()+" from "+theEvent.group());
      selectedRule = PApplet.parseInt(theEvent.group().value());
      //has to be here for the controlp5 library
    }
  } 
  else if (theEvent.isController()) {
    //    println(theEvent.controller().value()+" from "+theEvent.controller());
  }
 


  //  switch(theEvent.controller().id()) {
  //    case(1):
  //    myColorRect = (int)(theEvent.controller().value());
  //    break;
  //    case(2):
  //    myColorBackground = (int)(theEvent.controller().value());
  //    break;
  //    case(3):
  //    println(theEvent.controller().stringValue());
  //    break;  
  //  }
  
}

public void slider(float theColor) {
  //myColor = color(theColor);
  //println("a slider event. setting background to "+theColor);
}


//



class Cam { 

  float fov = 45;    //what primative/data structure works for this?
  //Matrix loc;
  ;
  //Matrix rot;
  int col, defaultCol = color(0, 0, 255), badCol = color(255, 0, 0), 
  draggedCol = color(0, 0, 0), selectedCol = color(255, 255, 255);
  FloatBuffer modelViewMatrix = FloatBuffer.allocate(16);
  boolean isSelected;
  int boxScale = 40;
  boolean isNext = false;
  

  //testing default constructor
  Cam() { 
    col = defaultCol;
//    loc = new Matrix(4, 4);
//    rot = new Matrix(4, 4);
  }

//  Cam(float fov, Matrix loc, Matrix rot, color col) { 
//
//    this.fov = fov;
//    this.loc = loc;
//    this.rot = rot;
//    this.col = col;
//  }

  Cam(FloatBuffer modelViewMatrix) {
    this.modelViewMatrix = modelViewMatrix;
    col = defaultCol;
  }

  public PVector getTranslation() {
    if (this.modelViewMatrix == null) {
      println("Model View Matrix is corrupted");
      return null;
    }
    float[] arr = this.modelViewMatrix.array();
    if (arr.length != 16) {
      println("Model View Matrix is corrupted");
      return null;
    }
    float[] translation = new float[3];
    return new PVector(arr[12], arr[13], arr[14]);
  }
  
  public PVector getZAxis() {
    if (this.modelViewMatrix == null) {
      println("Model View Matrix is corrupted");
      return null;
    }
    float[] arr = this.modelViewMatrix.array();
    if (arr.length != 16) {
      println("Model View Matrix is corrupted");
      return null;
    }
    return new PVector(arr[8], arr[9], arr[10]);    
  }
  
  public float getFOV() {
    return fov;
  }

  public void setColor(int r, int g, int b) {
    this.col = color(r, g, b);
  }
  
  public int getColor(){
    return col; 
  }
  
  public void display() {


    pushMatrix();
    
//    println("Yo! Camera!");
//    printCamera(); 
//
//    println("BAH! Modelview!");
//    printMatrix();

    stroke(0);
    //    lights();
    //    translate(160, 160, 0);
    float[] matrix = modelViewMatrix.array();

    //translate(matrix[12], matrix[13], matrix[14]);
    //rotateY(acos(matrix[0]));
    //rotateX(asin(matrix[1]));
    PMatrix3D myMatrix;
    myMatrix=new PMatrix3D();
    myMatrix.set(matrix);
    /*
    println("GAA! Transform Matrix");
     for (int i=0;i<16;i++){
     print(matrix[i]);
     print (" ");
     if ((i+1)%4==0)
     println("");
     }
     println("");
     */
    myMatrix.transpose();
    applyMatrix(myMatrix);  
    /* a and d stuff            
     println("HRMPF! DrawPosition");
     printMatrix();
     //rotAngle should be 0 and grow by pressing a and shrink by pressing d
     rotateY(rotAngle);
     
     PMatrix3D anotherMatrix=new PMatrix3D();
     getMatrix(anotherMatrix);
     
     //actually new global transformation for your camera:
     globalTransform = anotherMatrix * foRealCameraMatrix.invert();
     */
    line(0, 0, 0, 0, 0, 100);
    fill(col);
    box(boxScale);

    if (isSelected) {
      rotateY(radians(fov));
      line(0, 0, 0, 0, 0, 1000);
      rotateY(radians(-2*fov));
      line(0, 0, 0, 0, 0, 1000);
    }
    if(false){
//      float[] matrix1 = modelViewMatrix.array();
      fill(color(255, 0, 255));
      ellipse(matrix[12], -matrix[14], 20, 20);
    }
    popMatrix();
  }

  public void setDefaultColor() {
    col = defaultCol;
  }

  public void changeToSelectedColor() {
    /*col = color(
     int(random(0, 255)),
     int(random(0, 255)),
     int(random(0, 255))
     );
     */
    col = color(255, 255, 255);
  }

  public void changeToDragColor() {
    col = color(0, 0, 0);
  }

  public void changeToDefaultColor() {
    col = color(0, 0, 0);
  }
  public void drag(int x, int y) {
    float[] matrix = modelViewMatrix.array();
    //println(matrix[12] + " " + matrix[13] + " " + matrix[14] + " " );
    matrix[12] = x;
    matrix[14] = -y;
    //println(matrix[12] + " " + matrix[13] + " " + matrix[14] + " " );
  }
  
  public boolean isInView(PVector vect) {
    PVector z = getZAxis();
    PVector v1 = PVector.sub(vect, getTranslation());
    float dotP = PVector.dot(v1, z)/(z.mag() * v1.mag());
    if ((acos(dotP) * 180/PI) <= fov) {
      return true;
    }
    return false;
  }
  
  public boolean camIsSelected(){
    return isSelected;
  }
  
  public void changeToColor(int c){
    col = c;
  }
  
  public void setNextShapeActive(){
    
    isNext = true;
  }
  
}

public class CamPos extends Event{
  
  int xPos;
  int yPos;
  
  public CamPos(int x, int y, int time){
    xPos = x;
    yPos = y;
    timeStamp = time;
    type = CAM_POS;
  }
  
  public String toString(){
    return "CamPos";
  }
}
public class CharPos extends Event{
  
  int xPos;
  int yPos;
  
  public CharPos(int x, int y, int time){
    xPos = x;
    yPos = y;
    timeStamp = time;
    type = CHAR_POS;
  }
  
  public String toString(){
    return "CharPos";
  }
}




class Character { 
  
  float fov = 45;    //what primative/data structure works for this?
//  Matrix loc;;
//  Matrix rot;
  int col, defaultCol = color(0,255,0), badCol = color(255, 0, 0), 
  draggedCol = color(0,0,0), selectedCol = color(255,255,255);
  FloatBuffer modelViewMatrix = FloatBuffer.allocate(16);
  boolean isSelected;

  //testing default constructor
  Character() { 
    col = defaultCol;
//    loc = new Matrix(4,4);
//    rot = new Matrix(4,4);
  }
  
//  Character(float fov, Matrix loc, Matrix rot, color col) { 
//    
//    this.fov = fov;
//    this.loc = loc;
//    this.rot = rot;
//    this.col = col;
//  }

  Character(FloatBuffer modelViewMatrix) {
    this.modelViewMatrix = modelViewMatrix;
    col = defaultCol;
  }

  public PVector getTranslation() {
    if (this.modelViewMatrix == null) {
      println("Model View Matrix is corrupted");
      return null;
    }
    float[] arr = this.modelViewMatrix.array();
    if (arr.length != 16) {
      println("Model View Matrix is corrupted");
      return null;
    }
    float[] translation = new float[3];
    return new PVector(arr[12], arr[13], arr[14]);
  }

  public float getFOV() {
    return fov;
  }

  public void display() {
    /*
    pushMatrix();

    noStroke();

    float[] matrix = modelViewMatrix.array();
    translate(matrix[3], matrix[7], 0);
    rotateZ(matrix[0]);
    fill(col);
    sphere(30);

    stroke(0);
    line(0, 0, 0, 0, 50, 0);
    popMatrix();
    */
    pushMatrix();
    
    noStroke();
    float[] matrix = modelViewMatrix.array();
    
    translate(matrix[12], matrix[13], matrix[14]);
    rotateY(acos(matrix[0]));
    
    fill(col);
    sphere(30);

    stroke(0);
    //line(0, 0, 0, 0, 0, 50);
    popMatrix();
    
  }

  public void changeToDragColor(){
    col = color(0, 0, 0);
  }
  
  public void changeToDefaultColor(){
    col = defaultCol;
  }
  
  public void drag(int x, int y){
    float[] matrix = modelViewMatrix.array();
    matrix[12] = x;
    matrix[14] = -y;
  }
}
interface Constants{
  public final int CHAR_POS = 0;
  public final int CAM_POS = 1;
  public final int DIA_TIME = 2;
}


class DataManager {
  ArrayList<Cam> cameras;
  ArrayList<Character> characters;
  
  public DataManager(String fileName) {
    String[] lines = new String[0];
//    lines = loadStrings('file1.txt');
    for (int i=0; i<lines.length; i++) {
      println(lines[i]);
    }
  }
}



public class Debug{

  ControlP5 cp5;
  
  Debug(){
  }
  
  Debug(ControlP5 c){
    cp5 = c;
    
    //cp5.addButton("addCam");
    
    
  }
  
//  public void play(int theValue) {
//    println("a button event from buttonB: "+theValue);
//
//  }

  


//tickArr.add(new Tick(150, hsYPos));
  
}







public class Dialog extends Event{
  
  AudioPlayer ap;
  
  //EVENTUALLY, ASSOCIATE A SOUNDFILE FROM THE CONSTRUCTOR AS WELL!!!
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
      int playAt = globalTime - timeStamp;
      ap.play(playAt);
      println("gTime is " + globalTime + " delTime is " + playAt);
    }
  }
  
  public void pauseAudio(){
    ap.pause();
  }
  
}
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
  
  public void execute(int time){
    
  }

  
}



public class RulesChecker implements Constants{
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
        }
        else{
          tArr.get(i).setCutViolation(false);
        }
        
      }
    }

  }
  
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
      
      println("current sscrubber is at time " + tl.getScrollbarTimeInSecs() );
      println("totalTime is " + total);
      
      int average = total/(tArr.size()-1);
      println("totalAverage is " + average);
      
      //compare the average to the actual distribution of tick events
      for(int i = 0; i<delTimeArr.length; i++){
        if(!(delTimeArr[i] < (average+20) && delTimeArr[i] > (average-20)) || delTimeArr[i]<3){
          tArr.get(i+1).setPacingViolation(true);
        }
        else{
          if(tArr.get(i+1).getPacingViolation()){
            tArr.get(i+1).setPacingViolation(false);
          }
        }
      }
      
    }
    
  }
}
/**

here's the input file stuff:

0.7f 0.0f 0.7f 0.0f 0.0f 1.0f 0.0f 0.0f 0.7f 0.0f -0.7f 0.0f 100.0f 000.0f -100.0f 1f
1.0f 0.0f 0.0f 0.0f 0.0f 1.0f 0.0f 0.0f 0.0f 0.0f 1.0f 0.0f 450.0f 000.0f -550.0f 1f
-0.7f 0.0f 0.7f 0.0f 0.0f 1.0f 0.0f 0.0f 0.7f 0.0f 0.7f 0.0f 100.0f 000.0f -550.0f 1f
1.0f 0.0f 0.0f 0.0f 0.0f 1.0f 0.0f 0.0f 0.0f 0.0f -1.0f 0.0f 450.0f 000.0f -100.0f 1f

I need to put this information into 

**/







//this class reads in a file that contains scene information, including camera positions, character positions, and dialog timestamps.
public class SceneManager implements Constants {
  
  LinkedList<Event> eventList;
  Queue<Event> eventQueue;
  Iterator<Event> queueIt;
  ListIterator<Event> listIt;
  
  //debug one; eventually read from a JSON or XML file
  public SceneManager(Minim m){
    
//    camPosList = new LinkedList<Event>();
//    charPosList = new LinkedList<Event>();
//    dialogTimeList = new LinkedList<Event>();
    
    //TODO; read from input file and populate the List objects;
    //for now, just use addJunk; later use populateList() instead
    addJunkWithAudio(m);
//    addJunk();
    //createQueue(0);

  }
  
  //LEGACY DON'T USE!
  public void addJunk(){
//    eventList = new LinkedList<Event>();
//    eventList.add(new CamPos(10,10,2));
//    eventList.add(new Dialog(null, 3));
//    eventList.add(new Dialog("groove.mp3", 50));
//    eventList.add(new CharPos(50,50,4));
//    eventList.add(new CharPos(50,50,5));
//    
//    createQueue(0);
    
  }
  public void addJunkWithAudio(Minim mn){
    eventList = new LinkedList<Event>();
    eventList.add(new CamPos(10,10,2));
    
    eventList.add(new Dialog("groove.mp3", 2, mn));
    
    eventList.add(new Dialog("groove2.mp3", 60, mn));
    
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
  
}
/**
A tick is an event on a timeline that specifically represents a change in the selected camera for that specific time.
**/

class Tick implements Comparable{
    
    //tick attributes
    float tickXPos, tickYPos, tickWidth, tickHeight;
    final int offCol = color(40,127,80);
    final int errorCol = color(255,0,0);
    final int onCol = offCol;
    int col;
    boolean active;
    Cam cam;
    int time;
    boolean pacingViolation;
    boolean cutViolation;
    
    //default constructor is only used for testing; do NOT use for normal use yet.
    Tick(){
      float r = random(50, width-100);
      tickXPos = r;
      tickYPos = height-(height/8);
      tickWidth = 15;
      tickHeight = tickWidth;
      active = true;
      col = onCol;
      pacingViolation = false;
      cutViolation = false;
    }
    
    Tick(float tXPos, float tYPos){
      tickXPos = tXPos;
      tickYPos = tYPos;
      tickWidth = 15;
      tickHeight = tickWidth;
      col = onCol;
    }
    
    Tick(float tXPos, float tYPos, Cam c, int t){
      this(tXPos, tYPos);
      cam = c;
      time = t;
    }
    
    public void displayTick(){
      fill(col);
      ellipse(tickXPos, tickYPos, tickWidth, tickHeight);
    }
    
    public float getXPos(){
      return tickXPos;
    }
    public float getYPos(){
      return tickYPos;
    }
    public float getWidth(){
      return tickWidth;
    }
    public float getHeight(){
      return tickHeight;
    }
    
    public boolean isActive(){
      return active;
    }
    
    public void setToActive(){
      active = true;
      col = onCol;
    }
    
    public void setToInActive(){
      active = false;
      col = offCol;
    }
    
    public void toggleActive(){
      active = !active;
      if(col==onCol)
        col=offCol;
      else
        col=onCol;  
    }
    
    public int getCol(){
      return col;
    }
    
    public Cam getCam(){
      return cam;
    }
    
    public void setCam(Cam c){
      cam = c;
    }
    
    public void changeCamColor(){
      cam.changeToColor( color(100,100,100));
    }
    
    public void changeCamColorPrev(){
      //keep the same color, just change opacity
      int c = cam.getColor();
      
      int r=(c>>16)&255;
      int g=(c>>8)&255;
      int b=c&255; 

      cam.changeToColor( color(r,g,b, 40));
    }
    
    public void changeCamColorNext(){
      //keep the same color, just change opacity
      int c = cam.getColor();
      
      int r=(c>>16)&255;
      int g=(c>>8)&255;
      int b=c&255; 
      
      cam.changeToColor( color(r,g,b));
      cam.setNextShapeActive();
    }
    
    public int getTimeStamp(){
      return time;
    }
    
    public void setPacingViolation(boolean b){
      pacingViolation = b;
      if(!b){ col = offCol;}
      else{col = errorCol;}
    }
    
    public boolean getPacingViolation(){
      return pacingViolation;
    }
    
    public void setCutViolation(boolean b){
      cutViolation = b;
      if(!b){ col = offCol;}
      else{col = errorCol;}
    }
    
    public boolean getCutViolation(){
      return cutViolation;
    }
    
    public int compareTo(Object otherTick){
      if(!(otherTick instanceof Tick)){
        throw new ClassCastException("Not a valid Tick object!");
      }
      
      Tick tempTick = (Tick)otherTick;
      
      if(this.getTimeStamp() > tempTick.getTimeStamp()){
        return 1;
      }
      else if(this.getTimeStamp() < tempTick.getTimeStamp()){
        return -1;
      }
      else{
        return 0;
      }

    }
    
}
/**
  Class that holds the timeline object and manages the scrubber and tick placements; this includes playback.
**/

//TODO: tie the camera data structure with tick management


public class Timeline {
  HScrollbar hs1; //scrollbar
  SceneManager sMan;
  int curFrame;
  //audio object
  
  
  //scrollbar attributes
  public int hsXPos = 50, hsYPos = height-(height/8), hsWidth=width-100, 
  hsHeight = 25, looseVal = 1, totalTime = 120, fps = 30, disp = 50;
  
  ArrayList<Tick> tickArr;
//  ArrayList<Event> eventArr;
  
    
  Timeline(SceneManager sManager) {

    hs1 = new HScrollbar(hsXPos, hsYPos, hsWidth, hsHeight, looseVal, disp);
    sMan = sManager;
    
    
    tickArr = new ArrayList();
//    eventArr = new ArrayList();  //TODO; EVERYTHING WITH EVENTS!

  }
  
  public void draw() {
    fill(255);

    hs1.update();

    hs1.display();
    
    stroke(0);
    line(hsXPos, hsYPos, hsWidth+hsXPos, hsYPos);
  }
  
  //legacy code; don't use
  public void addTick(float xPos){
      tickArr.add(new Tick(xPos, hsYPos));
  }
  
  public void addTick(Cam c){
    tickArr.add(new Tick(hs1.getSliderPos(), hsYPos, c, hs1.getPosInSeconds()));
    //set the older ticks to inactive
    for(int i = 0; i<tickArr.size()-1; i++){
      tickArr.get(i).setToInActive();
    }
    //sort the ticks in case one was placed before an existing tick
    Collections.sort(tickArr);
  }
  
  public ArrayList<Tick> getTickArr(){
    return tickArr;
  }
  
  public Tick getActiveTick(){
    for(int i = 0; i<tickArr.size()-1; i++)
    {
      if(tickArr.get(i).isActive()){
        return tickArr.get(i);
      }
    }
    return null;
  }
  
  public void play(){
    hs1.executePlay();
  }
  
  //used or scrubbing
  public void setFrame(int frameNum){
    hs1.setSposWithFrame(frameNum);
  }
  
  public void pause(){
    println(hs1.getSliderPos());
    hs1.executePause();
    println(hs1.getSliderPos());
  }
  
  public int getScrollbarTimeInSecs(){
    return hs1.getPosInSeconds();
  }
  
  
  class HScrollbar {
    int swidth, sheight;    // width and height of bar
    float xpos, ypos;       // x and y position of bar
    float spos, newspos;    // x position of slider
    float sposMin, sposMax; // max and min values of slider
    int loose;              // how loose/heavy
    boolean over;           // is the mouse over the slider?
    boolean locked;
    float ratio;
    Tick prevTick, nextTick;
    long startTime;
    boolean isPlaying = false;
    int displacement = 0;
  
    HScrollbar (float xp, float yp, int sw, int sh, int l, int dis) {
      displacement = dis;
      swidth = sw;
      sheight = sh;
      int widthtoheight = sw - sh;
      ratio = (float)sw / (float)widthtoheight;
      xpos = xp;
      ypos = yp-sheight/2;
      spos = xpos;
      newspos = spos;
      sposMin = xpos;
      sposMax = xpos + swidth - sheight;
      loose = l;
    }
  
    public void update() {
      
      

      if(isPlaying){
        //only plays sound for dialog
        if(sMan.eventHappened(getPosInSeconds())){
          //put sound code here!!!
          sMan.peekNextEvent().execute(getPosInSeconds());
          println(sMan.popEvent());
        }
        
        //find if previous dialog should still be playing, and if so, play it
        if(sMan.getPreviousPoppedDialog(getPosInSeconds()) != null){
          sMan.getPreviousPoppedDialog(getPosInSeconds()).execute(getPosInSeconds());
//          println(sMan.getPreviousPoppedDialog(getPosInSeconds()));
        }
      }
      
      if(overSlide()) {
        over = true;
      } else {
        over = false;
      }
      
      if(mousePressed && over) {
        locked = true;
      }
      if(!mousePressed) {
        locked = false;
      }
      if(locked) {
        newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
      }

      if(abs(newspos - spos) > 1 || isPlaying) {
        
        //if playback has collided with the end of the timeline, stop playing
        if(isPlaying){
          if(getPosInSeconds() >= totalTime){
            executePause();
          }
        }
                
        if(isPlaying){
          long estimatedTime = System.nanoTime() - startTime;
          
          if(estimatedTime/1000000000 >= 1){
            //if one second has passed, make a new start time (reset the second timer)
            startTime = System.nanoTime();
//            println("before spos is " + spos + " time is " + getPosInSeconds());
            spos = incrementSposInSeconds();
            println("spos is " + spos + " time is " + getPosInSeconds() + " frame is " + getPosInFrames());
          }
        
        }
        else{
          spos = spos + (newspos-spos)/loose;
        }
      }
      //if the timeline is NOT playing, create the queue for the events to unfold in order
      if(!isPlaying){
        sMan.createQueue(getPosInSeconds()); 
      }
//      println(getPosInSeconds());

    }
  
    public float constrain(float val, float minv, float maxv) {
      return min(max(val, minv), maxv);
    }
  
    public boolean overSlide() {
      if(mouseX > xpos && mouseX < xpos+swidth &&
         mouseY > ypos && mouseY < ypos+sheight) {
        return true;
      } else {
        return false;
      }
    }
  
    //displays the timeline box and the ticks.
    public void display() {
      noStroke();
      fill(204);
      //timeline
      rect(xpos, ypos, swidth, sheight);
      if(over || locked) {
        fill(0, 0, 0);
      } else {
        fill(102, 102, 102);
      }
      //scrubber
      //println(spos);
      rect(spos-sheight/2, ypos, sheight, sheight);
      
      for(int i = 0; i<tickArr.size(); i++){
        tickArr.get(i).displayTick();
      }
      
      prevTick = null;
      nextTick = null;
      
      for(int i = 0; i<tickArr.size(); i++){
        if (tickArr.get(i).getXPos() < spos){
          prevTick = tickArr.get(i);
        }
        else{
          break;
        }
      }
      
      for(int i = 0; i<tickArr.size(); i++){
        if (tickArr.get(i).getXPos() > spos){
          nextTick = tickArr.get(i);
          break;
        }
      }
      
      
      if(prevTick != null){
        prevTick.changeCamColorPrev();
      }
      if(nextTick != null){
        nextTick.changeCamColorNext();
      }

    }
    
    //todo; this
    private int incrementSposInFrames(){
      return 0;
    }
    
    public void setSposWithFrame(int frameNum){
      spos = fps*frameNum+displacement;
    }
    
    public int getPosInFrames(){
      return (int)(((spos-displacement)/swidth)*(totalTime))*fps;
    }
    
    public int getPosInSeconds() {
      return (int)(((spos-displacement)/swidth)*totalTime);
    }
    
    //EVENTUALLY REMOVE THIS FUNCTION; need to rely on incrementFrame instead
    private int incrementSposInSeconds(){
//      println(getPosInSeconds());
//      println("posInSec " + getPosInSeconds() + " swidth+50 " + (swidth+50) + " " + (1/totalTime) + " " + (1.0/totalTime)*swidth*50);

      return (int)(((((float)getPosInSeconds()+ 1.5f)/(totalTime))*swidth)+displacement);
      
    }
    
    public float getSliderPos(){
      return spos;
    }
    public void setSpos(float s){
      spos = s;
    }
    
    public void executePlay(){
      println("play");
      
      isPlaying = true;
      startTime = System.nanoTime();    
      
    }
    
    public void executePause(){
      println("pause");
      isPlaying = false;
      
       
    }
    
  }
  
  
}
  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#FFFFFF", "GUI" });
  }
}
