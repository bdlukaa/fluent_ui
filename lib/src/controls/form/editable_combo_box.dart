part of 'combo_box.dart';

/// A function that submits the text of an editable combo box.
///
/// The function should return the new value of the text.
///
/// In the following example, everytime the user submits the text box, the
/// text is uppercased
/// ```dart
/// EditableComboBox(
///   onFieldSubmitted: (text) {
///     return text.toUpperCase();
///   },
/// ),
/// ```
typedef SubmitEditableCombobox = String Function(String text);

/// By default, a combo box lets the user select from a pre-defined list of
/// options. However, there are cases where the list contains only a subset of
/// valid values, and the user should be able to enter other values that aren't
/// listed. To support this, you can make the combo box editable.
///
/// See also:
///   * <https://docs.microsoft.com/en-us/windows/apps/design/controls/combo-box#make-a-combo-box-editable>
class EditableComboBox<T> extends ComboBox<T> {
  /// Creates an editable combo box.
  const EditableComboBox({
    required this.onFieldSubmitted,
    super.key,
    super.autofocus,
    super.popupColor,
    super.disabledPlaceholder,
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
    this.textController,
    this.onTextChanged,
    this.inputFormatters,
    // When adding new arguments, consider adding similar arguments to
    // EditableComboboxFormField.
  });

  /// Called when the text field text is submitted
  ///
  /// Return the new value of the text.
  ///
  /// In the folllowing example, everytime the user submits the text box, the
  /// text is uppercased
  /// ```dart
  /// EditableComboBox(
  ///   onFieldSubmitted: (text) {
  ///     return text.toUpperCase();
  ///   },
  /// ),
  /// ```
  final SubmitEditableCombobox onFieldSubmitted;

  /// The text controller attached to the text field.
  ///
  /// If not provided, a new controller will be created.
  final TextEditingController? textController;

  /// Called when the text field text is changed.
  ///
  /// In the following example, everytime the user types a character, the text
  /// is printed to the console.
  ///
  /// ```dart
  /// EditableComboBox(
  ///   onTextChanged: (text) {
  ///     print(text);
  ///   },
  /// ),
  /// ```
  ///
  /// See also:
  ///
  ///   * [onChanged], which is called when the selected value changes.
  final ValueChanged<String>? onTextChanged;

  /// {@macro flutter.widgets.editableText.inputFormatters}
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<ComboBox<T>> createState() => _EditableComboboxState<T>();
}

class _EditableComboboxState<T> extends ComboBoxState<T> {
  @override
  EditableComboBox<T> get widget => super.widget as EditableComboBox<T>;

  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.textController ?? TextEditingController();
    _setText('${widget.value}');
  }

  @override
  void _onChanged(T? newValue) {
    super._onChanged(newValue);

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
    );
  }

  @override
  void _handleFocusChanged() {
    super._handleFocusChanged();

    // if lost focus, call onFieldSubmitted
    if (!focusNode!.hasFocus) {
      final text = controller.text;
      final newText = widget.onFieldSubmitted(text);
      _setText(newText);
    }
  }

  @override
  void didUpdateWidget(covariant EditableComboBox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.textController == null && widget.textController != null) {
      controller.dispose();
      controller = widget.textController!;
      _setText('${widget.value}');
    } else if (oldWidget.textController != null &&
        widget.textController == null) {
      controller = TextEditingController(text: '${widget.value}');
    }
  }

  @override
  void dispose() {
    if (widget.textController == null) controller.dispose();
    super.dispose();
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
        style: widget.style,
        focusNode: focusNode,
        autofocus: widget.autofocus,
        controller: controller,
        expands: widget.isExpanded,
        enabled: isEnabled,
        unfocusedColor: Colors.transparent,
        suffix: Builder(
          builder: (context) {
            return IconButton(
              icon: IconTheme.merge(
                data: IconThemeData(
                  color: _iconColor(context),
                  size: widget.iconSize,
                ),
                child: widget.icon,
              ),
              onPressed: openPopup,
            );
          },
        ),
        onSubmitted: (text) {
          final newText = widget.onFieldSubmitted(text);
          _setText(newText);
        },
        onChanged: widget.onTextChanged,
        inputFormatters: widget.inputFormatters,
      ),
    );
  }
}

/// A [FormField] that contains a [ComboBox].
///
/// This is a convenience widget that wraps a [ComboBox] widget in a
/// [FormField].
///
/// A [Form] ancestor is not required. The [Form] simply makes it easier to
/// save, reset, or validate multiple fields at once. To use without a [Form],
/// pass a [GlobalKey] to the constructor and use [GlobalKey.currentState] to
/// save or reset the form field.
///
/// See also:
///
///  * [ComboBox], which is the underlying text field without the [Form]
///    integration.
class ComboboxFormField<T> extends FormField<T> {
  /// Creates a [ComboBox] widget that is a [FormField]
  ///
  /// For a description of the `onSaved`, `validator`, or `autovalidateMode`
  /// parameters, see [FormField]. For the rest, see [ComboBox].
  ///
  /// The `items`, `elevation`, `iconSize`, `isExpanded` and `autofocus`
  /// parameters must not be null.
  ComboboxFormField({
    required List<ComboBoxItem<T>>? items,
    required this.onChanged,
    super.key,
    ComboBoxBuilder? selectedItemBuilder,
    T? value,
    Widget? placeholder,
    Widget? disabledPlaceholder,
    VoidCallback? onTap,
    int elevation = 8,
    TextStyle? style,
    Widget icon = const WindowsIcon(WindowsIcons.chevron_down),
    Color? iconDisabledColor,
    Color? iconEnabledColor,
    double iconSize = 8.0,
    bool isExpanded = false,
    Color? focusColor,
    FocusNode? focusNode,
    bool autofocus = false,
    Color? popupColor,
    super.onSaved,
    super.validator,
    super.autovalidateMode = AutovalidateMode.disabled,
    // When adding new arguments, consider adding similar arguments to
    // ComboBox.
  }) : super(
         initialValue: value,
         builder: (field) {
           final state = field as _ComboboxFormFieldState<T>;

           // An unfocusable Focus widget so that this widget can detect if its
           // descendants have focus or not.
           return Focus(
             canRequestFocus: false,
             skipTraversal: true,
             child: Builder(
               builder: (context) {
                 return FormRow(
                   padding: EdgeInsetsDirectional.zero,
                   error: field.errorText != null
                       ? Text(field.errorText!)
                       : null,
                   child: Align(
                     alignment: AlignmentDirectional.centerStart,
                     child: ComboBox<T>(
                       items: items,
                       selectedItemBuilder: selectedItemBuilder,
                       value: state.value,
                       placeholder: placeholder,
                       disabledPlaceholder: disabledPlaceholder,
                       onChanged: onChanged == null ? null : state.didChange,
                       onTap: onTap,
                       elevation: elevation,
                       style: style,
                       icon: icon,
                       iconDisabledColor: iconDisabledColor,
                       iconEnabledColor: iconEnabledColor,
                       iconSize: iconSize,
                       isExpanded: isExpanded,
                       focusColor: focusColor,
                       focusNode: focusNode,
                       autofocus: autofocus,
                       popupColor: popupColor,
                     ),
                   ),
                 );
               },
             ),
           );
         },
       );

  /// {@macro flutter.material.dropdownButton.onChanged}
  final ValueChanged<T?>? onChanged;

  @override
  FormFieldState<T> createState() => _ComboboxFormFieldState<T>();
}

class _ComboboxFormFieldState<T> extends FormFieldState<T> {
  @override
  void didChange(T? value) {
    super.didChange(value);
    final dropdownButtonFormField = widget as ComboboxFormField<T>;
    assert(dropdownButtonFormField.onChanged != null);
    dropdownButtonFormField.onChanged!(value);
  }

  @override
  void didUpdateWidget(ComboboxFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setValue(widget.initialValue);
    }
  }
}

/// A [FormField] that contains an [EditableComboBox].
///
/// This is a convenience widget that wraps an [EditableComboBox] widget in a
/// [FormField].
///
/// A [Form] ancestor is not required. The [Form] simply makes it easier to
/// save, reset, or validate multiple fields at once. To use without a [Form],
/// pass a [GlobalKey] to the constructor and use [GlobalKey.currentState] to
/// save or reset the form field.
///
/// See also:
///
///  * [EditableComboBox], which is the underlying text field without the [Form]
///    integration.
class EditableComboboxFormField<T> extends FormField<T> {
  /// Creates an [EditableComboBox] widget that is a [FormField]
  ///
  /// For a description of the `onSaved`, `validator`, or `autovalidateMode`
  /// parameters, see [FormField]. For the rest, see [EditableComboBox].
  ///
  /// The `items`, `elevation`, `iconSize`, `isExpanded` and `autofocus`
  /// parameters must not be null.
  EditableComboboxFormField({
    required List<ComboBoxItem<T>>? items,
    required this.onChanged,
    required SubmitEditableCombobox onFieldSubmitted,
    super.key,
    ComboBoxBuilder? selectedItemBuilder,
    super.initialValue,
    Widget? placeholder,
    Widget? disabledPlaceholder,
    VoidCallback? onTap,
    int elevation = 8,
    TextStyle? style,
    Widget icon = const WindowsIcon(WindowsIcons.chevron_down),
    Color? iconDisabledColor,
    Color? iconEnabledColor,
    double iconSize = 8.0,
    bool isExpanded = false,
    Color? focusColor,
    FocusNode? focusNode,
    bool autofocus = false,
    Color? popupColor,
    super.onSaved,
    super.validator,
    super.autovalidateMode = AutovalidateMode.disabled,
    List<TextInputFormatter>? inputFormatters,
    // When adding new arguments, consider adding similar arguments to
    // EditableComboBox.
  }) : super(
         builder: (field) {
           final state = field as _EditableComboboxFormFieldState<T>;

           // An unfocusable Focus widget so that this widget can detect if its
           // descendants have focus or not.
           return Focus(
             canRequestFocus: false,
             skipTraversal: true,
             child: Builder(
               builder: (context) {
                 return FormRow(
                   padding: EdgeInsetsDirectional.zero,
                   error: field.errorText != null
                       ? Text(field.errorText!)
                       : null,
                   child: Align(
                     alignment: AlignmentDirectional.centerStart,
                     child: EditableComboBox<T>(
                       items: items,
                       selectedItemBuilder: selectedItemBuilder,
                       value: state.value,
                       placeholder: placeholder,
                       disabledPlaceholder: disabledPlaceholder,
                       onChanged: onChanged == null ? null : state.didChange,
                       onTap: onTap,
                       elevation: elevation,
                       style: style,
                       icon: icon,
                       iconDisabledColor: iconDisabledColor,
                       iconEnabledColor: iconEnabledColor,
                       iconSize: iconSize,
                       isExpanded: isExpanded,
                       focusColor: focusColor,
                       focusNode: focusNode,
                       autofocus: autofocus,
                       popupColor: popupColor,
                       onFieldSubmitted: onFieldSubmitted,
                       inputFormatters: inputFormatters,
                     ),
                   ),
                 );
               },
             ),
           );
         },
       );

  /// {@macro flutter.material.dropdownButton.onChanged}
  final ValueChanged<T?>? onChanged;

  @override
  FormFieldState<T> createState() => _EditableComboboxFormFieldState<T>();
}

class _EditableComboboxFormFieldState<T> extends FormFieldState<T> {
  @override
  void didChange(T? value) {
    super.didChange(value);
    final dropdownButtonFormField = widget as EditableComboboxFormField<T>;
    assert(dropdownButtonFormField.onChanged != null);
    dropdownButtonFormField.onChanged!(value);
  }

  @override
  void didUpdateWidget(EditableComboboxFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setValue(widget.initialValue);
    }
  }
}
