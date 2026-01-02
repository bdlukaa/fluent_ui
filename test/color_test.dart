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
      expect(color.r, color.normal.r);
      expect(color.g, color.normal.g);
      expect(color.b, color.normal.b);
      for (final key in primaryKeys) {
        expect(color[key]!.a, 1.0);
      }
    }
  });

  test('All grey variants are opaque', () {
    const currentValue = 210;
    for (var i = currentValue; i > 0; i -= 10) {
      expect(Colors.grey[i].a, 1.0);
    }
  });
}
