import blobDetection.*;
import java.awt.Color;
import nl.tue.id.oocsi.*;
import java.util.*;
import nl.tue.id.oocsi.server.*;
import org.openkinect.processing.*;
import jp.nyatla.nyar4psg.*;
import org.openkinect.freenect.*;
import controlP5.*;

ControlP5 cp5;
BlobThread blobthread;
KinectThread kinectthread;
VectorThread vectorthread;
CalibrateThread calibratethread;

boolean DRAW_VECTORS = false;
boolean startServices = false;
int left = 0, top = 0, right = 400, bottom = 400;
int pleft = 0, ptop = 0, pright = 400, pbottom = 400;

float levels = 25; //can deccrease layers to improve performance                                                     

float colorStart =  0, colorRange =  1;             
int shift;
OOCSI oocsi;
//int lowestPoint = 885, highestPoint = 885-50;
int lowestPoint = 825, highestPoint = 765;
//int lowestPoint = 950, highestPoint = 850;

void setup() {
  //OOCSIServer.main(new String[] {});
  size(1280, 800, P2D);
  //size(640, 480, P2D);  

  kinectthread = new KinectThread(this);
  kinectthread.start();
  calibratethread = new CalibrateThread();
}

void draw() {
  // Kinect and Projector are usually misaligned, need to manually calibrate them so they cover the same area
  //TO DO: Calibration should also include some sort of multi-stage calibration, where you begin by setting the bounding box
  // THEN: once the bounding box is set, it draws the blobs on top of the kinect image, and the user needs to align the two 
  if (!calibratethread.calibrated) calibratethread.calibration(); 
  // once calibration is done, must start the various services that will do blob tracking and also calculate the vector gradients
  else if (!startServices && calibratethread.calibrated) {
    kinectthread.createBuffer(); //need to create buffer before creating vector thread
    blobthread = new BlobThread(calibratethread.getDisplayRect()[2], calibratethread.getDisplayRect()[3]);
    vectorthread = new VectorThread(calibratethread.getDisplayRect()[2], calibratethread.getDisplayRect()[3]);
    blobthread.start();
    vectorthread.start();
    //oocsi = new OOCSI(this, "senderName_" + System.currentTimeMillis(), "localhost");
    //update the shift based on calibration
    shift = calibratethread.getDisplayRect()[3]*calibratethread.getDisplayRect()[2]+calibratethread.getDisplayRect()[2]; //might have to transmit the new height and width... or could get it from the image that's sent
    //frameRate(1);
    cp5 = new ControlP5(this);
    cp5.addSlider("left")
      .setPosition(10, 10)
      .setSize(200, 20)
      .setRange(0, 400)
      .setValue(0)
      ;
    cp5.addSlider("top")
      .setPosition(10, 40)
      .setSize(200, 20)
      .setRange(0, 400)
      .setValue(0)
      ;
    cp5.addSlider("right")
      .setPosition(10, 70)
      .setSize(200, 20)
      .setRange(0, 400)
      .setValue(400)
      ;
    cp5.addSlider("bottom")
      .setPosition(10, 100)
      .setSize(200, 20)
      .setRange(0, 400)
      .setValue(400)
      ;
    startServices = true;
  } else {
    try {
      background(0);
      //frameRate(1);
      kinectthread.run();
      //image(kinectthread.display(),0,0,width,height);
      blobthread.run();
      //vectorthread.run();
      //background(0);
      //image(kinectthread.getVideo(), 0, 0, width, height, 
      //calibratethread.getDisplayRect()[0], calibratethread.getDisplayRect()[1], 
      //calibratethread.getDisplayRect()[2], calibratethread.getDisplayRect()[3] 
      //  );
      // is it possible to take the rectangle and then display it within the screen?
      // need to explore the idea of the blobs not stretching...
      image(blobthread.display(), blobthread.myX, blobthread.myY, blobthread.myWidth, blobthread.myHeight); 
      //image(blobthread.display(), calibratethread.getDisplayRect()[0], calibratethread.getDisplayRect()[1]);
      //, calibratethread.getDisplayRect()[2], calibratethread.getDisplayRect()[3]);
      //if (DRAW_VECTORS) image(vectorthread.display(), 0, 0, width, height);

      //oocsi.channel("datachannel").data("image pixels", (int[]) blobthread.getPixels()).send();
      //oocsi.channel("datachannel").data("array", (float[]) vectorthread.getGradients()).send();
      //oocsi.channel("datachannel").data("image dimensions", (int[]) calibratethread.getDisplayRect()).send();
      text(lowestPoint +" , "+frameRate, width-100, height-10);
      if (left!=pleft) {
        blobthread.addToLeft(left-pleft);
        pleft=left;
      }
      if (top!=ptop) {
        blobthread.addToTop(top-ptop);
        ptop=top;
      }
      if (right!=pright) {
        blobthread.addToRight(right-pright);
        pright=right;
      }
      if (bottom!=pbottom) {
        blobthread.addToBottom(bottom-pbottom);
        pbottom=bottom;
      }
      //wait(5000);
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  }
}

void exit() {
  if (startServices) {
    blobthread.exit();
    vectorthread.exit();
  }
  kinectthread.exit();
  super.exit();
}

void keyPressed() {
  //println(key);
  if (keyCode==UP) {
    lowestPoint+=5;
    highestPoint+=5;
  }
  if (keyCode==DOWN) {
    lowestPoint-=5;
    highestPoint-=5;
  }
  if (keyCode == RIGHT) {
  }
  if (keyCode == LEFT) {
  }
  if (key==ENTER) {
    if (!calibratethread.calibrated) calibratethread.setRect();
    //else {
    //  calibratethread.calibrated=!calibratethread.calibrated;
    //  calibratethread.undoRect();
    //}
  }
}