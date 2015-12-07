import processing.net.*;

// You only need to check port number just as same as client's.
// IP Address is picked from your currently assigned local IP address.
int port = 60001;
boolean myServerRunning = true;
Server myServer;

int frameRateVal = 60;
int memeSamplePerSec = 20;  // JINS MEME is 20Hz 
int maxStockNum = memeSamplePerSec * 30;  // stock samples per 30sec
ArrayList<String[]> stockVals = new ArrayList<String[]>();
String prevDataStr = "";

/********************************************************
 *
 * processing defined callbacks
 *
 ********************************************************/
void setup()
{
  size(1024, 640);
  textFont(createFont("SanSerif", 12));
  
  myServer = new Server(this, port);    
  println("start listening...");
  
  frameRate(frameRateVal);
}

void mousePressed()
{
  // If the mouse clicked, myServer stops
  if (myServerRunning) {
      myServer.stop();
      myServerRunning = false;
  }else{    
    myServer = new Server(this, port);  
    myServerRunning = true;
    println("start listening...");
  }
}

void draw()
{
  // reset window
  background(200);
  textAlign(LEFT);
  
  // plot framelate
  text(str(frameRate), 5, height - 10);
  
  // plot always show datas for each draw() cycle
  plotEachDataLabels();
  
  // deal data
  if (!myServerRunning) {
    textAlign(LEFT);
    textSize(12);
    stroke(255);
    text("server stopped", 5, 15);
    return;
  }
  
  /* executed below if server is running */
  
  textAlign(LEFT);
  textSize(12);
  stroke(255);
  text("server running", 5, 15);
  
  // Retrieve tcp data and plot raw data as a texts
  String[] vals = retrieveData();
  // Update data array for display
  if(this.stockVals.size() >= maxStockNum) {
    this.stockVals.remove(0);
  }
  this.stockVals.add(vals);
  
  // Plot raw data
  plotEachRawVals();
  
  /* Plot each graph below */
  
  // surround blink speed/strength
  stroke(0);
  rect(140, 310, 400, height - 310);
  noFill();
  
  Rect eyeMoveRect = new Rect(140, 0, 400, 310);
  Rect blinkSpeedRect = new Rect(140, 310, 400, (height-310)*0.5);
  Rect blinkStrengthRect = new Rect(140, 310 + (height-310)*0.5, 400, (height-310)*0.5);
  Rect isWalkingRect = new Rect(540, height/3 * 2, width - 540, height/3);
  Rect accRect = new Rect(540, 0, width - 540, height/3);
  Rect gyroRect = new Rect(540, int(height/3 * 1), width - 540, height/3);
  
  plotEyeMoveGraphs(eyeMoveRect);
  
  // void plotDataGraph(String graphTitle, Rect rect, float maxY, int auxMod, int valIdx)
  plotDataGraph("blinkSpeed", blinkSpeedRect, 1000.0, 100, RtmIndexes.blinkSpeed.ordinal());
  plotDataGraph("blinkStrength", blinkStrengthRect, 200.0, 50, RtmIndexes.blinkStrength.ordinal());
  
  plotAccGraphs(accRect);
  plotGyroGraphs(gyroRect);
  plotDataGraph("isWalking", isWalkingRect, 2, 1, RtmIndexes.isWalking.ordinal());
}

/*********************************************************
 *
 * Private instance methods below
 *
 *********************************************************/

void plotEachDataLabels() {
    
  int xPos = 90;
  int yPos = 40;
  int yPosAdd = 15;
  
  // Labels
  textAlign(RIGHT);
  textSize(12);
  stroke(255);
  text("fitError:", xPos, yPos);
  yPos += yPosAdd;
  text("isWalking:", xPos, yPos);
  yPos += yPosAdd;
  text("powerLeft:", xPos, yPos);
  yPos += yPosAdd;
  text("eyeMoveUp:", xPos, yPos);
  yPos += yPosAdd;
  text("eyeMoveDown:", xPos, yPos);
  yPos += yPosAdd;
  text("eyeMoveLeft:", xPos, yPos);
  yPos += yPosAdd;
  text("eyeMoveRight:", xPos, yPos);
  yPos += yPosAdd;
  text("blinkSpeed:", xPos, yPos);
  yPos += yPosAdd;
  text("blinkStrength:", xPos, yPos);
  yPos += yPosAdd;
  text("roll:", xPos, yPos);
  yPos += yPosAdd;
  text("pitch:", xPos, yPos);
  yPos += yPosAdd;
  text("yaw:", xPos, yPos);
  yPos += yPosAdd;
  text("accX:", xPos, yPos);
  yPos += yPosAdd;
  text("accY:", xPos, yPos);
  yPos += yPosAdd;
  text("accZ:", xPos, yPos);
}

void plotEachRawVals()
{
  if (this.stockVals == null || stockVals.size() <= 0) {
    return;
  }
  
  String[] values = this.stockVals.get(this.stockVals.size()-1);
  if (values == null || values.length <= 0) {
    return;
  }
  
  int xPos = 95;
  int yPos = 40;
  int yPosAdd = 15;
  
  // Values
  textAlign(LEFT);
  textSize(12);
  stroke(255);
  text(values[RtmIndexes.fitError.ordinal()], xPos, yPos);
  yPos += yPosAdd;
  text(values[RtmIndexes.isWalking.ordinal()], xPos, yPos);
  yPos += yPosAdd;
  text(values[RtmIndexes.powerLeft.ordinal()], xPos, yPos);
  yPos += yPosAdd;
  text(values[RtmIndexes.eyeMoveUp.ordinal()], xPos, yPos);
  yPos += yPosAdd;
  text(values[RtmIndexes.eyeMoveDown.ordinal()], xPos, yPos);
  yPos += yPosAdd;
  text(values[RtmIndexes.eyeMoveLeft.ordinal()], xPos, yPos);
  yPos += yPosAdd;
  text(values[RtmIndexes.eyeMoveRight.ordinal()], xPos, yPos);
  yPos += yPosAdd;
  text(values[RtmIndexes.blinkSpeed.ordinal()], xPos, yPos);
  yPos += yPosAdd;
  text(values[RtmIndexes.blinkStrength.ordinal()], xPos, yPos);
  yPos += yPosAdd;
  text(values[RtmIndexes.roll.ordinal()], xPos, yPos);
  yPos += yPosAdd;
  text(values[RtmIndexes.pitch.ordinal()], xPos, yPos);
  yPos += yPosAdd;
  text(values[RtmIndexes.yaw.ordinal()], xPos, yPos);
  yPos += yPosAdd;
  text(values[RtmIndexes.accX.ordinal()], xPos, yPos);
  yPos += yPosAdd;
  text(values[RtmIndexes.accY.ordinal()], xPos, yPos);
  yPos += yPosAdd;
  text(values[RtmIndexes.accZ.ordinal()], xPos, yPos);
}

String[] retrieveData(){

  String[] vals = new String[0];
  Client thisClient = myServer.available();
  if (thisClient == null) {
    return vals; // <- empty
  }
  
  int bytesAvailable = thisClient.available();
  if (bytesAvailable <= 0) {
    return vals; // <- empty
  }

  byte[] byteBuffer = new byte[bytesAvailable];
  int byteCount = thisClient.readBytes(byteBuffer); 
  String readStr = new String(byteBuffer);
  //println(byte(lastLetter.charAt(0)));
  if (readStr == null || readStr.length() <= 0){
    return vals;  // <- empty 
  }

  println(readStr);

  if (byte(readStr.substring(readStr.length()-1).charAt(0)) != 10){
    prevDataStr = readStr;
    return vals;  // <- empty
  }
  
  if (prevDataStr.length() > 0) {
    readStr = prevDataStr + readStr;
    println(readStr);
    prevDataStr = "";
  }

  //String readStr = thisClient.readStringUntil(10);
  return vals = split(readStr, ',');
}

void plotEyeMoveGraphs(Rect rect) {
  
  float originX = rect.pt.x;
  float originY = rect.pt.y;
  float sizeWidth = rect.size.width;
  float sizeHeight = rect.size.height;
  
  int graphNum = 4;
  int eyeMoveFieldNum = 4;  // 0 ~ 3 
  float margin = 20;
  
  float graphWidth = sizeWidth - margin*2;
  float graphHeight = (sizeHeight - margin*(graphNum+1)) / graphNum;

  float graphOriginX = margin + originX;
  
  stroke(0);
  rect(originX, originY, sizeWidth, sizeHeight);
  noFill();
  
  for(int i=0; i<graphNum; i++){
    float graphOriginY = (i == 0) ? originY + margin : originY + graphHeight*i + margin*(i+1);
    
    // Draw title
    String graphTitle = "none";
    switch(i){
        case 0:
          graphTitle = "Up";
          break;
        case 1:
          graphTitle = "Down";
          break;
        case 2:
          graphTitle = "Left";
          break;        
        case 3:
          graphTitle = "Right";
          break;
        default:
          break;
    }
    textAlign(LEFT);
    textSize(12);
    stroke(0);
    text(graphTitle, graphOriginX, graphOriginY - 5);
    
    // Draw box outline
    rect(graphOriginX, graphOriginY, graphWidth, graphHeight);
    noFill();

    float auxResolutionY = graphHeight / eyeMoveFieldNum;
    float resolutionX = graphWidth / maxStockNum;

    textAlign(CENTER);
    textSize(8);
    stroke(0);
    text(str(eyeMoveFieldNum), graphOriginX - 10, graphOriginY);
    
    textAlign(CENTER);
    textSize(8);
    stroke(0);
    text("0", graphOriginX - 10, graphOriginY + (eyeMoveFieldNum * auxResolutionY));

    // Draw auxiliary line
//    for(int j=1; j<eyeMoveFieldNum; j++){
//      float auxOriginY = graphOriginY + (j * auxResolutionY);
//      drawDottedLine(graphOriginX, auxOriginY, graphOriginX + graphWidth, auxOriginY, 100);
//    }
    
    // Draw Graduation(per 10 second)
//    drawGraduation(graphOriginX, graphOriginY, resolutionX, graphHeight);

    // Draw each data
    Float aGraphOriginY = graphOriginY + graphHeight;  // think left bottom is the origin
    Point prevPt = new Point(graphOriginX, aGraphOriginY);
    for(int j=0; j < stockVals.size(); j++){
      
      String[] vals = stockVals.get(j);
      if(vals == null || vals.length <= 0){ continue; }
      
      EyeMove eye = new EyeMove(); 
      eye.setEyeMoves(vals);
      
      float eyeMoveVal = 0;
      switch(i){
        case 0:
          eyeMoveVal = eye.up;
          break;
        case 1:
          eyeMoveVal = eye.down;
          break;
        case 2:
          eyeMoveVal = eye.left;
          break;        
        case 3:
          eyeMoveVal = eye.right;
          break;
        default:
          break;
      }
      
      float destX = graphOriginX + resolutionX * (j+1);
      float destY = aGraphOriginY - auxResolutionY * eyeMoveVal;
      
      line(prevPt.x, prevPt.y, destX, destY);
      prevPt.set(destX, destY);
    }
        
  }
  
}

/*
  [ roll / pitch / yaw ] -180 <-> 0 <-> 179
 */
void plotGyroGraphs(Rect rect) {
  
  float originX = rect.pt.x;
  float originY = rect.pt.y;
  float sizeWidth = rect.size.width;
  float sizeHeight = rect.size.height;
  
  int lineNum = 3;
  float margin = 20;
  float maxY = 360;
  
  ColorPalette RollColor = new ColorPalette(212,4,4);  // almost red
  ColorPalette PitchColor = new ColorPalette(59,166,95);  // almost green
  ColorPalette YawColor = new ColorPalette(64,64,64);  // almost gray
  
  // Draw box outline
  rect(originX, originY, sizeWidth, sizeHeight);
  noFill();
  
  float graphWidth = sizeWidth - margin*2;
  float graphHeight = sizeHeight - margin*2;
  
  float graphOriginX = margin + originX;
  float graphOriginY = margin + originY;

  // Draw color sample
  float colSampleMargin = 5;
  float colSampleOriginY = originY + sizeHeight - colSampleMargin;
  float colSampleOriginX = originX + colSampleMargin;
  float colSampleWidth = 30;
  
  textAlign(LEFT);
  textSize(10);
  fill(RollColor.r, RollColor.g, RollColor.b);
  text("roll", colSampleOriginX, colSampleOriginY);

  colSampleOriginX += colSampleWidth - 10;
  fill(PitchColor.r, PitchColor.g, PitchColor.b);
  text("pitch", colSampleOriginX, colSampleOriginY);

  colSampleOriginX += colSampleWidth;
  fill(YawColor.r, YawColor.g, YawColor.b);
  text("yaw", colSampleOriginX, colSampleOriginY);  

  noFill();
  
  // Draw title
  textAlign(LEFT);
  textSize(12);
  stroke(0);
  text("Head angle", graphOriginX, graphOriginY - 5);

  // Draw graph outline
  stroke(0);
  rect(graphOriginX, graphOriginY, graphWidth, graphHeight);
  noFill();
    
  float resolutionX = graphWidth / maxStockNum;
  float resolutionY = graphHeight / maxY;
  
  textAlign(CENTER);
  textSize(8);
  stroke(0);
  text("179", graphOriginX - 10, graphOriginY);
  
  textAlign(CENTER);
  textSize(8);
  stroke(0);
  text("0", graphOriginX - 10, graphOriginY + (maxY*0.5 * resolutionY));

  textAlign(CENTER);
  textSize(8);
  stroke(0);
  text("-180", graphOriginX - 10, graphOriginY + (maxY * resolutionY));
      
  // Draw auxiliary line
/*  
  for(int j=0; j<maxY; j++){
    if (j%(maxY/2) <= 0){
      float auxOriginY = graphOriginY + (j * resolutionY);
      drawDottedLine(graphOriginX, auxOriginY, graphOriginX + graphWidth, auxOriginY, 100);
    }
  }
*/
  // Draw Graduation(per 10 second)
//  drawGraduation(graphOriginX, graphOriginY, resolutionX, graphHeight);

  if (this.stockVals == null || this.stockVals.size() <= 0){
    return;
  }
  
  Float aGraphOriginY = graphOriginY + graphHeight;  // think left bottom is the origin
  Float offsetY = resolutionY * maxY/2;

  // Draw each data
  Point prevPtRoll = new Point(graphOriginX, aGraphOriginY - offsetY);
  Point prevPtPitch = new Point(graphOriginX, aGraphOriginY - offsetY);
  Point prevPtYaw = new Point(graphOriginX, aGraphOriginY - offsetY);

  for(int j=0; j < stockVals.size(); j++){
    
    String[] vals = stockVals.get(j);
    if(vals == null || vals.length <= 0){ continue; }
    
    Gyro gyro = new Gyro();
    gyro.setGyros(vals);
    
    // Draw roll
    float destX = graphOriginX + resolutionX * (j+1);
    float destY = aGraphOriginY - resolutionY * gyro.roll - offsetY;
    stroke(RollColor.r, RollColor.g, RollColor.b);
    line(prevPtRoll.x, prevPtRoll.y, destX, destY);
    prevPtRoll.set(destX, destY);
    
    // Draw pitch
    destX = graphOriginX + resolutionX * (j+1);
    destY = aGraphOriginY - resolutionY * gyro.pitch - offsetY;
    stroke(PitchColor.r, PitchColor.g, PitchColor.b);
    line(prevPtPitch.x, prevPtPitch.y, destX, destY);
    prevPtPitch.set(destX, destY);

    // Draw yaw
    destX = graphOriginX + resolutionX * (j+1);
    destY = aGraphOriginY - resolutionY * gyro.yaw - offsetY;
    stroke(YawColor.r, YawColor.g, YawColor.b);
    line(prevPtYaw.x, prevPtYaw.y, destX, destY);
    prevPtYaw.set(destX, destY);
    
  }
}


/*
  -128 <-> 0 <-> 127
 */
void plotAccGraphs(Rect rect) {
  
  float originX = rect.pt.x;
  float originY = rect.pt.y;
  float sizeWidth = rect.size.width;
  float sizeHeight = rect.size.height;
  
  int lineNum = 3;
  float margin = 20;
  float maxY = 256;
  
  ColorPalette accXColor = new ColorPalette(212,4,4);  // almost red
  ColorPalette accYColor = new ColorPalette(59,166,95);  // almost green
  ColorPalette accZColor = new ColorPalette(64,64,64);  // almost gray
  
  // Draw box outline
  rect(originX, originY, sizeWidth, sizeHeight);
  noFill();
  
  float graphWidth = sizeWidth - margin*2;
  float graphHeight = sizeHeight - margin*2;
  
  float graphOriginX = margin + originX;
  float graphOriginY = margin + originY;

  // Draw color sample
  float colSampleMargin = 5;
  float colSampleOriginY = originY + sizeHeight - colSampleMargin;
  float colSampleOriginX = originX + colSampleMargin;
  float colSampleWidth = 30;
  
  textAlign(LEFT);
  textSize(10);
  fill(accXColor.r, accXColor.g, accXColor.b);
  text("accX", colSampleOriginX, colSampleOriginY);

  colSampleOriginX += colSampleWidth;
  fill(accYColor.r, accYColor.g, accYColor.b);
  text("accY", colSampleOriginX, colSampleOriginY);

  colSampleOriginX += colSampleWidth;
  fill(accZColor.r, accZColor.g, accZColor.b);
  text("accZ", colSampleOriginX, colSampleOriginY);  

  noFill();

  // Draw title
  textAlign(LEFT);
  textSize(12);
  stroke(0);
  text("Acc", graphOriginX, graphOriginY - 5);

  // Draw graph outline
  rect(graphOriginX, graphOriginY, graphWidth, graphHeight);
  noFill();
    
  float resolutionX = graphWidth / maxStockNum;
  float resolutionY = graphHeight / maxY;
  
  textAlign(CENTER);
  textSize(8);
  stroke(0);
  text("127", graphOriginX - 10, graphOriginY);
  
  textAlign(CENTER);
  textSize(8);
  stroke(0);
  text("0", graphOriginX - 10, graphOriginY + (maxY*0.5 * resolutionY));

  textAlign(CENTER);
  textSize(8);
  stroke(0);
  text("-128", graphOriginX - 10, graphOriginY + (maxY * resolutionY));
  
  // Draw auxiliary line
//  for(int j=0; j<maxY; j++){
//    if (j%(maxY/2) <= 0){
//      float auxOriginY = graphOriginY + (j * resolutionY);
//      drawDottedLine(graphOriginX, auxOriginY, graphOriginX + graphWidth, auxOriginY, 100);      
//    }
//  }
  // Draw Graduation(per 10 second)
//  drawGraduation(graphOriginX, graphOriginY, resolutionX, graphHeight);

  if (this.stockVals == null || this.stockVals.size() <= 0){
    return;
  }
  
  Float aGraphOriginY = graphOriginY + graphHeight;  // think left bottom is the origin
  Float offsetY = resolutionY * maxY/2;
    
  // Draw each data
  Point prevPtX = new Point(graphOriginX,aGraphOriginY - offsetY);
  Point prevPtY = new Point(graphOriginX,aGraphOriginY - offsetY);
  Point prevPtZ = new Point(graphOriginX,aGraphOriginY - offsetY);

  for(int j=0; j < stockVals.size(); j++){
    
    String[] vals = stockVals.get(j);
    if(vals == null || vals.length <= 0){ continue; }
    
    Acc acc = new Acc(); 
    acc.setAccs(vals);
    
    // Draw accX
    float destX = graphOriginX + resolutionX * (j+1);
    float destY = aGraphOriginY - resolutionY * acc.x - offsetY;
    stroke(accXColor.r,accXColor.g,accXColor.b);
    line(prevPtX.x, prevPtX.y, destX, destY);
    prevPtX.set(destX, destY);
    
    // Draw accY
    destX = graphOriginX + resolutionX * (j+1);
    destY = aGraphOriginY - resolutionY * acc.y - offsetY;
    stroke(accYColor.r,accYColor.g,accYColor.b);
    line(prevPtY.x, prevPtY.y, destX, destY);
    prevPtY.set(destX, destY);

    // Draw accZ
    destX = graphOriginX + resolutionX * (j+1);
    destY = aGraphOriginY - resolutionY * acc.z - offsetY;
    stroke(accZColor.r,accZColor.g, accZColor.b);
    line(prevPtZ.x, prevPtZ.y, destX, destY);
    prevPtZ.set(destX, destY);
    
  }
}

/*
 * maxY: the maximum value of this meme data
 * auxMod: defines how offten auxiliary line drawn (not used) 
 * valIdx: the meme data array's index which can be assigned by RtmIndexes
 */
void plotDataGraph(String graphTitle, Rect rect, float maxY, int auxMod, int valIdx) {

  float originX = rect.pt.x;
  float originY = rect.pt.y;
  float sizeWidth = rect.size.width;
  float sizeHeight = rect.size.height;
  
  float margin = 20;
  
  float graphWidth = sizeWidth - margin*2;
  float graphHeight = sizeHeight - margin*2;

  float graphOriginX = margin + originX;
  float graphOriginY = margin + originY;  // Upper left is the origin at this time
    
  // Draw title
  textAlign(LEFT);
  textSize(12);
  stroke(0);
  text(graphTitle, graphOriginX, graphOriginY - 5);
  
  // Draw box outline
  rect(graphOriginX, graphOriginY, graphWidth, graphHeight);
  noFill();

  float auxResolutionY = graphHeight / maxY;
  float resolutionX = graphWidth / maxStockNum;

  textAlign(CENTER);
  textSize(8);
  stroke(0);
  text(str(int(maxY)), graphOriginX - 10, graphOriginY);
  
  textAlign(CENTER);
  textSize(8);
  stroke(0);
  text("0", graphOriginX - 10, graphOriginY + (maxY * auxResolutionY));

  // Draw auxiliary line
//  for(int j=1; j<maxY; j++){
//    if(j%auxMod <= 0){
//      float auxOriginY = graphOriginY + (j * auxResolutionY);
//      drawDottedLine(graphOriginX, auxOriginY, graphOriginX + graphWidth, auxOriginY, 100);
//    }
//  }
  // Draw Graduation(in second)
//  drawGraduation(graphOriginX, graphOriginY, resolutionX, graphHeight);
      
  if (this.stockVals == null || this.stockVals.size() <= 0){
    return;
  }
    
  // Draw each data
  Float aGraphOriginY = graphOriginY + graphHeight;  // think left bottom is the origin 
  Point prevPt = new Point(graphOriginX, aGraphOriginY);
  for(int j=0; j < stockVals.size(); j++){
    
    String[] vals = stockVals.get(j);
    if(vals == null || vals.length <= 0){ continue; }
    
    String valStr = vals[valIdx];
    if(valStr == null || valStr.length() <= 0){ continue; }
    
    float destX = graphOriginX + resolutionX * (j+1);
    float destY = aGraphOriginY - auxResolutionY * float(valStr);
    
    line(prevPt.x, prevPt.y, destX, destY);
    prevPt.set(destX, destY);
  }
}

void drawGraduation(float originX, float originY, float resolutionX, float graphHeight) {
  
  // Draw graduation
 for(int k=0; k < maxStockNum; k++){
   // per 1 Sec
   if (k%memeSamplePerSec <= 0){
     float gradX = originX + resolutionX * k;
     float gradY = originY + graphHeight;
     line(gradX, gradY, gradX, gradY-3);
   }
   // per 10 Sec
   if (k%(memeSamplePerSec*10) <= 0){
     float xPos = originX + resolutionX * k;
     float yPos = originY + graphHeight + 9;
     textAlign(CENTER);
     textSize(8);
     stroke(0);
     text(str(k/memeSamplePerSec), xPos, yPos);
   }
 }
}

void drawDottedLine(float x1, float y1, float x2, float y2, float dotDensity) {
  for (int i = 0; i <= dotDensity; i++) {
    float x = lerp(x1, x2, i/dotDensity);
    float y = lerp(y1, y2, i/dotDensity);
    point(x, y);
  }
}