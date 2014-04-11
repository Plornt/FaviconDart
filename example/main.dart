import 'package:favicon_dart/favicon_dart.dart';
import 'dart:html';
import 'dart:async';

void main () {
  window.onLoad.listen((ev) { 
    
    /* Please note, this is not the best examples to go by as 
     * the code had to be duplicated due to having multiple favicons
     * on the demo page. I will at some point make some better example code
     * but you are probably better off from visiting the demo page in your
     * browser as it has examples listed with the relevant code required.
     * 
     * This is essentially the example code for the example site.
     */
    
    /*  MAIN PAGE EXAMPLE */
    
    // Select the main page favicon image
    ImageElement exOneImg = querySelector("#ex_one");

    // Clone image element so it doesnt replace with its own contents again.
    ImageElement baseFavicon = exOneImg.clone(false);
    
    // Create a favicon for the tab bar
    Favicon mainFCon = new Favicon(size: 32);
    // Create a favicon for the big demo
    Favicon icon = new Favicon(destinationElement: exOneImg, size: 320);
    // Create the badges
    Badge badge = new Badge (maxFontSize: 200, fontFamily: "sans-serif", fontStyle: "bold");
    Badge mainFConBadge = new Badge (maxFontSize: 20, fontFamily: "sans-serif", fontStyle: "bold");
    // Add the sources to the main favicon tab bar
    mainFCon.addElement(new IconSource());
    mainFCon.addElement(mainFConBadge);   
   
    icon.addElement(new Source(baseFavicon));
    icon.addElement(badge);
    
    // Global variables to hold our video sources
    Source videoSource;
    Source mainFConVideoSource;
    
    // Lots of code duplication for the buttons
    // TODO: Clean this up.
    ButtonElement b = querySelector("#ex_one_p1");
    b.onClick.listen((ev) { 
        exampleOneChangeBadge(badge, mainFConBadge, 1);
    });
    ButtonElement b10 = querySelector("#ex_one_p10");
    b10.onClick.listen((ev) { 
      exampleOneChangeBadge(badge, mainFConBadge, 10);
    });
         
    ButtonElement bm1 = querySelector("#ex_one_m1");
    bm1.onClick.listen((ev) { 
      exampleOneChangeBadge(badge, mainFConBadge, -1);
    });
    
    ButtonElement bm10 = querySelector("#ex_one_m10");
    bm10.onClick.listen((ev) { 
      exampleOneChangeBadge(badge, mainFConBadge, -10);
    });
    
    // Reset button 
    // Resets the video if its currently running too.
    ButtonElement bReset = querySelector("#ex_one_reset");
    bReset.onClick.listen((ev) { 
      badge.stop(true);
      badge.clearCurrent();
      exampleOneBadgeNum = 0;
      badge.badge(0);
     
      if (videoSource != null) {
        mainFCon.elements.remove(mainFConVideoSource);
        icon.elements.remove(videoSource);
        mainFConVideoSource = null;
        videoSource = null;
      }
    });
    
    ButtonElement bVideo = querySelector("#ex_one_video");
    bVideo.onClick.listen((ev) { 
      // Create the HTML video element with relevant sources
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
      
      // Create a new *favicon* source with our video element
      videoSource = new Source(v);
      mainFConVideoSource = new Source(v);
      
      // Add them to the favicon and bring the badge to the front of the favicon
      mainFCon.addElement(mainFConVideoSource);
      icon.addElement(videoSource); 
      mainFCon.bringToFront(mainFConBadge);
      icon.bringToFront(badge);
    });
    
    /* Mini Demos */
    Badge ex2badge = new Badge();
    Example exampleTwo = new Example("two",(Favicon f) {
      f.addElement(new Source(baseFavicon));
      f.addElement(ex2badge);
    }, (int badgeNum) { 
      ex2badge.badge(badgeNum);
    });
    
    Badge ex3badge = new Badge();
     Example exampleThree = new Example("three",(Favicon f) {
       f.addElement(new Source(baseFavicon));
       f.addElement(ex3badge);
     }, (int badgeNum) { 
       ex3badge..fadeInBadge(badgeNum);
     });
     
     Badge ex4badge = new Badge();
        Example exampleFour = new Example("four",(Favicon f) {
          f.addElement(new Source(baseFavicon));
          f.addElement(ex4badge);
        }, (int badgeNum) { 
          ex4badge.slideInBadge(badgeNum, "up", startInstantly: true);
        });
       
    
  });   
}

int exampleOneBadgeNum = 0;
void exampleOneChangeBadge (Badge b, Badge b2, int number) {
  exampleOneBadgeNum += number;
  // Update the badge with a "pop" animation
  b..stop(true)
   ..transitionBadge(exampleOneBadgeNum, queue: true)
   ..resize(1.0, startingScale: 0.0, duration: 400, queue: true)
   ..play(); 
   
  b2..stop(true)
    ..transitionBadge(exampleOneBadgeNum, queue: true)
    ..resize(1.0, startingScale: 0.0, duration: 400, queue: true)
    ..play(); 
}

class Example {
  String ex;
  Favicon fav;
  int badgeNum = 0;
  Favicon f;
  Example (this.ex, Function onCreate, Function onClickBadge) {
    ButtonElement minusOne = querySelector('#ex_${ex}_m1');
    ButtonElement plusOne = querySelector('#ex_${ex}_p1');
    f = new Favicon(destinationElement: querySelector("#ex_${ex}_icon") ,size: 16);
    onCreate(f);
    minusOne.onClick.listen((ev) { badgeNum--; onClickBadge(badgeNum); });
    plusOne.onClick.listen((ev) { badgeNum++; onClickBadge(badgeNum); });
  }
}


