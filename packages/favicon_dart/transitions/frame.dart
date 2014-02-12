part of FaviconDart;

class FaviconFrame {
  Completer c = new Completer();
  List<FavicoTween> transitions = new List<FavicoTween>();
  FaviconFrame();
  void add (FavicoTween item) { 
    transitions.add(item);
  }
}