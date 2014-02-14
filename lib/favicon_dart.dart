library FaviconDart;

import 'dart:html';
import 'dart:async';
import 'dart:math';

part 'favicon_elements/favicon_element.dart';
part 'favicon_elements/background_color.dart';
part 'favicon_elements/badge.dart';

part 'sources/animation.dart';
part 'sources/source.dart';
part 'sources/favicon.dart';

part 'transitions/frame.dart';
part 'transitions/item.dart';

part 'utilities/browser_detect.dart';
part 'utilities/image_preloader.dart';
part 'utilities/rgba.dart';

class Favicon {
  List<FaviconElement> elements = new List<FaviconElement>();
  Element destinationElement;
  int size;
  
  /// Set to true to use browser specific optimisations where possible
  /// Recommended value: true
  bool applyOptimisations = true;  

  CanvasElement _canvas;
  CanvasRenderingContext2D _context;
  int _browser = BrowserDetect.UNKNOWN;
  num _prevFrameTime = 0;
  Stopwatch _stopwatch = new Stopwatch();
  
  /***
   * Creates an internal canvas and manages the state of any FaviconDrawables. 
   * 
   * [destinationElement] is the desired destination element. Defaults to the 
   * current pages favicon.
   * 
   * [size] is the output size of the icon.
   */
  Favicon ({ this.destinationElement, this.size: 16 }) {
    // Default to the current pages favicon:
    if (this.destinationElement == null) {
      List<Element> elements = querySelectorAll("link[rel\$='icon']");
      if (elements.length > 0) {
        destinationElement = elements[0];
      }
      else {
        destinationElement = new LinkElement()..rel = "icon"..type = "image/png";
      }
    }
    
    // Setup our canvas and do a bit of browser detection for any optimisations
    _browser = BrowserDetect.detect(window.navigator.userAgent);
    _canvas = new CanvasElement();
    _canvas.width = this.size;
    _canvas.height = this.size;
    _context = _canvas.getContext("2d");    

    
    // Start timing and begin the draw loop
    _stopwatch.start();
    new Timer(new Duration(milliseconds: 33), _loopDraw); 
  }
  
  void _loopDraw () {
    new Timer(new Duration(milliseconds: 33), _loopDraw);
    // Clear the canvas:
    _canvas.width = _canvas.width;
    
    // Work out how much time has elapsed since previous frames
    double t = _stopwatch.elapsedMicroseconds / 1000;
    double timeElapsed = t - _prevFrameTime;
    _prevFrameTime = t;
    
    // Loop through the drawables, update them and then draw them to the temp canvas
    int eleLength = elements.length;
    for (int x = 0; x < eleLength; x++) { 
      FaviconElement currentDrawable = elements[x];
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
    
    // Send the canvas image buffer data 
    _updateImage (_canvas.toDataUrl()); 
  }
  
  /***
   * Takes a base 64 representation of an image and applies it to the
   * destination element. 
   * 
   * [LinkElement]'s will have it applied to the href.
   * Any other elements have it applied to the src element
   */  
  void _updateImage (String base64Image) {
      if (destinationElement is LinkElement) {
        destinationElement.setAttribute("href", base64Image);
        if (_browser == BrowserDetect.FIREFOX && this.applyOptimisations) { 
          destinationElement.remove();
          document.head.append(destinationElement);
        }
        return;
      }
      destinationElement.setAttribute("src", base64Image);
  }
  
  /***
   * Adds the drawable to the favicons render queue.
   */
  void addElement (FaviconElement drawable) {
    drawable._parent = this;
    drawable.onPushedToFavicon();
    this.elements.add(drawable);
  }
}

