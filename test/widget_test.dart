import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visionmate/features/home/presentation/screens/home_screen.dart';

void main() {
  testWidgets('VisionMate HomeScreen renders successfully', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    expect(find.text('Vision Mate'), findsOneWidget);
    expect(find.text('Assistance Tools'), findsOneWidget);
    expect(find.text('Explore Surround...'), findsOneWidget);
    expect(find.text('Smart Text Reader'), findsOneWidget);
    expect(find.text('Find Object & Ca...'), findsOneWidget);
    expect(find.text('Voice AI Assistant'), findsOneWidget);
    expect(find.text('Navigation Guida...'), findsOneWidget);
    expect(find.text('Emergency S...'), findsOneWidget);
  });
}
