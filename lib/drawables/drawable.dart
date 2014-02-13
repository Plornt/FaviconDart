part of FaviconDart;

class State {
  Map<String, dynamic> state;
  State(this.state) {
    
  }
  
  dynamic get (String key) {
    if (state.containsKey(key)) {
      return state[key];
    }
    return null;
  }
  
  void set(String key, dynamic val) {
    state[key] = val;
  }
  
  void addNum (String key, num amount) {
    if (state.containsKey(key)) {
      if (state[key] is num) {
        state[key] += amount;
      }
    }
    else {
      state[key] = amount;
    }
  }
  
  void merge (State otherState) {
    otherState.state.forEach((String key, dynamic val) { 
      if (val is num) this.addNum(key, val);
      else 
        state[key] = val;
    });
  }
  
  void override (Map <String, dynamic> state) {
    this.state.addAll(state);
  }
    
  State clone () {
    return new State(this.state);
  }
}

class TransitionEvent {
  final int type;
  const TransitionEvent (this.type);
  
  static const TransitionEvent STEP = const TransitionEvent(2);
  static const TransitionEvent STOP = const TransitionEvent(1);
  static const TransitionEvent BEGIN = const TransitionEvent(0);
}

abstract class FaviconElement {
 bool _remove = false;
 List<TransitionItem> _transitionQueue = new List<TransitionItem>();
 TransitionItem _currentQueue = new TransitionItem(new State({}));
 bool _isTransitioning = true;  
 
 State state = new State({
                                         "x": 0.0,
                                         "y": 0.0,
                                         "opacity": 0.0,
                                         "scale": 0.0,
                                         "container_width": 0.0,
                                         "container_height": 0.0
                                       });
 
 Favicon _parent; 
 Favicon get parent => _parent;
 
 
 /* GETTERS AND SETTERS */
 double get x => state.get("x");
 double get y => state.get("y");
 double get opacity => state.get("opacity");
 double get scale => state.get("scale");
 double get width => state.get("container_width");
 double get height => state.get("container_height");
 
 set x (double v) => state.set("x", v);
 set y (double v) => state.set("y", v); 
 set opacity (double v) => state.set("opacity", v);
 set scale (double v) => state.set("scale", v);
 set width (double v) => state.set("container_width", v);
 set height (double v) => state.set("container_height", v);
 
 FaviconElement () {
   
 }
 
 /***
  * 
  */
  TransitionItem transition (Map<String, dynamic> transitionItems, [ bool addToQueue = false ]) {
    if (addToQueue) {
      _currentQueue.toState.override(transitionItems);
      return _currentQueue;
    }
    else {
      TransitionItem insertedTransition = new TransitionItem(new State(transitionItems));
      return insertedTransition;
    }    
  }
 
 /***
  * Takes the current transition queue and plays it.
  */
 TransitionItem play () {
   _transitionQueue.add(_currentQueue);
   this.clearCurrent();
   return _currentQueue;   
 }
 
 /***
  * Inserts the current transition queue to the top of the stack and plays it. 
  */
 TransitionItem insertPlay () {
   if (_transitionQueue.length >= 1) {
    _transitionQueue.insert(0, _currentQueue);
   }
   else {
     _transitionQueue.add(_currentQueue);
   }
   this.clearCurrent();
   return _currentQueue;   
 }
 
 /***
  * Clears the current transition queue
  */
 void clearCurrent () {
   _currentQueue = new TransitionItem(new State({}));
 }
 
 /***
  * Stops and clears any queued transitions
  * 
  * if [endTransitions] is true the queued transitions futures will complete
  */
 void stop ([bool endTransitions = false]) {
   this.clearCurrent();
   if (endTransitions) {
     _transitionQueue.forEach((TransitionItem t) { 
       t.c.complete(this);
     });
   }
   _transitionQueue = new List<TransitionItem>();
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
     // TODO: Process transition
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
 void onTransitionEnd ([ TransitionItem currentFrame ]) {
   
 }
 

 /***
  * Called when the transition queue has been emptied
  */
 void onTransitionQueueEmptied () {
   
 }
 
 
 /***
  * Called when the element has been attached to a Favicon
  */
 void onPushedToFavicon () {
   
 }
 
 /***
  * Called before an animation begins processing
  */
 void onBeforeTransitionStart ([ TransitionItem currentFrame ]) {
   
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
 
}

abstract class FaviconPausable extends FaviconElement {
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