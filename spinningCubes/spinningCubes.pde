//3D Vector class
public class Vector {
  public float x;
  public float y;
  public float z;
  public Vector(float x, float y,float z) {
    this.x=x;
    this.y=y;
    this.z=z;
  }
  public Vector(Vector vec) {
    this.x=vec.x;
    this.y=vec.y;
    this.z=vec.z;
  }
  public void addVec(Vector vec) {
    x+=vec.x;
    y+=vec.y;
    z+=vec.z;
  }
  public void subVec(Vector vec) {
    x-=vec.x;
    y-=vec.y;
    z-=vec.z;
  }
  public void sclVec(float scale) {
    x*=scale;
    y*=scale;
    z*=scale;
  }
  public void nrmVec() {
    sclVec(1/getMag());
  }
  public void nrmVec(float mag) {
    sclVec(mag/getMag());
  }
  public void limVec(float lim) {
    float mag=getMag();
    if (mag>lim) {
      sclVec(lim/mag);
    }
  }
  public float getAng1() {
    return atan2(y, x);
  }
  public float getAng2() {
    return atan2(z, x);
  }
  public float getAng3() {
    return atan2(z, y);
  }
  public float getAng1(Vector vec) {
    return atan2(vec.y-y, vec.x-x);
  }
  public float getAng2(Vector vec) {
    return atan2(vec.z-z, vec.x-x);
  }
  public float getAng3(Vector vec) {
    return atan2(vec.z-z, vec.x-x);
  }
  public float getMag1() {
    return sqrt(sq(x)+sq(y));
  }
  public float getMag2() {
    return sqrt(sq(x)+sq(z));
  }
  public float getMag3() {
    return sqrt(sq(y)+sq(z));
  }
  public float getMag() {
    return sqrt(sq(x)+sq(y)+sq(z));
  }
  public float getMag1(Vector vec) {
    return sqrt(sq(vec.x-x)+sq(vec.y-y));
  }
  public float getMag2(Vector vec) {
    return sqrt(sq(vec.x-x)+sq(vec.z-z));
  }
  public float getMag3(Vector vec) {
    return sqrt(sq(vec.y-y)+sq(vec.z-z));
  }
  public float getMag(Vector vec) {
    return sqrt(sq(vec.x-x)+sq(vec.y-y)+sq(vec.z-z));
  }
  public void rotVec1(float rot) {
    float mag=getMag1();
    float ang=getAng1();
    ang+=rot;
    x=cos(ang)*mag;
    y=sin(ang)*mag;
  }
  public void rotVec2(float rot) {
    float mag=getMag2();
    float ang=getAng2();
    ang+=rot;
    x=cos(ang)*mag;
    z=sin(ang)*mag;
  }
  public void rotVec3(float rot) {
    float mag=getMag3();
    float ang=getAng3();
    ang+=rot;
    y=cos(ang)*mag;
    z=sin(ang)*mag;
  }
  public void minVec(Vector min){
    x=min(x,min.x);
    y=min(y,min.y);
    z=min(z,min.z);
  }
  public void maxVec(Vector max){
    x=max(x,max.x);
    y=max(y,max.y);
    z=max(z,max.z);
  }
}

class Cube{
  ArrayList<Vector> vecs;
  Vector pos;
  
  int animateTime;
  int animateLength;
  //lock prevents the animation from being triggered twice
  boolean locked;
  color col;
  
  Cube(Vector p,int al){
    pos=new Vector(p);
    
    //create points defining the cube
    vecs=new ArrayList<Vector>();
    vecs.add(new Vector( size, size, size));
    vecs.add(new Vector( size, size,-size));
    vecs.add(new Vector( size,-size,-size));
    vecs.add(new Vector(-size,-size,-size));
    vecs.add(new Vector(-size, size, size));
    vecs.add(new Vector(-size,-size, size));
    vecs.add(new Vector(-size, size,-size));
    vecs.add(new Vector( size,-size, size));
    
    //rotate the points to be in an isometric view
    for(Vector vec:vecs){
      vec.rotVec2(PI/4);
      vec.rotVec3(magic);
    }
    
    //setup animation
    animateTime=0;
    animateLength=al;
    locked=true;
    
    col=color(0);
  }
  void setCol(color toSet){
    col=toSet;
  }
  
  //run the animation
  void animate(){
    if(animateTime>0){
      animateTime--;
      spin();
      rise();
    }
  }
  void spin(){
    float spin=PI/2/animateLength;
    for(Vector vec:vecs){
      
      vec.rotVec3(-magic);
      vec.rotVec2(-PI/4);
      
      vec.rotVec2(spin);
      
      vec.rotVec2(PI/4);
      vec.rotVec3(magic);
    }
  }
  void rise(){
    float rise=yDiff*2/animateLength;
    pos.addVec(new Vector(0,-rise,0));
  }
  
  //trigger the animation
  void trigger(){
    if(animateTime==0&&!locked){
      animateTime=animateLength;
      locked=true;
    }
  }
  //allow the animation to play again
  void unLock(){
    locked=false;
  }
  
  //displaying is a little complicated
  void display(){
    //find the corners closest and furthest from the camera
    Vector furthest=null;
    Vector closest=null;
    float distF=0;
    float distC=0;
    for(int i=0;i<vecs.size();i++){
      if(furthest==null||vecs.get(i).z>distF){
        distF=vecs.get(i).z;
        furthest=vecs.get(i);
      }
      if(closest==null||vecs.get(i).z<distC){
        distC=vecs.get(i).z;
        closest=vecs.get(i);
      }
    }
    
    //find the the corners that make up the edge of the shape
    ArrayList<Vector> edges=new ArrayList<Vector>();
    for(int i=0;i<vecs.size();i++){
      if(vecs.get(i)!=furthest&&vecs.get(i)!=closest){
        edges.add(vecs.get(i));
      }
    }
    
    //display the shape with fill
    fill(col);
    beginShape();
    //start at a point and then draw a line to its closest neighbor
    //after a point has been handled remove it to make sure it won't be displayed again
    Vector point=edges.get(0);
    edges.remove(0);
    while(edges.size()>0){
      //display current point
      vertex(point.x+pos.x, point.y+pos.y);
      //find and select closest neighbor
      int next=-1;
      float dist=0;
      for(int i=0;i<edges.size();i++){
        float temp=edges.get(i).getMag1(point);
        if(next==-1||temp<dist){
          next=i;
          dist=temp;
        }
      }
      point=edges.get(next);
      edges.remove(next);
    }
    vertex(point.x+pos.x, point.y+pos.y);
    //finish drawing shape
    endShape(CLOSE);
    
    //display inner lines
    for(int i=0;i<vecs.size();i++){
      //display all lines that are directly connected to the closest point to the camera
      if(vecs.get(i)!=furthest&&vecs.get(i)!=closest&&vecs.get(i).getMag(closest)<size*2+0.1){
        line(vecs.get(i).x+pos.x,vecs.get(i).y+pos.y,closest.x+pos.x,closest.y+pos.y);
      }
    }
  }
}


//special numbers
float magic=atan(1/sqrt(2));
float yDiff;
float xDiff;

ArrayList<Cube> cubes;

//trigger settings
float triggerRing=0;
float triggerRange=5;
float triggerGrow=3;
Vector triggerCenter=new Vector(400,600,0);

//general settings
float size=15;
int high=40;
int wide=10;

void setup(){
  //setup processing sketch
  size(800,800);
  colorMode(HSB);
  strokeWeight(1.5);
  stroke(0);
  
  //init special numbers
  Vector v1=new Vector( size,-size, size);
  Vector v2=new Vector(-size, size,-size);
  v1.rotVec2(PI/4);
  v1.rotVec3(magic);
  v2.rotVec2(PI/4);
  v2.rotVec3(magic);
  yDiff=(v2.y-v1.y)/2;
  
  Vector v3=new Vector( size,-size,-size);
  Vector v4=new Vector(-size,-size, size);
  v3.rotVec2(PI/4);
  v3.rotVec3(magic);
  v4.rotVec2(PI/4);
  v4.rotVec3(magic);
  xDiff=v3.x-v4.x;
  
  //create all cubes
  cubes=new ArrayList<Cube>();
  for(int y=0;y<high;y++){
    for(int x=0;x<wide;x++){
      Cube toAdd;
      if(y%2==0){
        toAdd=new Cube(new Vector(xDiff*2*x,yDiff*y,0),y*2+20);
      }else{
        toAdd=new Cube(new Vector(xDiff*2*x+xDiff,yDiff*y,0),y*2+20);
      }
      toAdd.setCol(color(y*256/high,100,220));
      cubes.add(toAdd);
    }
  }
}

void draw(){
  background(0);
  
  //run and display cubes
  triggerRing+=triggerGrow;
  for(int i=0;i<cubes.size();i++){
    if(abs(cubes.get(i).pos.getMag1(triggerCenter)-triggerRing)<triggerRange){
      cubes.get(i).trigger();
    }
    //unused code to make squares loop
    //if(cubes.get(i).pos.y<-yDiff){
    //  cubes.get(i).pos.y+=yDiff*high;
    //}
    
    //animate and display cubes
    cubes.get(i).animate();
    cubes.get(i).display();
  }
}

//start a new animation when a key is pressed
void keyPressed(){
  triggerRing=0;
  for(int i=0;i<cubes.size();i++){
    cubes.get(i).unLock();
  }
}
