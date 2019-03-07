/*  DRIVING FUTURES
 *  Ira Winder, ira@mit.edu, 2018
 *
 *  Primary Parking classes to enable a system of parking ammenities and vehicle demand.
 *
 *  CLASSES CONTAINED:
 *
 *    Parking_System()     - Mathematically realated parameters to forcast vheicle and parking demand over time using logistic equations
 *    Parking_Structures() - A portfolio of Parking Structures (Surface, Below Ground, and Above Ground)
 *    Parking_Routes()     - A list of travel routes to and from Parking Structures - Depends on Pathfinder.pde
 *    Parking()            - A Parking Structure with attributes
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

// Contains a system of elements including autonomous vehicles, ride share vehicles, 
// parking information, trip demands, and simulated outputs.
//
class Parking_System {
  int tripDemand_0;
  int year_0, year_f, year_now, intervals; // initial and final years
  float demand_growth; // yearly growth for trip demand (exponential growth)
  
  float rideShare_share; // % trips using Ride Share at Equilibrium
  float rideShare_growth; // Pace of Adoption (k-value of logistic eq.)
  int rideShare_peak_hype_year; // Year of peak adoption
  
  float av_share; // % trips using Autonomous Vehicle at Equilibrium
  float av_growth; // Pace of Adoption (k-value of logistic eq.)
  int av_peak_hype_year; // Year of peak adoption
  
  int totOther, totBelow, totSurface, totAbove; // Total Parking Stock at year_0
  int belowOff, surfaceOff, aboveOff; // Total Deactivated Stock
  float priorityBelow, prioritySurface, priorityAbove; // Relative priority when removing parking utilization (all three must add up to 1!!
  
  /* 4 Car Types:
   *
   *                Human Driver              Autonomous Vehicle
   *
   *  Private       1. [Private, Driver]      3. [Private, AV]
   *
   *   Shared       2. [Shared,  Driver]      4. [Shared,  AV]
   */
  
  // Number of Trips Demanded for array of N years (This is a KEY Independent Variable!)
  int[] tripDemand;
  
  // Number of Vehicles of Each Type for array of N years
  int[] numCar1,  numCar2,  numCar3,  numCar4,  totalCars;
  
  // Number of Local Parking Spaces needed for each Vehicle to array of N years
  int[] numPark1, numPark2, numPark3, numPark4, totalPark;
  
  // Number of Vehicles of Each Type for array of N years
  int[] numTrip1,  numTrip2,  numTrip3,  numTrip4;
  
  // Number of Parking Spaces "Freed Up" by vehicle reduction
  int[] otherFree, belowFree, surfaceFree, aboveFree, totalFree;
   
  // Number of trips served per vehicle of each type
  float TRIPS_PER_CAR1 = 1.0;
  float TRIPS_PER_CAR2 = 4.0;
  float TRIPS_PER_CAR3 = 1.0;
  float TRIPS_PER_CAR4 = 5.0;
   
  // Number of parking Spaces needed per vehicle of each type
  float SPACES_PER_CAR1 = 0.85;
  float SPACES_PER_CAR2 = 0.10;
  float SPACES_PER_CAR3 = 0.70;
  float SPACES_PER_CAR4 = 0.15;
   
  Parking_System(int tripDemand_0, int year_0, int year_f) {
    this.tripDemand_0 = tripDemand_0;
    this.year_0 = year_0;
    this.year_f = year_f;
    intervals = 1 + year_f - year_0;
    year_now = year_0;
     
    tripDemand    = new int[intervals];
     
    numCar1       = new int[intervals];
    numCar2       = new int[intervals];
    numCar3       = new int[intervals];
    numCar4       = new int[intervals];
    totalCars     = new int[intervals];
     
    numPark1      = new int[intervals];
    numPark2      = new int[intervals];
    numPark3      = new int[intervals];
    numPark4      = new int[intervals];
    totalPark     = new int[intervals];
     
    numTrip1      = new int[intervals];
    numTrip2      = new int[intervals];
    numTrip3      = new int[intervals];
    numTrip4      = new int[intervals];
     
    otherFree     = new int[intervals];
    belowFree     = new int[intervals];
    surfaceFree   = new int[intervals];
    aboveFree     = new int[intervals];
    totalFree     = new int[intervals];
  }
   
  void update() {
    float av_s, rs_s; // Instantaneous share of AV and RideShare
     
    for (int i=0; i<intervals; i++) {
      av_s = logistic(av_share,        av_growth,        year_0 + i, av_peak_hype_year);
      rs_s = logistic(rideShare_share, rideShare_growth, year_0 + i, rideShare_peak_hype_year);

      tripDemand[i] = int(tripDemand_0 * pow(1 + demand_growth, i));
       
      // Update Vehicle Counts
      numCar1[i] = int( tripDemand[i] * (1 - av_s) * (1 - rs_s) / TRIPS_PER_CAR1 );
      numCar2[i] = int( tripDemand[i] * (0 + av_s) * (1 - rs_s) / TRIPS_PER_CAR2 );
      numCar3[i] = int( tripDemand[i] * (1 - av_s) * (0 + rs_s) / TRIPS_PER_CAR3 );
      numCar4[i] = int( tripDemand[i] * (0 + av_s) * (0 + rs_s) / TRIPS_PER_CAR4 );
       
      // Update Parking Space Demand
      numPark1[i]  = int( numCar1[i] * SPACES_PER_CAR1 ) * (totBelow +  totSurface + totAbove) / tripDemand_0;
      numPark2[i]  = int( numCar2[i] * SPACES_PER_CAR2 ) * (totBelow +  totSurface + totAbove) / tripDemand_0;
      numPark3[i]  = int( numCar3[i] * SPACES_PER_CAR3 ) * (totBelow +  totSurface + totAbove) / tripDemand_0;
      numPark4[i]  = int( numCar4[i] * SPACES_PER_CAR4 ) * (totBelow +  totSurface + totAbove) / tripDemand_0;
      totalPark[i] = numPark1[i] + numPark2[i] + numPark3[i] + numPark4[i];
       
      // Update Unutilized Parking Capacity
      totalFree[i]   = totBelow +  totSurface + totAbove - totalPark[i];
      belowFree[i]   = 0;
      surfaceFree[i] = 0;
      aboveFree[i]   = 0;
      if (totalFree[i] < 0) {
        // Negative total capacity is over capacity
        otherFree[i] = totalFree[i];
      } else {
        otherFree[i] = 0;
      }
      
      // Allocation of Parking Vacancy Based Upon Priority triangle
      //
      int pB = int( 0.5 + 100 * priorityBelow   ); // 0-100
      int pS = int( 0.5 + 100 * prioritySurface ); // 0-100
      int pA = int( 0.5 + 100 * priorityAbove   ); // 0-100
      int pBSA = pB + pS + pA; // ~100
      int pBS = pB + pS;
      int pBA = pB + pA;
      int pSA = pS + pA;
      int counterBSA = 0;
      int counterBS = 0;
      int counterBA = 0;
      int counterSA = 0;
      int k     = totalFree[i] - belowOff - surfaceOff - aboveOff;
      int kLast = totalFree[i] - belowOff - surfaceOff - aboveOff;
      while (k > 0) {
        // A. Tries to allocate to below ground
        if (counterBSA < pB) {
          if (belowFree[i] < totBelow) {
            belowFree[i]++;
            k--;
          } else {
            // i. Tries to allocate to Surface and Above
            if (pS == pA) {
              if (surfaceFree[i] < totSurface) {
                surfaceFree[i]++;
                k--;
              } 
              if (aboveFree[i] < totAbove) {
                aboveFree[i]++;
                k--;
              } 
            // ii. Tries to allocate to Surface THEN Above
            } else if (counterSA < pS || (pA == 0 && pS != 0) ) {
              if (surfaceFree[i] < totSurface) {
                surfaceFree[i]++;
                k--;
              } else if (aboveFree[i] < totAbove) {
                aboveFree[i]++;
                k--;
              } 
            // iii. Tries to allocate to Above THEN Surface
            } else {
              if (aboveFree[i] < totAbove) {
                aboveFree[i]++;
                k--;
              } else if (surfaceFree[i] < totSurface) {
                surfaceFree[i]++;
                k--;
              }
            }
            counterSA++;
            if (counterSA == pSA) counterSA = 0;
          }
        // B. Tries to allocate to surface
        } else if (counterBSA < pB+pS) {
          if (surfaceFree[i] < totSurface) {
            surfaceFree[i]++;
            k--;
          } else {
            if (pB == pA) {
              if (belowFree[i] < totBelow) {
                belowFree[i]++;
                k--;
              } 
              if (aboveFree[i] < totAbove) {
                aboveFree[i]++;
                k--;
              } 
            } else if (counterBA < pB || (pA == 0 && pB != 0) ) {
              if (belowFree[i] < totBelow) {
                belowFree[i]++;
                k--;
              } else if (aboveFree[i] < totAbove) {
                aboveFree[i]++;
                k--;
              } 
            } else {
              if (aboveFree[i] < totAbove) {
                aboveFree[i]++;
                k--;
              } else if (belowFree[i] < totBelow) {
                belowFree[i]++;
                k--;
              }
            }
            counterBA++;
            if (counterBA == pBA) counterBA = 0;
          }
        // B. Tries to allocate to above ground
        } else if (counterBSA < pB+pS+pA) {
          if (aboveFree[i] < totAbove) {
            aboveFree[i]++;
            k--;
          } else {
            if (pB == pS) {
              if (belowFree[i] < totBelow) {
                belowFree[i]++;
                k--;
              } 
              if (surfaceFree[i] < totSurface) {
                surfaceFree[i]++;
                k--;
              } 
            } else if (counterBS < pB || (pS == 0 && pB != 0) ) {
              if (belowFree[i] < totBelow) {
                belowFree[i]++;
                k--;
              } else if (surfaceFree[i] < totSurface) {
                surfaceFree[i]++;
                k--;
              } 
            } else {
              if (surfaceFree[i] < totSurface) {
                surfaceFree[i]++;
                k--;
              } else if (belowFree[i] < totBelow) {
                belowFree[i]++;
                k--;
              }
            }
            counterBS++;
            if (counterBS == pBS) counterBS = 0;
          }
        }
        counterBSA++;
        if (counterBSA == pBSA) counterBSA = 0;
        
        // Avoids infinite loop!
        if (kLast == k) {
          println("Infinite loop avoided!");
          break;
        } else {
          kLast = k;
        }
      }
      
      // Update Relative number of Trips 
      numTrip1[i]  = int( numCar1[i] * TRIPS_PER_CAR1 );
      numTrip2[i]  = int( numCar2[i] * TRIPS_PER_CAR2 );
      numTrip3[i]  = int( numCar3[i] * TRIPS_PER_CAR3 );
      numTrip4[i]  = int( numCar4[i] * TRIPS_PER_CAR4 );
    }
  }
  
  // Equation for Logistic (carrying capacity)
  // https://en.wikipedia.org/wiki/Logistic_function
  //
  float logistic(float L, float k, float x, float x_0) {
    return L / (1 + exp( -k*(x - x_0) ));
  }
  
  // Plot a stacked bar char with 4 elements per interval
  void plot4(String title, String unit, int[] value1, int[] value2, int[] value3, int[] value4, int color1, int color2, int color3, int color4, int x, int y, int w, int h, float scaler) {
  
    pushMatrix(); translate(x, y);
    float iWidth = float(w)/intervals;
    float columnW = 0.40*iWidth; // fraction of total width
     
    // Draw current year indicator
    //
    stroke(255, 100); noFill();
    int j = (year_now - year_0);
    float markerH = min(h, h-scaler*(value1[j] + value2[j] + value3[j] + value4[j])) - 5;
    line(j*iWidth + 0.5*columnW, 22, j*iWidth + 0.5*columnW, markerH);
    
    // Cycle through each interval of the graph
    //
    int alpha = 200;
    for (int i=0; i<intervals; i++) {
      float xpos1 = i*iWidth;
      noStroke();
      
      // Value 1
      fill(color1, alpha);
      rect( xpos1, h - scaler*value1[i], columnW, scaler*value1[i] );
      // Value 2
      fill(color2, alpha);
      rect( xpos1, h - scaler*(value1[i] + value2[i]), columnW, scaler*value2[i] );
      // Value 3
      fill(color3, alpha);
      rect( xpos1, h - scaler*(value1[i] + value2[i] + value3[i]), columnW, scaler*value3[i] );
      // Value 4
      fill(color4, alpha);
      rect( xpos1, h - scaler*(value1[i] + value2[i] + value3[i] + value4[i]), columnW, scaler*value4[i] );
       
    }
    
    // Draw Current Year Total
    //
    fill(150);
    String current = year_now + "\nTot: " + (value1[j]+value2[j]+value3[j]+value4[j]);
    if (j < intervals/2) {
      textAlign(LEFT, TOP);
      text(current, j*iWidth + iWidth, 20);
    } else {
      textAlign(RIGHT, TOP);
      text(current, j*iWidth - 0.5*iWidth, 20);
    }
    
    // Draw Graph Title, x_axis, and y_axis
    //
    fill(255);
    textAlign(LEFT, TOP);
    text(title, 0, 0);
    textAlign(RIGHT, TOP);
    text(unit, w, 0);
    fill(150);
    textAlign(LEFT, BOTTOM);
    text(year_0, 0, h+16);
    textAlign(RIGHT, BOTTOM);
    text(year_f, w, h+16);

    popMatrix();
  }
}

class Parking {
  PVector location;
  String type, name, respondent, address, devName, devAddy, parkMethod, userGroup;
  int capacity, utilization;
  float area, ratio;
  boolean show; // is this draw or detected in GUI
  int col;
  boolean highlight;
  boolean active;
  float s_x, s_y; // screen location (for mouse commnads)
  
  Parking(float x, float y, float area, String type, int capacity) {
    this.location = new PVector(x, y);
    this.type = type;
    this.capacity = capacity;
    this.area = area;
    this.utilization = capacity;
    ratio = 1.0;
    show = true;
    
    respondent = "";
    address = "";
    name = "";
    devName = "";
    devAddy = "";
    parkMethod = "";
    userGroup = "";
    
    highlight = false;
    active = true;
    
    // Initialize off screen
    s_x = -1000;
    s_y = -1000;
  }

  void setScreen() {
    s_x = screenX(location.x, location.y, location.z);
    s_y = screenY(location.x, location.y, location.z);
  }
  
  void displayInfo() {
    int rows = 7;
    if (!respondent.equals("")) rows++;
    if (!address.equals("")) rows++;
    if (!name.equals("")) rows++;
    if (!devName.equals("")) rows++;
    if (!devAddy.equals("")) rows++;
    if (!parkMethod.equals("")) rows++;
    if (!userGroup.equals("")) rows++;
    
    int infoW = 400;
    int infoH = 50 + rows * 16;
    float x, y;
    x = min(width  - infoW, s_x + 10);
    y = min(height - infoH, s_y + 10);
    fill(0, 200);   noStroke();
    rect(x+3, y+3, infoW, infoH, 25);
    fill(255, 20); noStroke();
    rect(x+0, y+0, infoW, infoH, 25);
    
    String typeInfo = "";
    typeInfo += "\n" + type;
    
    String spaceInfo = "";
    spaceInfo += "\n\n\n\n" + (capacity-utilization) + " / " + capacity + " spaces";
    
    String info = "";
    info += "Parking Typology:\n\n\nUnutilized Parking:";
    info += "\n\nParcel Area: " + int(area) + " sqft\n";
    if (!name.equals(""))
      info += "\nName: " + name;
    if (!address.equals("")) 
      info += "\nAddress: " + address;
    if (!devName.equals(""))
      info += "\nDeveloper: " + devName;
    if (!devAddy.equals(""))
      info += "\nDev. Addy: " + devAddy;
    if (!parkMethod.equals(""))
      info += "\nParking Method: " + parkMethod;
    if (!userGroup.equals(""))
      info += "\nUser Group: " + userGroup;
    if (!respondent.equals(""))
      info += "\n\nData Confirmed By: " + respondent;
    
    fill(col); textAlign(LEFT, TOP);
    text(typeInfo, int(x+25), int(y+25), infoW - 50, infoH-50);
    
    if (capacity == utilization) {
      fill(#FF0000);
      spaceInfo += " - AT CAPACITY";
    } else if (utilization == 0) {
      fill(#00FF00); 
      spaceInfo += " - VACANT";
    } else {
      fill(255);
    }
    text(spaceInfo, int(x+25), int(y+25), infoW - 50, infoH-50);
    
    fill(255);
    text(info, int(x+25), int(y+25), infoW - 50, infoH-50);
  }
    
}

class Parking_Structures {
  ArrayList<Parking> parking;
  int totBelow, totSurface, totAbove;
  int minCap = 200;
  
  Parking_Structures(float latMin, float latMax, float lonMin, float lonMax) {
    parking = new ArrayList<Parking>();
    totAbove = 0;
    totSurface = 0;
    totAbove = 0;
  }
  
  void reset() {
    for (Parking p: parking) p.active = true;
  }
}

class Parking_Routes {
  ArrayList<Path> paths;
  PGraphics img;
  Pathfinder finder;
  
  Parking_Routes(String fileName) {
    paths = new ArrayList<Path>();
    loadJSON(fileName);
  }
  
  Parking_Routes() {
    paths = new ArrayList<Path>();
  }
  
  // Paths are created by loading a compatible JSON file
  //
  void loadJSON(String fileName) {
    JSONArray pathsJSON = loadJSONArray(fileName);

    for (int i=0; i<pathsJSON.size(); i++) {
      // Each element in pathsJSON array is a path object
      JSONObject pathJSON = pathsJSON.getJSONObject(i);
      Path path = new Path();
      path.enableFinder = false;
      path.closed = true;
      path.diameter = 10;
      
      // Each path object contains series of waypoints:
      JSONArray waypointsJSON = pathJSON.getJSONArray("waypoints");
      path.waypoints = new ArrayList<PVector>();
      for (int j=0; j<waypointsJSON.size(); j++) {
        JSONObject waypointJSON = waypointsJSON.getJSONObject(j);
        float x = waypointJSON.getFloat("x");
        float y = waypointJSON.getFloat("y");
        PVector waypoint = new PVector(x, y);
        path.waypoints.add(waypoint);
        
        if( j == 0                        ) path.origin      = new PVector(x, y);
        if( j == waypointsJSON.size() - 1 ) path.destination = new PVector(x, y);
      }
      paths.add(path);
    }
  }
  
  // Save Paths to JSON
  //
  void saveJSON(String fileName) {
    JSONArray pathsJSON = new JSONArray();
    
    for (Path p: paths) {
      // Each element in pathsJSON array is a path object
      JSONObject pathJSON = new JSONObject();
    
      // Each path object contains series of waypoints:
      JSONArray waypointsJSON = new JSONArray();
      
      for (PVector v: p.waypoints) {
        JSONObject waypointJSON = new JSONObject();
        waypointJSON.setFloat("x", v.x);
        waypointJSON.setFloat("y", v.y);
        waypointsJSON.append(waypointJSON);
      }
      pathJSON.setJSONArray("waypoints", waypointsJSON);
      pathsJSON.append(pathJSON);
    }
    
    // JSON file saved to disk
    saveJSONArray(pathsJSON, "data/" + fileName);
  }
  
  void render(int w, int h) {
    img = createGraphics(w, h);
    img.beginDraw();
    img.clear();
    for (Path p: paths) {
      // Draw Shortest Path
      //
      PVector pt;
      img.noFill();
      img.stroke(255, 20);
      img.strokeWeight(10);
      img.strokeCap(ROUND);
      img.beginShape();
      for (int i=0; i<p.waypoints.size(); i++) {
        pt = p.waypoints.get(i);
        img.vertex(pt.x, pt.y);
      }
      img.endShape();
      
    }
    for (Path p: paths) {
      // Draw Origin (Red) and Destination (Blue)
      //
      img.fill(0, 255);     // Black
      img.stroke(255, 255); // White
      img.strokeWeight(4);
      img.ellipse(p.origin.x, p.origin.y, p.diameter, p.diameter);
      
    }
    img.endDraw();
  }
}