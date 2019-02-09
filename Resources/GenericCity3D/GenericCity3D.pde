/*
Computational Urban Science Workshop
Ira Winder and Nina Lutz 

Script: Nina Lutz
A script that generates a random city on a predetermined grid 
and makes 3 different lights
*/

void setup() {
  size(900, 700, P3D);
  initCity();
}

void draw() {
  
  background(20);
  
  //Moves your view with the mouse
  camera(mouseX, mouseX, (height/2) / tan(PI/6), width/2, height/2, 0, 0, 1, 0);

  //Rotation and translation to keep it spinning
  translate(width/2, height/2 + 100, 0);
  rotateX(-radians(20));
  rotateY(radians(45+num));
  
  //3 different lights
  pointLight(0, 255, 0, lightx1, -40, lightz1);
  pointLight(0, 0, 255, lightx2, -40, lightz2);
  pointLight(255, 0, 0, lightx3, -40, lightz3);
  
  strokeWeight(1);
  
  //Draws buildings
  drawBuildings();
  
  //Draws lights
  drawLights();
  

}
