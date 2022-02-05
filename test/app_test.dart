import 'package:flutter/material.dart' as m;
import 'package:flutter_test/flutter_test.dart';

import 'package:fluent_ui/fluent_ui.dart';

Widget wrapApp({required Widget child}) {
  return FluentApp(home: child);
}

void main() {
  testWidgets('Can nest apps', (WidgetTester tester) async {
    await tester.pumpWidget(
      const FluentApp(
        home: FluentApp(
          home: Text('Home sweet home'),
        ),
      ),
    );

    expect(find.text('Home sweet home'), findsOneWidget);
  });

  testWidgets('Can get text scale from media query',
      (WidgetTester tester) async {
    double? textScaleFactor;
    await tester.pumpWidget(FluentApp(
      home: Builder(builder: (BuildContext context) {
        textScaleFactor = MediaQuery.of(context).textScaleFactor;
        return Container();
      }),
    ));
    expect(textScaleFactor, isNotNull);
    expect(textScaleFactor, equals(1.0));
  });

  testWidgets('Has default material and fluent localizations',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      FluentApp(
        home: Builder(
          builder: (BuildContext context) {
            return Column(
              children: <Widget>[
                Text(MaterialLocalizations.of(context).selectAllButtonLabel),
                Text(FluentLocalizations.of(context).selectAllButtonLabel),
              ],
            );
          },
        ),
      ),
    );

    // Default US "select all" text.
    expect(find.text('Select all'), findsNWidgets(2));
  });

  testWidgets(
    'A parent material Theme is not overriden by FluentApp',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        m.Theme(
          data: m.ThemeData.light(),
          child: FluentApp(
            theme: ThemeData.dark(),
            home: Builder(
              builder: (BuildContext context) {
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
    },
  );
}
