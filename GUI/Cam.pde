//import Jama.*;

import java.nio.FloatBuffer;

class Cam { 

  float fov = 45;    //what primative/data structure works for this?
  //Matrix loc;
  ;
  //Matrix rot;
  color col, defaultCol = color(0, 0, 255), badCol = color(255, 0, 0), 
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

  PVector getTranslation() {
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
  
  PVector getZAxis() {
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
  
  float getFOV() {
    return fov;
  }

  void setColor(int r, int g, int b) {
    this.col = color(r, g, b);
  }
  
  color getColor(){
    return col; 
  }
  
  void display() {


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

  void setDefaultColor() {
    col = defaultCol;
  }

  void changeToSelectedColor() {
    /*col = color(
     int(random(0, 255)),
     int(random(0, 255)),
     int(random(0, 255))
     );
     */
    col = color(255, 255, 255);
  }

  void changeToDragColor() {
    col = color(0, 0, 0);
  }

  void changeToDefaultColor() {
    col = color(0, 0, 0);
  }
  void drag(int x, int y) {
    float[] matrix = modelViewMatrix.array();
    //println(matrix[12] + " " + matrix[13] + " " + matrix[14] + " " );
    matrix[12] = x;
    matrix[14] = -y;
    //println(matrix[12] + " " + matrix[13] + " " + matrix[14] + " " );
  }
  
  boolean isInView(PVector vect) {
    PVector z = getZAxis();
    PVector v1 = PVector.sub(vect, getTranslation());
    float dotP = PVector.dot(v1, z)/(z.mag() * v1.mag());
    if ((acos(dotP) * 180/PI) <= fov) {
      return true;
    }
    return false;
  }
  
  boolean camIsSelected(){
    return isSelected;
  }
  
  void changeToColor(color c){
    col = c;
  }
  
  void setNextShapeActive(){
    
    isNext = true;
  }
  
}

