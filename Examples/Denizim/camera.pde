float camRotation;
float MAX_ZOOM;
float MIN_ZOOM;
float CAMX_DEFAULT;
float CAMY_DEFAULT;
float camZoom;
PVector camOffset;

void initCamera() {
  camRotation = 0; // (0 - 2*PI)
  MAX_ZOOM = 0.1;
  MIN_ZOOM = 1.0;
  CAMX_DEFAULT = 0;
  CAMY_DEFAULT = - 0.12 * city.get(cityIndex).boundary.y;
  camZoom = 0.2;
  camOffset = new PVector(CAMX_DEFAULT, CAMY_DEFAULT);
}

// Set Camera Position
void setCamera(PVector boundary) {
  float eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ;
  
  // Camera Position
  eyeX = boundary.x * 0.5;
  //eyeY = (camZoom/MIN_ZOOM - 0.5) * boundary.y;
  eyeY = 0.50 * boundary.y - camZoom * 0.50 * boundary.y;
  eyeZ = boundary.z + pow(camZoom, 4) * 2 * max(boundary.x, boundary.y);
  
  // Point of Camera Focus
  centerX = 0.50 * boundary.x;
  centerY = 0.50 * boundary.y;
  //centerZ = -1.0 * boundary.z;
  centerZ = boundary.z;
  
  // Axes Directionality (Do not change)
  upX =   0;
  upY =   0;
  upZ =  -1;
  
  camera(eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ);
  if (!inverted) {
    lights(); // Default Lighting Condition
  }
}