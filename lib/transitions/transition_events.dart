part of FaviconDart;

typedef bool FaviconTransition (FaviconElement drawable, double deltaT, List parameters, TweenItem item);


/***
 * ENUM of Transition Event Types
 */
class TweenEventType {
  final int type;
  const TweenEventType (this.type);
  
  static const TweenEventType STEP = const TweenEventType(2);
  static const TweenEventType STOP = const TweenEventType(1);
  static const TweenEventType BEGIN = const TweenEventType(0);
}

class TweenEvent {
  final TweenEventType type;
  final TweenItem item;
  TweenEvent(TweenEventType this.type, this.item);
}


/***
 * Container for an transition element including any parameters given and the current state of the transition
 */
class TweenItem {  
  bool forceStopped = false;
  
  StreamController<TweenEvent> _eventStreamController = new StreamController<TweenEvent>.broadcast();
  Stream get eS => _eventStreamController.stream;  
 
  /// State of the object the transition is to tween to
  TweenStateContainer toState;
  /// State of the object before the transition has begun
  TweenStateContainer fromState;
      
  TweenItem (this.toState);
  
  int frameNumber = 0;
  
  bool get isFirstFrame {
    return frameNumber == 0;
  }
  
  /***
   * Alias to streams listen function
   */
   StreamSubscription<TweenEvent> listen(void onData(TweenEvent t), {Function onError ,  void onDone(), bool cancelOnError}) {
    return eS.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
   
   /***
    * Listens to [eS] for any transition events of type [TransitionEventType.BEGIN]
    */
   void onBegin (void onTransitionBegin (TweenItem item)) {
     eS.listen((TweenEvent ev) { 
       if (ev.type == TweenEventType.BEGIN) {
         onTransitionBegin(ev.item);
       }
     });   
   }
   

   /***
    * Listens to [eS] for any transition events of type [TransitionEventType.STEP]
    */
   void onStep (void onTransitionStep (TweenItem item)) {
     eS.listen((TweenEvent ev) { 
       if (ev.type == TweenEventType.STEP) {
         onTransitionStep(ev.item);
       }
     });   
   }
   

   /***
    * Listens to [eS] for any transition events of type [TransitionEventType.STOP]
    */
   void onStop (void onStop (TweenItem item)) {
     eS.listen((TweenEvent ev) { 
        if (ev.type == TweenEventType.STOP) {
          onStop(ev.item);
        }
     });   
   }
   
   /***
    * Adds a transition event to the event stream
    */
   void _sendEvent (TweenEvent te) {
     if (!_eventStreamController.isClosed) {
       _eventStreamController.add(te);
       
       if (te.type == TweenEventType.STOP) {
         _eventStreamController.close();
       }
     }
   }
}