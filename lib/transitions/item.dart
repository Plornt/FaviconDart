part of FaviconDart;

typedef bool FaviconTransition (FaviconElement drawable, double deltaT, List parameters, TransitionItem item);

/***
 * Container for an transition element including any parameters given and the current state of the transition
 */
class TransitionItem {  
  bool forceStopped = false;
  
  StreamController<TransitionEvent> _eventStreamController = new StreamController<TransitionEvent>();
  Stream get eS => _eventStreamController.stream;  
 
  TransitionStateContainer toState;
  TransitionStateContainer fromState;
      
  TransitionItem (this.toState);
  
  int frameNumber = 0;
  
  bool get isFirstFrame {
    return frameNumber == 0;
  }
  
  /***
   * Alias to streams listen function
   */
   StreamSubscription<TransitionEvent> listen(void onData(TransitionEvent t), {Function onError ,  void onDone(), bool cancelOnError}) {
    return eS.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
   
   void onBegin (void onTransitionBegin (TransitionItem item)) {
     eS.listen((TransitionEvent ev) { 
       if (ev.type == TransitionEventType.BEGIN) {
         onTransitionBegin(ev.item);
       }
     });   
   }
   
   void onStep (void onTransitionStep (TransitionItem item)) {
     eS.listen((TransitionEvent ev) { 
       if (ev.type == TransitionEventType.STEP) {
         onTransitionStep(ev.item);
       }
     });   
   }
   
   void onStop (void onStop (TransitionItem item)) {
     eS.listen((TransitionEvent ev) { 
        if (ev.type == TransitionEventType.STOP) {
          onStop(ev.item);
        }
     });   
   }
   
   void _sendEvent (TransitionEvent te) {
     if (!_eventStreamController.isClosed) {
       _eventStreamController.add(te);
       
       if (te.type == TransitionEventType.STOP) {
         _eventStreamController.close();
       }
     }
   }
}