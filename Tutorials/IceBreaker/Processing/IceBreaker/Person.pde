class Person {
  
  String name;
  String year;
  String course;
  PVector screenLocation;
  
  boolean hover;
  boolean locked;
  
  Person(String _name, String _year) {
    name = _name;
    year = _year;
    screenLocation = new PVector(width/2, height/2);
    course = "";
  }
  
  Person(String _name, String _year, String _course) {
    name = _name;
    year = _year;
    screenLocation = new PVector(width/2, height/2);
    course = _course;
  }
  
  // Arrange my person some angle theta along a circle
  void circleLocation(float theta) {
    float radius = 0.35*height;
    screenLocation.x = 0.8*width/2 + radius*sin(theta);
    screenLocation.y = height/2 + radius*cos(theta);
  }
  
  void randomLocation() {
    float x = random(0.8*width);
    float y = random(height);
    screenLocation = new PVector(x, y);
  }
  
  void draw() {
    noStroke();
    
    // What color is my person?
    if (year.equals("1")) {
      fill(#FF0000);
    } else if (year.equals("2")) {
      fill(#00FF00);
    } else if (year.equals("3")) {
      fill(#0000FF);
    } else if (year.equals("4")) {
      fill(#FFFF00);
    } else if (year.equals("G")) {
      fill(#FF00FF);
    } else {
      fill(#00FFFF);
    }
    
    // Draws a Circle Representing my Person
    ellipse(screenLocation.x, screenLocation.y, 30, 30);
    noFill();
    stroke(255);
    strokeWeight(5);
    ellipse(screenLocation.x, screenLocation.y, 30, 30);
    
    // Draw Text Information about my person
    fill(255); // Color Text White
    text(name + "\nYear: " + year, screenLocation.x + 25, screenLocation.y - 25);
    
  }
  
  boolean check() {
    if ( hoverEvent() ) {
      hover = true;
    } else {
      hover = false;
    }
    
    if (mousePressed && hover) {
      locked = true;
    } else {
      locked = false;
    }
    
    return locked;
  }
  
  void update() {
    
    //if ( hoverEvent() ) {
    //  hover = true;
    //} else {
    //  hover = false;
    //}
    
    //if (mousePressed && hover) {
    //  locked = true;
    //} else {
    //  locked = false;
    //}
    
    if (locked) {
      screenLocation = new PVector(mouseX, mouseY);
    }
    
  }
  
  boolean hoverEvent() {
    if ( abs(mouseX - screenLocation.x) < 15 && abs(mouseY - screenLocation.y) < 15 ) {
      return true;
    } else {
      return false;
    }
  }
  
}
