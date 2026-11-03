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

    expect(find.text('VisionMate 3.0'), findsOneWidget);
    expect(find.text('Assistance Tools'), findsOneWidget);
    expect(find.text('Explore Surroundings'), findsOneWidget);
    expect(find.text('Read Text'), findsOneWidget);
    expect(find.text('AI Assistant'), findsOneWidget);
    expect(find.text('Navigation Guidance'), findsOneWidget);
  });
}
