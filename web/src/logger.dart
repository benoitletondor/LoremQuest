part of rpg;

class Logger {
  static debug(String aStr) {
    html.window.console.debug(aStr);
  }

  static warn(String aStr) {
    html.window.console.warn(aStr);
  }

  static error(String aStr) {
    html.window.console.error(aStr);
  }
}
