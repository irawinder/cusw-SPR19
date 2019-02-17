class Polygon{
  ArrayList<PVector> coordinates;
  color fill;
  PShape p;
  
  Polygon(){
    coordinates = new ArrayList<PVector>();
  }
  
  Polygon(ArrayList<PVector> coords){
    coordinates = coords;
    fill = color(0, 255, 255);
    makeShape();
  }
  
  void makeShape(){
    p = createShape();
    p.beginShape();
    p.fill(fill);
    p.noStroke();
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
