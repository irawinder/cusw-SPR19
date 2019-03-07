// Global Constants and Configuration for Application

int frameCounter = 0;
int popCounter = 0;
int POP_RESET = 10000;

// Frame Delay between each sensor ping
int PING_FREQ = 4*60;

boolean freezeVisitCounter = false;


// Fraction of screen height to use as margin
float MARGIN = 0.03;

// Default color for lines, text, etc
int lnColor = 255;  // (0-255)
// Default background color
int bgColor = 20;    // (0-255)
// Default baseline alpha value
int baseAlpha = 50; // (0-255)
// Default Grass Color
int grassColor = #95AA13;
// Soofa Red
int soofaColor = #de1b17;

// Number to apply to UI transparency
float uiFade = 1.0;  // 0.0 - 1.0
int FADE_TIMER = 300;
int fadeTimer = 300;

// Draw Realistic Ground Map
boolean drawMap = true;

boolean inverted = false;
void invertColors() {
  lnColor = bgColor;
  bgColor = abs(lnColor - 255);
  inverted = !inverted;
}