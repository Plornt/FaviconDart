part of FaviconDart;

void _loadWaitTransitions () {
  FaviconDrawable.registerTransition(const Symbol ("wait"), (FaviconDrawable drawable, double deltaT, List parameters, FavicoTween item) {
      return (item.duration >= parameters[0]);
  });
}