import com.cage.zxing4p3.*;

class QRReader {
  
  ZXING4P zxing4p;
  
  PVector[] markers = null;

  String decodedText;
  String latestDecodedText = "";

  int tw;

  QRReader() {
    // CREATE A NEW EN-/DECODER INSTANCE
    zxing4p = new ZXING4P();

    // DISPLAY VERSION INFORMATION
    zxing4p.version();
  }
  
  void run(){
    // DISPLAY LATEST DECODED TEXT
  //if (!latestDecodedText.equals(""))
  //{
  //  tw = int(textWidth(latestDecodedText));
  //  fill(0, 150);
  //  rect((width>>1)-(tw>>1)-5, 15, tw+10, 36);
  //  fill(255);
  //  text(latestDecodedText, width>>1, 43);
  //  markers = zxing4p.getPositionMarkers();
  //}

  // TRY TO DETECT AND DECODE A QRCODE IN THE VIDEO CAPTURE
  // decodeImage(boolean tryHarder, PImage img)
  // tryHarder: false => fast detection (less accurate)
  //            true  => best detection (little slower)
  try
  {  
    decodedText = zxing4p.decodeImage(false, kinectthread.getVideo());
  }
  catch (Exception e)
  {  
    println("Zxing4processing exception: "+e);
    decodedText = "";
  }

  if (!decodedText.equals(""))
  { // FOUND A QRCODE!
    if (latestDecodedText.equals("") || (!latestDecodedText.equals(decodedText)))
      println("Zxing4processing detected: "+decodedText);
    latestDecodedText = decodedText;
  }
  
  //if (markers != null)
  //  {
  //    fill(255, 0, 0);
  //    stroke(255, 0, 0);
  //    strokeWeight(4);
  //    rectMode(CENTER);
  //    for (int i=0; i<markers.length; i++)
  //    {
  //      //int j = i+1;
  //      //if (j>3) j= 0;
  //      point(markers[i].x,markers[i].y);
  //      //line(markers[i].x, markers[i].y, markers[j].x, markers[j].y);
  //      //if (!dumped) println("x: "+markers[i].x+" y: "+markers[i].y);
  //    }
  //    //dumped = true;
  //  }
  }
}