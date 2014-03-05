import 'package:favicon_dart/favicon_dart.dart';
import 'dart:html';
import 'dart:async';

void main () {
  window.onLoad.listen((ev) { 
  LinkElement img = new LinkElement();
  img.rel = "icon";
  img.type = "image/png";

  
  
 // ImageElement img = new ImageElement();
  
  Favicon icon = new Favicon(destinationElement: img, size: 16);
  Badge badge = new Badge (maxFontSize: 12, fontFamily: "sans-serif", fontStyle: "bold");
  
  icon.addElement(new IconSource());
  
  
  /* VIDEO TEST */
//    VideoElement v = new VideoElement();
//    SourceElement vSource = new SourceElement();
//    vSource.src = "chromeicon.webm";
//    SourceElement vSourceOther = new SourceElement();
//    vSourceOther.src = "chromeicon.mp4";
//    
//    v.append(vSource);
//    v.append(vSourceOther);
//    v.style.display = "none";
//    v.autoplay = true;
//    v.loop = true;
//    document.body.append(v);
//    Source videoSource = new Source(v);
//    icon.addElement(videoSource); 

  
  /* CANVAS TEST */
//    CanvasElement c = new CanvasElement();
//    c.width = 32;
//    c.height = 32;
//    CanvasRenderingContext2D ctx = c.getContext("2d");
//    RGBA colour = new RGBA(0,0,0);
//    new Timer.periodic(new Duration(milliseconds: 33), (t) { 
//      colour.r += 10;
//      colour.g += 5;
//      colour.b += 3;
//      ctx.fillStyle = colour.toString();
//      ctx.fillRect(0, 0, 32, 32);
//    });
//    Source fcs = new Source (c);
//    icon.addElement(fcs);  
//  
  
  icon.addElement(badge);
  
  document.head.append(img);
    
    ButtonElement b = new ButtonElement();
    b.innerHtml = "+ 1";
    int badgeNum = 1;
    b.onClick.listen((ev) { 
      badgeNum+= 1;
      print("Pressed $badgeNum");
      updateBadge(badge, badgeNum);
    });
    document.body.append(b);
    //document.body.append(img);
  });   
}

void updateBadge (Badge badge, int n) { 
  print("Start transition");
  badge..opacity = 1.0
       ..stop()
       ..transition({ "x": 0.0 }, duration: 500).listen((t) { 
           if (t.type == TransitionEventType.BEGIN) {
             badge.x = badge.parent.size.toDouble();
              badge.badge(n);
           }
           else if (t.type == TransitionEventType.STOP ) {
             badge.badge(n);
           }
        });
}


