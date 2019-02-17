class POI{
  PVector coord;
  float lat, lon;
  color fill;
  
  POI(float _lat, float _lon){
    lat = _lat;
    lon = _lon;
    coord = new PVector(lat, lon);
    fill = color(255, 0, 255);
  }
  
  void draw(){
    PVector screenLocation = map.getScreenLocation(coord);
    fill(fill);
    noStroke();
    ellipse(screenLocation.x, screenLocation.y, 10, 10);
  }
}
