JSONObject example;
JSONArray features;
JSONObject wholeArea;
//Look at https://processing.org/reference/JSONObject.html for more info

void loadData(){
  background = loadImage("data/background.png");
  background.resize(width, height);
  
  //Whole area
  wholeArea = loadJSONObject("data/wholeArea.geojson");
  features = wholeArea.getJSONArray("features");
  
  //Small example
  //example = loadJSONObject("data/example.json");
  //features = example.getJSONArray("features");
  
  println("There are: ", features.size(), " features");
}

void parseData(){
  for(int i =0; i<features.size(); i++){
      //Identify 3: properties, geometry, and type 
      String type = features.getJSONObject(i).getJSONObject("geometry").getString("type");
      JSONObject geometry = features.getJSONObject(i).getJSONObject("geometry");
      JSONObject properties = features.getJSONObject(i).getJSONObject("properties");
      
      //identify more information! 
      String dataAmenity = properties.getJSONObject("tags").getString("amenity");
      String amenity = "";
      if(dataAmenity != null) amenity = dataAmenity;
      
      //Make POIs! 
      if(type.equals("Point")){
        //create a new POI! 
        float lat = geometry.getJSONArray("coordinates").getFloat(1);
        float lon = geometry.getJSONArray("coordinates").getFloat(0);
        
        POI poi = new POI(lat, lon);
        poi.type = amenity;
        if(amenity.equals("atm"))poi.ATM = true;
        pois.add(poi);
      }
      //Make Polygons! 
      if(type.equals("Polygon")){
        //make a new polgyon! 
        ArrayList<PVector> coords = new ArrayList<PVector>();
        JSONArray coordinates = geometry.getJSONArray("coordinates").getJSONArray(0);
        for(int j = 0; j<coordinates.size(); j++){
            float lat = coordinates.getJSONArray(j).getFloat(1);
            float lon = coordinates.getJSONArray(j).getFloat(0);
            PVector coordinate = new PVector(lat, lon);
            coords.add(coordinate);
        }
        Polygon poly = new Polygon(coords);
        polygons.add(poly);
      }
      
      //Make roads/ways! 
      if(type.equals("LineString")){
        ArrayList<PVector> coords = new ArrayList<PVector>();
        JSONArray coordinates = geometry.getJSONArray("coordinates");
        for(int j =0; j<coordinates.size(); j++){
          float lat = coordinates.getJSONArray(j).getFloat(1);
          float lon = coordinates.getJSONArray(j).getFloat(0);
          //make a pvector
          PVector coordinate = new PVector(lat, lon);
          coords.add(coordinate);
        }
        Way way = new Way(coords);
        ways.add(way);
      }
      
  }
}
