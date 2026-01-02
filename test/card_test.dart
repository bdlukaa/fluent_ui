import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('Card renders with default values', (tester) async {
    const testText = 'Test Card';

    await tester.pumpWidget(wrapApp(child: const Card(child: Text(testText))));

    expect(find.text(testText), findsOneWidget);

    final container = tester.widget<Container>(find.byType(Container));
    expect(container.padding, const EdgeInsetsDirectional.all(12));
    expect(container.margin, isNull);

    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.borderRadius, const BorderRadius.all(Radius.circular(4)));
    expect(decoration.border, isNotNull);
  });

  testWidgets('Card applies custom padding and margin', (tester) async {
    const customPadding = EdgeInsetsDirectional.symmetric(vertical: 8);
    const customMargin = EdgeInsetsDirectional.all(16);

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

  testWidgets('Card applies custom background color', (tester) async {
    final testColor = Colors.blue;

    await tester.pumpWidget(
      wrapApp(
        child: Card(backgroundColor: testColor, child: const Text('Test')),
      ),
    );

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, testColor);
  });

  testWidgets(
    'Card uses theme cardColor when background color is not provided',
    (tester) async {
      final theme = FluentThemeData(cardColor: Colors.red);

      await tester.pumpWidget(
        FluentApp(
          theme: theme,
          home: const Card(child: Text('Test')),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, theme.cardColor);
    },
  );

  testWidgets('Card applies custom border color', (tester) async {
    final testColor = Colors.green;

    await tester.pumpWidget(
      wrapApp(
        child: Card(borderColor: testColor, child: const Text('Test')),
      ),
    );

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.border?.top.color, testColor);
  });

  testWidgets('Card uses theme border color when not provided', (tester) async {
    final theme = FluentThemeData();

    await tester.pumpWidget(
      FluentApp(
        theme: theme,
        home: const Card(child: Text('Test')),
      ),
    );

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration! as BoxDecoration;
    expect(
      decoration.border?.top.color,
      theme.resources.cardStrokeColorDefault,
    );
  });

  testWidgets('Card applies custom borderRadius', (tester) async {
    const customRadius = BorderRadius.all(Radius.circular(20));

    await tester.pumpWidget(
      wrapApp(
        child: const Card(borderRadius: customRadius, child: Text('Test')),
      ),
    );

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.borderRadius, customRadius);
  });
}
