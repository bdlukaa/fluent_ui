import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Test constraints',
    (WidgetTester tester) async {
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: FluentTheme(
          data: FluentThemeData(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 10,
                maxWidth: 100,
                minHeight: 20,
                maxHeight: 200,
              ),
              child: Button(
                child: const SizedBox.shrink(),
                onPressed: () {},
              ),
            ),
          ),
        ),
      ));

      var buttonBox = tester.firstRenderObject<RenderBox>(find.byType(Button));
      var innerBox = tester.firstRenderObject<RenderBox>(find.byType(SizedBox));

      expect(
          buttonBox.constraints,
          const BoxConstraints(
            minWidth: 10,
            maxWidth: 100,
            minHeight: 20,
            maxHeight: 200,
          ));
      expect(buttonBox.size.width, greaterThanOrEqualTo(10));
      expect(buttonBox.size.height, greaterThanOrEqualTo(20));

      expect(innerBox.constraints.smallest, Size.zero);
      expect(innerBox.constraints.maxWidth, lessThanOrEqualTo(100));
      expect(innerBox.constraints.maxHeight, lessThanOrEqualTo(200));
      expect(innerBox.size, Size.zero);
    },
  );
}
