import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

List<DiagnosticsNode> _properties(Diagnosticable value) =>
    value.toDiagnosticsNode().getProperties();

DiagnosticsNode _property(Diagnosticable value, String name) =>
    _properties(value).firstWhere((property) => property.name == name);

void main() {
  test('Typography reports its display style with the API field name', () {
    const typography = Typography.raw();
    final property = _property(typography, 'display');

    expect(property, isA<DiagnosticsProperty<TextStyle>>());
    expect(
      _properties(typography).map((property) => property.name),
      isNot(contains('header')),
    );
  });

  test('theme and style diagnostics expose corrected property names', () {
    expect(
      _property(const RadioButtonThemeData(), 'foregroundColor'),
      isA<DiagnosticsProperty<Object?>>(),
    );
    expect(
      _property(const SliderThemeData(), 'thumbRadius'),
      isA<ObjectFlagProperty<WidgetStateProperty<double?>?>>(),
    );
    expect(
      _property(const SliderThemeData(), 'trackHeight'),
      isA<ObjectFlagProperty<WidgetStateProperty<double?>?>>(),
    );
    expect(
      _property(
        const ScrollbarThemeData(crossAxisMargin: 2),
        'crossAxisMargin',
      ).value,
      2.0,
    );
  });

  test('text input and suggestions avoid user-provided diagnostic values', () {
    final textBox = TextBox(
      controller: TextEditingController(text: 'private value'),
      placeholder: 'Private hint',
    );
    final suggestions = AutoSuggestBox<String>(
      items: [AutoSuggestBoxItem(value: 'private', label: 'Private')],
    );

    expect(
      _property(textBox, 'controller'),
      isA<ObjectFlagProperty<TextEditingController?>>(),
    );
    expect(
      _property(textBox, 'placeholder'),
      isA<ObjectFlagProperty<String?>>(),
    );
    expect(_property(suggestions, 'itemCount').value, 1);
  });

  testWidgets('NavigationViewState exposes safe runtime diagnostics', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: NavigationView(
          pane: NavigationPane(
            selected: 0,
            items: [
              PaneItem(
                icon: const Icon(FluentIcons.home),
                title: const Text('Home'),
                body: const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );

    final state = tester.state<NavigationViewState>(
      find.byType(NavigationView),
    );
    final properties = _properties(state);

    expect(
      properties.map((property) => property.name),
      containsAll([
        'requestedDisplayMode',
        'displayMode',
        'isPaneOpen',
        'isTransitioning',
        'selectedIndex',
        'historyDepth',
      ]),
    );
  });
}
