import 'dart:html';
import 'dart:async';

void main () {
  new Favicon();
}

class Favicon {
  CanvasElement _canvas;
  CanvasRenderingContext2D _context;
  List<FaviconDrawable> elements = new List<FaviconDrawable>();
  Element destinationElement;
  int size;
  Favicon ({ this.destinationElement, this.size: 16 }) {
    if (this.destinationElement == null) {
      // TODO: Set default
    }
    
    _canvas = new CanvasElement();
    _canvas.width = this.size;
    _context = _canvas.getContext("2d");    
    FaviconDrawable._init();    
    window.requestAnimationFrame(_beginLoop);
    }
  
  num _prevFrameTime = 0;
  
  void _beginLoop (num t) {
    window.requestAnimationFrame(_beginLoop);
    _canvas.width = _canvas.width;
    num timeElapsed = t - _prevFrameTime;
    _prevFrameTime = t;
    int eleLength = elements.length;
    for (int x = 0; x <= eleLength; x++) { 
      FaviconDrawable currentDrawable = elements[x];
      currentDrawable.update(timeElapsed);
      if (!currentDrawable._remove) {
        currentDrawable.draw(_context);
      }
    }
  }
}
typedef bool FaviconTransition (FaviconDrawable drawable, int deltaT, List parameters, FaviconTransitionQueue currentQueue);

@proxy
abstract class FaviconDrawable {
 bool _remove = false;
 List<FaviconTransitionQueue> _animationQueue = new List<FaviconTransitionQueue>();
 FaviconTransitionQueue _currentQueue = new FaviconTransitionQueue();
 bool _isTransitioning = false; 
 num x;
 num y;
 num scale;
 num opacity; 
 
 num targetX = 0;
 num targetY = 0;
 num targetScale = 1;
 num targetOpacity = 1;
 
 void play () {
   this._isTransitioning = true;
   _animationQueue.add(_currentQueue);
   this.clearCurrent();
 }
 
 void clearCurrent () {
   _currentQueue = new FaviconTransitionQueue();
 }
 void stop () {
   _currentState.animationComplete = true;
   this.clearCurrent();
   _animationQueue = new List<FaviconTransitionQueue>();
 }
 
 void pause () {
   _isTransitioning = false;
 }
 
 void destroy () {
   this._remove = true;
 }
 
 void _update (int timeSinceLastFrame) {
   if (_isTransitioning) { 
     if (_animationQueue.length > 0) {
       FaviconTransitionQueue currentAnimationQueue = _animationQueue[0];
       if (currentAnimationQueue.transitions.length < 0) {
         FaviconTransitionQueueItem currentAnimation = currentAnimationQueue.transitions[0];
         bool isComplete = FaviconDrawable._transitions[currentAnimation.animationName](this, currentAnimation.parameters, timeSinceLastFrame, currentAnimationQueue);
         if (isComplete) currentAnimation.c.complete(this);
       }
       else {
         _animationQueue.removeAt(0);
         this.onAnimationQueueEnd();
         // Reinvoke the update method
         this._update(timeSinceLastFrame);
         // Leave this one so it doesnt update twice...
         return;
       }
     }
   }
   
   this.update(timeSinceLastFrame);
 }
 
 void onAnimationQueueEnd () {
   
 }
 
 void update (int timeSinceLastFrame) {
  
 }
 void draw (CanvasRenderingContext2D ctx) {
   
 }
 
 //***** Transition loading and registration
 static Map<Symbol, FaviconTransition> _transitions = new Map<Symbol, FaviconTransition> ();
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
     // TODO: Register animations
   }
 }
 noSuchMethod (Invocation invoke) {
   if (invoke.isMethod){
     if (FaviconDrawable._transitions.containsKey(invoke.memberName)) {
       var fIQI = new FaviconTransitionQueueItem(invoke.memberName, parameters);
       _currentQueue.add(fIQI);
      return fIQI.c.future;
     }
   }
   super.noSuchMethod(invoke);
 }
 
}

class FaviconTransitionQueue {
  List<FaviconTransitionQueueItem> transitions = new List<FaviconTransitionQueueItem>();
  FaviconTransitionQueue();
  void add (FaviconTransitionQueueItem item) { 
    transitions.add(item);
  }
}
class FaviconTransitionQueueItem { // Probably too descriptive!
  Symbol animationName;
  Completer c = new Completer();
  List parameters;
  FaviconTransitionQueueItem (this.animationName, this.parameters);
}

class FaviconPosition { 
  final int pos;
  const FaviconPosition(this.pos);
  static const FaviconPosition TOP_LEFT = const FaviconPosition(0);
  static const FaviconPosition TOP_RIGHT = const FaviconPosition(1);
  static const FaviconPosition BOTTOM_LEFT = const FaviconPosition(2);
  static const FaviconPosition BOTTOM_RIGHT = const FaviconPosition(3);
}

class FaviconBadge extends FaviconDrawable {
  String backgroundColour;
  String fontFamily;
  String fontStyle;
  String type;
  FaviconPosition position;
  List<int> badgeUpdateQueue = new List<int>();
  int currBadge = 0;
  
  void onAnimationQueueEnd () {
    if (badgeUpdateQueue.length > 0) {
      currBadge = badgeUpdateQueue[0];
      badgeUpdateQueue.removeAt(0);
    }
  }
  
  void draw (CanvasRenderingContext2D ctx) {
      
  }
  
  void update (int deltaT) {
     
  }
  
  void clearBadgeQueue() {
    badgeUpdateQueue = new List<int>();
  }
  
  void badge (int updateNumber) {
    badgeUpdateQueue.add(updateNumber);
    this.play();
  }
}
