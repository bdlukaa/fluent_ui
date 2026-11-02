import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluent_ui/windows_icon_fallback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

/// The fallback [WindowsIcon] resolved by name before name lookup became
/// opt-in, kept verbatim so the tests below compare against it.
IconData legacyNameFallback(IconData icon) {
  MapEntry<String, IconData>? windowsEntry;
  for (final entry in WindowsIcons.allIcons.entries) {
    if (entry.value == icon) {
      windowsEntry = entry;
      break;
    }
  }
  if (windowsEntry == null) return icon;
  for (final entry in FluentIcons.allIcons.entries) {
    if (entry.key == windowsEntry.key || entry.value == windowsEntry.value) {
      return entry.value;
    }
  }
  return icon;
}

/// Expects every [WindowsIcon] under [tester] to render the icon the legacy
/// name lookup resolved, and returns the [WindowsIcons] glyphs it checked.
List<IconData> expectLegacyFallbacks(WidgetTester tester) {
  final checked = <IconData>[];
  for (final element in find.byType(WindowsIcon).evaluate()) {
    final icon = (element.widget as WindowsIcon).icon!;
    final rendered = tester.widget<Icon>(
      find
          .descendant(
            of: find.byWidget(element.widget),
            matching: find.byWidgetPredicate((w) => w.runtimeType == Icon),
          )
          .first,
    );
    expect(
      rendered.icon,
      legacyNameFallback(icon),
      reason: 'WindowsIcon(U+${icon.codePoint.toRadixString(16)})',
    );
    checked.add(icon);
  }
  return checked;
}

/// The `WindowsIcon(` invocations in the package sources, with their
/// argument lists.
Iterable<({String file, String args})> windowsIconInvocations() sync* {
  final sources = Directory('lib').listSync(recursive: true).whereType<File>();
  for (final file in sources) {
    if (!file.path.endsWith('.dart') ||
        file.path.endsWith('windows_icon.dart')) {
      continue;
    }
    final lines = file
        .readAsLinesSync()
        .where((line) => !line.trimLeft().startsWith('///'))
        .join('\n');
    for (final match in RegExp(r'\bWindowsIcon\(').allMatches(lines)) {
      var depth = 1;
      var end = match.end;
      while (depth > 0) {
        final char = lines[end++];
        if (char == '(') depth++;
        if (char == ')') depth--;
      }
      yield (file: file.path, args: lines.substring(match.end, end - 1));
    }
  }
}

void main() {
  tearDown(() => WindowsIcon.fallbackResolver = null);

  test('icon classes are annotated for icon tree shaking', () {
    for (final (path, className) in [
      ('lib/src/icons.dart', 'FluentIcons'),
      ('lib/src/windows_icons.dart', 'WindowsIcons'),
    ]) {
      expect(
        File(path).readAsStringSync(),
        contains('@staticIconProvider\nclass $className {'),
        reason: path,
      );
    }
  });

  test('package WindowsIcons pass the fallback the name lookup chose', () {
    final literal = RegExp(
      r'^\s*WindowsIcons\.(\w+),\s*fallbackIcon:\s*FluentIcons\.(\w+),',
    );
    final dynamicSites = <String>[];
    var literalSites = 0;
    for (final (:file, :args) in windowsIconInvocations()) {
      expect(args, contains('fallbackIcon:'), reason: '$file: $args');
      final match = literal.firstMatch(args);
      if (match == null) {
        dynamicSites.add(file);
        continue;
      }
      final windowsIcon = WindowsIcons.allIcons[match[1]!]!;
      expect(
        FluentIcons.allIcons[match[2]!],
        legacyNameFallback(windowsIcon),
        reason: '$file: ${match[1]}',
      );
      literalSites++;
    }
    expect(literalSites, greaterThan(20));
    // Covered by the InfoBar widget test below.
    expect(dynamicSites, everyElement(endsWith('info_bar.dart')));
  });

  testWidgets('InfoBar severity icons render the legacy fallback', (
    tester,
  ) async {
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
    expect(expectLegacyFallbacks(tester), [
      WindowsIcons.info_solid,
      FluentIcons.critical_error_solid,
      WindowsIcons.completed_solid,
      WindowsIcons.status_error_full,
    ]);
  });

  for (final (direction, chevron) in [
    (TextDirection.ltr, WindowsIcons.chevron_right),
    (TextDirection.rtl, WindowsIcons.chevron_left),
  ]) {
    testWidgets('MenuFlyoutSubItem chevron renders the legacy fallback '
        '(${direction.name})', (tester) async {
      final controller = FlyoutController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        wrapApp(
          child: Directionality(
            textDirection: direction,
            child: FlyoutTarget(
              controller: controller,
              child: const Text('Target'),
            ),
          ),
        ),
      );
      controller.showFlyout<void>(
        builder: (context) => Directionality(
          textDirection: direction,
          child: MenuFlyout(
            items: [
              MenuFlyoutSubItem(
                text: const Text('Sub'),
                items: (context) => [],
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(expectLegacyFallbacks(tester), [chevron]);
    });
  }

  testWidgets('controls render the legacy fallbacks', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: ScaffoldPage(
          content: Column(
            children: [
              SizedBox(
                height: 80,
                child: TabView(
                  currentIndex: 0,
                  onNewPressed: () {},
                  tabs: [
                    Tab(
                      text: const Text('Tab'),
                      body: const SizedBox(),
                      onClosed: () {},
                    ),
                  ],
                ),
              ),
              NumberBox<int>(
                value: 1,
                onChanged: (_) {},
                mode: SpinButtonPlacementMode.inline,
              ),
              ComboBox<int>(
                value: 1,
                items: const [ComboBoxItem(value: 1, child: Text('One'))],
                onChanged: (_) {},
              ),
              CalendarView(),
            ],
          ),
        ),
      ),
    );
    expect(
      expectLegacyFallbacks(tester),
      containsAll(<IconData>[
        WindowsIcons.add,
        WindowsIcons.chrome_close,
        WindowsIcons.chevron_up,
        WindowsIcons.chevron_down,
        WindowsIcons.caret_up_solid8,
        WindowsIcons.caret_down_solid8,
      ]),
    );
  });

  testWidgets('renders the Windows glyph on Windows', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    await tester.pumpWidget(
      wrapApp(
        child: const WindowsIcon(
          WindowsIcons.add,
          fallbackIcon: FluentIcons.add,
        ),
      ),
    );
    expect(tester.widget<Icon>(find.byType(Icon).last).icon, WindowsIcons.add);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets(
    'without a fallback renders the Windows glyph and notes it once',
    (tester) async {
      final printed = <String?>[];
      final previousDebugPrint = debugPrint;
      debugPrint = (message, {wrapWidth}) => printed.add(message);
      try {
        await tester.pumpWidget(
          wrapApp(
            child: const Column(
              children: [
                WindowsIcon(WindowsIcons.airplane),
                WindowsIcon(WindowsIcons.airplane),
              ],
            ),
          ),
        );
      } finally {
        debugPrint = previousDebugPrint;
      }
      final rendered = tester
          .widgetList<Icon>(find.byType(Icon))
          .where((icon) => icon is! WindowsIcon);
      expect(rendered.map((icon) => icon.icon), [
        WindowsIcons.airplane,
        WindowsIcons.airplane,
      ]);
      expect(printed, hasLength(1));
      expect(printed.single, contains('windows_icon_fallback.dart'));
    },
  );

  testWidgets('fallbackResolver restores name-based fallback', (tester) async {
    WindowsIcon.fallbackResolver = fluentIconFallback;
    await tester.pumpWidget(
      wrapApp(child: const WindowsIcon(WindowsIcons.airplane)),
    );
    expect(
      tester.widget<Icon>(find.byType(Icon).last).icon,
      FluentIcons.airplane,
    );
  });

  test('fluentIconFallback resolves as the legacy name lookup did', () {
    for (final icon in WindowsIcons.allIcons.values) {
      expect(fluentIconFallback(icon) ?? icon, legacyNameFallback(icon));
    }
    expect(fluentIconFallback(FluentIcons.add), isNull);
  });
}
