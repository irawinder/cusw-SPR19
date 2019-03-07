/*  GUI3D
 *  Ira Winder, ira@mit.edu, 2018
 *
 *  Init Functions (Superficially Isolated from Main.pde)
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

// Camera Object with built-in GUI for navigation and selection
//
Camera cam;
PVector B; // Bounding Box for 3D Environment
int MARGIN; // Pixel margin allowed around edge of screen

// Semi-transparent Toolbar for information and sliders
//
Toolbar bar_left, bar_right; 
int BAR_X, BAR_Y, BAR_W, BAR_H;
boolean showGUI;

// Location of an Object a user can move with arrow keys
//
PVector objectLocation; 
float s_x, s_y;

// Locations of objects user has placed with mouse
//
ArrayList<PVector> additions; 
boolean placeAdditions;
float cursor_x, cursor_y;
PVector additionLocation;

// Processing Font Containers
PFont f12, f18, f24;

// Counter to track which phase of initialization
//
boolean initialized;
int initPhase = 0;
int phaseDelay = 0;
String status[] = {
  "Initializing Canvas ...",
  "Loading Data ...",
  "Initializing Toolbars and 3D Environment ...",
  "Ready to go!"
};
int NUM_PHASES = status.length;

void init() {
  
  initialized = false;
    
  if (initPhase == 0) {
    
    // Load default background image
    //
    loadingBG = loadImage("data/loadingScreen.jpg");
    
    // Set Fonts
    //
    f12 = createFont("Helvetica", 12);
    f18 = createFont("Helvetica", 18);
    f24 = createFont("Helvetica", 24);
    textFont(f12);
    
    // Create canvas for drawing everything to earth surface
    //
    B = new PVector(3000, 3000, 0);
    MARGIN = 25;
    
  } else if (initPhase == 1) {
    
    // Init Data / Sample 3D objects to manipulate
    //
    objectLocation = new PVector(B.x/2, B.y/2, 0);
    additions = new ArrayList<PVector>();
    placeAdditions = true;
    
  } else if (initPhase == 2) {
    
    // Initialize GUI3D
    //
    showGUI = true;
    initToolbars();
    initCamera();
    
  } else if (initPhase == 3) {
    
    initialized = true;
  }
  
  loadingScreen(loadingBG, initPhase, NUM_PHASES, status[initPhase]);
  if (!initialized) initPhase++; 
  delay(phaseDelay);

}

void initCamera() {
  
  // Initialize 3D World Camera Defaults
  //
  cam = new Camera (B, MARGIN);
  cam.ZOOM_DEFAULT = 0.25;
  cam.ZOOM_POW     = 1.75;
  cam.ZOOM_MAX     = 0.10;
  cam.ZOOM_MIN     = 0.75;
  cam.ROTATION_DEFAULT = PI; // (0 - 2*PI)
  cam.init(); // Must End with init() if any BASIC variables within Camera() are changed from default
  
  // Add non-camera UI blockers and edit camera UI characteristics AFTER cam.init()
  //
  cam.vs.xpos = width - 3*MARGIN - BAR_W;
  //cam.hs.enable = false; //disable rotation
  cam.drag.addBlocker(MARGIN, MARGIN, BAR_W, BAR_H);
  cam.drag.addBlocker(width - MARGIN - BAR_W, MARGIN, BAR_W, BAR_H);
  
  // Turn cam off while still initializing
  //
  cam.off();  
}

void initToolbars() {
  
  // Initialize Toolbar
  BAR_X = MARGIN;
  BAR_Y = MARGIN;
  BAR_W = 250;
  BAR_H = 800 - 2*MARGIN;
  
  // Left Toolbar
  bar_left = new Toolbar(BAR_X, BAR_Y, BAR_W, BAR_H, MARGIN);
  bar_left.title = "GUI3D Visualization Template\n";
  bar_left.credit = "(Left-hand Toolbar)\n\n";
  bar_left.explanation = "";
  bar_left.controlY = BAR_Y + bar_left.margin + 2*bar_left.CONTROL_H;
  bar_left.addSlider("Slider A", "%", 0, 100, 25, 1, 'q', 'w', true);
  bar_left.addSlider("Slider B", "%", 0, 100, 50, 1, 'a', 's', true);
  bar_left.addSlider("SPACER",   "%", 0, 100, 50, 1, 'a', 's', false);
  bar_left.addSlider("Slider C", "%", 0, 100, 75, 1, 'z', 'x', false);
  bar_left.addSlider("Slider D", "%", 0, 100, 25, 1, 'i', 'o', false);
  bar_left.addSlider("SPACER",   "%", 0, 100, 50, 1, 'a', 's', false);
  bar_left.addSlider("Slider E", "%", 0, 100, 50, 1, 'k', 'l', false);
  bar_left.addSlider("Slider F", "%", 0, 100, 75, 1, ',', '.', false);
  bar_left.addSlider("SPACER",   "%", 0, 100, 50, 1, 'a', 's', false);
  bar_left.addTriSlider("TriSlider", "value1", #FF00FF, "value2", #FFFF00, "value3", #00FFFF);
  bar_left.addRadio("Item A", 200, true, '1', true);
  bar_left.addRadio("Item B", 200, true, '2', true);
  bar_left.addRadio("Item C", 200, true, '3', true);
  bar_left.addRadio("Item D", 200, true, '4', true);
  bar_left.addRadio("Item W", 200, true, '5', true);
  bar_left.addRadio("Item X", 200, true, '6', true);
  bar_left.addRadio("Item Y", 200, true, '7', true);
  bar_left.addRadio("Item Z", 200, true, '8', true);
  for (int i=0; i<4; i++) {
    bar_left.radios.get(i+4).xpos = bar_left.barX + bar_left.barW/2; 
    bar_left.radios.get(i+4).ypos = bar_left.radios.get(i).ypos;
  }
  // Delete Spacers
  bar_left.sliders.remove(8);
  bar_left.sliders.remove(5);
  bar_left.sliders.remove(2);
  
  
  // Right Toolbar
  bar_right = new Toolbar(width - (BAR_X + BAR_W), BAR_Y, BAR_W, BAR_H, MARGIN);
  bar_right.title = "";
  bar_right.credit = "(Right-hand Toolbar)\n\n";
  bar_right.explanation = "Framework for explorable 3D model parameterized with sliders, radio buttons, and 3D Cursor. ";
  bar_right.explanation += "\n\nPress ' r ' to reset all inputs\nPress ' p ' to print camera settings\nPress ' a ' to add add objects\nPress ' h ' to hide GUI";
  bar_right.controlY = BAR_Y + bar_left.margin + 6*bar_left.CONTROL_H;
  bar_right.addRadio("Button A", 200, true, '!', false);
  bar_right.addRadio("Button B", 200, true, '@', false);
  bar_right.addRadio("Button C", 200, true, '#', false);
  bar_right.addRadio("Button D", 200, true, '$', false);
  bar_right.addRadio("Button E", 200, true, '%', false);
  bar_right.addSlider("SPACER",   "kg", 50, 100, 72, 1, '<', '>', false);
  bar_right.addSlider("Slider 1", "kg", 50, 100, 72, 1, '<', '>', false);
  bar_right.addSlider("Slider 2", "kg", 50, 100, 72, 1, '<', '>', false);
  bar_right.addSlider("Slider 3", "kg", 50, 100, 72, 1, '<', '>', false);
  bar_right.addSlider("Slider 4", "kg", 50, 100, 72, 1, '<', '>', false);
  bar_right.addSlider("Slider 5", "kg", 50, 100, 72, 1, '<', '>', false);
  bar_right.addSlider("Slider 6", "kg", 50, 100, 72, 1, '<', '>', false);
  bar_right.addSlider("Slider 7", "kg", 50, 100, 72, 1, '<', '>', false);
  bar_right.addButton("Button 1", #009900, 'b', true);
  bar_right.sliders.remove(0);
}

// Converts latitude, longitude to local friendly screen units (2D or 3D)
PVector latlonToXY(PVector latlon, float latMin, float latMax, float lonMin, float lonMax, float xMin, float yMin, float xMax, float yMax) {
  float X_Width = xMax - xMin;
  float Y_Width = yMax - yMin;
  float lat_scaler = (latlon.x - latMin) / abs(latMax - latMin);
  float lon_scaler = (latlon.y - lonMin) / abs(lonMax - lonMin);
  float X  = xMin + X_Width * lon_scaler;
  float Y  = yMin - Y_Width * lat_scaler + Y_Width;
  return new PVector(X,Y);
}
