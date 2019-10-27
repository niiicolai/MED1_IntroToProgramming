import processing.sound.*;

String menuBackgroundMusicName = "music_modern_war.wav";
SoundFile menuBackgroundMusic;

String menuClickSoundName = "ui_menu_button_click_12.wav";
SoundFile menuClickSound;

String gameBackgroundMusicName = "background_construction_factory_warehouse_machine_loop_01.wav";
SoundFile gameBackgroundMusic;

String announcerStartSoundName = "announcer_voice_classic_FPS_style_fight.wav";
SoundFile announcerStartSound;

String announcerEndSoundName = "announcer_voice_classic_FPS_style_gameover.wav";
SoundFile announcerEndSound;

String dieSoundName = "voice_male_grunt_pain_death_10.wav";
SoundFile dieSound;

String pickupSoundName = "item_pickup_swipe_01.wav";
SoundFile pickupSound;

String shootSoundName = "gun_pistol_shot_05.wav";
SoundFile shootSound;

GameManager gameManager = new GameManager();

boolean gameStarted;
String mainMenuBggImagePath = "poster.png";
PImage mainMenuBggImage;
PVector mainMenuBggImagePosition = new PVector(0, -50);
float mainMenuBggImageYOffset = 200;
Button startButton;

PFont mainFont;
String mainFontName = "Arial";

void setup () {
  size (700, 600);
  frameRate(60);
  
  menuBackgroundMusic = new SoundFile(this, menuBackgroundMusicName);
  menuClickSound = new SoundFile(this, menuClickSoundName);
  gameBackgroundMusic = new SoundFile(this, gameBackgroundMusicName);
  announcerStartSound = new SoundFile(this, announcerStartSoundName);
  announcerEndSound = new SoundFile(this, announcerEndSoundName);
  dieSound = new SoundFile(this, dieSoundName);
  pickupSound = new SoundFile(this, pickupSoundName);
  shootSound = new SoundFile(this, shootSoundName);
  
  mainFont = createFont(mainFontName, 25);
  mainMenuBggImage = loadImage(mainMenuBggImagePath);
  
  PVector size = new PVector(200, 30);
  startButton = new Button(new PVector(57, height/2+size.y), size, "PLAY", #f77777, #f77777, #ffffff);
  
  menuBackgroundMusic.loop();
  
  gameManager.init();
}

void draw () {
  textFont(mainFont);

  if (!gameStarted) {

    image(mainMenuBggImage, mainMenuBggImagePosition.x, mainMenuBggImagePosition.y, 700, 800);
    
    startButton.display();
    startButton.hover = startButton.mouseWithin();
  
    if (startButton.hover && gameManager.inputHandler.leftMouse) {
      gameStarted = true;
      
      menuClickSound.play();
      menuBackgroundMusic.stop();
      gameBackgroundMusic.loop();
      announcerStartSound.play();
    }
    
    return;
  }
  
  gameManager.run();
}

void mousePressed() {
  if (mouseButton == LEFT) gameManager.inputHandler.leftMouse = true;
}

void mouseReleased() {
  if (mouseButton == LEFT) gameManager.inputHandler.leftMouse = false;
}

void keyPressed() {  
  gameManager.inputHandler.keyPress(key);
}

void keyReleased() {
  gameManager.inputHandler.keyRelease(key);
}
