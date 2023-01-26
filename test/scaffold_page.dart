import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets(
    'viewInsets is considered when rendering the page when resizeToAvoidBottomInset is true',
    (WidgetTester tester) async {
      const viewInsets = EdgeInsets.only(top: 27.0);
      await tester.pumpWidget(
        wrapApp(
          child: SizedBox(
            height: 400,
            child: MediaQuery(
              data: const MediaQueryData(viewInsets: viewInsets),
              child: ScaffoldPage(
                content: Container(
                  color: Colors.black,
                  height: 300.0,
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        tester.firstWidget<Padding>(find.byType(Padding)).padding,
        viewInsets,
      );
    },
  );
}
