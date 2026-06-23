import 'package:bacteria_simulation/bacterialcollection.dart';
import 'package:bacteria_simulation/historygraph/bacteriahistorygraph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bacteria_simulation/main.dart';

void main() {
  testWidgets('Bacteria rendering test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pump(); // trigger frame to let LayoutBuilder set size

    // Print the widget tree
    debugDumpApp();

    // Verify that the custom paint widgets are rendered
    expect(find.byType(Bacterialcollection), findsOneWidget);
    expect(find.byType(Bacteriahistorygraph), findsOneWidget);
  });
}
