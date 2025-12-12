import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('ListTile displays title, subtitle, leading, and trailing', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: const ListTile(
          leading: Icon(FluentIcons.mail),
          title: Text('Title'),
          subtitle: Text('Subtitle'),
          trailing: Icon(FluentIcons.chevron_right),
        ),
      ),
    );

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Subtitle'), findsOneWidget);
    expect(find.byIcon(FluentIcons.mail), findsOneWidget);
    expect(find.byIcon(FluentIcons.chevron_right), findsOneWidget);
  });

  testWidgets('ListTile calls onPressed when tapped', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      wrapApp(
        child: ListTile(
          title: const Text('Tap me'),
          onPressed: () {
            pressed = true;
          },
        ),
      ),
    );

    await tester.tap(find.text('Tap me'));
    await tester.pumpAndSettle();
    expect(pressed, isTrue);
  });

  testWidgets('ListTile.selectable (single) calls onSelectionChange', (
    tester,
  ) async {
    bool? selected;
    await tester.pumpWidget(
      wrapApp(
        child: ListTile.selectable(
          title: const Text('Selectable'),
          onSelectionChange: (v) {
            selected = v;
          },
        ),
      ),
    );

    await tester.tap(find.text('Selectable'));
    await tester.pumpAndSettle();
    expect(selected, isTrue);
  });

  testWidgets('ListTile.selectable (multiple) toggles selection', (
    tester,
  ) async {
    bool? selected = false;
    await tester.pumpWidget(
      wrapApp(
        child: ListTile.selectable(
          title: const Text('Multi'),
          selected: selected,
          selectionMode: ListTileSelectionMode.multiple,
          onSelectionChange: (v) => {selected = v},
        ),
      ),
    );

    await tester.tap(find.text('Multi'));
    await tester.pumpAndSettle();
    expect(selected, isTrue);
  });

  testWidgets('ListTile renders semantic label', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: const ListTile(
          title: Text('Semantic'),
          semanticLabel: 'CustomLabel',
        ),
      ),
    );

    final semantics = tester.getSemantics(find.byType(ListTile));

    expect(semantics.label, 'CustomLabel');
  });
}
