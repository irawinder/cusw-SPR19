/*  PATHFINDER AND NETWORK ALGORITHMS
 *  Ira Winder, ira@mit.edu
 *  Nina Lutz, nlutz@mit.edu
 *  Coded w/ Processing 3 (Java)
 *
 *  The Main Tab "Tutoiral_3A_Agents" shows an example implementation of 
 *  algorithms useful for finding shortest pathes snapped to a gridded or OSM-based 
 *  network. Explore the various tabs to see how they work.
 *
 *  CLASSES CONTAINED:
 *
 *    Pathfinder() - Method to calculate shortest path between to nodes in a graph/network
 *    Graph() - Network of nodes and wighted edges
 *    Node() - Fundamental building block of Graph()
 *    ObstacleCourse() - Contains multiple Obstacles; Allows editing, saving, and loading of configuration
 *    Obstacle() - 2D polygon that can detect overlap events
 *    MercatorMap() - translate lat-lon to screen coordinates
 *    
 *    Standard GIS shapes:
 *    POI() - i.e. points, representing points of interest, etc
 *    Way() - i.e. lines, representing streets, paths, etc
 *    Polygons() - representing buildings, parcels, etc
 *
 *  FUNDAMENTAL OUTPUT: 
 *
 *    ArrayList<PVector> shortestPath = Pathfinder.findPath(PVector A, PVector B, boolean enable)
 *
 *  CLASS DEPENDENCY TREE: 
 *
 *
 *     POI() / Way()  ->  Node()  ->      Graph()        ->      Pathfinder()  ->  OUTPUT: ArrayList<PVector> shortestPath
 *
 *                                            ^                                        |
 *                                            |                                        v
 *
 *     Polygon()  ->  Obstacle()  ->  ObstacleCourse()                             Agent()                                   
 *
 */

// Make a blank map 
MercatorMap map;
PImage background;

// Declare GIS-style Objects
ArrayList<POI> pois;
ArrayList<Way> ways; 
ArrayList<Polygon> polygons;

void setup() {
  size(900, 650);
  
  /* Intiailize your data structures early in setup */
  map = new MercatorMap(width, height, 42.36244, 42.35537, -71.10105, -71.08809, 0);
  polygons = new ArrayList<Polygon>();
  ways = new ArrayList<Way>();
  pois = new ArrayList<POI>();
  
  /* Load in and parse your data in setup -- don't want to do this every frame! */
  loadData();
  parseData();
  
  /* Step 1: Initialize Network Using ONLY ONE of these methods */
  //randomNetwork(0.5); // a number between 0.0 and 1.0 specifies how 'porous' the network is
  waysNetwork(ways);
  //randomNetworkMinusBuildings(0.1, polygons); // a number between 0.0 and 1.0 specifies how 'porous' the network is
  
  /* Step 2: Initialize Paths Using ONLY ONE of these methods */
  //randomPaths(50);
  poiPaths(50);
  
  /* Step 3: Initialize Paths Using ONLY ONE of these methods */
  //initPopulation(600);
  initPopulation(300);
  
}

void draw() {
  background(0);
  
  /* background image from OSM */
  //image(background, 0, 0);
  drawGISObjects();
  
  /*  Displays the Graph in grayscale */
  tint(255, 75); // overlaid as an image
  image(network.img, 0, 0);
  
  /*  Displays the path last calculated in Pathfinder.
   *  The results are overridden everytime findPath() is run.
   *  FORMAT: display(color, alpha)
   */
  //boolean showVisited = true;
  //finder.display(255, 200, showVisited);
  
  /*  Displays the path properties.
   *  FORMAT: display(color, alpha)
   */
  for (Path p: paths) {
    p.display(100, 155);
  }
  
  /*  Update and Display the population of agents
   *  FORMAT: display(color, alpha)
   */
  boolean collisionDetection = true;
  for (Agent p: people) {
    p.update(personLocations(people), collisionDetection);
    p.display(#FFFF00, 255);
  }
  
}

void keyPressed() {
  
  randomPaths(50);
  poiPaths(50);
  initPopulation(300);
  
}
