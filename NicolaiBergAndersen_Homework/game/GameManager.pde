class GameManager {
  
  // Declare an instance of an InputHandler
  // Which keeps tracks of key presses and releases
  InputHandler inputHandler = 
    new InputHandler();
  
  // A value used to indicate teams
  final int teamOne = 1;
  final int teamTwo = 2;
  
  // The number of items that max should be present
  // within the scene
  final int numberOfItems = 10;  
  
  // The number of bullets an ammo box contains
  final int ammoBoxAmount = 20;
  
  // The size of items spawned
  final PVector itemSize = new PVector(40, 25);
  
  // The path to the item image
  final String itemImagePath = "ammoBox.png";
  
  // An array of items
  Item[] items;
  
  // The number of obstacles that max should be present
  final int numberOfObstacles = 10;
  
  // The path to the obstacle image
  final String obstacleImagePath = "crate.png";
  
  // Obstacles range of size
  final PVector obstacleSizeRange = new PVector(50, 70);
  
  // An array of obstacles
  Obstacle[] obstacles;
  
  // The number of enenmies that max should be present
  final int numberOfEnemies = 5;
  
  final float enemySpawnTime = 100;
  
  // A reference to an enemy spawner
  EnemySpawner enemySpawner;
  
  final float itemSpawnTime = 100;
  
  // A reference to an item spawner
  ItemSpawner itemSpawner;
  
  // The number of bullets that max CAN be present
  final int numberOfBullets = 30;
  
  // The size of bullets
  final PVector bulletSize = new PVector(5, 5);
  
  // A reference to a bullet pool
  // used to get inactive bullets
  Pool bulletPool;
  
  // A list of gameobjects
  // Used for avoidance detection
  ArrayList<GameObject> objectsToAvoid;
  
  // An array of all humanoids
  // This should include all enemies AND the player
  // Used to execute necessary functions
  Humanoid[] humanoids = new Humanoid[numberOfEnemies+1];
  
  // Player settings
  final PVector playerStartPosition = new PVector(100, 100);
  final PVector playerSize = new PVector(35, 60);
  final float playerMaxHealth = 100; 
  final float playerMoveSpeed = 3;  
  final float playerRespawnTime = 100;
  final float playerFireRate = 20;
  final int playerBullets = 100;
  
  // Enemy settings
  final PVector[] enemyStartPositions = new PVector[]{new PVector(width-100, height-100)};
  final PVector enemySize = new PVector(35, 60);
  final float enemyMoveSpeed = 1.5;
  final float enemyStoppingDistance = 130;
  final float enemyMaxHealth = 100;
  final int enemyBullets = 100;
  
  // the path to the background image
  final String backgroundImagePath = "asphalt.jpg";
  
  // Score
  int score;
  
  // A reference to the game's background image
  PImage bggImage;  
  
  public void init() {
    // Load background image
    bggImage = loadImage(backgroundImagePath);
    
    // load amomo box image
    PImage ammoBoxImage = loadImage(itemImagePath);  
    
    // create an instance of an array with the length of 'numberOfItems'
    items = new Item[numberOfItems];
    
    // loop through the array
    for (int i = 0; i < items.length; i++) {  
      
      // get a random position within the window
      PVector randomPos = new PVector(random(0, width), random(0, height));
      
      // create a size
      PVector size = new PVector(itemSize.x, itemSize.y);
      
      // create a new instance of an item and add it to the array
      items[i] = new Item(randomPos, size, ammoBoxImage, ammoBoxAmount);
      
      // set its visual state to true
      items[i].active = true;      
    }
  
    // load crate image
    PImage crateImage = loadImage(obstacleImagePath);
    
    // create an instance of an array with the length of 'numberOfObstacles'
    obstacles = new Obstacle[numberOfObstacles];
    
    // loop through that array
    for (int i = 0; i < numberOfObstacles; i++) {
      
      // create a random size within the obstacle size range
      float _w = random(obstacleSizeRange.x, obstacleSizeRange.y);
      
      // create a random position within the processing display window
      PVector randomPos = new PVector(random(0, width), random(0, height));
      
      // create a size
      PVector size = new PVector (_w, _w);
      
      // create an instance of an obstacle and add it to the array
      obstacles[i] = new Obstacle(randomPos, size, crateImage);
    }
  
    // loop through all obstacles again
    for (int i = 0; i < obstacles.length; i++) {
      
      // run the reposition function to ensure obstacles and items doesn't overlap
      obstacles[i].repositionGameObject(new GameObject[][]{obstacles, items});
    }
  
    // loop through all items again
    for (int i = 0; i < items.length; i++) {
      
      // run the reposition function to ensure obstacles and items doesn't overlap
      items[i].repositionGameObject(new GameObject[][]{obstacles, items});
    }  
  
    // create an instance of an array with the length of 'numberOfBullets'
    Bullet[] bullets = new Bullet[numberOfBullets];
    
    // loop through the array
    for (int i = 0; i < numberOfBullets; i++) {
      
      // create a position and size
      PVector pos = new PVector(0, 0);
      PVector size = new PVector(bulletSize.x, bulletSize.y);
      
      // create an instance of a bullet and add it to the array
      bullets[i] = new Bullet(pos, size, null);
      
      // add a reference to the humanoids array
      bullets[i].humanoids = humanoids;
    }
    
    // create an new instance of a pool with the bullet array
    bulletPool = new Pool(bullets);
    
    // create an instance of an array with the length of '4'
    AnimationState[] animationStates = new AnimationState[4];
  
    // create an instance of an array with the length of '21'
    PImage[] playerIdleImages = new PImage[21];
    
    // loop through that array
    for (int i = 0; i < playerIdleImages.length; i++) {    
      // load all images using a prefix + number + file type
      playerIdleImages[i] = loadImage("000"+(i+1)+".png");
    } 
    
    // create a new instance of an animation state and add it to the array 
    animationStates[0] = new AnimationState("Idle", playerIdleImages, 5, true);
  
    // create an instance of an array with the length of '21'
    PImage[] playerWalkImages = new PImage[21];
    
    // loop through that array
    for (int i = 0; i < playerWalkImages.length; i++) {    
      // load all images using a prefix + number + file type
      playerWalkImages[i] = loadImage("walk"+(i+1)+".png");
    }    
    
    // create a new instance of an animation state and add it to the array 
    animationStates[1] = new AnimationState("Walk", playerWalkImages, 1, true);
  
    // create an instance of an array with the length of '13'
    PImage[] playerHitImages = new PImage[13];
    
    // loop through that array
    for (int i = 0; i < playerHitImages.length; i++) {  
      // load all images using a prefix + number + file type
      playerHitImages[i] = loadImage("shoot"+(i+1)+".png");
    }
    
    // create a new instance of an animation state and add it to the array 
    animationStates[2] = new AnimationState("Shoot", playerHitImages, .2, false);
  
    // create an instance of an array with the length of '21'
    PImage[] playerDieImages = new PImage[21];
    
    // loop through that array
    for (int i = 0; i < playerDieImages.length; i++) {  
      // load all images using a prefix + number + file type
      playerDieImages[i] = loadImage("die"+(i+1)+".png");
    }
    
    // create a new instance of an animation state and add it to the array 
    animationStates[3] = new AnimationState("Die", playerDieImages, 1, false);  
    
    // create an instance of a player
    Player player = new Player(
      playerStartPosition, playerSize, playerMoveSpeed, teamOne, 
      animationStates, playerMaxHealth, playerBullets, bulletPool, inputHandler, items, playerRespawnTime
      );    
      
    // change the default fire rate
    player.weaponCtrl.fireRate = playerFireRate;
    
    // add the player to the last index of the humanoids array
    humanoids[humanoids.length-1] = player;
  
    // create an instance of an array with the length of 'numberOfEnemies'    
    Enemy[] enemies = new Enemy[numberOfEnemies];
    
    // loop through that array
    for (int i = 0; i < numberOfEnemies; i++) {  
      
      // create an instance of an enemy and add it to the enemy array
      enemies[i] = new Enemy(
        enemyStartPositions[0], enemySize, enemyMoveSpeed, teamTwo, 
        animationStates, enemyMaxHealth, enemyBullets, bulletPool, player, enemyStoppingDistance
        );
        
      // set the enemy's visual state to false
      enemies[i].active = false;
      
      // add the enemy to the humanoids array
      humanoids[i] = enemies[i];
    }

    // create an instance of an enemy spawner with the enemies created above
    enemySpawner = new EnemySpawner(enemies, enemyStartPositions, enemySpawnTime);
    
    // create an instance of an item spawner with the items created above
    // - use the enemy start position since it's going to respawn them anyway
    itemSpawner = new ItemSpawner(items, enemyStartPositions, itemSpawnTime, new GameObject[][]{obstacles, items});      
  
    // create an instance of an array list of items to avoid
    objectsToAvoid = new ArrayList<GameObject>();
    
    // loop through all obstacles
    for (int i = 0; i < obstacles.length; i++) {
      
      // add the obstacle to the list
      objectsToAvoid.add(obstacles[i]);
    }
  
    // loop through all humanoids
    for (int i = 0; i < humanoids.length; i++) {
      
      // add the humanoid to the list
      objectsToAvoid.add(humanoids[i]);
    }
  }
  
  // Execute to run the game
  public void run() {
    
    // draw the background image
    image(bggImage, 0, 0, width, height);
    
    // update spawner objects
    enemySpawner.update();
    itemSpawner.update();
    
    // execute display on all items
    for (int i = 0; i < items.length; i++) {
      items[i].display();
    }
  
    // execute display, update, and run avoidance detection
    for (int i = 0; i < humanoids.length; i++) {
      humanoids[i].display();
      humanoids[i].update();
      humanoids[i].collider.overlapAvoidance(objectsToAvoid);
    }
  
    // execute display on all obstacles
    for (int i = 0; i < obstacles.length; i++) {
      obstacles[i].display();
    }
  
    // execute update on all bullets within the bullet pool
    for (int i = 0; i < bulletPool.gameObjects.length; i++) {    
      
      // get a gameobject from the pool and cast it to a Bullet
      Bullet _bullet = (Bullet)bulletPool.gameObjects[i];
      
      // execute update on the bullet object
      _bullet.update();
    }
    
    // draw gameplay user interface
    textAlign(LEFT);
    fill(255);
    textSize(15);
    text("Score: "+score+"\n"+
         "Health: "+humanoids[humanoids.length-1].healthCtrl.health+"\n"+
         "Total bullets: "+humanoids[humanoids.length-1].weaponCtrl.bullets+"\n"+
         "Magazin bullets: "+humanoids[humanoids.length-1].weaponCtrl.currentMagSize+"\n"+
         "Reload timer: "+humanoids[humanoids.length-1].weaponCtrl.reloadTimer, 30, 40);
  }
}
