part of FaviconDart;

// Was sort of expecting more drawables to use the following:
class Position { 
  final int pos;
  const Position(this.pos);
  static const Position TOP_LEFT = const Position(0);
  static const Position TOP_RIGHT = const Position(1);
  static const Position BOTTOM_LEFT = const Position(2);
  static const Position BOTTOM_RIGHT = const Position(3);
}


class Badge extends FaviconElement {
  RGBA backgroundColor;
  RGBA fontColor;
  String fontStyle;
  String fontFamily;
  String type;
  Position position;
  //List<int> badgeUpdateQueue = new List<int>();
  int currBadge = 0;
  int padding = 0;
  int showAbove = 0;
  num maxFontSize;
  bool adaptiveFontSize;
  num fontSize;
  
  
  Badge ({ this.backgroundColor,
                  this.fontColor, 
                  this.maxFontSize: 12,
                  this.adaptiveFontSize: true,
                  this.fontFamily: "sans-serif", 
                  this.fontStyle: "bold",
                  this.type: "rounded", 
                  this.position: Position.BOTTOM_RIGHT, 
                  this.padding: 0,
                  this.showAbove: 0
                  }) {
    if (currBadge > showAbove) this.opacity = 1.0;
    else this.opacity = 0.0;
    this.fontSize = this.maxFontSize;
   if (this.backgroundColor == null) backgroundColor = new RGBA (255, 0, 0);
   if (this.fontColor == null) fontColor = new RGBA (255,255,255);
  }
  
//  void onBeforeAnimationQueueBegin ([ FaviconFrame currentFrame ]) {
//    if (badgeUpdateQueue.length > 0) {
//      currBadge = badgeUpdateQueue[0];
//      badgeUpdateQueue.removeAt(0);
//      if (currBadge > showAbove) this.opacity = 1.0;
//      else this.opacity = 0.0;
//    }
//  }
  
  void onAnimationQueueEnd ([ FaviconFrame currentFrame ]) {
  
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
    // TODO: Expose this padding somehow when everything looks right...
    int paddingLR = 4;
    int paddingTB = 4;
    
    String badgeText = convertBadgeToText(currBadge);
    ctx.font = "$fontStyle ${fontSize}px $fontFamily";   
    ctx.textBaseline="middle"; 
    double fontWidth = ctx.measureText(badgeText).width;
    if (this.adaptiveFontSize) {
      // TODO: Dont use loops like this pretty evil!
      while ((fontWidth + paddingLR) <= this.parent.size && this.fontSize < this.maxFontSize) {
        this.fontSize += 0.01;
        ctx.font = "$fontStyle ${fontSize}px $fontFamily";   
        fontWidth = ctx.measureText(badgeText).width;
      }
      while ((fontWidth + paddingLR) >= this.parent.size) {
        this.fontSize -= 0.01;
        ctx.font = "$fontStyle ${fontSize}px $fontFamily";   
        fontWidth = ctx.measureText(badgeText).width;
      }
    }
    // Estimated font height 
    double fontHeight = ctx.measureText("M").width; // Yeah! Because that makes sense right... 
        
    this.width = fontWidth + paddingLR;
    this.height = fontHeight + paddingTB;
   
    backgroundColor.alphaMod = opacity;  
    ctx.fillStyle = backgroundColor.toString();   
    switch (position) {
      case Position.TOP_LEFT:
        ctx.translate(2, 2);
        break;
      case Position.TOP_RIGHT:
        ctx.translate(parent.size - width - padding, 2);
        break;
      case Position.BOTTOM_LEFT:
        ctx.translate(2, parent.size - height - padding);
        break;

      case Position.BOTTOM_RIGHT:
        ctx.translate(parent.size - width - padding, parent.size - height - padding);
        break;
    }
    
    // TODO: Expose this somehow
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
    ctx.fillText(convertBadgeToText(currBadge), x + (paddingLR / 2), y + (height / 2));  
    
  }
  
  void onUpdate (double deltaT) {
     
  }
  
  void clearBadgeQueue() {
   // badgeUpdateQueue = new List<int>();
  }
  
  void badge (int updateNumber) {
    currBadge = updateNumber;
  //  badgeUpdateQueue.add(updateNumber);
  }
}