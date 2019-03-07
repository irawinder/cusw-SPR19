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
    
    // acceleration = pixels per second per second
    // force = G*m2/d^2
    float G = 0.3;
    float distance = max(50, location.dist(a.location)); // minimum of 50 px prevents slingshots
    float magnitude = G*a.mass/sq(distance); // Newton's Law of Gravitation
    
    PVector gravity = new PVector(a.location.x - location.x, a.location.y - location.y);
    gravity.normalize();
    gravity.setMag(magnitude);
    
    // force = mass * acceleration OR acceleration = force / mass
    acceleration.add(gravity);
  }
  
  // this function is designed to run every 'timestep'
  void update() {
    
    // Every frame, we apply Euler's method to update the 
    // velocity then location of our Body:
    // Reference: https://en.wikipedia.org/wiki/Euler_method
    
    // v = pixels per second
    velocity.add(acceleration);
    
    // l = pixels
    location.add(velocity);
  }
  
  void draw(boolean showForce) {
    
    if (showForce) {
      // Draw Acceleration Vector
      stroke(200, 100); strokeWeight(5);
      line(location.x, location.y, location.x + 1000*acceleration.x, location.y + 1000*acceleration.y);
    }
    
    // Draw Planetoid
    fill(col); noStroke();
    circle(location.x, location.y, pow(10*mass, 1.0/3));
    
  }
}
