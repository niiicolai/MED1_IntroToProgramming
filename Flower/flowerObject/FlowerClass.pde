class Flower {

  // Variables

  float r = 40;       // radius of the flower petal
  int n_petals = 5;  // number of petals 
  float x;       // x-position of the center of the flower
  float y;       // y-position of the center of the flower
  int petalColor = #898989;//hexadecimal number for the color of petals

  // the number of pixels the flower should move
  // each time velocity is applied
  int velocitySpeed = 3;

  // the current x and y velocity
  // both are declared with either a random positive or negative value
  int xVelocity = (random(-5, 5) > 0 ? velocitySpeed : -velocitySpeed);
  int yVelocity = (random(-5, 5) > 0 ? velocitySpeed : -velocitySpeed);

  // The max number of tail elements which can be instantiated
  int maxTailElements = 80;

  // The position of each tail element saved as a PVector object
  PVector[] tailPositions = new PVector[maxTailElements];

  // Used to keep track of the current iteration of tail elements,
  // used in the second approach of applying a tail to the flower.
  int tailIndex = 0;

  Flower(float temp_r, int temp_n_petals, float temp_x, float temp_y, int temp_petalColor) {
    r=temp_r;
    n_petals = temp_n_petals;
    x=temp_x;
    y=temp_y;
    petalColor=temp_petalColor;
  }

  Flower(float temp_x, float temp_y) {
    x=temp_x;
    y=temp_y;
  }

  public void displayTail1() {
    // loop through the tail positions array from behind
    for (int i = tailPositions.length-1; i > 0; i--) {

      // move the current iteration one iteration up
      tailPositions[i] = tailPositions[i-1];
    }

    // cache the current position to the first iteration of the array
    tailPositions[0] = new PVector(x, y);

    // loop through all tail positions
    for (int i = tailPositions.length-1; i > 0; i--) {
      color c = color(random(255), random(255), random(255), tailPositions.length-i);
      drawTailElement(i, c, (tailPositions.length+i) / 3);
    }
  }

  // More efficient technique ~ https://processing.org/tutorials/arrays/
  public void displayTail2() {
    // cache the current position to the array element at the position
    // matching the value of tail index
    tailPositions[tailIndex] = new PVector(x, y);    

    // increment tailindex with 1 and then
    // use the modulo operator to get the remainder
    tailIndex = (tailIndex+1) % tailPositions.length;

    for (int i = 0; i < tailPositions.length; i++) {             
      int pos = (tailIndex + i) % tailPositions.length;
      color c = color(random(255), random(255), random(255));      
      drawTailElement(pos, c, ((tailPositions.length-i)/2));      
    }
  }

  void drawTailElement(int i, color c, float _r) {
    // if the current iteration doesn't have a value of 'null'
    if (tailPositions[i] != null) {        
      // draw a circle      
      stroke(c);
      fill(c);
      circle(tailPositions[i].x, tailPositions[i].y, _r);
    }
  }

  public void display () {      
    float ballX;
    float ballY;

    fill(petalColor);
    for (float i=0; i<PI*2; i+=2*PI/n_petals) {
      //  ballX=width/2 + r*cos(i);
      //  ballY=height/2 + r*sin(i);
      ballX=x + r*cos(i);
      ballY=y + r*sin(i);
      ellipse(ballX, ballY, r, r);
    }
    fill(200, 0, 0);
    ellipse(x, y, r*1.2, r*1.2);
  }

  // Moves the flower based on the given amount of velocity
  // on both x and y axis. Be aware that the velocity
  // can be both a negative and a positive value,
  // this means if we 'plus' the negative velocity
  // with either x or y it will actually subtract
  // the velocity from the specific axis value
  public void move() {
    x += xVelocity;
    y += yVelocity;
  }

  // Inverts the current velocity if the x or y position
  // of the flower is out of display boundaries.
  public void boundariesCheck() {

    // if the x position is equal or less than zero
    // it sets velocity on x axis to a positive value
    if (x <= 0) {
      xVelocity = velocitySpeed;

      // OR if the x position is greater or equal to 'width'
      // it sets velocity on x axis to a negative value
    } else if (x >= width) {
      xVelocity = -velocitySpeed;
    }

    // this part does the same as described above for velocity
    // on x axis, just for velocity on y axis instead.
    if (y <= 0) {
      yVelocity = velocitySpeed;
    } else if (y >= height) {
      yVelocity = -velocitySpeed;
    }
  }
}
