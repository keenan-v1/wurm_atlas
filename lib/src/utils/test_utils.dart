import 'package:logging/logging.dart';

class TestUtils {
  static void enableLogging(Level? level) {
    Logger.root.level = level ?? Level.ALL;
    Logger.root.onRecord.listen((LogRecord r) {
      // ignore: avoid_print
      print('[${r.level}] ${r.loggerName}: ${r.message}');
    });
  }
}
