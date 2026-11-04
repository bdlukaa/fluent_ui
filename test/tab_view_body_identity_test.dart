import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('TabView honors programmatic selection before attachment', (
    tester,
  ) async {
    final controller = TabViewController(
      initialIndex: 1,
      tabs: [
        Tab(text: const Text('A'), body: const Text('Body A')),
        Tab(text: const Text('B'), body: const Text('Body B')),
      ],
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(wrapApp(child: TabView(controller: controller)));

    expect(find.text('Body A'), findsNothing);
    expect(find.text('Body B'), findsOneWidget);
  });

  testWidgets('TabView renders an empty tab list without a body', (
    tester,
  ) async {
    final controller = TabViewController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(wrapApp(child: TabView(controller: controller)));

    expect(find.byType(PageView), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TabView gives explicit tab keys distinct pages', (tester) async {
    var rebuild = false;
    List<Tab> tabs() => [
      Tab(
        key: const ValueKey('A'),
        text: const Text('A'),
        body: _CounterBody('A-$rebuild'),
      ),
      Tab(
        key: const ValueKey('B'),
        text: const Text('B'),
        body: _CounterBody('B-$rebuild'),
      ),
    ];
    final controller = TabViewController(tabs: tabs());
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrapApp(
        child: StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              Button(
                onPressed: () => setState(() {
                  rebuild = true;
                  controller.replaceTabs(tabs());
                }),
                child: const Text('rebuild'),
              ),
              Expanded(child: TabView(controller: controller)),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(Button, 'increment'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(Button, 'rebuild'));
    await tester.pumpAndSettle();

    expect(find.text('A-true:1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _CounterBody extends StatefulWidget {
  const _CounterBody(this.label);

  final String label;

  @override
  State<_CounterBody> createState() => _CounterBodyState();
}

class _CounterBodyState extends State<_CounterBody>
    with AutomaticKeepAliveClientMixin {
  var _count = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${widget.label}:$_count'),
        Button(
          onPressed: () => setState(() => _count++),
          child: const Text('increment'),
        ),
      ],
    );
  }
}
