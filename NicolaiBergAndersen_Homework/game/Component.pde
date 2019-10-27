// COMPONENT CLASS
// Used to define objects with shared functionality for gameobjects
//
// A subclass of the Component class can therefore be any type
// of object which adds shared functionality 
//
// An example could be 
//   - health, colliders, navigation etc.
//
class Component {
  // The gameobject which own this component
  GameObject gameObject;
    
  Component(GameObject _gameObject) {
    // Set the gameobject
    gameObject = _gameObject; 
  }
}

// COLLIDER CLASS < Component
// Used to define colliders which use the position and size of the given
// gameobject for collision calculations
//
class Collider extends Component {

  Collider(GameObject _gameObject) {
    // Execute the parent class' constructor with the required parameters
    super(_gameObject);
  }

  // Returns true if this collider overlaps with the one provided
  boolean overlaps(Collider other) {
    return (
      PVector.dist(gameObject.centerPosition(), other.gameObject.centerPosition()) <= other.gameObject.size.x/1.1 || 
      PVector.dist(gameObject.centerPosition(), other.gameObject.centerPosition()) <= other.gameObject.size.y/1.1
    );
  }
  
  // Check if one of the gameobjects within the provided arraylist
  // overlaps with this collider and 'push' the gameobject away from it
  // to avoid gameobjects with colliders overlapping
  public void overlapAvoidance(ArrayList<GameObject> gameObjects) {
    
    // Loop through all the gameobjects
    for (int i = 0; i < gameObjects.size(); i++) {
      
      // if the current gameobject's collider isn't this collider
      // and it's collider overlap with this one 
      if (gameObjects.get(i).collider != this && overlaps(gameObjects.get(i).collider)) {
        
        // Calculate the direction to the gameobject that's overlapping
        PVector dir = new PVector(gameObjects.get(i).position.x-gameObject.position.x, gameObjects.get(i).position.y-gameObject.position.y);
        
        // normalize the direction
        dir.normalize();
        
        // move this gameobject in the opposite direction
        gameObject.move(new PVector(-dir.x, -dir.y));    
        
        // break out of the loop
        break;
      } 
    }
  }
}

// NAVIGATOR CLASS < Component
// Used to automatically move gameobjects towards a destination
//
// Can be used to move any type of gameobject 
// which require automatic movement
//
// An example could be
//   - enemies, bullets, obstacles etc.
//
class Navigator extends Component { 
  
  // the amount of distance there should be between the gameobject
  // and destination before it stops
  private float stoppingDistance;  
  
  // the navigator's destination
  private PVector destination;  
  
  // wether or not this navigator is moving
  private boolean isMoving;

  Navigator(GameObject _gameObject, float _stoppingDistance) {
    // Execute the parent class' constructor with the required parameters
    super(_gameObject);
    
    // Set stopping distance
    stoppingDistance = _stoppingDistance; 
  }

  // Execute to run navigator behaviour
  // - Keep track of isMoving state
  // - Keep track of movement calculations
  public void update() {
    // if the navigator isMoving and the distance between its gameobject's position
    // and the destination is less or equal to 'stoppingDistance' 
    if (isMoving && PVector.dist(gameObject.position, destination) <= stoppingDistance) {
      // set isMoving state to false
      isMoving = false;
      
    // if the navigator isMoving state isn't activated when the distance between its gameobject's position
    // and the destination is greater than the stopping distance
    } else if (!isMoving && PVector.dist(gameObject.position, destination) > stoppingDistance) {
      // set isMoving state to true
      isMoving = true;
    }

    // if the navigator is moving
    if (isMoving) {
      // calculate direction towards the destination
      PVector dir = new PVector(destination.x-gameObject.position.x, destination.y-gameObject.position.y);
      
      // normalize the direction
      dir.normalize();
      
      // move the gameobject towards the direction
      gameObject.move(dir);
    }
  }
  
  // Execute to set a new destination
  public void setDestination(PVector dest) {
    destination = new PVector(dest.x, dest.y);
  }
}

// HEALTHCONTROLLER CLASS < Component
// Used to add health functionality for gameobjects
//
class HealthController extends Component {
  
  // the component owner's current health
  private float health;
  
  // ...
  private float maxHealth;

  // Wether or not the owner is dead
  public boolean isDead;
  
  // Wether or not the gameobject should respawn
  // when it dies
  private boolean respawnAble;
  
  // ...
  private PVector respawnPosition;  
  
  // Time before respawning
  private float respawnTime;
  
  // variable which count frames
  // used to simulate a timer based on frames
  // instead of actual time
  // Could be replaced with real time calculations such as millis()
  private int frameCounter;
  
  HealthController(float _maxHealth) {
    // Execute the parent class' constructor with a null value
    // This component only need the parent functionality
    // in cases where it need to respawn
    super(null);
    
    // Set max health
    maxHealth = _maxHealth;
    
    // Set the current health to max health
    health =  _maxHealth;
  }
  
  
  // Execute to run health behaviour
  // - Keep track of respawn timer 
  public void update() {
    
    // if this healthCtrl is respawnable and dead    
    if (respawnAble && isDead) {
      
      // increment the frame counter
      frameCounter++;
      
      // if the frame counter is greater or equal to respawn time
      if (frameCounter >= respawnTime) {
        
        // set the frame counter back to zero
        frameCounter = 0;
        
        // Execute the respawn function
        respawn();
      }
    }
  }
  
  // Execute to apply damage to this healthCtrl
  public void applyDamage(float dmg) {
    
    // if this healthCtrl is already dead
    if (isDead) {
      // stop the function at the line below
      return;
    }

    // decrement health by the given damage
    health -= dmg;

    // if health is less or equal to zero
    if (health <= 0) {
      
      dieSound.play();
      
      // set this healthCtrl as 'dead'
      isDead = true;      
      
      if (respawnAble) {
        announcerEndSound.play();
        gameManager.score = 0;
      } else {
        gameManager.score++;
      }
    }
  }
  
  // Execute to make this healthCtrl 'respawnable'
  public void setRespawnAbility(GameObject obj, float time, PVector position) {    
    
    // Set the gameObject owner
    gameObject = obj;
    
    // Set the respawn time
    respawnTime = time;
    
    // Set the respawn position
    respawnPosition = new PVector(position.x, position.y);
    
    // Set this healthCtrl as 'respawnable'
    respawnAble = true;
  }
  
  // Execute to respawn healthCtrl owner
  public void respawn() {
    // 'Teleport' the gameobject to the respawn position
    gameObject.setPosition(respawnPosition);
    
    // Reset the healthCtrl to its initial values
    reset();
  }

  // Execute to reset the healthCtrl to its initial values
  public void reset() {
    health = maxHealth; 
    isDead = false;
  }
}

// WEAPONCONTROLLER CLASS < Component
// Used to add shooting functionality to gameobjects
//
class WeaponController extends Component {
  
  // The gameobject's team
  private int team;  

  // The total number of bullets this gameobject has available
  private int bullets;
  
  // the number of bullets this gameobject started with
  private int startBullets;
  
  // Bullet damage
  private float damage = 10;
  
  // The amount of speed the bullet should move with
  private float bulletSpeed = 5;
  
  // The max number of bullets the weapon's magazin can have
  private int maxMagSize = 20;
  
  // The current number of bullets within the weapon's magazin
  private int currentMagSize = maxMagSize;  

  // Determines if the gameobject can shoot
  private boolean fireCooldown;
  
  // Determines if the gameobject is reloading
  private boolean isReloading;

  // Used to simulate a fire cooldown timer
  private float fireCooldownTimer;
  
  // The amount of time before the gameobject can shoot on fire cooldown
  private float fireRate = 120;
  
  // The number of pixels this gameobject's bullet's can move
  private float fireLength = 100;

  // Used to simulate a reload timer
  private float reloadTimer;
  
  // The amount of time before the gameobject is done reloading
  private float reloadTime = 100;  
  
  // a reference to the bullet pool
  private Pool pool;

  WeaponController(GameObject _gameObject, int _bullets, Pool _bulletPool, int _team) {
    // Execute the parent class' constructor with the required parameters
    super(_gameObject);

    // Set bullets
    bullets = _bullets;    
    
    // Set bullet pool
    pool = _bulletPool;
    
    // Set start bullets
    startBullets = _bullets;

    // Set team
    team = _team;
  }

  // Execute to run weapon controller behaviour
  // - Keep track of automatic reloading
  // - -||- fire cool down timer
  // - -||- reloading timer
  public void update() {
    // if the current number of bullets within the magazin is equal or less than zero
    // and the gameobject have any bullets
    // and the gameobject isn't already reloading
    if (currentMagSize <= 0 && bullets > 0 && !isReloading) {
      // Execute the reload function
      reload();
    }
    
    // ...
    if (fireCooldown) {
      
      // Increment the fire cooldown timer
      fireCooldownTimer++;
      
      // if the fire cooldown timer is equal or greater than 'firerate'
      if (fireCooldownTimer >= fireRate) {
        
        // Reset the timer
        fireCooldownTimer = 0;
        
        // And 'disable fire cooldown'
        fireCooldown = false;
      }
    }

    // ...
    if (isReloading) {
      
      // Increment the reload timer
      reloadTimer++;
      
      // if the reload timer is equal or greater than 'reloadTime'
      if (reloadTimer >= reloadTime) {
        
        // Reset the timer
        reloadTimer = 0;
        
        // Execute finish reload 
        finishReload();
      }
    }
  }

  // Execute to spawn a bullet which moves towards
  // the given destination
  public void shoot(PVector dest) {
    
    // if the gameobject doesn't have any bullets inside its magazin
    // or is on fire cooldown
    // or is reloading
    if (currentMagSize <= 0 || fireCooldown || isReloading) {
      // stop the function below this line
      return;
    }

    // get an inactive bullet instance from the bullet pool
    Bullet bullet = (Bullet)pool.getInactiveObject();
    
    // if there was a bullet available
    if (bullet != null) {
      
      shootSound.play();

      // get the center position of the owner
      PVector pos = gameObject.centerPosition();
      
      // Recalculate destination based on fire length
      float x = (dest.x < pos.x ? -fireLength : fireLength);
      float y = (dest.y < pos.y ? -fireLength : fireLength);
      
      // Declare a new destination combined with the given destination
      PVector _dest = new PVector(dest.x+x, dest.y+y);
      
      // Execute spawn on the bullet to activate it
      bullet.spawn(pos, _dest, damage, bulletSpeed, team, fireLength);

      // Remove a bullet from the magazin
      currentMagSize--;
      
      // Activate fire cooldown
      fireCooldown = true;
    }
  }

  // Execute to start reloading
  public void reload() {
    
    // if the gameobject doesn't have any bullets
    // or already is reloading
    if (bullets <= 0 || isReloading) {
      
      // stop the function below this line
      return;
    }

    // set 'isReloading' state to true
    isReloading = true;
  }

  // Execute to finish reloading which includes 
  // calculating new magazin size and disabling reloading state
  private void finishReload() {
    
    // Calculate the difference between number of bullets within the magazin
    // and how many there can be
    int diff = maxMagSize - currentMagSize;
    
    // if the gameobject have more or exact number of bullets available
    if (bullets >= diff) {
      
      // set the current magazin to its max size
      currentMagSize = maxMagSize;
      
      // remove the difference from the number of bullets available
      bullets -= diff;
      
    // if the gameobject doesn't have more or the same number of bullets available as 
    // the difference needed
    } else {
      
      // add the rest of the bullets available
      currentMagSize += bullets; 
      
      // set the bullets available to zero
      bullets = 0;
    } 

    // set reloading state to false
    isReloading = false;
  }
  
  public void reset() {
    bullets = startBullets;
    currentMagSize = maxMagSize;
    
    isReloading = false;
    fireCooldown = false;
    
    reloadTimer = 0;
    fireCooldownTimer = 0;
  }
}
