Table nodes, attributes;
void loadData(){
  nodes = loadTable("data/smallTestNodes.csv", "header");
  attributes = loadTable("data/smallTestAttributes.csv", "header");
  println("Data Loaded");
}


void parseData(){
  int previd = 0;
  ArrayList<PVector> coords = new ArrayList<PVector>();
  for(int i = 0; i<nodes.getRowCount(); i++){
    int shapeid = int(nodes.getString(i, 0));
       if(shapeid != previd){
         if(coords.size() > 0){
           Polygon poly = new Polygon(coords);
           polygons.add(poly);
         }
         //clear coords
         coords = new ArrayList<PVector>();
         //reset variable
         previd = shapeid;
       }
       if(shapeid == previd){
         float lat = float(nodes.getString(i, 2));
         float lon = float(nodes.getString(i, 1));
         coords.add(new PVector(lat, lon));
       }
  }
  println(polygons.size());

}
