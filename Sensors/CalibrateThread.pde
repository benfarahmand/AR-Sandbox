class CalibrateThread {

  boolean calibrated = false;
  boolean setRectangle = false;
  int initX = 0, initY = 0, rectW = 0, rectH = 0;
  boolean initXY = false;
  int[] rectCoordinates;
  //BlobDetection theBlobDetection;
  PImage img;
  //int screenScale;

  CalibrateThread() {
    rectCoordinates = new int[4];
    //theBlobDetection = new BlobDetection(kinectthread.getVideo().width, kinectthread.getVideo().height);
    img = createImage(640,480,RGB);
    //screenScale = (640/480)/( width / height );
  }

  int[] getDisplayRect() {
    return rectCoordinates;
  }

  void setRect() {
    //take coordinates of the rect and zoom it
    setRectangle = true;
    calibrated = true;
    println(initX +","+ initY +","+ rectW +","+ rectH);
    initX = (int)((float)initX*(640.0/width));
    initY = (int)((float)initY*(480.0/height));
    rectW = (int)((float)rectW*(640.0/width));
    rectH = (int)((float)rectH*(480.0/height));
    println(initX +","+ initY +","+ rectW +","+ rectH);
    rectCoordinates[0] = initX;
    rectCoordinates[1] = initY;
    rectCoordinates[2] = rectW;
    rectCoordinates[3] = rectH;
  }
  
  void addToLeft(int l){
    rectCoordinates[0] += l;
  }
  
  void addToTop(int t){
    rectCoordinates[1] += t;
  }
  
  void addToRight(int r){
    rectCoordinates[2] += r;
  }
  
  void addToBottom(int b){
    rectCoordinates[3] += b;
  }
  
  void undoRect(){
    setRectangle = false;
    initXY = false;
  }

  void calibration() {
    // - needs to find the farthest object
    // - needs to find the closest object
    // - needs to be able to select a portion of the kinect screen to read the depth from
    //  - maybe i can click and drag a rectangle around it
    // - then, it needs to scale that section of the


    // first try and find the rectangle and then project the image back through the projector
    if (!setRectangle) {
      //background(255); //set it to white, and then do threshhold to find the blob rectangle
      image(kinectthread.getVideo(), 0, 0,width,height);
      stroke(255);
      strokeWeight(15);
      rect(0,0,width,height);
      stroke(0,255, 0);
      strokeWeight(5);
      noFill();
      if (mousePressed) {
        if (!initXY) {
          initX = mouseX;
          initY = mouseY;
          initXY=true;
        }
        stroke(250, 0, 0);
        strokeWeight(2);
        rectW = abs(mouseX-initX);
        rectH = abs(mouseY-initY);
      }
      rect(initX, initY, rectW, rectH);
      text(initX +","+ initY +","+ rectW +","+ rectH,mouseX+10,mouseY+10);
      //println(initX +","+ initY +","+ rectW +","+ rectH);
    } else {
      img.copy(kinectthread.getVideo(),initX,initY,rectW,rectH,0,0,img.width,img.height);
      image(img,0,0,width,height);
    }
    //img = kinectthread.getVideo();
    //theBlobDetection.setThreshold(0.2);
    //theBlobDetection.computeBlobs(img.pixels);
  }
}