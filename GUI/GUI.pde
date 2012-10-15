

import controlP5.*;

import Jama.*;
import javax.media.opengl.*;
import processing.opengl.*;
import java.nio.FloatBuffer;
import java.util.ArrayList;
import oscP5.*;
import controlP5.*;
import picking.*;

ControlP5 controlP5;
DropdownList ruleChoiceList;
GL gl;
//Picker camPicker, charPicker;
Picker picker;
color bGround = color(70, 70, 70);
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

void setup() {
  size(winWidth, winHeight, OPENGL);
  background(bGround);
  sm = new SceneManager();
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
  int numOfCams = int(tokens[0]);
  for (int i=1; i<numOfCams+1; i++) {

    tokens = split(lines[i], " ");
    float[] matrix = new float[16];
    for (int j=0; j<tokens.length; j++) {
      matrix[j] = float(tokens[j]);
    }

    cameras.add(new Cam(FloatBuffer.wrap(matrix))); // add all the cameras
  }

  tokens = split(lines[1 + numOfCams], " ");
  if (tokens.length != 1) {
    println("Incorrect file format for number of characters");
    return;
  }
  int numOfChars = int(tokens[0]);
  for (int i= 2 + numOfCams; i<lines.length; i++) {
    tokens = split(lines[i], " ");
    float[] matrix = new float[16];
    for (int j=0; j<tokens.length; j++) {
      matrix[j] = float(tokens[j]);
    }

    characters.add(new Character(FloatBuffer.wrap(matrix))); // add all the characters
  }

    characters.get(0).col=color(255,255,0);
    characters.get(1).col=color(255,0,255);
    
    timeline = new Timeline(sm);
    
    debug = new Debug(controlP5);
    
    //title, start, end, initVal, xpos, ypos, width, height
    //controlP5.addSlider("Timeline", 0,120,0,100,winHeight-50,winWidth-200,30);

}

void draw() { // display things

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
void resetAllCams() {
  for (int i = 0; i<cameras.size(); i++) {
    cameras.get(i).setDefaultColor();
  }
}

void mouseClicked() {

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

void mouseDragged() {

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
void keyPressed() {
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
void oscEvent(OscMessage theOscMessage) {

  //Friedrich added this select camera event
  if (theOscMessage != null && theOscMessage.checkAddrPattern("/selectActorByName")) {
    println("yay!");
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
    matrix[12]=(700-matrix[12])*2.0;
    matrix[14]=matrix[14] * 1.5;
    //println (matrix[12]);

    FloatBuffer fb = FloatBuffer.allocate(16);
    fb = FloatBuffer.wrap(matrix);
    // TODO(sanjeet): Currently using only camera 5
    // Change this variable based on the data received from OSC
    //    int selectedCamera = 5;
    cameras.get(selectedCamera).modelViewMatrix = fb;
  }
}

void customize(DropdownList ddl) {
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

void controlEvent(ControlEvent theEvent) {
  // PulldownMenu is if type ControlGroup.
  // A controlEvent will be triggered from within the ControlGroup.
  // therefore you need to check the originator of the Event with
  // if (theEvent.isGroup())
  // to avoid an error message from controlP5.
  if (theEvent.isGroup()) {
    if (theEvent.group().name() == "ruleChoiceList") {
      //    println(theEvent.group().value()+" from "+theEvent.group());
      selectedRule = int(theEvent.group().value());
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

void slider(float theColor) {
  //myColor = color(theColor);
  //println("a slider event. setting background to "+theColor);
}


