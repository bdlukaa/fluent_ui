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
      extentOffset: controller.text.length - 1,
      affinity: TextAffinity.downstream,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasFluentLocalizations(context));

    final theme = FluentTheme.of(context);

    // The width of the button and the menu are defined by the widest
    // item and the width of the placeholder.
    // We should explicitly type the items list to be a list of <Widget>,
    // otherwise, no explicit type adding items maybe trigger a crash/failure
    // when placeholder and selectedItemBuilder are provided.
    final List<Widget> items = widget.selectedItemBuilder == null
        ? (widget.items != null ? List<Widget>.from(widget.items!) : <Widget>[])
        : List<Widget>.from(widget.selectedItemBuilder!(context));

    int? placeholderIndex;
    if (widget.placeholder != null ||
        (!isEnabled && widget.disabledHint != null)) {
      Widget displayedHint = isEnabled
          ? widget.placeholder!
          : widget.disabledHint ?? widget.placeholder!;
      if (widget.selectedItemBuilder == null) {
        displayedHint = _ComboboxItemContainer(child: displayedHint);
      }

      placeholderIndex = items.length;
      items.add(DefaultTextStyle(
        style: textStyle!.copyWith(color: theme.disabledColor),
        child: IgnorePointer(
          ignoringSemantics: false,
          child: displayedHint,
        ),
      ));
    }

    const EdgeInsetsGeometry padding = _kAlignedButtonPadding;

    // If value is null (then selectedIndex is null) then we
    // display the placeholder or nothing at all.
    final Widget innerItemsWidget;
    if (items.isEmpty) {
      innerItemsWidget = Container();
    } else {
      innerItemsWidget = _ContainerWithoutPadding(
        child: IndexedStack(
          sizing: StackFit.passthrough,
          index: selectedIndex ?? placeholderIndex,
          alignment: AlignmentDirectional.centerStart,
          children: items.map((Widget item) {
            return Column(mainAxisSize: MainAxisSize.min, children: [item]);
          }).toList(),
        ),
      );
    }

    Widget result = DefaultTextStyle(
      style: isEnabled
          ? textStyle!
          : textStyle!.copyWith(color: theme.disabledColor),
      child: Container(
        padding: padding.resolve(Directionality.of(context)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.isExpanded)
              Expanded(child: innerItemsWidget)
            else
              innerItemsWidget,
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8.0),
              child: IconTheme.merge(
                data: IconThemeData(color: iconColor, size: widget.iconSize),
                child: widget.icon,
              ),
            ),
          ],
        ),
      ),
    );

    return TextBox(
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
      onTap: () {
        _setText(controller.text);
      },
    );

    return Semantics(
      button: true,
      child: Actions(
        actions: _actionMap,
        child: Button(
          onPressed: isEnabled ? openPopup : null,
          autofocus: widget.autofocus,
          focusNode: focusNode,
          style: ButtonStyle(padding: ButtonState.all(EdgeInsets.zero)),
          child: result,
        ),
      ),
    );
  }
}
