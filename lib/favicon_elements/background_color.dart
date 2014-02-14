part of FaviconDart;

/***
 * A simple single solid colour background element
 */
class Background extends FaviconElement {
  RGBA backgroundColor;
  Background (this.backgroundColor);
  void onDraw (CanvasRenderingContext2D ctx) {
    ctx.fillStyle = backgroundColor.toString();
    ctx.fillRect(x, y, parent.size, parent.size);
  }
}