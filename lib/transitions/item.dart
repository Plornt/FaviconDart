part of FaviconDart;

typedef bool FaviconTransition (FaviconElement drawable, double deltaT, List parameters, TransitionItem item);

/***
 * Container for an transition element including any parameters given and the current state of the transition
 */
class TransitionItem {  
  /// Completer to return once the transition has completed
  Completer c = new Completer();
  bool forceStopped = false;
  
  State toState;
      
  TransitionItem (this.toState);
}