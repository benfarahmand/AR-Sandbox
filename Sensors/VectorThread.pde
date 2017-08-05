class VectorThread {//extends Thread {

  boolean running = false, gradientsReady = false, bufferReady = false;
  PImage img; //this is the alpha image containing the depth information
  //float[][][] gradients, tempGradients; //third dimension is velocity, 1st index = x, 2nd index = y
  float[] gradients, tempGradients; //second dimension is velocity, 1st index = x, 2nd index = y
  //int wfactor, hfactor;
  PGraphics buffer, tempBuffer;
  int resolution=1;
  int myWidth, myHeight;

  VectorThread() {
    //gradients = new float[width][height][2]; //for 2d array: it would be height*width+width, then to access it, it's y*width+x
    //tempGradients = new float[width][height][2];
    gradients = new float[2*(height*width+width)]; //for 2d array: it would be height*width+width, then to access it, it's y*width+x
    tempGradients = new float[2*(height*width+width)];
    buffer = createGraphics(width, height);
    tempBuffer = createGraphics(width, height);
  }

  VectorThread(int w, int h) {
    //gradients = new float[width][height][2]; //for 2d array: it would be height*width+width, then to access it, it's y*width+x
    //tempGradients = new float[width][height][2];
    gradients = new float[2*(h*w+w)]; //for 2d array: it would be height*width+width, then to access it, it's y*width+x
    tempGradients = new float[2*(h*w+w)];
    buffer = createGraphics(w, h);
    tempBuffer = createGraphics(w, h);
    myWidth = w;
    myHeight = h;
  }
  
  //float[] getGradients() {
  //  if (gradientsReady) return tempGradients;
  //  else return gradients;
  //}
  
  float[] getGradients() {
    return gradients;
  }
  
  PGraphics display() {
    return tempBuffer;
  }
  
  //PGraphics display() {
  //  if (bufferReady) return tempBuffer;
  //  else return buffer;
  //}

  void run() {
    //println("entered vector thread run");
    if (running) {
      try {
          //img = new PImage(kinectthread.display().width, kinectthread.display().height);
          //img.copy(kinectthread.display(), 0, 0, kinectthread.display().width, kinectthread.display().height, 0, 0, img.width, img.height);
          //wfactor = width/img.width;
          //hfactor = height/img.height;
          //gradientsReady = false;
          calculateVelocityVectors(kinectthread.display());
          //gradientsReady = true;
          //copyGradients();
          if (DRAW_VECTORS) {
            bufferReady = false;
            drawVectors(tempBuffer);
            bufferReady = true;
            buffer = copyGraphics(tempBuffer, buffer);
          }
          //Thread.sleep(5000);
          //oocsi.channel("datachannel").data("array", (float[]) getGradients()).send();
      }
      //catch(InterruptedException ie) {
      //  println("Child thread interrupted! " + ie);
      //} 
      catch (Exception e) {
        println("vector Thread: "+e.toString());
      }
    }
  }

  void drawVectors(PGraphics pg) {
    pg.beginDraw();
    pg.clear();
    //pg.strokeWeight(wfactor*hfactor);
    for (int x = 0; x < myWidth; x++) {
      for (int y = 0; y < myHeight; y++) {
        //pg.fill(map(getGradients()[y*width+x][0],minX,maxX,0.0,255.0),map(getGradients()[y*width+x][1],minY,maxY,0.0,255.0),0);
        //pg.point(x*wfactor,y*hfactor);
        //pg.rect(x*wfactor,y*hfactor,wfactor*hfactor,wfactor*hfactor);
        pg.stroke(200, 0, 0);
        pg.point(x*wfactor, y*hfactor);
        pg.stroke(0, 200, 0);
        //pg.point(x*wfactor+getGradients()[x][y][0],y*hfactor+getGradients()[x][y][1]);
        pg.point(x*wfactor+getGradients()[y*myWidth+x], y*hfactor+getGradients()[y*myWidth+x+shift]);
        pg.stroke(200);
        //pg.line(x*wfactor,y*hfactor,x*wfactor+getGradients()[x][y][0],y*hfactor+getGradients()[x][y][1]);
        pg.line(x*wfactor, y*hfactor, x*wfactor+getGradients()[y*myWidth+x], y*hfactor+getGradients()[y*myWidth+x+shift]);
      }
    }
    pg.endDraw();
  }

  void calculateVelocityVectors(PImage pi) {
    //pi.loadPixels();
    //println(brightness(pi.get(34,72)));
    //println(brightness(pi.get(233,265)));
    for (int x = 1+resolution; x < myWidth-(1+resolution); x+=resolution) {
      for (int y = 1+resolution; y < myHeight-(1+resolution); y+=resolution) {
        //int depth = pi.get(x,y); 
        float top = brightness(pi.get(x, y+1));
        float bottom = brightness(pi.get(x, y-1));
        float left = brightness(pi.get(x-1, y));
        float right = brightness(pi.get(x+1, y));
        //gradients[x][y][0] = (bottom - top); //velocity in x direction
        //gradients[x][y][1] = (right - left); //velocity in y direction
        gradients[y*myWidth+x+(shift)] = -(bottom - top); //velocity in x direction
        gradients[y*myWidth+x] = -(right - left); //velocity in y direction
      }
    }
  }

  void copyGradients() {
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        //tempGradients[x][y][0] = gradients[x][y][0]; 
        //tempGradients[x][y][1] = gradients[x][y][1];
        tempGradients[y*width+x] = gradients[y*width+x]; 
        tempGradients[y*width+x+shift] = gradients[y*width+x+shift];
      }
    }
  }

  public void start() {
    //super.start();
    running = true;
  }

  public void exit() {
    running = false;
    println("exiting vector thread");
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
}