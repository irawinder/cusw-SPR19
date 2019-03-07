// The Body class is an autonoumous object with mass that follows 
// Newton's laws. It is designed to experience gravity.

class Body {
  
  // At any given time, our Body has a location, 
  // velocity, and acceleration expressed as vectors:
  PVector location;
  PVector velocity;
  PVector acceleration;
  
  // The Body's mass:
  float mass;
  
  // color of our Body
  color col; 
  
  Body(float _mass) {
    // Body is initialized as a static object at the center of the canvas:
    location = new PVector(width/2, height/2);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0,0);
    
    mass = _mass;
    
    // translucent gray color by default
    col = color(0, 200);
  }
  
  void resetAcceleration() {
    acceleration.setMag(0);
  }
  
  void applyGravity(Body a) {
    
    // 1. Calculate Magnitude of Gravity
    // acceleration = pixels per second per second
    // force = G*m2/d^2
    // force = mass * acceleration
    //
    //float G = 
    //float distance = 
    //float magnitude = 
    
    // 2. Vectorize gravity:
    //PVector gravity =
    
    // 3. Apply gravity of body a to acceleration:
    
  }
  
  // this function is designed to run every 'timestep'
  void update() {
    
    // Every frame, we apply Euler's method to update the 
    // velocity then location of our Body:
    // Reference: https://en.wikipedia.org/wiki/Euler_method
    
    // v = pixels per second
    
    // l = pixels
    
  }
  
  void draw(boolean showForce) {
    
    if (showForce) {
      // Draw Acceleration Vector
      stroke(200, 100); strokeWeight(5);
      line(location.x, location.y, location.x + 1000*acceleration.x, location.y + 1000*acceleration.y);
    }
    
    // Draw Planetoid (Dimenion of Circle is proportional to cube root of mass)
    fill(col); noStroke();
    circle(location.x, location.y, pow(10*mass, 1.0/3));
    
  }
}
