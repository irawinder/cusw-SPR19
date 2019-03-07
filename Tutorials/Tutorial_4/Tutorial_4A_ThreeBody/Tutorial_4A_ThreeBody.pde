/*
Computational Urban Science Workshop
Ira Winder and Nina Lutz 

Script: Ira Winder
Three-body solution with Agent Based Simulation + Euler's Method
*/

// Our three bodies that we wish to simulate
Body planetA, planetB, star;

void setup() {
  size(800, 800);
  
  // Planet A
  planetA = new Body(100.0);  // Initial Mass
  planetA.location.y += -200; // Initial Location
  planetA.velocity.x += +1.0; // Initial Velocity
  
  // Planet B
  planetB = new Body(500.0); // Initial Mass
  planetB.location.x += +100; // Initial Location
  planetB.velocity.y += -2.0; // Initial Velocity
  
  // Planet C
  star = new Body(2000.0);   // Initial Mass
  star.location.x += +000;    // Initial Location
  star.velocity.y += +0.5;    // Initial Velocity
  star.col = color(255, 200, 0, 200); // Yellow
  
}

void draw() {
  
  // Set all body's accelerations to 0
  planetA.resetAcceleration();
  planetB.resetAcceleration();
  star.resetAcceleration();
  
  // Each body exerts a force on all other bodies
  planetA.applyGravity(star);
  planetA.applyGravity(planetB);
  planetB.applyGravity(star);
  planetB.applyGravity(planetA);
  star.applyGravity(planetA);
  star.applyGravity(planetB);
  
  // Draw all Bodies;
  background(255);
  planetA.draw(accLine);
  planetB.draw(accLine);
  star.draw(accLine);
  
  // Update Velocity and Location of each body
  planetA.update();
  planetB.update();
  star.update();
  
  fill(50);
  text("Press any key to draw acceleration vector", 25, 25);
}

boolean accLine = false;
void keyPressed() {
  accLine = !accLine;
}
