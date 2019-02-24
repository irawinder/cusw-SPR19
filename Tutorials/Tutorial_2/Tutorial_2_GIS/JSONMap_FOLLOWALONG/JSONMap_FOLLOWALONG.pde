/*
This is the follow along script for Tutorial 2 

Nina Lutz
CUSW IAP 2019 
*/

//First make a blank map 
MercatorMap map;
PImage background; 

void setup(){
  size(1000, 650);
  
  //Intiailize your data structures early in setup 
  map = new MercatorMap(width, height, 42.3636, 42.3557, -71.1034, -71.0869, 0);
  pois = new ArrayList<POI>();
  polygons = new ArrayList<Polygon>();
  ways = new ArrayList<Way>();
  loadData();
  parseData();
}

void draw(){
  image(background, 0, 0);
  fill(0, 120);
  rect(0, 0, width, height);
  
  drawInfo();
  
  for(int i =0; i<ways.size(); i++){
    ways.get(i).draw();
  }
  
  for(int i =0; i<polygons.size(); i++){
    polygons.get(i).draw();
  }
  
  for(int i =0; i<pois.size(); i++){
    pois.get(i).draw();
  }
  noStroke();
}
