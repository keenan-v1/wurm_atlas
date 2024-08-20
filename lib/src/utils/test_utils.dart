import 'package:logging/logging.dart';

class TestUtils {
  static void enableLogging() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord r) {
      // ignore: avoid_print
      print('${r.loggerName}(${r.level}): ${r.message}');
    });
  }
}
