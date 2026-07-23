import 'package:flutter_test/flutter_test.dart';
import 'package:gohotels/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GoHotelApp());
    // pumpAndSettle ishlatilmaydi: login fonidagi ambient animatsiya uzluksiz.
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('GoHotel Service'), findsWidgets);
  });
}
