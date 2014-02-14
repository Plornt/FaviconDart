part of FaviconDart;

/***
 * The ImagePreloader takes a list of sources and preloads them.
 */
class ImagePreloader {
  bool isLoaded = false;
  List<String> _imageSources = new List<String>();
  List<ImageElement> images = new List<ImageElement>();
  
  ImagePreloader ();
  
  /***
   * Adds an image source to be loaded
   * 
   * Call [startLoad] to begin the loading process.
   */
  void addImage (String source) { 
    _imageSources.add(source);
  }
  
  /***
   * Takes a list of sources and adds them ready to be loaded
   * 
   * Call [startLoad] to begin the loading process.
   */
  void addImages (List<String> sources) {
    _imageSources.addAll(sources);
  }
  
  /***
   * Starts the loading process, creates image elements and waits for them to load
   * 
   * Returns a future that:
   * Completes with [true] to signify the images have all loaded
   * Completes with an error event if there was an error whilst loading an image 
   */
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
