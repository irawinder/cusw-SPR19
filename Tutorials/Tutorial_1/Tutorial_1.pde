// Step 1: Create / Allocate Memory for your Person
ArrayList<Person> people;
ArrayList<Connection> frands;

// Runs Once
void setup() {
  size(600, 600);
  initialize();
}

// Runs Over and Over at 60 - FPS
void draw() {
  
  background(0); // Black Background
  //background(255); White Background
  
  //fill(255);
  //ellipse(mouseX, mouseY, 50, 10*mouseY/100); 
  
  // Draw People
  for (Person p: people) {
    p.update(); // updates location IF selected
    p.drawPerson();
  }
  
  // Draw Connections
  for (Connection c: frands) {
    c.draw();
  }
  
}

void mousePressed() {
  
  //background(#FF0000, 100);
  
  for (Person p: people) {
    if(p.checkSelection()) {
      break;
    } // ONLY SELECTS ONE PERSON WHEN MOUSE IS CLICKED
  }
}

void mouseReleased() {
  for (Person p: people) {
    p.locked = false;
  }
}

void keyPressed() {
  initialize();
}

void initialize() {
  people = new ArrayList<Person>();
  frands = new ArrayList<Connection>();
  
  for (int i=0; i<100; i++) { 
    Person p = new Person("Person " + i, str(int(random(1, 10))));
    p.randomLocation();
    people.add(p);
  }
  
  // Who are frands?
  for (Person origin: people) {
    for (Person destination: people) {
      // Is person referencing themself?
      if (!origin.name.equals(destination.name)) {
        // Are Origin and Dest same year?
        if (origin.year.equals(destination.year)) {
          frands.add(new Connection(origin, destination, "frands"));
        }
      }
    }
  }
  
  println(frands.size());
}
