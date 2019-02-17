/*
This script allows you to take in 
and draw basic GIS data from a JSON of GIS information

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
  polygons = new ArrayList<Polygon>();
  ways = new ArrayList<Way>();
  pois = new ArrayList<POI>();
  
  //Load in and parse your data in setup -- don't want to do this every frame!
  loadData();
  parseData();
}

void draw(){
  //background image from OSM 
  image(background, 0, 0);
  
  //Draw all the ways (roads, sidewalks, etc)
  for(int i = 0; i<ways.size(); i++){
    ways.get(i).draw();
  }
  
  //Draw all polygons 
  for(int i = 0; i<polygons.size(); i++){
    polygons.get(i).draw();
  }

  //Draw all POIs
  for(int i = 0; i<pois.size(); i++){
    pois.get(i).draw();
  }
  
  
}
