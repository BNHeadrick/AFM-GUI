import Jama.*;

import java.nio.FloatBuffer;

class Character { 
  
  float fov = 45;    //what primative/data structure works for this?
//  Matrix loc;;
//  Matrix rot;
  color col, defaultCol = color(0,255,0), badCol = color(255, 0, 0), 
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

  float getFOV() {
    return fov;
  }

  void display() {
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
    sphere(3);

    stroke(0);
    //line(0, 0, 0, 0, 0, 50);
    popMatrix();
    
  }

  void changeToDragColor(){
    col = color(0, 0, 0);
  }
  
  void changeToDefaultColor(){
    col = defaultCol;
  }
  
  void drag(int x, int y){
    float[] matrix = modelViewMatrix.array();
    matrix[12] = x;
    matrix[14] = -y;
  }
  
  public void setModelViewMatrix(FloatBuffer fb){
    this.modelViewMatrix = fb;
  }
  
  public FloatBuffer getModelViewMatrix(){
    return modelViewMatrix;
  }
  
}
