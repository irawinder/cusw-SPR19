class POI{
  //What is the coordinate of the POI in lat, lon
  PVector coord;
  
  //Lat, lon values
  float lat;
  float lon;
  
  //fill color
  color fill;

  POI(float _lat, float _lon){
    lat = _lat;
    lon = _lon;
    coord = new PVector(lat, lon);
    fill = color(255, 0, 225, 100);
  }
  
  void draw(){
    PVector screenLocation = map.getScreenLocation(coord);
    fill(fill);
    noStroke();
    ellipse(screenLocation.x, screenLocation.y, 10, 10);
  }
  
  
}
