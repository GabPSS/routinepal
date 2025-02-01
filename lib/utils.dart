abstract final class Utils {
  static DateTime today() {
    var today = DateTime.now();
    return DateTime(today.year, today.month, today.day);
  }
}
