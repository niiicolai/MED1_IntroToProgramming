// GAMEOBJECT CLASS
// Used to define objects with
//   - Position, size, movement speed (and collision if needed)
//
// A subclass of the GameObject class can therefore be any type
// of object which needs to be displayed inside the Processing display window
//
// An example could be 
//   - obstacles, humanoids, bullets and items etc.
//
class GameObject {
  // The gameobject's position
  public PVector position;
  
  // the gameobject's size
  public PVector size;
  
  // used to check if the gameobject is active
  public boolean active;
  
  // the gameobject's movement speed
  public float speed;

  // not required
  public Collider collider;

  GameObject(PVector _position, PVector _size) {
    position = new PVector(_position.x, _position.y);
    size = new PVector(_size.x, _size.y);;
  }  
      
  // moves the gameobject by speed
  public void move(PVector velocity) {
    velocity.mult(speed);
    position.add(velocity);
  }
  
  // set the position of the gameobject to a new PVector
  // to avoid gameObject's sharing the same position object
  public void setPosition(PVector _position) {
    position = new PVector(_position.x, _position.y);
  }
  
  // returns a new instance of the gameobject's position
  public PVector getPosition() {
    return new PVector(position.x, position.y); 
  }
  
  // returns a new instance of the gameobject's center position
  public PVector centerPosition() {
    return new PVector(position.x+(size.x/2), position.y+(size.y/2)); 
  }
  
  // Execute to reposition gameobject at a position
  // where it doesn't overlap with the given gameobjects
  void repositionGameObject(GameObject[][] otherObjects) {
    
    // create a boolean for later use
    boolean overlaps = false;
    
    // loop through all arrays within the 'array of arrays'
    for (int y = 0; y < otherObjects.length; y++) {
      
      // loop through all objects within the current array
      for (int i = 0; i < otherObjects[y].length; i++) {
        
        // if the object's collider isn't this collider
        // and their colliders' overlaps
        if (otherObjects[y][i].collider != collider &&
          otherObjects[y][i].collider.overlaps(collider)) {
          
          // set overlaps to 'true'
          overlaps = true;      
          
          // break out of the array
          break;
        }                
      }
      
      // break out again
      if (overlaps) break;
    }
    
    // if the gameobject overlaps
    if (overlaps) {
      
      // set the position to a new random position within the display window
      setPosition(new PVector(random(80, width-80), random(80, height-80)));
      
      // run the function again to check if it still overlaps
      repositionGameObject(otherObjects); 
    }
  }
}

// OBSTACLE CLASS < GameObject
// Used to define simple obstacles displayed as a rect with
//   - Position, size, stroke color, fill color and collision
//
class Obstacle extends GameObject {
  
  // The image used to display the obstacle
  PImage image;
  
  Obstacle(PVector _position, PVector _size, PImage _image) {
    // Execute the parent class' constructor with the required parameters
    super(_position, _size); 
    
    // set the image
    image = _image;
    
    // Add the collider component
    collider = new Collider(this);
  }
  
  // Execute to display the obstacle
  void display() {
    // Draw the obstacle image
    image(image, position.x, position.y, size.x, size.y); 
  }
}

// ITEM CLASS < GameObject
// Used to define items with
//   - Position, size, display image, item specific parameters and collision
//
class Item extends GameObject {
  
  // Whether or not the item gives bullets
  boolean givesBullets;
  
  // The number of bullets the item gives
  int gives;
  
  // The image used to display the item
  PImage image;
  
  Item(PVector _position, PVector _size, PImage _image, int _gives) {
    // Execute the parent class' constructor with the required parameters
    super(_position, _size); 
    
    // Declare image
    image = _image;
    
    // Declare how many bullet this item gives
    gives = _gives;
    
    // Add the collider component
    collider = new Collider(this);
  }
  
  // Execute to display the item
  void display() {
    // Only show the item if the gameobject is active
    if (active) image(image, position.x, position.y, size.x, size.y);      
  }    
}

// BULLET CLASS < GameObject
// Used to define bullets with
//   - Position, size, damage, fire length, team, collision and navigation
//
class Bullet extends GameObject {

  // The navigator component
  // used for automatic movement
  private Navigator navigator;
  
  // The bullet's start position
  private PVector startPosition;
  
  // The bullet's damage
  private float damage;
  
  // The length the bullet moves before it disapears
  private float fireLength;
  
  // The bullet's team
  // used to check if it did hit an enemy or friendly humanoid
  private int team;
  
  // A color used to change the display window's background color
  // (quick) to simulate a hit effect
  private color hitEffect = #ff5252;
  
  // the circle's fill color
  private color fillColor = color(22);

  // the circle's stroke color
  private color strokeColor = color(22);
  
  // A reference to all 'killable' humanoids
  private Humanoid[] humanoids;

  Bullet(PVector _position, PVector _size, Humanoid[] _humanoids) {
    // Execute the parent class' constructor with the required parameters
    super(_position, _size);
    
    // set the reference to killable humanoids
    humanoids = _humanoids;
    
    // Add the collider component
    collider = new Collider(this);
    
    // Add the navigator component with a stoppingDistance
    float stoppingDistance = 0;
    navigator = new Navigator(this, stoppingDistance);
    
  }
  
  // Execute to spawn a bullet at a position with
  //   - damage, speed, fire length, team and destination
  public void spawn(PVector _position, PVector _dest, float _damage, float _speed, int _team, float _fireLength) {   
    // Cache the bullet's start position for later use
    startPosition = new PVector(_position.x, _position.y);
    
    // Set the bullet's position
    position = new PVector(_position.x, _position.y);
    
    // Set the bullet's damage
    damage = _damage;
    
    // Set the bullet's team
    team = _team;
    
    // Set the bullet's speed
    speed = _speed;
    
    // Set the bullet's fire length
    fireLength = _fireLength;
    
    // Execute the 'setDestination(PVector)' method on the navigator component
    // with the given destination
    navigator.setDestination(_dest);

    // Set the gameobject as 'active'
    active = true;
  }

  // Execute to run bullet behaviour
  // - Draw the bullet's visual
  // - Keep track of length traveled since it 'spawned'
  // - Keep track of collision with humanoids
  // - Update the navigator component
  public void update() {
    // if the gameobject isn't active
    if (!active) {
      // stop the function at the line below
      return;
    }
    
    // if the distance between the bullet's current position and its
    // start position is greater than the given fire length 
    if (PVector.dist(startPosition, position) > fireLength) {
      // disable the bullet
      active = false; 
    }

    // Loop through all humanoid instances
    for (int x = 0; x < humanoids.length; x++) {
      
      // if the humanoid is NOT on the same team
      // is NOT dead and it overlaps with the bullet's collider
      if (team != humanoids[x].team && 
          !humanoids[x].healthCtrl.isDead && collider.overlaps(humanoids[x].collider)) {
            
        // apply damage to the humanoid's health controller component
        humanoids[x].healthCtrl.applyDamage(damage);
        
        // draw a red background for hit effect
        background(hitEffect);
        
        // if the humanoid is dead, disable its gameobject
        if (humanoids[x].healthCtrl.isDead) {          
          humanoids[x].animator.setState("Die");         
        }
        
        // disable the bullet
        active = false;
        
        // break out of the loop to avoid
        // the bullet adding damage to more than one humanoid        
        break;
      }
    }
    
    // Set the bullet's stroke color
    stroke(strokeColor);
    
    // Set the bullet's fill color
    fill(fillColor);
    
    // Draw the bullet as a circle at the current position with size.x as radius 
    circle(position.x, position.y, size.x);    
    
    // Update the navigator component
    navigator.update();
  }
}
