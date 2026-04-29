import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gitdocs/main.dart';

void main() {
  testWidgets('renders the GitDocs app shell', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const GitDocsApp());
    await tester.pumpAndSettle();

    expect(find.text('GitDocs'), findsWidgets);
    expect(find.byIcon(Icons.edit_document), findsOneWidget);
  });
}
