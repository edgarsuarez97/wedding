import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_g_and_e/app.dart';
import 'package:wedding_g_and_e/ui/features/intro/views/envelope_intro.dart';

void main() {
  testWidgets('Muestra el sobre sellado al entrar al sitio', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const WeddingApp());

    expect(find.byType(EnvelopeIntro), findsOneWidget);
    expect(find.text('Toca el sello para abrir'), findsOneWidget);
    expect(find.text('Ver invitación'), findsNothing);
  });

  testWidgets('Abrir el sello revela la tarjeta y luego avisa al sitio', (
    WidgetTester tester,
  ) async {
    var opened = false;
    await tester.pumpWidget(
      MaterialApp(home: EnvelopeIntro(onOpened: () => opened = true)),
    );

    await tester.tap(find.byKey(const ValueKey('envelope-seal')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Ver invitación'), findsOneWidget);
    expect(opened, isFalse);

    await tester.tap(find.text('Ver invitación'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(opened, isTrue);
  });
}
