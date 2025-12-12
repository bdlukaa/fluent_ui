import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('Info Badge renders with default values when source is null', (
    tester,
  ) async {
    await tester.pumpWidget(wrapApp(child: const InfoBadge()));

    final container = tester.widget<Container>(find.byType(Container));
    expect(
      container.constraints,
      const BoxConstraints(maxWidth: 10, maxHeight: 10),
    );

    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.borderRadius, BorderRadius.circular(100));

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
}
