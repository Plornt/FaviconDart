part of FaviconDart;

// Was sort of expecting more drawables to use the following:
class FaviconPosition { 
  final int pos;
  const FaviconPosition(this.pos);
  static const FaviconPosition TOP_LEFT = const FaviconPosition(0);
  static const FaviconPosition TOP_RIGHT = const FaviconPosition(1);
  static const FaviconPosition BOTTOM_LEFT = const FaviconPosition(2);
  static const FaviconPosition BOTTOM_RIGHT = const FaviconPosition(3);
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
  int showAbove = 0;
  
  FaviconBadge ({ this.backgroundColor,
                  this.fontColor, 
                  this.font: "bold 8px sans-serif", 
                  this.type: "rounded", 
                  this.position: FaviconPosition.BOTTOM_RIGHT, 
                  this.padding: 0,
                  this.showAbove: 0
                  }) {
    if (currBadge > showAbove) this.opacity = 1.0;
    else this.opacity = 0.0;
    
   if (this.backgroundColor == null) backgroundColor = new RGBA (255, 0, 0);
   if (this.fontColor == null) fontColor = new RGBA (255,255,255);
  }
  
  void onBeforeAnimationQueueBegin ([ FaviconFrame currentFrame ]) {
    if (badgeUpdateQueue.length > 0) {
      currBadge = badgeUpdateQueue[0];
      badgeUpdateQueue.removeAt(0);
      if (currBadge > showAbove) this.opacity = 1.0;
      else this.opacity = 0.0;
    }
  }
  
  void onAnimationQueueEnd ([ FaviconFrame currentFrame ]) {
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
    double fontHeight = 4.0;
    
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
    int borderStepBack = 3;
    num r = 5;   
    
    // http://stackoverflow.com/questions/1255512/how-to-draw-a-rounded-rectangle-on-html-canvas
    // TODO: Fix this properly
    if (type == "rounded") {
     
        if (width < 2 * r) r = width / 2;
        if (height < 2 * r) r = height / 2;
        ctx.beginPath();
        ctx.moveTo(x+r, y);
        ctx.arcTo(x+width, y,   x+width, y+height, r);
        ctx.arcTo(x+width, y+height, x,   y+height, r);
        ctx.arcTo(x,   y+height, x,   y,   r);
        ctx.arcTo(x,   y,   x+width, y,   r);
        ctx.closePath();
        ctx.fill();
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