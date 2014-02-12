part of FaviconDart;

abstract class FaviconDrawable {
 bool _remove = false;
 List<FaviconFrame> _animationQueue = new List<FaviconFrame>();
 FaviconFrame _currentQueue = new FaviconFrame();
 bool _isTransitioning = false; 
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
   this._isTransitioning = true;
   Completer c = _currentQueue.c;
   _animationQueue.add(_currentQueue);
   this.clearCurrent();
   return c.future;   
 }
 
 /***
  * Inserts the current animation queue to the top of the stack and plays it. 
  */
 Future<FaviconDrawable> insertAndPlay () {
   this._isTransitioning = true;
   Completer c = _currentQueue.c;
   _animationQueue.insert(0, _currentQueue);
   this.clearCurrent();
   return c.future;   
 }
 
 /***
  * Cleares the current animation queue
  */
 void clearCurrent () {
   _currentQueue = new FaviconFrame();
 }
 
 /***
  * Stops and clears any queued animations
  */
 void stop () {
   this._isTransitioning = false;
   this.clearCurrent();
   _animationQueue = new List<FaviconFrame>();
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
     if (_animationQueue.length > 0) {
       FaviconFrame currentAnimationQueue = _animationQueue[0];
       int animLength = currentAnimationQueue.transitions.length;
       if (animLength > 0) {
         bool allComplete = true;
         if (currentAnimationQueue.transitions[0].isFirstFrame) this.onBeforeAnimationQueueBegin();
         for (int animX = 0; animX < animLength; animX++) {
           FavicoTween currentAnimation = currentAnimationQueue.transitions[animX];
           bool isComplete = FaviconDrawable._transitions[currentAnimation.animationName](this, timeSinceLastFrame, currentAnimation.parameters, currentAnimation);
           
           currentAnimation.frameNumber++;
           currentAnimation.duration += timeSinceLastFrame;
           if (isComplete) {
             currentAnimation.c.complete(this);
             currentAnimationQueue.transitions.removeAt(animX);
             animX--;
             animLength--;
           }
           else allComplete = false;
         }
         
         if (allComplete) {
           this._isTransitioning = false;
           this.onAnimationQueueEnd();
           currentAnimationQueue.c.complete(this);
           _animationQueue.removeAt(0);
         }
       }
       else {
         _animationQueue.removeAt(0);
         // Reinvoke the update method
         this._onUpdate(timeSinceLastFrame);
         // Leave this one so it doesnt update twice...
         return;
       }
     }
     else {
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
 void onAnimationQueueEnd () {
   
 }
 
 /***
  * Called when the element has been attached to a Favicon
  */
 void onPushedToFavicon () {
   
 }
 
 /***
  * Called before an animation begins processing
  */
 void onBeforeAnimationQueueBegin () {
   
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
       var fIQI = new FavicoTween(invoke.memberName, invoke.positionalArguments);
       _currentQueue.add(fIQI);
      return fIQI.c.future;
     }
   }
   super.noSuchMethod(invoke);
 }
 
}

class FaviconPausable extends FaviconDrawable {
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