class Way{
  //Coordinates and color variables
  ArrayList<PVector>coordinates;
  color stroke;
  
  //Empty constructor
  Way(){}
  
  //Constructor of coordinates
  Way(ArrayList<PVector> coords){
    coordinates =  coords;
    stroke = color(0, 0, 255, 100);
  }
  
  //Draw the road
  void draw(){
    strokeWeight(4);
    stroke(stroke);
    for(int i = 0; i<coordinates.size()-1; i++){
        //iterate through the coordinates and draw lines
        PVector screenStart = map.getScreenLocation(coordinates.get(i));
        PVector screenEnd = map.getScreenLocation(coordinates.get(i+1));
        line(screenStart.x, screenStart.y, screenEnd.x, screenEnd.y);
  }
  }
}
