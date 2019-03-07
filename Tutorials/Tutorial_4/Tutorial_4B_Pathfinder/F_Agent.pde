class Agent {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;
  float maxspeed;
  float tolerance = 1;
  ArrayList<PVector> path;
  int pathIndex, pathLength; // Index and Amount of Nodes in a Path
  int pathDirection; // -1 or +1 to specific directionality
  
  Agent(float x, float y, int rad, float maxS, ArrayList<PVector> path) {
    r = rad;
    tolerance *= r;
    maxspeed = maxS;
    maxforce = 0.2;
    this.path = path;
    pathLength = path.size();
    if (random(-1, 1) <= 0 ) {
      pathDirection = -1;
    } else {
      pathDirection = +1;
    }
    float jitterX = random(-tolerance, tolerance);
    float jitterY = random(-tolerance, tolerance);
    location = new PVector(x + jitterX, y + jitterY);
    acceleration = new PVector(0, 0);
    velocity = new PVector(0, 0);
    pathIndex = getClosestWaypoint(location);
  }
  
  PVector seek(PVector target){
    PVector desired = PVector.sub(target,location);
    desired.normalize();
    desired.mult(maxspeed);
    PVector steer = PVector.sub(desired,velocity);
    steer.limit(maxforce);
    return steer;
  }
  
  PVector separate(ArrayList<PVector> others){
    float desiredseparation = 0.5 * r;
    PVector sum = new PVector();
    int count = 0;
    
    for(PVector location : others) {
      float d = PVector.dist(location, location);
      
      if ((d > 0 ) && (d < desiredseparation)){
        
        PVector diff = PVector.sub(location, location);
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
    PVector separateForce = separate(others);
    if (collisionDetection) {
      separateForce.mult(3);
      acceleration.add(separateForce);
    }
    
    // Apply Seek Force
    PVector waypoint = path.get(pathIndex);
    float jitterX = random(-tolerance, tolerance);
    float jitterY = random(-tolerance, tolerance);
    PVector direction = new PVector(waypoint.x + jitterX, waypoint.y + jitterY);
    PVector seekForce = seek(direction);
    seekForce.mult(1);
    acceleration.add(seekForce);
    
    // Update velocity
    velocity.add(acceleration);
    
    // Update Location
    location.add(new PVector(velocity.x, velocity.y));
        
    // Limit speed
    velocity.limit(maxspeed);
    
    // Reset acceleration to 0 each cycle
    acceleration.mult(0);
    
    // Checks if Agents reached current waypoint
    // If reaches endpoint, reverses direction
    //
    float prox = sqrt( sq(location.x - waypoint.x) + sq(location.y - waypoint.y) );
    if (prox < 3 && path.size() > 1 ) {
      if (pathDirection == 1 && pathIndex == pathLength-1 || pathDirection == -1 && pathIndex == 0) {
        pathDirection *= -1;
      }
      pathIndex += pathDirection;
    }
  }
  
  void display(color col, int alpha) {
    fill(col, alpha);
    noStroke();
    ellipse(location.x, location.y, r, r);
  }
}
