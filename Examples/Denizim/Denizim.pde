/*  Denizim Beacon Simulator, Ira Winder and Changing Environments, 2018
 *
 *  Beacon Simulator simulates and visualizes wireless 
 *  sensors. Sensors detect synthetic people that ambulate 
 *  through an urban environment.
 *
 */

String version = "Beta 1.3";

//String company = "Soofa ";
String company = "";
String project = company + "Denizim:\nBeacon Simulator " + version + "\nIra Winder\n\n";
String description = company + "Sensors can collect anonymized " +
                     "data to help cities understand visitor behavior. " +
                     "This simulator shows how they collect data from a " +
                     "population.";

// Scrollbars (horizontal and vertical
HScrollbar hs;
VScrollbar vs;

// Drag Functions
XYDrag drag;

boolean showUI = true;

// Initiatizes program on startup
void setup() {

  // Run application at a specified pixel dimension
  //size(1280, 800, P3D);
  
  // Run application to match native screen resolution
  fullScreen(P3D);
  
  // Sets Color Mode to Hue, Saturation, and Brightness
  colorMode(HSB);
  
  // Initialize the environment
  initFields();
  
  // Initialize Running Graph
  visitors = new RunningGraph(10, 135, 150);
  
  // Initialize the Camera
  initCamera();
  
  // Initialize Horizontal Scrollbar
  hs = new HScrollbar(width - int(height*MARGIN) - int(0.3*height), int((1-1.5*MARGIN)*height), int(0.3*height), int(MARGIN*height), 5);
  camRotation = hs.getPosPI(); // (0 - 2*PI)
  
  // Initialize Vertical Scrollbar
  vs = new VScrollbar(width - int(1.5*MARGIN*height), int(MARGIN*height), int(MARGIN*height), int(0.3*height), 5);
  
  // Initialize Drag Funciton
  drag = new XYDrag(1.0, 7, 5, 5, width - 10, int(0.85*height) - 5);
  
  resetControls();
}

// Runs on a loop after setup()
void draw() {
  background(bgColor);
  
  // Update mouse and keyboard inputs
  updateInputs();
      
  // Update Simulation Aspects
  Field f = city.get(cityIndex);
  for (Person p: f.people) {
    p.update(personLocations(f.people), true);
    p.update(f);
    
    if (frameCounter == 0) { // Ping Sensors
      if (!p.detected) {
        for (Sensor s: f.beacons) {
          p.detected = s.detect(p.loc, p.detected);
          if (p.detected) {
            if (!freezeVisitCounter) p.numDetects++;
            break;
          }
        }
      } else {
        boolean check = false;
        for (Sensor s: f.beacons) {
          if(s.detect(p.loc, p.detected)) check = true;
        }
        if (!check) p.detected = false;
      }
    }
  }
  
  if (frameCounter == 0) {
    // Update Visitor Summary Info
    Float[] reading = new Float[3];
    reading[0] = 0.0; // Total Pop
    reading[1] = 0.0; // Total Detected
    reading[2] = 0.0; // Return Visitors Detected
    for (Person p: f.people) {
      reading[0]++;
      if (p.detected) {
        reading[1]++;
        if (p.numDetects > 1) {
          reading[2]++;
        }
      }
    }
    visitors.addReading(reading);
    visitors.updateMax(f.people.size());
  }
  
  // Draw 3D Graphics
  draw3D(f);

  // Draw 2D Graphics
  if (showUI) draw2D();
  
  //Count Frames
  if (frameCounter < PING_FREQ - 1) {
    frameCounter++;
  } else {
    frameCounter = 0;
  }
  
  //Count Frames for Pop
  if (popCounter < POP_RESET - 1) {
    popCounter++;
  } else {
    popCounter = 0;
    f.randomizePeople();
  }
  
}

void draw2D() {
  Field f = city.get(cityIndex);
  // Temporarily Overrides 3D Graphics Settings
  camera();
  noLights();
  perspective();
  hint(DISABLE_DEPTH_TEST);
  
  // Draw Scroll Bars
  hs.display();
  vs.display();
  
  // Draw Help Text
  pushMatrix();
  translate(width/2, MARGIN*height);
  fill(lnColor, 255-baseAlpha);
  textAlign(CENTER, TOP);
  text("Press 'r' to reset camera position", 0, 0);
  translate(0, height - 2*MARGIN*height);
  textAlign(CENTER, BOTTOM);
  fill(lnColor, 2*baseAlpha);
  String credit = "";
  if ( !company.equals("") ){
    credit += " and " + company;
  }
  text("Copyright 2018 Ira Winder" + credit, 0, 0);
  popMatrix();
  
  
  pushMatrix();
  // Draw Help Canvas
  translate(MARGIN*height, MARGIN*height);
  fill(bgColor, 2*baseAlpha);
  rect( 2, 2, 230, 800 - 48, 10);
  fill(lnColor, 1*baseAlpha);
  rect( 0, 0, 230, 800 - 48, 10);
  
  //// Draw Logo (1500 x 719)
  translate(20, 5);
  tint(255, 255);
  if (company.equals("Soofa ")) {
    image(logo, 0, 10, 0.1*1500, 0.1*719);
  
  
    // Draw Description
    translate(0, 0.15*719);
  } else {
    translate(0, 20);
  }
  fill(lnColor);
  textAlign(LEFT, TOP);
  text(project + description + "\n\nLegend:", 0, 0, 200, 0.9*height);
  
  //Draw Legend
  translate(0, 100 + 56);
  //DrawShadows
  fill(bgColor);
  rect(1, 1 +  0, 4, 12, 3);
  rect(1, 1 + 28, 4, 12, 3);
  rect(1, 1 + 56, 4, 12, 3);
  //ellipse(5, 1 + 84 + 8, 16, 16);
  if (f.showPaths) {
    ellipse(5, 0 + 112 + 8, 12, 12);
    ellipse(5, 0 + 168 + 8, 12, 12);
  }
  //DrawPeople
  fill(#CCCCCC);
  stroke(bgColor);
  rect(0, 0 +  0, 4, 12, 3);
  noStroke();
  fill(150, 255, 255);
  rect(0, 0 + 28, 4, 12, 3);
  fill(100, 255, 255);
  rect(0, 0 + 56, 4, 12, 3);
  if (!inverted) {
    fill(200);
  } else{
    fill(150);
  }
  ellipse(4, 0 + 84 + 8, 18, 18);
  fill(soofaColor, 200);
  ellipse(4, 0 + 84 + 8, 10, 10);
  if (f.showPaths) {
    strokeWeight(2);
    stroke(lnColor, 150);
    line(4, 112+5+11, 4, 168+5-5);
    fill(0);
    stroke(#FFFF00);
    ellipse(4, 0 + 112 + 8, 12, 12);
    stroke(#0000FF);
    ellipse(4, 0 + 168 + 8, 12, 12);
    strokeWeight(1);
  }
  //DrawText
  fill(lnColor);
  String pathText = "";
  if (f.showPaths) {
    pathText += "\n\n  Origin\n\n - Shortest Path\n\n  Destination";
  }
  text("Undetected Visitor\n\nNew Visitor\n\nReturning Visitor\n\n  " + company + "Sensor" + pathText, 10, -1);
  popMatrix();
  
  //DrawDirections
  pushMatrix();
  translate(width - height*MARGIN - 275, height*MARGIN);
  fill(lnColor, (255-baseAlpha)*uiFade);
  text("Directions:\n\n1. Use scrollbars and mouse to zoom, pan, and rotate.\n\n2. Press '1-5' to randomly generate one to five " + company + "sensors, respectively.\n\n3. Press '0' to delete all " + company + "Sensors.\n\n4. Click any location to add a " + company + "Sensor.\n\n" +
       "5. Press ' m ' to toggle map\n\n6. Press ' p ' to reset population\n\n7. Press ' i ' to invert colors", 0, 0, 200, 400);
  popMatrix();
  
  //Draw Summary
  pushMatrix();
  translate(MARGIN*height+10, MARGIN*height + 485);
  visitors.display();
  Float[] reading = visitors.summary.get(visitors.summary.size()-1);
  textAlign(RIGHT, BOTTOM);
  float beaconFade = sq(1 - float(frameCounter) / PING_FREQ);
  fill(lnColor, beaconFade*255);
  text("Reading #" + visitors.leaderIndex + " ", 135, -10);
  textAlign(LEFT, TOP);
  fill(lnColor);
  text("Coverage: " + int(1000*reading[1]/reading[0])/10.0 + "%\n" +
       "Repeat Visits: " + int(1000*reading[2]/reading[1])/10.0 + "%\n\n" +
       "Location:\nMills Park, Oak Park, IL", 0, 180);
  popMatrix();
  
  hint(ENABLE_DEPTH_TEST);
}

void draw3D(Field f) {
  setCamera(f.boundary);
  
  pushMatrix();
  
  // Rotate Reference Frame
  translate(0.5*f.boundary.x, 0.5*f.boundary.y, 0.5*f.boundary.z);
  rotate(camRotation);
  translate(-0.5*f.boundary.x, -0.5*f.boundary.y, -0.5*f.boundary.z);
  
  // Translate Reference Frame
  translate(camOffset.x, camOffset.y, 0);
  
  // Draw 3D Objects
  f.render();
  
  popMatrix();
}
