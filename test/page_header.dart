import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('renders a title without actions', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: const SizedBox(
          width: 800,
          height: 120,
          child: PageHeader(title: Text('Settings', key: Key('title'))),
        ),
      ),
    );

    expect(find.byKey(const Key('title')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps title and actions in one row at regular widths', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: const SizedBox(
          width: 800,
          height: 120,
          child: PageHeader(
            title: SizedBox(key: Key('title'), height: 40),
            commandBar: SizedBox(key: Key('actions'), width: 120, height: 40),
          ),
        ),
      ),
    );

    final title = tester.getRect(find.byKey(const Key('title')));
    final actions = tester.getRect(find.byKey(const Key('actions')));
    expect(actions.top, title.top);
    expect(actions.left, greaterThan(title.right));
    expect(tester.takeException(), isNull);
  });

  testWidgets('moves actions below the title at compact widths', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: const Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 320,
            height: 160,
            child: PageHeader(
              title: SizedBox(key: Key('title'), height: 40),
              commandBar: SizedBox(key: Key('actions'), width: 120, height: 40),
            ),
          ),
        ),
      ),
    );

    final title = tester.getRect(find.byKey(const Key('title')));
    final actions = tester.getRect(find.byKey(const Key('actions')));
    expect(actions.top, greaterThan(title.bottom));
    expect(actions.right, 320);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long titles and actions remain valid with text scaling', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final scale in [1.0, 1.5, 2.0]) {
      await tester.pumpWidget(
        wrapApp(
          child: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: const Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 320,
                height: 1000,
                child: PageHeader(
                  title: Text(
                    'A deliberately long settings page title that should wrap',
                  ),
                  commandBar: SizedBox(
                    key: Key('actions'),
                    width: 140,
                    height: 40,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull, reason: 'scale: $scale');
    }
  });

  testWidgets('RTL places trailing actions on the logical start side', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: const Directionality(
          textDirection: TextDirection.rtl,
          child: SizedBox(
            width: 800,
            height: 120,
            child: PageHeader(
              title: SizedBox(key: Key('title'), width: 200, height: 40),
              commandBar: SizedBox(key: Key('actions'), width: 120, height: 40),
            ),
          ),
        ),
      ),
    );

    final title = tester.getRect(find.byKey(const Key('title')));
    final actions = tester.getRect(find.byKey(const Key('actions')));
    expect(actions.right, lessThan(title.left));
    expect(tester.takeException(), isNull);
  });

  testWidgets('header title aligns with ScaffoldPage content', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: const SizedBox(
          width: 800,
          height: 300,
          child: ScaffoldPage(
            header: PageHeader(title: Text('Settings', key: Key('title'))),
            content: SizedBox(key: Key('content')),
          ),
        ),
      ),
    );

    expect(
      tester.getTopLeft(find.byKey(const Key('title'))).dx,
      tester.getTopLeft(find.byKey(const Key('content'))).dx,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('command bar receives bounded width for overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: const SizedBox(
          width: 320,
          height: 200,
          child: PageHeader(
            title: Text('Actions'),
            commandBar: CommandBar(
              primaryItems: [
                CommandBarButton(
                  icon: Icon(FluentIcons.add),
                  label: Text('Add'),
                  onPressed: _noop,
                ),
                CommandBarButton(
                  icon: Icon(FluentIcons.delete),
                  label: Text('Delete'),
                  onPressed: _noop,
                ),
                CommandBarButton(
                  icon: Icon(FluentIcons.edit),
                  label: Text('Edit'),
                  onPressed: _noop,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}

void _noop() {}
