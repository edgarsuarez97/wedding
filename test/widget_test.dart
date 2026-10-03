import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_g_and_e/app.dart';
import 'package:wedding_g_and_e/ui/features/intro/views/gatefold_intro.dart';

void main() {
  testWidgets('Muestra la portada sellada al entrar al sitio', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const WeddingApp());

    expect(find.byType(GatefoldIntro), findsOneWidget);
    expect(find.text('Toca el sello para abrir'), findsOneWidget);
  });

  testWidgets('Un toque en el sello abre las puertas y muestra el sitio', (
    WidgetTester tester,
  ) async {
    var opened = false;
    await tester.pumpWidget(
      MaterialApp(home: GatefoldIntro(onOpened: () => opened = true)),
    );

    await tester.tap(find.byKey(const ValueKey('envelope-seal')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    expect(opened, isFalse);

    await tester.pump(const Duration(seconds: 1));
    expect(opened, isTrue);
  });
}
