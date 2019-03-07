// Objects to define our Network
//
ObstacleCourse course;
Graph network;
Pathfinder finder;

//  Object to define and capture a specific origin, destiantion, and path
ArrayList<Path> paths;

//  Objects to define agents that navigate our environment
ArrayList<Agent> people;

void randomNetwork(float cull) {
  //  An example gridded network of width x height (pixels) and node resolution (pixels)
  //
  int nodeResolution = 10;  // pixels
  int graphWidth = width;   // pixels
  int graphHeight = height; // pixels
  network = new Graph(graphWidth, graphHeight, nodeResolution);
  network.cullRandom(cull); // Randomly eliminates a fraction of the nodes in the network (0.0 - 1.0)
}

void randomNetworkMinusBuildings(float cull, ArrayList<Polygon> poly) {
  //  An example gridded network of width x height (pixels) and node resolution (pixels)
  //
  int nodeResolution = 10;  // pixels
  int graphWidth = width;   // pixels
  int graphHeight = height; // pixels
  network = new Graph(graphWidth, graphHeight, nodeResolution);
  
  // An obstacle Course Based Upon Building Footprints
  //
  course = new ObstacleCourse();
  for (Polygon p: poly) {
    int numCorners = p.coordinates.size();
    PVector[] corners = new PVector[numCorners];
    for (int i=0; i<numCorners; i++) {
      PVector screenLocation = map.getScreenLocation(p.coordinates.get(i));
      corners[i] = new PVector(screenLocation.x, screenLocation.y);
    }
    Obstacle o = new Obstacle(corners);
    course.addObstacle(o);
  }
  
  // Subtract Building Footprints from Network
  //
  network.cullRandom(cull); // Randomly eliminates a fraction of the nodes in the network (0.0 - 1.0)
  network.applyObstacleCourse(course);
  
}

void waysNetwork(ArrayList<Way> w) {
  //  An example gridded network of width x height (pixels) and node resolution (pixels)
  //
  int nodeResolution = 10;  // pixels
  int graphWidth = width;   // pixels
  int graphHeight = height; // pixels
  network = new Graph(graphWidth, graphHeight, nodeResolution, w);
}

void randomPaths(int numPaths) {
  /*  An pathfinder object used to derive the shortest path. */
  finder = new Pathfinder(network);
  
  /*  Generate List of Shortest Paths through our network
   *  FORMAT 1: Path(float x, float y, float l, float w) <- defines 2 random points inside a rectangle
   *  FORMAT 2: Path(PVector o, PVector d) <- defined by two specific coordinates
   */
   
  paths = new ArrayList<Path>();
  for (int i=0; i<numPaths; i++) {
    //  An example Origin and Desination between which we want to know the shortest path
    //
    PVector orig = new PVector(random(1.0)*width, random(1.0)*height);
    PVector dest = new PVector(random(1.0)*width, random(1.0)*height);
    Path p = new Path(orig, dest);
    p.solve(finder);
    paths.add(p);
  }
  
}

void poiPaths(int numPaths) {
  /*  An pathfinder object used to derive the shortest path. */
  finder = new Pathfinder(network);
  
  /*  Generate List of Shortest Paths through our network
   *  FORMAT 1: Path(float x, float y, float l, float w) <- defines 2 random points inside a rectangle
   *  FORMAT 2: Path(PVector o, PVector d) <- defined by two specific coordinates
   */
   
  paths = new ArrayList<Path>();
  for (int i=0; i<numPaths; i++) {
    
    // Searches for valid paths only
    boolean notFound = true;
    while(notFound) {
      //  An example Origin and Desination between which we want to know the shortest path
      //
      // Origin is Random POI
      int orig_index = int(random(pois.size()));
      PVector orig = pois.get(orig_index).coord;
      orig = map.getScreenLocation(orig);
      
      // Destination is Random POI
      int dest_index = int(random(pois.size()));
      PVector dest = pois.get(dest_index).coord;
      dest = map.getScreenLocation(dest);
      
      Path p = new Path(orig, dest);
      p.solve(finder);
      
      if(p.waypoints.size() > 1) {
        notFound = false;
        paths.add(p);
      }
      
    }
    
  }
  
}

void initPopulation(int count) {
  /*  An example population that traverses along various paths
  *  FORMAT: Agent(x, y, radius, speed, path);
  */
  people = new ArrayList<Agent>();
  for (int i=0; i<count; i++) {
    int random_index = int(random(paths.size()));
    Path random_path = paths.get(random_index);
    if (random_path.waypoints.size() > 1) {
      int random_waypoint = int(random(random_path.waypoints.size()));
      float random_speed = random(0.1, 0.3);
      PVector loc = random_path.waypoints.get(random_waypoint);
      Agent person = new Agent(loc.x, loc.y, 5, random_speed, random_path.waypoints);
      people.add(person);
    }
  }
}

ArrayList<PVector> personLocations(ArrayList<Agent> people) {
  ArrayList<PVector> l = new ArrayList<PVector>();
  for (Agent a: people) {
    l.add(a.location);
  }
  return l;
}
