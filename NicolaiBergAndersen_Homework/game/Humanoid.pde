// HUMANOID CLASS < GameObject
// Used to define abstract gameobjects with
//   - Position, size, movement speed, team, 
//   - health, weapon controlling, animation and collision
//
class Humanoid extends GameObject {
  // The humanoid's weapon controller
  public WeaponController weaponCtrl;
  
  // The humanoid's health controller
  public HealthController healthCtrl;
  
  // The humanoid's animator (controller)
  public Animator animator;
  
  // The humanoid's team
  // used in damage situations to check for friendly fire
  public int team;
  
  // the humanoid's last position 
  public PVector lastPosition;

  Humanoid(PVector _position, PVector _size, float _speed, int _team, AnimationState[] _animationStates) {
    // Execute the parent class' constructor with the required parameters          
    super(_position, _size);
    
    // set the speed
    speed = _speed;
    
    // set the team
    team = _team;
    
    // cache the current position
    lastPosition = new PVector (position.x, position.y);
    
    // set the animator
    animator = new Animator(_animationStates);

    // Set the collider
    collider = new Collider(this);    
  }

  // Execute to display the humanoid    
  public void display() {

    // Execute play() on the animator in order to play the
    // current animation
    animator.play();

    // Draws an image based on the current animation image
    image(animator.animationImage(), position.x, position.y, 
      size.x, size.y);
  }
  
  // Execute to run humanoid behaviour
  // - Keep track of animation behaviour
  // - Keep track of weapon controller update
  // - Keep track of health controller update
  public void update() {
    animationBehaviour();
    
    if (weaponCtrl != null) {
      weaponCtrl.update(); 
    }
    
    if (healthCtrl != null) {
      healthCtrl.update(); 
    }
  }    
  
  void animationBehaviour() {
    
    boolean isDead = animator.getCurrentStateName() == "Die";
    
    if (healthCtrl != null && !healthCtrl.isDead && isDead) {
      animator.setState("Idle");
    }
        
    if (isDead) {
      return; 
    }
    
    boolean isShooting = animator.getCurrentStateName() == "Shoot";
    
    // set the animation state to idle
    // if the shoot animation is done playing
    if (isShooting && animator.playedIterationOnce) {
          
      animator.setState("Idle");
    }
    
    boolean isIdle = animator.getCurrentStateName() == "Idle";
    boolean isWalking = animator.getCurrentStateName() == "Walk";    
    boolean isMoving = (position.x != lastPosition.x || position.y != lastPosition.y);
    
    if (!isShooting && !isWalking && isMoving) {
      
      animator.setState("Walk"); 
      
    } else if (!isShooting && !isIdle && !isMoving) {

      animator.setState("Idle"); 
    }
    
    lastPosition = new PVector (position.x, position.y);
  }
  
  void shoot(PVector dest) {
    if (weaponCtrl == null) {
      return;
    }
    
    if (!weaponCtrl.fireCooldown &&
        !weaponCtrl.isReloading &&
        weaponCtrl.currentMagSize > 0) {
  
      // activate shoot animation
      animator.setState("Shoot"); 
      
      weaponCtrl.shoot(dest); 
    }
  }
}

// PLAYER CLASS < Humanoid < GameObject
// Used to define players controlled by the InputHandler
// and objects which can collide with 'pick-up' items
//
class Player extends Humanoid {
  
  // A reference to a inputHandler;
  private InputHandler _inputHandler;
  
  // A reference to an array of pickup items;
  private Item[] pickupItems;
  
  Player(PVector _position, PVector _size, float _speed, int _team,
         AnimationState[] _animationStates, float _maxHealth, int _bullets, Pool _bulletPool, InputHandler ih, Item[] _pickupItems, float respawnTime) {
    // Execute the parent class' constructor with the required parameters
    super(_position, _size, _speed, _team, _animationStates);
    
    // Set the input handler reference
    _inputHandler = ih;
    
    // Set the pickup items reference
    pickupItems = _pickupItems;
    
    // Create an instance of a new weaponCtrl
    weaponCtrl = new WeaponController(this, _bullets, _bulletPool, _team);    
    
    // Create an instance of a new healthCtrl
    healthCtrl = new HealthController(_maxHealth);
    
    // Set the health controller as respawn able
    healthCtrl.setRespawnAbility(this, respawnTime, _position);
  }
  
  // Execute to run player behaviour
  // - Keep track of health- and weapon ctrl. update
  // - -||- player movement
  // - -||- shooting and reloading
  // - -||- 'pick-up' item collision
  //
  // Requires and input handler and an array of items (can be empty)
  public void update() {    
    // Execute update on the parent class
    super.update();
    
    // if the player's is dead
    if (healthCtrl.isDead) {                  
      // stop the function below this line
      return;
    }
    
    // if the left mouse is clicked
    if (_inputHandler.leftMouse) {
      
      // shoot towards the cursor direction
      shoot(_inputHandler.mouseVector()); 
    }
    
    // if the r key is pressed
    if (_inputHandler.rPressed) {
      
      // start reloading
       weaponCtrl.reload();
    }

    // create temp. velocity with the value of zero
    PVector velocity = new PVector(0, 0);
    
    // check if one of the movement key is pressed and apply velocity in the respective direction    
    if (_inputHandler.aPressed) velocity.x--; // LEFT       
    else if (_inputHandler.dPressed) velocity.x++; // RIGHT 
    else if (_inputHandler.wPressed) velocity.y--; // UP
    else if (_inputHandler.sPressed) velocity.y++; // DOWN
    
    // move the humanoid in the wanted direction
    move(velocity);
    
    // loop through all 'pick-up' items
    for (int i = 0; i < pickupItems.length; i++) {
      
      // if the player collides with an active item
      if (pickupItems[i].active && collider.overlaps(pickupItems[i].collider)) {
        
        pickupSound.play();
        
        // give the player bullets
        weaponCtrl.bullets += pickupItems[i].gives;
        
        // disable the item
        pickupItems[i].active = false;
      }
    }
  }
}

// ENEMY CLASS < Humanoid < GameObject
// Used to define gameobjects which follows a target
// and attack it as long both participants are alive
//
class Enemy extends Humanoid {
  
  // The enemy's navigator
  private Navigator navigator;
  
  // The enemy's target
  private Humanoid target;
  
  // tint color used to manipulate enemy image
  color tintColor = #ff4040;
  
  Enemy(PVector _position, PVector _size, float _speed, int _team, AnimationState[] _animationStates,
         float _maxHealth, int _bullets, Pool _bulletPool, Humanoid _target, float stoppingDist) {
    // Execute the parent class' constructor with the required parameters   
    super(_position, _size, _speed, _team, _animationStates);

    // set the target
    target = _target;

    // create an instance of a health ctrl.
    healthCtrl = new HealthController(_maxHealth);    
    
    // create an instance of a weapon ctrl.
    weaponCtrl = new WeaponController(this, _bullets, _bulletPool, _team);      
    
    // create an instance of a navigator
    navigator = new Navigator(this, stoppingDist);
  }
  
  // Execute to display the enemy  
  public void display() {
    
    // if the enemy is active
    if (active) {
      
      // Set tint color
      tint(tintColor);
      
      // execute the parent's display function
      super.display();
      
      // remove tint to avoid other objects being affected
      noTint();
    } 
  }
  
  // Execute to run enemy behaviour
  public void update() {
    // Execute the parent's update function
    super.update();        
    
    // if the target is dead
    // or this enemy is dead
    // or this enemy is inactive
    if (target.healthCtrl.isDead || 
        healthCtrl.isDead ||
        !active) {
          
        // disable the enemy when the die animation is done playing
        if (active && animator.getCurrentStateName() == "Die" &&
          animator.playedIterationOnce) {            
          active = false;
        }
      
      // stop this function below this line
      return; 
    }         
    
    // set the navigator destination to the target's position
    navigator.setDestination(target.position);        
    
    // execute update on the navigator
    navigator.update();
    
    // if this enemy is within the navigator's stopping distance from the target
    if (PVector.dist(position, target.position) <= navigator.stoppingDistance) {
      
      // shoot a bullet at the target's position
      shoot(target.centerPosition());
    }
  }
}
