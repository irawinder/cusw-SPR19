MercatorMap map;

void setup(){
  size(600, 700);
  //Intiailize your data structures early in setup 
  map = new MercatorMap(width, height, 29, 26, -83, -76, 0);
  polygons = new ArrayList<Polygon>();
  loadData();
  parseData();
}

void draw(){
  background(0);
  for(int i =0; i<polygons.size(); i++){
    polygons.get(i).draw();
  }
}
