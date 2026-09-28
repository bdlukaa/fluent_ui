import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('ProgressBar exposes correct semantics', (tester) async {
    await tester.pumpWidget(
      wrapApp(child: const ProgressBar(value: 66, semanticLabel: 'Loading')),
    );

    final semantics = tester
        .getSemantics(find.bySemanticsLabel('Loading'))
        .getSemanticsData();
    expect(semantics.label, 'Loading');
    expect(semantics.value, '66.00');
  });

  testWidgets('ProgressBar renders in LTR directionality', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: ProgressBar(value: 50),
        ),
      ),
    );

    expect(find.byType(ProgressBar), findsOneWidget);
  });

  testWidgets('ProgressBar renders in RTL directionality', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: const Directionality(
          textDirection: TextDirection.rtl,
          child: ProgressBar(value: 50),
        ),
      ),
    );

    expect(find.byType(ProgressBar), findsOneWidget);
  });

  testWidgets('Indeterminate ProgressBar renders in RTL directionality', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: const Directionality(
          textDirection: TextDirection.rtl,
          child: ProgressBar(),
        ),
      ),
    );

    expect(find.byType(ProgressBar), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(ProgressBar), findsOneWidget);
  });

  testWidgets(
    'indeterminate animation repaints without rebuilding CustomPaint',
    (tester) async {
      await tester.pumpWidget(wrapApp(child: const ProgressBar()));

      final customPaint = find.descendant(
        of: find.byType(ProgressBar),
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

  testWidgets('determinate ProgressBar does not keep a ticker running', (
    tester,
  ) async {
    await tester.pumpWidget(wrapApp(child: const ProgressBar(value: 50)));

    expect(tester.hasRunningAnimations, isFalse);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('ProgressBar stops and restarts its animation on mode changes', (
    tester,
  ) async {
    late void Function(void Function()) update;
    double? value;
    await tester.pumpWidget(
      wrapApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return ProgressBar(value: value);
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

  testWidgets('ProgressBar respects TickerMode', (tester) async {
    await tester.pumpWidget(
      wrapApp(child: const TickerMode(enabled: false, child: ProgressBar())),
    );
    expect(tester.hasRunningAnimations, isFalse);

    await tester.pumpWidget(
      wrapApp(child: const TickerMode(enabled: true, child: ProgressBar())),
    );
    await tester.pump();
    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('ProgressBar handles degenerate constraints', (tester) async {
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
            child: const ProgressBar(value: 50),
          ),
        ),
      );
      expect(tester.takeException(), isNull, reason: 'size: $size');
    }
  });

  testWidgets('ProgressBar preserves custom colors and stroke width', (
    tester,
  ) async {
    const active = Color(0xff123456);
    const background = Color(0xff654321);
    await tester.pumpWidget(
      wrapApp(
        child: const ProgressBar(
          value: 50,
          activeColor: active,
          backgroundColor: background,
          strokeWidth: 8,
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('indeterminate ProgressBar semantics do not animate', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(child: const ProgressBar(semanticLabel: 'Loading')),
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
