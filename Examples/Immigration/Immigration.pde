//Shamelessly taken from Ira Winder's Github for a class example
//https://github.com/irawinder/Immigration

World synthetic;
String worldType = "UN_REGIONS";

void setup() {
  size(1200, 900);
  synthetic = new World(worldType);
  runTime = 1000;
}

// Amount of frmes to run draw() function when graphics need to be refreshed
// Set to a number as high as needed when updating visuals that need to be animated
int runTime = 0;

void draw() {
  
  background(30);
  synthetic.update();
  synthetic.display();
  
  if (runTime > 0) {
    runTime--;
  } else {
    noLoop();
  }
}

void keyPressed() {
  switch(key) {
    case 'r': // reset
      synthetic = new World(worldType);
      runTime = 1000;
      loop();
      break;
    case 'n': // next type
      if (worldType.equals("RANDOM")) {
        worldType = "UN_CONTINENTS";
      } else if (worldType.equals("UN_CONTINENTS")) {
        worldType = "UN_REGIONS";
      } else if (worldType.equals("UN_REGIONS")) {
        worldType = "UN_NATIONS";
      } else if (worldType.equals("UN_NATIONS")) {
        worldType = "RANDOM";
      }
      
      synthetic = new World(worldType);
      runTime = 1000;
      loop();
      break;
    case 'm': // migrate
      int origin, destination;
      for (int i=0; i<25; i++) {
        origin = int(random(0, synthetic.worldNations.size() ));
        destination = int(random(0, synthetic.worldNations.size() ));
        synthetic.migrate(0, origin, destination);
      }
      runTime = 1000;
      loop();
      break;
  }  
}
