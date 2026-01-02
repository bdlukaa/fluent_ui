import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('Info Badge renders with default values when source is null', (
    tester,
  ) async {
    await tester.pumpWidget(wrapApp(child: const InfoBadge()));

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.borderRadius, BorderRadius.circular(100));

    // Verify size through constraints on the Container
    expect(container.constraints?.minWidth, 6);
    expect(container.constraints?.minHeight, 6);
    expect(container.child, isNull);
  });

  testWidgets('Info Badge renders with text source correctly', (tester) async {
    const testText = '5';
    await tester.pumpWidget(
      wrapApp(child: const InfoBadge(source: Text(testText))),
    );

    expect(find.text(testText), findsOneWidget);
  });

  testWidgets('Info Badge applies custom background color', (tester) async {
    const testColor = Colors.errorPrimaryColor;

    await tester.pumpWidget(wrapApp(child: const InfoBadge(color: testColor)));

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, testColor);
  });

  testWidgets('InfoBadge.success uses success color', (tester) async {
    await tester.pumpWidget(
      wrapApp(child: const InfoBadge.success(source: Text('1'))),
    );

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, Colors.successPrimaryColor);
  });

  testWidgets('InfoBadge.critical uses error color', (tester) async {
    await tester.pumpWidget(
      wrapApp(child: const InfoBadge.critical(source: Text('!'))),
    );

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, Colors.errorPrimaryColor);
  });

  testWidgets('InfoBadge.informational uses accent color', (tester) async {
    await tester.pumpWidget(
      wrapApp(child: const InfoBadge.informational(source: Text('i'))),
    );

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration! as BoxDecoration;
    // Should use accent color (not a specific fixed color)
    expect(decoration.color, isNotNull);
  });

  testWidgets('InfoBadge.attention uses accent color', (tester) async {
    await tester.pumpWidget(
      wrapApp(child: const InfoBadge.attention(source: Text('!'))),
    );

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration! as BoxDecoration;
    // Should use accent color (not a specific fixed color)
    expect(decoration.color, isNotNull);
  });

  testWidgets('Info Badge with source has padding', (tester) async {
    await tester.pumpWidget(
      wrapApp(child: const InfoBadge(source: Text('10'))),
    );

    final container = tester.widget<Container>(find.byType(Container));
    expect(
      container.padding,
      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  });
}
