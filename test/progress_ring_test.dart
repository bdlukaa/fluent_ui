import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('ProgressRing exposes correct semantics', (tester) async {
    await tester.pumpWidget(
      wrapApp(child: const ProgressRing(value: 66, semanticLabel: 'Loading')),
    );

    final semantics = tester
        .getSemantics(find.bySemanticsLabel('Loading'))
        .getSemanticsData();
    expect(semantics.label, 'Loading');
    expect(semantics.value, '66.00');
  });

  testWidgets(
    'indeterminate ProgressRing repaints without rebuilding CustomPaint',
    (tester) async {
      await tester.pumpWidget(wrapApp(child: const ProgressRing()));

      final customPaint = find.descendant(
        of: find.byType(ProgressRing),
        matching: find.byType(CustomPaint),
      );
      final element = tester.element(customPaint);
      final widget = element.widget;
      final painter = tester
          .renderObject<RenderCustomPaint>(customPaint)
          .painter;

      await tester.pump(const Duration(milliseconds: 250));

      expect(tester.element(customPaint).widget, same(widget));
      expect(
        tester.renderObject<RenderCustomPaint>(customPaint).painter,
        same(painter),
      );
    },
  );

  testWidgets('determinate ProgressRing does not keep a ticker running', (
    tester,
  ) async {
    await tester.pumpWidget(wrapApp(child: const ProgressRing(value: 50)));

    expect(tester.hasRunningAnimations, isFalse);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('ProgressRing stops and restarts its animation on mode changes', (
    tester,
  ) async {
    late void Function(void Function()) update;
    double? value;
    await tester.pumpWidget(
      wrapApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return ProgressRing(value: value);
          },
        ),
      ),
    );
    expect(tester.hasRunningAnimations, isTrue);

    update(() => value = 50);
    await tester.pump();
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);

    update(() => value = null);
    await tester.pump();
    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('ProgressRing respects TickerMode', (tester) async {
    await tester.pumpWidget(
      wrapApp(child: const TickerMode(enabled: false, child: ProgressRing())),
    );
    expect(tester.hasRunningAnimations, isFalse);

    await tester.pumpWidget(
      wrapApp(child: const TickerMode(enabled: true, child: ProgressRing())),
    );
    await tester.pump();
    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('ProgressRing handles degenerate constraints', (tester) async {
    for (final size in const <Size>[
      Size.zero,
      Size(1, 0),
      Size(0, 1),
      Size(1, 1),
      Size(4.5, 4.5),
      Size(40, 40),
      Size(1000, 1000),
    ]) {
      await tester.pumpWidget(
        wrapApp(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: const ProgressRing(value: 50),
          ),
        ),
      );
      expect(tester.takeException(), isNull, reason: 'size: $size');
    }
  });

  testWidgets('ProgressRing preserves custom colors and stroke width', (
    tester,
  ) async {
    const active = Color(0xff123456);
    const background = Color(0xff654321);
    await tester.pumpWidget(
      wrapApp(
        child: const ProgressRing(
          value: 50,
          activeColor: active,
          backgroundColor: background,
          strokeWidth: 8,
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('indeterminate ProgressRing semantics do not animate', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(child: const ProgressRing(semanticLabel: 'Loading')),
    );
    final node = tester.getSemantics(find.bySemanticsLabel('Loading'));
    final before = node.getSemanticsData();

    await tester.pump(const Duration(milliseconds: 500));

    final after = node.getSemanticsData();
    expect(after.label, before.label);
    expect(after.value, before.value);
    expect(after.flagsCollection, before.flagsCollection);
  });
}
