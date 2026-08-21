import 'package:flutter_test/flutter_test.dart';

import 'package:santv_app/main.dart';

void main() {
  testWidgets('SanTV app carga correctamente', (WidgetTester tester) async {
    // Construye la app y dispara un frame.
    await tester.pumpWidget(const SanTvApp());

    // Verifica que el título "SAN TV" del header aparece.
    expect(find.text('SAN TV'), findsOneWidget);
  });
}