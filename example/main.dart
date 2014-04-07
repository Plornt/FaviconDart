import 'package:favicon_dart/favicon_dart.dart';
import 'dart:html';
import 'dart:async';

void main () {
  window.onLoad.listen((ev) { 
  
  
 // ImageElement img = new ImageElement();
//  LinkElement link = new LinkElement();
//  link.rel = "shortcut icon";
//  link.href = "favicon.png";
//  link.type = "image/png";
//  document.head.append(link);
  Favicon icon = new Favicon(destinationElement: querySelector("#favicon"), size: 16);
  Badge badge = new Badge (maxFontSize: 9, fontFamily: "sans-serif", fontStyle: "bold", backgroundColor: new RGBA(0, 150, 0), fontColor: new RGBA(255,255,100));
  
  icon.addElement(new IconSource());
  
  
  /* VIDEO TEST */
    VideoElement v = new VideoElement();
    SourceElement vSource = new SourceElement();
    vSource.src = "chromeicon.webm";
    SourceElement vSourceOther = new SourceElement();
    vSourceOther.src = "chromeicon.mp4";
    v.volume = 0.0;
    v.append(vSource);
    v.append(vSourceOther);
    v.style.display = "none";
    v.autoplay = true;
    v.loop = true;
    document.body.append(v);
    Source videoSource = new Source(v);
    icon.addElement(videoSource); 

  
  /* CANVAS TEST */
//    CanvasElement c = new CanvasElement();
//    c.width = 32;
//    c.height = 32;
//    CanvasRenderingContext2D ctx = c.getContext("2d");
//    RGBA colour = new RGBA(10,30,50);
//    new Timer.periodic(new Duration(milliseconds: 33), (t) { 
//      colour.r += 5;
//      colour.g += 5;
//      colour.b += 5;
//      ctx.fillStyle = colour.toString();
//      ctx.fillRect(0, 0, 32, 32);
//    });
//    Source fcs = new Source (c);
//    icon.addElement(fcs);  
//  
  
  icon.addElement(badge);
  
    
    ButtonElement b = new ButtonElement();
    b.innerHtml = "+ 1";
    int badgeNum = 0;
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
  badge.wait(duration: 5000, startInstantly: true).listen((TweenEvent t) { 
    if (t.type == TweenEventType.BEGIN){
      badge.x = 0.0;
      badge.y = 0.0;  
    }
    if (t.type != TweenEventType.STEP) {
      badge.badge(n);
    }    
  });
  badge.slideOut("right", duration: 1000);
}


