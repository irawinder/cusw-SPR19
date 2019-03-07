/*  DRIVING FUTURES
 *  Ira Winder, ira@mit.edu, 2018
 *
 *  Driving Futures is an application that simulates and visualizes 
 *  parking utilization for passenger vehicles in hypothetical scenarios.
 *
 *  TAB MAP:
 *
 *      "A_" denotes high layer of organization on par with Main.pde
 *
 *      Main.pde          - highest level layer containing most interdependencies and complexity
 *      A_Init.pde        - mostly void functions to initializing application and simulation
 *      A_Listen.pde      - mostly void functions for drawing application to screen
 *      A_Render.pde      - Primary simulation environment
 *      Parking.pde, Agent.pde, Camera.pde, Pathfinder.pde, Toolbar.pde - Primitive class modules with no interdependencies
 *
 *  PRIMARY CLASSES:
 *
 *      These are not necessarily inter-dependent
 *      
        Parking_Routes()     - A list of travel routes to and from Parking Structures - Depends on Pathfinder.pde
 *      Parking_System()     - Mathematically realated parameters to forcast vheicle and parking demand over time using logistic equations   
 *      Parking_Structures() - A portfolio of Parking Structures (Surface, Below Ground, and Above Ground)
 *      Agent()              - A force-based autonomous agent that can navigate along a series of waypoints that comprise a path
 *      Camera()             - The primary container for implementing and editing Camera parameters
 *      ToolBar()            - Toolbar that may implement ControlSlider(), Radio Button(), and TriSlider()
 *
 *  DATA INPUT:
 *
 *      A simulation is populated with the following structured data CSVs, usually exported from
 *      ArcGIS or QGIS from available OSM files
 *
 *      Vehicle Road Network CSV
 *      Comma separated values where each node in the road network 
 *      represented as a row with the following 3 columns of information (i.e. data/roads.csv):
 *        
 *          X (Lat), Y (Lon), Road_ID
 *
 *      Parking Structure Nodes CSV
 *      Comma Separated values where each row describes a 
 *      parking structure (i.e. data/parking_nodes.csv):
 *
 *          X (Lat), Y (Lon), Structure_ID, Structure_Type, Area [sqft], Num_Spaces
 *
 *      Parking Structure Polygons CSV
 *      Comma Separated values where each row describes a 
 *      node of a parking structure polygon in the order that it is drawn (i.e. 
 *      data/parking_poly.csv):
 *
 *          X (Lat), Y (Lon), Structure_ID, Structure_Type, Area [sqft], Num_Spaces
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

boolean initialized;

// Runs once when application begins
//
void setup() {
  size(1280, 800, P3D);
  //fullScreen(P3D);
  
  initialized = false;
}

// Runs on a infinite loop after setup
//
void draw() {
  if (!initialized) {
    
    // A_Init.pde - runs until initialized = true
    //
    initialize();
    
  } else {
    
    // A_Listen.pde and A_Render.pde
    //
    listen();
    render3D();
    render2D();
  }
}
