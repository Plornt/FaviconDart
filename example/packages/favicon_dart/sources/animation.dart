part of FaviconDart;

/***
 * Drawable element of an animation.
 */
class FaviconAnimationSource extends FaviconPausable {
  /// Delay between moving frames
  int frameDelay;
  /// Number of frames the animation contains
  int frames;
  
  bool isSpriteSheet = false;
  // if isSpriteSheet:
  int frameSizeX;
  int rows = 1;
  int columns = 1;
  
  bool isLoaded = false;
  
  /// Current frame number
  int frame = 0;
 
  double _frameN = 0.0;
    
  FaviconImagePreloader _preloader = new FaviconImagePreloader();
   
  /***
   * Creates a new animation from a list of image sources.
   */
  FaviconAnimationSource.imageList (List<String> source, [ int this.frameDelay = 20 ]) {
    frames = source.length;
    _preloader.addImages(source);
    _load();
  }
 
  /***
   * Creates a new animation from a horizontal sprite sheet.
   * [frameSizeX] is the size of the frames in the image file [sheetSource]
   */
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
      _frameN += timeElapsed / frameDelay;
      if (_frameN >= 1) {
        frame += (_frameN).floor();
        _frameN -= _frameN.floor();
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
