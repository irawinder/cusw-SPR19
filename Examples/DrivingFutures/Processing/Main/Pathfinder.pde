/*  PATHFINDER ALGORITHMS
 *  Ira Winder, ira@mit.edu, 2018
 *
 *  Scripts that ultimately calucation the shortest path between two 
 *  points according to variously defined network configurations.
 *
 *  CLASSES CONTAINED:
 *
 *    Pathfinder() - Method to calculate shortest path between two nodes in a graph/network
 *    Graph()      - Network of nodes and wighted edges
 *    Node()       - Fundamental building block of Graph()
 *
 *    RoadNetwork()    - Class for importing OSM road lines and converting them into Graph()
 *    RasterCourse()   - Class for importing rasterfiles and converting them into Graph()
 *    ObstacleCourse() - Contains multiple Obstacles; Allows editing, saving, and loading of configuration
 *    Obstacle()       - 2D polygon that can detect overlap events
 *
 *
 *  FUNDAMENTAL OUTPUT: 
 *
 *    ArrayList<PVector> shortestPath = Pathfinder.findPath(PVector A, PVector B, boolean enable)
 *
 *  CLASS DEPENDENCY TREE: 
 *
 *
 *     Node()      ->      Graph()        ->      Pathfinder()  ->  OUTPUT: ArrayList<PVector> shortestPath
 *
 *                            ^                                        |
 *     Roadnetwork()    ->    |                                        v
 *
 *     Obstacle()  ->  ObstacleCourse()                             Agent()                                   
 *
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
  boolean drawNodes, drawEdges;
  
  // Graph from JSON File
  //
  Graph (int w, int h, String fileName, boolean drawNodes, boolean drawEdges) {
    img = createGraphics(w, h);
    nodes = new ArrayList<Node>();
    loadJSON(fileName);
    this.drawNodes = drawNodes;
    this.drawEdges = drawEdges;
    render(255, 255);
  }
  
  // Using the canvas width and height in pixels, a gridded graph 
  // is generated with a pixel spacing of 'scale'
  //
  Graph (int w, int h, float scale) {
    SCALE = scale;
    U = int(w / SCALE);
    V = int(h / SCALE);
    img = createGraphics(w, h);
    drawNodes = true;
    drawEdges = true;
    nodes = new ArrayList<Node>();
    for (int i=0; i<U; i++) {
      for (int j=0; j<V; j++) {
        nodes.add(new Node(i*SCALE + scale/2, j*SCALE + scale/2, SCALE));
      }
    }
    generateEdges();
  }
  
  // Using the canvas width and height in pixels, a graph 
  // is generated using an OSM-standard roadfile CSV/Table 
  //
  Graph(int w, int h, float latMin, float latMax, float lonMin, float lonMax, float scale, RoadNetwork r) {
    SCALE = scale;
    U = int(w / SCALE);
    V = int(h / SCALE);
    img = createGraphics(w, h);
    drawNodes = false;
    drawEdges = true;
    nodes = new ArrayList<Node>();
    
    float x, y;
    int numNodes = r.networkT.getRowCount();
    Node n;
    float canvasX, canvasY;
    for (int i=0; i<numNodes; i++) {
      // Status Output
      if (i%10000 == 0 || i == numNodes-1) println("Loading Nodes: " + int(100*float(i+1)/numNodes) + "% complete");
      x        = r.networkT.getFloat(i, 0);
      y        = r.networkT.getFloat(i, 1);
      canvasX  = w * (x - lonMin) / abs(lonMax - lonMin);
      canvasY  = h - h * (y - latMin) / abs(latMax - latMin);
      n = new Node(canvasX, canvasY, SCALE);
      n.clearNeighbors();
      nodes.add(n);
    }
    
    // Connect per Object ID
    int objectID, lastID = -1;
    float dist, speed;
    String oneway, type;

    for (int i=0; i<numNodes; i++) {
      if (i%10000 == 0 || i == numNodes-1) println("Loading Segments: " + int(100*float(i+1)/nodes.size()) + "% complete");
      if (i != 0) {
      lastID   = r.networkT.getInt(i-1, 2);
      }
      objectID = r.networkT.getInt(i, 2);
      if (lastID == objectID) {
        oneway = r.networkT.getString(i, 7);
        type = r.networkT.getString(i, 4);
        speed = r.getSpeed(type); // need to eventually map speed to node type
        dist = sqrt(sq(nodes.get(i).loc.x - nodes.get(i-1).loc.x) + sq(nodes.get(i).loc.y - nodes.get(i-1).loc.y));
        dist /= speed;
        //Key: F = From-To; T = To-From; B = both directions okay
        if (!oneway.equals("F")) nodes.get(i).addNeighbor(i-1, dist);
        if (!oneway.equals("T")) nodes.get(i-1).addNeighbor(i, dist);
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
    for (int i=0; i<numNodes; i++) {
      nodes.get(i).ID = i;
      u = min(U-1, nodes.get(i).gridX);
      u = max(0,   u);
      v = min(V-1, nodes.get(i).gridY);
      v = max(0,   v);
      bucket[u][v].add(nodes.get(i));
    }
    for (int i=0; i<numNodes; i++) {
      // Status Output
      if (i%10000 == 0 || i == numNodes-1) println("Connecting Segments: " + int(100*float(i+1)/nodes.size()) + "% complete");
      u = min(U-1, nodes.get(i).gridX);
      u = max(0,   u);
      v = min(V-1, nodes.get(i).gridY);
      v = max(0,   v);
      ArrayList<Node> nearby = bucket[u][v];
      for (int j=0; j<nearby.size(); j++) {
        dist = abs(nodes.get(i).loc.x - nearby.get(j).loc.x) + abs(nodes.get(i).loc.y - nearby.get(j).loc.y);
        //if (dist < 20) { // distance in canvas pixels
        if (dist == 0) { // distance in canvas pixels
          type = r.networkT.getString(i, 4);
          speed = r.getSpeed(type); // need to eventually map speed to node type
          dist /= speed;
          nodes.get(i).addNeighbor(nearby.get(j).ID, dist);
          nodes.get(nearby.get(j).ID).addNeighbor(i, dist);
        }
      }
    }
    
    render(255, 255);
  }
  
  // A Graph is created by loading a compatible JSON file
  //
  void loadJSON(String fileName) {
    JSONObject graphJSON = loadJSONObject(fileName);
    
    U = graphJSON.getInt("U");
    V = graphJSON.getInt("V");
    SCALE = graphJSON.getInt("SCALE");
    JSONArray nodesJSON = graphJSON.getJSONArray("nodes");
    
    nodes.clear();
    for (int n=0; n<nodesJSON.size(); n++) {
      JSONObject nodeJSON = nodesJSON.getJSONObject(n);
      float x = nodeJSON.getFloat("locX");
      float y = nodeJSON.getFloat("locY");
      Node node = new Node(x, y, SCALE);
      node.ID = nodeJSON.getInt("ID");
      node.gridX = nodeJSON.getInt("gridX");
      node.gridY = nodeJSON.getInt("gridY");
      
      JSONArray neighborsJSON = nodeJSON.getJSONArray("neighbors");
      for (int i=0; i<neighborsJSON.size(); i++) {
        JSONObject neighborJSON = neighborsJSON.getJSONObject(i);
        int adj_ID = neighborJSON.getInt("adj_ID");
        float adj_Dist = neighborJSON.getFloat("adj_Dist");
        node.addNeighbor(adj_ID, adj_Dist);
      }
      nodes.add(node);
    }
  }
  
  // Save Graph Nodes to JSON
  //
  void saveJSON(String fileName) {
    JSONObject graphJSON = new JSONObject();
    
    // The graph object contains four attributes:
    graphJSON.setInt("U", U);
    graphJSON.setInt("V", V);
    graphJSON.setFloat("SCALE", SCALE);
    JSONArray nodesJSON = new JSONArray();
    
    // All nodes of the graph are populated
    for (Node n: nodes) {
      JSONObject nodeJSON = new JSONObject();
      
      // Each node's metadata:
      nodeJSON.setInt("ID", n.ID);
      nodeJSON.setFloat("locX", n.loc.x);
      nodeJSON.setFloat("locY", n.loc.y);
      nodeJSON.setInt("gridX", n.gridX);
      nodeJSON.setInt("gridY", n.gridY);
      
      // Each node has a list of neighbors (ID and distance) associated with them
      JSONArray neighborsJSON = new JSONArray();
      for (int i=0; i<n.adj_ID.size(); i++) {
        JSONObject neighborJSON = new JSONObject();
        neighborJSON.setInt("adj_ID", n.adj_ID.get(i) );
        neighborJSON.setFloat("adj_Dist", n.adj_Dist.get(i) );
        neighborsJSON.append(neighborJSON);
      }
      nodeJSON.setJSONArray("neighbors", neighborsJSON);
      nodesJSON.append(nodeJSON);
    }
    graphJSON.setJSONArray("nodes", nodesJSON);
    
    // JSON file saved to disk
    saveJSONObject(graphJSON, "data/" + fileName);
  }
  
  void newNodes(ArrayList<PVector> locs) {
    nodes.clear();
    for (PVector l: locs) {
      nodes.add( new Node(l.x, l.y, SCALE) );
    }
    generateEdges();
  }
  
  // Snap continuous coordinate to grid mesh
  //
  PVector snapXY(float x, float y) {
    PVector snap = new PVector(0,0);
    if (x % SCALE < SCALE/2) {
      snap.x = x - x % SCALE - SCALE/2;
    } else {
      snap.x = x - x % SCALE + SCALE/2;
    }
    if (y % SCALE < SCALE/2) {
      snap.y = y - y % SCALE - SCALE/2;
    } else {
      snap.y = y - y % SCALE + SCALE/2;
    }
    return snap;
  }
  
  // Detect node at a specific location
  //
  boolean emptyNode(PVector loc) {
    boolean empty = true;
    for (Node n: nodes) {
      if ( abs(n.loc.x - loc.x) < SCALE/2 && abs(n.loc.y - loc.y) < SCALE/2 ) {
        empty = false;
      }
    }
    return empty;
  }
 
  
  // Toggle Snap Node
  void toggleSnapNode(float x, float y) {
    boolean empty = true;
    Node n;
    for (int i=0; i<nodes.size(); i++) {
      n = nodes.get(i);
      if ( abs(n.loc.x - x) < SCALE/2 && abs(n.loc.y - y) < SCALE/2 ) {
        empty = false;
        nodes.remove(i);
        break;
      }
    }
    if ( empty ) {
      PVector newLocation = snapXY(x, y);
      addNode(newLocation.x, newLocation.y);
    }
  }
  
  // Add a a Node
  void addNode(float x, float y) {
    Node n = new Node(x,y, SCALE);
    nodes.add(n);
  }
  
  // Removes Nodes that intersect with set of obstacles
  //
  void applyCourse(ObstacleCourse c) {
    for (int i=nodes.size()-1; i>=0; i--) {
      if(c.pointInCourse(nodes.get(i).loc)) {
        nodes.remove(i);
      }
    }
    generateEdges();
  }
  
  // Removes nodes specified by a grayscale image
  //
  void applyCourse(RasterCourse c) {
    for (int i=nodes.size()-1; i>=0; i--) {
      if(c.pointInCourse(nodes.get(i).loc, "ADD")) {
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
      if (i%100 == 0) println(int(100*float(i)/nodes.size()) + "% complete");
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
    img.strokeWeight(10);
    
    // Draws Tangent Circles Centered at pathfinding nodes
    //
    if (drawNodes) {
      Node n;
      for (int i=0; i<nodes.size(); i++) {
        n = nodes.get(i);
        img.ellipse(n.loc.x, n.loc.y, SCALE, SCALE);
      }
    }
    
    // Draws Edges that Connect Nodes
    //
    if (drawEdges) {
      int neighbor;
      for (int i=0; i<nodes.size(); i++) {
        for (int j=0; j<nodes.get(i).adj_ID.size(); j++) {
          neighbor = nodes.get(i).adj_ID.get(j);
          img.line(nodes.get(i).loc.x, nodes.get(i).loc.y, nodes.get(neighbor).loc.x, nodes.get(neighbor).loc.y);
        }
      }
    }
    img.endDraw();
  }
}


// Specifies a Path Object (a sequence of points)
//
class Path {
  PVector origin;
  PVector destination;
  ArrayList<PVector> waypoints;
  boolean enableFinder = true;
  float diameter = 10;
  boolean closed;
  
  Path () { } // Load blank path
  
  Path(float x, float y, float l, float w) {
    origin = new PVector( random(x, x+l), random(y, y+w) );
    destination = new PVector( random(x, x+l), random(y, y+w) );
    waypoints = new ArrayList<PVector>();
    straightPath();
  }
  
  Path(PVector o, PVector d) {
    origin = o;
    destination = d;
    waypoints = new ArrayList<PVector>();
    straightPath();
  }
  
  void solve(Pathfinder finder) {
    waypoints = finder.findPath(origin, destination, enableFinder);
    diameter = 2*finder.network.SCALE;
  }
  
  void joinPath(Path p, boolean closed) {
    for(PVector v: p.waypoints) {
      waypoints.add(v);
    }
    this.closed = closed;
  }
  
  void straightPath() {
    waypoints.clear();
    waypoints.add(origin);
    waypoints.add(destination);
    closed = false;
  }
  
  void display(int col, int alpha) {
    // Draw Shortest Path
    //
    noFill();
    strokeWeight(2);
    stroke(#00FF00, alpha); // Green
    PVector n1, n2;
    for (int i=1; i<waypoints.size(); i++) {
      n1 = waypoints.get(i-1);
      n2 = waypoints.get(i);
      line(n1.x, n1.y, n2.x, n2.y);
    }
    
    // Draw Origin (Red) and Destination (Blue)
    //
    pushMatrix();
    translate(0,0,1);
    fill(#FF0000); // Red
    ellipse(origin.x, origin.y, diameter, diameter);
    fill(#0000FF); // Blue
    ellipse(destination.x, destination.y, diameter, diameter);
    popMatrix();
    strokeWeight(1);
  }
}

// The Pathfinder class allows one to the retreive a path (ArrayList<PVector>) that
// describes an optimal route.  The Pathfinder must be initialized as a graph (i.e. a network of nodes and edges).
// An ObstacleCourse object may be used to customize the Pathfinder Graph
//
// Development Notes/Process
// Step 1: Create a matrix of Nodes that exclude those overlapping with Obstacle Course (Graph + Node classes)
// Step 2: Generate Edges connect adjacent nodes (Graph class)
// Step 3: Implement A* Pathfinding Algorithm (Pathfinding class)
//
class Pathfinder { 
  Graph network;
  
  int networkSize;
  
  //Helper Variables for Pathfinder Calculation
  PVector a, b;
  ArrayList<PVector> pathNodes, visitedNodes;
  float[] totalDist;
  int[] parentNode;
  boolean[] visited;
  ArrayList<Integer> allVisited;
  
  Pathfinder(Graph network) {
    this.network = network;
    networkSize = network.nodes.size();
    totalDist = new float[networkSize];
    parentNode = new int[networkSize];
    visited = new boolean[networkSize];
    allVisited = new ArrayList<Integer>();
    pathNodes = new ArrayList<PVector>();
    visitedNodes = new ArrayList<PVector>();
    a = new PVector(0, 0);
    b = new PVector(0, 0);
  }
  
  // a, b, represent respective index for start and end nodes in pathfinding network
  //
  ArrayList<PVector> findPath(PVector A, PVector B, boolean enable) {
    
    pathNodes = new ArrayList<PVector>();
    a = A;
    b = B;
    allVisited.clear();
    
    // If method is passed a false boolean, merely returns the origin and destinate as a eclidean path
    //
    if (!enable) {
      
      pathNodes.add(a);
      pathNodes.add(b);
      
    } else {
      
      ArrayList<Integer> toVisit = new ArrayList<Integer>();
      
      int a_index = getClosestNode(a);
      int b_index = getClosestNode(b);
      
      // Initialize Helper Variables
      //
      for (int i=0; i<networkSize; i++) {
        totalDist[i] = Float.MAX_VALUE;
        visited[i] = false;
      }
      totalDist[a_index] = 0;
      parentNode[a_index] = a_index;
      int current = a_index;
      toVisit.add(current);
      allVisited.add(current);
      
      // Loop runs until path is found or ruled out
      //
      boolean complete = false;
      while(!complete) {
        
        // Cycles through all neighbors in current node
        //
        for(int i=0; i<network.getNeighborCount(current); i++) { 
          
          // Resets the cumulative distance if shorter path is found
          //
          float currentDist = totalDist[current] + getNeighborDistance(current, i);
          if (totalDist[getNeighbor(current, i)] > currentDist) {
            totalDist[getNeighbor(current, i)] = currentDist;
            parentNode[getNeighbor(current, i)] = current;
          }
          
          // Adds non-visited neighbors of current node to queue
          //
          if (!visited[getNeighbor(current, i)]) {
            toVisit.add(getNeighbor(current, i));
            allVisited.add(getNeighbor(current, i));
            visited[getNeighbor(current, i)] = true;
          }
        }
        
        // Marks current node as visited and removes from queue
        //
        visited[current] = true;
        toVisit.remove(0);
        
        // If there are still nodes in the queue, goes to the next. 
        //
        if (toVisit.size() > 0) {
          
          current = toVisit.get(0);
          
          // Terminates loop if destination is reached
          //
          if (current == b_index) {
            
            // Working backward from destination, rebuilds optimal path to origin from parentNode data
            //
            pathNodes.add(0, b); //Canvas Coordinate of destination
            pathNodes.add(0, getNode(b_index) ); //Pathfinding node closest to destination
            current = b_index;
            while (!complete) {
              pathNodes.add(0, getNode(parentNode[current]) );
              current = parentNode[current];
              
              if (current == a_index) {
                complete = true;
                pathNodes.add(0, a); //Canvas Coordinate of origin
              }
            }
          }
        
        // If no more nodes left in queue, path is returned as unsolved
        //
        } else {
          
          // Returns path-not-found
          //
          complete = true;
          
          // only returns the origin as path
          //
          pathNodes.add(0, a);
        }
      }
    }
    
    return pathNodes;
  }
  
  ArrayList<PVector> getVisited() {
    
    visitedNodes = new ArrayList<PVector>();
    
    for (int i=0; i<allVisited.size(); i++) {
      visitedNodes.add(getNode(allVisited.get(i)));
    }
    
    return visitedNodes;
  }
    
  float getResolution() {
    return network.SCALE;
  }
  
  int getNeighbor(int current, int i) {
    return network.getNeighbor(current, i);
  }
  
  float getNeighborDistance(int current, int i) {
    return network.getNeighborDistance(current, i);
  }
  
  // calculates the index of pathfinding node closest to the given canvas coordinate 'v'
  // returns -1 if node not found
  //
  int getClosestNode(PVector v) {
    int node = -1;
    float distance = Float.MAX_VALUE;
    float currentDist;
    
    for (int i=0; i<networkSize; i++) {
      currentDist = sqrt( sq(v.x-getNode(i).x) + sq(v.y-getNode(i).y) );
      if (currentDist < distance) {
        node = i;
        distance = currentDist;
      }
    }
    
    return node;
  }
  
  PVector getNode(int i) {
    if (i < networkSize) {
      return network.nodes.get(i).loc;
    } else {
      return new PVector(-1,-1);
    }
  }
  
  void display(int col, int alpha, boolean showVisited) {
    noFill();
    
    // Draw Visited Nodes
    strokeWeight(1);
    stroke(col, alpha);
    if (showVisited) {
      PVector n;
      for (int i=0; i<visitedNodes.size(); i++) {
        n = visitedNodes.get(i);
        ellipse(n.x, n.y, network.SCALE, network.SCALE);
      }
    }
    
    // Draw Shortest Path
    //
    strokeWeight(2);
    stroke(#00FF00, alpha); // Green
    PVector n1, n2;
    for (int i=1; i<pathNodes.size(); i++) {
      n1 = pathNodes.get(i-1);
      n2 = pathNodes.get(i);
      line(n1.x, n1.y, n2.x, n2.y);
    }
    
    // Draw Origin (Red) and Destination (Blue)
    //
    stroke(#FF0000, alpha); // Red
    ellipse(a.x, a.y, network.SCALE, network.SCALE);
    stroke(#0000FF, alpha); // Blue
    ellipse(b.x, b.y, network.SCALE, network.SCALE);
    
    strokeWeight(1);
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

class RasterCourse {
  PImage raster;
  // The effective position of the raster within the main canvas:
  float rX, rY, rW, rH;
  float scaleX, scaleY;
  // Threshold and radius define the sensativity of the obstacle detection algorithm
  float threshold, sensitivity;
  int searchU, searchV, sampleSize;
  boolean invert = false;
  
  RasterCourse(PImage raster, float sensitivity, float threshold, float radius, int rX, int rY, int rW, int rH) {
    this.raster = raster;
    this.threshold = 255.0*threshold;
    this.sensitivity = sensitivity;
    this.rX = rX;
    this.rY = rY;
    this.rW = rW;
    this.rH = rH;
    scaleX = float(raster.width)  / rW;
    scaleY = float(raster.height) / rH;
    searchU = int(radius*scaleX);
    searchV = int(radius*scaleY);
    sampleSize = (2*searchU+1)*(2*searchV+1);
  }
  
  RasterCourse(PImage raster, float sensitivity, float threshold, float radius) {
    this(raster, sensitivity, threshold, radius, 0, 0, raster.width, raster.height);
  }
  
  void invert() {
    invert = !invert;
  }
  
  // Detect of a canvas Node is "blocked" by the RasterCourse
  boolean pointInCourse(PVector canvasLoc, String mode) {
    int u, v;
    int positives = 0;
    color sample;
    float brightness;
    boolean inCourse = false;
    if (canvasLoc.x > rX && canvasLoc.x < rX+rW && canvasLoc.y > rY && canvasLoc.y < rY+rH) {
      for (int i=-searchU; i<=searchU; i++) {
        for (int j=-searchV; j<=searchV; j++) {
          u = int( (canvasLoc.x - rX) * scaleX ) + i;
          v = int( (canvasLoc.y - rY) * scaleY ) + j;
          u = constrain(u, 0, raster.width-1);
          v = constrain(v, 0, raster.height-1);
          sample = raster.get(u, v);
          if (invert) {
            brightness = 255.0 - brightness(sample);
          } else {
            brightness = brightness(sample);
          }
          if ( brightness < threshold ) {
            positives++;
          }
        }
      }
      if (positives > (1-sensitivity)*sampleSize) {
        inCourse = true;
      }
    }
    if (mode.equals("ADD") && positives < sampleSize) inCourse = false;
    return inCourse;
  }
}

class RoadNetwork {
  Table networkT;
  float x_min, x_max;
  float y_min, y_max;
  float x_w,   y_w;
  
  float[] speedCategories;
  ArrayList<ArrayList<String>> classNames = new ArrayList<ArrayList<String>>();
  
  RoadNetwork(String fileName) {
    networkT = loadTable(fileName, "header"); // formatted as QGIS Export of Extracted Nodes
    float x, y;
    for (int i=0; i<networkT.getRowCount(); i++) {
      x = networkT.getFloat(i, 0);
      y = networkT.getFloat(i, 1);
      if (i==0) {
        x_min = networkT.getFloat(i, 0);
        x_max = networkT.getFloat(i, 0);
        y_min = networkT.getFloat(i, 1);
        y_max = networkT.getFloat(i, 1);
      } else {
        if (x < x_min) x_min = networkT.getFloat(i, 0);
        if (x > x_max) x_max = networkT.getFloat(i, 0);
        if (y < y_min) y_min = networkT.getFloat(i, 1);
        if (y > y_max) y_max = networkT.getFloat(i, 1);
      }
    }
    x_w = x_max - x_min;
    y_w = y_max - y_min;
    
    printExtents();
    
    initSpeedCategories();
  }
  
  RoadNetwork(String fileName, float latMin, float latMax, float lonMin, float lonMax) {
  // Use rarely to "clean" and save a CSV file of a roadnetwork that is larger than you need
    networkT = loadTable(fileName, "header"); // formatted as QGIS Export of Extracted Nodes
    x_min = lonMin;
    x_max = lonMax;
    y_min = latMin;
    y_max = latMax;
    x_w = x_max - x_min;
    y_w = y_max - y_min;
    for (int i=networkT.getRowCount()-1; i > 0; i--) {
      if (networkT.getFloat(i, 0) < x_min || networkT.getFloat(i, 0) > x_max || 
          networkT.getFloat(i, 1) < y_min || networkT.getFloat(i, 1) > y_max ) {
      
        networkT.removeRow(i);  
        println(i);
      }
      
      //Relevant for Boston Road Segments Datafile ... deprecated when using OSM format
      //boolean noway = networkT.getString(i, 16).equals("N");
      //if (noway) {
      //  networkT.removeRow(i);  
      //  println(i);
      //}
    }
    
    printExtents();
    saveTable(networkT, "data/roads_smaller.csv");
    
    initSpeedCategories();
  }
  
  void initSpeedCategories() {
    
    /*  MA Speed Limits 
        https://en.wikipedia.org/wiki/Speed_limits_in_the_United_States_by_jurisdiction#Massachusetts
      
          20 mph (32 km/h) in the area of a vehicle (for example, an ice cream truck) that is selling merchandise and is displaying flashing amber lights
          20 mph (32 km/h) in a school zone when children are present
          30 mph (48 km/h) on a road in a "thickly settled" or business district for at least 1⁄8 mile (200 m)
          40 mph (64 km/h) on a road outside of a "thickly settled" or business district for at least 1⁄4 mile (400 m)
          50 mph (80 km/h) on a divided highway outside of a "thickly settled" or business district for at least 1⁄4 mile (400 m)
        
        Best-Guess OSM Standard Vehicle-Road Classifications:
    */
    
    speedCategories = new float[4];
    speedCategories[0] = 20.0; 
    speedCategories[1] = 30.0; 
    speedCategories[2] = 40.0; 
    speedCategories[3] = 50.0; 
    
    ArrayList<String> names;
    
    names = new ArrayList<String>();
    names.add("living_street");
    names.add("service");
    names.add("track");
    names.add("track_grade1");
    names.add("track_grade2");
    names.add("track_grade3");
    names.add("track_grade4");
    names.add("track_grade5");
    names.add("unclassified");
    names.add("unknown");
    classNames.add(names);
    
    names = new ArrayList<String>();
    names.add("trunk_link");
    names.add("primary_link");
    names.add("secondary_link");
    names.add("tertiary_link");
    names.add("residential");
    classNames.add(names);
    
    names = new ArrayList<String>();
    names.add("motorway_link");
    names.add("trunk");
    names.add("primary");
    names.add("secondary");
    names.add("tertiary");
    classNames.add(names);
    
    names = new ArrayList<String>();
    names.add("motorway");
    classNames.add(names);
  }
  
  void printExtents() {
    println("Road Network Lon Range: " + x_min + " , " + x_max + "\n" + 
            "Road Network Lat Range: " + y_min + " , " + y_max
            );
  }
  
  float getSpeed(String roadType) {
    
    float speed = 0.0;

    for (int i=0; i<speedCategories.length; i++) {
      for (String t: classNames.get(i)) {
        if (roadType.equals(t)) {
          speed = speedCategories[i];
          break;
        }
      }
    }
    return speed;
    
  }
}