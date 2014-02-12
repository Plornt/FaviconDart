import 'dart:html';
import 'dart:async';
import 'dart:math';

void main () {
  window.onLoad.listen((ev) { 
  LinkElement img = new LinkElement();
  img.rel = "icon";
  img.type = "image/png";

  
  
  Favicon icon = new Favicon(destinationElement: img, size: 16);
  FaviconBadge badge = new FaviconBadge ();
  
  icon.addElement(new FaviconIconSource());
  
  
  /* VIDEO TEST */
    
//    VideoElement v = new VideoElement();
//    SourceElement vSource = new SourceElement();
//    vSource.src = "chromeicon.webm";
//    SourceElement vSourceOther = new SourceElement();
//    vSourceOther.src = "chromeicon.mp4";
//    
//    v.append(vSource);
//    v.append(vSourceOther);
//    v.style.display = "none";
//    v.autoplay = true;
//    v.loop = true;
//    document.body.append(v);
//    FaviconVideoSource videoSource = new FaviconVideoSource(v);
//   icon.addElement(videoSource); 
//  
  
  /* CANVAS TEST */
  CanvasElement c = new CanvasElement();
  c.width = 32;
  c.height = 32;
  CanvasRenderingContext2D ctx = c.getContext("2d");
  RGBA colour = new RGBA(0,0,0);
  new Timer.periodic(new Duration(milliseconds: 60), (t) { 
    colour.r += 10;
    colour.g += 5;
    colour.b += 3;
    ctx.fillStyle = colour.toString();
    ctx.fillRect(0, 0, 32, 32);
  });
  FaviconCanvasSource fcs = new FaviconCanvasSource (c);
  icon.addElement(fcs);  
  
  icon.addElement(badge..opacity = 0.0);
  
  document.head.append(img);
    
    ButtonElement b = new ButtonElement();
    b.innerHtml = "+ 1";
    b.onClick.listen((ev) { 
      badge..stop()
           ..opacity = 0.0
           ..fadeIn(300)
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
  Stopwatch _stopwatch = new Stopwatch();
  Favicon ({ this.destinationElement, this.size: 16 }) {
    if (this.destinationElement == null) {
      updateFavicon = true;
    }
    
    _canvas = new CanvasElement();
    _canvas.width = this.size;
    _canvas.height = this.size;
    _context = _canvas.getContext("2d");    
    FaviconDrawable._init();    
    _stopwatch.start();
    new Timer(new Duration(milliseconds: 33), _beginLoop); 
  }
  
  num _prevFrameTime = 0;
  void _beginLoop () {
    new Timer(new Duration(milliseconds: 33), _beginLoop);
    // Request animation frame doesnt work for this because it doesnt get activated when the tab is inactive... effectively making this useless
    //window.requestAnimationFrame(_beginLoop);
    _canvas.width = _canvas.width;
    double t = _stopwatch.elapsedMicroseconds / 1000;
    double timeElapsed = t - _prevFrameTime;
    _prevFrameTime = t;
    int eleLength = elements.length;
    for (int x = 0; x < eleLength; x++) { 
      FaviconDrawable currentDrawable = elements[x];
      currentDrawable._onUpdate(timeElapsed);
      if (!currentDrawable._remove) {
        currentDrawable.onDraw(_context);
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
      if (destinationElement is LinkElement) {
        
        document.head.append(destinationElement);
        destinationElement.remove();
        destinationElement.setAttribute("href", base64Image);
        return;
      }
      destinationElement.setAttribute("src", base64Image);
    }
  }
  void addElement (FaviconDrawable drawable) {
    drawable._parent = this;
    drawable.onPushedToFavicon();
    this.elements.add(drawable);
  }
}

typedef bool FaviconTransition (FaviconDrawable drawable, double deltaT, List parameters, FavicoTween item);
//@proxy
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
   _currentQueue = new FaviconFrame();
 }
 void stop () {
   this._isTransitioning = false;
   this.clearCurrent();
   _animationQueue = new List<FaviconFrame>();
   onStop();
 }
 
 void pauseTransition () {
   _isTransitioning = false;
   onPauseTransition();
 }
 
 void resumeTransition () {
   _isTransitioning = true;
   onResumeTransition();
 }
 
 void destroy () {
   this._remove = true;
   onDestroy();
 }
 
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
         this.onBeforeAnimationQueueBegin();
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
 
 void onDestroy () {
   
 }
 
 void onPauseTransition () {
   
 }
 
 void onResumeTransition () {
   
 }
 
 void onStop() {
   
 }
 
 void onAnimationQueueEnd () {
   
 }
 
 void onPushedToFavicon () {
   
 }
 
 void onBeforeAnimationQueueBegin () {
   
 }
 
 void onUpdate (double timeSinceLastFrame) {
  
 }
 
 void onDraw (CanvasRenderingContext2D ctx) {
   
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
     bool slide (FaviconDrawable drawable, double deltaT, List parameters, FavicoTween item) {
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
     registerTransition(const Symbol ("slideInUp"), (FaviconDrawable drawable, double deltaT, List parameters, FavicoTween item) {
       return slide (drawable, deltaT, [{ "up": true }, parameters.length > 0 ? parameters[0] : 1000], item);
     });
     registerTransition(const Symbol ("slideInDown"), (FaviconDrawable drawable, double deltaT, List parameters, FavicoTween item) {
       return slide (drawable, deltaT, [{ "down": true }, parameters.length > 0 ? parameters[0] : 1000], item);
     });
     registerTransition(const Symbol ("slideInLeft"), (FaviconDrawable drawable, double deltaT, List parameters, FavicoTween item) {
       return slide (drawable, deltaT, [{ "left": true }, parameters.length > 0 ? parameters[0] : 1000], item);
     });
     registerTransition(const Symbol ("slideInRight"), (FaviconDrawable drawable, double deltaT, List parameters, FavicoTween item) {
       return slide (drawable, deltaT, [{ "right": true }, parameters.length > 0 ? parameters[0] : 1000], item);
     });
     
     // Slide outs

     registerTransition(const Symbol ("slideOutUp"), (FaviconDrawable drawable, double deltaT, List parameters, FavicoTween item) {
       return slide (drawable, deltaT, [{ "up": true }, parameters.length > 0 ? parameters[0] : 1000, false], item);
     });
     registerTransition(const Symbol ("slideOutDown"), (FaviconDrawable drawable, double deltaT, List parameters, FavicoTween item) {
       return slide (drawable, deltaT, [{ "down": true }, parameters.length > 0 ? parameters[0] : 1000, false], item);
     });
     registerTransition(const Symbol ("slideOutLeft"), (FaviconDrawable drawable, double deltaT, List parameters, FavicoTween item) {
       return slide (drawable, deltaT, [{ "left": true }, parameters.length > 0 ? parameters[0] : 1000, false], item);
     });
     registerTransition(const Symbol ("slideOutRight"), (FaviconDrawable drawable, double deltaT, List parameters, FavicoTween item) {
       return slide (drawable, deltaT, [{ "right": true }, parameters.length > 0 ? parameters[0] : 1000, false], item);
     });
     
     
     // Fades
     
     bool fade (FaviconDrawable drawable, double deltaT, List parameters, FavicoTween item) {
       int duration = (parameters.length >= 1 && parameters[0] is int ? parameters[0] : 1000);
       num targetOpacity = (parameters.length >= 2 && parameters[1] is num ? parameters[1] : 1.0);
       bool isComplete = false;
       bool towards = false;
       double opacityStep;
       if (item.isFirstFrame) {
         item.state["towards"] = drawable.opacity < targetOpacity; 
         towards = drawable.opacity < targetOpacity;
         opacityStep = (max(targetOpacity, drawable.opacity) - min(targetOpacity, drawable.opacity)) / duration;
         if (!towards) opacityStep = - opacityStep;

         item.state["opacityStep"] = opacityStep;
         drawable.targetOpacity = targetOpacity;
       }
       else {
         opacityStep = item.state["opacityStep"];
         towards = item.state["towards"];
       }
       
       drawable.opacity += (opacityStep * deltaT);
       if ((towards && drawable.opacity > targetOpacity) || (!towards && drawable.opacity < targetOpacity)){
         drawable.opacity = targetOpacity;
         isComplete = true;
       }
       return isComplete;
     }

     registerTransition(const Symbol ("fade"), fade);
     registerTransition(const Symbol ("fadeIn"), (FaviconDrawable drawable, double deltaT, List parameters, FavicoTween item) {
        if (item.isFirstFrame) drawable.opacity = 0.0; 
        return fade (drawable, deltaT, [parameters.length > 0 ? parameters[0] : 1000, 1.0], item);
     });
     registerTransition(const Symbol ("fadeOut"), (FaviconDrawable drawable, double deltaT, List parameters, FavicoTween item) {
        return fade (drawable, deltaT, [parameters.length > 0 ? parameters[0] : 1000, 0.0], item);
     });
     
     registerTransition(const Symbol ("wait"), (FaviconDrawable drawable, double deltaT, List parameters, FavicoTween item) {
             return (item.duration >= parameters[0]);
     });
   }
 }
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

class FaviconFrame {
  Completer c = new Completer();
  List<FavicoTween> transitions = new List<FavicoTween>();
  FaviconFrame();
  void add (FavicoTween item) { 
    transitions.add(item);
  }
}
class FavicoTween {
  Symbol animationName;
  Completer c = new Completer();
  double duration = 0.0;
  int frameNumber = 0;  
  bool get isFirstFrame {
    return frameNumber == 0;
  }  
  Map state = new Map();
  List parameters;  
  FavicoTween (this.animationName, this.parameters);
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
  int _r = 0;
  int _g = 0;
  int _b = 0;
  num a = 0;
  num alphaMod = 1.0;
  
  set r (int r) {
    _r = r % 255;
  }
  set g (int r) {
    _g = r % 255;
  }
  set b (int r) {
    _b = r % 255;
  }
  
  int get r => _r;
  int get g => _g;
  int get b => _b;
  
  RGBA (this._r, this._g, this._b,[ this.a = 1.0 ]);
  String toString () {
    return "rgba($_r, $_g, $_b, ${a * alphaMod})";
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
  int padding = 0;
  
  FaviconBadge ({ this.backgroundColor, this.fontColor, this.font: "bold 8px sans-serif", this.type: "round", this.position: FaviconPosition.BOTTOM_RIGHT, this.padding: 0 }) {
   if (this.backgroundColor == null) backgroundColor = new RGBA (255, 0, 0);
   if (this.fontColor == null) fontColor = new RGBA (255,255,255);
  }
  
  void onBeforeAnimationQueueBegin () {
    if (badgeUpdateQueue.length > 0) {
      currBadge = badgeUpdateQueue[0];
      badgeUpdateQueue.removeAt(0);
    }
  }
  
  void onAnimationQueueEnd () {
    if (badgeUpdateQueue.length > 0) {
      this.resumeTransition();
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
  
  void onDraw (CanvasRenderingContext2D ctx) {
    String badgeText = convertBadgeToText(currBadge);
    ctx.font = "$font";   
    double fontWidth = ctx.measureText(badgeText).width;
    // Estimated font height 
    double fontHeight = 6.0;
    
    int paddingLR = 4;
    int paddingTB = 4;
    
    this.width = fontWidth + paddingLR;
    this.height = fontHeight + paddingTB;
    
   
    backgroundColor.alphaMod = opacity;  
    ctx.fillStyle = backgroundColor.toString();   
    switch (position) {
      case FaviconPosition.TOP_LEFT:
        ctx.translate(2, 2);
        break;
      case FaviconPosition.TOP_RIGHT:
        ctx.translate(parent.size - width - padding, 2);
        break;
      case FaviconPosition.BOTTOM_LEFT:
        ctx.translate(2, parent.size - height - padding);
        break;

      case FaviconPosition.BOTTOM_RIGHT:
        ctx.translate(parent.size - width - padding, parent.size - height - padding);
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
    ctx.fillText(convertBadgeToText(currBadge), x + (paddingLR / 2),  fontHeight + (paddingTB / 2) + y);  
    
  }
  
  void onUpdate (double deltaT) {
     
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
    _lastBadgeNum = updateNumber;
    badgeUpdateQueue.add(updateNumber);
    return this.play();
  }
}

class FaviconIconSource extends FaviconDrawable {
  LinkElement linkElement;
  ImageElement _image;
  bool _hasLoaded = false;
  
  FaviconIconSource ([ this.linkElement ]) {
    _image = new ImageElement();
    if (linkElement == null) {
      var queryElem = querySelectorAll(r"head > link[rel$='icon']");
      if (queryElem.length > 0) {
        linkElement = queryElem[0];
        _image.src = linkElement.href;
      }
      else {
        print("Could not find favicon tag to load the image from. Attempting to load default favicon from server");
        _image.src = "/favicon.ico";
        
      }
    }  
    else {
      _image.src = linkElement.href;
    }
    _image.onLoad.listen((ev) { 
      _hasLoaded = true;
    });
    _image.onError.listen((ev) { 
      print("Could not load image: ${_image.src} ... Removing from favicon");
      this.destroy();
    });    
  }
  
  void onDraw (CanvasRenderingContext2D ctx) {
    if (_hasLoaded) {
      ctx.drawImageScaled(_image, x, y, parent.size, parent.size);   
    }
  }
}
class FaviconPausable extends FaviconDrawable {
  bool isPaused = false;
  void pause() {
    isPaused = true;
  }
  void resume() {
    isPaused = false;
  }
}
class FaviconImagePreloader {
  bool isLoaded = false;
  List<String> _imageSources = new List<String>();
  List<ImageElement> images = new List<ImageElement>();
  FaviconImagePreloader ();
  void addImage (String source) { 
    _imageSources.add(source);
  }
  void addImages (List<String> sources) {
    _imageSources.addAll(sources);
  }
  
  Future<bool> startLoad () {
    Completer c = new Completer();
    int waiting = _imageSources.length;
    int loaded = 0;
    _imageSources.forEach((String source) { 
      ImageElement currImage = new ImageElement();
      currImage.src = source;
      currImage.onLoad.listen((event) { 
         loaded++;
         if (loaded == waiting) {
           c.complete(true);
         }
      });
      currImage.onError.listen((errorEvent) {
        if (!c.isCompleted) c.completeError(errorEvent);
      });
    });
    return c.future;
  }
}

class FaviconCanvasSource extends FaviconDrawable {
  CanvasElement source;
  FaviconCanvasSource (this.source);
  void onDraw(CanvasRenderingContext2D ctx) {
    ctx.drawImageScaled(source, x, y, parent.size, parent.size);
  }
}

class FaviconVideoSource extends FaviconDrawable {
  VideoElement source;
  bool autoLoop = true;
  FaviconVideoSource (this.source);
  
  void onDraw(CanvasRenderingContext2D ctx) {
    ctx.drawImageScaled(source, x, y, parent.size, parent.size);
  }
}

class FaviconAnimationSource extends FaviconPausable {
  int frameDelay;
  int frames;
  
  bool isSpriteSheet = false;
  // if isSpriteSheet:
  int frameSizeX;
  int rows = 1;
  int columns = 1;
  
  bool isLoaded = false;
  int frame = 0;
  double frameN = 0.0;
    
  FaviconImagePreloader _preloader = new FaviconImagePreloader();
    
  FaviconAnimationSource.imageList (List<String> source, [ int this.frameDelay = 20 ]) {
    frames = source.length;
    _preloader.addImages(source);
    _load();
  }
 
  FaviconAnimationSource.spriteSheet (String sheetSource, { int this.frameDelay: 20, int this.frameSizeX }) {
    _preloader.addImage(sheetSource);
    _load();
  }
  
  void _load () {
    _preloader.startLoad().then((bool isDone) { 
      if (isSpriteSheet) {
         frames = (_preloader.images[0].width ~/ frameSizeX);
      }
      isLoaded = isDone;
    });
  }
  
  void onPushedToFavicon () {
    if (frameSizeX == null) frameSizeX = parent.size;
  }
  
  void onUpdate (double timeElapsed) {
    if (!isPaused) {
      frameN += timeElapsed / frameDelay;
      if (frameN >= 1) {
        frame += (frameN).floor();
        frameN -= frameN.floor();
        if (frame > (frames - 1)) frame = (frame % (frames - 1));
      }
    }
  }
  
  void onDraw (CanvasRenderingContext2D ctx) {
    if (isLoaded) {
      if (isSpriteSheet) {
        ctx.drawImageScaledFromSource(_preloader.images[0], frameSizeX * frame, 0, frameSizeX, _preloader.images[0].height, 0, 0, parent.size, parent.size);
      }
      else {
        ctx.drawImageScaled(_preloader.images[frame], x, y, parent.size, parent.size);
      }
    }
  }
}

class FaviconBackgroundSource extends FaviconDrawable {
  RGBA backgroundColor;
  FaviconBackgroundSource (this.backgroundColor);
  void onDraw (CanvasRenderingContext2D ctx) {
    ctx.fillStyle = backgroundColor.toString();
    ctx.fillRect(x, y, parent.size, parent.size);
  }
}