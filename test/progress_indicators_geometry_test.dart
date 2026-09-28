import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

class _RecordingCanvas implements Canvas {
  final lines = <({Offset start, Offset end, Paint paint})>[];
  final arcs = <({Rect rect, double start, double sweep, Paint paint})>[];

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #drawLine) {
      lines.add((
        start: invocation.positionalArguments[0] as Offset,
        end: invocation.positionalArguments[1] as Offset,
        paint: invocation.positionalArguments[2] as Paint,
      ));
      return null;
    }
    if (invocation.memberName == #drawArc) {
      arcs.add((
        rect: invocation.positionalArguments[0] as Rect,
        start: invocation.positionalArguments[1] as double,
        sweep: invocation.positionalArguments[2] as double,
        paint: invocation.positionalArguments[4] as Paint,
      ));
      return null;
    }
    return null;
  }
}

RenderCustomPaint _customPaint(WidgetTester tester, Type indicator) {
  final finder = find.descendant(
    of: find.byType(indicator),
    matching: find.byType(CustomPaint),
  );
  return tester.renderObject<RenderCustomPaint>(finder);
}

void main() {
  testWidgets('ProgressBar keeps its approved animation geometry', (
    tester,
  ) async {
    const samples = <({Duration elapsed, double start, double end})>[
      (elapsed: Duration.zero, start: 2.25, end: 2.25),
      (elapsed: Duration(milliseconds: 300), start: 2.25, end: 0.27),
      (elapsed: Duration(milliseconds: 750), start: 0.675, end: 0.675),
      (elapsed: Duration(milliseconds: 1500), start: 2.25, end: 2.25),
    ];

    for (final sample in samples) {
      await tester.pumpWidget(wrapApp(child: ProgressBar(key: UniqueKey())));
      await tester.pump(sample.elapsed);

      final renderObject = _customPaint(tester, ProgressBar);
      final canvas = _RecordingCanvas();
      renderObject.painter!.paint(canvas, renderObject.size);

      expect(canvas.lines, hasLength(2));
      const strokeWidth = 4.5;
      final adjustedWidth = renderObject.size.width - strokeWidth / 2;
      final expectedStart = sample.start == 2.25
          ? 2.25
          : adjustedWidth * sample.start + strokeWidth / 2;
      final expectedEnd = sample.start == sample.end
          ? expectedStart
          : adjustedWidth * sample.end;
      expect(canvas.lines[1].start.dx, closeTo(expectedStart, 0.0001));
      expect(canvas.lines[1].end.dx, closeTo(expectedEnd, 0.0001));
    }
  });

  testWidgets('ProgressRing keeps its approved tween geometry', (tester) async {
    const samples = <({Duration elapsed, double start, double sweep})>[
      (elapsed: Duration(milliseconds: 500), start: 225, sweep: 90),
      (elapsed: Duration(milliseconds: 1500), start: 765, sweep: 90),
    ];

    for (final sample in samples) {
      await tester.pumpWidget(wrapApp(child: ProgressRing(key: UniqueKey())));
      await tester.pump(sample.elapsed);

      final renderObject = _customPaint(tester, ProgressRing);
      final canvas = _RecordingCanvas();
      renderObject.painter!.paint(canvas, renderObject.size);

      expect(canvas.arcs, hasLength(2));
      expect(
        canvas.arcs[1].start,
        closeTo((sample.start - 90) * 2 * 3.141592653589793 / 360, 0.0001),
      );
      expect(
        canvas.arcs[1].sweep,
        closeTo(sample.sweep * 2 * 3.141592653589793 / 360, 0.0001),
      );
    }
  });

  testWidgets('ProgressRing preserves backwards sweep direction', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(child: const ProgressRing(backwards: true)),
    );
    await tester.pump(const Duration(milliseconds: 500));

    final renderObject = _customPaint(tester, ProgressRing);
    final canvas = _RecordingCanvas();
    renderObject.painter!.paint(canvas, renderObject.size);

    expect(canvas.arcs, hasLength(2));
    expect(
      canvas.arcs[1].start,
      closeTo((-225 - 90) * 2 * 3.141592653589793 / 360, 0.0001),
    );
  });

  testWidgets('ProgressBar updates custom colors after a widget change', (
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
        ),
      ),
    );

    final renderObject = _customPaint(tester, ProgressBar);
    final canvas = _RecordingCanvas();
    renderObject.painter!.paint(canvas, renderObject.size);

    expect(canvas.lines[0].paint.color.toARGB32(), background.toARGB32());
    expect(canvas.lines[1].paint.color.toARGB32(), active.toARGB32());
  });

  testWidgets('ProgressRing updates custom colors after a widget change', (
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
        ),
      ),
    );

    final renderObject = _customPaint(tester, ProgressRing);
    final canvas = _RecordingCanvas();
    renderObject.painter!.paint(canvas, renderObject.size);

    expect(canvas.arcs[0].paint.color.toARGB32(), background.toARGB32());
    expect(canvas.arcs[1].paint.color.toARGB32(), active.toARGB32());
  });

  testWidgets('theme accent changes reach ProgressBar paint', (tester) async {
    final firstTheme = FluentThemeData(accentColor: Colors.red.toAccentColor());
    final secondTheme = FluentThemeData(
      accentColor: Colors.green.toAccentColor(),
    );
    await tester.pumpWidget(
      wrapApp(
        child: FluentTheme(
          data: firstTheme,
          child: const ProgressBar(value: 50),
        ),
      ),
    );

    var renderObject = _customPaint(tester, ProgressBar);
    var canvas = _RecordingCanvas();
    renderObject.painter!.paint(canvas, renderObject.size);
    expect(
      canvas.lines[1].paint.color.toARGB32(),
      firstTheme.accentColor.defaultBrushFor(firstTheme.brightness).toARGB32(),
    );

    await tester.pumpWidget(
      wrapApp(
        child: FluentTheme(
          data: secondTheme,
          child: const ProgressBar(value: 50),
        ),
      ),
    );

    renderObject = _customPaint(tester, ProgressBar);
    canvas = _RecordingCanvas();
    renderObject.painter!.paint(canvas, renderObject.size);
    expect(
      canvas.lines[1].paint.color.toARGB32(),
      secondTheme.accentColor
          .defaultBrushFor(secondTheme.brightness)
          .toARGB32(),
    );
  });

  testWidgets('theme accent changes reach ProgressRing paint', (tester) async {
    final firstTheme = FluentThemeData(accentColor: Colors.red.toAccentColor());
    final secondTheme = FluentThemeData(
      accentColor: Colors.green.toAccentColor(),
    );
    await tester.pumpWidget(
      wrapApp(
        child: FluentTheme(
          data: firstTheme,
          child: const ProgressRing(value: 50),
        ),
      ),
    );

    var renderObject = _customPaint(tester, ProgressRing);
    var canvas = _RecordingCanvas();
    renderObject.painter!.paint(canvas, renderObject.size);
    expect(
      canvas.arcs[1].paint.color.toARGB32(),
      firstTheme.accentColor.defaultBrushFor(firstTheme.brightness).toARGB32(),
    );

    await tester.pumpWidget(
      wrapApp(
        child: FluentTheme(
          data: secondTheme,
          child: const ProgressRing(value: 50),
        ),
      ),
    );

    renderObject = _customPaint(tester, ProgressRing);
    canvas = _RecordingCanvas();
    renderObject.painter!.paint(canvas, renderObject.size);
    expect(
      canvas.arcs[1].paint.color.toARGB32(),
      secondTheme.accentColor
          .defaultBrushFor(secondTheme.brightness)
          .toARGB32(),
    );
  });
}
