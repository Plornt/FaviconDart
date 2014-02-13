part of FaviconDart;

void _loadWaitTransitions () {
  FaviconDrawable.registerTransition(const Symbol ("wait"), (FaviconDrawable drawable, double deltaT, List parameters, FaviconTween item) {
    print(item.duration); 
    return (item.duration >= parameters[0]);
  });
}