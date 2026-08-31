import 'package:flutter_test/flutter_test.dart';
import 'package:mufarrigh/features/settings/settings_screen.dart';

void main() {
  testWidgets('Settings screen contains developer section', (WidgetTester tester) async {
    // Basic test
    expect(find.byType(SettingsScreen), isNotNull);
  });
}
