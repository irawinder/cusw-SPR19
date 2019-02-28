void keyPressed(){
  if(key == '+'){
    cellWidth +=.25;
    cellHeight +=.25;
  }
  if(key == '-' && cellWidth != 1){
    cellWidth -=.25;
    cellHeight -=.25;
  }
  
  makeFakeHeatmap();
}
