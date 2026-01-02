import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('horizontal Divider correct height', (tester) async {
    await tester.pumpWidget(wrapApp(child: const Center(child: Divider())));

    final box = tester.firstRenderObject(find.byType(Divider)) as RenderBox;
    expect(box.size.height, 1.0);
  });

  testWidgets('vertical Divider correct width', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: const Center(child: Divider(direction: Axis.vertical)),
      ),
    );

    final box = tester.firstRenderObject(find.byType(Divider)) as RenderBox;
    expect(box.size.width, 1.0);
  });

  testWidgets('Divider thickness applied correctly', (tester) async {
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

    final hBox = tester.firstRenderObject(find.byType(Divider)) as RenderBox;
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

    final vBox = tester.firstRenderObject(find.byType(Divider)) as RenderBox;
    expect(vBox.size.width, 4.0);
  });
}
