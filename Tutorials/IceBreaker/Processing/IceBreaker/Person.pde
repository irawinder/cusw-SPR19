// A class Representing basic properties of a Person

class Person {
  
  String name;
  String year;
  PVector screenLocation;
  
  // true/false statement to track whether person is activated by mouse clicks
  boolean hover;  // Is person being hovered over by mouse?
  boolean locked; // is person selected by mouse?
  
  Person(String _name, String _year) {
    name = _name;
    year = _year;
    screenLocation = new PVector(width/2, height/2);
  }
  
  // Arrange my person some angle theta along a circle
  void circleLocation(float theta) {
    float radius = 0.35*height;
    screenLocation.x = 0.8*width/2 + radius*sin(theta);
    screenLocation.y = height/2 + radius*cos(theta);
  }
  
  // Place my person randomly on the screen
  void randomLocation() {
    float x = random(0.8*width);
    float y = random(height);
    screenLocation = new PVector(x, y);
  }
  
  void draw() {
    noStroke();
    
    // What color is my person?
    if (year.equals("1")) {
      fill(#FF0000); // Red
    } else if (year.equals("2")) {
      fill(#00FF00); // Green
    } else if (year.equals("3")) {
      fill(#0000FF); // Blue
    } else if (year.equals("4")) {
      fill(#FFFF00); // Yellow
    } else if (year.equals("G")) {
      fill(#FF00FF); // Magenta
    } else {
      fill(#00FFFF); // Cyan
    }
    
    // Draws a solid colored Circle Representing my Person
    ellipse(screenLocation.x, screenLocation.y, 30, 30);
    
    // Draws a white outline of a circle on top of my solid color circle
    noFill(); stroke(255); // Solid White; no fill
    strokeWeight(5); // 5 pixels stroke width
    ellipse(screenLocation.x, screenLocation.y, 30, 30);
    
    // Draw Text Information about my person
    fill(255); // Color Text White
    text(name + "\nYear: " + year, screenLocation.x + 25, screenLocation.y - 25);
    
  }
  
  // Is person selected by mouse? 
  // Run this in mousePressed()
  boolean check() {
    
    // Checks if hovering over person
    if ( hoverEvent() ) {
      hover = true;
    } else {
      hover = false;
    }
    
    // "Locks on" to person if so
    if (mousePressed && hover) {
      locked = true;
    } else {
      locked = false;
    }
    
    return locked;
  }
  
  // Update location of person if "locked on" with mouse
  void update() {
    
    if (locked) {
      screenLocation = new PVector(mouseX, mouseY);
    }
    
  }
  
  // Checks to see if mouse is hovering over person
  boolean hoverEvent() {
    if ( abs(mouseX - screenLocation.x) < 15 && abs(mouseY - screenLocation.y) < 15 ) {
      return true;
    } else {
      return false;
    }
  }
  
}
