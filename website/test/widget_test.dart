import 'package:flutter_test/flutter_test.dart';
import 'package:peekit_plugins_site/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PeekItPluginsApp());
    expect(find.byType(PeekItPluginsApp), findsOneWidget);
  });
}
