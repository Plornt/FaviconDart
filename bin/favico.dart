import 'dart:html';
import 'dart:async';
import 'dart:math';

void main () {
  window.onLoad.listen((ev) { 
  ImageElement img = new ImageElement();
  Favicon icon = new Favicon(destinationElement: img, size: 64);
  FaviconBadge badge = new FaviconBadge ();
  icon.addElement(new FaviconBackgroundSource (new RGBA (0, 255, 0)));
  icon.addElement(badge);
  
  document.body.append(img);
    
    ButtonElement b = new ButtonElement();
    b.innerHtml = "+ 1";
    b.onClick.listen((ev) { 
      badge..stop()
           ..fade(0.5, 0.5)
           ..slideInDown(200)
           ..incrementBadge();
    });
    document.body.append(b);
  
  });
  
  
  
}

class Favicon {
  CanvasElement _canvas;
  CanvasRenderingContext2D _context;
  List<FaviconDrawable> elements = new List<FaviconDrawable>();
  Element destinationElement;
  bool updateFavicon = false;
  int size;
  Favicon ({ this.destinationElement, this.size: 16 }) {
    if (this.destinationElement == null) {
      updateFavicon = true;
    }
    
    _canvas = new CanvasElement();
    _canvas.width = this.size;
    _canvas.height = this.size;
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
    for (int x = 0; x < eleLength; x++) { 
      FaviconDrawable currentDrawable = elements[x];
      currentDrawable._update(timeElapsed);
      if (!currentDrawable._remove) {
        currentDrawable.draw(_context);
      }
      else {
        elements.removeAt(x);
        x--;
        eleLength--;
      }
    }
    updateImage (_canvas.toDataUrl());
  }
  
  void updateImage (String base64Image) {
    if (!updateFavicon) {
      destinationElement.setAttribute("src", base64Image);
    }
  }
  void addElement (FaviconDrawable drawable) {
    drawable._parent = this;
    this.elements.add(drawable);
  }
}
typedef bool FaviconTransition (FaviconDrawable drawable, num deltaT, List parameters, FaviconTransitionQueueItem item);
//@proxy
abstract class FaviconDrawable {
 bool _remove = false;
 List<FaviconTransitionQueue> _animationQueue = new List<FaviconTransitionQueue>();
 FaviconTransitionQueue _currentQueue = new FaviconTransitionQueue();
 bool _isTransitioning = false; 
 num x = 0;
 num y = 0;
 num scale = 1;
 num opacity = 0;
 
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
 
 
 Future<FaviconDrawable> play () {
   this._isTransitioning = true;
   Completer c = _currentQueue.c;
   _animationQueue.add(_currentQueue);
   this.clearCurrent();
   return c.future;   
 }
 
 Future<FaviconDrawable> insertAndPlay () {
   this._isTransitioning = true;
   Completer c = _currentQueue.c;
   _animationQueue.insert(0, _currentQueue);
   this.clearCurrent();
   return c.future;   
 }
 
 void clearCurrent () {
   _currentQueue = new FaviconTransitionQueue();
 }
 void stop () {
   this._isTransitioning = false;
   this.clearCurrent();
   _animationQueue = new List<FaviconTransitionQueue>();
 }
 
 void pause () {
   _isTransitioning = false;
 }
 
 void resume () {
   _isTransitioning = true;
 }
 
 void destroy () {
   this._remove = true;
 }
 
 void _update (num timeSinceLastFrame) {
   if (_isTransitioning) { 
     if (_animationQueue.length > 0) {
       FaviconTransitionQueue currentAnimationQueue = _animationQueue[0];
       int animLength = currentAnimationQueue.transitions.length;
       if (animLength > 0) {
         bool allComplete = true;
         if (currentAnimationQueue.transitions[0].isFirstFrame) this.onBeforeAnimationQueueBegin();
         for (int animX = 0; animX < animLength; animX++) {
           FaviconTransitionQueueItem currentAnimation = currentAnimationQueue.transitions[animX];
           bool isComplete = FaviconDrawable._transitions[currentAnimation.animationName](this, timeSinceLastFrame, currentAnimation.parameters, currentAnimation);
           
           currentAnimation.isFirstFrame = false;
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
         this.onBeforeAnimationQueueBegin();
         // Reinvoke the update method
         this._update(timeSinceLastFrame);
         // Leave this one so it doesnt update twice...
         return;
       }
     }
     else {
        this.onAnimationQueueEnd();
     }
   }
   
   this.update(timeSinceLastFrame);
 }
 
 void onAnimationQueueEnd () {
   
 }
 void onBeforeAnimationQueueBegin () {
   
 }
 void update (double timeSinceLastFrame) {
  
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
     bool slide (FaviconDrawable drawable, num deltaT, List parameters, FaviconTransitionQueueItem item) {
              //Map<String, bool>
              int duration = parameters.length > 1 && parameters[1] is int ? parameters[1] : 1000;
              bool isIn = parameters.length > 2 && parameters[2] is bool ? parameters[2] : true;
              Map<String, bool> directions = parameters[0];
              bool isComplete = true;
              
              if (directions.containsKey("left") || directions.containsKey("right")) {
               bool isLeft = directions["left"] == true;
               
               // Reset our target location so we can slide in or out
               if (item.isFirstFrame) {
                   if (isIn) {
                     drawable.targetX = 0;
                     drawable.x = (isLeft  == true ? drawable.parent.size: 0 - drawable.parent.size);
                    
                   }
                   else drawable.x = (isLeft  == true ? 0 - drawable.parent.size : drawable.parent.size);
               }
               
               // Step per millisecond
               num step = (max(drawable.targetX, drawable.scaledWidth) - min(drawable.targetX, drawable.scaledWidth)) / duration;
               
               // Move our current location relative to the duration of the animation and time elapsed
               if (isLeft) drawable.x -= step * deltaT;
               else drawable.x += step * deltaT;
               
               // Check if weve gone past the target, if so, jump to the target and complete the animation
               if ((isLeft && drawable.x < drawable.targetX) || (!isLeft && drawable.x > drawable.targetX)) {
                  drawable.x = drawable.targetY;
               }
               else isComplete = false;
             }
              
              if (directions.containsKey("up") || directions.containsKey("down")) {
                bool isUp = directions["up"] == true;
                
                // Reset our target location so we can slide in or out
                if (item.isFirstFrame) {
                    if (isIn) {
                      drawable.targetY = 0;
                      drawable.y = (isUp  == true ? drawable.parent.size : 0 - drawable.parent.size);
                    }
                    else drawable.y = (isUp  == true ? 0 - drawable.parent.size : drawable.parent.size);
                }
                
                // Step per millisecond
                num step = (max(drawable.targetY, drawable.scaledHeight) - min(drawable.targetY, drawable.scaledHeight)) / duration;
                // Move our current location relative to the duration of the animation and time elapsed
                if (isUp) drawable.y -= step * deltaT;
                else drawable.y += step * deltaT;
                
                // Check if weve gone past the target, if so, jump to the target and complete the animation
                if ((isUp && drawable.y < drawable.targetY) || (!isUp && drawable.y > drawable.targetY)) {
                   drawable.y = drawable.targetY;
                }
                else isComplete = false;
              }
              
              return isComplete;
            }
     registerTransition(const Symbol("slide"), slide);
     
     // Slide ins
     registerTransition(const Symbol ("slideInUp"), (FaviconDrawable drawable, num deltaT, List parameters, FaviconTransitionQueueItem item) {
       return slide (drawable, deltaT, [{ "up": true }, parameters.length > 0 ? parameters[0] : 1000], item);
     });
     registerTransition(const Symbol ("slideInDown"), (FaviconDrawable drawable, num deltaT, List parameters, FaviconTransitionQueueItem item) {
       return slide (drawable, deltaT, [{ "down": true }, parameters.length > 0 ? parameters[0] : 1000], item);
     });
     registerTransition(const Symbol ("slideInLeft"), (FaviconDrawable drawable, num deltaT, List parameters, FaviconTransitionQueueItem item) {
       return slide (drawable, deltaT, [{ "left": true }, parameters.length > 0 ? parameters[0] : 1000], item);
     });
     registerTransition(const Symbol ("slideInRight"), (FaviconDrawable drawable, num deltaT, List parameters, FaviconTransitionQueueItem item) {
       return slide (drawable, deltaT, [{ "right": true }, parameters.length > 0 ? parameters[0] : 1000], item);
     });
     
     // Slide outs

     registerTransition(const Symbol ("slideOutUp"), (FaviconDrawable drawable, num deltaT, List parameters, FaviconTransitionQueueItem item) {
       return slide (drawable, deltaT, [{ "up": true }, parameters.length > 0 ? parameters[0] : 1000, false], item);
     });
     registerTransition(const Symbol ("slideOutDown"), (FaviconDrawable drawable, num deltaT, List parameters, FaviconTransitionQueueItem item) {
       return slide (drawable, deltaT, [{ "down": true }, parameters.length > 0 ? parameters[0] : 1000, false], item);
     });
     registerTransition(const Symbol ("slideOutLeft"), (FaviconDrawable drawable, num deltaT, List parameters, FaviconTransitionQueueItem item) {
       return slide (drawable, deltaT, [{ "left": true }, parameters.length > 0 ? parameters[0] : 1000, false], item);
     });
     registerTransition(const Symbol ("slideOutRight"), (FaviconDrawable drawable, num deltaT, List parameters, FaviconTransitionQueueItem item) {
       return slide (drawable, deltaT, [{ "right": true }, parameters.length > 0 ? parameters[0] : 1000, false], item);
     });
     
     
     // Fades
     
     bool fade (FaviconDrawable drawable, num deltaT, List parameters, FaviconTransitionQueueItem item) {
       int duration = (parameters.length >= 1 && parameters[0] is int ? parameters[0] : 1000);
       num targetOpacity = (parameters.length >= 2 && parameters[1] is num ? parameters[1] : 1.0);
       bool isComplete = false;
       if (item.isFirstFrame) {
         item.state["towards"] = drawable.opacity < targetOpacity; 
         item.state["origOpacity"] = drawable.opacity; 
         drawable.targetOpacity = targetOpacity;
       }
       num step = (drawable.targetOpacity - item.state["origOpacity"]) / duration;

       drawable.opacity += (step * deltaT);
       if ((item.state["towards"] && drawable.opacity > targetOpacity) || (!item.state["towards"] && drawable.opacity < targetOpacity)){
         drawable.opacity = targetOpacity;
         isComplete = true;
       }
       return isComplete;
     }

     registerTransition(const Symbol ("fade"), fade);
     registerTransition(const Symbol ("fadeIn"), (FaviconDrawable drawable, num deltaT, List parameters, FaviconTransitionQueueItem item) {
        return fade (drawable, deltaT, [parameters.length > 0 ? parameters[0] : 1000, 1.0], item);
     });
     registerTransition(const Symbol ("fadeOut"), (FaviconDrawable drawable, num deltaT, List parameters, FaviconTransitionQueueItem item) {
        return fade (drawable, deltaT, [parameters.length > 0 ? parameters[0] : 1000, 0.0], item);
     });
   }
 }
 noSuchMethod (Invocation invoke) {
   if (invoke.isMethod){
     if (FaviconDrawable._transitions.containsKey(invoke.memberName)) {
       var fIQI = new FaviconTransitionQueueItem(invoke.memberName, invoke.positionalArguments);
       _currentQueue.add(fIQI);
      return fIQI.c.future;
     }
   }
   super.noSuchMethod(invoke);
 }
 
}

class FaviconTransitionQueue {
  Completer c = new Completer();
  List<FaviconTransitionQueueItem> transitions = new List<FaviconTransitionQueueItem>();
  FaviconTransitionQueue();
  void add (FaviconTransitionQueueItem item) { 
    transitions.add(item);
  }
}
class FaviconTransitionQueueItem { // Probably too descriptive!
  Symbol animationName;
  Completer c = new Completer();
  bool isFirstFrame = true;
  Map state = new Map();
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

class RGBA {
  int r = 0;
  int g = 0;
  int b = 0;
  num a = 0;
  num alphaMod = 0;
  
  RGBA (this.r, this.g, this.b,[ this.a = 1.0 ]);
  String toString () {
    return "rgba($r, $g, $b, ${a - alphaMod})";
  }
  
}

class FaviconBadge extends FaviconDrawable {
  RGBA backgroundColor;
  RGBA fontColor;
  String font;
  String type;
  FaviconPosition position;
  List<int> badgeUpdateQueue = new List<int>();
  int currBadge = 0;
  
  FaviconBadge ({ this.backgroundColor, this.fontColor, this.font: "35px Arial bold", this.type: "round", this.position: FaviconPosition.TOP_RIGHT }) {
   if (this.backgroundColor == null) backgroundColor = new RGBA (255, 0, 0);
   if (this.fontColor == null) fontColor = new RGBA (255,255,255);
  }
  
  void onBeforeAnimationQueueBegin () {
    if (badgeUpdateQueue.length > 0) {
      print(badgeUpdateQueue[0]);
      currBadge = badgeUpdateQueue[0];
      badgeUpdateQueue.removeAt(0);
    }
  }
  
  void onAnimationQueueEnd () {
    if (badgeUpdateQueue.length > 0) {
      this.resume();
    }
  }
  String convertBadgeToText (int badgeNum) {

    if (badgeNum > 999999) {
       return "${(badgeNum / 1000000).toStringAsFixed(1)}M";
    }
    if (badgeNum > 999) {
      return "${(badgeNum / 1000).toStringAsFixed(1)}K";
    }
    return badgeNum.toString();
  }
  
  void draw (CanvasRenderingContext2D ctx) {
    String badgeText = convertBadgeToText(currBadge);
    ctx.font = "$font";   
    double fontWidth = ctx.measureText(badgeText).width;
    // Estimated font height 
    double fontHeight = fontWidth / badgeText.length;
    
    int paddingLR = 4;
    int paddingTB = 10;
    
    this.width = fontWidth + paddingLR;
    this.height = fontHeight + paddingTB;
    
    int bgPadding = 2;
    backgroundColor.alphaMod = opacity;  
    ctx.fillStyle = backgroundColor.toString();   
    switch (position) {
      case FaviconPosition.TOP_LEFT:
        ctx.translate(2, 2);
        break;
      case FaviconPosition.TOP_RIGHT:
        ctx.translate(parent.size - width - bgPadding, 2);
        break;
      case FaviconPosition.BOTTOM_LEFT:
        ctx.translate(2, parent.size - height - bgPadding);
        break;

      case FaviconPosition.BOTTOM_RIGHT:
        ctx.translate(parent.size - width - bgPadding, parent.size - height - bgPadding);
        break;
    }
       
    // TODO: Fix this properly
    if (type == "round") {
      ctx.fillRect(x, y, width, height);
    }
    else { 
      ctx.fillRect(x, y, width, height);
    }

    fontColor.alphaMod = opacity;
    ctx.fillStyle = fontColor.toString();
    ctx.fillText(convertBadgeToText(currBadge), x + (paddingLR / 2), height + y - (paddingTB / 4));  
    
  }
  
  void update (num deltaT) {
     
  }
  
  void clearBadgeQueue() {
    badgeUpdateQueue = new List<int>();
  }
  Future<FaviconDrawable> incrementBadge () {
    _lastBadgeNum++;
    return this.badge(_lastBadgeNum);
  }
  int _lastBadgeNum = 0;
  Future<FaviconDrawable> badge (int updateNumber) {
    //currBadge = updateNumber;
    _lastBadgeNum = updateNumber;
    badgeUpdateQueue.add(updateNumber);
    return this.play();
  }
}

class FaviconBackgroundSource extends FaviconDrawable {
  RGBA backgroundColor;
  FaviconBackgroundSource (this.backgroundColor);
  void draw (CanvasRenderingContext2D ctx) {
    ctx.fillStyle = backgroundColor.toString();
    ctx.fillRect(x, y, parent.size, parent.size);
  }
}