/* IceBreaker Network Visualization
 * 11.S195 Computational Urban Science Workshop
 * jiw@mit.edu
 *
 * This script allows you define and manipulate a graph representing students in a class.
 */

// List of people in Computational Urban Science Workshop (CUSW)
ArrayList<Person> cusw;

// Connection between Frands (i.e. acquaintences)
ArrayList<Connection> frands;

// Connections between students in the same year or cohort
ArrayList<Connection> cohort;

void setup() {
  
  // Set Screen Size to 800 x 700 pixels
  size(800, 700);
  
  // Initialize array of People from our class
  Person[] p = new Person[28];
  p[0] = new Person("Zhang, Jenny", "1");
  p[1] = new Person("Levenson, Emily", "1");
  p[2] = new Person("Eain, Yun", "1");
  p[3] = new Person("Cong, Cleverina C", "2");
  p[4] = new Person("He, Jude", "2");
  p[5] = new Person("Liu, Emily", "2");
  p[6] = new Person("Hoffman, Meital H", "3");
  p[7] = new Person("Merced Hernandez, Hadrian", "3");
  p[8] = new Person("Vogel, Amy L", "3");
  p[9] = new Person("Langston, Christine M", "4");
  p[10] = new Person("Gong, Zoe P", "4");
  p[11] = new Person("Kohn, Jacob Elias", "G");
  p[12] = new Person("Dev, Jay", "G");
  p[13] = new Person("Nina Lutz", "G");
  p[14] = new Person("Wu, Yue", "G");
  p[15] = new Person("Ira Winder", "FAC");
  p[16] = new Person("Beavery McBeaver Beaver", "Eternally Young");
  p[17] = new Person("Daniel Yu", "3");
  p[18] = new Person("Titus Venverloo", "3");
  p[19] = new Person("Melanie Droogleever Fortuyn", "3");
  p[20] = new Person("Ajara Ceesay", "SPURS");
  p[21] = new Person("Sharlene Chiu", "4");
  p[22] = new Person("Helena Rong", "G");
  p[23] = new Person("Lara Shonkwiler", "2");
  p[24] = new Person("Nanako", "Panasonic");
  p[25] = new Person("Grace", "2");
  p[26] = new Person("Rosanne", "4");
  p[27] = new Person("Eric", "4");
  
  // Add all of these people to an array list of People, cusw
  cusw = new ArrayList<Person>();
  for (int i=0; i<p.length; i++) {
    cusw.add(p[i]);
  }
  
  // Initialize Frands and Acquaintances
  frands = new ArrayList<Connection>();
  frands.add(new Connection(p[15], p[13], "frands"));
  frands.add(new Connection(p[15], p[12], "frands"));
  frands.add(new Connection(p[15], p[6], "frands"));
  frands.add(new Connection(p[15], p[7], "frands"));
  frands.add(new Connection(p[15], p[8], "frands"));
  frands.add(new Connection(p[15], p[18], "frands"));
  frands.add(new Connection(p[15], p[19], "frands"));
  frands.add(new Connection(p[15], p[21], "frands"));
  frands.add(new Connection(p[15], p[11], "frands"));
  frands.add(new Connection(p[15], p[25], "frands"));
  frands.add(new Connection(p[13], p[26], "frands"));
  frands.add(new Connection(p[13], p[10], "frands"));
  frands.add(new Connection(p[13], p[7], "frands"));
  frands.add(new Connection(p[13], p[21], "frands"));
  frands.add(new Connection(p[13], p[19], "frands"));
  frands.add(new Connection(p[13], p[6], "frands"));
  frands.add(new Connection(p[13], p[7], "frands"));
  frands.add(new Connection(p[13], p[18], "frands"));
  frands.add(new Connection(p[8], p[6], "best frands"));
  frands.add(new Connection(p[8], p[9], "frands"));
  frands.add(new Connection(p[18], p[19], "frands"));
  frands.add(new Connection(p[18], p[21], "frands"));
  frands.add(new Connection(p[18], p[21], "frands"));
  frands.add(new Connection(p[27], p[9], "frands"));
  frands.add(new Connection(p[21], p[9], "frands"));
  frands.add(new Connection(p[21], p[19], "frands"));
  frands.add(new Connection(p[10], p[13], "frands"));
  frands.add(new Connection(p[7], p[5], "frands"));
  frands.add(new Connection(p[7], p[25], "frands"));
  frands.add(new Connection(p[22], p[14], "frands"));
  frands.add(new Connection(p[22], p[11], "frands"));
  
  // Initialize Cohort Relationships
  cohort = new ArrayList<Connection>();
  for (Person peep1: cusw) {
    for (Person peep2: cusw) {
      if (!peep1.name.equals(peep2.name)) { // people are not connected to themselves
        if (peep1.year.equals(peep2.year)) { // two people are connected when same 'year'
          cohort.add(new Connection(peep1, peep2, "cohort"));
        }
      }
    }
  }
  
  // Arrange all of the people in a cute little circle on the canvas
  int num_people = cusw.size();
  for (int i=0; i<num_people; i++) {
    Person peep = cusw.get(i);
    float theta = (2*PI*i)/num_people;
    peep.circleLocation(theta);
  }
  
  // Arrange all of the people randomly
  //for (Person peep: cusw) {
  //  peep.randomLocation();
  //}
}

void draw() {
  background(0);
  
  // Draw connections by year
  //for (Connection c: cohort) {
  //  c.draw();
  //}
  
  // Draw Connections by Acquaintenceship
  for (Connection c: frands) {
    c.draw();
  }
  
  // Draw Nodes Representing People
  for (Person p: cusw) {
    p.update();
    p.draw();
  }
  
}

// This function runs whenever a mouse button is pressed down
void mousePressed() {
  // Checks to see if you clicked a person
  for (Person p: cusw) {
    if ( p.check() ) { 
      break;
    }
  }
}

// This function runs whenever a mouse button is released
void mouseReleased() {
  // Unselect all People
  for (Person p: cusw) {
    p.locked = false;
  }
}
