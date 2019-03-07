/*  CAMERA ALGORITHMS
 *  Ira Winder, ira@mit.edu, 2018
 *
 *  This script demonstrates the implementation of a "Camera" class that has ready-made
 *  UI, Sliders, Radio Buttons, I/O, and smooth camera transitions. For a generic 
 *  implementation check out the repo at: http://github.com/irawinder/UI3D
 *
 *  CLASSES CONTAINED:
 *
 *    Camera()     - The primary container for implementing and editing Camera parameters
 *    HScollbar()  - A horizontal Slider bar
 *    VScrollBar() - A Vertical Slider Bar
 *    XYDrag()     - A Container for implmenting click-and-drag 3D Navigation
 *    Chunk()      - A known, fixed volume of space
 *    ChunkGrid()  - A grid of Chunks in 3D space that are accessible via the mouse cursor
 *
 *  MIT LICENSE: Copyright 2018 Ira Winder
 *
 *               Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
 *               and associated documentation files (the "Software"), to deal in the Software without restriction, 
 *               including without limitation the rights to use, copy, modify, merge, publish, distribute, 
 *               sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
 *               furnished to do so, subject to the following conditions:
 *
 *               The above copyright notice and this permission notice shall be included in all copies or 
 *               substantial portions of the Software.
 *
 *               THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT 
 *               NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
 *               NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
 *               DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
 *               OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
 
class Camera {
  PVector boundary;
  
  // Camera Parameters:
  float rotation;
  float zoom;
  PVector offset;
  
  // Camera Defaults
  float ROTATION_DEFAULT;
  float ZOOM_DEFAULT;
  float X_DEFAULT;
  float Y_DEFAULT;
  
  // Zoom Constraints
  float ZOOM_MAX;
  float ZOOM_MIN;
  float ZOOM_POW;
  
  // UI: Click and Drad Extents
  int eX, eY, eW, eH; // x, y, width, height of bounding box where clicking and dragging is valid
  
  // UI: Scrollbars (horizontal and vertical)
  //
  HScrollbar hs;
  VScrollbar vs;

  // UI: Mouse Drag Information
  //
  XYDrag drag;
  
  // UI: Chunks used for selecting area in 3D
  //
  boolean enableChunks;
  ChunkGrid chunkField;
  
  // UI: Active UI Input
  // Input -1 = none
  // Input  0 = drag
  // Input  1 = horizontal scroll bar
  // Input  2 = vertical scroll bar
  //
  int activeInput = -1;
  
  // UI: Superficial Parameters for drawing slider bars and text
  //
  int margin;            // Pixels to use as buffer margin for UI
  int LINE_COLOR = 255;  // (0-255) Default color for lines, text, etc
  int BASE_ALPHA = 50;   // (0-255) Default baseline alpha value
  
  // UI: Transparency fades over time
  //
  int FADE_TIMER = 300;
  int fadeTimer = 300;
  float uiFade = 1.0;  // 0.0 - 1.0
  int MOVE_TIMER = 120;
  int moveTimer = 120;
  
  // UI: Chunks used for selecting area in 3D
  //
  int CHUNK_RESOLUTION = 20; // length of chunk units
  int CHUNK_TIMER = 5; // Amounts of ticks between chunk detection
  int chunkTimer  = 5;
  
  // UI: Show Frame Rate
  //
  boolean showFrameRate;
  
  Camera(PVector boundary, int margin) {
    this.boundary = boundary;
    this.margin = margin;
    
    // Initialize the Camera
    ROTATION_DEFAULT = PI; // (0 - 2*PI)
    X_DEFAULT = 0;
    Y_DEFAULT = 0;
    ZOOM_MAX = 0.0;
    ZOOM_MIN = 1.0;
    ZOOM_POW = 3.0;
    ZOOM_DEFAULT = 0.6;
    
    // Initial click and dragging UI contraints
    eX = 0;
    eY = 0;
    eW = width;
    eH = height;
    
    // Allow 3D mouse cursor object to select chunks
    enableChunks = true;
    
    init();
  }
  
  void init() {
    zoom = ZOOM_DEFAULT;
    rotation = ROTATION_DEFAULT;
    offset = new PVector(X_DEFAULT, Y_DEFAULT);
    int thirdPix  = int(0.3*height);
    
    // Initialize Horizontal Scrollbar
    hs = new HScrollbar(width/2 - thirdPix/2, height - 1.5*margin, thirdPix, margin, 10);
    
    // Initialize Vertical Scrollbar
    vs = new VScrollbar(eX + eW - int(1.5*margin), margin, margin, thirdPix, 10);
    
    // Initialize Drag Funciton
    drag = new XYDrag(1.0, 7, eX, eY, eW, eH);
    
    // Initialize Selection Chunks
    chunkField = new ChunkGrid(boundary, CHUNK_RESOLUTION, eX, eY, eW, eH);
    
    showFrameRate = false;
    
    reset();
  }
  
  // Set Camera Position based upon current parameters
  //
  void on() {
    float eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ;
    
    // Camera Position
    eyeX = boundary.x * 0.5;
    eyeY = 0.50 * boundary.y - zoom * 0.50 * boundary.y;
    eyeZ = boundary.z + pow(zoom, ZOOM_POW) * 2 * max(boundary.x, boundary.y);
    
    // Point of Camera Focus
    centerX = 0.50 * boundary.x;
    centerY = 0.50 * boundary.y;
    centerZ = boundary.z;
    
    // Axes Directionality (Do not change)
    upX =   0;
    upY =   0;
    upZ =  -1;
    
    perspective(PI/3.0, float(width)/height, 1, 10*boundary.x);
    camera(eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ);
    lights(); // Default Lighting Condition
    
    // Rotate Reference Frame
    translate(0.5*boundary.x, 0.5*boundary.y, 0.5*boundary.z);
    rotate(rotation);
    translate(-0.5*boundary.x, -0.5*boundary.y, -0.5*boundary.z);
  
    // Translate Reference Frame
    translate(offset.x, offset.y, 0);
    
    update();
    hint(ENABLE_DEPTH_TEST);
  }
  
  // Turn camera off when drawing 2D UI components, for instance
  //
  void off() {
    camera(); noLights(); perspective(); 
    hint(DISABLE_DEPTH_TEST);
  }
  
  // resets and centers camera view
  //
  void reset() {
    hs.newspos = hs.sposMin + (hs.sposMax - hs.sposMin) * (ROTATION_DEFAULT)      / (2*PI);
    vs.newspos = vs.sposMax - (vs.sposMax - vs.sposMin) * (ZOOM_DEFAULT-ZOOM_MAX) / (ZOOM_MIN-ZOOM_MAX);
    drag.x_offset = 0;
    drag.y_offset = 0;
    drag.camX_init = X_DEFAULT;
    drag.camY_init = Y_DEFAULT;
    moved();
  }
  
  void moved() {
    uiFade = 1.0;
    fadeTimer = FADE_TIMER;
    on();
    if (chunkTimer <= 0) {
      if (!mousePressed && enableChunks) chunkField.checkChunks(mouseX, mouseY);
      chunkTimer = CHUNK_TIMER;
    }  else {
      chunkTimer--;
    }
    if (moveTimer > 0) moveTimer--;
  }
  
  void pressed() {
    // Determine which output is active
    if (hs.overEvent()) {
      activeInput = 1;
    } else if (vs.overEvent()) {
      activeInput = 2;
    } else if (drag.inExtents() && !drag.inBlocker()) {
      activeInput = 0;
      drag.init(offset.x, offset.y);
    } else {
      activeInput = -1;
    }
    moveTimer = MOVE_TIMER;
  }
  
  void update() {
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
    // Update All Scroll, Drag, and Chunk Inputs
    if (!mousePressed) {
      if (drag.updating()) {
        drag.update(zoom, boundary);
        offset.x = drag.getX(rotation);
        offset.y = drag.getY(rotation);
      }
      hs.update();
      rotation = hs.getPosPI();
      vs.update();
      zoom = vs.getPosZoom(ZOOM_MIN, ZOOM_MAX);
      
    // Update Drag Only
    } else if (activeInput == 0) {
      drag.update(zoom, boundary);
      offset.x = drag.getX(rotation);
      offset.y = drag.getY(rotation);
      
    // Update Horizontal Scroll Bar Only
    } else if (activeInput == 1) {
      hs.update();
      rotation = hs.getPosPI();
      
    // Update Vertical Scroll Bar Only
    } else if (activeInput == 2) {
      vs.update();
      zoom = vs.getPosZoom(ZOOM_MIN, ZOOM_MAX);
    }
  }
  
  // Renders the UI on a 2D canvas that writes over any 3D image
  //
  void drawControls() {
    cam.off();
    
    // Draw Scroll Bars
    hs.display(LINE_COLOR, BASE_ALPHA);
    vs.display(LINE_COLOR, BASE_ALPHA);
    
    // Draw Help Text
    pushMatrix(); translate(width/2, margin);
    fill(LINE_COLOR, 255-BASE_ALPHA);
    textAlign(CENTER, TOP);
    text("Press 'c' for default camera position", 0, 0);
    if (showFrameRate) text("(f)ramerate: " + int(frameRate*10)/10.0, 0, 32);
    popMatrix();
    
    if (!hs.enable) {
      pushMatrix(); translate(width/2, height - margin);
      textAlign(CENTER, BOTTOM);
      fill(LINE_COLOR, 255-2*BASE_ALPHA);
      text("Copyright 2018 Ira Winder", 0, 0);
      popMatrix();
    }
  }
  
  // Check if mouse is hovering over any of the camera GUI components
  //
  boolean hoverGUI() {
    if (cam.drag.inExtents() && !cam.drag.inBlocker() && !(cam.hs.overEvent() && cam.hs.enable) && !(cam.vs.overEvent() && cam.vs.enable) ) {
      return false;
    } else {
      return true;
    }
  }
}

// Horizontal Slider
//
class HScrollbar {
  float swidth, sheight;  // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // x position of slider
  float sposMin, sposMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;
  boolean enable;

  HScrollbar (float xp, float yp, float sw, float sh, int l) {
    swidth = sw;
    sheight = sh;
    float widthtoheight = sw - sh;
    ratio = sw / widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos = xpos + swidth/2 - sheight/2;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    loose = l;
    enable = true;
  }

  void update() {
    if (overEvent() && enable) {
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
    if (abs(newspos - spos) > 0.001) {
      spos = spos + (newspos-spos)/loose;
    }
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  boolean overEvent() {
    if (mouseX > xpos && mouseX < xpos+swidth &&
       mouseY > ypos && mouseY < ypos+sheight && enable) {
      return true;
    } else {
      return false;
    }
  }

  void display(int lineColor, int baseAlpha) {
    if (enable) {
      noStroke(); fill(0.6*lineColor, baseAlpha);
      rect(xpos, ypos, swidth, sheight, sheight);
      if (over || locked) {
        fill(lineColor, baseAlpha);
      } else {
        fill(0.4*lineColor, baseAlpha);
      }
      ellipse(spos + sheight/2, ypos + sheight/2, sheight, sheight);
      fill(lineColor, 255); textAlign(CENTER, BOTTOM);
      text("ROTATION", xpos + swidth/2, ypos - 14);
    }
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

// Vertical Slider
//
class VScrollbar {
  float swidth, sheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // y position of slider
  float sposMin, sposMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;
  boolean enable;

  VScrollbar (float xp, float yp, float sw, float sh, int l) {
    swidth = sw;
    sheight = sh;
    float heighttowidth = sw - sh;
    ratio = sh / heighttowidth;
    xpos = xp-swidth/2;
    ypos = yp;
    spos = ypos;
    newspos = spos;
    sposMin = ypos;
    sposMax = ypos + sheight - swidth;
    loose = l;
    enable = true;
  }

  void update() {
    if (overEvent() && enable) {
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
    if (abs(newspos - spos) > 0.001) {
      spos = spos + (newspos-spos)/loose;
    }
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  boolean overEvent() {
    if (mouseX > xpos && mouseX < xpos+swidth &&
       mouseY > ypos && mouseY < ypos+sheight && enable) {
      return true;
    } else {
      return false;
    }
  }

  void display(int lineColor, int baseAlpha) {
    if (enable) {
      noStroke(); fill(0.6*lineColor, 2*baseAlpha);
      rect(xpos, ypos, swidth, sheight, swidth);
      if (over || locked) {
        fill(lineColor, 2*baseAlpha);
      } else {
        fill(0.4*lineColor, 4*baseAlpha);
      }
      ellipse(xpos + swidth/2, spos + swidth/2, swidth, swidth);
      fill(lineColor, 255); textAlign(CENTER, TOP);
      text("ZOOM", xpos + swidth/2, ypos + sheight + 21);
    }
  }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return spos * ratio;
  }
  
  float getPosZoom(float MIN_VAL, float MAX_VAL) {
    // Convert spos to be values between
    // 0 and 2PI
    return (MIN_VAL - (MIN_VAL - MAX_VAL) * (spos-sposMin) / (sposMax-sposMin));
  }
}

// Helper Class For Enhanced, Smoothed Mouse UI
//
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
  
  // Areas Blocked From Clicking (Such as a Toolbar)
  //
  ArrayList<Integer[]> blocker;
  
  boolean enable;
  
  XYDrag(float s, float l, int eX, int eY, int eW, int eH ) {
    scaler = s;
    loose = l;
    
    extentX = eX;
    extentY = eY;
    extentW = eW;
    extentH = eH;
    
    blocker = new ArrayList<Integer[]>();
    
    enable = true;
  }
  
  void addBlocker(int x, int y, int w, int h) {
    Integer[] b = new Integer[4];
    b[0] = x;
    b[1] = y;
    b[2] = w;
    b[3] = h;
    blocker.add(b);
  }
  
  boolean inExtents() {
    if (mouseX >= extentX && mouseX < extentX+extentW && mouseY > extentY && mouseY < extentY+extentH && enable) {
      return true; 
    } else {
      return false;
    }
  }
  
  boolean inBlocker() {
    boolean inside = false;
    for (Integer[] b: blocker) 
      if (mouseX >= b[0] && mouseX < b[0]+b[2] && mouseY > b[1] && mouseY < b[1]+b[3]) 
        inside = true;
    return inside;
  }
  
  void init(float offsetX, float offsetY) {
    x_init = mouseX;
    y_init = mouseY;
    camX_init = offsetX;
    camY_init = offsetY;
    x_smooth = 0;
    y_smooth = 0;
  }
  
  void update(float zoom, PVector boundary) {
    if (mousePressed) {
      x_offset = - 0.002*boundary.x*zoom*(mouseX - x_init);
      y_offset = - 0.002*boundary.y*zoom*(mouseY - y_init);
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
  
  float getX(float rotation) {
    return camX_init + x*cos(rotation) + y*sin(rotation);
  }
  
  float getY(float rotation) {
    return camY_init - x*sin(rotation) + y*cos(rotation);
  }
}

// Object that defines an area that is sensitive to user-based mouse selection
//
class Chunk {
  PVector location; // location of chunk
  float size; // cube size of chunk
  float s_x, s_y; // screen location of chunk
  boolean hover;
  
  Chunk(PVector location, float size) {
    this.location = location;
    this.size = size;
    hover = false;
  }
  
  void setScreen() {
    s_x = screenX(location.x, location.y, location.z);
    s_y = screenY(location.x, location.y, location.z);
  }
}

// Grid of Chunks for discretely continuous spatial selection
//
class ChunkGrid {
  int resolution, tolerance;
  float chunkU, chunkV;
  ArrayList<Chunk> selectionGrid;
  Chunk closest;
  boolean closestFound;
  
  // number of pixels within range to select
  int TOLERANCE = 40;
    
  PGraphics img;
  
  // Extent of Clickability
  int extentX;
  int extentY;
  int extentW;
  int extentH;
  
  ChunkGrid(PVector boundary, int resolution, int eX, int eY, int eW, int eH) {
    this.resolution = resolution;
    
    Chunk chunk; PVector chunkLocation;
    selectionGrid = new ArrayList<Chunk>();
    chunkU  = boundary.x / resolution;
    chunkV  = boundary.y / resolution;
    for(int u=0; u<chunkU; u++) {
      for(int v=0; v<chunkV; v++) {
        chunkLocation = new PVector(u + 0.5, v + 0.5);
        chunkLocation.mult(resolution);
        chunk = new Chunk(chunkLocation, resolution);
        selectionGrid.add(chunk);
      }
    }
    closestFound = false;
    
    extentX = eX;
    extentY = eY;
    extentW = eW;
    extentH = eH;
    
    drawGrid();
  }
  
  // Returns the location of chunk closest to user's mouse position
  //
  void checkChunks(int mouseX, int mouseY) {
    closestFound = false;
    
    // Updates Screenlocation for all chunks
    for (Chunk chunk: selectionGrid) chunk.setScreen();
    
    // Discovers closest chunk to mouse
    PVector mouse = new PVector(mouseX, mouseY);
    Chunk c; PVector c_location; int c_index = -1;
    float dist = Float.POSITIVE_INFINITY;
    for (int i=0; i<selectionGrid.size(); i++) {
      c = selectionGrid.get(i);
      c.hover = false;
      c_location = new PVector(c.s_x, c.s_y);
      if (mouse.dist(c_location) < dist && mouse.dist(c_location) < TOLERANCE) {
        dist = mouse.dist(c_location);
        c_index = i;
      }
    }
    
    // Retrieve and store closest chunk found
    if (mouseX > extentX && mouseX < extentX+extentW && mouseY > extentY && mouseY < extentY+extentH) {
      if (c_index >= 0) {
        closestFound = true;
        closest = selectionGrid.get(c_index);
        closest.hover = true;
      }
    }
  }
  
  // Draw PGraphic with Selection Grid 
  void drawGrid() {
    int w = int(chunkU*resolution);
    int h = int(chunkV*resolution);
    img = createGraphics(w, h);
    img.beginDraw(); img.clear();
    for (Chunk c: selectionGrid) {
      img.stroke(0, 255); img.noFill();
      img.rect(c.location.x-c.size/2, c.location.y-c.size/2, c.size, c.size);
    }
    img.endDraw();
  }
  
  void drawCursor() {
    if (closestFound) {
      pushMatrix(); translate(closest.location.x, closest.location.y, closest.location.z + closest.size/2);
      stroke(#FFFF00, 255); strokeWeight(1); noFill();
      box(closest.size, closest.size, closest.size);
      popMatrix();
    }
  }
}
