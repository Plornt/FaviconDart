part of FaviconDart;

class TransitionStateContainer {
  Map<String, dynamic> state;
  Map<String, int> durations = new Map<String, int>();
  TransitionStateContainer(this.state) {
    
  }
  
  dynamic get (String key) {
    if (state.containsKey(key)) {
      return state[key];
    }
    return null;
  }
  
  void setTransitionDuration (String key, int duration) {
    durations[key] = duration;
  }
  
  int getDuration (String key) {
    return durations[key];
  } 
  void set(String key, dynamic val) {
    state[key] = val;
  }
  
  void addNum (String key, num amount) {
//    print("$key => $amount");
    if (state.containsKey(key)) {
      if (state[key] is num) {
        state[key] += amount;
      }
    }
    else {
      state[key] = amount;
    }
  }
  
  void merge (TransitionStateContainer otherState) {
    otherState.state.forEach((String key, dynamic val) { 
      if (val is num) this.addNum(key, val);
      else 
        state[key] = val;
    });
  }
  
  void override (Map <String, dynamic> state) {
    this.state.addAll(state);
  }
    
  TransitionStateContainer clone () {
    Map<String, dynamic> clonedCopy = new Map<String, dynamic>();
    clonedCopy.addAll(this.state);
    return new TransitionStateContainer(clonedCopy);
  }
}

class TransitionEventType {
  final int type;
  const TransitionEventType (this.type);
  
  static const TransitionEventType STEP = const TransitionEventType(2);
  static const TransitionEventType STOP = const TransitionEventType(1);
  static const TransitionEventType BEGIN = const TransitionEventType(0);
}

class TransitionEvent {
  final TransitionEventType type;
  final TransitionItem item;
  TransitionEvent(TransitionEventType this.type, this.item);
}

abstract class FaviconElement {
 bool _remove = false;
 List<TransitionItem> _transitionQueue = new List<TransitionItem>();
 TransitionItem _currentQueue = new TransitionItem(new TransitionStateContainer({}));
 bool _isTransitioning = true;  
 
 TransitionStateContainer state = new TransitionStateContainer({
                                         "x": 0.0,
                                         "y": 0.0,
                                         "opacity": 0.0,
                                         "scale": 0.0,
                                         "container_width": 0.0,
                                         "container_height": 0.0,
                                         "wait": 0.0 
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
  TransitionItem transition (Map<String, dynamic> transitionItems, { int duration: 1000, bool addToQueue: false }) {
    if (addToQueue) {
      _currentQueue.toState.override(transitionItems);
      transitionItems.forEach((String item, nu) {
         _currentQueue.toState.setTransitionDuration(item, duration);
      });
      return _currentQueue;
    }
    else {
      TransitionItem insertedTransition = new TransitionItem(new TransitionStateContainer(transitionItems));
      transitionItems.forEach((String item, nu) {
         insertedTransition.toState.setTransitionDuration(item, duration);
      });
      _transitionQueue.add(insertedTransition);            
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
   _currentQueue = new TransitionItem(new TransitionStateContainer({}));
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
       t._sendEvent(new TransitionEvent(TransitionEventType.STOP, t));
     });
   }
   _transitionQueue = new List<TransitionItem>();
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
     int tLength = _transitionQueue.length;
     if (tLength >= 1) {
       TransitionItem curr = _transitionQueue[0];
       if (curr.isFirstFrame) { 
         curr._sendEvent(new TransitionEvent(TransitionEventType.BEGIN, curr));
         this.onBeforeTransitionStart(curr);
         curr.frameNumber++;
         // Essentially yeild for any updates from the event streams
         // TODO: FIX THIS TO WORK BETTER
         return;
       }
       else if (curr.frameNumber == 1) {
         curr.fromState = this.state.clone();
       }
       Map<String, dynamic> toState = curr.toState.state;
       Map<String, dynamic> fromState = curr.fromState.state;
       int tsL = toState.length;
       Iterable<String> elementKeys = toState.keys;
       if (tsL > 0) {
         for (int x = 0; x < tsL; x++) {
           String tk = elementKeys.elementAt(x); //transition element key
           dynamic val = toState[tk];
           dynamic fromS = fromState[tk];
           bool isComplete = false;
           /* TWEEN NUMBERS */
           if (val is num && fromState.containsKey(tk) && fromS is num) {
             num step = ((val - fromS) / curr.toState.getDuration(tk)) * timeSinceLastFrame;
             
             if ((val > fromS && ((this.state.state[tk] + step) >= val)) || (val < fromS && (this.state.state[tk] + step) <= val)) {
               isComplete = true;
               this.state.set(tk, toState[tk]);
               print(this.state.state[tk]);
             }
             else this.state.addNum(tk, step);
           }
           
           if (isComplete) {
             tsL--;
             x--;
             toState.remove(tk);
           }
         }
         
         curr._sendEvent(new TransitionEvent(TransitionEventType.STEP, curr));
         curr.frameNumber++;
       }
       else {
         _transitionQueue.removeAt(0);
         curr._sendEvent(new TransitionEvent(TransitionEventType.STOP, curr));
         this.onTransitionEnd(curr);
         
       }       
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