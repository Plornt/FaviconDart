part of FaviconDart;

/***
 * Creates a drawable from an icon in a [LinkElement] 
 */
class FaviconIconSource extends FaviconDrawable {
  LinkElement linkElement;
  ImageElement _image;
  bool _hasLoaded = false;
  
  
  /***
   * [linkElement] defaults to the pages default favicon. If no icon element is found it creates one from your 
   * servers favicon.ico image.
   */
  FaviconIconSource ([ this.linkElement ]) {
    _image = new ImageElement();
    if (linkElement == null) {
      var queryElem = querySelectorAll(r"link[rel$='icon']");
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