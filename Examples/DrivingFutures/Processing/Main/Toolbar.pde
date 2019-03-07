/*  TOOLBAR ALGORITHMS
 *  Ira Winder, ira@mit.edu, 2018
 *
 *  input are generalizable for parameterized models. For a generic 
 *  implementation check out the repo at: http://github.com/irawinder/GUI3D
 *  
 *  CLASSES CONTAINED:
 *
 *    Toolbar()       - Toolbar that may implement ControlSlider(), Radio Button(), and TriSlider()
 *    ControlSlider() - A customizable horizontal slider ideal for generic parameritization of integers
 *    Button()        - A customizable button that triggers a one-time action
 *    RadioButton()   - A customizable radio button ideal for generic parameritization of boolean
 *    TriSlider()     - A customizable triable slider that outputs three positive floats that add up to 1.0
 *
 *  MIT LICENSE: Copyright 2018 Ira Winder
 *
 *               Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
 *               and associated documentation files (the "Software"), to deal in the Software without restriction, 
 *               including without limitation the rights to use, copy, modify, merge, publish, distribute, 
 *               sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
 *               furnished to do so, subject to the following conditions:
 *
 *               The above copyright notice and this permission notice shall be included in all copies or 
 *               substantial portions of the Software.
 *
 *               THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT 
 *               NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
 *               NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
 *               DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
 *               OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
  
class Toolbar {
  int barX, barY, barW, barH; // X, Y, Width, and Height of Toolbar on Screen
  int contentW, contentH;     // pixel width and height of toolbar content accounting for margin
  int margin;                 // standard internal pixel buffer distance from edge of canvas
  int CONTROL_H = 35;         // standard vertical pixel distance between control elements
  int controlY;               // vertical position where controls begin
  
  String title, credit, explanation;
  ArrayList<ControlSlider> sliders;
  ArrayList<RadioButton> radios;
  ArrayList<Button> buttons;
  ArrayList<TriSlider> tSliders;
  
  Toolbar(int barX, int barY, int barW, int barH, int margin) {
    this.barX = barX;
    this.barY = barY;
    this.barW = barW;
    this.barH = barH;
    this.margin = margin;
    contentW = barW - 2*margin;
    contentH = barH - 2*margin;
    sliders  = new ArrayList<ControlSlider>();
    buttons  = new ArrayList<Button>();
    radios  = new ArrayList<RadioButton>();
    tSliders = new ArrayList<TriSlider>();
    controlY = 8*CONTROL_H;
  }
  
  void addSlider(String name, String unit, int valMin, int valMax, float DEFAULT_VALUE, float inc, char keyMinus, char keyPlus, boolean keyCommand) {
    float num = sliders.size() + radios.size() + 2*buttons.size() + 6*tSliders.size();
    ControlSlider s;
    s = new ControlSlider();
    s.name = name;
    s.unit = unit;
    s.keyPlus = keyPlus;
    s.keyMinus = keyMinus;
    s.keyCommand = keyCommand;
    s.xpos = barX + margin;
    s.ypos = controlY + int(num*CONTROL_H);
    s.len = contentW - margin;
    s.valMin = valMin;
    s.valMax = valMax;
    s.DEFAULT_VALUE = DEFAULT_VALUE;
    s.value = s.DEFAULT_VALUE;
    s.s_increment = inc;
    sliders.add(s);
  }
  
  void addRadio(String name, int col, boolean DEFAULT_VALUE, char keyToggle, boolean keyCommand) {
    float num = sliders.size() + radios.size() + 2*buttons.size() + 6*tSliders.size();
    RadioButton b;
    b = new RadioButton();
    b.name = name;
    b.keyToggle = keyToggle;
    b.keyCommand = keyCommand;
    b.xpos = barX + margin;
    b.ypos = controlY + int(num*CONTROL_H);
    b.DEFAULT_VALUE = DEFAULT_VALUE;
    b.value = b.DEFAULT_VALUE;
    b.col = col;
    radios.add(b);
  }
  
  void addButton(String name, int col, char keyToggle, boolean keyCommand) {
    float num = sliders.size() + radios.size() + 2*buttons.size() + 6*tSliders.size() - 0.25;
    Button b = new Button();
    b.name = name;
    b.col = col;
    b.keyToggle = keyToggle;
    b.keyCommand = keyCommand;
    b.xpos = barX + margin;
    b.ypos = controlY + int(num*CONTROL_H);
    b.bW = barW - 2*margin;
    b.bH = CONTROL_H;
    buttons.add(b);
  }
  
  void addTriSlider(String name, String name1, int col1, String name2, int col2, String name3, int col3) {
    float num = sliders.size() + radios.size() + 2*buttons.size() + 6*tSliders.size();
    TriSlider t;
    t = new TriSlider();
    t.name = name;
    t.name1 = name1;
    t.col1 = col1;
    t.name2 = name2;
    t.col2 = col2;
    t.name3 = name3;
    t.col3 = col3;
    t.xpos = barX + margin;
    t.ypos = controlY + int(num*CONTROL_H);
    t.corner1.x = barX + 0.50*barW;
    t.corner1.y = controlY + (num+0.70)*CONTROL_H + 16;
    t.corner2.x = barX + 0.33*barW;
    t.corner2.y = controlY + (num+2.90)*CONTROL_H + 16;
    t.corner3.x = barX + 0.67*barW;
    t.corner3.y = controlY + (num+2.90)*CONTROL_H + 16;
    t.avgX = (t.corner1.x+t.corner2.x+t.corner3.x)/3.0;
    t.avgY = (t.corner1.y+t.corner2.y+t.corner3.y)/3.0;
    t.avg = new PVector(t.avgX, t.avgY);
    t.r = t.avg.dist(t.corner1);
    t.pt = new PVector(t.avgX, t.avgY);
    t.calculateValues();
    tSliders.add(t);
  }
  
  void pressed() {
    if (sliders.size()  > 0) for (ControlSlider s: sliders ) s.listen();
    if (radios.size()   > 0) for (RadioButton   b: radios  ) b.listen();
    if (buttons.size()  > 0) for (Button        b: buttons ) b.listen();
    if (tSliders.size() > 0) for (TriSlider     t: tSliders) t.listen();
  }
  
  void released() {
    if (sliders.size()  > 0) for (ControlSlider s: sliders ) s.isDragged = false;
    if (tSliders.size() > 0) for (TriSlider     t: tSliders) t.isDragged = false;
    if (buttons.size()  > 0) for (Button        b: buttons ) b.released();
  }
  
  void restoreDefault() {
    if (sliders.size()  > 0) for (ControlSlider s: sliders ) s.value = s.DEFAULT_VALUE;
    if (radios.size()   > 0) for (RadioButton   b: radios  ) b.value = b.DEFAULT_VALUE;
    if (tSliders.size() > 0) for (TriSlider     t: tSliders) t.useDefault();
  }
  
  // Draw Margin Elements
  //
  void draw() {
    pushMatrix();
    translate(barX, barY);
    
    // Shadow
    pushMatrix(); translate(3, 3);
    noStroke();
    fill(0, 100);
    rect(0, 0, barW, barH, margin);
    popMatrix();
    
    // Canvas
    fill(255, 20);
    noStroke();
    rect(0, 0, barW, barH, margin);
    
    // Canvas Content
    translate(margin, margin);
    textAlign(LEFT, TOP);
    fill(255);
    text(title + credit + explanation, 0, 0, contentW, contentH);
    popMatrix();
    
    // Sliders
    for (ControlSlider s: sliders) {
      s.update();
      s.drawMe();
    }
    
    // Buttons
    for (RadioButton b: radios) b.drawMe();
    for (Button b: buttons)     b.drawMe();
    
    // TriSliders
    for (TriSlider t: tSliders) {
      t.update();
      t.drawMe();
    }
  }
  
  boolean hover() {
    if (mouseX > barX && mouseX < barX + barW && 
        mouseY > barY && mouseY < barY + barH) {
      return true;
    } else {
      return false;
    }
  }
}

class ControlSlider {
  String name;
  String unit;
  int xpos;
  int ypos;
  int len;
  int diameter;
  char keyMinus;
  char keyPlus;
  boolean keyCommand;
  boolean isDragged;
  int valMin;
  int valMax;
  float value;
  float DEFAULT_VALUE = 0;
  float s_increment;
  int col;
  
  ControlSlider() {
    xpos = 0;
    ypos = 0;
    len = 200;
    diameter = 15;
    keyMinus = '-';
    keyPlus = '+';
    keyCommand = true;
    isDragged = false;
    valMin = 0;
    valMax = 0;
    value = 0;
    s_increment = 1;
    col = 255;
  }
  
  void update() {
    if (isDragged) value = (mouseX-xpos)*(valMax-valMin)/len+valMin;
    checkLimit();
    if (value % s_increment < s_increment/2) {
      value = s_increment*int(value/s_increment);
    } else {
      value = s_increment*(1+int(value/s_increment));
    }
  }
  
  void listen() {
    if(mousePressed && hover() ) {
      isDragged = true;
    }
    
    //Keyboard Controls
    if (keyCommand) {
      if ((keyPressed == true) && (key == keyMinus)) {value--;}
      if ((keyPressed == true) && (key == keyPlus))  {value++;}
      checkLimit();
    }
  }
  
  void checkLimit() {
    if(value < valMin) value = valMin;
    if(value > valMax) value = valMax;
  }
  
  boolean hover() {
    if( mouseY > (ypos-diameter/2) && mouseY < (ypos+diameter/2) && 
        mouseX > (xpos-diameter/2) && mouseX < (xpos+len+diameter/2) ) {
      return true;
    } else {
      return false;
    }
  }
  
  void drawMe() {

    // Slider Info
    strokeWeight(1);
    fill(255);
    textAlign(LEFT, BOTTOM);
    String txt = "";
    if (keyCommand) txt += "[" + keyMinus + "," + keyPlus + "] ";
    txt += name;
    text(txt, int(xpos), int(ypos-0.75*diameter) );
    textAlign(LEFT, CENTER);
    text(int(value) + " " + unit,int(xpos+6+len), int(ypos-1) );
    
    // Slider Bar
    fill(100); noStroke();
    rect(xpos,ypos-0.15*diameter,len,0.3*diameter,0.3*diameter);
    // Bar Indentation
    fill(50);
    rect(xpos+3,ypos-1,len-6,0.15*diameter,0.15*diameter);
    // Bar Positive Fill
    fill(150);
    rect(xpos+3,ypos-1,0.5*diameter+(len-1.0*diameter)*(value-valMin)/(valMax-valMin),0.15*diameter,0.15*diameter);
    
    // Slider Circle
    noStroke();
    fill(col, 225);
    if ( hover() ) fill(col, 255);
    ellipse(xpos+0.5*diameter+(len-1.0*diameter)*(value-valMin)/(valMax-valMin),ypos,diameter,diameter);
  }
}

class Button {
  String name;
  int col;
  int xpos;
  int ypos;
  int bW, bH, bevel;
  char keyToggle;
  boolean keyCommand;
  int valMin;
  int valMax;
  boolean trigger;
  boolean pressed;
  boolean enabled;
  
  Button() {
    xpos = 0;
    ypos = 0;
    bW = 100;
    bH = 25;
    keyToggle = ' ';
    keyCommand = true;
    trigger = false;
    pressed = false;
    enabled = true;
    col = 200;
    bevel = 25;
  }
  
  void listen() {
    
    // Mouse Controls
    if( mousePressed && hover() && enabled) {
      pressed = true;
    }
    
    // Keyboard Controls
    if(keyCommand) if ((keyPressed == true) && (key == keyToggle)) {pressed = true;}
  }
  
  void released() {
    if (pressed && enabled) {
      trigger = true;
      pressed = false;
    }
  }
  
  boolean hover() {
    if( mouseY > ypos && mouseY < ypos + bH && 
        mouseX > xpos && mouseX < xpos + bW ) {
      return true;
    } else {
      return false;
    }
  }
  
  void drawMe() {
    
    int shift = 0;
    if (pressed) shift = 3;
    
    // Button Shadow
    //
    fill(50); noStroke();
    rect(xpos+3,ypos+3, bW, bH, bevel);
    
    // Button
    //
    stroke(255, 100); strokeWeight(3);
    if (enabled) {
      int alpha = 200;
      if ( hover() || pressed) alpha = 255;
      fill(col, alpha);
      rect(xpos+shift,ypos+shift, bW, bH, bevel);
    }
    strokeWeight(1);
    
    // Button Info
    //
    textAlign(CENTER, CENTER); fill(255);
    String label = "";
    if (keyCommand) label += "[" + keyToggle + "] ";
    label += name;
    text(label,int(xpos + 0.5*bW)+shift,int(ypos + 0.5*bH)+shift );
  }
}

class RadioButton {
  String name;
  int col;
  int xpos;
  int ypos;
  int diameter;
  char keyToggle;
  boolean keyCommand;
  int valMin;
  int valMax;
  boolean value;
  boolean DEFAULT_VALUE;
  
  RadioButton() {
    xpos = 0;
    ypos = 0;
    diameter = 20;
    keyToggle = ' ';
    keyCommand = true;
    value = false;
    col = 200;
  }
  
  void listen() {
    
    // Mouse Controls
    if( mousePressed && hover() ) {
      value = !value;
    }
    
    // Keyboard Controls
    if (keyCommand) if ((keyPressed == true) && (key == keyToggle)) {value = !value;}
  }
  
  boolean hover() {
    if( mouseY > ypos-diameter && mouseY < ypos && 
        mouseX > xpos          && mouseX < xpos+diameter ) {
      return true;
    } else {
      return false;
    }
  }
  
  void drawMe() {
    
    pushMatrix(); translate(0, -0.5*diameter, 0);
    
    // Button Info
    strokeWeight(1);
    if (value) { fill(255); }
    else       { fill(150); } 
    textAlign(LEFT, CENTER);
    String label = "";
    if (keyCommand) label += "[" + keyToggle + "] ";
    label += name;
    text(label,int(xpos + 1.5*diameter),int(ypos) );
    
    // Button Holder
    noStroke(); fill(50);
    ellipse(xpos+0.5*diameter+1,ypos+1,diameter,diameter);
    fill(100);
    ellipse(xpos+0.5*diameter,ypos,diameter,diameter);
    
    // Button Circle
    noStroke();
    int alpha = 200;
    if ( hover() ) alpha = 255;
    if (value) { fill(col, alpha); } 
    else       { fill( 0 , alpha); } 
    ellipse(xpos+0.5*diameter,ypos,0.7*diameter,0.7*diameter);
    
    popMatrix();
  }
}

// Class that maps a point within a triangle to 3 values that add to 1.0
//
class TriSlider {
  float value1, value2, value3;
  String name, name1, name2, name3;
  int col1, col2, col3;
  int xpos, ypos;
  PVector pt, corner1, corner2, corner3;
  int diameter;
  boolean isDragged;
  float avgX, avgY, r;
  PVector avg;
  
  TriSlider() {
    diameter = 15;
    corner1 = new PVector(0, 0);
    corner2 = new PVector(0, 0);
    corner3 = new PVector(0, 0);
    pt      = new PVector(0, 0);
    xpos = 0;
    ypos = 0;
    isDragged = false;
    // Default
    value1 = 0.1;
    value2 = 0.2;
    value3 = 0.7;
  }
  
  void useDefault() {
    pt = new PVector(avg.x, avg.y);
    calculateValues();
  }
  
  void listen() {
    PVector mouse = new PVector(mouseX, mouseY);
    if (mouse.dist(avg) < r) isDragged = true;
  }
  
  void update() {
    
    // Update Mouse Condition
    if(isDragged || keyPressed) {
      PVector mouse = new PVector(mouseX, mouseY);
      if(mouse.dist(avg) > r && isDragged) {
        PVector ray = new PVector(mouse.x - avg.x, mouse.y - avg.y);
        ray.setMag(r);
        mouse = new PVector(avg.x, avg.y);
        mouse.add(ray);
      }
      if (mousePressed && isDragged) {
        pt.x = mouse.x;
        pt.y = mouse.y;
      }
      calculateValues();
    }
  }
  
  boolean hover() {
    PVector mouse = new PVector(mouseX, mouseY);
    return mouse.dist(avg) < r;
  }
  
  void calculateValues() {
    // Update Values
    float dist1, dist2, dist3;
    float pow = 3;
    float maxDist = 1.60*r;
    if (pt.dist(corner1) > maxDist) {
      dist1 = 0;
    } else {
      dist1 = 1 / pow(pt.dist(corner1) + 0.00001, pow);
    }
    if (pt.dist(corner2) > maxDist) {
      dist2 = 0;
    } else {
      dist2 = 1 / pow(pt.dist(corner2) + 0.00001, pow);
    }
    if (pt.dist(corner3) > maxDist) {
      dist3 = 0;
    } else {
      dist3 = 1 / pow(pt.dist(corner3) + 0.00001, pow);
    }
    float sum = dist1 + dist2 + dist3;
    
    dist1 /= sum;
    dist2 /= sum;
    dist3 /= sum;
    value1 = dist1;
    value2 = dist2;
    value3 = dist3;
  }
  
  void drawMe() {
    // Draw Background Circle + Triangle
    //
    noStroke();
    fill(50, 150);
    ellipse(avg.x+3, avg.y+3, 2*r, 2*r);
    fill(100, 150);
    ellipse(avg.x, avg.y, 2*r, 2*r);
    fill(100);
    beginShape();
    vertex(corner1.x, corner1.y);
    vertex(corner2.x, corner2.y);
    vertex(corner3.x, corner3.y);
    endShape(CLOSE);
    
    // Draw Cursor
    //
    fill(200);
    if( hover() ) fill(255);
    ellipse(pt.x, pt.y, diameter, diameter);
    
    // Draw Element Meta Information
    //
    fill(255);
    textAlign(LEFT, TOP);
    text(name, int(xpos), int(ypos-16) );
    textAlign(CENTER, BOTTOM); fill(col1);
    text(name1, int(avg.x), int(corner1.y) - 24 );
    textAlign(RIGHT,   TOP); fill(col2);
    text(name2, int(corner2.x) - 8, int(corner2.y) + 16 );
    textAlign(LEFT,  TOP); fill(col3);
    text(name3, int(corner3.x) + 8, int(corner3.y) + 16 );
    textAlign(CENTER, BOTTOM);
    fill(col1);
    text(int(100*value1+0.5) + "%", int(corner1.x), int(corner1.y) - 8 );
    textAlign(RIGHT, TOP);
    fill(col2);
    text(int(100*value2+0.5) + "%", int(corner2.x) - 8, int(corner2.y) );
    textAlign(LEFT, TOP);
    fill(col3);
    text(int(100*value3+0.5) + "%", int(corner3.x) + 8, int(corner3.y) );
  }
}
