import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('PasswordBox shows reveal button in peek mode when focused', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: PasswordBox(controller: TextEditingController(text: 'password')),
      ),
    );

    await tester.tap(find.byType(PasswordBox));
    await tester.pumpAndSettle();

    expect(find.byIcon(FluentIcons.red_eye), findsOneWidget);
  });

  testWidgets('PasswordBox always shows reveal button in peekAlways mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: PasswordBox(
          controller: TextEditingController(text: 'password'),
          revealMode: PasswordRevealMode.peekAlways,
        ),
      ),
    );

    await tester.tap(find.byType(PasswordBox));
    await tester.pump();
    await tester.tapAt(Offset.zero);
    await tester.pump();

    expect(find.byIcon(FluentIcons.red_eye), findsOneWidget);
  });

  testWidgets('PasswordBox shows placeholder when empty', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: const PasswordBox(
          placeholder: 'Enter password',
          revealMode: PasswordRevealMode.hidden,
        ),
      ),
    );

    expect(find.text('Enter password'), findsOneWidget);
  });

  testWidgets('PasswordBox calls onChanged when text changes', (tester) async {
    String? newValue;
    await tester.pumpWidget(
      wrapApp(
        child: PasswordBox(
          onChanged: (value) => newValue = value,
          revealMode: PasswordRevealMode.hidden,
        ),
      ),
    );

    await tester.enterText(find.byType(PasswordBox), 'newpass');
    await tester.pump();

    expect(newValue, equals('newpass'));
  });

  testWidgets('PasswordBox is disabled when enabled is false', (tester) async {
    await tester.pumpWidget(
      wrapApp(child: const ScaffoldPage(content: PasswordBox(enabled: false))),
    );

    final textBox = tester.widget<PasswordBox>(find.byType(PasswordBox));
    expect(textBox.enabled, isFalse);

    await tester.tap(find.byType(PasswordBox));
    await tester.pump();

    expect(find.byIcon(FluentIcons.red_eye), findsNothing);
  });

  testWidgets('PasswordBox shows leading icon when provided', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: const ScaffoldPage(
          content: PasswordBox(
            leadingIcon: Icon(FluentIcons.password_field),
            revealMode: PasswordRevealMode.hidden,
          ),
        ),
      ),
    );

    expect(find.byIcon(FluentIcons.password_field), findsOneWidget);
  });
}
