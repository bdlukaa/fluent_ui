import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

const primaryKeys = <String>[
  'darkest',
  'darker',
  'dark',
  'normal',
  'light',
  'lighter',
  'lightest',
];

void main() {
  test('All accent colors are opaque and equal their primary color', () {
    for (final color in Colors.accentColors) {
      expect(color.value, color.normal.value);
      for (final key in primaryKeys) {
        expect(color[key]!.alpha, 0xFF);
      }
    }

    expect(Colors.blue.value, Colors.blue.normal.value);
  });

  test('All grey variants are opaque', () {
    var currentValue = 210;
    for (var i = currentValue; i > 0; i -= 10) {
      expect(Colors.grey[i].alpha, 0xFF);
    }
  });
}
