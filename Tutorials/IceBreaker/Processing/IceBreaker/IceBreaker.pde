ArrayList<Person> cusw;
ArrayList<Connection> frands;
ArrayList<Connection> cohort;
ArrayList<Connection> course;

void setup() {
  
  size(800, 700);
  
  // Initialize People from our class
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
  
  cusw = new ArrayList<Person>();
  for (int i=0; i<p.length; i++) {
    cusw.add(p[i]);
  }
  
    // Initialize Other Relationships
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
      if (!peep1.name.equals(peep2.name)) {
        if (peep1.year.equals(peep2.year)) {
          cohort.add(new Connection(peep1, peep2, "cohort"));
        }
      }
    }
  }
  
  // Arrange all of the people in a cute little circle
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
  
  //for (Connection c: cohort) {
  //  c.draw();
  //}
  
  for (Connection c: frands) {
    c.draw();
  }
  
  for (Person p: cusw) {
    p.update();
    p.draw();
  }
  
}

void mousePressed() {
  for (Person p: cusw) {
    if ( p.check() ) {
      break;
    }
  }
}

void mouseReleased() {
  for (Person p: cusw) {
    p.locked = false;
  }
}

void initConnections() {
  
}
