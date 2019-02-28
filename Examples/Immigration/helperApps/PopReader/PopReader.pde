/**
 *    read different values from a xls file.
 *
 *    fjenett 20071115
 */

import de.bezier.data.*;

XlsReader reader;

  //Data Locations
  int sheet = 0;
  int firstRow = 29;
  int lastRow = 289;
  int nameColumn = 2;
  int popCol_1950 = 5;
  int popCol_2015 = 70;
  
// Names of Locations for values
ArrayList<String> world, continent, region, nation;

//// Population Values
//Table population;

JSONObject wor;

void setup ()
{  
  int numWorld     = 1;
  int numContinent = 6;
  int numRegion    = 22;
  int numNation    = 233;
  
  int numEntries   = 273;
  
  world =     new ArrayList<String>();
  continent = new ArrayList<String>();
  region =    new ArrayList<String>();
  nation =    new ArrayList<String>();

  reader = new XlsReader( this, "WPP2015_POP_F01_1_TOTAL_POPULATION_BOTH_SEXES.xls" );    // assumes file to be in the data folder
  
  println("Populating World, Continent, Region, and Nation names ...");
  reader.openSheet(10);
  for (int i=0; i<numWorld; i++)     { world.add(     reader.getString( i+1, 0 ) ); println( "world: "     + world.get(i)     ); }
  for (int i=0; i<numContinent; i++) { continent.add( reader.getString( i+1, 1 ) ); println( "continent: " + continent.get(i) ); }
  for (int i=0; i<numRegion; i++)    { region.add(    reader.getString( i+1, 2 ) ); println( "region: "    + region.get(i)    ); }
  for (int i=0; i<numNation; i++)    { nation.add(    reader.getString( i+1, 3 ) ); println( "nation: "    + nation.get(i)    ); }
  
//  population = new Table();
//  population.addColumn("name");
//  population.addColumn("category");
  
  // Initialize JSON Object "WORLD"
  wor = new JSONObject();
  wor.setString("name", world.get(0));
  JSONArray cons = new JSONArray();
  wor.setJSONArray("continents", cons);
  
  reader.openSheet(0);
  println("Loading JSON World Tree ...");
  println("Name of First Entry: " + reader.getString( firstRow, nameColumn ));
  println("Name of Last Entry: " + reader.getString( lastRow, nameColumn ));
  
  int worIndex = 0;
  int conIndex = -1;
  int regIndex = -1;
  int natIndex = -1;
  String current;
  int pop, year;
  
  // Cycles through all of the Containers in the UN Populations Document
  for (int i=firstRow; i<lastRow+1; i++) {
    current = reader.getString(i, nameColumn);
    
    boolean match = false;
    
    // Checks to see if New Continent Container
    for (int c=0; c<continent.size(); c++) {
      if (current.equals( continent.get(c) )) {
        match = true;
        conIndex++;
        regIndex = -1;
        natIndex = -1;
        
        // Adds Entry
        JSONObject con = new JSONObject();
        con.setString("name", current );
        for (int p=popCol_1950; p<popCol_2015+1; p++) {
          pop = reader.getInt(i, p);
          year = 1950 + p - popCol_1950;
          con.setInt("pop" + year, pop);
        }
        JSONArray regs = new JSONArray();
        con.setJSONArray("regions", regs);
        wor.getJSONArray("continents").setJSONObject(conIndex, con);

        break;
      }
    }
    
    // Checks to see if New Region Container
    if (!match) {
      for (int r=0; r<region.size(); r++) {
        if (current.equals( region.get(r) )) {
          match = true;
          regIndex++;
          natIndex = -1;
          
          // Adds Entry
          JSONObject reg = new JSONObject();
          reg.setString("name", current );
          for (int p=popCol_1950; p<popCol_2015+1; p++) {
            pop = reader.getInt(i, p);
            year = 1950 + p - popCol_1950;
            reg.setInt("pop" + year, pop);
          }
          JSONArray nats = new JSONArray();
          reg.setJSONArray("nations", nats);
          wor.getJSONArray("continents").getJSONObject(conIndex).
              getJSONArray("regions").setJSONObject(regIndex, reg);

          break;
          
        }
      }
    }
    
    // Checks to see if New Nation Container
    if (!match) {
      for (int n=0; n<nation.size(); n++) {
        if (current.equals( nation.get(n) )) {
          match = true; 
          
          if (regIndex > -1) {
            
            natIndex++;
            
            // Adds Entry
            JSONObject nat = new JSONObject();
            nat.setString("name", current );
            for (int p=popCol_1950; p<popCol_2015+1; p++) {
              pop = reader.getInt(i, p);
              year = 1950 + p - popCol_1950;
              nat.setInt("pop" + year, pop);
            }
            wor.getJSONArray("continents").getJSONObject(conIndex).
                getJSONArray("regions").getJSONObject(regIndex).
                getJSONArray("nations").setJSONObject(natIndex, nat);
                
          } else {
            
            // Cretes New Region Based Upon Continent Label
            regIndex++;
            natIndex = 0;
            
            // Adds Container One Level Up
            JSONObject reg = new JSONObject();
            reg.setString("name", wor.getJSONArray("continents").getJSONObject(conIndex).getString("name") );
            for (int p=popCol_1950; p<popCol_2015+1; p++) {
              year = 1950 + p - popCol_1950;
              pop = wor.getJSONArray("continents").getJSONObject(conIndex).getInt("pop" + year);
              reg.setFloat("pop" + year, pop);
            }
            JSONArray nats = new JSONArray();
            reg.setJSONArray("nations", nats);
            wor.getJSONArray("continents").getJSONObject(conIndex).
                getJSONArray("regions").setJSONObject(regIndex, reg);
            
            // Adds Entry
            JSONObject nat = new JSONObject();
            nat.setString("name", current );
            for (int p=popCol_1950; p<popCol_2015+1; p++) {
              pop = reader.getInt(i, p);
              year = 1950 + p - popCol_1950;
              nat.setInt("pop" + year, pop);
            }
            wor.getJSONArray("continents").getJSONObject(conIndex).
                getJSONArray("regions").getJSONObject(regIndex).
                getJSONArray("nations").setJSONObject(natIndex, nat);
                
          }
          
          break;
        }
      }
    }
    //println(wor);
    saveJSONObject(wor, "world.json");
  }
  
}

void addPopulations(JSONObject object, XlsReader reader, int i) {
  int pop, year;
  for (int p=popCol_2015; p<popCol_2015+1; p++) {
    pop = reader.getInt(i, p);
    year = 1950 + p - popCol_1950;
    object.setInt("pop" + year, pop);
  }
}
