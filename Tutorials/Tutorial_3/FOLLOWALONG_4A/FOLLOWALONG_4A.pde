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
  planetA = new Body(100.0);
  
  // Planet B
  //planetB = new Body(500.0);
  
  // Planet C
  //star = new Body(2000.0);
  
}

void draw() {
  
  // Set all bodys' accelerations to 0
  
  // Each body exerts a force on all other bodies
  
  // Draw all Bodies;
  background(255);
  planetA.draw(accLine);
  //planetB.draw(accLine);
  //star.draw(accLine);
  
  // Update Velocity and Location of each body (Why do we do this *after* drawing the bodies?)
  
  // Draw UI
  fill(50);
  text("Press any key to draw acceleration vector (Currently " + accLine + ")", 25, 25);
}

boolean accLine = false;
void keyPressed() {
  accLine = !accLine;
}
