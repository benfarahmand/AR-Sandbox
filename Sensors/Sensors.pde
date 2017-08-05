import blobDetection.*;
import java.awt.Color;
import nl.tue.id.oocsi.*;
import java.util.*;
import nl.tue.id.oocsi.server.*;
import org.openkinect.processing.*;
import jp.nyatla.nyar4psg.*;
import org.openkinect.freenect.*;

BlobThread blobthread;
KinectThread kinectthread;
VectorThread vectorthread;
CalibrateThread calibratethread;

boolean DRAW_VECTORS = true;
boolean startServices = false;

float levels = 15; //can deccrease layers to improve performance                    
//float hfactor, wfactor;                                 

float colorStart =  0, colorRange =  1;             
int shift;
OOCSI oocsi;
//int lowestPoint = 885, highestPoint = 885-50;
int lowestPoint = 850, highestPoint = 750;
//int lowestPoint = 950, highestPoint = 850;

void setup() {
  OOCSIServer.main(new String[] {});
  //size(1280, 768, P2D);
  size(640, 480, P2D);  

  kinectthread = new KinectThread(this);
  kinectthread.start();
  calibratethread = new CalibrateThread();
}

void draw() {
  // Kinect and Projector are usually misaligned, need to manually calibrate them so they cover the same area
  if (!calibratethread.calibrated) calibratethread.calibration(); 
  // once calibration is done, must start the various services that will do blob tracking and also calculate the vector gradients
  else if (!startServices && calibratethread.calibrated) {
    kinectthread.createBuffer(); //need to create buffer before creating vector thread
    blobthread = new BlobThread(calibratethread.getDisplayRect()[2], calibratethread.getDisplayRect()[3]);
    vectorthread = new VectorThread(calibratethread.getDisplayRect()[2], calibratethread.getDisplayRect()[3]);
    blobthread.start();
    vectorthread.start();
    oocsi = new OOCSI(this, "senderName_" + System.currentTimeMillis(), "localhost");
    //update the shift based on calibration
    shift = calibratethread.getDisplayRect()[3]*calibratethread.getDisplayRect()[2]+calibratethread.getDisplayRect()[2]; //might have to transmit the new height and width... or could get it from the image that's sent
    frameRate(1);
    startServices = true;
  } else {
    try {
      background(0);

      kinectthread.run();
      //image(kinectthread.display(),0,0,width,height);
      blobthread.run();
      vectorthread.run();
      //background(0);
      //image(kinectthread.getVideo(),0,0);
      //image(blobthread.display(), 0, 0, width, height);
      //if (DRAW_VECTORS) image(vectorthread.display(), 0, 0, width, height);
      

      oocsi.channel("datachannel").data("image pixels", (int[]) blobthread.getPixels()).send();
      oocsi.channel("datachannel").data("array", (float[]) vectorthread.getGradients()).send();
      oocsi.channel("datachannel").data("image dimensions", (int[]) calibratethread.getDisplayRect()).send();
      text(lowestPoint +" , "+frameRate, width-100, height-10);
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