import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:fluent_ui/fluent_ui.dart';

/// A [FormField] that contains a [TextBox].
///
/// This is a convenience widget that wraps a [TextBox] widget in a
/// [FormField].
///
/// A [Form] ancestor is not required. The [Form] simply makes it easier to
/// save, reset, or validate multiple fields at once. To use without a [Form],
/// pass a [GlobalKey] to the constructor and use [GlobalKey.currentState] to
/// save or reset the form field.
///
/// When a [controller] is specified, its [TextEditingController.text]
/// defines the [initialValue]. If this [FormField] is part of a scrolling
/// container that lazily constructs its children, like a [ListView] or a
/// [CustomScrollView], then a [controller] should be specified.
/// The controller's lifetime should be managed by a stateful widget ancestor
/// of the scrolling container.
///
/// If a [controller] is not specified, [initialValue] can be used to give
/// the automatically generated controller an initial value.
///
/// Remember to call [TextEditingController.dispose] of the [TextEditingController]
/// when it is no longer needed. This will ensure we discard any resources used
/// by the object.
///
/// See also:
///
///   * <https://docs.microsoft.com/en-us/windows/apps/design/controls/text-box>
///   * [TextBox], which is the underlying text field without the [Form]
///    integration.
class TextFormBox extends FormField<String> {
  /// Creates a text form box
  TextFormBox({
    Key? key,
    this.controller,
    String? initialValue,
    FocusNode? focusNode,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction? textInputAction,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextDirection? textDirection,
    TextAlign textAlign = TextAlign.start,
    TextAlignVertical? textAlignVertical,
    bool autofocus = false,
    bool readOnly = false,
    ToolbarOptions? toolbarOptions,
    bool? showCursor,
    String obscuringCharacter = '•',
    bool obscureText = false,
    bool autocorrect = true,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    bool enableSuggestions = true,
    int? maxLines = 1,
    int? minLines,
    bool expands = false,
    int? maxLength,
    double? minHeight,
    EdgeInsetsGeometry padding = kTextBoxPadding,
    ValueChanged<String>? onChanged,
    GestureTapCallback? onTap,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onFieldSubmitted,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    List<TextInputFormatter>? inputFormatters,
    bool? enabled,
    double cursorWidth = 2.0,
    double? cursorHeight,
    Radius cursorRadius = const Radius.circular(2.0),
    Color? cursorColor,
    Brightness? keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool enableInteractiveSelection = true,
    TextSelectionControls? selectionControls,
    ScrollPhysics? scrollPhysics,
    Iterable<String>? autofillHints,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
    String? placeholder,
    TextStyle? placeholderStyle,
    String? header,
    TextStyle? headerStyle,
    ScrollController? scrollController,
    Clip clipBehavior = Clip.antiAlias,
    Widget? prefix,
    OverlayVisibilityMode prefixMode = OverlayVisibilityMode.always,
    Widget? suffix,
    OverlayVisibilityMode suffixMode = OverlayVisibilityMode.always,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    String? restorationId,
    MaxLengthEnforcement? maxLengthEnforcement,
    ui.BoxHeightStyle selectionHeightStyle = ui.BoxHeightStyle.tight,
    ui.BoxWidthStyle selectionWidthStyle = ui.BoxWidthStyle.tight,
    BoxDecoration? decoration,
    bool enableIMEPersonalizedLearning = true,
    MouseCursor? mouseCursor,
    bool scribbleEnabled = true,
    Color? highlightColor,
    Color? errorHighlightColor,
  })  : assert(initialValue == null || controller == null),
        assert(obscuringCharacter.length == 1),
        assert(maxLines == null || maxLines > 0),
        assert(minLines == null || minLines > 0),
        assert(
          (maxLines == null) || (minLines == null) || (maxLines >= minLines),
          "minLines can't be greater than maxLines",
        ),
        assert(
          !expands || (maxLines == null && minLines == null),
          'minLines and maxLines must be null when expands is true.',
        ),
        assert(!obscureText || maxLines == 1,
            'Obscured fields cannot be multiline.'),
        assert(maxLength == null || maxLength > 0),
        super(
          key: key,
          initialValue:
              controller != null ? controller.text : (initialValue ?? ''),
          onSaved: onSaved,
          validator: validator,
          autovalidateMode: autovalidateMode,
          builder: (FormFieldState<String> field) {
            final _TextFormBoxState state = field as _TextFormBoxState;

            void onChangedHandler(String value) {
              field.didChange(value);
              if (onChanged != null) {
                onChanged(value);
              }
            }

            return FormRow(
              padding: EdgeInsets.zero,
              error: (field.errorText == null) ? null : Text(field.errorText!),
              child: UnmanagedRestorationScope(
                bucket: field.bucket,
                child: TextBox(
                  controller: state._effectiveController,
                  focusNode: focusNode,
                  keyboardType: keyboardType,
                  textInputAction: textInputAction,
                  style: style,
                  strutStyle: strutStyle,
                  textAlign: textAlign,
                  textAlignVertical: textAlignVertical,
                  textCapitalization: textCapitalization,
                  autofocus: autofocus,
                  toolbarOptions: toolbarOptions,
                  readOnly: readOnly,
                  showCursor: showCursor,
                  obscuringCharacter: obscuringCharacter,
                  obscureText: obscureText,
                  autocorrect: autocorrect,
                  smartDashesType: smartDashesType,
                  smartQuotesType: smartQuotesType,
                  enableSuggestions: enableSuggestions,
                  maxLines: maxLines,
                  minLines: minLines,
                  expands: expands,
                  maxLength: maxLength,
                  onChanged: onChangedHandler,
                  onTap: onTap,
                  onEditingComplete: onEditingComplete,
                  onSubmitted: onFieldSubmitted,
                  inputFormatters: inputFormatters,
                  enabled: enabled,
                  cursorWidth: cursorWidth,
                  cursorHeight: cursorHeight,
                  cursorColor: cursorColor,
                  cursorRadius: cursorRadius,
                  scrollPadding: scrollPadding,
                  scrollPhysics: scrollPhysics,
                  keyboardAppearance: keyboardAppearance,
                  enableInteractiveSelection: enableInteractiveSelection,
                  autofillHints: autofillHints,
                  placeholder: placeholder,
                  placeholderStyle: placeholderStyle,
                  header: header,
                  headerStyle: headerStyle,
                  scrollController: scrollController,
                  clipBehavior: clipBehavior,
                  prefix: prefix,
                  prefixMode: prefixMode,
                  suffix: suffix,
                  suffixMode: suffixMode,
                  highlightColor: (field.errorText == null)
                      ? highlightColor
                      : errorHighlightColor ?? Colors.red,
                  dragStartBehavior: dragStartBehavior,
                  minHeight: minHeight,
                  padding: padding,
                  maxLengthEnforcement: maxLengthEnforcement,
                  restorationId: restorationId,
                  selectionHeightStyle: selectionHeightStyle,
                  selectionWidthStyle: selectionWidthStyle,
                  decoration: decoration,
                  enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
                  mouseCursor: mouseCursor,
                  scribbleEnabled: scribbleEnabled,
                  textDirection: textDirection,
                  selectionControls: selectionControls,
                ),
              ),
            );
          },
        );

  final TextEditingController? controller;

  @override
  FormFieldState<String> createState() => _TextFormBoxState();
}

class _TextFormBoxState extends FormFieldState<String> {
  TextEditingController? _controller;

  TextEditingController? get _effectiveController =>
      widget.controller ?? _controller;

  @override
  TextFormBox get widget => super.widget as TextFormBox;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController(text: widget.initialValue);
    } else {
      widget.controller!.addListener(_handleControllerChanged);
    }
  }

  @override
  void didUpdateWidget(TextFormBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);

      if (oldWidget.controller != null && widget.controller == null) {
        _controller =
            TextEditingController.fromValue(oldWidget.controller!.value);
      }

      if (widget.controller != null) {
        setValue(widget.controller!.text);
        if (oldWidget.controller == null) {
          _controller = null;
        }
      }
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChanged);
    super.dispose();
  }

  @override
  void didChange(String? value) {
    super.didChange(value);

    if (value != null && _effectiveController!.text != value) {
      _effectiveController!.text = value;
    }
  }

  @override
  void reset() {
    super.reset();

    if (widget.initialValue != null) {
      setState(() {
        _effectiveController!.text = widget.initialValue!;
      });
    }
  }

  void _handleControllerChanged() {
    if (_effectiveController!.text != value) {
      didChange(_effectiveController!.text);
    }
  }
}
