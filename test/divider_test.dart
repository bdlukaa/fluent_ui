import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('horizontal Divider correct height', (WidgetTester tester) async {
    await tester.pumpWidget(
      wrapApp(child: const Center(child: Divider())),
    );

    final RenderBox box = tester.firstRenderObject(find.byType(Divider));
    expect(box.size.height, 1.0);
  });

  testWidgets('vertical Divider correct width', (WidgetTester tester) async {
    await tester.pumpWidget(
      wrapApp(child: const Center(child: Divider(direction: Axis.vertical))),
    );

    final RenderBox box = tester.firstRenderObject(find.byType(Divider));
    expect(box.size.width, 1.0);
  });

  testWidgets('Divider thickness applied correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: const Center(
          child: DividerTheme(
            data: DividerThemeData(thickness: 4),
            child: Divider(),
          ),
        ),
      ),
    );

    final RenderBox hBox = tester.firstRenderObject(find.byType(Divider));
    expect(hBox.size.height, 4.0);

    await tester.pumpWidget(
      wrapApp(
        child: const Center(
          child: DividerTheme(
            data: DividerThemeData(thickness: 4),
            child: Divider(direction: Axis.vertical),
          ),
        ),
      ),
    );

    final RenderBox vBox = tester.firstRenderObject(find.byType(Divider));
    expect(vBox.size.width, 4.0);
  });
}
