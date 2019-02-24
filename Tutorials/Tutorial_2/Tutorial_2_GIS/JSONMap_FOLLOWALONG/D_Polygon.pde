ArrayList<Polygon> polygons;

class Polygon{
  PShape p;
  ArrayList<PVector> coordinates;
  
  Polygon(){
    coordinates = new ArrayList<PVector>();
  }
  
  Polygon(ArrayList<PVector> coords){
    coordinates = coords;
    makeShape();
  }
  
  void makeShape(){
    p = createShape();
    p.beginShape();
    p.fill(polygon_fill);
    p.strokeWeight(.5);
    p.stroke(255);
    for(int i =0; i<coordinates.size(); i++){
      PVector screenLocation = map.getScreenLocation(coordinates.get(i));
      p.vertex(screenLocation.x, screenLocation.y);
    }
    p.endShape();
  }
  
  void draw(){
    shape(p, 0, 0);
  }
}
