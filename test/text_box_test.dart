import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('TextBox displays entered text using controller', (tester) async {
    final controller = TextEditingController();
    const inputText = 'fluent_ui';
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(child: TextBox(controller: controller));
        },
      ),
    );
    final textBoxFinder = find.byType(TextBox);
    expect(textBoxFinder, findsOneWidget);
    await tester.enterText(textBoxFinder, inputText);
    await tester.pumpAndSettle();

    expect(controller.text, inputText);
  });
  testWidgets('TextBox updates value via onChanged callback when user types', (
    tester,
  ) async {
    var text = '';
    const inputText = 'fluent_ui';
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: TextBox(
              onChanged: (value) {
                setState(() {
                  text = value;
                });
              },
            ),
          );
        },
      ),
    );
    final textBoxFinder = find.byType(TextBox);
    expect(textBoxFinder, findsOneWidget);
    await tester.enterText(textBoxFinder, inputText);
    await tester.pumpAndSettle();

    expect(text, inputText);
  });

  testWidgets(
    'TextBox should maintain cursor position correctly during edits',
    (tester) async {
      final controller = TextEditingController();
      const inputText = 'fluent_ui';

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return wrapApp(child: TextBox(controller: controller));
          },
        ),
      );
      final textBoxFinder = find.byType(TextBox);
      expect(textBoxFinder, findsOneWidget);
      await tester.enterText(textBoxFinder, inputText);
      await tester.pumpAndSettle();

      expect(controller.selection.baseOffset, equals(inputText.length));
      expect(controller.selection.extentOffset, equals(inputText.length));
    },
  );

  testWidgets('TextBox should respect maxLength property', (tester) async {
    final controller = TextEditingController();
    const maxLength = 5;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: TextBox(maxLength: maxLength, controller: controller),
          );
        },
      ),
    );
    final textBoxFinder = find.byType(TextBox);
    expect(textBoxFinder, findsOneWidget);
    await tester.enterText(textBoxFinder, 'fluent_ui');
    await tester.pumpAndSettle();
    expect(controller.text.length, equals(maxLength));
    expect(controller.text, 'fluen');
  });

  testWidgets('TextBox should gain focus when tapped', (tester) async {
    final focusNode = FocusNode();

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(child: TextBox(focusNode: focusNode));
        },
      ),
    );
    final textBoxFinder = find.byType(TextBox);
    expect(textBoxFinder, findsOneWidget);
    expect(focusNode.hasFocus, false);
    await tester.tap(textBoxFinder);
    await tester.pumpAndSettle();
    expect(focusNode.hasFocus, true);
  });
  testWidgets('TextBox should lose focus when tapping outside', (tester) async {
    final focusNode = FocusNode();

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: Column(
              children: [
                TextBox(key: const Key('TextBox1'), focusNode: focusNode),
                const TextBox(key: Key('TextBox2')),
              ],
            ),
          );
        },
      ),
    );
    final textBoxFinder1 = find.byKey(const Key('TextBox1'));
    final textBoxFinder2 = find.byKey(const Key('TextBox2'));

    expect(textBoxFinder1, findsOneWidget);
    expect(textBoxFinder2, findsOneWidget);
    expect(focusNode.hasFocus, false);
    await tester.tap(textBoxFinder1);
    expect(focusNode.hasFocus, true);
    await tester.tap(textBoxFinder2);
    await tester.pumpAndSettle();
    expect(focusNode.hasFocus, false);
  });

  testWidgets('TextBox moves focus to next TextBox when Tab key is pressed', (
    tester,
  ) async {
    final focusNode1 = FocusNode();
    final focusNode2 = FocusNode();
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: Column(
              children: [
                TextBox(
                  autofocus: true,
                  key: const Key('TextBox1'),
                  focusNode: focusNode1,
                ),
                TextBox(focusNode: focusNode2, key: const Key('TextBox2')),
              ],
            ),
          );
        },
      ),
    );
    final textBoxFinder1 = find.byKey(const Key('TextBox1'));
    final textBoxFinder2 = find.byKey(const Key('TextBox2'));

    expect(textBoxFinder1, findsOneWidget);
    expect(textBoxFinder2, findsOneWidget);

    expect(focusNode1.hasFocus, true);
    expect(focusNode2.hasFocus, false);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    expect(focusNode1.hasFocus, false);
    expect(focusNode2.hasFocus, true);
  });

  testWidgets(
    'TextBox showing selection handles survives a rebuild of its Overlay',
    (tester) async {
      final controller = TextEditingController(text: 'fluent_ui');
      addTearDown(controller.dispose);
      // The TextBox is built directly by an OverlayEntry, so it rebuilds
      // whenever the Overlay does, including the build triggered by inserting
      // its own selection handle entries.
      await tester.pumpWidget(
        FluentApp(
          builder: (context, child) => Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (context) => TextBox(controller: controller),
              ),
            ],
          ),
        ),
      );

      // Double tapping the word selects it and shows the selection handles.
      final textStart =
          tester.getTopLeft(find.byType(EditableText)) + const Offset(4, 8);
      await tester.tapAt(textStart);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(textStart);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final editableText = tester.state<EditableTextState>(
        find.byType(EditableText),
      );
      expect(editableText.selectionOverlay?.handlesAreVisible, isTrue);
    },
  );

  testWidgets(
    'TextBox keeps its default selection controls until the undo controller '
    'changes',
    (tester) async {
      final firstUndoController = UndoHistoryController();
      final secondUndoController = UndoHistoryController();
      addTearDown(firstUndoController.dispose);
      addTearDown(secondUndoController.dispose);
      var undoController = firstUndoController;
      TextSelectionControls? selectionControls;
      late StateSetter setState;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, stateSetter) {
            setState = stateSetter;
            return wrapApp(
              child: TextBox(
                undoController: undoController,
                selectionControls: selectionControls,
              ),
            );
          },
        ),
      );
      TextSelectionControls? currentControls() => tester
          .widget<EditableText>(find.byType(EditableText))
          .selectionControls;

      final defaultControls = currentControls()!;
      expect(defaultControls, isA<WindowsTextSelectionHandleControls>());
      expect(
        (defaultControls as WindowsTextSelectionHandleControls)
            .undoHistoryController,
        same(firstUndoController),
      );

      setState(() {});
      await tester.pump();
      expect(currentControls(), same(defaultControls));

      setState(() => undoController = secondUndoController);
      await tester.pump();
      final refreshedControls =
          currentControls()! as WindowsTextSelectionHandleControls;
      expect(refreshedControls, isNot(same(defaultControls)));
      expect(
        refreshedControls.undoHistoryController,
        same(secondUndoController),
      );

      final customControls = WindowsTextSelectionHandleControls();
      setState(() => selectionControls = customControls);
      await tester.pump();
      expect(currentControls(), same(customControls));
    },
  );
}
