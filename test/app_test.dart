import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter_test/flutter_test.dart';

Widget wrapApp({required Widget child}) {
  return FluentApp(home: child);
}

void main() {
  testWidgets('Can nest apps', (tester) async {
    await tester.pumpWidget(
      const FluentApp(home: FluentApp(home: Text('Home sweet home'))),
    );

    expect(find.text('Home sweet home'), findsOneWidget);
  });

  testWidgets('Can get text scale from media query', (tester) async {
    double? textScaleFactor;
    await tester.pumpWidget(
      FluentApp(
        home: Builder(
          builder: (context) {
            textScaleFactor = MediaQuery.textScalerOf(context).scale(1);
            return Container();
          },
        ),
      ),
    );
    expect(textScaleFactor, isNotNull);
    expect(textScaleFactor, equals(1.0));
  });

  testWidgets('Has default material and fluent localizations', (tester) async {
    await tester.pumpWidget(
      FluentApp(
        home: Builder(
          builder: (context) {
            return Column(
              children: <Widget>[
                Text(MaterialLocalizations.of(context).selectAllButtonLabel),
                Text(FluentLocalizations.of(context).selectAllActionLabel),
              ],
            );
          },
        ),
      ),
    );

    // Default US "select all" text.
    expect(find.text('Select all'), findsNWidgets(2));
  });

  testWidgets('A parent material Theme is not overriden by FluentApp', (
    tester,
  ) async {
    await tester.pumpWidget(
      m.Theme(
        data: m.ThemeData.light(),
        child: FluentApp(
          theme: FluentThemeData.dark(),
          home: Builder(
            builder: (context) {
              return Column(
                children: <Widget>[
                  Text('${m.Theme.of(context).brightness}'),
                  Text('${FluentTheme.of(context).brightness}'),
                ],
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Brightness.light'), findsOneWidget);
    expect(find.text('Brightness.dark'), findsOneWidget);
  });

  testWidgets(
    'Do not display warning if country code is provided for supportedLocales',
    (tester) async {
      await tester.pumpWidget(
        const FluentApp(supportedLocales: [Locale('en', 'US')]),
      );
    },
  );
}
