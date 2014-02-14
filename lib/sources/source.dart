part of FaviconDart;

/***
 * Draw a pre-existing [CanvasImageSource] to the canvas. 
 */
class Source extends FaviconElement {
  CanvasImageSource source;
  Source (this.source);
  void onDraw(CanvasRenderingContext2D ctx) {
    ctx.drawImageScaled(source, x, y, parent.size, parent.size);
  }
}
