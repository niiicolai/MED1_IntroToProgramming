
Flower[] flowers;

int numberOfFlowers = 10;

int radiusMin = 30;
int radiusMax = 60;

int petalsMin = 7;
int petalsMax = 14;

color backgroundColor = #43AF76;

void setup() {
  size(1200, 800);
  
  flowers = new Flower[numberOfFlowers];
  for (int i = 0; i < numberOfFlowers; i++) {
    flowers[i] = new Flower(random(radiusMin, radiusMax), 
                            (int)random(petalsMin, petalsMax), 
                            random(0, width), 
                            random(0, height),
                            color(random(255), random(255), random(255)));
  }
}

void draw() {
  background(backgroundColor);
  
  for (int i = 0; i < flowers.length; i++) {
    flowers[i].display();
    flowers[i].move();
    flowers[i].boundariesCheck();
  }
}
