part of FaviconDart;

/***
 * Manages an RGBA representation of a colour
 */
class RGBA {
  int _r = 0;
  int _g = 0;
  int _b = 0;
  num a = 0;
  
  /// Alpha modifier is the amount to modify the 
  /// alpha channel by.
  num alphaMod = 1.0;
  
  set r (int r) {
    _r = r % 255;
  }
  set g (int r) {
    _g = r % 255;
  }
  set b (int r) {
    _b = r % 255;
  }
  
  /// Retreive the red colour value
  int get r => _r;
  /// Retreive the green colour value
  int get g => _g;
  /// Retreive the blue colour value
  int get b => _b;
  
  /***
   * Creates a RGBA object with the supplied values.
   * 
   * [r] is the Red channel
   * [g] is the Green channel
   * [b] is the Blue channel
   * 
   * Optionally supply an [a](alpha) channel.
   */
  RGBA (this._r, this._g, this._b,[ this.a = 1.0 ]);
  
  
  String toString () {
    return "rgba($_r, $_g, $_b, ${a * alphaMod})";
  }
  
}
