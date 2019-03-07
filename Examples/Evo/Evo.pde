/*  Ira Winder, jiw@mit.edu
 *
 *  An environment for testing natural selection processing on some digital "bugs"
 *  Groovy PREDATORS by Anton (adewinter)!
 */

/*  Key Parameters:
 *
 *    W, width of canvas [pixels]
 *    H, height of canvas [pixels]
 *
 *    D_f, diameter of food [pixels]
 *    P_f, period of food generation [ticks]
 *
 *    D_b, diameter of bug [pixels]
 *    V_b, maximum velocity of a "bug" [pixels/frame]
 *    S_b, number of bugs "spawned" when food eaten [bugs]
 *    H_b, number of ticks a bug can go without food before death [ticks]
 *
 *  Key Behaviors
 *
 *    - Bug acceleration is "random" in 2D space but velocity never exceeds V_b
 *    - Upon encountering food, a bug will eat it.  The polygon representing the bug and the food must intersect.
 *    - If a bug goes length of time H_b without eating food it will disappear from simulation
 *    - Upon eating food, the bug will become completely "full,"  and will instantly generate offspring of amount S_b
 *    - Every amount of time P_f, a unit of food is placed randomly on the canvas
 *
 */

ArrayList<Bug> population;
ArrayList<Food> noms;
ArrayList<Predator> preds;
Arena arena;

int FOOD_TIMER = 15;   // P_f
int FOOD_SIZE = 15;    // D_f
int FOOD_INITIAL_COUNT = 30;

int SPAWN_COUNT = 5;   // S_b
float MAX_SPEED = 0.5; // V_b
int MAX_HUNGER = 500;  // H_b
int BUG_SIZE = 5;      // D_b
int BUG_INITIAL_COUNT = 50;

int PREDATOR_INITIAL_COUNT = 5;
int PREDATOR_SPAWN_COUNT = 1;
float PREDATOR_SPAWN_CHANCE = 5.0;  // ( 0 - 100% )
int PREDATOR_MAX_HUNGER = 300;
float PREDATOR_MAX_SPEED = 1.0;
int PREDATOR_SIZE = 10;

int counter;

boolean run;

void setup() {
  size(1280, 764);
  arena = new Arena(600, 600); // W, H
  population = new ArrayList<Bug>();
  noms = new ArrayList<Food>();
  preds = new ArrayList<Predator>();

  PVector randomLocation;
  float randomX, randomY;

  // Random Bugs
  Bug randomBug;
  float scaler;
  for (int i=0; i<BUG_INITIAL_COUNT; i++) {
    randomX = random(0, arena.w);
    randomY = random(0, arena.h);
    randomLocation = new PVector(randomX, randomY);
    scaler = float(BUG_INITIAL_COUNT - i)/BUG_INITIAL_COUNT;
    randomBug = new Bug(scaler*MAX_SPEED, randomLocation, MAX_HUNGER, SPAWN_COUNT, BUG_SIZE);
    population.add(randomBug);
  }

  // Random Food
  Food randomFood;
  for (int i=0; i<FOOD_INITIAL_COUNT; i++) {
    randomX = random(0, arena.w);
    randomY = random(0, arena.h);
    randomLocation = new PVector(randomX, randomY);
    randomFood = new Food(randomLocation, FOOD_SIZE);
    noms.add(randomFood);
  }

  // Random Predators
  Predator randomPredator;
  for (int i=0; i<PREDATOR_INITIAL_COUNT; i++) {
    randomX = random(0, arena.w);
    randomY = random(0, arena.h);
    randomLocation = new PVector(randomX, randomY);
    randomPredator = new Predator(PREDATOR_MAX_SPEED, randomLocation, PREDATOR_MAX_HUNGER, PREDATOR_SPAWN_COUNT, PREDATOR_SIZE);
    preds.add(randomPredator);
  }

  counter = 0;
  run = false;
}

Food nom, newFood;
Bug bug, newBug;

void draw() {
  background(0);

  translate(width/2 - arena.w/2, height/2 - arena.h/2);
  arena.draw();

  if (run) {

    // Random Food
    if (counter >= FOOD_TIMER) {
      PVector randomLocation;
      float randomX, randomY;
      randomX = random(0, arena.w);
      randomY = random(0, arena.h);
      randomLocation = new PVector(randomX, randomY);
      newFood = new Food(randomLocation, FOOD_SIZE);
      noms.add(newFood);

      counter = 0;
    }

    // Update Food
    for (int b=population.size()-1; b>=0; b--) {
      bug = population.get(b);

      for (int f=noms.size()-1; f>=0; f--) {
        nom = noms.get(f);
        if (nom.eat(bug.location, bug.size)) {
          bug.full();
          noms.remove(nom);
        }
      }

      // Random Bugs
      PVector newLocation, newVelocity, newAcceleration;
      if (bug.spawn) {
        for (int j=0; j<bug.spawnSize; j++) {
          newLocation = new PVector(bug.location.x, bug.location.y);
          newVelocity = new PVector(bug.velocity.x, bug.velocity.y);
          newAcceleration = new PVector(bug.acceleration.x, bug.acceleration.y);
          newBug = new Bug(MAX_SPEED, newLocation, MAX_HUNGER, SPAWN_COUNT, BUG_SIZE, bug.bodyColor);
          newBug.velocity = newVelocity;
          population.add(newBug);
        }
        bug.spawn = false;
      }
    }

    // Update Bugs
    for (int i=population.size()-1; i>=0; i--) {
      bug = population.get(i);
      if (bug.starved) {
        population.remove(bug);
      }
      bug.update(arena);

      // Check if any predator ate this particular bug
      for (int p=preds.size()-1; p>=0; p--) {
        Predator pred = preds.get(p);
        if (pred.willEat(bug)) {
          pred.full();
          population.remove(bug);
        }
      }
    }

    // Update Predators
    for (int p=preds.size()-1; p>=0; p--) {
      Predator pred = preds.get(p);
      pred.spawn();
      if(pred.starved) {
        preds.remove(pred);
      }
      pred.update(arena);
    }

    counter++;
  }

  // Draw Food
  for (Food f : noms) {
    f.draw();
  }

  // Draw Bugs
  for (Bug b : population) {
    b.draw();
  }

  // Draw Predators
  for (Predator p : preds) {
    p.draw();
    p.nomBlip();
  }

  if (!run) {
    fill(255);
    textAlign(CENTER);
    text("Press SPACEBAR to begin", arena.w/2, arena.h/2);
  }
}

class Arena {
  int w, h;

  Arena(int w, int h) {
   this.w = w;
   this.h = h;
  }

  void draw() {
    noFill(); stroke(50); strokeWeight(FOOD_SIZE);
    rect(0, 0, w, h, FOOD_SIZE);
  }
}

class Bug {
  float maxSpeed;
  PVector location, velocity, acceleration;
  int hunger, maxHunger, spawnSize, size;
  boolean starved, spawn;
  color bodyColor = -1;

  Bug(float maxSpeed, PVector location, int maxHunger, int spawnSize, int size) {
    this.maxSpeed = maxSpeed;
    this.location = location;
    this.maxHunger = maxHunger;
    this.spawnSize = spawnSize;
    this.size = size;

    if (this.bodyColor == -1) {
      colorMode(HSB);
      this.bodyColor = color(125+random(100), 255, 255);
      colorMode(RGB);
    }
    velocity = new PVector(0,0,0);
    acceleration = new PVector(0,0,0);

    hunger = 0;
    starved = false;
    spawn = false;
  }

  Bug(float maxSpeed, PVector location, int maxHunger, int spawnSize, int size, color bodyColor) {
    this(maxSpeed, location, maxHunger, spawnSize, size);
    this.bodyColor = bodyColor;
  }

  void update(Arena a) {
    float MAX_ACC = 2.0;
    acceleration.x += random(-MAX_ACC, MAX_ACC);
    acceleration.y += random(-MAX_ACC, MAX_ACC);
    velocity.add(acceleration);

    if (velocity.mag() > maxSpeed) {
      velocity.setMag(maxSpeed);
    }

    location.add(velocity);

    if (location.x < 0) {
      location.x = arena.w + location.x;
    } else if (location.x > a.w) {
      location.x = location.x - arena.w;
    }

    if (location.y < 0) {
      location.y = arena.h + location.y;
    } else if (location.y > a.h) {
      location.y = location.y - arena.h;
    }

    hunger++;
    if (hunger >= maxHunger) {
      starved = true;
    }

  }

  void full() {
    hunger = 0;
    spawn = true;
  }

  void draw() {
    if (starved) {
      noFill();
    } else {
      fill(bodyColor, 255.0 * (maxHunger - hunger) / maxHunger);
    }
    stroke(255, 10); strokeWeight(1);
    ellipse(location.x, location.y, size, size);
  }
}

class Predator extends Bug {
  
  int NOM_BLIP_TICKS = 10;
  int nomBlip = 0;
  
  Predator(float maxSpeed, PVector location, int maxHunger, int spawnSize, int size) {
    super(maxSpeed, location, maxHunger, spawnSize, size, color(255,0,0)); //Predators are always RED
  }

  boolean willEat(Bug bug) {
    PVector distance = new PVector(bug.location.x, bug.location.y);
    distance.sub(location);

    if (distance.mag() < 0.5*(size+bug.size)) {
      nomBlip = NOM_BLIP_TICKS;
      return true;
    } else {
      return false;
    }
  }
  
  void spawn() {
    if(this.spawn) {
      if (random(100.0) < PREDATOR_SPAWN_CHANCE) { // Only spawns predators a fraction of the time.  Has the effect of predorator eating "many" bugs before spawning
        for (int j=0; j<this.spawnSize; j++) {
          PVector newLocation = new PVector(this.location.x, this.location.y);
          Predator newPred = new Predator(this.maxSpeed, newLocation, this.maxHunger, this.spawnSize, this.size); //inherit from the properties of the spawn-er
          newPred.velocity = new PVector(this.velocity.x, this.velocity.y);
          preds.add(newPred);
        }
      }
      this.spawn = false;
    }
  }
  
  void nomBlip() {
    if (nomBlip > 0) {
      fill(255); 
      textAlign(CENTER);
      text("nom!", location.x, location.y + 2*size);
      nomBlip--;
    }
  }
}

class Food {
  PVector location;
  int size;

  Food(PVector location, int size) {
    this.location = location;
    this.size = size;
  }

  boolean eat(PVector bugLocation, int bugSize) {
    PVector distance = new PVector(bugLocation.x, bugLocation.y);
    distance.sub(location);
    if (distance.mag() < 0.5*(size+bugSize)) {
      return true;
    } else {
      return false;
    }
  }

  void draw() {
    fill(#00CC00, 100); stroke(255, 100); strokeWeight(3);
    ellipse(location.x, location.y, size, size);
  }
}

void keyPressed() {
  switch(key) {
    case ' ':
      if (run) {
        run = false;
      } else {
        run = true;
      }
      break;
  }
}
