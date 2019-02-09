void setup(){
  size(800, 800);
  frameRate(10);
}

void draw(){
  background(255);
  noStroke();
  
  /*
  Opacity examples
  */
  colorMode(RGB);
  //First, look at opacity which ranges from 0 to 255, or transparent to fully filled
  fill(0, 100, 20); //full opacity
  ellipse(100, 50, 20, 20);
  fill(0, 100, 20, 255); //still full
  ellipse(130, 50, 20, 20);
  fill(0, 100, 20, 200);
  ellipse(160, 50, 20, 20);
  fill(0, 100, 20, 150);
  ellipse(190, 50, 20, 20);
  fill(0, 100, 20, 50);
  ellipse(190, 50, 20, 20); 
  fill(0, 100, 20, 10);
  ellipse(190, 50, 20, 20);
  
  
  /*
  Gradient lerp
  */
  colorMode(RGB);
  //Nice lerp gradient for heatmaps from red to green, using yellow as an inbetween to avoid the brown you get between them
  //Read here https://processing.org/reference/lerpColor_.html
  color red = color(230, 0, 0); //Red
  color green = color(0, 150, 0); //Green
  color yellow = color(255, 255, 0); //Yellow -- between green and red 
  color col = color(0);
  
  for(int i = 0; i<200; i++){
    if(i<100) col = lerpColor(red, yellow, i/100.0);
    if(i == 100) col = yellow;
    if(i > 100) col = lerpColor(yellow, green, (i-100)/100.0);
    fill(col);
    rect(100 + i, 200, 1, 30);
  }
  
  /*
  Rainbow colors!
  */
  colorMode(HSB);
  color new_color = color( random(255.0), 255, 255);
  fill(new_color);
  ellipse(300, 300, 100, 100);
  
  /*
  Data/Quant Based Gradient
  Changing color from a variable 
  */
  colorMode(RGB);
  float my_fun_variable = random(0, 255);
  color my_color = color(my_fun_variable, 0, 0);
  fill(my_color);
  ellipse(400, 100, 40, 40);
  
}
