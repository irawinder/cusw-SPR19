/*  DRIVING FUTURES
 *  Ira Winder, ira@mit.edu, 2018
 *
 *  Init Functions (Superficially Isolated from Main.pde)
 *
 *  MIT LICENSE:  Copyright 2018 Ira Winder
 *
 *               Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
 *               and associated documentation files (the "Software"), to deal in the Software without restriction, 
 *               including without limitation the rights to use, copy, modify, merge, publish, distribute, 
 *               sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
 *               furnished to do so, subject to the following conditions:
 *
 *               The above copyright notice and this permission notice shall be included in all copies or 
 *               substantial portions of the Software.
 *
 *               THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT 
 *               NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
 *               NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
 *               DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
 *               OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import java.io.File;
import java.io.FileNotFoundException;

//  GeoLocation Parameters:
float latCtr, lonCtr, bound, latMin, latMax, lonMin, lonMax;

//  Object to Define Systems Model
Parking_System sys;
//  Object to define parking facilities:
Parking_Structures structures;
// Object to define and capture paths to collection of origins, destinations:
Parking_Routes routes;

// Object for initializing road network and paths
Graph network;

//  Objects to define agents that navigate our environment:
ArrayList<Agent> type1; // Private non-AV
ArrayList<Agent> type2; // Shared  non-AV
ArrayList<Agent> type3; // Private AV
ArrayList<Agent> type4; // Shared  AV

// Camera Object with built-in GUI for navigation and selection
//
Camera cam;
PVector B = new PVector(6000, 6000, 0); // Bounding Box for 3D Environment
int MARGIN = 25; // Pixel margin allowed around edge of screen

// Semi-transparent Toolbar for information and sliders
//
Toolbar bar_left, bar_right; 
int BAR_X, BAR_Y, BAR_W, BAR_H;

// Index of Entity one is currently hovering over
int hoverIndex = 0; String hoverType = "";

// Counter to track which phase of initialization
int initPhase = 0;
int phaseDelay = 0;
String status[] = {
  "Loading Background ...",
  "Loading Toolbars ...",
  "Importing Road Network ...",
  "Importing Parking Infrastructure ...",
  "Finding Shortest Paths ...",
  "Setting Up 3D Environment ...",
  "Calibrating Systems Model ...",
  "Populating Vehicles ...",
  "Finishing Up ...",
  "Ready to go!"
};
int NUM_PHASES = status.length;

// Fonts
PFont font12, font60;

void initialize() {
  
  if (initPhase == 0) {
    font12 = createFont("Helvetica", 12);
    font60 = createFont("Helvetica", 60);
    textFont(font12);
    loadingBG = loadImage("loading.png");
    
  } else if (initPhase == 1) {
    
    //  Parameter Space for Geometric Area
    //
    latCtr = +42.350;
    lonCtr = -71.066;
    bound    =  0.035;
    latMin = latCtr - bound;
    latMax = latCtr + bound;
    lonMin = lonCtr - bound;
    lonMax = lonCtr + bound;
    
  } else if (initPhase == 2) {
    
    // Initialize Toolbar
    //
    BAR_X = MARGIN;
    BAR_Y = MARGIN;
    BAR_W = 250;
    BAR_H = 800 - 2*MARGIN;
    
    // Initialize Left Toolbar
    bar_left = new Toolbar(BAR_X, BAR_Y, BAR_W, BAR_H, MARGIN);
    bar_left.title = "Driving Futures V1.1\n";
    //bar_left.credit = "I. Winder, D. Vasquez, K. Kusina,\nA. Starr, K. Silvester, JF Finn";
    bar_left.credit = "";
    bar_left.explanation = "Explore a hypothetical future of shared and autonomous vehicles.\n\n";
    bar_left.explanation += "Press ' r ' to reset sliders\n";
    bar_left.explanation += "Press ' a ' to autoplay";
    //bar_left.explanation += "[f] <- Press 'f' to show framerate";
    bar_left.controlY = BAR_Y + bar_left.margin + 4*bar_left.CONTROL_H;
    bar_left.addSlider("Year of Analysis",               "",  2010, 2030, 2017, 1, 'q', 'w', false);
    bar_left.addSlider("Annual Vehicle Trip Growth",    "%", -2,       8,    3, 1, 'Q', 'W', false);
    bar_left.addSlider("RideShare: Trip Equilibrium",   "%",  0,     100,   60, 1, 'a', 's', false);
    bar_left.addSlider("RideShare: Peak Adoption Year",  "",  2010, 2030, 2018, 1, 'A', 'S', false);
    bar_left.addSlider("AV: Trip Equilibrium",          "%",     0,  100,   90, 1, 'z', 'x', false);
    bar_left.addSlider("AV: Peak Adoption Year",         "",  2010, 2030, 2024, 1, 'Z', 'X', false);
    bar_left.addTriSlider("Redevelop\nPriority",        "Below\nGround", belowColor, 
                                                        "Surface\nParking", surfaceColor, 
                                                        "Above\nGround", aboveColor);
    bar_left.addRadio("BLANK", 0, true, ' ', true); // Spacer for Parking and Vehicle Button Lables
    bar_left.addRadio("Below",               belowColor,    true, '1', true);
    bar_left.addRadio("Surface",             surfaceColor,  true, '2', true);
    bar_left.addRadio("Above",               aboveColor,    true, '3', true);
    bar_left.addRadio("RSVD",                reservedColor, true, '4', true);
    bar_left.addRadio("Private",             car1Color,     true, '5', true);
    bar_left.addRadio("Shared",              car2Color,     true, '6', true);
    bar_left.addRadio("AV Private",          car3Color,     true, '7', true);
    bar_left.addRadio("AV Shared",           car4Color,     true, '8', true);
    bar_left.radios.remove(0); // Remove blanks
    for (int i=0; i<4; i++) {   // Shift last 4 radios right
      bar_left.radios.get(i+4).xpos = bar_left.barX + bar_left.barW/2; 
      bar_left.radios.get(i+4).ypos = bar_left.radios.get(i).ypos;
    }
    
    // Initialize Right Toolbar
    bar_right = new Toolbar(width - (BAR_X + BAR_W), BAR_Y, BAR_W, BAR_H, MARGIN);
    bar_right.title = "[Analysis] System Projections";
    bar_right.credit = "";
    bar_right.explanation = "";
    bar_right.controlY = BAR_Y + bar_right.margin + bar_left.CONTROL_H;
    
  } else if (initPhase == 3) {
    
    initRoads();
    
  } else if (initPhase == 4) {
    
    initParking();
    
  } else if (initPhase == 5) {
    
    initPaths();
    
  } else if (initPhase == 6) {
    
    // Initialize 3D World Camera Defaults
    //
    cam = new Camera (B, MARGIN);
    cam.X_DEFAULT    = -350;
    cam.Y_DEFAULT     =  50;
    cam.ZOOM_DEFAULT = 0.30;
    cam.ZOOM_POW     = 1.75;
    cam.ZOOM_MAX     = 0.10;
    cam.ZOOM_MIN     = 0.40;
    cam.ROTATION_DEFAULT = PI; // (0 - 2*PI)
    cam.enableChunks = false;  // Enable/Disable 3D mouse cursor field for continuous object placement
    cam.init(); // Must End with init() if any BASIC variables within Camera() are changed from default 
    
    // Add non-camera UI blockers and edit camera UI characteristics AFTER cam.init()
    //
    cam.vs.xpos = width - 3*MARGIN - BAR_W;
    //cam.hs.enable = false; //disable rotation
    cam.drag.addBlocker(MARGIN, MARGIN, BAR_W, BAR_H);
    cam.drag.addBlocker(width - MARGIN - BAR_W, MARGIN, BAR_W, BAR_H);
    
    // Turn cam off while still initializing
    //
    cam.off();
  
  } else if (initPhase == 7) {
    
    // Setup System Simulation
    sys = new Parking_System(1001, 2010, 2030);
    sys.av_growth = 1.0;
    sys.rideShare_growth = 1.0;
    sys.totBelow = structures.totBelow     / 100;
    sys.totSurface = structures.totSurface / 100;
    sys.totAbove = structures.totAbove     / 100;
    syncSliders();
    sys.update();
    syncParking();
  
  } else if (initPhase == 8) {
    
    // Initialize Vehicle Agents
    initVehicles();  
  
  } else if (initPhase == 9) {
    
    initialized = true;
    
  }
  
  loadScreen(loadingBG, initPhase, NUM_PHASES, status[initPhase]);
  if (!initialized) initPhase++; 
  delay(phaseDelay);
}

void initRoads() {

  // Check for existance of JSON file
  //
  String fileName = "local/boston_OSM.json";
  File graphJSON = new File(dataPath(fileName));
  boolean loadFile;
  if(graphJSON.exists()) { 
    loadFile = true;
  } else {
    loadFile = false;
    println("The specified file '" + fileName + "' is not present. Creating new one ... ");
  }
  
  // loadFile = false; // override! Turns out this doesn't really save much computational speed anyway ...
  
  // Graph pixel dimensions
  //
  int graphWidth  = int(B.x); // pixels
  int graphHeight = int(B.y); // pixels
    
  if (loadFile) {
    
    //  A Road Network Created from a JSON File compatible with Graph.loadJSON()
    //
    boolean drawNodes = false;
    boolean drawEdges = true;
    network = new Graph(graphWidth, graphHeight, fileName, drawNodes, drawEdges);
    
  } else {
    
    //  A Road Network Created from a QGIS OSM File
    //
    // Use this function rarely when you need to clean a csv file. It saves a new file to the data folder
    //rNetwork = new RoadNetwork("data/roads.csv", latMin, latMax, lonMin, lonMax);
    //
    RoadNetwork rNetwork = new RoadNetwork("data/roads.csv");
    
    //  An example gridded network of width x height (pixels) and node resolution (pixels)
    //
    int nodeResolution = 5;     // pixels
    network = new Graph(graphWidth, graphHeight, latMin, latMax, lonMin, lonMax, nodeResolution, rNetwork);
    
    // Save network to JSON file
    //
    network.saveJSON(fileName);
  }
}

void initParking() {
  
  //  Init A list of parking structures
  //
  structures = new Parking_Structures(latMin, latMax, lonMin, lonMax);
  Table parkingCSV = loadTable("data/parking.csv", "header");
  
  for (int i=0; i<parkingCSV.getRowCount(); i++) {
    float x = parkingCSV.getFloat(i, "X");
    float y = parkingCSV.getFloat(i, "Y");
    float canvasX  = B.x * (x - lonMin) / abs(lonMax - lonMin);
    float canvasY  = B.y - B.y * (y - latMin) / abs(latMax - latMin);
    float area = parkingCSV.getFloat(i, "SHAPE_area");
    String type = parkingCSV.getString(i, "20171127_Parking");
    int capacity = parkingCSV.getInt(i, "20171127_Gensler Revised Parking Spots");
    Parking park = new Parking(canvasX, canvasY, area, type, capacity);
    park.respondent = parkingCSV.getString(i, "20171127_Respondent (First+ Last)");
    park.address    = parkingCSV.getString(i, "MAL");
    park.name       = parkingCSV.getString(i, "Proj_nam");
    park.devName    = parkingCSV.getString(i, "DevName");
    park.devAddy    = parkingCSV.getString(i, "DevAddy");
    park.parkMethod = parkingCSV.getString(i, "Park_type");
    park.userGroup  = parkingCSV.getString(i, "User_Group");
    
    String sub = ""; if (park.type.length() >= 3) sub = park.type.substring(0,3);
    if (sub.equals("Bel")) {
      park.col = belowColor;
      structures.totBelow += park.capacity;
    } else if (sub.equals("Sur")) {
      park.col = surfaceColor;
      structures.totSurface += park.capacity;
    } else if (sub.equals("Sta") || sub.equals("Abo")) {
      park.col = aboveColor;
      structures.totAbove += park.capacity;
    } else {
      park.col = reservedColor;
    } 
    
    //if (capacity > 0) structures.parking.add(park);
    structures.parking.add(park);
  }
}

void initPaths() {
  
  // Check for existance of JSON file
  //
  String fileName = "local/routes.json";
  File routesJSON = new File(dataPath(fileName));
  boolean loadFile;
  if(routesJSON.exists()) { 
    loadFile = true;
  } else {
    loadFile = false;
    println("The specified file '" + fileName + "' is not present. Creating new one ... ");
  }
  
  //loadFile = false;
  
  // Collection of routes to and from home, work, and parking ammentities
  if (loadFile) {
    
    // generate from file
    //
    routes = new Parking_Routes(fileName);
    
  } else {
    
    // generate randomly according to parking structures
    //
    routes = new Parking_Routes();
    Path path, pathReturn;
    PVector origin, destination;
    
    boolean debug = false;
    
    //  An example pathfinder object used to derive the shortest path
    //  setting enableFinder to "false" will bypass the A* algorithm
    //  and return a result akin to "as the bird flies"
    //
    Pathfinder finder = new Pathfinder(network);
    
    if (debug) {
      
      for (int i=0; i<5; i++) {
        //  An example Origin and Desination between which we want to know the shortest path
        //
        int rand1 = int( random(network.nodes.size()));
        int rand2 = int( random(structures.parking.size()));
        boolean closedLoop = true;
        origin      = network.nodes.get(rand1).loc;
        destination = structures.parking.get(rand2).location;
        path = new Path(origin, destination);
        path.solve(finder);
        
        if (path.waypoints.size() <= 1) { // Prevents erroneous origin point from being added when only return path found
          path.waypoints.clear();
        }
        pathReturn = new Path(destination, origin); 
        pathReturn.solve(finder);
        path.joinPath(pathReturn, closedLoop);
        
        routes.paths.add(path);
      }
      
    } else {
  
      for (Parking p: structures.parking) {
        //  An example Origin and Desination between which we want to know the shortest path
        //
        int rand1 = int( random(network.nodes.size()));
        boolean closedLoop = true;
        origin      = network.nodes.get(rand1).loc;
        destination = p.location;
        path = new Path(origin, destination);
        path.solve(finder);
        if (path.waypoints.size() <= 1) { // Prevents erroneous origin point from being added when only return path found
          path.waypoints.clear();
        }
        pathReturn = new Path(destination, origin); 
        pathReturn.solve(finder);
        path.joinPath(pathReturn, closedLoop);
        routes.paths.add(path);
      }
      
    }
    routes.saveJSON(fileName);
  }
  routes.render(int(B.x), int(B.y));
}

void initVehicles() {
  int yr = sys.year_now - sys.year_0;
  
  type1 = new ArrayList<Agent>();
  type2 = new ArrayList<Agent>();
  type3 = new ArrayList<Agent>();
  type4 = new ArrayList<Agent>();
  
  for (int i=0; i<sys.numCar1[yr]; i++) addVehicle(type1, "1");
  for (int i=0; i<sys.numCar2[yr]; i++) addVehicle(type2, "2");
  for (int i=0; i<sys.numCar3[yr]; i++) addVehicle(type3, "3");
  for (int i=0; i<sys.numCar4[yr]; i++) addVehicle(type4, "4");
}

void addVehicle(ArrayList<Agent> array, String type) {
  //  An example population that traverses along shortest path calculation
  //  FORMAT: Agent(x, y, radius, speed, path);
  //
  Agent vehicle;
  PVector loc;
  int random_waypoint;
  float random_speed;
  
  Path random;
  boolean loop = true;
  boolean teleport = true;
  
  random = routes.paths.get( int(random(routes.paths.size())) );
  int wpts = random.waypoints.size();
  while (wpts < 2) {
    random = routes.paths.get( int(random(routes.paths.size())) );
    wpts = random.waypoints.size();
  }
  random_waypoint = int(random(random.waypoints.size()));
  random_speed = 3.0*random(0.3, 0.4);
  loc = random.waypoints.get(random_waypoint);
  vehicle = new Agent(loc.x, loc.y, 2, random_speed, random.waypoints, loop, teleport, "RIGHT", type);
  
  // Designame vehicle passengers
  if (vehicle.type.equals("1")) {
    vehicle.passengers = int( random(0, 1.99) ); 
    vehicle.driver = true;
  }
  if (vehicle.type.equals("2")) {
    vehicle.passengers = int( random(1, 3.99) ); 
    vehicle.driver = true;
  }
  if (vehicle.type.equals("3")) {
    vehicle.passengers = int( random(1, 2.5) ); 
    vehicle.driver = false;
  }
  if (vehicle.type.equals("4")) {
    vehicle.passengers = int( random(2, 4.99) );
    vehicle.driver = false;
  }
  array.add(vehicle);
}
