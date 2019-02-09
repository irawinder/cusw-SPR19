
void drawLights(){
  pushMatrix();
  translate(0, -50, 0);

  strokeWeight(20);
  
  stroke(0, 255, 0);
  translate(0, 0, lightz1);
  ellipse(lightx1, -40, 5, 5);
  translate(0, 0, -lightz1);
  
  stroke(0, 0, 255);
  translate(0, 0, lightz2);
  ellipse(lightx2, -40, 5, 5);
  translate(0, 0, -lightz2);
  
  stroke(255, 0, 0);
  translate(0, 0, lightz3);
  ellipse(lightx3, -40, 5, 5);
  translate(0, 0, -lightz3);
  popMatrix();

}
