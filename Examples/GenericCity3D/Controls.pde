void keyPressed(){
  if(key == ' '){
      city.clear();
      lights.clear();
      initCity();
  }
  
  if(key == 'c'){
    city.clear();
    lights.clear();
    corners = !corners;
    initCity();
  }
}
