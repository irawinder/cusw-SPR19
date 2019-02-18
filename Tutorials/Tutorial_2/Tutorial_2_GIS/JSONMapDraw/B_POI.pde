ArrayList<POI> pois;

class POI {
  //What is the coordinate of the POI in lat, lon
  PVector coord;

  //Lat, lon values
  float lat;
  float lon;

  //Is ATM? 
  boolean ATM;

  //String to hold the type -- defaults to empty if there is none
  String type;

  POI(float _lat, float _lon) {
    lat = _lat;
    lon = _lon;
    coord = new PVector(lat, lon);
  }

  void draw() {
    PVector screenLocation = map.getScreenLocation(coord);
    fill(poi_fill);
    noStroke();
    if (ATM) fill(atm);
    ellipse(screenLocation.x, screenLocation.y, 6, 6);
  }
}
