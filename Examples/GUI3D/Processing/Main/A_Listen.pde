/*  GUI3D
 *  Ira Winder, ira@mit.edu, 2018
 *
 *  Listen Functions (Superficially Isolated from Main.pde)
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

// Function that update in-memory elements
//
void listen() {
  
  // screenX() and screenY() methods need 3D camera active
  //
  cam.on();
  
  // Arrow-Object: Calculate Object's Screen Location
  //
  s_x = screenX(objectLocation.x, objectLocation.y, objectLocation.z + 30/2.0);
  s_y = screenY(objectLocation.x, objectLocation.y, objectLocation.z + 30/2.0);
  
  // Click-Object: Draw Selection Cursor
  //
  cursor_x = -1000;
  cursor_y = -1000;
  additionLocation = new PVector(0,0);
  if (cam.enableChunks && cam.chunkField.closestFound && placeAdditions && !cam.hoverGUI()) {
    Chunk c = cam.chunkField.closest;
    additionLocation = c.location;
    // Calculate Curson Screen Location
    cursor_x = screenX(additionLocation.x, additionLocation.y, additionLocation.z + 30/2.0);
    cursor_y = screenY(additionLocation.x, additionLocation.y, additionLocation.z + 30/2.0);
  }
  
  // Trigger the button
  //
  if (bar_right.buttons.get(0).trigger) {
    println("Button Pressed");
    bar_right.buttons.get(0).trigger = false;
  }
}

void mousePressed() { if (initialized) {
  
  cam.pressed();
  bar_left.pressed();
  bar_right.pressed();
  
} }

void mouseClicked() { if (initialized) {
  
  if (cam.chunkField.closestFound && cam.enableChunks && !cam.hoverGUI()) {
    additions.add(cam.chunkField.closest.location);
  }
  
} }

void mouseReleased() { if (initialized) {
  
  bar_left.released();
  bar_right.released();
  cam.moved();
  
} }

void mouseMoved() { if (initialized) {
  
  cam.moved();
  
} }

void keyPressed() { if (initialized) {
    
  cam.moved();
  bar_left.pressed();
  bar_right.pressed();
  
  switch(key) {
    case 'f':
      cam.showFrameRate = !cam.showFrameRate;
      break;
    case 'c':
      cam.reset();
      break;
    case 'r':
      additions.clear();
      bar_left.restoreDefault();
      bar_right.restoreDefault();
      break;
    case 'h':
      showGUI = !showGUI;
      break;
    case 'p':
      println("cam.offset.x = " + cam.offset.x);
      println("cam.offset.x = " + cam.offset.x);
      println("cam.zoom = "     + cam.zoom);
      println("cam.rotation = " + cam.rotation);
      break;
    case 'a':
      placeAdditions = !placeAdditions;
      break;
    case '-':
      objectLocation.z -= 20;
      break;
    case '+':
      objectLocation.z += 20;
      break;
  }
  
  if (key == CODED) {
    if (keyCode == UP) {
      objectLocation.y -= 20;
    } else if (keyCode == DOWN) {
      objectLocation.y += 20;
    } else if (keyCode == LEFT) {
      objectLocation.x -= 20;
    } else if (keyCode == RIGHT) {
      objectLocation.x += 20;
    } 
  }
  
} }

void keyReleased() { if (initialized) {
    
    bar_left.released();
    bar_right.released();
  
} }
