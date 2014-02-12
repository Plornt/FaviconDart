part of FaviconDart;


void _loadFadeTransitions () {
  
  bool fade (FaviconDrawable drawable, double deltaT, List parameters, FavicoTween item) {
    int duration = (parameters.length >= 1 && parameters[0] is int ? parameters[0] : 1000);
    num targetOpacity = (parameters.length >= 2 && parameters[1] is num ? parameters[1] : 1.0);
    bool isComplete = false;
    bool towards = false;
    double opacityStep;
    if (item.isFirstFrame) {
      item.state["towards"] = drawable.opacity < targetOpacity; 
      towards = drawable.opacity < targetOpacity;
      opacityStep = (max(targetOpacity, drawable.opacity) - min(targetOpacity, drawable.opacity)) / duration;
      if (!towards) opacityStep = - opacityStep;

      item.state["opacityStep"] = opacityStep;
      drawable.targetOpacity = targetOpacity;
    }
    else {
      opacityStep = item.state["opacityStep"];
      towards = item.state["towards"];
    }
    
    drawable.opacity += (opacityStep * deltaT);
    if ((towards && drawable.opacity > targetOpacity) || (!towards && drawable.opacity < targetOpacity)){
      drawable.opacity = targetOpacity;
      isComplete = true;
    }
    return isComplete;
  }

  FaviconDrawable.registerTransition(const Symbol ("fade"), fade);
  FaviconDrawable.registerTransition(const Symbol ("fadeIn"), (FaviconDrawable drawable, double deltaT, List parameters, FavicoTween item) {
     if (item.isFirstFrame) drawable.opacity = 0.0; 
     return fade (drawable, deltaT, [parameters.length > 0 ? parameters[0] : 1000, 1.0], item);
  });
  FaviconDrawable.registerTransition(const Symbol ("fadeOut"), (FaviconDrawable drawable, double deltaT, List parameters, FavicoTween item) {
     return fade (drawable, deltaT, [parameters.length > 0 ? parameters[0] : 1000, 0.0], item);
  });
}