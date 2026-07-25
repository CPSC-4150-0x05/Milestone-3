import 'package:flutter_test/flutter_test.dart';
import 'package:team_3_f25_project/utils/list_assignment.dart';

void main() {
  group('resolveAssignedListId', () {
    test('returns the existing list id when one is already assigned', () {
      expect(resolveAssignedListId(3, 1), 3);
    });

    test('falls back to the default list id when none is assigned', () {
      expect(resolveAssignedListId(null, 1), 1);
    });
  });
}
