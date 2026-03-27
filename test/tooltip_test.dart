import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('Tooltip shows message on long press', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: ScaffoldPage(
          content: Center(
            child: Tooltip(
              message: 'Test Tooltip',
              triggerMode: TooltipTriggerMode.longPress,
              child: Button(
                child: const Text('Long Press Me'),
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Test Tooltip'), findsNothing);
    await tester.longPress(find.byType(Button));
    await tester.pumpAndSettle();
    expect(find.text('Test Tooltip'), findsOneWidget);
  });

  testWidgets('Tooltip shows message on hover', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: ScaffoldPage(
          content: Center(
            child: Tooltip(
              message: 'Test Tooltip',
              child: Button(
                key: const Key('Button'),
                child: const Text('Hover Me'),
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Test Tooltip'), findsNothing);

    // Create a mouse gesture and hover over the button
    final gesture = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
      pointer: 1,
    );
    await gesture.addPointer(location: Offset.zero);
    await tester.pump();
    await gesture.moveTo(tester.getCenter(find.byKey(const Key('Button'))));
    await tester.pumpAndSettle(const Duration(milliseconds: 1500));

    expect(find.text('Test Tooltip'), findsOneWidget);

    await gesture.moveTo(Offset.zero);
    await tester.pumpAndSettle();
    expect(find.text('Test Tooltip'), findsNothing);
  });

  testWidgets('Tooltip dismisses when clicking outside', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: ScaffoldPage(
          content: Column(
            children: [
              Tooltip(
                message: 'Tooltip 1',
                child: Button(child: const Text('Button 1'), onPressed: () {}),
              ),
              Button(child: const Text('Button 2'), onPressed: () {}),
            ],
          ),
        ),
      ),
    );
    final gesture = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
      pointer: 1,
    );
    await gesture.addPointer(location: Offset.zero);
    await tester.pumpAndSettle();

    await gesture.moveTo(tester.getCenter(find.text('Button 1')));
    await tester.pumpAndSettle(const Duration(milliseconds: 1500));
    expect(find.text('Tooltip 1'), findsOneWidget);

    await tester.tap(find.text('Button 2'));
    await tester.pumpAndSettle();
    expect(find.text('Tooltip 1'), findsNothing);
  });

  testWidgets('Tooltip with richMessage displays correctly', (tester) async {
    const richMessage = TextSpan(
      text: 'Rich ',
      children: [
        TextSpan(
          text: 'Tooltip',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );

    await tester.pumpWidget(
      wrapApp(
        child: ScaffoldPage(
          content: Center(
            child: Tooltip(
              richMessage: richMessage,
              child: Button(child: const Text('Tap Me'), onPressed: () {}),
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
      pointer: 1,
    );
    await gesture.addPointer(location: Offset.zero);

    await gesture.moveTo(tester.getCenter(find.text('Tap Me')));
    await tester.pumpAndSettle(const Duration(milliseconds: 1500));
    expect(find.text('Rich Tooltip'), findsOneWidget);
  });

  testWidgets('Tooltip.dismissAllToolTips works correctly', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: ScaffoldPage(
          content: Column(
            children: [
              Tooltip(
                message: 'Tooltip 1',
                child: Button(child: const Text('Button 1'), onPressed: () {}),
              ),
              Tooltip(
                message: 'Tooltip 2',
                child: Button(child: const Text('Button 2'), onPressed: () {}),
              ),
            ],
          ),
        ),
      ),
    );

    final gesture = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
      pointer: 1,
    );
    await gesture.addPointer(location: Offset.zero);

    await gesture.moveTo(tester.getCenter(find.text('Button 1')));
    await tester.pumpAndSettle(const Duration(milliseconds: 1500));

    expect(find.text('Tooltip 1'), findsOneWidget);

    await gesture.moveTo(tester.getCenter(find.text('Button 2')));
    await tester.pumpAndSettle(const Duration(milliseconds: 1500));
    expect(find.text('Tooltip 2'), findsOneWidget);

    final dismissed = Tooltip.dismissAllToolTips();
    await tester.pumpAndSettle();

    expect(dismissed, isTrue);
    expect(find.text('Tooltip 1'), findsNothing);
    expect(find.text('Tooltip 2'), findsNothing);
  });

  testWidgets('Tooltip respects visibility', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: ScaffoldPage(
          content: TooltipVisibility(
            visible: false,
            child: Center(
              child: Tooltip(
                message: 'Should not show',
                child: Button(child: const Text('Tap Me'), onPressed: () {}),
              ),
            ),
          ),
        ),
      ),
    );
    final gesture = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
      pointer: 1,
    );
    await gesture.addPointer(location: Offset.zero);
    await gesture.moveTo(tester.getCenter(find.text('Tap Me')));
    await tester.pumpAndSettle(const Duration(milliseconds: 1500));

    expect(find.text('Should not show'), findsNothing);
  });

  testWidgets('Tooltip with empty message does not show', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: ScaffoldPage(
          content: Center(
            child: Tooltip(
              message: '',
              child: Button(child: const Text('Tap Me'), onPressed: () {}),
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
      pointer: 1,
    );
    await gesture.addPointer(location: Offset.zero);
    await gesture.moveTo(tester.getCenter(find.text('Tap Me')));
    await tester.pumpAndSettle(const Duration(milliseconds: 1500));

    expect(find.text(''), findsNothing);
  });

  testWidgets('Tooltip does not rebuild child when mouse tracker changes', (
    tester,
  ) async {
    // Regression test: when the mouse enters or leaves the window,
    // _mouseIsConnected used to change via setState, which would add/remove
    // the MouseRegion wrapper and cause the child widget to lose its state.
    var initStateCount = 0;

    await tester.pumpWidget(
      wrapApp(
        child: ScaffoldPage(
          content: Center(
            child: Tooltip(
              message: 'tooltip message',
              child: _InitStateCounter(onInitState: () => initStateCount++),
            ),
          ),
        ),
      ),
    );

    expect(initStateCount, 1);

    // Simulate a mouse being added (hover over the widget)
    final gesture = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
      pointer: 1,
    );
    await gesture.addPointer(location: Offset.zero);
    await tester.pump();

    // The child's initState should NOT be called again
    expect(initStateCount, 1);

    // Move the mouse over the tooltip child
    await gesture.moveTo(tester.getCenter(find.byType(_InitStateCounter)));
    await tester.pump();
    expect(initStateCount, 1);

    // Remove the mouse pointer (simulate cursor leaving window)
    await gesture.removePointer();
    await tester.pump();

    // The child should still preserve its state
    expect(initStateCount, 1);
  });
}

/// A helper widget that counts how many times initState is called.
class _InitStateCounter extends StatefulWidget {
  const _InitStateCounter({required this.onInitState});

  final VoidCallback onInitState;

  @override
  State<_InitStateCounter> createState() => _InitStateCounterState();
}

class _InitStateCounterState extends State<_InitStateCounter> {
  @override
  void initState() {
    super.initState();
    widget.onInitState();
  }

  @override
  Widget build(BuildContext context) {
    return const Text('Stateful child');
  }
}
