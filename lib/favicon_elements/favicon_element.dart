part of FaviconDart;

abstract class FaviconElement {
 bool _remove = false;
 List<TweenItem> _transitionQueue = new List<TweenItem>();
 TweenItem _currentQueue = new TweenItem(new TweenStateContainer({}));
 bool _isTransitioning = true;  
 
 TweenStateContainer state = new TweenStateContainer({
                                         "x": 0.0,
                                         "y": 0.0,
                                         "opacity": 0.0,
                                         "scale": 1.0,
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
 
  TweenItem transition (Map<String, dynamic> transitionItems, { int duration: 1000, bool addToQueue: false }) {
    if (addToQueue) {
      _currentQueue.toState.override(transitionItems);
      transitionItems.forEach((String item, nu) {
         _currentQueue.toState.setTransitionDuration(item, duration);
      });
      return _currentQueue;
    }
    else {
      TweenItem insertedTransition = new TweenItem(new TweenStateContainer(transitionItems));
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
 TweenItem play () {
   _transitionQueue.add(_currentQueue);
   this.clearCurrent();
   return _currentQueue;   
 }
 
 /***
  * Inserts the current transition queue to the top of the stack and plays it. 
  */
 TweenItem insertPlay () {
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
   _currentQueue = new TweenItem(new TweenStateContainer({}));
 }
 
 /***
  * Stops and clears any queued transitions
  * 
  * if [endTransitions] is true the queued transitions futures will complete
  */
 void stop ([bool endTransitions = false]) {
   this.clearCurrent();
   if (endTransitions) {
     _transitionQueue.forEach((TweenItem t) { 
       t._sendEvent(new TweenEvent(TweenEventType.STOP, t));
     });
   }
   _transitionQueue = new List<TweenItem>();
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
       TweenItem curr = _transitionQueue[0];
       if (curr.isFirstFrame) { 
         curr._sendEvent(new TweenEvent(TweenEventType.BEGIN, curr));
         this.onBeforeTransitionStart(curr);
         curr.frameNumber++;
         // Essentially yeild for any updates from the event streams
         // Need to do this before v1 as this loses 33ms :/
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
             }
             else this.state.addNum(tk, step);
           }
           if (isComplete) {
             tsL--;
             x--;
             toState.remove(tk);
           }
         }
         
         curr._sendEvent(new TweenEvent(TweenEventType.STEP, curr));
         curr.frameNumber++;
       }
       else {
         _transitionQueue.removeAt(0);
         curr._sendEvent(new TweenEvent(TweenEventType.STOP, curr));
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
 void onTransitionEnd ([ TweenItem currentFrame ]) {
   
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
 void onBeforeTransitionStart ([ TweenItem currentFrame ]) {
   
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
 
 /***
  * Fades in an element
  * [startInstantly] starts the transition straight after this is called
  * [queue] adds the transition to the queue ready to be [play()]'d
  * [initialOpacity] sets the opacity the animation should start at.
  */
 TweenItem fadeIn ({ int duration: 500, bool startInstantly: false, bool queue: false, double initialOpacity: 0.0 }) {
   if (startInstantly) this.stop();
   return this.transition({ "opacity": 1.0 }, duration: duration, addToQueue: queue)..listen((t) { 
     if (t.type == TweenEventType.BEGIN) {
       if (initialOpacity != null) this.opacity = initialOpacity;
     }
   });
 }
 
 /***
  * Fades out an element
  * [startInstantly] starts the transition straight after this is called
  * [queue] adds the transition to the queue ready to be [play()]'d
  */
 TweenItem fadeOut ({ int duration: 500, bool startInstantly: false, bool queue: false}) {
   if (startInstantly) this.stop();
   return this.transition({ "opacity": 0.0 }, duration: duration, addToQueue: queue);
 }
 
 TweenItem slideIn (String direction, { int duration: 500, bool startInstantly: false, bool queue: false, Map startState: null }) {
   bool adjustStartState = false;
   if (startState == null) {
    adjustStartState = true;
    startState = {};
  }
   Map end;
   switch (direction.toLowerCase()) {
     case "up":
       end = { "y": 0.0 };
       if (adjustStartState) startState = { "y": this.parent.size.toDouble() };
       break;
     case "down":
       end = { "y": 0.0 };
       if (adjustStartState) startState = { "y": -this.parent.size.toDouble() };
       break;
     case "left":
       end = { "x": 0.0 };

       if (adjustStartState) startState = { "x": this.parent.size.toDouble() };
       break;
     case "right":
       end = { "x": 0.0 };

       if (adjustStartState) startState = { "x": -this.parent.size.toDouble() };
       break;
     default:
       throw new ArgumentError("Unknown direction $direction - valid options: up, down, left, right.");
       break;
   } 
   if (startInstantly) this.stop();
   return this.transition(end, duration: duration, addToQueue: queue)..listen((t) { 
     if (t.type == TweenEventType.BEGIN) {
       this.state.override(startState);
     }
   });
 }
 
 TweenItem slideOut (String direction, { int duration: 500, bool startInstantly: false, bool queue: false, Map startState: const { "x": 0.0, "y": 0.0 } }) {
   Map end;
   switch (direction.toLowerCase()) {
     case "up":
       end = { "y": this.parent.size.toDouble() };
       break;
     case "down":
       end = { "y": -this.parent.size.toDouble() };
       break;
     case "left":
       end = { "x": this.parent.size.toDouble() };
       break;
     case "right":
       end = { "x": -this.parent.size.toDouble() };
       break;
     default:
       throw new ArgumentError("Unknown direction $direction - valid options: up, down, left, right.");
       break;
   } 
   if (startInstantly) this.stop();
   return this.transition(end, duration: duration, addToQueue: queue)..listen((t) { 
     if (t.type == TweenEventType.BEGIN) {
       this.state.override(startState);
     }
   });
 }
 
 TweenItem wait ({ int duration: 500, bool startInstantly: false, bool queue: false }) {
   if (startInstantly) this.stop();
   return this.transition({ "wait": 0 }, duration: duration, addToQueue: queue)..listen((t) { 
     if (t.type == TweenEventType.BEGIN) {
       this.state.override({"wait": 1});
     }
   });
 }
 
 TweenItem resize (double scale, { double startingScale, int duration: 500, bool startInstantly: false, bool queue: false }) {
    if (startInstantly) this.stop();
    return this.transition({ "scale": scale }, duration: duration, addToQueue: queue)..listen((t) { 
      if (t.type == TweenEventType.BEGIN && startingScale != null) {
        this.state.override({"scale": startingScale});
      }
    });
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