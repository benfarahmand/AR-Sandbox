import org.openkinect.freenect.*;
import org.openkinect.processing.*;

class KinectThread {//extends Thread {

  boolean running = false;
  Kinect kinect;
  PGraphics buffer, tempBuffer;
  // Array of BlobDetection Instances
  Topology_Sim7_Sensors parent;
  boolean bufferReady = false;

  KinectThread(Topology_Sim7_Sensors p) {
    parent = p;
    //buffer = createGraphics(width, height);
    //tempBuffer = createGraphics(width, height);
    kinect = new Kinect(p);
    //println(kinect.getTilt());
    //kinect.setTilt(0.0);
    //println(kinect.getTilt());
    kinect.initDepth();
    kinect.initVideo();
  }


  //PGraphics display() {
  //  if (bufferReady) return tempBuffer;
  //  else return buffer;
  //}

  PGraphics display() {
    return tempBuffer;
  }

  PImage getVideo() {
    return kinect.getVideoImage();
  }

  void run() {
    //println("entered kinect thread run");
    if (running) {
      try {
        //bufferReady = false;
        //generateAlphaImage();
        generateAlphaImage(calibratethread.getDisplayRect()[0], 
          calibratethread.getDisplayRect()[1], 
          calibratethread.getDisplayRect()[2], 
          calibratethread.getDisplayRect()[3]);
        //bufferReady = true;
        //Thread.sleep(5000);
        //buffer = copyGraphics(tempBuffer, buffer);
      }
      //catch(InterruptedException ie) {
      //  println("Child thread interrupted! " + ie);
      //} 
      catch (Exception e) {
        e.printStackTrace();
      }
    }
  }

  void generateAlphaImage(int initX, int initY, int rectW, int rectH) {
    tempBuffer.beginDraw();
    tempBuffer.clear();
    int[] depth = kinect.getRawDepth();// Get the raw depth as array of integers
    int skip = 4; // number of skipped locations equals scale, increase scale to increase speed, but lowers resolution
    tempBuffer.strokeWeight(skip);
    for (int x = initX; x < initX+rectW; x += skip) {
      for (int y = initY; y < initY+rectH; y += skip) {
        int offset = x + y*kinect.width;
        int rawDepth = depth[offset];
        if (rawDepth>lowestPoint) {
          tempBuffer.stroke(255, map(lowestPoint, lowestPoint, highestPoint, 0, 255));
          //tempBuffer.fill(255, map(lowestPoint, lowestPoint, highestPoint, 0, 255));
        } else if (rawDepth<highestPoint) {
          tempBuffer.stroke(255, map(highestPoint, lowestPoint, highestPoint, 0, 255));
          //tempBuffer.fill(255, map(lowestPoint, lowestPoint, highestPoint, 0, 255));
        } else {
          tempBuffer.stroke(255, map(rawDepth, lowestPoint, highestPoint, 0, 255));
          //tempBuffer.fill(255, map(lowestPoint, lowestPoint, highestPoint, 0, 255));
        }
        tempBuffer.point(x-initX, y-initY);
        //tempBuffer.rect(x, y,x+skip,y+skip);
      }
    }
    tempBuffer.endDraw();
    tempBuffer.filter(BLUR, 8);
  }

  void generateAlphaImage() {
    tempBuffer.beginDraw();
    tempBuffer.clear();
    int[] depth = kinect.getRawDepth();// Get the raw depth as array of integers
    int skip = 4; // number of skipped locations equals scale, increase scale to increase speed, but lowers resolution
    tempBuffer.strokeWeight(skip);
    for (int x = 0; x < kinect.width; x += skip) {
      for (int y = 0; y < kinect.height; y += skip) {
        int offset = x + y*kinect.width;
        int rawDepth = depth[offset];
        if (rawDepth>lowestPoint) {
          tempBuffer.stroke(255, map(lowestPoint, lowestPoint, highestPoint, 0, 255));
          //tempBuffer.fill(255, map(lowestPoint, lowestPoint, highestPoint, 0, 255));
        } else if (rawDepth<highestPoint) {
          tempBuffer.stroke(255, map(highestPoint, lowestPoint, highestPoint, 0, 255));
          //tempBuffer.fill(255, map(lowestPoint, lowestPoint, highestPoint, 0, 255));
        } else {
          tempBuffer.stroke(255, map(rawDepth, lowestPoint, highestPoint, 0, 255));
          //tempBuffer.fill(255, map(lowestPoint, lowestPoint, highestPoint, 0, 255));
        }
        tempBuffer.point(x, y);
        //tempBuffer.rect(x, y,x+skip,y+skip);
      }
    }
    tempBuffer.endDraw();
    tempBuffer.filter(BLUR, 8);
  }

  // These functions come from: http://graphics.stanford.edu/~mdfisher/Kinect.html
  float rawDepthToMeters(int depthValue) {
    if (depthValue < 2047) {
      return (float)(1.0 / ((double)(depthValue) * -0.0030711016 + 3.3309495161));
    }
    return 0.0f;
  }

  int metersToRawDepth(float rawDepth) {
    return (int)((((1.0 / rawDepth)-3.3309495161))/-0.0030711016);
  } 
  
  public void createBuffer() {
    //tempBuffer = createGraphics(width, height);
    tempBuffer = createGraphics(calibratethread.getDisplayRect()[2], calibratethread.getDisplayRect()[3]);
  }

  public void start() {
    //super.start();
    running = true;
  }

  public void exit() {
    running = false;
    println("exiting kinect runner");
  }
}