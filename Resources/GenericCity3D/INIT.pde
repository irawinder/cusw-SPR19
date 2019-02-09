boolean corners;
boolean lit;
ArrayList city = new ArrayList();
ArrayList lights = new ArrayList();
float num = 0;
int minDim = 10;
int maxDim = 30;

float lightx1, lightx2, lightx3, lightz1, lightz2, lightz3;
int locParam = 175;
int cellSize = 5;

//Simple function to initialize a random city
void initCity(){
  lightx1 = random(-locParam, locParam );
  lightx2 =random(-locParam, locParam );
  lightx3 = random(-locParam, locParam );
  
  lightz1 = random(-locParam, locParam );
  lightz2 = random(-locParam, locParam );
  lightz3 = random(-locParam, locParam );
  
  //initializes buildings on all parts of the 10x10 grid 
  for (int x = -cellSize; x <= cellSize; x++) {
    for (int z = -cellSize; z <= cellSize; z++) {
      float r = random(0, 1);
      if (r > 0.5) {
        float d = abs(10-dist(x, 0, z, 0, 0, 0));
        city.add(new Building(new PVector(random(-locParam, locParam), 0, random(-locParam, locParam)), random(d-d/2, d+(d*d)/5), random(minDim, maxDim), random(minDim, maxDim)));
      }
      //grid cells
      city.add(new Building(new PVector(x*35, 0, z*35), 0, 35, 35));
    }
  }
  

 //some coordinate workings
 if(corners){
   city.add(new Building(new PVector(0, 0, 0), 10, 35, 35)); //center
   city.add(new Building(new PVector(35*5, 0, 35*5), 10, 35, 35)); //right front at start 
   city.add(new Building(new PVector(35*-5, 0, 35*-5), 10, 35, 35)); //left back at start
   city.add(new Building(new PVector(35*5, 0, 35*-5), 10, 35, 35)); //right back at start   
   city.add(new Building(new PVector(35*-5, 0, 35*5), 10, 35, 35)); //left front at start
 }
 
}
