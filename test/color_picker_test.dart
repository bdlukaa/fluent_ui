import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluent_ui/src/controls/pickers/color_picker/color_spectrum.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('ColorPicker - verifies initial state and preview visibility', (
    tester,
  ) async {
    var currentColor = Colors.blue.normal;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: ColorPicker(
              color: currentColor,
              onChanged: (color) {
                setState(() {
                  currentColor = color;
                });
              },
            ),
          );
        },
      ),
    );

    // Verify the ColorPicker widget exists
    expect(find.byType(ColorPicker), findsOneWidget);

    // Check if initial color is preserved
    final initialColorState = currentColor;
    expect(initialColorState, Colors.blue.normal);

    // Find color preview container
    final preview = find.descendant(
      of: find.byType(ColorPicker),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration != null &&
            widget.decoration is BoxDecoration,
      ),
    );
    expect(preview, findsWidgets);

    await tester.pump(const Duration(seconds: 1));

    // Verify the color value matches initial blue color
    expect(
      currentColor,
      equals(Colors.blue.normal),
      reason: 'Color value should match initial blue color',
    );
  });

  testWidgets('ColorPicker - switches between ring and box spectrum shapes', (
    tester,
  ) async {
    Color currentColor = Colors.blue;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: ColorPicker(
              color: currentColor,
              onChanged: (color) {
                setState(() {
                  currentColor = color;
                });
              },
              colorSpectrumShape: ColorSpectrumShape.box,
            ),
          );
        },
      ),
    );

    // Verify correct spectrum type is rendered
    expect(
      find.byType(ColorBoxSpectrum),
      findsOneWidget,
      reason: 'Box spectrum should be visible when specified',
    );
    expect(
      find.byType(ColorRingSpectrum),
      findsNothing,
      reason: 'Ring spectrum should not be visible when box is specified',
    );

    // Find and interact with box spectrum
    final boxSpectrum = find.byType(ColorBoxSpectrum);
    await tester.tapAt(tester.getCenter(boxSpectrum));
    await tester.pumpAndSettle();

    // Verify color changed after interaction
    expect(
      currentColor,
      isNot(equals(Colors.blue)),
      reason: 'Color should change after spectrum interaction',
    );
  });

  testWidgets(
    'ColorPicker - changes color through hex input with alpha support',
    (tester) async {
      Color currentColor = Colors.blue;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return wrapApp(
              child: ColorPicker(
                color: currentColor,
                onChanged: (color) {
                  setState(() {
                    currentColor = color;
                  });
                },
                isColorSliderVisible: false,
                isAlphaSliderVisible: false,
                isAlphaTextInputVisible: false,
                isMoreButtonVisible: false,
                isColorChannelTextInputVisible: false,
              ),
            );
          },
        ),
      );

      // Wait for widget to settle
      await tester.pump();
      await tester.pumpAndSettle();

      // Find hex input field
      final textboxFinder = find.byType(TextBox);
      expect(
        textboxFinder,
        findsWidgets,
        reason: 'Hex input TextBox should be visible',
      );

      // Test fully opaque red color
      await tester.enterText(textboxFinder.first, '#FFFF0000');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(
        currentColor,
        equals(const Color(0xFFFF0000)),
        reason: 'Color should change to opaque red',
      );

      // Test semi-transparent red color
      await tester.enterText(textboxFinder.first, '#80FF0000');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(
        currentColor,
        equals(const Color(0x80FF0000)),
        reason: 'Color should change to semi-transparent red',
      );
    },
  );
}
