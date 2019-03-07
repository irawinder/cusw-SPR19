/*  AGENT CLASS
 *  Ira Winder, ira@mit.edu, 2018
 *
 *  A force-based autonomous agent that can navigate along 
 *  a series of waypoints that comprise a path
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

// TODO - Reduce complexity/entanglements of Agent() class

class Agent {
  // What is the "friendly" name of your agent?
  String type;
  // What is it's radius?
  float radius;
  // Is this agent special or need to be highlighted?
  boolean highlight;
  boolean showPath;
  
  // What is the agent's instantaneous status?
  PVector locationPath;       // location down center of path
  PVector location;           // absolute location, accounting for right or left-hand lane offset
  PVector velocity;
  PVector acceleration;
  
  // Maximum velocity and acceleration
  float maxforce;
  float maxspeed;
  
  // imprecision of agent movement
  float uncertainty = 0; 
  
  // PathFinding Attributes:
  //
  // Waypoints for an agent to follow
  ArrayList<PVector> path;
  int pathIndex, pathLength; // Index and Amount of Nodes in a Path
  int pathDirection; // -1 or +1 to specific directionality
  // After reaching end of path, does the agent retrace its steps backwards or go directly back to beginning?
  boolean loop;
  // if loop, does agent teleport to beginning after reaching the end?
  boolean teleport; 
  // Does the agent have a preference for the right or for the left side of a path?
  String laneSide; 
  
  // Specify up to 4 passengers to draw in vehicle
  int passengers;
  // Specify if vehicle needs a human driver
  boolean driver;
  boolean showPassengers;
  
  // screen location (for mouse commnads)
  //
  float s_x, s_y; 
  void setScreen() {
    s_x = screenX(location.x, location.y, location.z);
    s_y = screenY(location.x, location.y, location.z);
  }
  
  Agent(float x, float y, int radius, float maxS, ArrayList<PVector> path, boolean loop, boolean teleport, String laneSide, String type) {
    this.radius = radius;
    maxspeed = maxS;
    maxforce = 0.2;
    this.path = path;
    this.type = type;
    pathLength = path.size();
    
    // If loop = true, agent will immediately seek to origin if destination is reached
    // If loop = false, agent will retrace its path back and forth along a path
    this.loop = loop;
    
    // If teleport and loop = true; agent will teleport to origin when destination is reached
    // If teleport = false; agent will seek origin without teleporting when destination is reached; may ignore path when returning
    this.teleport = teleport;
    
    // If laneSide = "RIGHT"; cars will be offset to the right
    // If laneSide = "LEFT"; cars will be offset to the left
    this.laneSide = laneSide;
    
    if (loop) {
      pathDirection = +1;
    } else {
      if (random(-1, 1) <= 0 ) {
        pathDirection = -1;
      } else {
        pathDirection = +1;
      }
    }
    
    float jitterX = random(-uncertainty, uncertainty);
    float jitterY = random(-uncertainty, uncertainty);
    locationPath  = new PVector(x + jitterX, y + jitterY);
    location      = new PVector(x + jitterX, y + jitterY);
    acceleration  = new PVector(0, 0);
    velocity      = new PVector(0, 0);
    pathIndex     = getClosestWaypoint(locationPath);
    
    highlight = false;
    showPath  = false;
    
    passengers = 4;
    driver = true;
    showPassengers = true;
  }
  
  PVector seek(PVector target){
    PVector desired = PVector.sub(target,locationPath);
    desired.normalize();
    desired.mult(maxspeed);
    PVector steer = PVector.sub(desired,velocity);
    steer.limit(maxforce);
    return steer;
  }
  
  PVector separate(ArrayList<PVector> others){
    float desiredseparation = radius;
    PVector sum = new PVector();
    int count = 0;
    
    for(PVector loc : others) {
      float d = PVector.dist(loc, locationPath);
      
      if ((d > 0 ) && (d < desiredseparation)){
        
        PVector diff = PVector.sub(loc, locationPath);
        diff.normalize();
        diff.div(d);
        sum.add(diff);
        count++;
      }
    }
    if (count > 0){
      sum.div(count);
      sum.normalize();
      sum.mult(maxspeed);
      sum.sub(velocity);
      sum.limit(maxforce);
    }
   return sum;   
  }
  
  // calculates the index of path node closest to the given canvas coordinate 'v'.
  // returns 0 if node not found.
  //
  int getClosestWaypoint(PVector v) {
    int point_index = 0;
    float distance = Float.MAX_VALUE;
    float currentDist;
    PVector p;
    for (int i=0; i<path.size(); i++) {
      p = path.get(i);
      currentDist = sqrt( sq(v.x-p.x) + sq(v.y-p.y) );
      if (currentDist < distance) {
        point_index = i;
        distance = currentDist;
      }
    }
    return point_index;
  }
  
  void update(ArrayList<PVector> others, boolean collisionDetection) {
    
    // Apply Repelling Force
    PVector separateForce;
    if (collisionDetection) {
      separateForce = separate(others);
      separateForce.mult(1);
      acceleration.add(separateForce);
    }
    
    // Apply Seek Force
    PVector waypoint = path.get(pathIndex);
    float jitterX = random(-uncertainty, uncertainty);
    float jitterY = random(-uncertainty, uncertainty);
    PVector direction = new PVector(waypoint.x + jitterX, waypoint.y + jitterY);
    PVector seekForce = seek(direction);
    seekForce.mult(1);
    acceleration.add(seekForce);
    
    // Update velocity
    velocity.add(acceleration);
    
    // Update Location on Path
    locationPath.add(new PVector(velocity.x, velocity.y));
    
    // Adjust location to left or right of centerline
    //
    float orientation = velocity.heading(); 
    float xLane=0; float yLane=0;
    if(laneSide.equals("RIGHT")) {
      xLane = radius*cos(orientation+PI/2);
      yLane = radius*sin(orientation+PI/2);
    } else if(laneSide.equals("LEFT")) {
      xLane = -radius*cos(orientation+PI/2);
      yLane = -radius*sin(orientation+PI/2);
    }
    location.x = locationPath.x + xLane;
    location.y = locationPath.y + yLane;
        
    // Limit speed
    velocity.limit(maxspeed);
    
    // Reset acceleration to 0 each cycle
    acceleration.mult(0);
    
    // Checks if Agents reached current waypoint
    // If reaches endpoint, reverses direction
    //
    float prox = sqrt( sq(locationPath.x - waypoint.x) + sq(locationPath.y - waypoint.y) );
    if (prox < 3 && path.size() > 1 ) {
      
      // If return to origin
      if (loop) {
        if (pathDirection == 1 && pathIndex == pathLength-1) {
          pathIndex = 0;
          if (teleport) {
            locationPath.x = path.get(0).x;
            locationPath.y = path.get(0).y;
          }
        } else {
          pathIndex += pathDirection;
        }
        
      // If retrace path backward
      } else {
        if (pathDirection == 1 && pathIndex == pathLength-1 || pathDirection == -1 && pathIndex == 0) {
          pathDirection *= -1;
        }
        pathIndex += pathDirection;
      }
    }
  }
  
  void display(float scaler, String type, color col, int alpha) {
    
    // Find Screen location of vehicle
    setScreen();
    
    if (s_x>0 && s_x<width && s_y>0 && s_y<height) {
    
      // Adjust vehicle's location and orientation
      pushMatrix(); translate(location.x, location.y);
      float orientation = velocity.heading(); 
      rotate(orientation + PI/2);
      
      noStroke();
      if (highlight) {
        fill(col, 255);
      } else {
        fill(col, alpha);
      }
      if (type.equals("BOX")) {
        
        // Draw Vehicle
        //
        box(scaler*radius, 2*scaler*radius, 0.75*scaler*radius);
        
        // Draw Passengers
        //
        if (showPassengers) {
          int i = 1;
          int driverOffset = 0;
          if ((!driver && passengers < 4) || driver) {
            driverOffset = 1;
          } else if (passengers == 4) {
            i = 0;
          }
            
          while (i<passengers+driverOffset) {
            float x = (scaler * radius) * ( -0.25 + 0.5 * int( 0.5 * i ) );
            float y = (scaler * radius) * ( -0.40 + 0.8 * (  1 - (i+1) % 2 ) );
            stroke(0, 200); strokeWeight(0.80*scaler*radius);
            pushMatrix(); translate(x, y, 0.5*scaler*radius); point(0, 0); popMatrix();
            i++;
          }
          float x = (scaler * radius) * ( -0.25 );
            float y = (scaler * radius) * ( -0.40 );
          if (this.type.equals("2") ) {
            stroke(0, 150); strokeWeight(1); noFill();
            pushMatrix(); translate(x, y, 0.5*scaler*radius); ellipse(0, 0, 0.40*scaler*radius, 0.40*scaler*radius); popMatrix();
          } else if (this.type.equals("1") ) {
            stroke(0, 150); strokeWeight(0.80*scaler*radius);
            pushMatrix(); translate(x, y, 0.5*scaler*radius); point(0, 0); popMatrix();
          }
            
            
        }
        
      } else {
        ellipse(0, 0, scaler*radius, scaler*radius);
      }
      
      if (highlight || showPath) {
        // Draw Bubble around car
        fill(#00AA00, 50); noStroke();
        sphere(4*scaler*radius);
      }
      popMatrix();
      
      if (showPath) {
        // Draw Bubble around destination
        pushMatrix(); translate(path.get(0).x, path.get(0).y);
        fill(#AA0000, 100); noStroke();
        sphere(4*scaler*radius);
        popMatrix();
      }
      
      // Draw Path
      if (showPath) {
        noFill(); stroke(#00AA00, 100); strokeWeight(3); strokeCap(ROUND);
        beginShape();
        for (PVector v: path) vertex(v.x, v.y);
        endShape();
      }
    }
  }
}