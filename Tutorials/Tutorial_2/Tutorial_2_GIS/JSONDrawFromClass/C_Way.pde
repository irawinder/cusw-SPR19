class Way{
  ArrayList<PVector>coordinates;
  color stroke;
  
  Way(){}
  
  Way(ArrayList<PVector> coords){
    coordinates = coords;
    stroke = color(0, 0, 255);
  }
  
  void draw(){
    strokeWeight(4);
    stroke(stroke);
    for(int i =0; i<coordinates.size()-1; i++){
      PVector screenStart = map.getScreenLocation(coordinates.get(i));
      PVector screenEnd = map.getScreenLocation(coordinates.get(i+1));
      line(screenStart.x, screenStart.y, screenEnd.x, screenEnd.y);
    }
  }
  
}
