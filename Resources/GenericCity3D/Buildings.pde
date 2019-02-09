//Simple building class
class Building {
  
  //properties of the building
  PVector loc;
  float size, num, w, h;
  
  //Constructor
  Building(PVector loc, float size, float w, float h) {
    this.loc  = loc;
    this.size = size*12;
    this.h = h;
    this.w = w;
  }
  
  //Draw function for the building
  void draw() {
    pushMatrix();
    translate(loc.x, loc.y-num/2, loc.z);
    
    fill(100);
    noStroke();
    
    //Gives the grid cells an outline and brighter fill
    if(size < 1){
      stroke(20);
      fill(255);
    }

    box(w, num, h);
    
    popMatrix();


    // Animate growth
    if (num < size) {
      num+=map(size, 0, 200, 0.3, 4);
    }
  }
}


void drawBuildings(){
  for (int i = 0; i < city.size (); i++) {
    Building b = (Building) city.get(i);
    b.draw();
  }
  //controls rotation speed
  num+=0.3;

}
