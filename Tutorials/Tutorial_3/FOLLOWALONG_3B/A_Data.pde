Table CountyBoundary;
Table CensusData;
Table CensusBlocks;


void loadData(){
  CountyBoundary = loadTable("data/FloridaNodes.csv", "header");
  CensusBlocks = loadTable("data/CensusNodes.csv", "header");
  CensusData = loadTable("data/CensusAttrs.csv", "header");
  println("Data Loaded");
}

void parseData(){
}
