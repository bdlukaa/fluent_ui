import 'package:flutter_test/flutter_test.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'app_test.dart';

void main() {
  testWidgets('Card renders with default values', (WidgetTester tester) async {
    const testText = 'Test Card';

    await tester.pumpWidget(wrapApp(child: const Card(child: Text(testText))));

    expect(find.text(testText), findsOneWidget);

    final container = tester.widget<Container>(find.byType(Container));
    expect(container.padding, const EdgeInsets.all(12.0));
    expect(container.margin, isNull);

    final decoration = container.decoration as BoxDecoration;
    expect(
      decoration.borderRadius,
      const BorderRadius.all(Radius.circular(4.0)),
    );
    expect(decoration.border, isNotNull);
  });

  testWidgets('Card applies custom padding and margin', (
    WidgetTester tester,
  ) async {
    const customPadding = EdgeInsets.symmetric(vertical: 8.0);
    const customMargin = EdgeInsets.all(16.0);

    await tester.pumpWidget(
      wrapApp(
        child: const Card(
          padding: customPadding,
          margin: customMargin,
          child: Text('Test'),
        ),
      ),
    );

    final container = tester.widget<Container>(find.byType(Container));
    expect(container.padding, customPadding);
    expect(container.margin, customMargin);
  });

  testWidgets('Card applies custom background color', (
    WidgetTester tester,
  ) async {
    final testColor = Colors.blue;

    await tester.pumpWidget(
      wrapApp(
        child: Card(backgroundColor: testColor, child: const Text('Test')),
      ),
    );

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, testColor);
  });

  testWidgets(
    'Card uses theme cardColor when background color is not provided',
    (WidgetTester tester) async {
      final theme = FluentThemeData(cardColor: Colors.red);

      await tester.pumpWidget(
        FluentApp(
          theme: theme,
          home: const Card(child: Text('Test')),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, theme.cardColor);
    },
  );

  testWidgets('Card applies custom border color', (WidgetTester tester) async {
    final testColor = Colors.green;

    await tester.pumpWidget(
      wrapApp(
        child: Card(borderColor: testColor, child: const Text('Test')),
      ),
    );

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.border?.top.color, testColor);
  });

  testWidgets('Card uses theme border color when not provided', (
    WidgetTester tester,
  ) async {
    final theme = FluentThemeData();

    await tester.pumpWidget(
      FluentApp(
        theme: theme,
        home: const Card(child: Text('Test')),
      ),
    );

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;
    expect(
      decoration.border?.top.color,
      theme.resources.cardStrokeColorDefault,
    );
  });

  testWidgets('Card applies custom borderRadius', (WidgetTester tester) async {
    const customRadius = BorderRadius.all(Radius.circular(20.0));

    await tester.pumpWidget(
      wrapApp(
        child: const Card(borderRadius: customRadius, child: Text('Test')),
      ),
    );

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.borderRadius, customRadius);
  });
}
