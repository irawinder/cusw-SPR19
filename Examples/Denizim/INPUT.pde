//  Input -1 = none
//  Input  0 = drag
//  Input  1 = horizontal scroll bar
//  Input  2 = vertical scroll bar
int activeInput = -1;

void updateInputs() {
  
  // Fade input controls when not in use
  if (mousePressed) {
    uiFade = 1.0;
    fadeTimer = FADE_TIMER;
  } else {
    if (fadeTimer > 0) {
      fadeTimer--;
    } else {
      if (uiFade > 0.1) {
        uiFade *= 0.99;
      } else {
        uiFade = 0;
      }
    }
  }
  
  // Update All Scroll and Drag Inputs
  if (!mousePressed) {
    if (drag.updating()) {
      drag.update();
      camOffset.x = drag.getX();
      camOffset.y = drag.getY();
    }
    hs.update();
    camRotation = hs.getPosPI();
    vs.update();
    camZoom = vs.getPosZoom();
    
  // Update Drag Only
  } else if (activeInput == 0) {
    drag.update();
    camOffset.x = drag.getX();
    camOffset.y = drag.getY();
    
  // Update Horizontal Scroll Bar Only
  } else if (activeInput == 1) {
    hs.update();
    camRotation = hs.getPosPI();
    
  // Update Vertical Scroll Bar Only
  } else if (activeInput == 2) {
    vs.update();
    camZoom = vs.getPosZoom();
  }
}

class HScrollbar {
  int swidth, sheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // x position of slider
  float sposMin, sposMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;

  HScrollbar (float xp, float yp, int sw, int sh, int l) {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos = xpos + swidth/2 - sheight/2;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    loose = l;
  }

  void update() {
    if (overEvent()) {
      over = true;
    } else {
      over = false;
    }
    if (mousePressed && over) {
      locked = true;
    }
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
    }
    if (abs(newspos - spos) > 0.05) {
      spos = spos + (newspos-spos)/loose;
    }
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  boolean overEvent() {
    if (mouseX > xpos && mouseX < xpos+swidth &&
       mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

  void display() {
    noStroke();
    fill(204, baseAlpha);
    rect(xpos, ypos, swidth, sheight, sheight);
    if (over || locked) {
      fill(lnColor, baseAlpha);
    } else {
      fill(102, baseAlpha);
    }
    ellipse(spos + sheight/2, ypos + sheight/2, sheight, sheight);
    fill(lnColor, 255);
    textAlign(CENTER, BOTTOM);
    text("ROTATION", xpos + swidth/2, ypos - 14);
  }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return spos * ratio;
  }
  
  float getPosPI() {
    // Convert spos to be values between
    // 0 and 2PI
    return 2 * PI * (spos-sposMin) / (swidth-sheight);
  }
}

class VScrollbar {
  int swidth, sheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // y position of slider
  float sposMin, sposMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;

  VScrollbar (float xp, float yp, int sw, int sh, int l) {
    swidth = sw;
    sheight = sh;
    int heighttowidth = sw - sh;
    ratio = (float)sh / (float)heighttowidth;
    xpos = xp-swidth/2;
    ypos = yp;
    spos = sheight/2;
    newspos = spos;
    sposMin = ypos;
    sposMax = ypos + sheight - swidth;
    loose = l;
  }

  void update() {
    if (overEvent()) {
      over = true;
    } else {
      over = false;
    }
    if (mousePressed && over) {
      locked = true;
    }
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      newspos = constrain(mouseY-swidth/2, sposMin, sposMax);
    }
    if (abs(newspos - spos) > 0.05) {
      spos = spos + (newspos-spos)/loose;
    }
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  boolean overEvent() {
    if (mouseX > xpos && mouseX < xpos+swidth &&
       mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

  void display() {
    noStroke();
    fill(204, 2*baseAlpha);
    rect(xpos, ypos, swidth, sheight, swidth);
    if (over || locked) {
      fill(lnColor, 2*baseAlpha);
    } else {
      fill(102, 4*baseAlpha);
    }
    ellipse(xpos + swidth/2, spos + swidth/2, swidth, swidth);
    fill(lnColor, 255);
    textAlign(CENTER, TOP);
    text("ZOOM", xpos + swidth/2, ypos + sheight + 21);
  }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return spos * ratio;
  }
  
  float getPosZoom() {
    // Convert spos to be values between
    // 0 and 2PI
    return MIN_ZOOM + (MAX_ZOOM - MIN_ZOOM) * spos / float(sheight);
  }
}

class XYDrag {
  float scaler;
  float loose;
  
  float x_init;
  float y_init;
  float x_offset;
  float y_offset;
  float x_smooth;
  float y_smooth;
  
  float x, y;
  
  float camX_init;
  float camY_init;
  
  // Extent of Clickability
  int extentX;
  int extentY;
  int extentW;
  int extentH;
  
  XYDrag(float s, float l, int eX, int eY, int eW, int eH ) {
    scaler = s;
    loose = l;
    
    extentX = eX;
    extentY = eY;
    extentW = eW;
    extentH = eH;
  }
  
  boolean inExtents() {
    if (mouseX > extentX && mouseX < extentX+extentW && mouseY > extentY && mouseY < extentY+extentH) {
      return true; 
    } else {
      return false;
    }
  }
  
  void init() {
    x_init = mouseX;
    y_init = mouseY;
    camX_init = camOffset.x;
    camY_init = camOffset.y;
    x_smooth = 0;
    y_smooth = 0;
  }
  
  void update() {
    if (mousePressed) {
      x_offset = - (mouseX - x_init);
      y_offset = - (mouseY - y_init);
    }
    if (abs(x_smooth - x_offset) > 1) {
      x_smooth = x_smooth + (x_offset-x_smooth)/loose;
    }
    if (abs(y_smooth - y_offset) > 1) {
      y_smooth = y_smooth + (y_offset-y_smooth)/loose;
    }
    x = scaler*x_smooth;
    y = scaler*y_smooth;
  }
  
  boolean updating() {
    if (abs(x_smooth - x_offset) > 1 || abs(y_smooth - y_offset) > 1) {
      return true;
    } else {
      return false;
    }
  }
  
  // Coordinate Rotation Transformation:
  // x' =   x*cos(theta) + y*sin(theta)
  // y' = - x*sin(theta) + y*cos(theta)
  
  float getX() {
    return camX_init + x*cos(camRotation) + y*sin(camRotation);
  }
  
  float getY() {
    return camY_init - x*sin(camRotation) + y*cos(camRotation);
  }
}

void mousePressed() {
  
  // Determine which output is active
  if (hs.overEvent()) {
    activeInput = 1;
  } else if (vs.overEvent()) {
    activeInput = 2;
  } else if (drag.inExtents()) {
    activeInput = 0;
    drag.init();
  } else {
    activeInput = -1;
  }
}

void mouseClicked() {
  Field f = city.get(cityIndex);
  float fieldX = f.boundary.x*(mouseX - 0.25*width)/(0.5*width); 
  float fieldY = f.boundary.y*(mouseY - 0.15*height)/(0.7*height);
  fieldX = constrain(fieldX, 0, f.boundary.x);
  fieldY = constrain(fieldY, 0, f.boundary.y);
  
  if (f.blockEditing) {
    Block b;
    b = new Block(fieldX, fieldY, 50, 50, 0);
    f.blocks.add(b);
    if (f.blocks.size() > 1) {
      f.selectedBlock = f.blocks.size()-1;
    }
  } else {
    Sensor s = new Sensor(fieldX, fieldY);
    f.beacons.add(s);
  }
}

void mouseMoved() {
  uiFade = 1.0;
  fadeTimer = FADE_TIMER;
}

void keyPressed() {
  uiFade = 1.0;
  fadeTimer = FADE_TIMER;
  
  Field f = city.get(cityIndex);
  
  if (f.blockEditing) {
    switch(key) {
      case 'S':
        f.saveBlocks();
        break;
      case 'L':
        f.loadBlocks(cityIndex + "/" +"blockTable.tsv");
        break;
    }
    
    if (f.blocks.size() > 0) {
      Block b = f.blocks.get(f.selectedBlock);
      switch(key) {
        case ']':
          f.nextBlock();
          break;
        case '[':
          f.lastBlock();
          break;
        case 'd':
          f.removeBlock();
          break;
        case 'b':
          f.randomizeBlocks();
          break;
        case '1':
          b.l -= 2;
          break;
        case '2':
          b.l += 2;
          break;
        case '3':
          b.w -= 2;
          break;
        case '4':
          b.w += 2;
          break;
        case '5':
          b.h -= 2;
          break;
        case '6':
          b.h += 2;
          break;
      }
      
      if (key == CODED) { 
        if (keyCode == LEFT) {
          b.loc.x -= 2; 
        }  
        if (keyCode == RIGHT) {
          b.loc.x += 2; 
        }  
        if (keyCode == DOWN) {
          b.loc.y -= 2;
        }  
        if (keyCode == UP) {
          b.loc.y += 2;
        }
      }
    }
   
  } else {
    
    switch(key) {
      case '0':
        f.randomBeacons(0);
        break;
      case '1':
        f.randomBeacons(1);
        break;
      case '2':
        f.randomBeacons(2);
        break;
      case '3':
        f.randomBeacons(3);
        break;
      case '4':
        f.randomBeacons(4);
        break;
      case '5':
        f.randomBeacons(5);
        break;
    }
  }
  
  switch(key) {
    case 'r':
      uiFade = 1.0;
      fadeTimer = FADE_TIMER;
      resetControls();
      break;
    case 'p':
      f.randomizePeople();
      break;
    //case 'i':
    //  initFields();
    //  break;
    case 'm':
      drawMap = !drawMap;
      f.showPaths = !f.showPaths;
      break;
    //case 'B':
    //  f.blockEditing = !f.blockEditing;
    //  println("Editing Blocks: " + f.blockEditing);
    //  break;
    //case 'F':
    //  f.fenceEditing = !f.fenceEditing;
    //  println("Editing Fences: " + f.fenceEditing);
    //  break;
    //case 'f':
    //  f.showPaths = !f.showPaths;
    //  break;
    case 'i':
      invertColors();
      break;
    case 'h':
      showUI = !showUI;
      break;
  }
}

// resets and centers camera view
void resetControls() {
  hs.newspos = hs.xpos + hs.swidth/2 - hs.sheight/2;
  vs.newspos = vs.sposMin + 0.1*vs.sheight;
  drag.x_offset = 0;
  drag.y_offset = 0;
  drag.camX_init = CAMX_DEFAULT;
  drag.camY_init = CAMY_DEFAULT;
}
