part of FaviconDart;

void _loadSlideTransitions () {
  bool slide (FaviconDrawable drawable, double deltaT, List parameters, FavicoTween item) {
                //Map<String, bool>
                int duration = parameters.length > 1 && parameters[1] is int ? parameters[1] : 1000;
                bool isIn = parameters.length > 2 && parameters[2] is bool ? parameters[2] : true;
                Map<String, bool> directions = parameters[0];
                bool isComplete = true;
                
                if (directions.containsKey("left") || directions.containsKey("right")) {
                 bool isLeft = directions["left"] == true;
                 
                 // Reset our target location so we can slide in or out
                 if (item.isFirstFrame) {
                     if (isIn) {
                       drawable.targetX = 0;
                       drawable.x = (isLeft  == true ? drawable.parent.size: 0 - drawable.parent.size);
                      
                     }
                     else drawable.x = (isLeft  == true ? 0 - drawable.parent.size : drawable.parent.size);
                 }
                 
                 // Step per millisecond
                 num step = (max(drawable.targetX, drawable.scaledWidth) - min(drawable.targetX, drawable.scaledWidth)) / duration;
                 
                 // Move our current location relative to the duration of the animation and time elapsed
                 if (isLeft) drawable.x -= step * deltaT;
                 else drawable.x += step * deltaT;
                 
                 // Check if weve gone past the target, if so, jump to the target and complete the animation
                 if ((isLeft && drawable.x < drawable.targetX) || (!isLeft && drawable.x > drawable.targetX)) {
                    drawable.x = drawable.targetY;
                 }
                 else isComplete = false;
               }
                
                if (directions.containsKey("up") || directions.containsKey("down")) {
                  bool isUp = directions["up"] == true;
                  
                  // Reset our target location so we can slide in or out
                  if (item.isFirstFrame) {
                      if (isIn) {
                        drawable.targetY = 0;
                        drawable.y = (isUp  == true ? drawable.parent.size : 0 - drawable.parent.size);
                      }
                      else drawable.y = (isUp  == true ? 0 - drawable.parent.size : drawable.parent.size);
                  }
                  
                  // Step per millisecond
                  num step = (max(drawable.targetY, drawable.scaledHeight) - min(drawable.targetY, drawable.scaledHeight)) / duration;
                  // Move our current location relative to the duration of the animation and time elapsed
                  if (isUp) drawable.y -= step * deltaT;
                  else drawable.y += step * deltaT;
                  
                  // Check if weve gone past the target, if so, jump to the target and complete the animation
                  if ((isUp && drawable.y < drawable.targetY) || (!isUp && drawable.y > drawable.targetY)) {
                     drawable.y = drawable.targetY;
                  }
                  else isComplete = false;
                }
                
                return isComplete;
              }
       FaviconDrawable.registerTransition(const Symbol("slide"), slide);
       
       // Slide ins
       FaviconDrawable.registerTransition(const Symbol ("slideInUp"), (FaviconDrawable drawable, double deltaT, List parameters, FavicoTween item) {
         return slide (drawable, deltaT, [{ "up": true }, parameters.length > 0 ? parameters[0] : 1000], item);
       });
       FaviconDrawable.registerTransition(const Symbol ("slideInDown"), (FaviconDrawable drawable, double deltaT, List parameters, FavicoTween item) {
         return slide (drawable, deltaT, [{ "down": true }, parameters.length > 0 ? parameters[0] : 1000], item);
       });
       FaviconDrawable.registerTransition(const Symbol ("slideInLeft"), (FaviconDrawable drawable, double deltaT, List parameters, FavicoTween item) {
         return slide (drawable, deltaT, [{ "left": true }, parameters.length > 0 ? parameters[0] : 1000], item);
       });
       FaviconDrawable.registerTransition(const Symbol ("slideInRight"), (FaviconDrawable drawable, double deltaT, List parameters, FavicoTween item) {
         return slide (drawable, deltaT, [{ "right": true }, parameters.length > 0 ? parameters[0] : 1000], item);
       });
       
       // Slide outs

       FaviconDrawable.registerTransition(const Symbol ("slideOutUp"), (FaviconDrawable drawable, double deltaT, List parameters, FavicoTween item) {
         return slide (drawable, deltaT, [{ "up": true }, parameters.length > 0 ? parameters[0] : 1000, false], item);
       });
       FaviconDrawable.registerTransition(const Symbol ("slideOutDown"), (FaviconDrawable drawable, double deltaT, List parameters, FavicoTween item) {
         return slide (drawable, deltaT, [{ "down": true }, parameters.length > 0 ? parameters[0] : 1000, false], item);
       });
       FaviconDrawable.registerTransition(const Symbol ("slideOutLeft"), (FaviconDrawable drawable, double deltaT, List parameters, FavicoTween item) {
         return slide (drawable, deltaT, [{ "left": true }, parameters.length > 0 ? parameters[0] : 1000, false], item);
       });
       FaviconDrawable.registerTransition(const Symbol ("slideOutRight"), (FaviconDrawable drawable, double deltaT, List parameters, FavicoTween item) {
         return slide (drawable, deltaT, [{ "right": true }, parameters.length > 0 ? parameters[0] : 1000, false], item);
       });
       
}