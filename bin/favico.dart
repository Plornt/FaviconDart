import 'dart:html';
import 'dart:async';

// Useragent sniffing...
// Not good! 
// TODO: Replace this with something more robust.
String _lowerCaseUserAgent = window.navigator.userAgent.toLowerCase();
Map<String, bool> browserType = {
  "firefox": _lowerCaseUserAgent.contains("firefox"),
  "chrome": _lowerCaseUserAgent.contains("chrome"),
  "opera": _lowerCaseUserAgent.contains("opera"),
  "ie": _lowerCaseUserAgent.contains("msie") || _lowerCaseUserAgent.contains("trident")
};

abstract class FavicoSource {
  void render (CanvasRenderingContext2D ctx, num deltaT) {
    
  }
}
class FavicoImageSource extends FavicoSource {
  void render (CanvasRenderingContext2D ctx, num deltaT) {
    
  }
}
class FavicoSpriteSource extends FavicoSource {
  String imageSource;
  int frameWidth;
  int frameHeight;
  num millisecondsPerFrame;
  

  ImageElement _image;
  int currentFrame;
  
  
  FavicoSpriteSource (this.imageSource, this.frameWidth, this.frameHeight);
  
  void render (CanvasRenderingContext2D ctx, num deltaT) {
    
  }  
}
class FavicoVideoSource extends FavicoSource {
  VideoElement video;
  bool repeat;
  FavicoVideoSource(this.video);
  void render (CanvasRenderingContext2D ctx, num deltaT) {
    
  }
}

class FavicoFrameSource extends FavicoSource {
  List<String> urlList;
  FavicoFrameSource (this.urlList);
  void render (CanvasRenderingContext2D ctx, num deltaT) {
    
  }  
}

class FavicoCanvasSource extends FavicoSource {
  CanvasElement canvas;
  FavicoCanvasSource (this.canvas);
  void render (CanvasRenderingContext2D ctx, num deltaT) {
    
  }  
}

void main () {
  var f = new Favico();
  f.pulse(10);
}

class Position {
  static int TOP_LEFT = 1;
  static int TOP_RIGHT = 2;
  static int BOTTOM_LEFT = 3;
  static int BOTTOM_RIGHT = 4;
  
}

typedef FavicoState FavicoAnimation(FavicoState fs, num deltaT, List parameters);
class Favico {
  // Options 
  String backgroundColor = "#d00";
  String textColor = "white";
  String fontFamily = "sans-serif";
  String fontStyle = "bold";
  FavicoType type;
  int position;
  FavicoImageSource source;
  Element destination;
  
  // Elements
  CanvasElement _canvas;
  CanvasRenderingContext2D _context;
  
  num _currentBadgeNumber;
  
  List<FavicoAnimationItem> animationQueue;
  
  Favico ({ this.backgroundColor: "#d00",
            this.textColor: "white", 
            this.fontFamily: "sans-serif", 
            this.fontStyle: "bold", 
            this.type, 
            this.position, 
            this.destination }) {
            if (this.position == null) this.position = Position.BOTTOM_RIGHT;
            if (this.type == null) this.type = FavicoType.CIRCLE;
            if (!_initialized) init();
            
       if (this.position < 0 || this.position > 4) this.position = Position.BOTTOM_RIGHT;
       
       
  }
  
  
  // Static:
  static bool _initialized = false;
  static Map<Symbol, FavicoAnimation> _animationElements = new Map<Symbol, FavicoAnimation>();
  
  /// Registers an animation for use with Favico badges.
  static void registerAnimation (Symbol animationName, FavicoAnimation animationCallback) {
    _animationElements[animationName] = animationCallback;
  }

  static void init () {
    /// TODO: Register default animations here..      
    _initialized = true;
  }
  
  
  // 
  noSuchMethod(Invocation invo) {
    if (_animationElements.containsKey(invo.memberName)) { 
      animationQueue.add(new FavicoAnimationItem (invo.memberName, invo.positionalArguments));
      return this;
    }
    throw new NoSuchMethodError(invo);
  }
}

class FavicoAnimationItem {
  Symbol itemName;
  List parameters;
  FavicoAnimationItem (Symbol this.itemName, this.parameters);
}

/***
 * Contains modifier fields that describe the desired favicon state
 * Fields: [x] [y] [opacity] [scale]
 */
class FavicoState {
  num x = 1.0;
  num y = 1.0;
  num opacity = 1.0;
  num scale = 1.0;
  int position = Position.BOTTOM_RIGHT;
  
  bool isComplete = false;
}

abstract class FavicoType {  
  static FavicoType CIRCLE = new CircleFavico();
  void render(num badgeNumber, CanvasRenderingContext2D ctx);
}

class CircleFavico extends FavicoType {
  void render (num badgeNumber, CanvasRenderingContext2D ctx) {
    
  }
}