// An array of flowers which will be used
// to loop through all flower objects
Flower[] flowers;

// The number of flowers we want to spawn
int numberOfFlowers = 2;

// The min and max radius for a flower
int radiusMin = 20;
int radiusMax = 50;

// The min and max amount petals a flower can have.
int petalsMin = 7;
int petalsMax = 14;

// The display windows background color
color backgroundColor = #43AF76;

void setup() {
  size(1200, 800);
  
  // Declare an instance of a flower array with the length of 'numberOfFlowers' 
  flowers = new Flower[numberOfFlowers+1];
  
  // Add a flower to the end of the array using the alternative constructor
  flowers[flowers.length-1] = new Flower(width/2, height/2);
  
  // Loop from 0 to 'numberOfFlowers'
  for (int i = 0; i < numberOfFlowers; i++) {
    
    // Declare a random radius
    float radius = random(radiusMin, radiusMax);
    
    // Declare a random number of petals
    int petals = (int)random(petalsMin, petalsMax);
    
    // Declare a random x and y position within the display window
    float x = random(0, width);
    float y = random(0, height);
    
    // Declare a random color using rgb values
    color _color = color(random(255), random(255), random(255));
    
    // Add a flower with the generated parameters to the flower array
    flowers[i] = new Flower(radius, petals, x, y, _color);
  }
}

void draw() {
  // Set the display window's background color
  background(backgroundColor);
  
  // Loop through all flower objects within the flower array
  for (int i = 0; i < flowers.length; i++) {
    // Execute specific functions on each flower object
    flowers[i].display();
    flowers[i].move();
    flowers[i].boundariesCheck();
    
    if (i < flowers.length/2) {
      flowers[i].displayTail1(); 
    } else {
      flowers[i].displayTail2();
    }
  }
}
