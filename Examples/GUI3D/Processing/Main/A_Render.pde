/*  GUI3D
 *  Ira Winder, ira@mit.edu, 2018
 *
 *  Render Functions (Superficially Isolated from Main.pde)
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

// Begin Drawing 3D Elements
//
void render3D() {
  
  // Update camera position settings for a number of frames after key updates
  //
  if (cam.moveTimer > 0) {
    cam.moved();
  }
  
  // Draw and Calculate 3D Graphics 
  //
  hint(ENABLE_DEPTH_TEST);
  cam.on();
  
  // ****
  // NOTE: Objects draw earlier in the loop will obstruct 
  // objects drawn afterward (despite alpha value!)
  // ****
  
  // Field: Draw Rectangular plane comprising boundary area 
  //
  fill(255, 50);
  rect(0, 0, B.x, B.y);
  
  // Field: Draw Selection Field
  //
  pushMatrix(); translate(0, 0, 1);
  image(cam.chunkField.img, 0, 0, B.x, B.y);
  popMatrix();
  
  // Arrow-Object: Draw Object to edit with arrow keys
  //
  pushMatrix(); translate(objectLocation.x, objectLocation.y, objectLocation.z + 30/2.0);
  fill(255, 150); noStroke(); strokeWeight(1);
  box(30, 30, 30);
  popMatrix();
  
  if (cam.enableChunks) {
    
    // Click-Object: Draw mouse-based object additions
    //
    if (additions.size() > 0) {
      for (PVector v: additions) {
        pushMatrix(); translate(v.x, v.y, v.z + 15/2.0);
        fill(#00FF00, 200); noStroke();
        box(15, 15, 15);
        popMatrix();
      }
    }
  }
  
  if (cam.enableChunks && placeAdditions && cam.chunkField.closestFound) {
    
    // Place Ghost of Object to Place
    //
    //cam.chunkField.drawCursor();
    pushMatrix(); translate(additionLocation.x, additionLocation.y, additionLocation.z + 15/2.0);
    fill(#00FF00, 100); noStroke();
    box(15, 15, 15);
    popMatrix();
  }
}

// Begin Drawing 2D Elements
//
void render2D() {
  
  hint(DISABLE_DEPTH_TEST);
  cam.off();
  
  // Diameter of Cursor Objects
  //
  float diam = min(225, 5/pow(cam.zoom, 2));
  
  // Arrow-Object: Draw Cursor Ellipse and Text
  //
  noFill(); stroke(#FFFF00, 200);
  ellipse(s_x, s_y, diam, diam);
  fill(#FFFF00, 200); textAlign(LEFT, CENTER);
  text("OBJECT: Move with Arrow Keys", s_x + 0.6*diam, s_y);
  

  // Click-Object: Draw Cursor Text
  //
  if (cam.enableChunks && cam.chunkField.closestFound && placeAdditions && !cam.hoverGUI()) {
    fill(#00FF00, 200); textAlign(LEFT, CENTER);
    text("Click to Place", cursor_x + 0.3*diam, cursor_y);
  }
    
  // Draw Slider Bars for Controlling Zoom and Rotation (2D canvas begins)
  //
  cam.drawControls();
  
  // Draw Margin ToolBar
  //
  bar_left.draw();
  bar_right.draw();
}

PImage loadingBG;
void loadingScreen(PImage bg, int phase, int numPhases, String status) {

  // Place Loading Bar Background
  //
  image(bg, 0, 0, width, height);
  pushMatrix(); 
  translate(width/2, height/2);
  int BAR_WIDTH  = 400;
  int BAR_HEIGHT =  48;
  int BAR_BORDER =  10;

  // Draw Loading Bar Outline
  //
  noStroke(); 
  fill(255, 200);
  rect(-BAR_WIDTH/2, -BAR_HEIGHT/2, BAR_WIDTH, BAR_HEIGHT, BAR_HEIGHT/2);
  noStroke(); 
  fill(0, 200);
  rect(-BAR_WIDTH/2+BAR_BORDER, -BAR_HEIGHT/2+BAR_BORDER, BAR_WIDTH-2*BAR_BORDER, BAR_HEIGHT-2*BAR_BORDER, BAR_HEIGHT/2);

  // Draw Loading Bar Fill
  //
  float percent = float(phase+1)/numPhases;
  noStroke(); 
  fill(255, 150);
  rect(-BAR_WIDTH/2 + BAR_HEIGHT/4, -BAR_HEIGHT/4, percent*(BAR_WIDTH - BAR_HEIGHT/2), BAR_HEIGHT/2, BAR_HEIGHT/4);

  // Draw Loading Bar Text
  //
  textAlign(CENTER, CENTER); 
  fill(255);
  text(status, 0, 0);

  popMatrix();
}
