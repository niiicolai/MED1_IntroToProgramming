// POOL
// Used to cache gameobjects in an array
// and return them if they are inactive
//
class Pool {
  // An array of gameobjects
  public GameObject[] gameObjects;  

  Pool(GameObject[] _gameObjects) {
    
    // Set the gameobjects
    gameObjects = _gameObjects;
  }

  GameObject getInactiveObject() {
    // declare a variable with the type of GameObject
    // with the value of null
    GameObject obj = null;

    // loop through all gameObjects
    for (int i = 0; i < gameObjects.length; i++) {
      
      // if the gameobject is inactive
      if (!gameObjects[i].active) {
        
        // set the variable declared above to the gameobject                
        obj = gameObjects[i];
        
        // break out of the loop
        break;
      }
    }    
    
    // return the gameobject found if any
    return obj;
  }
}

// GAMEOBJECTSPAWNER
// Used to spawn gameobjects cached by a Pool
// and spawn them after an interval of frames
//
class GameObjectSpawner {
  
  // The pool which stores the gameobjects
  private Pool pool;
  
  // the positions where the spawner should spawn the gameobjects
  private PVector[] spawnPositions;  
  
  // the amount of time between gameobject spawning
  private float spawnTime;  
      
  // the last spawned gameobject
  public GameObject lastObj;
  
  // a counter used to simulate time
  private float frameCounter;

  GameObjectSpawner(GameObject[] _gameObjects, PVector[] _spawnPositions, float _spawnTime) {
    
    // set the spawn position
    spawnPositions = _spawnPositions;
    
    // set the spawn time
    spawnTime = _spawnTime;
    
    // create an instance of a pool with the give gameobjects
    pool = new Pool(_gameObjects);    
  }

  // Execute to run game object spawner behaviour
  public void update() {
    
    // increment the frame counter
    frameCounter++;
    
    // if the frame counter is equal or greater than spawn time
    if (frameCounter >= spawnTime) {
      
      // reset the frame counter
      frameCounter = 0;
      
      // spawn a gameobject
      spawn ();
    }
  }
  
  // Execute to spawn an inactive gameobject from the pool
  // and show it at the spawn position
  public void spawn () {
    
    // get an inactive gameobject from the pool
    lastObj = pool.getInactiveObject();
    
    // ensure any gameobjects where available
    if (lastObj != null) {
      
      // set the gameobject's position to the spawn position
      PVector randomPosition = spawnPositions[(int)random(0, spawnPositions.length-1)];
      lastObj.setPosition(randomPosition);
      
      // set the gameobject's active state to 'true'
      lastObj.active = true; 
    }
  }
}

// ENEMYSPAWNER < GameObjectSpawner
// Used to spawn gameobjects cached by a Pool
// and spawn them after an interval of frames
//
class EnemySpawner extends GameObjectSpawner {
  EnemySpawner(GameObject[] _gameObjects, PVector[] _spawnPositions, float _spawnTime) {
    // Execute the parent class' constructor with the required parameters
    super(_gameObjects, _spawnPositions, _spawnTime); 
  }
  
  // Execute to spawn an enemy
  public void spawn () {
    // Execute spawn on the parent class
    super.spawn();
    
    // get the last obj spawned and cast it into a type of Enemy
    Enemy obj = (Enemy)lastObj;
    
    // if the last object was an enemy, reset the enemy's health and weapon ctrl.
    if (obj != null) {
      obj.healthCtrl.reset();
      obj.weaponCtrl.reset();
    }      
  }
}

// ITEMSPAWNER < GameObjectSpawner
// Used to spawn gameobjects cached by a Pool
// and spawn them after an interval of frames
//
class ItemSpawner extends GameObjectSpawner {
  
  // An array of arraries which the spawner should avoid
  // spawning new objects on
  GameObject[][] gameobjectsToAvoid;
  
  ItemSpawner(GameObject[] _gameObjects, PVector[] _spawnPositions, float _spawnTime, GameObject[][] _gameobjectsToAvoid) {
    // Execute the parent class' constructor with the required parameters
    super(_gameObjects, _spawnPositions, _spawnTime);
    
    // set the gameObject which the spawner should avoid
    gameobjectsToAvoid = _gameobjectsToAvoid;
  }
  
  // Execute to spawn an item
  public void spawn () {
    // Execute spawn on the parent class
    super.spawn();
    
    // if the last object isn't null
    if (lastObj != null) {
      // reposition the gameobject to a position where it doesn't overlap with obstacles and items
      lastObj.repositionGameObject(gameobjectsToAvoid);
    }      
  }
}

// INPUTHANDLER
// Used to keep track of keyboard events
//
class InputHandler {
  
  // keyboard checks
  public boolean aPressed;
  public boolean dPressed;
  public boolean wPressed;
  public boolean sPressed;
  public boolean rPressed;
  
  // mouse checks
  public boolean leftMouse;
  
  // key setup
  final int aKey = 97;
  final int dKey = 100;
  final int wKey = 119;
  final int sKey = 115;
  final int rKey = 114;
  
  // Execute to detect key press
  public void keyPress(int value) {
    switch(value) {
      case aKey: 
        aPressed = true;
        break;
      case dKey: 
        dPressed = true;
        break;
      case wKey:
        wPressed = true;
        break;
      case sKey:
        sPressed = true;
        break;
      case rKey:
        rPressed = true;
        break;
    }
  }
  
  // Execute to detect key release
  public void keyRelease(int value) {
    switch(value) {
      case aKey: 
        aPressed = false;
        break;
      case dKey: 
        dPressed = false;
        break;
      case wKey:
        wPressed = false;
        break;
      case sKey:
        sPressed = false;
        break;
      case rKey:
        rPressed = false;
        break;
    }    
  }
  
  // Returns the current position of the mouse as a PVector
  public PVector mouseVector() {
    return new PVector(mouseX, mouseY);
  }
}

// BUTTON CLASS
// Used to define buttons with
//   - Position, size and click detection
//
class Button {
  
  private PVector position;  
  private PVector size;
  
  private String label;
  
  private color strokeColor;  
  private color fillColor;
  private color textColor;
  
  private int _textSize = 17;  
  private float padding = 10;
  
  private color shadowColor = color(0);
  private PVector shadowOffset = new PVector(6, 3);
  
  public boolean hover;
  
  Button(PVector _position, PVector _size, String _label, color _strokeColor, color _fillColor, color _textColor) {
    
    position = new PVector(_position.x, _position.y);
    
    size = new PVector(_size.x+padding, _size.y+padding);
  
    strokeColor = _strokeColor;
  
    fillColor = _fillColor;
  
    textColor = _textColor;
  
    label = _label;
  }
  
  public void display() {    
    
    fill(shadowColor);
    stroke(shadowColor);
    rect(position.x+shadowOffset.x, position.y+shadowOffset.y, size.x, size.y);
    
    stroke((hover ? textColor : strokeColor));
    fill((hover ? textColor : fillColor));
    rect(position.x, position.y, size.x, size.y);
 
    fill((hover ? fillColor : textColor));
    
    textAlign(CENTER);
    textSize(_textSize);
    text(label, position.x+padding/2, position.y+padding, size.x, size.y);
  
  }
  
  public boolean mouseWithin() {
    return (mouseX >= position.x && mouseX <= position.x+size.x &&
            mouseY >= position.y && mouseY <= position.y+size.y);
  }
}
