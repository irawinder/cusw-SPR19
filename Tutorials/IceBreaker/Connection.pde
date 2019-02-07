class Connection {
  Person origin;
  Person destination;
  String type;
  
  Connection (Person a, Person b, String _type) {
    origin = a;
    destination = b;
    type = _type;
  }
  
  void draw() {
    float x1 = origin.screenLocation.x;
    float y1 = origin.screenLocation.y;
    float x2 = destination.screenLocation.x;
    float y2 = destination.screenLocation.y;
    
    strokeWeight(5);
    if (type.equals("cohort")) {
      stroke(#00CC00, 150);
    } else {
      stroke(255, 150);
    }
    line(x1, y1, x2, y2);
    
    fill(255);
    text(type, (x1+x2)/2 + 20, (y1+y2)/2);
  }
}
