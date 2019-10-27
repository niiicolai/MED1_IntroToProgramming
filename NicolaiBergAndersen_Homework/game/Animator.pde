// ANIMATOR
// Used to add a image sequence 'player' to humanoids
// Is also a 'Component' in concept but doesn't 
// derrive from the Component class due to it doesn't need any of its functionalities
//
class Animator {

  // the current animation state
  private AnimationState currentAnimationState;

  // the animation states available for this animator
  public AnimationState[] animationStates;   

  // the current image index
  // used to determine which image to show
  // from the current animation states image sequence
  private int currentImageIndex;  

  // used to simulate a timer
  private float frameCounter;

  // wether or not the current animation has been played once
  public boolean playedIterationOnce;

  Animator(AnimationState[] _animationStates) {

    // set animation states
    animationStates = _animationStates;

    // set the current state to the first state
    setState(animationStates[0].name);
  }

  // Execute to return the current image sequence image
  public PImage animationImage() {
    return currentAnimationState.imageSequence[currentImageIndex];
  }

  // Execute to run the current animation states image sequence
  public void play() {
    
    // stop playing if the animation has played once
    // and it shouldn't loop
    if (playedIterationOnce && !currentAnimationState.loop) {
      return; 
    }

    // increment the frame counter
    frameCounter++;

    // if the frame counter is equal or greater than the current animation state's play speed
    if (frameCounter >= currentAnimationState.playSpeed) {

      // reset the frame counter
      frameCounter = 0;

      // increment the current image index
      currentImageIndex++;

      // if the current image index is equal or greater than the length of the current
      // animation state's image sequence
      if (currentImageIndex >= currentAnimationState.imageSequence.length) {
        
        // track the animation have been played once
        playedIterationOnce = true;
        
        // if the animation should loop
        if (currentAnimationState.loop) {
          // reset the current image index
          currentImageIndex = 0;
        } else {
          currentImageIndex--;
        }
      }
    }
  }

  // Execute to set the current state of the animator
  public void setState(String newStateName) {

    // if the current animation state is not null
    // and the name is equal to the new name
    if (currentAnimationState != null &&
      currentAnimationState.name == newStateName) {

      // stop the function below this line  
      return;
    }

    // reset the current image index
    currentImageIndex = 0;

    // reset the frame counter
    frameCounter = 0;
    
    // reset the iteration tracker
    playedIterationOnce = false;

    // loop through all the animation states
    for (int i = 0; i < animationStates.length; i++) {

      // if the animation state's name is equal to the new name
      if (animationStates[i].name == newStateName) {

        // set the current animation state
        currentAnimationState = animationStates[i];

        // break out of the loop
        break;
      }
    }
  }

  // Execute to get the current animation state's name
  public String getCurrentStateName() {
    return currentAnimationState.name;
  }
}

// ANIMATIONSTATE
// Used to define a sequence of images which 
// can be played using the animator
//
class AnimationState {

  // The animation state's name
  public String name;

  // The image sequence
  public PImage[] imageSequence;

  // The animation play speed
  public float playSpeed;
  
  // Wether or not this state should loop forever
  public boolean loop;

  AnimationState(String _name, PImage[] _imageSequence, float _playSpeed, boolean _loop) {

    // set the name
    name = _name;

    // set the sequence
    imageSequence = _imageSequence;

    // set the play speed
    playSpeed = _playSpeed;
    
    // set loop state
    loop = _loop;
  }
}
