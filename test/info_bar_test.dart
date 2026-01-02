import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  group('InfoBar', () {
    testWidgets('Default constructor creates InfoBar', (tester) async {
      await tester.pumpWidget(
        wrapApp(child: const InfoBar(title: Text('Test Title'))),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byType(InfoBar), findsOneWidget);
    });

    testWidgets('InfoBar.info creates InfoBar with info severity', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapApp(child: const InfoBar.info(title: Text('Info Message'))),
      );

      expect(find.text('Info Message'), findsOneWidget);
      final infoBar = tester.widget<InfoBar>(find.byType(InfoBar));
      expect(infoBar.severity, InfoBarSeverity.info);
    });

    testWidgets('InfoBar.warning creates InfoBar with warning severity', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapApp(child: const InfoBar.warning(title: Text('Warning Message'))),
      );

      expect(find.text('Warning Message'), findsOneWidget);
      final infoBar = tester.widget<InfoBar>(find.byType(InfoBar));
      expect(infoBar.severity, InfoBarSeverity.warning);
    });

    testWidgets('InfoBar.success creates InfoBar with success severity', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapApp(child: const InfoBar.success(title: Text('Success Message'))),
      );

      expect(find.text('Success Message'), findsOneWidget);
      final infoBar = tester.widget<InfoBar>(find.byType(InfoBar));
      expect(infoBar.severity, InfoBarSeverity.success);
    });

    testWidgets('InfoBar.error creates InfoBar with error severity', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapApp(child: const InfoBar.error(title: Text('Error Message'))),
      );

      expect(find.text('Error Message'), findsOneWidget);
      final infoBar = tester.widget<InfoBar>(find.byType(InfoBar));
      expect(infoBar.severity, InfoBarSeverity.error);
    });

    testWidgets('Named constructors accept all optional parameters', (
      tester,
    ) async {
      var onCloseCalled = false;

      await tester.pumpWidget(
        wrapApp(
          child: InfoBar.error(
            title: const Text('Error'),
            content: const Text('Content'),
            isLong: true,
            isIconVisible: false,
            onClose: () {
              onCloseCalled = true;
            },
          ),
        ),
      );

      final infoBar = tester.widget<InfoBar>(find.byType(InfoBar));
      expect(infoBar.severity, InfoBarSeverity.error);
      expect(infoBar.isLong, true);
      expect(infoBar.isIconVisible, false);
      expect(infoBar.content, isNotNull);
      expect(infoBar.onClose, isNotNull);

      // Test that content is rendered
      expect(find.text('Content'), findsOneWidget);

      // Test onClose callback works
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      expect(onCloseCalled, true);
    });
  });
}
