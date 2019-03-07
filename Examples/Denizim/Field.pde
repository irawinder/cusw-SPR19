/*  The Field class is a container to manage the 
 *  synthetic environment that containes Population 
 *  and Sensor classes, among others.
 */

class Field {
  // Bounding Box for Our Environment, Used to focus camera
  // Remember that (0,0) is in upper-left corner!
  PVector boundary;
  
  float BUFFER = 50; // feet
  float POPULATION = int(random(400, 600));
  
  // Objects for importing data files such as CSVs and Graphics
  PImage map;
  
  // Bounding Area(s) for Wandering Agents
  ArrayList<Fence> fences;
  int selectedFence = 0;
  boolean fenceEditing = false;
  
  // Block objects in our field
  ArrayList<Block> blocks;
  int selectedBlock = 0;
  boolean blockEditing = false;
  
  // Objects to define and capture specific origins, destiantions, and paths
  boolean showPaths = false;
  ArrayList<Path> paths;
  int selectedPath = 0;
  boolean pathEditing = false;
  
  // Network Objects
  ObstacleCourse course;
  Graph network;
  Pathfinder finder;
  
  void initEnvironment() {
    // Rectangular Building Forms
    //
    blocks = new ArrayList<Block>();
    //loadBlocks("0/millspark_buildings.tsv");
    loadBlocks("0/blockTable.tsv");
    
    // An obstacle Course Based Upon Building Footprints
    //
    course = new ObstacleCourse();
    Obstacle o;
    PVector[] corners = new PVector[4];
    for (Block bld: blocks) {
      corners[0] = new PVector(bld.loc.x - bld.l/2, bld.loc.y - bld.w/2);
      corners[1] = new PVector(bld.loc.x + bld.l/2, bld.loc.y - bld.w/2);
      corners[2] = new PVector(bld.loc.x + bld.l/2, bld.loc.y + bld.w/2);
      corners[3] = new PVector(bld.loc.x - bld.l/2, bld.loc.y + bld.w/2);
      o = new Obstacle(corners);
      course.addObstacle(o);
    }
    
    // A gridded network of width x height (pixels) and node resolution (pixels)
    //
    int nodeResolution = 10;  // pixels
    int graphWidth = int(boundary.x);   // pixels
    int graphHeight = int(boundary.y); // pixels
    network = new Graph(graphWidth, graphHeight, nodeResolution);
    network.cullRandom(0.0); // Randomly eliminates 10% of the nodes in the network
    network.applyObstacleCourse(course);
    
    // An example pathfinder object used to derive the shortest path
    // setting enableFinder to "false" will bypass the A* algorithm
    // and return a result akin to "as the bird flies"
    //
    finder = new Pathfinder(network);
    
    // Rectangular Geo-fences
    //
    fences = new ArrayList<Fence>();
    Fence fen;
    fen = new Fence(0, 0, boundary.x, boundary.y);
    fences.add(fen);
    fen = new Fence(0.5*boundary.x, 0.32*boundary.y, 0.25*boundary.x, 0.30*boundary.y);
    fences.add(fen);
    
    // Valid Pathways
    //
    paths = new ArrayList<Path>();
    Path p;
    PVector origin, destination;
    int side1, side2;
    for (int i=0; i<100; i++) {
      side1 = int(random(4));
      side2 = int(random(4));
      if (side1 == 0) {
        origin = new PVector(0 - 2*BUFFER, random(boundary.y));
      } else if (side1 == 1) {
        origin = new PVector(boundary.x + 2*BUFFER, random(boundary.y));
      } else if (side1 == 2) {
        origin = new PVector(random(boundary.x), 0 - 2*BUFFER);
      } else {
        origin = new PVector(random(boundary.x), boundary.y + 2*BUFFER);
      }
      if (side2 == 0) {
        destination = new PVector(0 - 2*BUFFER, random(boundary.y));
      } else if (side2 == 1) {
        destination = new PVector(boundary.x + 2*BUFFER, random(boundary.y));
      } else if (side2 == 2) {
        destination = new PVector(random(boundary.x), 0 - 2*BUFFER);
      } else {
        destination = new PVector(random(boundary.x), boundary.y + 2*BUFFER);
      }
      p = new Path(origin, destination);
      p.solve(finder);
      paths.add(p);
    }
    
  }
  
  // Sensor objects in our field
  ArrayList<Sensor> beacons;
  int selectedSensor = 0;
  boolean sensorEditing = false;
  
  // Person objects in our field
  ArrayList<Person> people;
  
  Field(float l, float w, float h, PImage img) {
    boundary = new PVector(l, w, h);
    
    initEnvironment();
    
    people = new ArrayList<Person>();
    randomizePeople();
    
    beacons = new ArrayList<Sensor>(); 
    randomBeacons(3);
    
    map = img;
  }
  
  void randomBeacons(int num) {
    beacons.clear(); 
    Sensor s;
    for (int i=0; i<num; i++) {
      s = new Sensor();
      s.randomize(0.22*boundary.x, 0.27*boundary.y, 0.58*boundary.x, 0.43*boundary.y, s.DIAM/2, s.DIAM/2);
      beacons.add(s);
    }
  }
  
  void randomizeBlocks() {
    for(Block b: blocks) {
      b.randomize(boundary.x, boundary.y, 50, 100);
    }
  }
  
  void randomizePeople() {
    people.clear();
    
    Person p;
    Fence fen = fences.get(1);
     //  Add Random Pathfinders
    //
    PVector loc;
    int random_waypoint;
    float random_speed;
    Path random;
    for (int i=0; i<POPULATION; i++) {
      random = paths.get( int(random(paths.size())) );
      while (random.waypoints.size() <= 1) {
        random = paths.get( int(random(paths.size())) );
      }
      if (random.waypoints.size() > 1) {
        random_waypoint = int(random(random.waypoints.size()));
        random_speed = random(0.1, 0.3);
        loc = random.waypoints.get(random_waypoint);
        p = new Person(loc.x, loc.y, random_speed, random.waypoints);
        p.randomize(fen.x, fen.y, fen.l, fen.w);
        // sets sensor counter randomly
        if (random(1.0) < 0.1) {
          if (freezeVisitCounter) {
            p.numDetects = 2;
          } else {
            p.numDetects = 1;
          }
        }
        if (i>0.95*POPULATION) p.pathFinding = false;
        people.add(p);
      }
    }
  }
  
  void nextBlock() {
    if (selectedBlock == blocks.size() - 1) {
      selectedBlock = 0;
    } else {
      selectedBlock++;
    }
  }
  
  void lastBlock() {
    if (selectedBlock == 0) {
      selectedBlock = blocks.size() - 1;
    } else {
      selectedBlock--;
    }
  }
  
  void removeBlock() {
    if (blocks.size() > 0) {
      blocks.remove(selectedBlock);
      if (selectedBlock > 0) {
        selectedBlock--;
      }
    }
  }
  
  void saveBlocks() {
    // Data file for saving/loading building objects
    Table blockTable = new Table();
    blockTable.addColumn();
    blockTable.addColumn();
    blockTable.addColumn();
    blockTable.addColumn();
    blockTable.addColumn();
    TableRow row;
    for (Block b: blocks) {
      row = blockTable.addRow();
      row.setFloat(0, b.loc.x);
      row.setFloat(1, b.loc.y);
      row.setFloat(2, b.l);
      row.setFloat(3, b.w);
      row.setFloat(4, b.h);
    }
    saveTable(blockTable, "data/" + cityIndex + "/blockTable.tsv");
    println(blocks.size() + " blocks saved.");
  }
  
  void loadBlocks(String name) {
    // Data file for saving/loading building objects
    Table blockTable = loadTable("data/" + name);
    
    blocks.clear();
    float x, y, l, w, h;
    Block b;
    for (int i=0; i<blockTable.getRowCount(); i++) {
      x = blockTable.getFloat(i, 0);
      y = blockTable.getFloat(i, 1);
      l = blockTable.getFloat(i, 2);
      w = blockTable.getFloat(i, 3);
      h = blockTable.getFloat(i, 4);
      b = new Block(x, y, l, w, h);
      blocks.add(b);
    }
    selectedBlock = 0;
    println(blockTable.getRowCount() + " blocks loaded.");
  }
  
  void render() {
    
    //// Draw Bounding Box
    //if (showPaths) {
    //  stroke(lnColor, 0.5*baseAlpha*uiFade);
    //  noFill();
    //  pushMatrix();
    //  translate(0.5*boundary.x, 0.5*boundary.y, 0.5*boundary.z);
    //  box(boundary.x, boundary.y, boundary.z);
    //  popMatrix();
    //}
    
    // Draw Ground
    pushMatrix();
    translate(0, 0, -1);
    if (map == null || !drawMap) {
      
      // Draw Ground Map
      //tint(255, 150);
      //image(map, 0, 0, boundary.x, boundary.y);
      //tint(255, 255);
      
      // Draw a Rectangle
      fill(50, 255 - baseAlpha);
      noStroke();
      rect(0, 0, boundary.x, boundary.y);
    } else {
      // Draw Ground Map
      tint(255, 225);
      image(map, 0, 0, boundary.x, boundary.y);
      tint(255, 255);
    }
    popMatrix();
    
    if (inverted) {
      lights();
    }
    
    // Draw Beacons
    for(Sensor s: beacons) {
      pushMatrix();
      translate(s.loc.x, s.loc.y, -5);
      noStroke();
      fill(s.col);
      sphere(s.DIAM);
      popMatrix();
    }
    
    // Draw People
    for(Person p: people) {
      // Only Draw People Within Bounds
      Fence fen = fences.get(0);
      if (p.loc.x > fen.x - BUFFER && p.loc.x < fen.x + fen.l + BUFFER &&
          p.loc.y > fen.y - BUFFER && p.loc.y < fen.y + fen.w + BUFFER ) {
            
        pushMatrix();
        translate(p.loc.x, p.loc.y, p.h/2);
        
        // Determine Color
        float scale;
        color col;
        float vis;
        if (p.detected) {
          //col = p.col;
          vis = min(1, p.numDetects-1) / 1.0;
          col = color(150 - 50*vis, 255, 255);
          scale = 1.0;
        } else {
          col = color(255, 2*baseAlpha);
          scale = 1.0;
        }
        
        // Determine Fade
        float fadeX, fadeY, fadeVal;
        
        Fence fen2;
        if (p.pathFinding) {
          fen2 = fences.get(0);
        } else {
          fen2 = fences.get(1);
        }
        fadeX = abs(p.loc.x - fen2.x - fen2.l/2) - fen2.l/2;
        fadeY = abs(p.loc.y - fen2.y - fen2.w/2) - fen2.w/2;
        fadeVal = 1 - max(fadeX, fadeY) / BUFFER;
        
        // Apply Fade, Color, and Draw Person
        noStroke();
        if (fadeVal > 0) {
          fill(col, fadeVal*255);
        } else {
          fill(col);
        }
        //if (!p.pathFinding) fill(#FF0000);
        box(scale*p.l, scale*p.w, scale*p.h);
        
        popMatrix();
      }
    }
    
    // Draw Buildings and Streets
    for(int i=0; i<blocks.size(); i++) {
      Block b = blocks.get(i);
      pushMatrix();
      translate(b.loc.x, b.loc.y, b.h/2);
      if (b.h > 0) {
        noStroke();
        if (i == selectedBlock && blockEditing) {
          fill(#FFFF00, 2*baseAlpha);
        } else {
          fill(b.col, 2*baseAlpha);
        }
      } else {
        noFill();
        if (i == selectedBlock && blockEditing) {
          stroke(#FFFF00, 2*baseAlpha);
        } else {
          stroke(b.col, 2*baseAlpha);
        }
      }
      if (blockEditing || b.h > 0 ) {
        box(b.l, b.w, b.h);
      }
      fill(255);
      noStroke();
      popMatrix();
    }
    
    if (showPaths) {
      // Draw Graph
      tint(255, 50);
      image(network.img, 0, 0);
      tint(255, 255);
      
      // Draw Path
      Path path;
      for (int i=0; i<paths.size(); i++) {
        path = paths.get(i);
        path.display(100, 25);
      }
    }
    
    float beaconFade = sq(1 - float(frameCounter) / PING_FREQ);
    
    // Draw Beacon Min Range
    hint(DISABLE_DEPTH_TEST);
    for(Sensor s: beacons) {
      pushMatrix();
      translate(s.loc.x, s.loc.y, -5);
      noStroke();
      if (beaconFade > 0.1) {
        //fill(lnColor, beaconFade*baseAlpha);
        //sphere(2*s.MIN_RANGE*(1-beaconFade));
        noFill();
        stroke(255, beaconFade*baseAlpha);
        strokeWeight(2);
        ellipse(0, 0, 2*s.MIN_RANGE, 2*s.MIN_RANGE);
        strokeWeight(1);
      }
      popMatrix();
    }
    
    // Draw Beacon Max Range
    if (beaconFade > 0.1) {
      for(Sensor s: beacons) {
        pushMatrix();
        translate(s.loc.x, s.loc.y, 0);
        //noStroke();
        //fill(lnColor, beaconFade*0.5*baseAlpha);
        stroke(255, beaconFade*baseAlpha);
        ellipse(0, 0, 2*(s.MAX_RANGE-s.MIN_RANGE)*(1-beaconFade) + 2*s.MIN_RANGE, 2*(s.MAX_RANGE-s.MIN_RANGE)*(1-beaconFade) + 2*s.MIN_RANGE);
        popMatrix();
      }
      hint(ENABLE_DEPTH_TEST);
    }
    
    // Draw Cursor
    if (!mousePressed) {
      pushMatrix();
      float fieldX = boundary.x*(mouseX - 0.25*width)/(0.5*width); 
      float fieldY = boundary.y*(mouseY - 0.15*height)/(0.7*height);
      fieldX = constrain(fieldX, 0, boundary.x);
      fieldY = constrain(fieldY, 0, boundary.y);
      translate(fieldX, fieldY, 10);
      fill(255);
      noStroke();
      sphere(5);
      popMatrix();
    }
    
  }
}

class Person extends Agent {
  PVector loc, vel, acc;
  float l, w, h; // length, width, and height
  float MAX_SPEED = 15.0; // pixels per second
  color col;
  boolean detected = false;
  int numDetects;
  
  boolean pathFinding = true;
  
  Person(float x, float y, float max_speed, ArrayList<PVector> waypoints) {
    super(x, y, 5, max_speed, waypoints);
    loc = new PVector(0, 0);
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    l = 2;
    w = 2;
    h = 6;
    MAX_SPEED /= 60.0; // convert from seconds to frames
    col = color(255);
    
    if (freezeVisitCounter) {
      numDetects = 1;
    } else {
      numDetects = 0;
    }
  }
  
  void randomize(float x, float y, float l, float w) {
    loc.x = random(x, x+l);
    loc.y = random(y, y+w);
    col = color(random(50, 100), 255, 255, 200);
  }
  
  void update(Field f) {
    
    //  Default Wandering Behavior
    //
    if (!pathFinding) {
      //  Accelerate in Random Direction
      //
      acc.x += random(-1, 1);
      acc.y += random(-1, 1);
      vel.add(acc);
      if (vel.mag() > MAX_SPEED) vel.setMag(MAX_SPEED);
      loc.add(vel);
      
      //  Agents that wander off of their border teleport to opposite border
      //
      Fence fen = f.fences.get(1);
      if (loc.x < fen.x - f.BUFFER) 
        loc.x = fen.x + fen.l + f.BUFFER;
      if (loc.x > fen.x + fen.l + f.BUFFER) 
        loc.x = fen.x - f.BUFFER;
      if (loc.y < fen.y - f.BUFFER) 
        loc.y = fen.y + fen.w + f.BUFFER;
      if (loc.y > fen.y + fen.w + f.BUFFER) 
        loc.y = fen.y - f.BUFFER;  
    } else {
      loc.x = location.x;
      loc.y = location.y;
    }
  }
}

ArrayList<PVector> personLocations(ArrayList<Person> people) {
  ArrayList<PVector> l = new ArrayList<PVector>();
  for (Person p: people) {
    l.add(p.location);
  }
  return l;
}

class Sensor {
  PVector loc;
  float l, w, h; // length, width, and height
  color col;
  int DIAM = 10;
  float MIN_RANGE = 0.5*75;  // ft
  float MAX_RANGE = 0.5*450; // ft
  
  Sensor() {
    loc = new PVector(0, 0);
    l = DIAM;
    w = DIAM;
    h = DIAM;
    col = soofaColor;
  }
  
  Sensor(float x, float y) {
    loc = new PVector(x, y);
    l = DIAM;
    w = DIAM;
    h = DIAM;
    col = soofaColor;
  }
  
  void randomize(float x_max, float y_max, float l_max, float w_max, float d_min, float d_max) {
    loc.x = random(x_max + d_max/2, x_max + l_max - d_max/2);
    loc.y = random(y_max + d_max/2, y_max + w_max - d_max/2);
    //col = color(random(100, 200), 255, 255);
  }
  
  void randomize(float x_max, float y_max, float d_min, float d_max) {
    loc.x = random(d_max/2, x_max - d_max/2);
    loc.y = random(d_max/2, y_max - d_max/2);
    //col = color(random(100, 200), 255, 255);
  }
  
  // Determines if a nearby person is being detected by sensor
  boolean detect(PVector pos, boolean currentlyReading) {
    PVector d = new PVector(pos.x-loc.x, pos.y-loc.y);
    float distance = d.mag();
    boolean detect = false;
    if (distance > MAX_RANGE) {
      detect = false;
    } else if (currentlyReading) {
      detect = true;
    } else if (distance <= MIN_RANGE) {
      detect = true;
    } else if (distance <= MAX_RANGE && distance > MIN_RANGE) {
      float probability =  pow(1.0 - (distance - MIN_RANGE) / (MAX_RANGE - MIN_RANGE), 3);
      if (random(1.0) < probability) {
        detect = true;
      } else {
        detect = false;
      }
    }
    return detect;
  }
}

class Block {
  PVector loc;
  float l, w, h; // length, width, and height
  color col;
  
  Block() {
    loc = new PVector(0, 0);
    l = 0;
    w = 0;
    h = 0;
    col = color(255);
  }
  
  Block(float x, float y, float l, float w, float h) {
    loc = new PVector(x, y);
    this.l = l;
    this.w = w;
    this.h = h;
    col = color(255);
  }
  
  void randomize(float x_max, float y_max, float d_min, float d_max) {
    l = random(d_min, d_max);
    w = random(d_min, d_max);
    h = 2*d_max*sq(random(0.1, 1.1));
    loc.x = random(d_max/2, x_max - d_max/2);
    loc.y = random(d_max/2, y_max - d_max/2);
    col = color(random(100, 200), 255, 255);
  }
}

// Specifies a boundary condition for People Agents
class Fence {
  float x, y, l, w;
  
  Fence(float x, float y, float l, float w) {
    this.x = x;
    this.y = y;
    this.l = l;
    this.w = w;
  }
}
