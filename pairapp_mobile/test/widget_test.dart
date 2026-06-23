import 'package:flutter_test/flutter_test.dart';
import 'package:pairapp_mobile/main.dart';

void main() {
  testWidgets('PairApp starts', (WidgetTester tester) async {
    await tester.pumpWidget(const PairApp());

    expect(find.text('PairApp mobile started'), findsOneWidget);
  });
}