void makeFakeHeatmap(){
  numXCells = int(width/cellWidth) + 1;
  numYCells = int(height/cellHeight) + 1;
}

class Heatmap{
  int cellX, cellY;
  float cellW, cellH;
  float[][] scores;
  color worst, mid, best;
  PGraphics p;
 
  Heatmap(){}
  
  Heatmap(int _cellX, int _cellY, float _cellW, float _cellH){}
  
  void normalizeScores(){
  }
  
  void draw(){ 
  }
  
}
