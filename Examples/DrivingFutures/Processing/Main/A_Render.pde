/*  DRIVING FUTURES
 *  Ira Winder, ira@mit.edu, 2018
 *
 *  Draw Functions (Superficially Isolated from Main.pde)
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
 
boolean showCar1 = true;
boolean showCar2 = true;
boolean showCar3 = true;
boolean showCar4 = true;
boolean showBelow = true;
boolean showSurface = true;
boolean showAbove = true;
boolean showReserved = true;
boolean SHOW_INFO = true;
boolean autoPlay = false;

// Car Colors
int car1Color = #FFFFFF;
int car2Color = #FF00FF;
int car3Color = #00FFFF;
int car4Color = #FFFF00;
 
// Parking Colors
int reservedColor = #999999;
int belowColor    = #CC99FF;
int surfaceColor  = #FFBB66;
int aboveColor    = #5555FF;

// Road Color
int roadColor = #FFAAAA;

void render3D() {

  // -------------------------
  // Begin Drawing 3D Elements
  //
  // ****
  // NOTE: Objects draw earlier in the loop will obstruct 
  // objects drawn afterward (despite alpha value!)
  // ****
  
  // Draw and Calculate 3D Graphics 
  cam.on();
  
  // Update camera position settings for a number of frames after key updates
  if (cam.moveTimer > 0) {
    cam.moved();
  }
  
  //Background Color
  //
  background(20);
  
  //  Displays the "Road" Graph.
  //
  fill(roadColor); stroke(255); // Default Colors
  tint(255, 25); // overlaid as an image
  image(network.img, 0, 0, B.x, B.y);
  
  // Draw Routes overlaid on streets
  tint(255, 175);
  image(routes.img, 0, 0, B.x, B.y);
  
  // Draw Parking Infrastructure
  //
  for (Parking p: structures.parking) {
    
    pushMatrix();
    
    boolean OVER_RIDE = false;
    if (p.capacity > 0 || OVER_RIDE) {
      
      // Draw Fill / ID Dot
      p.show = false;
      if (p.col == belowColor && showBelow) {
        p.show = true;
      } else if (p.col == surfaceColor && showSurface) {
        p.show = true;
      } else if (p.col == aboveColor && showAbove) {
        p.show = true;
      } else if (showReserved && p.col != belowColor && p.col != surfaceColor && p.col != aboveColor) {
        p.show = true;
      } 
      
      if (p.show) {
        // Find Screen location of parking ammenity
        p.setScreen();
        
        int buffer = 50;
        if (p.s_x > -buffer && p.s_x < width + buffer && p.s_y > - buffer && p.s_y < height + buffer) {
      
          // Draw Parking Button/Icon
          translate(0,0,1);
          if (p.capacity == p.utilization) {
            stroke(#AA0000, 200); strokeWeight(3);
          } else if (0 == p.utilization) {
            stroke(#00AA00, 200); strokeWeight(3);
          } else {
            noStroke();
          }
          if (p.highlight) {
            fill(p.col, 255);
          } else {
            fill(p.col, 200);
          }
          float pW = 2.0*sqrt( max(structures.minCap, p.capacity));
          ellipse(p.location.x, p.location.y, pW, pW);
          
          // Draw Parking Utilization
          translate(0,0,3);
          noStroke();  
          if (p.highlight) {
            fill(0, 150);
          } else {
            fill(0, 200);
          }
          if (p.utilization > 0 && p.capacity > 0) {
            arc(p.location.x, p.location.y, -10 + pW, -10 + pW, 0, p.ratio*2*PI);
          }
          
          //// Draw Potential Volume
          ////
          //if (p.capacity != p.utilization) {
          //  pushMatrix(); translate(p.location.x, p.location.y, pW/2-4);
          //  noFill(); stroke(255, 100); strokeWeight(1);
          //  box(0.7*pW, 0.7*pW, pW);
          //  popMatrix();
          //}
          
          //// Draw Development Volume
          ////
          //float h = pW*(1 - p.ratio);
          //pushMatrix(); translate(p.location.x, p.location.y, h/2-4);
          //fill(p.col, 100); noStroke();
          //box(0.7*pW, 0.7*pW, h);
          //popMatrix();
          
          // Draw Capacity Text
          //
          translate(0,0,1);
          fill(255, 255);
          textAlign(CENTER, CENTER);
          if (p.capacity - p.utilization > 0) text(p.capacity - p.utilization, int(p.location.x), int(p.location.y));
          
          // Draw Development Volume
          //
          if (!p.active || p.utilization == 0) {
            pushMatrix(); translate(p.location.x, p.location.y, 0.5*pW-4);
            fill(p.col, 100); stroke(p.col, 150); strokeWeight(1);
            box(0.7*pW, 0.7*pW, pW);
            popMatrix();
          }
        }
      } 
    }
    popMatrix();
  }
    
  //  Display the population of agents
  //
  float scaler = 2.0 * (1 + 2*cam.zoom);
  if (showCar1) for (Agent p: type1) p.display(scaler, "BOX", car1Color, 200);
  if (showCar2) for (Agent p: type2) p.display(scaler, "BOX", car2Color, 200);
  if (showCar3) for (Agent p: type3) p.display(scaler, "BOX", car3Color, 200);
  if (showCar4) for (Agent p: type4) p.display(scaler, "BOX", car4Color, 200);
}
  
void render2D() {  
  
  // -------------------------
  // Begin Drawing 2D Elements
  cam.off();
  
  if (SHOW_INFO) {
    
    // Draw Slider Bars for Controlling Zoom and Rotation (2D canvas begins)
    cam.drawControls();
    
    // Draw Margin Toolbar
    bar_left.draw();
    bar_right.draw();
    
    // Draw Large Current Year and Parking Demand Reduction
    //
    pushMatrix(); translate(bar_left.barX + bar_left.barW + bar_left.margin, bar_left.barY);
    textAlign(LEFT, TOP); textFont(font60);
    text(sys.year_now, 0, 0);
    textFont(font12); fill(255);
    text("Parking Demand (since 2010):", 0, 70);
    int yr = sys.year_now - sys.year_0;
    float parking_demand  = sys.totalPark[yr];
    float parking_total   = sys.totalPark[0];
    String sign = "";
    if (parking_demand < parking_total) {
      fill(#00AA00, 200);
    } else if (parking_demand > parking_total) {
      fill(#AA0000, 200);
      sign += "+";
    } else if (parking_demand == parking_total) {
      fill(150, 200);
    }
    textFont(font60);
    text(sign + " " + int(1000*(parking_demand-parking_total)/parking_total)/10.0 + "%", 0, 86);
    textFont(font12);
    popMatrix();
    
    // Radio Button Labels:
    //
    
    pushMatrix(); translate(bar_left.barX + bar_left.margin, int(17.5*bar_left.CONTROL_H) );
    textAlign(LEFT, BOTTOM); fill(255); 
    text("Parking", 0, 0);
    translate(bar_left.contentW/2, 0);
    text("Vehicles", 0, 0);
    popMatrix();
    
    // Draw System Output
    //
    pushMatrix(); translate(bar_right.barX + bar_right.margin, bar_right.controlY);
    sys.plot4("Vehicle Counts", "[100's]",       sys.numCar1,   sys.numCar2,   sys.numCar3,     sys.numCar4,   car1Color,  car2Color,  car3Color,    car4Color,  0,   0, bar_right.contentW, 125, 0.020);
    sys.plot4("Trips by Vehicle Type", "[100's]",sys.numTrip1,  sys.numTrip2,  sys.numTrip3,    sys.numTrip4,  car1Color,  car2Color,  car3Color,    car4Color,  0, 165, bar_right.contentW, 125, 0.015);
    sys.plot4("Parking Space Demand", "[100's]", sys.numPark1,  sys.numPark2,  sys.numPark3,    sys.numPark4,  car1Color,  car2Color,  car3Color,    car4Color,  0, 330, bar_right.contentW, 125, 0.040);
    sys.plot4("Parking Space Vacancy", "[100's]",sys.otherFree, sys.belowFree, sys.surfaceFree, sys.aboveFree, #990000,    belowColor, surfaceColor, aboveColor, 0, 495, bar_right.contentW, 125, 0.080);
    popMatrix();
  }
  
  // Draw Parking Info Box
  //
  if (hoverType .equals("parking")) structures.parking.get(hoverIndex).displayInfo();
  
}

PImage loadingBG;
void loadScreen(PImage bg, int phase, int numPhases, String status) {
  image(bg, 0, 0, width, height);
  pushMatrix(); translate(width/2, height/2);
  int lW = 400;
  int lH = 48;
  int lB = 10;
  
  // Draw Loading Bar Outline
  noStroke(); fill(255, 200);
  rect(-lW/2, -lH/2, lW, lH, lH/2);
  noStroke(); fill(0, 200);
  rect(-lW/2+lB, -lH/2+lB, lW-2*lB, lH-2*lB, lH/2);
  
  // Draw Loading Bar Fill
  float percent = float(phase)/numPhases;
  noStroke(); fill(255, 150);
  rect(-lW/2 + lH/4, -lH/4, percent*(lW - lH/2), lH/2, lH/4);
  
  textAlign(CENTER, CENTER); fill(255);
  text(status, 0, 0);
  
  popMatrix();
}