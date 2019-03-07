// Specifies a Path Object (a sequence of points)
//
class Path {
  PVector origin;
  PVector destination;
  ArrayList<PVector> waypoints;
  boolean enableFinder = true;
  float diameter = 10;
  
  // Constructs a random straight-line path within a specified rectangle
  Path(float x, float y, float l, float w) {
    origin = new PVector( random(x, x+l), random(y, y+w) );
    destination = new PVector( random(x, x+l), random(y, y+w) );
    waypoints = new ArrayList<PVector>();
    straightPath();
  }
  
  // Constructs an Empy Path with waypoints yet to be included
  Path(PVector o, PVector d) {
    origin = o;
    destination = d;
    waypoints = new ArrayList<PVector>();
    straightPath();
  }
  
  void solve(Pathfinder finder) {
    waypoints = finder.findPath(origin, destination, enableFinder);
    diameter = finder.network.SCALE;
  }
  
  void straightPath() {
    waypoints.clear();
    waypoints.add(origin);
    waypoints.add(destination);
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
    fill(#FF0000); // Red
    ellipse(origin.x, origin.y, diameter, diameter);
    fill(#0000FF); // Blue
    ellipse(destination.x, destination.y, diameter, diameter);
    
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
    
    // If method is passed a false boolean, merely returns the origin and destination as a eclidean path
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
      getVisited();
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
