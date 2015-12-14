/********************************************************
 *
 * Helper classes below
 *
 ********************************************************/
 
class Point {
  float x = 0;
  float y = 0;
  
  Point(float _x, float _y){
    x = _x;
    y = _y;
  }
  
  void set(float _x, float _y) {
    x = _x;
    y = _y;
  }
}

class Size {
  float width = 0;
  float height = 0;
  
  Size(float w, float h){
    width = w;
    height = h;
  }
}

class Rect {
  Size size;
  Point pt;
  
  Rect(float x, float y, float w, float h) {
    this.pt = new Point(x,y);
    this.size = new Size(w,h);
  }
}

class EyeMove {
  float up = 0;
  float down = 0;
  float left = 0;
  float right = 0;
  
  void setEyeMoves(String[] values){

    String str = values[RtmIndexes.eyeMoveUp.ordinal()];
    if(str != null && str.length() > 0){
      up = float(str);
    }
    str = values[RtmIndexes.eyeMoveDown.ordinal()];
    if(str != null && str.length() > 0){
      down = float(str);
    }
    
    str = values[RtmIndexes.eyeMoveLeft.ordinal()];
    if(str != null && str.length() > 0){
      left = float(str);
    }
    
    str = values[RtmIndexes.eyeMoveRight.ordinal()];
    if(str != null && str.length() > 0){
      right = float(str);
    }
  }
}

class ColorPalette {
  
  float r = 0;
  float g = 0;
  float b = 0;
  
  ColorPalette(float _r, float _g, float _b){
    r = _r;
    g = _g;
    b = _b;
  }
}

class Acc {

  float x = 0;
  float y = 0;
  float z = 0;
  
  void setAccs(String[] values){

    String str = values[RtmIndexes.accX.ordinal()];
    if(str != null && str.length() > 0){
      x = float(str);
    }
    str = values[RtmIndexes.accY.ordinal()];
    if(str != null && str.length() > 0){
      y = float(str);
    }
    str = values[RtmIndexes.accZ.ordinal()];
    if(str != null && str.length() > 0){
      z = float(str);
    }
  }
}

class Gyro {

  float roll = 0;
  float pitch = 0;
  float yaw = 0;
  
  void setGyros(String[] values){

    String str = values[RtmIndexes.roll.ordinal()];
    if(str != null && str.length() > 0){
      roll = float(str);
    }
    str = values[RtmIndexes.pitch.ordinal()];
    if(str != null && str.length() > 0){
      pitch = float(str);
    }
    str = values[RtmIndexes.yaw.ordinal()];
    if(str != null && str.length() > 0){
      yaw = float(str);
    }
  }
}