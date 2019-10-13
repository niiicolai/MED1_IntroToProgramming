class Flower {

  // Variables

  float r;       // radius of the flower petal
  int n_petals;  // number of petals 
  float x;       // x-position of the center of the flower
  float y;       // y-position of the center of the flower
  int petalColor;//hexadecimal number for the color of petals

  // the number of pixels the flower should move
  // each time velocity is applied
  int velocitySpeed = 3;

  // the current x and y velocity
  // both are declared with either a random positive or negative value
  int xVelocity = (random(-5,5) > 0 ? velocitySpeed : -velocitySpeed);
  int yVelocity = (random(-5,5) > 0 ? velocitySpeed : -velocitySpeed);

  Flower(float temp_r, int temp_n_petals, float temp_x, float temp_y, int temp_petalColor) {
    r=temp_r;
    n_petals = temp_n_petals;
    x=temp_x;
    y=temp_y;
    petalColor=temp_petalColor;
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
