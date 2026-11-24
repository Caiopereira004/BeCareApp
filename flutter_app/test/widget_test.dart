import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowup_flutter/main.dart';
import 'package:glowup_flutter/widgets/glowup_logo.dart';

void main() {
  testWidgets('Renderiza logo GlowUp e campos iniciam vazios', (WidgetTester tester) async {
    await tester.pumpWidget(const GlowUpApp());
    expect(find.byType(GlowUpLogo), findsOneWidget);
    expect(find.text('Bem-vindo ao GlowUp'), findsOneWidget);
  });
}
