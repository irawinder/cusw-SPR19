// A Class Representing directional connections between People objects

class Connection {
  Person origin;
  Person destination;
  String type;
  
  Connection (Person a, Person b, String _type) {
    origin = a;
    destination = b;
    type = _type;
  }
  
  // Draw a line between the two people that are connected
  void draw() {
    float x1 = origin.screenLocation.x;
    float y1 = origin.screenLocation.y;
    float x2 = destination.screenLocation.x;
    float y2 = destination.screenLocation.y;
    
    strokeWeight(5); // Line weight of 5 pixels
    if (type.equals("cohort")) {
      stroke(#00CC00, 150); // Transparent Green
    } else {
      stroke(255, 150); // Transparent White
    }
    line(x1, y1, x2, y2);
    
    // Print Edge Type to Canvas
    fill(255); // Solid White
    text(type, (x1+x2)/2 + 20, (y1+y2)/2);
  }
}
