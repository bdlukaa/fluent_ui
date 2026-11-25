import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fluent_ui_devtools_extension/icon_catalog.dart';
import 'package:fluent_ui_devtools_extension/icon_browser.dart';

void main() {
  test('loads both icon collections from fluent_ui', () {
    expect(IconCatalog.entriesFor(IconCollection.fluent), isNotEmpty);
    expect(IconCatalog.entriesFor(IconCollection.windows), isNotEmpty);
    expect(
      IconCatalog.entriesFor(IconCollection.fluent).first.icon,
      isA<IconData>(),
    );
  });

  test('normalizes separators and case when searching', () {
    final compact = IconCatalog.search(IconCollection.fluent, 'addfriend');
    final underscore = IconCatalog.search(IconCollection.fluent, 'ADD_FRIEND');
    final spaced = IconCatalog.search(IconCollection.fluent, 'add friend');

    expect(compact, equals(underscore));
    expect(compact, equals(spaced));
    expect(compact.map((entry) => entry.name), contains('add_friend'));
  });

  test('search supports partial icon names and identifiers', () {
    final entries = IconCatalog.search(IconCollection.windows, 'remote');
    final add = IconCatalog.search(
      IconCollection.fluent,
      'add',
    ).firstWhere((entry) => entry.name == 'add');

    expect(entries, isNotEmpty);
    expect(add.identifier, 'FluentIcons.add');
    expect(add.usageSnippet, 'const Icon(FluentIcons.add, size: 24)');
  });

  testWidgets(
    'switches collections, selects an icon, and supports narrow layouts',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final selected = IconCatalog.search(
        IconCollection.fluent,
        'add',
      ).firstWhere((entry) => entry.name == 'add');
      await tester.pumpWidget(
        FluentApp(home: IconBrowser(initialSelection: selected)),
      );

      expect(find.text('Fluent Icons'), findsOneWidget);
      expect(find.text('FluentIcons.add'), findsOneWidget);
      expect(tester.widget<Slider>(find.byType(Slider)).value, 64);
      await tester.drag(find.byType(Slider), const Offset(80, 0));
      await tester.pump();
      expect(tester.widget<Slider>(find.byType(Slider)).value, greaterThan(64));

      await tester.tap(find.byType(ComboBox<IconCollection>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Windows Icons'));
      await tester.pumpAndSettle();
      expect(find.text('Windows Icons'), findsOneWidget);
    },
  );

  testWidgets('shows an empty search state and clears the query', (
    tester,
  ) async {
    await tester.pumpWidget(FluentApp(home: const IconBrowser()));

    await tester.enterText(find.byType(TextBox), 'no such icon');
    await tester.pump();
    expect(find.text('No icons match this search.'), findsOneWidget);

    await tester.tap(find.byType(IconButton).first);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('No icons match this search.'), findsNothing);
  });
}
