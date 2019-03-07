// Classes that contains our urban sensor simulation
ArrayList<Field> city;
int cityIndex = 0;

// A running graph of Summary Information
RunningGraph visitors;

// Soofa Loga
PImage logo;

void initFields() {
  
  city = new ArrayList<Field>();
  Field f;
  PImage img;
  
  // Mills Park (PaganFest)
  img = loadImage("0/millspark_1000ft.png");
  f = new Field(1000, 1000, 50, img); // (ft, ft, ft)
  city.add(f);
  
  // Las Cruces
  // TBA  
    
  // 30 Rockefeller Center
  // TBA
  
  logo = loadImage("soofa_logo.png");
}

class RunningGraph {
  ArrayList<Float[]> summary; 
  ArrayList<String> label;
  int intervals;
  int x, y;
  float w, h;
  float BAR_GAP = 2;
  float barW;
  float MAX_VALUE = 500;
  int[] FILL;
  int leaderIndex = 0;
  
  RunningGraph(int intervals, float w, float h) {
    summary = new ArrayList<Float[]>();
    label = new ArrayList<String>();
    this.intervals = intervals;
    this.w = w;
    this.h = h;
    
    barW = (w - BAR_GAP)/intervals - BAR_GAP;

    //  [0] - Total Pop
    //  [1] - Total Detections
    //  [2] - Returning Visitors
    FILL = new color[3];
    FILL[0] = color(#999999); // White
    FILL[1] = color(150, 255,  255); // Blue
    FILL[2] = color(100, 255,  255); // Green
  }
  
  void addReading(Float[] reading) {
    if (summary.size() == intervals) {
      summary.remove(0);
      label.remove(0);
    }
    summary.add(reading);
    label.add("" + (leaderIndex+1));
    
    if (leaderIndex == intervals-1) {
      leaderIndex = 0;
    } else {
      leaderIndex++;
    }
    
    // Check Max Value
    for (int i=0; i<reading.length; i++) {
      if (reading[i] > MAX_VALUE) {
        MAX_VALUE = reading[i];
      }
    }
  }
  
  void updateMax(float max) {
    MAX_VALUE = max;
  }
  
  void display() {
    float beaconFade = sq(1 - float(frameCounter) / PING_FREQ);
    
    float barX, barY, barH;
    int count = intervals;
    
    for (int i=0; i<intervals; i++) {
      barX = i*(BAR_GAP+barW);
      barH = h;
      barY = h - barH;
      fill(bgColor);
      stroke(lnColor, baseAlpha);
      rect(barX, barY, barW, h, 5);
    }
    
    for (int i=summary.size()-1; i>=0; i--) {
      count--;
      Float[] reading = summary.get(i);
      for (int j=0; j<reading.length; j++) {
        barX = count*(BAR_GAP+barW);
        barH = reading[j] * h/MAX_VALUE;
        barY = h - barH;
        if (j < 3) fill(FILL[j]);
        noStroke();
        rect(barX, barY, barW, barH, 5);
        fill(lnColor);
        textAlign(CENTER, TOP);
        text(label.get(i), barX + barW/2, h + BAR_GAP);
        if (i == summary.size()-1) {
          fill(255, beaconFade*255);
          rect(barX, barY, barW, barH, 5);
          fill(lnColor);
          stroke(lnColor);
          line(w - 2*BAR_GAP - barW, barY, w+4, barY);
          textAlign(LEFT, CENTER);
          text(int(reading[j]) + " ppl", w + 10, barY);
        }
      }
    }
    fill(lnColor);
  }
}