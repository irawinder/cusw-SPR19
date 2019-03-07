AV_System sys;

void setup() {
  size(1000, 500);
  sys = new AV_System(1000, 2010, 2030);
  
  sys.demand_growth = 0.05;
  
  sys.av_share = 0.9;
  sys.av_growth = 1.0;
  sys.av_peak_hype_year = 2022;
  
  sys.rideShare_share = 0.8;
  sys.rideShare_growth = 1.0;
  sys.rideShare_peak_hype_year = 2016;
  
  sys.update();
}

void draw() {
  background(0);
  sys.plot();
}

class AV_System {
  int tripDemand_0;
  int year_0, year_f, intervals; // initial and final years
  float demand_growth; // yearly growth for trip demand (exponential growth)
  
  float rideShare_share; // % trips using Ride Share at Equilibrium
  float rideShare_growth; // Pace of Adoption (k-value of logistic eq.)
  int rideShare_peak_hype_year; // Year of peak adoption
  
  float av_share; // % trips using Autonomous Vehicle at Equilibrium
  float av_growth; // Pace of Adoption (k-value of logistic eq.)
  int av_peak_hype_year; // Year of peak adoption
  
  /* 4 Car Types:
   *
   *                Human Driver              Autonomous Vehicle
   *
   *  Private       1. [Private, Driver]      3. [Private, AV]
   *
   *   Shared       2. [Shared,  Driver]      4. [Shared,  AV]
   */
   
  // Number of Vehicles of Each Type for array of N years
  int[] numCar1, numCar2, numCar3, numCar4, totalCars;
  
  // Number of Trips Demanded for array of N years
  int[] tripDemand;
   
  // Number of trips served per vehicle of each type
  float TRIPS_PER_CAR1 = 1.0;
  float TRIPS_PER_CAR2 = 4.0;
  float TRIPS_PER_CAR3 = 1.0;
  float TRIPS_PER_CAR4 = 5.0;
   
  // Number of parking Spaces needed per vehicle of each type
  float SPACES_PER_CAR1 = 1.00;
  float SPACES_PER_CAR2 = 0.50;
  float SPACES_PER_CAR3 = 0.75;
  float SPACES_PER_CAR4 = 0.25;
   
   AV_System(int tripDemand_0, int year_0, int year_f) {
     this.tripDemand_0 = tripDemand_0;
     this.year_0 = year_0;
     this.year_f = year_f;
     intervals = year_f - year_0;
     
     numCar1    = new int[intervals];
     numCar2    = new int[intervals];
     numCar3    = new int[intervals];
     numCar4    = new int[intervals];
     totalCars  = new int[intervals];
     tripDemand = new int[intervals];
   }
   
   void update() {
     float av_s, rs_s; // Instantaneous share of AV and RideShare
     
     // Update Vehicle Counts
     for (int i=0; i<intervals; i++) {
       av_s = logistic(av_share,        av_growth,        year_0 + i, av_peak_hype_year);
       rs_s = logistic(rideShare_share, rideShare_growth, year_0 + i, rideShare_peak_hype_year);
       
       tripDemand[i] = int(tripDemand_0 * pow(1 + demand_growth, i));
       numCar1[i] = int( tripDemand[i] * (1 - av_s) * (1 - rs_s) );
       numCar2[i] = int( tripDemand[i] * (0 + av_s) * (1 - rs_s) );
       numCar3[i] = int( tripDemand[i] * (1 - av_s) * (0 + rs_s) );
       numCar4[i] = int( tripDemand[i] * (0 + av_s) * (0 + rs_s) );
       
       numCar1[i] /= TRIPS_PER_CAR1;
       numCar2[i] /= TRIPS_PER_CAR2;
       numCar3[i] /= TRIPS_PER_CAR3;
       numCar4[i] /= TRIPS_PER_CAR4;
       
       totalCars[i] = numCar1[i] + numCar2[i] + numCar3[i] + numCar4[i];
     }
   }
   
   float logistic(float L, float k, float x, float x_0) {
     return L / (1 + exp( -k*(x - x_0) ));
   }
   
   void plot() {
     for (int i=1; i<intervals; i++) {
       
       float xpos1 = (i-1)*float(width)/intervals;
       float xpos2 = (i)  *float(width)/intervals;
       
       stroke(#FF0000);
       line( xpos1, height - 0.2*tripDemand[i-1], xpos2, height - 0.2*tripDemand[i] );
       
       stroke(#00FF00);
       line( xpos1, height - 0.2*numCar1[i-1], xpos2, height - 0.2*numCar1[i] );
       
       stroke(#0000FF);
       line( xpos1, height - 0.2*numCar2[i-1], xpos2, height - 0.2*numCar2[i] );
       
       stroke(#00FFFF);
       line( xpos1, height - 0.2*numCar3[i-1], xpos2, height - 0.2*numCar3[i] );
       
       stroke(#FFFF00);
       line( xpos1, height - 0.2*numCar4[i-1], xpos2, height - 0.2*numCar4[i] );
       
       stroke(#FFFFFF);
       line( xpos1, height - 0.2*totalCars[i-1], xpos2, height - 0.2*totalCars[i] );
     }
   }
   
}