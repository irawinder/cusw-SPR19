/*  DRIVING FUTURES
 *  Ira Winder, ira@mit.edu, 2018
 *
 *  Listen Functions (Superficially Isolated from Main.pde)
 *
 *  MIT LICENSE:  Copyright 2018 Ira Winder
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
 
int playTimer = 0;
int PLAY_TIMER = 60;
int playPause = 0;
int PLAY_PAUSE = 120;

// Begin Updating backend system components
//
void listen() {
  
  // Autoplay progress
  //
  if (autoPlay) autoPlay();
  
  // Set Systems Model to Slider Values
  //
  syncSliders();
  
  // Set Parking and Vehicles Stats to Systems Model
  //
  syncParking();
  syncVehicles();
  
  // Update Vehicle Movement
  //
  boolean collisionDetection = false;
  ArrayList<PVector> otherLocations = new ArrayList<PVector>();
  if (collisionDetection) otherLocations = vehicleLocations();
  if (showCar1) for (Agent p: type1) p.update(otherLocations, collisionDetection);
  if (showCar2) for (Agent p: type2) p.update(otherLocations, collisionDetection);
  if (showCar3) for (Agent p: type3) p.update(otherLocations, collisionDetection);
  if (showCar4) for (Agent p: type4) p.update(otherLocations, collisionDetection);
  
  // Update Vehicle Draw
  //
  boolean show;
  if (cam.zoom < 0.2) {
    show = true;
  } else {
    show = false;
  }
  // show = false; // OVERRIDE
  for (Agent p: type1) p.showPassengers = show;
  for (Agent p: type2) p.showPassengers = show;
  for (Agent p: type3) p.showPassengers = show;
  for (Agent p: type4) p.showPassengers = show;
  
  // Update Hover Index and Type Values
  //
  hoverListen();
}

// Update Hover Index and Type Values
//
void hoverListen() {
  
  // Find Nearest Vehicle or Parking Entity when hovering
  //
  hoverIndex = 0; hoverType = "";
  PVector mouse = new PVector(mouseX, mouseY);
  
  // Practically deactivate hover when mouse over toolbars
  //
  if (bar_left.hover() || bar_right.hover()) mouse = new PVector(-1000, -1000);
  
  float shortestDistance = Float.POSITIVE_INFINITY;
  float MIN_DIST = 200.0 / (1+10*cam.zoom);
  if (showCar1) for (int i=0; i<type1.size(); i++) {
    Agent p = type1.get(i);
    p.highlight = false;
    float dist = mouseDistance(mouse, p.s_x, p.s_y);
    if ( dist < shortestDistance && dist < MIN_DIST ) {
      shortestDistance = dist; hoverIndex = i; hoverType = "car1";
    }
  }
  if (showCar2) for (int i=0; i<type2.size(); i++) {
    Agent p = type2.get(i);
    p.highlight = false;
    float dist = mouseDistance(mouse, p.s_x, p.s_y);
    if ( dist < shortestDistance && dist < MIN_DIST ) {
      shortestDistance = dist; hoverIndex = i; hoverType = "car2";
    }
  }
  if (showCar3) for (int i=0; i<type3.size(); i++) {
    Agent p = type3.get(i);
    p.highlight = false;
    float dist = mouseDistance(mouse, p.s_x, p.s_y);
    if ( dist < shortestDistance && dist < MIN_DIST ) {
      shortestDistance = dist; hoverIndex = i; hoverType = "car3";
    }
  }
  if (showCar4) for (int i=0; i<type4.size(); i++) {
    Agent p = type4.get(i);
    p.highlight = false;
    float dist = mouseDistance(mouse, p.s_x, p.s_y);
    if ( dist < shortestDistance && dist < MIN_DIST ) {
      shortestDistance = dist; hoverIndex = i; hoverType = "car4";
    }
  }
  for (int i=0; i<structures.parking.size(); i++) {
    Parking p = structures.parking.get(i);
    p.highlight = false;
    if (p.show) {
      float dist = mouseDistance(mouse, p.s_x, p.s_y);
      if ( dist < shortestDistance && dist < MIN_DIST ) {
        shortestDistance = dist; hoverIndex = i; hoverType = "parking";
      }
    }
  }
  
  // Update Parking and Vehicle Hightlights
  //
  if (hoverType.equals("parking")) structures.parking.get(hoverIndex).highlight = true;
  if (hoverType.equals("car1")) type1.get(hoverIndex).highlight = true;
  if (hoverType.equals("car2")) type2.get(hoverIndex).highlight = true;
  if (hoverType.equals("car3")) type3.get(hoverIndex).highlight = true;
  if (hoverType.equals("car4")) type4.get(hoverIndex).highlight = true;
}

// Set System Parameters According to Slider Values
//
void syncSliders() {
  sys.year_now                  = int(bar_left.sliders.get(0).value);
  sys.demand_growth             = bar_left.sliders.get(1).value/100.0;
  sys.av_share                  = bar_left.sliders.get(2).value/100.0;
  sys.av_peak_hype_year         = int(bar_left.sliders.get(3).value);
  sys.rideShare_share           = bar_left.sliders.get(4).value/100.0;
  sys.rideShare_peak_hype_year  = int(bar_left.sliders.get(5).value);
  sys.priorityBelow             = bar_left.tSliders.get(0).value1;
  sys.prioritySurface           = bar_left.tSliders.get(0).value2;
  sys.priorityAbove             = bar_left.tSliders.get(0).value3;
  showBelow                     = bar_left.radios.get(0).value;
  showSurface                   = bar_left.radios.get(1).value;
  showAbove                     = bar_left.radios.get(2).value;
  showReserved                  = bar_left.radios.get(3).value;
  showCar1                      = bar_left.radios.get(4).value;
  showCar2                      = bar_left.radios.get(5).value;
  showCar3                      = bar_left.radios.get(6).value;
  showCar4                      = bar_left.radios.get(7).value;
}

// Calculate Parking Ratios for each structure for current year only
//
void syncParking() {
  
  // Account for unactive parking first ...
  sys.belowOff   = 0;
  sys.surfaceOff = 0;
  sys.aboveOff   = 0;
  for (Parking p: structures.parking) {
    if (!p.active) {
      if (p.col == belowColor)   sys.belowOff   += p.capacity;
      if (p.col == surfaceColor) sys.surfaceOff += p.capacity;
      if (p.col == aboveColor)   sys.aboveOff   += p.capacity;
      p.utilization = 0;
    }
  }
  sys.belowOff   /= 100;
  sys.surfaceOff /= 100;
  sys.aboveOff   /= 100;
  
  sys.update();
  
  // For active parking, calculate ratio
  //
  int yr = sys.year_now - sys.year_0;
  float belowRatio   = 1 - float(sys.belowFree[yr]    )  / sys.totBelow  ;
  float surfaceRatio = 1 - float(sys.surfaceFree[yr]  )  / sys.totSurface;
  float aboveRatio   = 1 - float(sys.aboveFree[yr]    )  / sys.totAbove  ;
  
  for (Parking p: structures.parking) {
    p.ratio = 0;
    if (p.col == belowColor && p.active) {
      p.ratio = belowRatio;
    } else if (p.col == surfaceColor && p.active) {
      p.ratio = surfaceRatio;
    } else if (p.col == aboveColor && p.active) {
      p.ratio = aboveRatio;
    } else if (p.col == reservedColor && p.active) {
      p.ratio = 1.0;
    }
    p.utilization = int(p.ratio*p.capacity);
  }
}

void syncVehicles() {
  int yr = sys.year_now - sys.year_0;
  
  while (type1.size() > sys.numCar1[yr]) type1.remove(0);
  while (type2.size() > sys.numCar2[yr]) type2.remove(0);
  while (type3.size() > sys.numCar3[yr]) type3.remove(0);
  while (type4.size() > sys.numCar4[yr]) type4.remove(0);
  
  while (type1.size() < sys.numCar1[yr]) addVehicle(type1, "1");
  while (type2.size() < sys.numCar2[yr]) addVehicle(type2, "2");
  while (type3.size() < sys.numCar3[yr]) addVehicle(type3, "3");
  while (type4.size() < sys.numCar4[yr]) addVehicle(type4, "4");
  
}

//Automatically progress year of analysis
//
void autoPlay() {
  
  if (playTimer == PLAY_TIMER) {
    if (sys.year_now == sys.year_f && playPause < PLAY_PAUSE) {
      playPause++;
    } else {
      if (bar_left.sliders.get(0).value == bar_left.sliders.get(0).valMax) {
        bar_left.sliders.get(0).value = bar_left.sliders.get(0).valMin;
      } else {
        bar_left.sliders.get(0).value++;
      }
      playTimer = 0;
      playPause = 0;
    }
  } else {
    playTimer ++;
  }
  
}

void keyPressed() {
  if (initialized) {
    cam.moved();
    
    switch(key) {
      //case 'g':
      //  initPaths();
      //  initVehicles();
      //  break;
      case 'f':
        cam.showFrameRate = !cam.showFrameRate;
        break;
      case 'a':
        autoPlay = !autoPlay;
        playTimer = PLAY_TIMER;
        playPause = PLAY_PAUSE;
        break;
      case 'c':
        cam.reset();
        break;
      case 'r':
        bar_left.restoreDefault();
        bar_right.restoreDefault();
        structures.reset();
        initVehicles();
        break;
      //case 'h':
      //  SHOW_INFO = !SHOW_INFO;
      //  break;
      //case 's':
      //  save("capture.png");
      //  break;
      //case 'p':
      //  initVehicles();
      //  break;
      //case 'p':
      //  println("cam.offset.x = " + cam.offset.x);
      //  println("cam.offset.x = " + cam.offset.x);
      //  println("cam.zoom = "     + cam.zoom);
      //  println("cam.rotation = " + cam.rotation);
      //  break;
    }
    
    // Update Inputs and model
    bar_left.pressed();
    bar_right.pressed();
    syncSliders();
    syncParking();
    syncVehicles();
  }
}

void mousePressed() {
  if (initialized) {
    cam.pressed();
    bar_left.pressed();
    bar_right.pressed();
    syncSliders();
    sys.update();
    syncVehicles();
    
    //// Stop autoplay
    //autoPlay = false;
  }
}

void mouseMoved() {
  if (initialized) {
    cam.moved();
  }
}

void mouseReleased() {
  if (initialized) {
    bar_left.released();
    bar_right.released();
    syncSliders();
    sys.update();
    syncVehicles();
  }
}

void mouseDragged() {
  if (initialized) {
    sys.update();
    syncVehicles();
  }
}

void mouseClicked() {
  if (initialized) {
    if (hoverType.equals("parking")) {
      structures.parking.get(hoverIndex).active = !structures.parking.get(hoverIndex).active;
      syncParking();
    }
    boolean newPath = false;
    if (hoverType.equals("car1")) newPath = true;
    if (hoverType.equals("car2")) newPath = true;
    if (hoverType.equals("car3")) newPath = true;
    if (hoverType.equals("car4")) newPath = true;
    if (newPath) {
      for (Agent p: type1) p.showPath = false;
      for (Agent p: type2) p.showPath = false;
      for (Agent p: type3) p.showPath = false;
      for (Agent p: type4) p.showPath = false;
      try {
        if (hoverType.equals("car1")) type1.get(hoverIndex).showPath = !type1.get(hoverIndex).showPath;
        if (hoverType.equals("car2")) type2.get(hoverIndex).showPath = !type2.get(hoverIndex).showPath;
        if (hoverType.equals("car3")) type3.get(hoverIndex).showPath = !type3.get(hoverIndex).showPath;
        if (hoverType.equals("car4")) type4.get(hoverIndex).showPath = !type4.get(hoverIndex).showPath;
      } catch (RuntimeException e) { println("Oops! Something went wrong"); }
    }
  }
}

float mouseDistance (PVector mouse, float s_x, float s_y) {
  return abs(mouse.x-s_x) + abs(mouse.y-s_y);
}

ArrayList<PVector> vehicleLocations() {
  ArrayList<PVector> l = new ArrayList<PVector>();
  for (Agent a: type1) l.add(a.location);
  for (Agent a: type2) l.add(a.location);
  for (Agent a: type3) l.add(a.location);
  for (Agent a: type4) l.add(a.location);
  return l;
}
