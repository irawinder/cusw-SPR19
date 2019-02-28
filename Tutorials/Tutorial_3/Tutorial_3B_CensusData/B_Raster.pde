class Raster{
  //Simple class for a square raster
  float cellSize, w, h;
  int numX, numY;
  PVector start;
  PVector[][] centers;
  float[][] scores;
  
  Raster(float _size, float _w, float _h){
    w = _w;
    h = _h;
    numX = int(w/_size);
    numY = int(h/_size);
    cellSize = _size;
    centers = new PVector[numX][numY];
    scores = new float[numX][numY];
    start = new PVector(0, 0);
    generateCenters();
    bucketRasterPolys(CensusPolygons);
  }
  
  void generateCenters(){
    for(int i = 0; i<numX; i++){
      for(int j = 0; j<numY; j++){
        centers[i][j] = new PVector(i*(start.x + cellSize) + cellSize/2, j*(start.y + cellSize) + cellSize/2);
      }
    }
  }
  
  void bucketRasterPolys(ArrayList<Polygon>polys){
    //For now, we're just going to assign each cell a score based on what polygon its center is in 
    //If it isn't in any, then we just give it a score of 0 
    //You can always assign multiple scores, etc 
    //And then combine this with a HeatMap situation, like in another tutorial
    
    for(int i = 0; i<numX; i++){
      for(int j = 0; j<numY; j++){
        scores[i][j] = 0;
        for(int k = 0; k<polys.size();k ++){
          Polygon p = polys.get(k);
          PVector l = centers[i][j];
          if(p.pointInPolygon(map.getGeo(l))){
            //println(p.score);
            scores[i][j] = p.score;
          }
        }
        
      }
    }
    
  }
  
  void draw(){
    for(int i = 0; i<numX; i++){
      for(int j = 0; j<numY; j++){
      stroke(0);
      //obviously you could change this to a score situation like the heatmap
      fill(scores[i][j]);
      rect(i*(start.x + cellSize), j*(start.y + cellSize), cellSize, cellSize);
      ellipse(centers[i][j].x, centers[i][j].y, 1, 1);
      }
    }
  }

}
