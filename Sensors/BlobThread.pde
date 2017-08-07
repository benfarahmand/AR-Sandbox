//creating blob thread with potential for multi-threading in case we can run it faster
class BlobThread {//extends Thread {

  boolean running = false, bufferReady = false;
  BlobDetection[] theBlobDetection;// = new BlobDetection[int(levels)];
  PImage img;
  //PGraphics buffer; 
  PGraphics tempBuffer;
  int myWidth, myHeight;
  int myX, myY;

  BlobThread(int w, int h) {
    theBlobDetection = new BlobDetection[int(levels)];
    //buffer = createGraphics(w, h);
    tempBuffer = createGraphics(w, h);
    img = createImage(w, h, RGB);
    myX=0;
    myY=0;
    myWidth=width;
    myHeight=height;
  }

  PGraphics display() {
    return tempBuffer;
  }

  int[] getPixels() {
    tempBuffer.beginDraw();
    tempBuffer.loadPixels();
    tempBuffer.endDraw();
    return tempBuffer.pixels;
  }

  void run() {
    //println("entered blob thread run");
    if (running) {
      try {
        img = kinectthread.display();//new PImage(kinectthread.display().width, kinectthread.display().height);
        //img.copy(kinectthread.display(), 0, 0, kinectthread.display().width, kinectthread.display().height, 0, 0, img.width, img.height);
        for (int i=0; i<levels; i++) {
          theBlobDetection[i] = new BlobDetection(img.width, img.height);
          theBlobDetection[i].setThreshold(i/levels);
          theBlobDetection[i].computeBlobs(img.pixels);
        }
        //blobsReady = true;
        //bufferReady = false;
        tempBuffer.beginDraw();
        tempBuffer.clear();
        tempBuffer.strokeWeight(1);
        for (int i=0; i<levels; i++) {
          drawContours(i, tempBuffer);
        }
        tempBuffer.endDraw();
        //bufferReady = true;
        //buffer = copyGraphics(tempBuffer, buffer);
        //Thread.sleep(5000);
        //oocsi.channel("datachannel").data("image pixels", (int[]) getPixels()).send();
      }
      //catch(InterruptedException ie) {
      //  println("Child thread interrupted! " + ie);
      //} 
      catch (Exception e) {
        println("Blob Thread: "+e.toString());
      }
    }
  }

  PGraphics copyGraphics(PGraphics src, PGraphics dest) {
    if (dest == null || dest.width != src.width || dest.height != src.height) {
      dest = createGraphics(src.width, src.height);
    }
    src.loadPixels();
    dest.beginDraw();
    dest.clear();
    dest.loadPixels();
    arrayCopy(src.pixels, 0, dest.pixels, 0, src.pixels.length);
    dest.updatePixels();
    dest.endDraw();
    return dest;
  }

  void drawContours(int i, PGraphics tempBuffer) {
    Blob b;
    EdgeVertex eA, eB;
    for (int n=0; n<theBlobDetection[i].getBlobNb(); n++) {
      b=theBlobDetection[i].getBlob(n);
      if (b!=null) {
        tempBuffer.stroke(Color.HSBtoRGB((((float)i)/levels*colorRange+colorStart), 0.5, 0.5));
        for (int m=0; m<b.getEdgeNb(); m++) {
          eA = b.getEdgeVertexA(m);
          eB = b.getEdgeVertexB(m);
          if (eA !=null && eB !=null)
            tempBuffer.line(
              //eA.x*img.width*wfactor, eA.y*img.height*hfactor, 
              //eB.x*img.width*wfactor, eB.y*img.height*hfactor
              eA.x*img.width, eA.y*img.height, 
              eB.x*img.width, eB.y*img.height
              );
        }
      }
    }
  }

  void addToLeft(int l) {
    myX += l;
  }

  void addToTop(int t) {
    myY += t;
  }

  void addToRight(int r) {
    myWidth += r;
  }

  void addToBottom(int b) {
    myHeight += b;
  }

  public void start() {
    //super.start();
    running = true;
  }

  public void exit() {
    running = false;
    println("exiting blob thread");
  }
}