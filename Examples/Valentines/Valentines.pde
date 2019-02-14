float x, y;
float heartWidth, heartHeight, heartOffset;
float direction;
int minSize, maxSize;
void setup(){
    size(600, 600); 
    heartWidth = 200;
    heartHeight = 60;
    heartOffset = 10;
    
    y = 0;
    x = width/2;
    direction = 1;
    
    minSize = 200;
    maxSize = 350;
}

void draw(){
    colorMode(HSB);
    color new_color = color(frameCount%360, 255, 255);
    background(new_color);
    
   // colorMode(RGB);
    noStroke();
    fill(255);
   
    //Am I growing or shrinking the heart?
    if(heartWidth < 200 || heartWidth > 350){
        direction*=-1;
    }
    
    //Actual heart growth
    heartWidth+= .4*direction;
    heartHeight+=.2*direction;
    heartOffset-=.05*direction;
    
    //Drawing a heart!
    translate(x - heartWidth, y + heartHeight);
    beginShape();
    vertex(heartWidth , heartHeight);
    bezierVertex(heartWidth, -heartOffset, heartWidth*2, heartOffset, heartWidth , heartWidth-heartOffset);
    vertex(heartWidth , heartHeight);
    bezierVertex(heartWidth , -heartOffset, 0, heartOffset, heartWidth , heartWidth-heartOffset);
    endShape();
}
