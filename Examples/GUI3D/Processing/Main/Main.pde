/*  GUI3D ALGORITHMS
 *  Ira Winder, ira@mit.edu, 2018
 *
 *  These script demonstrates the implementation of a Camera() and Toolbar() 
 *  classes that has ready-made UI, Sliders, Radio Buttons, I/O, and smooth camera 
 *  transitions. For a generic implementation check out the repo at: 
 *  http://github.com/irawinder/GUI3D
 *
 *  CLASSES CONTAINED:
 *
 *    Camera()     - The primary container for implementing and editing Camera parameters
 *    HScollbar()  - A horizontal Slider bar
 *    VScrollBar() - A Vertical Slider Bar
 *    XYDrag()     - A Container for implmenting click-and-drag 3D Navigation
 *    Chunk()      - A known, fixed volume of space
 *    ChunkGrid()  - A grid of Chunks in 3D space that are accessible via the mouse cursor
 *
 *    Toolbar()       - Toolbar that may implement ControlSlider(), Radio Button(), and TriSlider()
 *    ControlSlider() - A customizable horizontal slider ideal for generic parameritization of integers
 *    Button()        - A customizable button that triggers a one-time action
 *    RadioButton()   - A customizable radio button ideal for generic parameritization of boolean
 *    TriSlider()     - A customizable triangle slider that outputs three positive floats that add up to 1.0
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

public void settings() {
  size(1280, 800, P3D);
  //fullScreen(P3D);
}

// Runs once when application begins
//
void setup() {
  
}

// Runs on a infinite loop after setup
//
void draw() {
  if (!initialized) {
    
    // A_Init.pde - runs until initialized = true
    // Unlike setup(), allows display of animated loading screen
    //
    init();
    
  } else {
    
    // A_Listen.pde - Updates settings and values for this frame
    //
    if (showGUI) listen();
    
    // A_Render.pde - Renders current frame of visualization
    //
    background(0);
    render3D();
    if (showGUI) render2D();
  }
}
