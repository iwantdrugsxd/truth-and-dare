import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:partizo/main.dart';

void main() {
  testWidgets('Game selection screen shows the three game tickets', (WidgetTester tester) async {
    await tester.pumpWidget(const PartizoApp());
    await tester.pump();

    expect(find.text('PARTIZO'), findsOneWidget);
    expect(find.text('TRUTH & DARE'), findsOneWidget);
    expect(find.text('UNDERCOVER'), findsOneWidget);
    expect(find.text('REVEAL ME'), findsOneWidget);
  });
}
