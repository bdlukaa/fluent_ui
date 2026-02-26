import 'package:fluent_ui/fluent_ui.dart';
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

  testWidgets('Indeterminate ProgressBar renders in RTL directionality',
      (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: const Directionality(
          textDirection: TextDirection.rtl,
          child: ProgressBar(),
        ),
      ),
    );

    expect(find.byType(ProgressBar), findsOneWidget);
    // Pump a few frames to verify the indeterminate animation runs without error
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(ProgressBar), findsOneWidget);
  });
}
