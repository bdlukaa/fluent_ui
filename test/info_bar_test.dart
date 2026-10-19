import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  group('InfoBar', () {
    testWidgets('named constructors set their severity', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          child: const Column(
            children: [
              InfoBar.info(title: Text('Info')),
              InfoBar.warning(title: Text('Warning')),
              InfoBar.success(title: Text('Success')),
              InfoBar.error(title: Text('Error')),
            ],
          ),
        ),
      );

      final infoBars = tester
          .widgetList<InfoBar>(find.byType(InfoBar))
          .toList();
      expect(infoBars.map((infoBar) => infoBar.severity), [
        InfoBarSeverity.info,
        InfoBarSeverity.warning,
        InfoBarSeverity.success,
        InfoBarSeverity.error,
      ]);
    });

    testWidgets('uses Windows severity icons and colors', (tester) async {
      final theme = FluentThemeData.light();
      await tester.pumpWidget(
        FluentApp(
          theme: theme,
          home: const Column(
            children: [
              InfoBar.info(title: Text('Info')),
              InfoBar.warning(title: Text('Warning')),
              InfoBar.success(title: Text('Success')),
              InfoBar.error(title: Text('Error')),
            ],
          ),
        ),
      );

      final icons = tester
          .widgetList<WindowsIcon>(find.byType(WindowsIcon))
          .toList();
      final expected = [
        (
          WindowsIcons.info_solid,
          theme.accentColor.defaultBrushFor(theme.brightness),
        ),
        (
          FluentIcons.critical_error_solid,
          theme.resources.systemFillColorCaution,
        ),
        (WindowsIcons.completed_solid, theme.resources.systemFillColorSuccess),
        (
          WindowsIcons.status_circle_error_x,
          theme.resources.systemFillColorCritical,
        ),
      ];

      expect(icons, hasLength(expected.length));
      for (var index = 0; index < expected.length; index++) {
        final icon = icons[index];
        expect(icon.icon, expected[index].$1);
        expect(icon.color, expected[index].$2);
        expect(icon.icon!.fontFamily, isNot('MaterialIcons'));
        expect(icon.icon!.fontPackage, 'fluent_ui');
      }
    });

    testWidgets('uses custom theme icons and colors', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          child: const InfoBarTheme(
            data: InfoBarThemeData(
              icon: _customIcon,
              iconColor: _customIconColor,
            ),
            child: InfoBar.success(title: Text('Success')),
          ),
        ),
      );

      final icon = tester.widget<WindowsIcon>(find.byType(WindowsIcon));
      expect(icon.icon, FluentIcons.add);
      expect(icon.color, Colors.purple);
    });

    testWidgets('hides the icon without retaining its spacing', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          child: const InfoBar(
            title: Text('Title', key: ValueKey('hidden-title')),
            isIconVisible: false,
          ),
        ),
      );
      final hiddenTitleX = tester
          .getTopLeft(find.byKey(const ValueKey('hidden-title')))
          .dx;
      expect(find.byType(Icon), findsNothing);

      await tester.pumpWidget(
        wrapApp(
          child: const InfoBar(
            title: Text('Title', key: ValueKey('visible-title')),
          ),
        ),
      );
      final visibleTitleX = tester
          .getTopLeft(find.byKey(const ValueKey('visible-title')))
          .dx;

      expect(visibleTitleX - hiddenTitleX, 32);
    });

    testWidgets('keeps close callbacks, actions, and custom styles', (
      tester,
    ) async {
      var closeCalls = 0;
      var actionCalls = 0;
      await tester.pumpWidget(
        wrapApp(
          child: InfoBar.error(
            title: const Text('Error'),
            action: Button(
              onPressed: () => actionCalls++,
              child: const Text('Retry'),
            ),
            onClose: () => closeCalls++,
            style: const InfoBarThemeData(
              padding: EdgeInsetsDirectional.all(20),
              iconColor: _customIconColor,
            ),
          ),
        ),
      );

      expect(
        tester
            .widget<Icon>(find.byIcon(FluentIcons.status_circle_error_x))
            .color,
        Colors.purple,
      );
      await tester.tap(find.text('Retry'));
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(actionCalls, 1);
      expect(closeCalls, 1);
    });

    testWidgets('uses the expected long and short layouts', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          child: const Column(
            children: [
              InfoBar(
                key: ValueKey('short'),
                title: Text('Short'),
                content: Text('Content'),
                action: Button(onPressed: null, child: Text('Action')),
              ),
              InfoBar(
                key: ValueKey('long'),
                title: Text('Long'),
                content: Text('Content'),
                action: Button(onPressed: null, child: Text('Action')),
                isLong: true,
              ),
            ],
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byKey(const ValueKey('short')),
          matching: find.byType(Wrap),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('long')),
          matching: find.byType(Wrap),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('long')),
          matching: find.byType(Column),
        ),
        findsOneWidget,
      );
    });
  });
}

IconData _customIcon(InfoBarSeverity severity) => FluentIcons.add;

Color _customIconColor(InfoBarSeverity severity) => Colors.purple;
