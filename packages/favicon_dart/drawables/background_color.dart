part of FaviconDart;


class FaviconBackground extends FaviconDrawable {
  RGBA backgroundColor;
  FaviconBackground (this.backgroundColor);
  void onDraw (CanvasRenderingContext2D ctx) {
    ctx.fillStyle = backgroundColor.toString();
    ctx.fillRect(x, y, parent.size, parent.size);
  }
}