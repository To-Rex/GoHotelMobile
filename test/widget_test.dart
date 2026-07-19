import 'package:flutter_test/flutter_test.dart';
import 'package:gohotels/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GoHotelApp());
    await tester.pumpAndSettle();
    expect(find.text('GoHotel Service'), findsWidgets);
  });
}
