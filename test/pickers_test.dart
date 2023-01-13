import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  group('DateTime test', () {
    testWidgets(
      'Correctly format month according to the specified locale',
      (tester) async {
        await tester.pumpWidget(wrapApp(
          child: DatePicker(
            locale: const Locale('pt'),
            selected: DateTime(1),
          ),
        ));

        expect(tester.any(find.text('Janeiro')), isNotNull);
      },
    );

    testWidgets(
      'Correctly format month according to the system locale',
      (tester) async {
        await tester.pumpWidget(FluentApp(
          locale: const Locale('pt'),
          home: DatePicker(
            selected: DateTime(1),
          ),
        ));

        expect(tester.any(find.text('Janeiro')), isNotNull);
      },
    );
  });
}
