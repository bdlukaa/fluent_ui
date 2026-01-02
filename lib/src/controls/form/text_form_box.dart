import 'dart:ui' as ui;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

/// A base class for form fields that can have a [TextEditingController].
abstract class ControllableFormBox extends FormField<String> {
  /// The controller for the text input.
  final TextEditingController? controller;

  /// Creates a controllable form box.
  const ControllableFormBox({
    required super.builder,
    super.autovalidateMode,
    super.enabled,
    super.initialValue,
    super.key,
    super.onSaved,
    super.restorationId,
    super.validator,
    this.controller,
  });
}

/// A [FormField] that contains a [TextBox].
///
/// This is a convenience widget that wraps a [TextBox] widget in a
/// [FormField].
///
/// A [Form] ancestor is not required. The [Form] simply makes it easier to
/// save, reset, or validate multiple fields at once. To use without a [Form],
/// pass a `GlobalKey<FormFieldState>` (see [GlobalKey]) to the constructor and use
/// [GlobalKey.currentState] to save or reset the form field.
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
/// {@macro flutter.material.textfield.wantKeepAlive}
///
/// Remember to call [TextEditingController.dispose] of the [TextEditingController]
/// when it is no longer needed. This will ensure any resources used by the object
/// are discarded.
///
/// See also:
///
///   * [TextBox], which is the underlying text field without the [Form]
///    integration.
///   * <https://docs.microsoft.com/en-us/windows/apps/design/controls/text-box>
class TextFormBox extends ControllableFormBox {
  /// Creates a [FormField] that contains a [TextBox].
  ///
  /// When a [controller] is specified, [initialValue] must be null (the
  /// default). If [controller] is null, then a [TextEditingController]
  /// will be constructed automatically and its `text` will be initialized
  /// to [initialValue] or the empty string.
  ///
  /// For documentation about the various parameters, see the [TextBox] class
  /// and [TextBox.new], the constructor.
  TextFormBox({
    super.key,
    super.controller,
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
    EdgeInsetsGeometry padding = kTextBoxPadding,
    ValueChanged<String>? onChanged,
    GestureTapCallback? onTap,
    TapRegionCallback? onTapOutside,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onFieldSubmitted,
    super.onSaved,
    super.validator,
    List<TextInputFormatter>? inputFormatters,
    super.enabled = true,
    double cursorWidth = 2.0,
    double? cursorHeight,
    Radius cursorRadius = const Radius.circular(2),
    Color? cursorColor,
    Brightness? keyboardAppearance,
    EdgeInsetsGeometry scrollPadding = const EdgeInsetsDirectional.all(20),
    bool? enableInteractiveSelection,
    TextSelectionControls? selectionControls,
    ScrollPhysics? scrollPhysics,
    Iterable<String>? autofillHints,
    super.autovalidateMode = AutovalidateMode.disabled,
    String? placeholder,
    TextStyle? placeholderStyle,
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
    WidgetStateProperty<BoxDecoration>? decoration,
    bool enableIMEPersonalizedLearning = true,
    bool stylusHandwritingEnabled =
        EditableText.defaultStylusHandwritingEnabled,
    Color? highlightColor,
    Color? errorHighlightColor,
    Color? unfocusedColor,
    EditableTextContextMenuBuilder? contextMenuBuilder =
        TextBox.defaultContextMenuBuilder,
    TextMagnifierConfiguration? magnifierConfiguration,
    SpellCheckConfiguration? spellCheckConfiguration,
  }) : assert(initialValue == null || controller == null),
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
       assert(
         !obscureText || maxLines == 1,
         'Obscured fields cannot be multiline.',
       ),
       assert(maxLength == null || maxLength > 0),
       super(
         initialValue: controller != null
             ? controller.text
             : (initialValue ?? ''),
         builder: (field) {
           assert(debugCheckHasFluentTheme(field.context));
           final theme = FluentTheme.of(field.context);
           final state = field as TextFormBoxState;

           void onChangedHandler(String value) {
             field.didChange(value);
             if (onChanged != null) {
               onChanged(value);
             }
           }

           return UnmanagedRestorationScope(
             bucket: field.bucket,
             child: FormRow(
               padding: EdgeInsetsDirectional.zero,
               error: (field.errorText == null) ? null : Text(field.errorText!),
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
                 readOnly: readOnly,
                 showCursor: showCursor,
                 obscuringCharacter: obscuringCharacter,
                 obscureText: obscureText,
                 autocorrect: autocorrect,
                 smartDashesType:
                     smartDashesType ??
                     (obscureText
                         ? SmartDashesType.disabled
                         : SmartDashesType.enabled),
                 smartQuotesType:
                     smartQuotesType ??
                     (obscureText
                         ? SmartQuotesType.disabled
                         : SmartQuotesType.enabled),
                 enableSuggestions: enableSuggestions,
                 maxLines: maxLines,
                 minLines: minLines,
                 expands: expands,
                 maxLength: maxLength,
                 onChanged: onChangedHandler,
                 onTap: onTap,
                 onTapOutside: onTapOutside,
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
                 scrollController: scrollController,
                 clipBehavior: clipBehavior,
                 prefix: prefix,
                 prefixMode: prefixMode,
                 suffix: suffix,
                 suffixMode: suffixMode,
                 highlightColor: (field.errorText == null)
                     ? highlightColor
                     : errorHighlightColor ??
                           Colors.red.defaultBrushFor(theme.brightness),
                 unfocusedColor: unfocusedColor,
                 dragStartBehavior: dragStartBehavior,
                 padding: padding,
                 maxLengthEnforcement: maxLengthEnforcement,
                 restorationId: restorationId,
                 selectionHeightStyle: selectionHeightStyle,
                 selectionWidthStyle: selectionWidthStyle,
                 decoration: decoration,
                 enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
                 stylusHandwritingEnabled: stylusHandwritingEnabled,
                 textDirection: textDirection,
                 selectionControls: selectionControls,
                 contextMenuBuilder: contextMenuBuilder,
                 magnifierConfiguration: magnifierConfiguration,
                 spellCheckConfiguration: spellCheckConfiguration,
               ),
             ),
           );
         },
       );

  @override
  FormFieldState<String> createState() => TextFormBoxState();
}

class TextFormBoxState extends FormFieldState<String> {
  TextEditingController? _controller;

  TextEditingController? get _effectiveController =>
      widget.controller ?? _controller;

  @override
  ControllableFormBox get widget => super.widget as ControllableFormBox;

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
  void didUpdateWidget(ControllableFormBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);

      if (oldWidget.controller != null && widget.controller == null) {
        _controller = TextEditingController.fromValue(
          oldWidget.controller!.value,
        );
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
