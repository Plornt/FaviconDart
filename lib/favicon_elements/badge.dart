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
  int padding = 0;
  int showAbove = 0;
  num maxFontSize;
  bool adaptiveFontSize;
  num fontSize;
  
  
  TweenStateContainer state = new TweenStateContainer({
                                          "x": 0.0,
                                          "y": 0.0,
                                          "opacity": 0.0,
                                          "scale": 1.0,
                                          "container_width": 0.0,
                                          "container_height": 0.0,
                                          "wait": 0.0,
                                          "currBadge": 0
                                        });
  

 set currBadge (int num) => state.set("currBadge", num);
 int get currBadge => state.get("currBadge").toInt();
 
  
  
  Badge ({ this.backgroundColor,
                  this.fontColor, 
                  this.maxFontSize: 9,
                  this.adaptiveFontSize: true,
                  this.fontFamily: "sans-serif", 
                  this.fontStyle: "bold",
                  this.type: "rounded", 
                  this.position: Position.BOTTOM_RIGHT, 
                  this.padding: 1,
                  this.showAbove: 0
                  }) {
    if (currBadge > showAbove) this.opacity = 1.0;
    else this.opacity = 0.0;
    this.fontSize = this.maxFontSize;
   if (this.backgroundColor == null) backgroundColor = new RGBA (255, 0, 0);
   if (this.fontColor == null) fontColor = new RGBA (255,255,255);
  }
  
  
  String convertBadgeToText (int badgeNum) {
    // Heh... You know for when you have a million notifications!
    if (badgeNum > 999999) {
       return "${(badgeNum / 1000000).toStringAsFixed(1)}m";
    }
    if (badgeNum > 999) {
      return "${(badgeNum / 1000).toStringAsFixed(0)}k+";
    }
    return badgeNum.toString();
  }
  
  void onDraw (CanvasRenderingContext2D ctx) {
    ctx.save();
    // TODO: Expose this padding somehow when everything looks right...
    int paddingLR = 2;
    int paddingTB = 4;
    
    String badgeText = convertBadgeToText(currBadge);
    ctx.font = "$fontStyle ${fontSize}px $fontFamily";   
    ctx.textBaseline="middle"; 
    double fontWidth = ctx.measureText(badgeText).width;
    if (this.adaptiveFontSize) {
      
      fontSize = (fontSize * ((((this.parent.size - paddingLR - padding) / fontWidth) * 100).round() / 100)).floor();
 
      if (fontSize > maxFontSize) {
        fontSize = maxFontSize;
      }
      ctx.font = "$fontStyle ${fontSize}px $fontFamily";   
      fontWidth = ctx.measureText(badgeText).width;        
    }
    // Estimated font height 
    double fontHeight = ctx.measureText("M").width; // Yeah! Because that makes sense right... 
        
    this.width = fontWidth + paddingLR;
    this.height = fontHeight + paddingTB;
   
    backgroundColor.alphaMod = opacity;  
    ctx.fillStyle = backgroundColor.toString();   
    num offsetX = 0;
    num offsetY = 0;
    switch (position) {
      case Position.TOP_LEFT:
        ctx.translate( padding,  padding);
        break;
      case Position.TOP_RIGHT:
        ctx.translate(parent.size - (width / 2) - padding, padding);
        offsetX = width / 2;
        break;
      case Position.BOTTOM_LEFT:
        ctx.translate( padding, parent.size - (height / 2) - padding);
        offsetY = height / 2;
        break;

      case Position.BOTTOM_RIGHT:
        ctx.translate(parent.size - (width / 2) - padding, parent.size - (height / 2) - padding);
        offsetX = width / 2;
        offsetY = height / 2;
        break;
    }

    ctx.scale(this.scale, this.scale);
    
    
    // TODO: Expose this somehow
    num r = 5;   
    
    // http://stackoverflow.com/questions/1255512/how-to-draw-a-rounded-rectangle-on-html-canvas
    // TODO: Fix this properly
    if (type == "rounded") {
     
        if (width < 2 * r) r = width / 2;
        if (height < 2 * r) r = height / 2;
        ctx.beginPath();
        ctx.moveTo(x+r-offsetX, y-offsetY);
        ctx.arcTo(x+width-offsetX, y-offsetY,   x+width-offsetX, y+height-offsetY, r);
        ctx.arcTo(x+width-offsetX, y+height-offsetY, x-offsetX,   y+height-offsetY, r);
        ctx.arcTo(x-offsetX,   y+height-offsetY, x-offsetX,   y-offsetY,   r);
        ctx.arcTo(x-offsetX,   y-offsetY,   x+width-offsetX, y-offsetY,   r);
        ctx.closePath();
        ctx.fill();
    }
    else { 
      ctx.fillRect(x-offsetX, y-offsetY, width, height);
    }
    fontColor.alphaMod = opacity;
    ctx.fillStyle = fontColor.toString();
    ctx.fillText(convertBadgeToText(currBadge), (x - offsetX) + (paddingLR / 2), (y - offsetY) + (height / 2));  
    ctx.restore();
  }
  
  void onUpdate (double deltaT) {
     
  }
  
  void checkBadgeOpacity () {
    if (currBadge > showAbove) {
      if (this.opacity == 0.0) this.opacity = 1.0;
    }
    else {
      this.opacity = 0.0;
    }
  }
  
  void badge (int updateNumber, { bool doOpacityCheck: true }) {
    currBadge = updateNumber;
    if (doOpacityCheck) {
      checkBadgeOpacity();
    }
  }
  
  TweenItem transitionBadge (int badgeNum, { int duration: 0, bool cancelable: false, bool startInstantly: false, bool queue: false, bool doOpacityCheck: true}) {
    return this.transition({ "currBadge": badgeNum }, duration: duration, addToQueue: queue)..listen((TweenEvent te) { 
      if (te.type == TweenEventType.STOP && cancelable == false)  {
        this.badge(badgeNum, doOpacityCheck: doOpacityCheck);
      }
      if (doOpacityCheck && te.type == TweenEventType.STEP){ 
        checkBadgeOpacity();
      }
    });
  }
  
  
 TweenItem fadeInBadge (int badgeNum, { int duration: 500, bool startInstantly: false, double initialOpacity: 0.0 }) {
   if (startInstantly) this.stop();
   this.fadeIn(duration: duration, queue: true, initialOpacity: initialOpacity);
   this.transitionBadge(badgeNum, queue: true);
   return this.play();
 }
 
 TweenItem fadeOutBadge (int badgeNum, { int duration: 500, bool startInstantly: false}) {
   if (startInstantly) this.stop();
   this.transitionBadge(badgeNum, queue: true);
   this.fadeOut(duration: duration, queue: true);
   return this.play();
 }
 
 TweenItem slideInBadge (int badgeNum, String direction, { int duration: 500, bool startInstantly: false, Map startState: null}) {
   if (startInstantly) this.stop();
   this.transitionBadge(badgeNum, queue: true);
   this.slideIn(direction, duration: duration, queue: true, startState: startState);
   return this.play();
 }
 
 TweenItem slideOutBadge (int badgeNum, String direction, { int duration: 500, bool startInstantly: false, Map startState: const { "x": 0.0, "y": 0.0 } }) {
   if (startInstantly) this.stop();
   this.transitionBadge(badgeNum, queue: true);
   this.slideOut(direction, duration: duration, queue: true, startState: startState);
   return this.play();
 }
}