import 'package:flutter_test/flutter_test.dart';
import 'package:team_3_f25_project/utils/speech_timeout.dart';

void main() {
  group('shouldStopListening', () {
    test('returns false before the timeout duration is reached', () {
      expect(
        shouldStopListening(
          const Duration(seconds: 7),
          const Duration(seconds: 8),
        ),
        isFalse,
      );
    });

    test('returns true once the elapsed time reaches the timeout duration', () {
      expect(
        shouldStopListening(
          const Duration(seconds: 8),
          const Duration(seconds: 8),
        ),
        isTrue,
      );
    });
  });
}
