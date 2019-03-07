// Nodes are the fundamental building block of our graph
//
class Node {
  PVector loc;
  int ID;
  int gridX, gridY; 
  
  // Variables to describe relationship to adjacent neighbors
  //
  ArrayList<Integer> adj_ID;
  ArrayList<Float> adj_Dist;
  
  Node (float x, float y, float scale) {
    ID = 0;
    
    loc = new PVector(x,y);
    // Neighbor ID in ArrayList<Node>
    adj_ID = new ArrayList<Integer>();
    // Distance to Respective Neighbor in ArrayList<Node>
    adj_Dist = new ArrayList<Float>();
    
    // Variable to describe local grid location for fast computation
    gridX = int(x/scale);
    gridY = int(y/scale);
  }
  
  void addNeighbor(int n, float d) {
    adj_ID.add(n);
    adj_Dist.add(d);
  }
  
  void clearNeighbors() {
    adj_ID.clear();
    adj_Dist.clear();
  }
}

// A network of nodes and edges
//
class Graph {
  
  ArrayList<Node> nodes;
  int U, V;
  float SCALE;
  PGraphics img; // Graph is drawn once into memory
  
  // Using the canvas width and height in pixels, a gridded graph 
  // is generated with a pixel spacing of 'scale'
  //
  Graph (int w, int h, float scale) {
    U = int(w/scale);
    V = int(h/scale);
    SCALE = scale;
    img = createGraphics(w, h);
    
    nodes = new ArrayList<Node>();
    for (int i=0; i<U; i++) {
      for (int j=0; j<V; j++) {
        nodes.add(new Node(i*SCALE + scale/2, j*SCALE + scale/2, scale));
      }
    }
    generateEdges();
  }
  
  // Using the canvas width and height in pixels, a graph 
  // is generated using an OSM-standard roadfile CSV/Table 
  //
  Graph(int w, int h, float scale, ArrayList<Way> ways) {
    SCALE = scale;
    U = int(w / SCALE);
    V = int(h / SCALE);
    img = createGraphics(w, h);
    nodes = new ArrayList<Node>();
    
    int numWays = ways.size();
    for (int i=0; i<numWays; i++) {
      int numNodes = ways.get(i).coordinates.size();
      for (int j=0; j<numNodes; j++) {
        
        float x = ways.get(i).coordinates.get(j).x;
        float y = ways.get(i).coordinates.get(j).y;
        PVector coord = new PVector(x, y);
        PVector screenLocation = map.getScreenLocation(coord);
        Node n = new Node(screenLocation.x, screenLocation.y, scale);
        n.ID = i;
        n.clearNeighbors();
        nodes.add(n);
      }
    }
    
    // Connect per Object ID
    int objectID, lastID = -1;
    float dist;

    for (int i=0; i<nodes.size(); i++) {
      
      if (i != 0) lastID   = nodes.get(i-1).ID;
      objectID = nodes.get(i).ID;
      if (lastID == objectID) {
        dist = sqrt(sq(nodes.get(i).loc.x - nodes.get(i-1).loc.x) + sq(nodes.get(i).loc.y - nodes.get(i-1).loc.y));
        nodes.get(i).addNeighbor(i-1, dist);
      }
    }
    
    // Add and Connect Intersecting Segments
    ArrayList<Node>[][] bucket = new ArrayList[U][V];
    for (int u=0; u<U; u++) {
      for (int v=0; v<V; v++) {
        bucket[u][v] = new ArrayList<Node>();
      }
    }
    int u, v;
    for (int i=0; i<nodes.size(); i++) {
      nodes.get(i).ID = i;
      u = min(U-1, nodes.get(i).gridX);
      u = max(0,   u);
      v = min(V-1, nodes.get(i).gridY);
      v = max(0,   v);
      bucket[u][v].add(nodes.get(i));
    }
    for (int i=0; i<nodes.size(); i++) {
      u = min(U-1, nodes.get(i).gridX);
      u = max(0,   u);
      v = min(V-1, nodes.get(i).gridY);
      v = max(0,   v);
      ArrayList<Node> nearby = bucket[u][v];
      for (int j=0; j<nearby.size(); j++) {
        dist = abs(nodes.get(i).loc.x - nearby.get(j).loc.x) + abs(nodes.get(i).loc.y - nearby.get(j).loc.y);
        //if (dist < 5) { // distance in canvas pixels
        if (dist == 0) { // distance in canvas pixels
          nodes.get(i).addNeighbor(nearby.get(j).ID, dist);
          nodes.get(nearby.get(j).ID).addNeighbor(i, dist);
        }
      }
    }
    
    render(255, 255);
  }
  
  // Removes Nodes that intersect with set of obstacles
  //
  void applyObstacleCourse(ObstacleCourse c) {
    for (int i=nodes.size()-1; i>=0; i--) {
      if(c.pointInCourse(nodes.get(i).loc)) {
        nodes.remove(i);
      }
    }
    generateEdges();
  }
  
  // Removes Random Nodes from graph.  Useful for debugging
  //
  void cullRandom(float percent) {
    for (int i=nodes.size()-1; i>=0; i--) {
      if(random(1.0) < percent) {
        nodes.remove(i);
      }
    }
    generateEdges();
  }
  
  // Generates network of edges that connect adjacent nodes (including diagonals)
  //
  void generateEdges() {
    float dist;
    
    for (int i=0; i<nodes.size(); i++) {
      nodes.get(i).clearNeighbors();
      for (int j=0; j<nodes.size(); j++) {
        dist = sqrt(sq(nodes.get(i).loc.x - nodes.get(j).loc.x) + sq(nodes.get(i).loc.y - nodes.get(j).loc.y));
        
        if (dist < 2*SCALE && dist != 0) {
          nodes.get(i).addNeighbor(j, dist);
        }
      }
    }
    
    render(255, 255);
  }
  
  // Returns the number of neighbors present at a given node index
  //
  int getNeighborCount(int i) {
    if (i < nodes.size()) {
      return nodes.get(i).adj_ID.size();
    } else {
      return 0;
    }
  }
  
  // Returns the Array Index of a specific Neighbor
  //
  int getNeighbor (int i, int j) {
    int neighbor = -1;
    
    if (getNeighborCount(i) > 0) {
      neighbor = nodes.get(i).adj_ID.get(j);
    }
    
    return neighbor;
  }
  
  // Returns the Distance of a Specific Neighbor
  //
  float getNeighborDistance (int i, int j) {
    float dist = Float.MAX_VALUE;
    
    if (getNeighborCount(i) > 0) {
      dist = nodes.get(i).adj_Dist.get(j);
    }
    
    return dist;
  }
  
  int getClosestNeighbor(int i) {
    int closest = -1;
    float dist = Float.MAX_VALUE;
    float currentDist;
    
    if (getNeighborCount(i) > 0) {
      for (int j=0; j<getNeighborCount(i); j++) {
        currentDist = nodes.get(i).adj_Dist.get(j);
        if (dist > currentDist) {
          dist = currentDist;
          closest = nodes.get(i).adj_ID.get(j);
        }
      }
    }
    
    return closest;
  }
  
  float getClosestNeighborDistance(int i) {
    float dist = Float.MAX_VALUE;
    int n = getClosestNeighbor(i);
    
    for (int j=0; j<getNeighborCount(i); j++) {
      if (nodes.get(i).adj_ID.get(j) == n) {
        dist = nodes.get(i).adj_Dist.get(j);
      }
    }
    
    return dist;
  }
  
  void render(int col, int alpha) {
    img.beginDraw();
    img.clear();
    
    // Formatting
    //
    img.noFill();
    img.stroke(col, alpha);
    img.strokeWeight(1);
    
    // Draws Tangent Circles Centered at pathfinding nodes
    //
    Node n;
    for (int i=0; i<nodes.size(); i++) {
      n = nodes.get(i);
      img.ellipse(n.loc.x, n.loc.y, SCALE, SCALE);
    }
    
    // Draws Edges that Connect Nodes
    //
    int neighbor;
    for (int i=0; i<nodes.size(); i++) {
      for (int j=0; j<nodes.get(i).adj_ID.size(); j++) {
        neighbor = nodes.get(i).adj_ID.get(j);
        img.line(nodes.get(i).loc.x, nodes.get(i).loc.y, nodes.get(neighbor).loc.x, nodes.get(neighbor).loc.y);
      }
    }
    img.endDraw();
  }
}

//  Obstacles allow a user to define a polygon in 2D space.  
//  The key utility method of the class allows one to test whether or not a point 
//  lies inside or outside of a polygon obstacle
//
//  USAGE:
//  Call precalc_values() to initialize the constant[] and multiple[] arrays,
//  then call pointInPolygon(x, y) to determine if the point is in the polygon.
//
//  The function will return YES if the point x,y is inside the polygon, or
//  NO if it is not.  If the point is exactly on the edge of the polygon,
//  then the function may return YES or NO.
//
//  Note that division by zero is avoided because the division is protected
//  by the "if" clause which surrounds it.
//
class Obstacle {
  ArrayList<PVector> v; //vertices of a polygon obstacles
  ArrayList<Float> l; //lengths of sides of a polygon obstacle
  boolean active = true; // Helpful for selectively disabling obstacle
  int polyCorners; // polyCorners: How many corners the polygon has (no repeats)
  int index; // index: Indicates the index value of the "selected" polycorner
  
  Obstacle () {
    v = new ArrayList<PVector>();
    l = new ArrayList<Float>();
    constant = new ArrayList<Float>();
    multiple = new ArrayList<Float>();
    drawOutline = true;
    polyCorners = 0;
    index = 0;
  }
  
  Obstacle (PVector[] vert) {
    v = new ArrayList<PVector>();
    l = new ArrayList<Float>();
    constant = new ArrayList<Float>();
    multiple = new ArrayList<Float>();
    drawOutline = true;
    polyCorners = vert.length;
    index = 0;
    
    for (int i=0; i<vert.length; i++) {
      v.add(new PVector(vert[i].x, vert[i].y));
    }
    
    if (polyCorners > 2) {
      calc_lengths();
      precalc_values();
    }
    
  }
  
  void calc_lengths() {
    
    l.clear();
    
    // Calculates the length of each edge in pixels
    for (int i=0; i<v.size(); i++) {
      if (i < v.size()-1 ){
        l.add(sqrt( sq(v.get(i+1).x-v.get(i).x) + sq(v.get(i+1).y-v.get(i).y)));
      } else {
        l.add(sqrt( sq(v.get(0).x-v.get(i).x) + sq(v.get(0).y-v.get(i).y)));
      }
    }
  }
  
  void nextIndex() {
    index = afterIndex();
  }
  
  int priorIndex() {
    if (v.size() == 0) {
      return 0;
    } else if (index == 0) {
      return v.size()-1;
    } else {
      return index - 1;
    }
  }
  
  int afterIndex() {
    if (v.size() == 0) {
      return 0;
    } else if (index >= v.size()-1) {
      return 0;
    } else {
      return index + 1;
    }
  }
  
  void addVertex(PVector vert) {
    polyCorners++;
    if(index == v.size()-1) {
      v.add(vert);
    } else {
      v.add(afterIndex(), vert);
    }
    index = afterIndex();
    if (polyCorners > 2) {
      calc_lengths();
      precalc_values();
    }
  }
  
  void nudgeVertex(int x, int y) {
   PVector vert = v.get(index);
   vert.x += x;
   vert.y += y;
   
   v.set(index, vert);
  }
  
  void removeVertex(){
    if (polyCorners > 0) {
      polyCorners--;
      v.remove(index);
      index = priorIndex();
      if (polyCorners > 2) {
        calc_lengths();
        precalc_values();
      }
    }
  }
  
  //  The following global arrays should be allocated before calling these functions:
  //
  ArrayList<Float>  constant; // = storage for precalculated constants
  ArrayList<Float>  multiple; // = storage for precalculated multipliers
  
  // Precalculates key values used in pointInPolygon() method
  //
  void precalc_values() {
  
    int i, j = polyCorners-1 ;
  
    constant.clear();
    multiple.clear();
  
    for(i=0; i<polyCorners; i++) {
      if(v.get(j).y==v.get(i).y) {
        constant.add(v.get(i).x);
        multiple.add(0.0); 
      } else {
        constant.add(v.get(i).x-(v.get(i).y*v.get(j).x)/(v.get(j).y-v.get(i).y)+(v.get(i).y*v.get(i).x)/(v.get(j).y-v.get(i).y));
        multiple.add((v.get(j).x-v.get(i).x)/(v.get(j).y-v.get(i).y)); 
      }
      j=i; 
    }
  }
  
  // Tests whether a point is inside of a polygon
  //
  boolean pointInPolygon(float x, float y) {
    
    if (polyCorners > 2) {
      int   i, j = polyCorners-1;
      boolean  oddNodes = false;
    
      for (i=0; i<polyCorners; i++) {
        if ((v.get(i).y< y && v.get(j).y>=y
        ||   v.get(j).y< y && v.get(i).y>=y)) {
          oddNodes^=(y*multiple.get(i)+constant.get(i)<x); 
        }
        j=i; 
      }
    
      return oddNodes; 
    } else {
      return false;
    }
  
  }
  
  boolean drawOutline;
  
  void display(color stroke, int alpha, boolean editOb, boolean editCourse) {
    
    if (drawOutline && polyCorners > 1) {
      // Draws Polygon Ouline
      for (int i=0; i<polyCorners; i++) {
        stroke(stroke, alpha);
        if (i == polyCorners-1) {
          line(v.get(i).x, v.get(i).y, v.get(0).x, v.get(0).y);
        } else {
          line(v.get(i).x, v.get(i).y, v.get(i+1).x, v.get(i+1).y);
        }
      }
    }
    
    if (editOb) {
      if (editCourse && polyCorners > 0) {
        stroke(#00FF00, alpha);
        ellipse(v.get(index).x, v.get(index).y, 30, 30);
      } if (editCourse && polyCorners > 1) {
        line(v.get(index).x, v.get(index).y, v.get(afterIndex()).x, v.get(afterIndex()).y);
        noStroke();
        fill(stroke, alpha);
        ellipse(v.get(afterIndex()).x, v.get(afterIndex()).y, 30/2, 30/2);
      }
    }
  }
  
}
    
// A class for assembling courses of obstacles
//
class ObstacleCourse {
  
  ArrayList<Obstacle> course;
  boolean editCourse = false;
  
  // Index of "selected" obstacle
  //
  int index; 
  
  // Number of Obstacles
  //
  int numObstacles;
  
  ObstacleCourse() {
    index = 0;
    numObstacles = 0;
    course = new ArrayList<Obstacle>();
  }
  
  void nextIndex() {
    if (index == course.size()-1) {
      index = 0;
    } else {
      index++;
    }
  }
  
  void nextVert() {
    Obstacle o = course.get(index);
    o.nextIndex();
    course.set(index, o);
  }
  
  void addVertex(PVector vert) {
    if (course.size() == 0) {
      addObstacle();
    }
    Obstacle o = course.get(index);
    o.addVertex(vert);
    course.set(index, o);
  }
  
  void nudgeVertex(int x, int y) {
    Obstacle o = course.get(index);
    o.nudgeVertex(x, y);
    course.set(index, o);
  }
  
  void removeVertex() {
    Obstacle o = course.get(index);
    o.removeVertex();
    course.set(index, o);
  }
  
  void addObstacle() {
    course.add(new Obstacle());
    numObstacles++;
    if (index == numObstacles-2) {
      index++;
    }
  }
  
  void addObstacle(Obstacle o) {
    course.add(o);
    numObstacles++;
    if (index == numObstacles-2) {
      index++;
    }
  }
  
  void removeObstacle() {
    if (numObstacles > 0) {
      course.remove(index);
      numObstacles--;
      if (index == numObstacles && index != 0) {
        index--;
      }
    }
  }
  
  void clearCourse() {
    course.clear();
    numObstacles = 0;
    index = 0;
  }
  
  boolean pointInCourse(PVector v) {
    boolean inside = false;
    
    // Tests for Collision with Agent of known location and velocity
    for (int i=0; i<numObstacles; i++) {
      if (course.get(i).pointInPolygon(v.x, v.y) ) {
        inside = true;
        break;
      }
    }
    
    return inside;
  }
  
  void display(color stroke, int alpha, boolean editCourse) {
    Obstacle o;
    for (int i=0; i<course.size(); i++) {
      o = course.get(i);
      if (i == index && editCourse) {
        strokeWeight(4);
        o.display(#FFFF00, alpha, true, editCourse);
      } else {
        strokeWeight(1);
        o.display(stroke, alpha, false, editCourse);
      }
      strokeWeight(1);
    }
  }
  
  void saveCourse(String filename) {
    Table courseTSV = new Table();
    courseTSV.addColumn("obstacle");
    courseTSV.addColumn("vertX");
    courseTSV.addColumn("vertY");
  
    for (int i=0; i<course.size(); i++) {
      for (int j=0; j<course.get(i).polyCorners; j++) {
        TableRow newRow = courseTSV.addRow();
        newRow.setInt("obstacle", i);
        newRow.setFloat("vertX", course.get(i).v.get(j).x);
        newRow.setFloat("vertY", course.get(i).v.get(j).y);
      }
    }
    
    saveTable(courseTSV, filename);
    
    println("ObstacleCourse data saved to '" + filename + "'");
    
  }
  
  // filename = "data/course.tsv"
  void loadCourse(String filename) {
    
    Table courseTSV;
    
    try {
      courseTSV = loadTable(filename, "header");
      println("Obstacle Course Loaded from " + filename);
    } catch(RuntimeException e){
      courseTSV = new Table();
      println(filename + " incomplete file");
    }
      
    int obstacle;
    
    if (courseTSV.getRowCount() > 0) {
      
      while (numObstacles > 0) {
        removeObstacle();
      }
      
      obstacle = -1;
      
      for (int i=0; i<courseTSV.getRowCount(); i++) {
        if (obstacle != courseTSV.getInt(i, "obstacle")) {
          obstacle = courseTSV.getInt(i, "obstacle");
          addObstacle();
        }
        addVertex(new PVector(courseTSV.getFloat(i, "vertX"), courseTSV.getFloat(i, "vertY")));
      }
      
    }
  }
}
