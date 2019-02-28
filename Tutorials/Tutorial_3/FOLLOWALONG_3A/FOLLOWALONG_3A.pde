/*
Computational Urban Science Workshop
Ira Winder and Nina Lutz 

Script: Nina Lutz
Simple heatmap class and script generating a random one
*/

Heatmap heatmap;
float cellWidth = 10;
float cellHeight = 10;
int numXCells, numYCells;

void setup(){
  size(600, 600);
  makeFakeHeatmap();
}

void draw(){
  image(heatmap.p, 0, 0);
}
