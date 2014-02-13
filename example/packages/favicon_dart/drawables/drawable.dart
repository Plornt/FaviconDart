part of FaviconDart;

abstract class FaviconDrawable {
 bool _remove = false;
 
 List<FaviconFrame> _transitionQueue = new List<FaviconFrame>();
 FaviconFrame _currentQueue = new FaviconFrame();
 bool _isTransitioning = true; 
 
 num x = 0;
 num y = 0;
 num scale = 1;
 num opacity = 1;
 
 num width = 0;
 num height = 0;
 num get scaledWidth => width * scale;
 num get scaledHeight => height * scale;
 
 
 num targetX = 0;
 num targetY = 0;
 num targetScale = 1;
 num targetOpacity = 1;
 
 Favicon _parent;
 
 Favicon get parent => _parent;
 
 FaviconDrawable () {
   
 }
 
 /***
  * Takes the current animation queue and plays it.
  */
 Future<FaviconDrawable> play () {
   Completer c = _currentQueue.c;
   _transitionQueue.add(_currentQueue);
   this.clearCurrent();
   return c.future;   
 }
 
 /***
  * Inserts the current animation queue to the top of the stack and plays it. 
  */
 Future<FaviconDrawable> insertPlay () {
   Completer c = _currentQueue.c;
   print("Inserted current queue");
   if (_transitionQueue.length >= 1) {
     print("Insert!");
    _transitionQueue.insert(0, _currentQueue);
   }
   else {
     print("Added");
     _transitionQueue.add(_currentQueue);
   }
   this.clearCurrent();
   return c.future;   
 }
 
 /***
  * Clears the current animation queue
  */
 void clearCurrent () {
   _currentQueue = new FaviconFrame();
 }
 
 /***
  * Stops and clears any queued animations
  */
 void stop () {
   this.clearCurrent();
   _transitionQueue = new List<FaviconFrame>();
   onStop();
 }
 
 
 /***
  * Pauses animation queue
  */
 void pauseTransition () {
   _isTransitioning = false;
   onPauseTransition();
 }
 
 /***
  * Resumes the animation queue
  */
 void resumeTransition () {
   _isTransitioning = true;
   onResumeTransition();
 }
 
 /***
  * Marks the element to be destroyed and removed from the parent Favicon.
  */
 void destroy () {
   this._remove = true;
   onDestroy();
 }
 
 /***
  * Called by the parent Favicon before the frame draws to the screen.
  */
 void _onUpdate (double timeSinceLastFrame) {
   if (_isTransitioning) { 
     // Transition is not paused:
     if (_transitionQueue.length > 0) {
        FaviconFrame currentFrame = _transitionQueue[0]; 
        if (currentFrame.isFirstFrame) this.onBeforeAnimationQueueBegin(currentFrame);
        currentFrame.frameNumber++;
        int transitionsLength = currentFrame.transitions.length;
        if (transitionsLength > 0) {
          for (int x = 0; x < transitionsLength; x++) {
            FaviconTween currentTransition = currentFrame.transitions[x];
            print(currentTransition.animationName);
            currentTransition.duration += timeSinceLastFrame;
            bool isComp = FaviconDrawable._transitions[currentTransition.animationName](this, timeSinceLastFrame, currentTransition.parameters, currentTransition);
            currentTransition.frameNumber++;
            if (isComp) {
              currentFrame.transitions.removeAt(x);
              currentTransition.c.complete(this);
              x--;
              transitionsLength--;
            }
          }
        }
        else {
          _transitionQueue.removeAt(0);
          currentFrame.c.complete(this);
          // No transitions in frame
          this.onAnimationQueueEnd(currentFrame);
        }
     }
     else {
       // No transitions in drawable
       this.onAnimationQueueEnd();
     }
   }
   
   this.onUpdate(timeSinceLastFrame);
 }
 
 /***
  * Called when the element has been marked for destruction
  */
 void onDestroy () {
   
 }
 
 /*** 
  * Called when the transition has been paused
  */
 void onPauseTransition () {
   
 }
 
 /***
  * Called when the transition has been resumed
  */
 void onResumeTransition () {
   
 }
 
 /*** 
  * Called when the transition has been stopped
  */
 void onStop() {
   
 }
 
 /***
  * Called when the animation queue has finished
  */
 void onAnimationQueueEnd ([ FaviconFrame currentFrame ]) {
   
 }
 
 /***
  * Called when the element has been attached to a Favicon
  */
 void onPushedToFavicon () {
   
 }
 
 /***
  * Called before an animation begins processing
  */
 void onBeforeAnimationQueueBegin ([ FaviconFrame currentFrame ]) {
   
 }
 
 /***
  * Called after transitions have finished processing the updated positions and before
  * the element has been drawn
  */
 void onUpdate (double timeSinceLastFrame) {
  
 }
 
 /***
  * Called when the element has finished updating and requires a redraw
  */
 void onDraw (CanvasRenderingContext2D ctx) {
   
 }
 
 //***** Transition loading and registration
 static Map<Symbol, FaviconTransition> _transitions = new Map<Symbol, FaviconTransition> ();
 
 /***
  * Registers a new transitions
  * [name] is the Symbol representation of the method name to be used
  * 
  * [transition] is the [FaviconTransition] called whenever the transition
  * is used
  */
 static bool registerTransition (Symbol name, FaviconTransition transition) {
   if (!FaviconDrawable._transitions.containsKey(name)) { 
     FaviconDrawable._transitions[name] = transition;
     return true;
   }
   return false;
 }
 
 static bool _initialized = false;
 
 static void _init () {
   if (!_initialized) {
     // Load default transitions
     _loadWaitTransitions();
     _loadSlideTransitions();
     _loadFadeTransitions();
   }
 }
 
 // Handler which handles the action to be taken whenever a transition is called on the element
 noSuchMethod (Invocation invoke) {
   if (invoke.isMethod){
     if (FaviconDrawable._transitions.containsKey(invoke.memberName)) {
       var fIQI = new FaviconTween(invoke.memberName, invoke.positionalArguments);
       _currentQueue.add(fIQI);
      return fIQI.c.future;
     }
   }
   super.noSuchMethod(invoke);
 }
 
}

abstract class FaviconPausable extends FaviconDrawable {
  bool isPaused = false;
  /// Pauses the current visual
  void pause() {
    isPaused = true;
  }
  /// Resumes the current visual
  void resume() {
    isPaused = false;
  }
}