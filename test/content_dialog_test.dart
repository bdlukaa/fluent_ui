import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('ContentDialog displays title, content, and actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: Builder(
          builder: (context) => Button(
            child: const Text('Open Dialog'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => ContentDialog(
                  title: const Text('Dialog Title'),
                  content: const Text('Dialog Content'),
                  actions: [
                    Button(child: const Text('OK'), onPressed: () {}),
                    Button(child: const Text('Cancel'), onPressed: () {}),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Dialog Title'), findsOneWidget);
    expect(find.text('Dialog Content'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('ContentDialog actions work and dialog closes', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      wrapApp(
        child: Builder(
          builder: (context) => Button(
            child: const Text('Show Dialog'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => ContentDialog(
                  title: const Text('Title'),
                  actions: [
                    Button(
                      child: const Text('Close'),
                      onPressed: () {
                        pressed = true;
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Close'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(pressed, isTrue);
    expect(find.byType(ContentDialog), findsNothing);
  });

  testWidgets('ContentDialog with one action aligns it to end', (tester) async {
    await tester.pumpWidget(
      FluentApp(
        home: Builder(
          builder: (context) => Button(
            child: const Text('Dialog'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => ContentDialog(
                  actions: [
                    Button(child: const Text('Only'), onPressed: () {}),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Dialog'));
    await tester.pumpAndSettle();
    // Find the Align widget that directly wraps the 'Only' button
    final align = tester.widget<Align>(
      find
          .ancestor(
            of: find.widgetWithText(Button, 'Only'),
            matching: find.byType(Align),
          )
          .first,
    );
    expect(align.alignment, AlignmentDirectional.centerEnd);
  });

  testWidgets('ContentDialog uses custom style', (tester) async {
    const customStyle = ContentDialogThemeData(
      padding: EdgeInsetsDirectional.all(10),
      titlePadding: EdgeInsetsDirectional.all(20),
      bodyPadding: EdgeInsetsDirectional.all(30),
      actionsPadding: EdgeInsetsDirectional.all(40),
      titleStyle: TextStyle(fontSize: 30),
    );
    await tester.pumpWidget(
      FluentApp(
        home: Builder(
          builder: (context) => Button(
            child: const Text('Styled Dialog'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const ContentDialog(
                  title: Text('Styled'),
                  content: Text('This dialog has custom styles.'),
                  actions: [Button(onPressed: null, child: Text('Close'))],
                  style: customStyle,
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Styled Dialog'));
    await tester.pumpAndSettle();

    final titlePadding = tester.widget<Padding>(
      find
          .ancestor(of: find.text('Styled'), matching: find.byType(Padding))
          .first,
    );
    final bodyPadding = tester.widget<Padding>(
      find
          .ancestor(
            of: find.text('This dialog has custom styles.'),
            matching: find.byType(Padding),
          )
          .first,
    );
    final actionsPadding = tester.widget<Padding>(
      find
          .ancestor(of: find.byType(Button), matching: find.byType(Padding))
          .first,
    );
    expect(bodyPadding.padding, const EdgeInsetsDirectional.all(30));
    expect(actionsPadding.padding, const EdgeInsetsDirectional.all(40));
    expect(titlePadding.padding, const EdgeInsetsDirectional.all(20));

    final text = tester.widget<DefaultTextStyle>(
      find
          .ancestor(
            of: find.text('Styled'),
            matching: find.byType(DefaultTextStyle),
          )
          .first,
    );
    expect(text.style.fontSize, 30);
  });

  testWidgets('ContentDialog does not crash with no title/content/actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: Builder(
          builder: (context) => Button(
            child: const Text('Open'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const ContentDialog(),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(ContentDialog), findsOneWidget);
  });
}
