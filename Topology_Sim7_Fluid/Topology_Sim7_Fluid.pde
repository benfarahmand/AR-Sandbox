import java.awt.Color;
import nl.tue.id.oocsi.*;
import java.util.*;

FluidThread fluidthread;             

boolean gradientBufferReady=false, calibrate=false;
PImage image, tempImage, initialImage;
float[] gradients, tempGradients;
int[] imagepixels, imagedim;
int shift;

void setup() {
  size(1280, 768, P2D);
  //shift = width*height+width;
  imagedim = new int[4];
  fluidthread = new FluidThread(this);
  image = createImage(width, height, RGB);
  tempImage = createImage(width, height, RGB);
  OOCSI oocsi = new OOCSI(this, "fluid" + System.currentTimeMillis(), "localhost");
  oocsi.subscribe("datachannel");
  frameRate(60);
}

void draw() { 
  background(0);
  if (calibrate) {
    if (initialImage != null && imagepixels!=null) {
      initialImage.loadPixels();
      for (int i = 0; i < imagepixels.length; i++) {
        initialImage.pixels[i]=imagepixels[i];
      }
      //for (int i = 0; i < imagepixels.length; i++) {
      //  initialImage.pixels[i]=imagepixels[imagepixels.length-i-1];
      //}
      initialImage.updatePixels();
      image.copy(initialImage, 0, 0, initialImage.width, initialImage.height, 0, 0, width, height);
      //scale(-1, 1); // You had it right!
      image(image, 0, 0, width, height);    
      tempImage.copy(image, 0, 0, width, height, 0, 0, width, height);
    } else {
      //pushMatrix();
      //scale(-1, 1); // You had it right!
      image(tempImage, 0, 0, width, height);
      //popMatrix();
    }
    //if(gradients!=null)println(gradients[10][10][0]);
    fluidthread.run();
  }
  stroke(255);
  text(frameRate, width-20, height-10);
  text(fluidthread.getParticleCount(), width-80, height-10);
}

public void keyReleased() {
  if (key == 't') fluidthread.UPDATE_PHYSICS = !fluidthread.UPDATE_PHYSICS;
  if (key == 'r') fluidthread.reset();
  if (key == 'f') fluidthread.USE_DEBUG_DRAW = !fluidthread.USE_DEBUG_DRAW;
  if (key == 'p') fluidthread.createParticles = !fluidthread.createParticles;
  if (key == 'g') fluidthread.APPLY_LIQUID_FX = !fluidthread.APPLY_LIQUID_FX;
}

//void mouseMoved() {
//  if (gradients!=null) println("Vx: "+gradients[mouseY*width+mouseX]+" Vy: "+gradients[mouseY*width+mouseX+shift]);
//}

void datachannel(OOCSIEvent event) {

  // get, cast and save array value
  gradients = (float[]) event.getObject("array");
  if (event.has("array")) {
    gradientBufferReady = false;
    arrayCopy(gradients, tempGradients, gradients.length);
    //for(int i = 0 ; i < gradients.length ; i ++){
    //  tempGradients[i] = gradients[gradients.length-i-1];

    //}
    gradientBufferReady = true;
  }
  // get, cast and save Date object value
  imagepixels = (int[]) event.getObject("image pixels");
  if (event.has("image dimensions") && !calibrate) {
    imagedim = (int[]) event.getObject("image dimensions");
    initialImage = createImage(imagedim[2], imagedim[3], RGB);
    shift = imagedim[2]*imagedim[3]+imagedim[2];
    tempGradients = new float[2*shift];
    gradients = new float[2*shift];
    calibrate=true;
  }
}