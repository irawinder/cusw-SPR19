color poi_fill = color(255, 99, 71);
color atm = color(255, 255, 0);
color polygon_fill = color(32, 178, 170);
color road_color = color(100, 149, 237);

void drawInfo(){
  fill(0);
  rect(20, 20, 125, 90);
  textSize(16);
  fill(poi_fill);
  text("POIs", 25, 40);
  fill(atm);
  text("ATM", 25, 60);
  fill(road_color);
  text("Roads", 25, 80);
  fill(polygon_fill);
  text("Buildings", 25, 100);
}
