# GUI3D Template
Generic implementation of classes for displaying, navigating, and manipulating a 3D Simulation in Processing 3

## How To Use
1. Make sure you have installed the latest version of [Java](https://www.java.com/verify/)
2. Download [Processing 3](https://processing.org/download/)
3. Clone or download the repository to your computer
4. Open and run "Processing/GUI3D/GUI3D.pde" with Processing 3

![alt text](/screenshots/GUI3D.png "GUI3D")

## 
Classes Contained

    Camera()     - The primary container for implementing and editing Camera parameters
    HScollbar()  - A horizontal Slider bar
    VScrollBar() - A Vertical Slider Bar
    XYDrag()     - A Container for implmenting click-and-drag 3D Navigation
    Chunk()      - A known, fixed volume of space
    ChunkGrid()  - A grid of Chunks in 3D space that are accessible via the mouse cursor
    
    Toolbar()       - Toolbar that may implement ControlSlider(), Radio Button(), and TriSlider()
    ControlSlider() - A customizable horizontal slider ideal for generic parameritization of integers
    RadioButton()   - A customizable radio button ideal for generic parameritization of boolean
    TriSlider()     - A customizable triable slider that outputs three positive floats that add up to 1.0
