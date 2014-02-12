part of FaviconDart;

typedef bool FaviconTransition (FaviconDrawable drawable, double deltaT, List parameters, FavicoTween item);

/***
 * Container for an transition element including any parameters given and the current state of the transition
 */
class FavicoTween {
  /// Symbol representing the transition method name
  Symbol animationName;
  
  /// Completer to return once the transition has completed
  Completer c = new Completer();
  
  /// Current duration elapsed of the transition
  double duration = 0.0;
  
  /// Current frame number of the transition
  int frameNumber = 0;  
  
  bool get isFirstFrame {
    return frameNumber == 0;
  }  
  
  /// Contains the state of the transition. Can be used to store values between transition frames/
  Map state = new Map();
  
  /// List of parameters provided when the transition was queued
  List parameters;  
  
  FavicoTween (this.animationName, this.parameters);
}