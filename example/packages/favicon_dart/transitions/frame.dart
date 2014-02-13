part of FaviconDart;

class FaviconFrame {
  Completer c = new Completer();
  List<FaviconTween> transitions = new List<FaviconTween>();
  int frameNumber = 0;
  bool get isFirstFrame {
    return frameNumber == 0;
  }
  FaviconFrame();
  void add (FaviconTween item) { 
    transitions.add(item);
  }
}