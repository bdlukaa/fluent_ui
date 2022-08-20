part of 'combo_box.dart';

typedef SubmitEditableCombobox = String Function(String text);

/// By default, a combo box lets the user select from a pre-defined list of
/// options. However, there are cases where the list contains only a subset of
/// valid values, and the user should be able to enter other values that aren't
/// listed. To support this, you can make the combo box editable.
///
/// See also:
///   * <https://docs.microsoft.com/en-us/windows/apps/design/controls/combo-box#make-a-combo-box-editable>
class EditableCombobox<T> extends Combobox<T> {
  /// Creates an editable combobox.
  const EditableCombobox({
    super.key,
    super.autofocus,
    super.comboboxColor,
    super.disabledHint,
    super.elevation,
    super.focusColor,
    super.focusNode,
    super.icon,
    super.iconDisabledColor,
    super.iconEnabledColor,
    super.iconSize,
    super.isExpanded,
    super.items,
    super.onChanged,
    super.onTap,
    super.placeholder,
    super.selectedItemBuilder,
    super.style,
    super.value,
    required this.onFieldSubmitted,
  });

  /// Called when the text field text is submitted
  ///
  /// Return the new value of the text.
  ///
  /// In the folllowing example, everytime the user submits the text box, the
  /// text is uppercased
  /// ```dart
  /// EditableCombobox(
  ///   onFieldSubmitted: (text) {
  ///     return text.toUpperCase();
  ///   }
  /// ),
  /// ```
  final SubmitEditableCombobox onFieldSubmitted;

  @override
  State<Combobox<T>> createState() =>
      // ignore: no_logic_in_create_state
      _EditableComboboxState<T>()..editable = this;
}

class _EditableComboboxState<T> extends ComboboxState<T> {
  late final EditableCombobox editable;

  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
      text: '${widget.value}',
    );
  }

  @override
  void onChanged(T? newValue) {
    super.onChanged(newValue);

    // when the popup is closed, we set the new text and select the text
    _setText(newValue?.toString());
  }

  void _setText(String? text) {
    if (text == null) {
      controller.clear();
    } else {
      controller.text = text;
    }

    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
      affinity: TextAffinity.downstream,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasFluentLocalizations(context));

    return Focus(
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) {
          return KeyEventResult.ignored;
        }

        if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
            event.logicalKey == LogicalKeyboardKey.arrowUp) {
          openPopup();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: TextBox(
        focusNode: focusNode,
        autofocus: widget.autofocus,
        controller: controller,
        expands: widget.isExpanded,
        enabled: isEnabled,
        unfocusedColor: Colors.transparent,
        suffix: IconButton(
          icon: IconTheme.merge(
            data: IconThemeData(color: iconColor, size: widget.iconSize),
            child: widget.icon,
          ),
          onPressed: openPopup,
        ),
        onSubmitted: (text) {
          final newText = editable.onFieldSubmitted(text);
          _setText(newText);
        },
      ),
    );
  }
}
