part of FaviconDart;

/// Used to optimise *NOT* to feature detect
class BrowserDetect {
  /***
   * Takes the useragent string and does a few string checks to see what type of browser it is
   * 
   * Returns an int representation of the browser.
   */
  static int detect (String UA) {
    UA = UA.toLowerCase();
    if (UA.indexOf("opera") != -1) return OPERA;
    if (UA.indexOf("firefox") != -1) return FIREFOX;
    if (UA.indexOf("chrome") != -1) return CHROME;
    if (UA.indexOf("safari") != -1) return SAFARI;
    if (UA.indexOf("msie") != -1 || UA.indexOf("trident") != -1) return INTERNET_EXPLORER;
    if (UA.indexOf("webkit") != -1) return UNKNOWN_WEBKIT;
    return UNKNOWN;
  }
  static int FIREFOX = 1;
  static int OPERA = 2;
  static int CHROME = 3;
  static int INTERNET_EXPLORER = 4;
  static int SAFARI = 5;
  static int UNKNOWN_WEBKIT = 6;
  static int UNKNOWN = 6;
}
