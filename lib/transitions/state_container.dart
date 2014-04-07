part of FaviconDart;

class TweenStateContainer {
  Map<String, dynamic> state;
  Map<String, int> durations = new Map<String, int>();
  TweenStateContainer(this.state) {
    
  }
  
  dynamic get (String key) {
    if (state.containsKey(key)) {
      return state[key];
    }
    return null;
  }
  
  void setTransitionDuration (String key, int duration) {
    durations[key] = duration;
  }
  
  int getDuration (String key) {
    return durations[key];
  } 
  void set(String key, dynamic val) {
    state[key] = val;
  }
  
  void addNum (String key, num amount) {
//    print("$key => $amount");
    if (state.containsKey(key)) {
      if (state[key] is num) {
        state[key] += amount;
      }
    }
    else {
      state[key] = amount;
    }
  }
  
  void merge (TweenStateContainer otherState) {
    otherState.state.forEach((String key, dynamic val) { 
      if (val is num) this.addNum(key, val);
      else 
        state[key] = val;
    });
  }
  
  void override (Map <String, dynamic> state) {
    this.state.addAll(state);
  }
    
  TweenStateContainer clone () {
    Map<String, dynamic> clonedCopy = new Map<String, dynamic>();
    clonedCopy.addAll(this.state);
    return new TweenStateContainer(clonedCopy);
  }
}
