JSONObject example;
JSONArray features;
JSONObject wholeArea;

void loadData(){
  //Load our image
  background = loadImage("data/background.png");
  background.resize(width, height);
  
  ////Small example area
  //example = loadJSONObject("data/example.json");
  //features = example.getJSONArray("features");
  
  //Bigger example area 
  wholeArea = loadJSONObject("data/wholeArea.json");
  features = wholeArea.getJSONArray("features");
  
  println("Data loaded");
}

void parseData(){
  JSONObject feature = features.getJSONObject(1);
  //println(feature);
  
  for(int i =0; i<features.size(); i++){
    //ID 3 main types of things in feature
    String type = features.getJSONObject(i).getJSONObject("geometry").getString("type");
    JSONObject geometry = features.getJSONObject(i).getJSONObject("geometry");
    JSONObject properties =  features.getJSONObject(i).getJSONObject("properties");
    println(properties);
    
    if(type.equals("Point")){
      //create new POI
      float lat = geometry.getJSONArray("coordinates").getFloat(1);
      float lon = geometry.getJSONArray("coordinates").getFloat(0);
      POI poi = new POI(lat, lon);
      pois.add(poi);
    }
    
    if(type.equals("Polygon")){
      //create new Polygon
      ArrayList<PVector> coords = new ArrayList<PVector>();
      JSONArray coordinates = geometry.getJSONArray("coordinates").getJSONArray(0);
      for(int j = 0; j<coordinates.size(); j++){
        float lat = coordinates.getJSONArray(j).getFloat(1);
        float lon = coordinates.getJSONArray(j).getFloat(0);
        //make new PVector and add to the list for the Polygon
        PVector coordinate = new PVector(lat, lon);
        coords.add(coordinate);
      }
      Polygon poly = new Polygon(coords);
      polygons.add(poly);
    }
    
    if(type.equals("LineString")){
      ArrayList<PVector> coords = new ArrayList<PVector>();
      JSONArray coordinates = geometry.getJSONArray("coordinates");
      for(int j = 0; j < coordinates.size(); j++){
        float lat = coordinates.getJSONArray(j).getFloat(1);
        float lon = coordinates.getJSONArray(j).getFloat(0);
        
        PVector coordinate = new PVector(lat, lon);
        coords.add(coordinate);
      }
      Way way = new Way(coords);
      ways.add(way);
    }
    
  }
}
