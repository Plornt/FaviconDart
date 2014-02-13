part of FaviconDart;

class FaviconFrame {
  Completer c = new Completer();
  List<TransitionItem> transitions = new List<TransitionItem>();
  int frameNumber = 0;
  bool get isFirstFrame {
    return frameNumber == 0;
  }
  FaviconFrame();
  void add (TransitionItem item) { 
    transitions.add(item);
  }
}