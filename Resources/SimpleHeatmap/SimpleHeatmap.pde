Heatmap heatmap;
void setup(){
  size(800, 800);
  
  makeFakeHeatmap();
}

void draw(){
  image(heatmap.p, 0, 0);
}

void makeFakeHeatmap(){
  int numXCells = 400;
  int numYCells = 400;
  int cellWidth = 2;
  int cellHeight = 2;

  heatmap = new Heatmap(numXCells, numYCells, cellWidth, cellHeight);
  float[][] randData = new float[numXCells][numYCells];
  for(int i = 0; i<numXCells; i++){
    for(int j = 0; j<numYCells; j++){
      randData[i][j] = random(300);
    }
  }
  heatmap.scores = randData;
  heatmap.normalizeScores();
  heatmap.draw();
}
