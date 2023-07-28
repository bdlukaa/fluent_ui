import 'dart:ui' as ui;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

// From https://github.com/microsoft/microsoft-ui-xaml/blob/main/dev/CommonStyles/Common_themeresources.xaml#L18
const kTextBoxPadding = EdgeInsetsDirectional.fromSTEB(10, 5, 6, 6);

/// Visibility of text field overlays based on the state of the current text entry.
///
/// Used to toggle the visibility behavior of the optional decorating widgets
/// surrounding the [EditableText] such as the prefix widget.
enum OverlayVisibilityMode {
  /// Overlay will never appear regardless of the text entry state.
  never,

  /// Overlay will only appear when the current text entry is not empty.
  ///
  /// This includes prefilled text that the user did not type in manually. But
  /// does not include text in placeholders.
  editing,

  /// Overlay will only appear when the current text entry is empty.
  ///
  /// This also includes not having prefilled text that the user did not type
  /// in manually. Texts in placeholders are ignored.
  notEditing,

  /// Always show the overlay regardless of the text entry state.
  always,
}

class _TextBoxSelectionGestureDetectorBuilder
    extends TextSelectionGestureDetectorBuilder {
  _TextBoxSelectionGestureDetectorBuilder({
    required _TextBoxState super.delegate,
  }) : _state = delegate;

  final _TextBoxState _state;

  @override
  void onSingleTapUp(TapDragUpDetails details) {
    super.onSingleTapUp(details);
    _state._requestKeyboard();
    _state.widget.onTap?.call();
  }

  @override
  void onDragSelectionEnd(TapDragEndDetails details) {
    _state._requestKeyboard();
  }
}

/// A fluent-style text field.
///
/// A text field lets the user enter text, either with a hardware keyboard or with
/// an onscreen keyboard.
///
/// This widget corresponds to `TextBox` on Windows.
///
/// The text field calls the [onChanged] callback whenever the user changes the
/// text in the field. If the user indicates that they are done typing in the
/// field (e.g., by pressing a button on the soft keyboard), the text field
/// calls the [onSubmitted] callback.
///
/// {@macro flutter.widgets.EditableText.onChanged}
///
/// The [controller] can also control the selection and composing region (and to
/// observe changes to the text, selection, and composing region).
///
/// The text field has an overridable [decoration] that, by default, draws a
/// rounded rectangle border around the text field. If you set the [decoration]
/// property to null, the decoration will be removed entirely.
///
/// {@macro flutter.material.textfield.wantKeepAlive}
///
/// Remember to call [TextEditingController.dispose] when it is no longer
/// needed. This will ensure we discard any resources used by the object.
///
/// {@macro flutter.widgets.editableText.showCaretOnScreen}
///
/// {@macro flutter.widgets.editableText.accessibility}
///
/// See also:
///
///  * [EditableText], which is the raw text editing control at the heart of a
///    text field.
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/text-box>
class TextBox extends StatefulWidget {
  /// Creates a fluent-style text field.
  ///
  /// To provide a prefilled text entry, pass in a [TextEditingController] with
  /// an initial value to the [controller] parameter.
  ///
  /// To provide a hint placeholder text that appears when the text entry is
  /// empty, pass a [String] to the [placeholder] parameter.
  ///
  /// The [maxLines] property can be set to null to remove the restriction on
  /// the number of lines. In this mode, the intrinsic height of the widget will
  /// grow as the number of lines of text grows. By default, it is `1`, meaning
  /// this is a single-line text field and will scroll horizontally when
  /// it overflows. [maxLines] must not be zero.
  ///
  /// The text cursor is not shown if [showCursor] is false or if [showCursor]
  /// is null (the default) and [readOnly] is true.
  ///
  /// If specified, the [maxLength] property must be greater than zero.
  ///
  /// The [selectionHeightStyle] and [selectionWidthStyle] properties allow
  /// changing the shape of the selection highlighting. These properties default
  /// to [ui.BoxHeightStyle.tight] and [ui.BoxWidthStyle.tight] respectively and
  /// must not be null.
  ///
  /// The [autocorrect], [autofocus], [dragStartBehavior],
  /// [expands], [obscureText], [prefixMode], [readOnly], [scrollPadding],
  /// [suffixMode], [textAlign], [selectionHeightStyle], [selectionWidthStyle],
  /// [enableSuggestions], and [enableIMEPersonalizedLearning] properties must
  /// not be null.
  ///
  /// {@macro flutter.widgets.editableText.accessibility}
  ///
  /// See also:
  ///
  ///  * [minLines], which is the minimum number of lines to occupy when the
  ///    content spans fewer lines.
  ///  * [expands], to allow the widget to size itself to its parent's height.
  ///  * [maxLength], which discusses the precise meaning of "number of
  ///    characters" and how it may differ from the intuitive meaning.
  const TextBox({
    super.key,
    this.controller,
    this.focusNode,
    this.decoration,
    this.foregroundDecoration,
    this.highlightColor,
    this.unfocusedColor,
    this.padding = kTextBoxPadding,
    this.placeholder,
    this.placeholderStyle,
    this.prefix,
    this.prefixMode = OverlayVisibilityMode.always,
    this.suffix,
    this.suffixMode = OverlayVisibilityMode.always,
    TextInputType? keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly = false,
    this.showCursor,
    this.autofocus = false,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = true,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.maxLengthEnforcement,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onTapOutside,
    this.inputFormatters,
    this.enabled,
    this.cursorWidth = 1,
    this.cursorHeight,
    this.cursorRadius = const Radius.circular(2.0),
    this.cursorColor,
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.dragStartBehavior = DragStartBehavior.start,
    bool? enableInteractiveSelection,
    this.selectionControls,
    this.onTap,
    this.scrollController,
    this.scrollPhysics,
    this.autofillHints = const <String>[],
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    this.scribbleEnabled = true,
    this.enableIMEPersonalizedLearning = true,
    this.contextMenuBuilder = _defaultContextMenuBuilder,
    this.spellCheckConfiguration,
    this.magnifierConfiguration,
  })  : assert(obscuringCharacter.length == 1),
        smartDashesType = smartDashesType ??
            (obscureText ? SmartDashesType.disabled : SmartDashesType.enabled),
        smartQuotesType = smartQuotesType ??
            (obscureText ? SmartQuotesType.disabled : SmartQuotesType.enabled),
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
        // Assert the following instead of setting it directly to avoid surprising the user by silently changing the value they set.
        assert(
          !identical(textInputAction, TextInputAction.newline) ||
              maxLines == 1 ||
              !identical(keyboardType, TextInputType.text),
          'Use keyboardType TextInputType.multiline when using TextInputAction.newline on a multiline TextField.',
        ),
        keyboardType = keyboardType ??
            (maxLines == 1 ? TextInputType.text : TextInputType.multiline),
        enableInteractiveSelection =
            enableInteractiveSelection ?? (!readOnly || !obscureText);

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController].
  final TextEditingController? controller;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// Controls the [BoxDecoration] of the box behind the text input.
  ///
  /// Defaults to having a rounded rectangle grey border and can be null to have
  /// no box decoration.
  final BoxDecoration? decoration;

  /// Controls the [BoxDecoration] of the box in front of the text input.
  ///
  /// If [highlightColor] is provided, this must not be provided
  final BoxDecoration? foregroundDecoration;

  /// The highlight color of the text box.
  ///
  /// If [foregroundDecoration] is provided, this must not be provided.
  ///
  /// See also:
  ///  * [unfocusedColor], displayed when the field is not focused
  final Color? highlightColor;

  /// The unfocused color of the highlight border.
  ///
  /// See also:
  ///   * [highlightColor], displayed when the field is focused
  final Color? unfocusedColor;

  /// Padding around the text entry area between the [prefix] and [suffix].
  ///
  /// Defaults to [kTextBoxPadding]
  final EdgeInsetsGeometry padding;

  /// A lighter colored placeholder hint that appears on the first line of the
  /// text field when the text entry is empty.
  ///
  /// Defaults to having no placeholder text.
  ///
  /// The text style of the placeholder text matches that of the text field's
  /// main text entry except a lighter font weight and a grey font color.
  final String? placeholder;

  /// The style to use for the placeholder text.
  ///
  /// The [placeholderStyle] is merged with the [style] [TextStyle] when applied
  /// to the [placeholder] text. To avoid merging with [style], specify
  /// [TextStyle.inherit] as false.
  ///
  /// Defaults to the [style] property with w300 font weight and grey color.
  ///
  /// If specifically set to null, placeholder's style will be the same as [style].
  final TextStyle? placeholderStyle;

  /// An optional [Widget] to display before the text.
  final Widget? prefix;

  /// Controls the visibility of the [prefix] widget based on the state of
  /// text entry when the [prefix] argument is not null.
  ///
  /// Defaults to [OverlayVisibilityMode.always] and cannot be null.
  ///
  /// Has no effect when [prefix] is null.
  final OverlayVisibilityMode prefixMode;

  /// An optional [Widget] to display after the text.
  final Widget? suffix;

  /// Controls the visibility of the [suffix] widget based on the state of
  /// text entry when the [suffix] argument is not null.
  ///
  /// Defaults to [OverlayVisibilityMode.always] and cannot be null.
  ///
  /// Has no effect when [suffix] is null.
  final OverlayVisibilityMode suffixMode;

  /// {@macro flutter.widgets.editableText.keyboardType}
  final TextInputType keyboardType;

  /// The type of action button to use for the keyboard.
  ///
  /// Defaults to [TextInputAction.newline] if [keyboardType] is
  /// [TextInputType.multiline] and [TextInputAction.done] otherwise.
  final TextInputAction? textInputAction;

  /// {@macro flutter.widgets.editableText.textCapitalization}
  final TextCapitalization textCapitalization;

  /// The style to use for the text being edited.
  ///
  /// Also serves as a base for the [placeholder] text's style.
  ///
  /// Defaults to the standard font style from [FluentTheme] if null.
  final TextStyle? style;

  /// {@macro flutter.widgets.editableText.strutStyle}
  final StrutStyle? strutStyle;

  /// {@macro flutter.widgets.editableText.textAlign}
  final TextAlign textAlign;

  /// {@macro flutter.material.InputDecorator.textAlignVertical}
  final TextAlignVertical? textAlignVertical;

  /// {@macro flutter.widgets.editableText.textDirection}
  final TextDirection? textDirection;

  /// {@macro flutter.widgets.editableText.readOnly}
  final bool readOnly;

  /// {@macro flutter.widgets.editableText.showCursor}
  final bool? showCursor;

  /// {@macro flutter.widgets.editableText.autofocus}
  final bool autofocus;

  /// {@macro flutter.widgets.editableText.obscuringCharacter}
  final String obscuringCharacter;

  /// {@macro flutter.widgets.editableText.obscureText}
  final bool obscureText;

  /// {@macro flutter.widgets.editableText.autocorrect}
  final bool autocorrect;

  /// {@macro flutter.services.TextInputConfiguration.smartDashesType}
  final SmartDashesType smartDashesType;

  /// {@macro flutter.services.TextInputConfiguration.smartQuotesType}
  final SmartQuotesType smartQuotesType;

  /// {@macro flutter.services.TextInputConfiguration.enableSuggestions}
  final bool enableSuggestions;

  /// {@macro flutter.widgets.editableText.maxLines}
  ///  * [expands], which determines whether the field should fill the height of
  ///    its parent.
  final int? maxLines;

  /// {@macro flutter.widgets.editableText.minLines}
  ///  * [expands], which determines whether the field should fill the height of
  ///    its parent.
  final int? minLines;

  /// {@macro flutter.widgets.editableText.expands}
  final bool expands;

  /// The maximum number of characters (Unicode grapheme clusters) to allow in
  /// the text field.
  ///
  /// After [maxLength] characters have been input, additional input
  /// is ignored, unless [maxLengthEnforcement] is set to
  /// [MaxLengthEnforcement.none].
  ///
  /// The TextField enforces the length with a
  /// [LengthLimitingTextInputFormatter], which is evaluated after the supplied
  /// [inputFormatters], if any.
  ///
  /// This value must be either null or greater than zero. If set to null
  /// (the default), there is no limit to the number of characters allowed.
  ///
  /// Whitespace characters (e.g. newline, space, tab) are included in the
  /// character count.
  ///
  /// {@macro flutter.services.lengthLimitingTextInputFormatter.maxLength}
  final int? maxLength;

  /// Determines how the [maxLength] limit should be enforced.
  ///
  /// If [MaxLengthEnforcement.none] is set, additional input beyond [maxLength]
  /// will not be enforced by the limit.
  ///
  /// {@macro flutter.services.textFormatter.effectiveMaxLengthEnforcement}
  ///
  /// {@macro flutter.services.textFormatter.maxLengthEnforcement}
  final MaxLengthEnforcement? maxLengthEnforcement;

  /// {@macro flutter.widgets.editableText.onChanged}
  final ValueChanged<String>? onChanged;

  /// {@macro flutter.widgets.editableText.onEditingComplete}
  final VoidCallback? onEditingComplete;

  /// {@macro flutter.widgets.editableText.onSubmitted}
  ///
  /// See also:
  ///
  ///  * [TextInputAction.next] and [TextInputAction.previous], which
  ///    automatically shift the focus to the next/previous focusable item when
  ///    the user is done editing.
  final ValueChanged<String>? onSubmitted;

  /// {@macro flutter.widgets.editableText.onTapOutside}
  final TapRegionCallback? onTapOutside;

  /// {@macro flutter.widgets.editableText.inputFormatters}
  final List<TextInputFormatter>? inputFormatters;

  /// Disables the text field when false.
  ///
  /// Text fields in disabled states have a light grey background and don't
  /// respond to touch events including the [prefix], [suffix].
  final bool? enabled;

  /// {@macro flutter.widgets.editableText.cursorWidth}
  final double cursorWidth;

  /// {@macro flutter.widgets.editableText.cursorHeight}
  final double? cursorHeight;

  /// {@macro flutter.widgets.editableText.cursorRadius}
  final Radius cursorRadius;

  /// The color to use when painting the cursor.
  ///
  /// Defaults to the [DefaultSelectionStyle.cursorColor]. If that color is
  /// null, it uses the [FluentThemeData.inactiveColor] of the ambient theme.
  final Color? cursorColor;

  /// Controls how tall the selection highlight boxes are computed to be.
  ///
  /// See [ui.BoxHeightStyle] for details on available styles.
  final ui.BoxHeightStyle selectionHeightStyle;

  /// Controls how wide the selection highlight boxes are computed to be.
  ///
  /// See [ui.BoxWidthStyle] for details on available styles.
  final ui.BoxWidthStyle selectionWidthStyle;

  /// The appearance of the keyboard.
  ///
  /// This setting is only honored on iOS devices.
  ///
  /// If null, defaults to the brightness of [FluentThemeData.brightness].
  final Brightness? keyboardAppearance;

  /// {@macro flutter.widgets.editableText.scrollPadding}
  final EdgeInsets scrollPadding;

  /// {@macro flutter.widgets.editableText.enableInteractiveSelection}
  final bool enableInteractiveSelection;

  /// {@macro flutter.widgets.editableText.selectionControls}
  final TextSelectionControls? selectionControls;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// {@macro flutter.widgets.editableText.scrollController}
  final ScrollController? scrollController;

  /// {@macro flutter.widgets.editableText.scrollPhysics}
  final ScrollPhysics? scrollPhysics;

  /// {@macro flutter.widgets.editableText.selectionEnabled}
  bool get selectionEnabled => enableInteractiveSelection;

  /// {@macro flutter.material.textfield.onTap}
  final GestureTapCallback? onTap;

  /// {@macro flutter.widgets.editableText.autofillHints}
  /// {@macro flutter.services.AutofillConfiguration.autofillHints}
  final Iterable<String>? autofillHints;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  /// {@macro flutter.material.textfield.restorationId}
  final String? restorationId;

  /// {@macro flutter.widgets.editableText.scribbleEnabled}
  final bool scribbleEnabled;

  /// {@macro flutter.services.TextInputConfiguration.enableIMEPersonalizedLearning}
  final bool enableIMEPersonalizedLearning;

  /// {@macro flutter.widgets.EditableText.contextMenuBuilder}
  ///
  /// If not provided, will build a default menu based on the platform.
  ///
  /// See also:
  ///
  ///  * [AdaptiveTextSelectionToolbar], which is built by default.
  final EditableTextContextMenuBuilder? contextMenuBuilder;

  static Widget _defaultContextMenuBuilder(
      BuildContext context, EditableTextState editableTextState) {
    return AdaptiveTextSelectionToolbar.editableText(
      editableTextState: editableTextState,
    );
  }

  /// {@macro flutter.widgets.magnifier.TextMagnifierConfiguration.intro}
  ///
  /// {@macro flutter.widgets.magnifier.intro}
  ///
  /// {@macro flutter.widgets.magnifier.TextMagnifierConfiguration.details}
  ///
  /// By default, builds an [TextMagnifier.adaptiveMagnifierConfiguration].
  /// If it is desired to suppress the magnifier, consider passing
  /// [TextMagnifierConfiguration.disabled].
  ///
  /// {@tool dartpad}
  /// This sample demonstrates how to customize the magnifier that this text field uses.
  ///
  /// ** See code in examples/api/lib/widgets/text_magnifier/text_magnifier.0.dart **
  /// {@end-tool}
  final TextMagnifierConfiguration? magnifierConfiguration;

  /// {@macro flutter.widgets.EditableText.spellCheckConfiguration}
  ///
  /// If [SpellCheckConfiguration.misspelledTextStyle] is not specified in this
  /// configuration, then [fluentMisspelledTextStyle] is used by default.
  final SpellCheckConfiguration? spellCheckConfiguration;

  /// The [TextStyle] used to indicate misspelled words in the Fluent style.
  ///
  /// See also:
  ///  * [SpellCheckConfiguration.misspelledTextStyle], the style configured to
  ///    mark misspelled words with.
  static final TextStyle fluentMisspelledTextStyle = TextStyle(
    decoration: TextDecoration.underline,
    decorationColor: Colors.red,
    decorationStyle: TextDecorationStyle.dotted,
  );

  @override
  State<TextBox> createState() => _TextBoxState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<TextEditingController>('controller', controller,
          defaultValue: null))
      ..add(DiagnosticsProperty<FocusNode>('focusNode', focusNode,
          defaultValue: null))
      ..add(DiagnosticsProperty<BoxDecoration>('decoration', decoration))
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>(
        'padding',
        padding,
        defaultValue: kTextBoxPadding,
      ))
      ..add(StringProperty('placeholder', placeholder))
      ..add(
          DiagnosticsProperty<TextStyle>('placeholderStyle', placeholderStyle))
      ..add(DiagnosticsProperty<OverlayVisibilityMode>(
          'prefix', prefix == null ? null : prefixMode))
      ..add(DiagnosticsProperty<OverlayVisibilityMode>(
          'suffix', suffix == null ? null : suffixMode))
      ..add(DiagnosticsProperty<TextInputType>('keyboardType', keyboardType,
          defaultValue: TextInputType.text))
      ..add(DiagnosticsProperty<TextStyle>('style', style, defaultValue: null))
      ..add(DiagnosticsProperty<bool>('autofocus', autofocus,
          defaultValue: false))
      ..add(DiagnosticsProperty<String>(
          'obscuringCharacter', obscuringCharacter,
          defaultValue: '•'))
      ..add(DiagnosticsProperty<bool>('obscureText', obscureText,
          defaultValue: false))
      ..add(DiagnosticsProperty<bool>('autocorrect', autocorrect,
          defaultValue: true))
      ..add(EnumProperty<SmartDashesType>('smartDashesType', smartDashesType,
          defaultValue:
              obscureText ? SmartDashesType.disabled : SmartDashesType.enabled))
      ..add(EnumProperty<SmartQuotesType>('smartQuotesType', smartQuotesType,
          defaultValue:
              obscureText ? SmartQuotesType.disabled : SmartQuotesType.enabled))
      ..add(DiagnosticsProperty<bool>('enableSuggestions', enableSuggestions,
          defaultValue: true))
      ..add(IntProperty('maxLines', maxLines, defaultValue: 1))
      ..add(IntProperty('minLines', minLines, defaultValue: null))
      ..add(DiagnosticsProperty<bool>('expands', expands, defaultValue: false))
      ..add(IntProperty('maxLength', maxLength, defaultValue: null))
      ..add(EnumProperty<MaxLengthEnforcement>(
          'maxLengthEnforcement', maxLengthEnforcement,
          defaultValue: null))
      ..add(DoubleProperty('cursorWidth', cursorWidth, defaultValue: 1.0))
      ..add(DoubleProperty('cursorHeight', cursorHeight, defaultValue: null))
      ..add(DiagnosticsProperty<Radius>('cursorRadius', cursorRadius,
          defaultValue: null))
      ..add(ColorProperty('cursorColor', cursorColor, defaultValue: null))
      ..add(FlagProperty('selectionEnabled',
          value: selectionEnabled,
          defaultValue: true,
          ifFalse: 'selection disabled'))
      ..add(DiagnosticsProperty<TextSelectionControls>(
          'selectionControls', selectionControls,
          defaultValue: null))
      ..add(DiagnosticsProperty<ScrollController>(
          'scrollController', scrollController,
          defaultValue: null))
      ..add(DiagnosticsProperty<ScrollPhysics>('scrollPhysics', scrollPhysics,
          defaultValue: null))
      ..add(EnumProperty<TextAlign>('textAlign', textAlign,
          defaultValue: TextAlign.start))
      ..add(DiagnosticsProperty<TextAlignVertical>(
          'textAlignVertical', textAlignVertical,
          defaultValue: null))
      ..add(EnumProperty<TextDirection>('textDirection', textDirection,
          defaultValue: null))
      ..add(DiagnosticsProperty<Clip>('clipBehavior', clipBehavior,
          defaultValue: Clip.hardEdge))
      ..add(DiagnosticsProperty<bool>('scribbleEnabled', scribbleEnabled,
          defaultValue: true))
      ..add(DiagnosticsProperty<bool>(
          'enableIMEPersonalizedLearning', enableIMEPersonalizedLearning,
          defaultValue: true))
      ..add(DiagnosticsProperty<SpellCheckConfiguration>(
          'spellCheckConfiguration', spellCheckConfiguration,
          defaultValue: null));
  }

  static final TextMagnifierConfiguration _fluentMagnifierConfiguration =
      TextMagnifier.adaptiveMagnifierConfiguration;
}

class _TextBoxState extends State<TextBox>
    with RestorationMixin, AutomaticKeepAliveClientMixin<TextBox>
    implements TextSelectionGestureDetectorBuilderDelegate, AutofillClient {
  RestorableTextEditingController? _controller;
  TextEditingController get _effectiveController =>
      widget.controller ?? _controller!.value;

  FocusNode? _focusNode;
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_focusNode ??= FocusNode());

  MaxLengthEnforcement get _effectiveMaxLengthEnforcement =>
      widget.maxLengthEnforcement ??
      LengthLimitingTextInputFormatter.getDefaultMaxLengthEnforcement();

  bool _showSelectionHandles = false;

  late _TextBoxSelectionGestureDetectorBuilder _selectionGestureDetectorBuilder;

  // API for TextSelectionGestureDetectorBuilderDelegate.
  @override
  bool get forcePressEnabled => true;

  @override
  final GlobalKey<EditableTextState> editableTextKey =
      GlobalKey<EditableTextState>();

  @override
  bool get selectionEnabled => widget.selectionEnabled;
  // End of API for TextSelectionGestureDetectorBuilderDelegate.

  @override
  void initState() {
    super.initState();
    _selectionGestureDetectorBuilder = _TextBoxSelectionGestureDetectorBuilder(
      delegate: this,
    );
    if (widget.controller == null) {
      _createLocalController();
    }
    _effectiveFocusNode
      ..canRequestFocus = widget.enabled ?? true
      ..addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(TextBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && oldWidget.controller != null) {
      _createLocalController(oldWidget.controller!.value);
    } else if (widget.controller != null && oldWidget.controller == null) {
      unregisterFromRestoration(_controller!);
      _controller!.dispose();
      _controller = null;
    }

    if (widget.focusNode != oldWidget.focusNode) {
      (oldWidget.focusNode ?? _focusNode)?.removeListener(_handleFocusChanged);
      (widget.focusNode ?? _focusNode)?.addListener(_handleFocusChanged);
    }
    _effectiveFocusNode.canRequestFocus = widget.enabled ?? true;
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    if (_controller != null) {
      _registerController();
    }
  }

  void _registerController() {
    assert(_controller != null);
    registerForRestoration(_controller!, 'controller');
    _controller!.value.addListener(updateKeepAlive);
  }

  void _createLocalController([TextEditingValue? value]) {
    assert(_controller == null);
    _controller = value == null
        ? RestorableTextEditingController()
        : RestorableTextEditingController.fromValue(value);
    if (!restorePending) {
      _registerController();
    }
  }

  @override
  String? get restorationId => widget.restorationId;

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_handleFocusChanged);
    _focusNode?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  EditableTextState get _editableText => editableTextKey.currentState!;

  void _requestKeyboard() {
    _editableText.requestKeyboard();
  }

  void _handleFocusChanged() {
    setState(() {
      // Rebuild the widget on focus change to show/hide the text selection
      // highlight.
    });
  }

  bool _shouldShowSelectionHandles(SelectionChangedCause? cause) {
    // When the text field is activated by something that doesn't trigger the
    // selection overlay, we shouldn't show the handles either.
    if (!_selectionGestureDetectorBuilder.shouldShowSelectionToolbar) {
      return false;
    }

    if (_effectiveController.selection.isCollapsed) {
      return false;
    }

    if (cause == SelectionChangedCause.keyboard) {
      return false;
    }

    if (cause == SelectionChangedCause.scribble) {
      return true;
    }

    if (_effectiveController.text.isNotEmpty) {
      return true;
    }

    return false;
  }

  void _handleSelectionChanged(
      TextSelection selection, SelectionChangedCause? cause) {
    final willShowSelectionHandles = _shouldShowSelectionHandles(cause);
    if (willShowSelectionHandles != _showSelectionHandles) {
      setState(() {
        _showSelectionHandles = willShowSelectionHandles;
      });
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      case TargetPlatform.fuchsia:
      case TargetPlatform.android:
        if (cause == SelectionChangedCause.longPress ||
            cause == SelectionChangedCause.drag) {
          _editableText.bringIntoView(selection.extent);
        }
        break;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
      case TargetPlatform.android:
        break;
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        if (cause == SelectionChangedCause.drag) {
          _editableText.hideToolbar();
        }
        break;
    }
  }

  @override
  bool get wantKeepAlive => _controller?.value.text.isNotEmpty ?? false;

  bool _shouldShowAttachment({
    required OverlayVisibilityMode attachment,
    required bool hasText,
  }) {
    switch (attachment) {
      case OverlayVisibilityMode.never:
        return false;
      case OverlayVisibilityMode.always:
        return true;
      case OverlayVisibilityMode.editing:
        return hasText;
      case OverlayVisibilityMode.notEditing:
        return !hasText;
    }
  }

  bool _showPrefixWidget(TextEditingValue text) {
    return widget.prefix != null &&
        _shouldShowAttachment(
          attachment: widget.prefixMode,
          hasText: text.text.isNotEmpty,
        );
  }

  bool _showSuffixWidget(TextEditingValue text) {
    return widget.suffix != null &&
        _shouldShowAttachment(
          attachment: widget.suffixMode,
          hasText: text.text.isNotEmpty,
        );
  }

  // True if any surrounding decoration widgets will be shown.
  bool get _hasDecoration {
    return widget.placeholder != null ||
        widget.prefix != null ||
        widget.suffix != null;
  }

  // Provide default behavior if widget.textAlignVertical is not set.
  // TextBox has top alignment by default, unless it has decoration
  // like a prefix or suffix, in which case it's aligned to the center.
  TextAlignVertical get _textAlignVertical {
    if (widget.textAlignVertical != null) {
      return widget.textAlignVertical!;
    }
    return _hasDecoration ? TextAlignVertical.center : TextAlignVertical.top;
  }

  Widget _addTextDependentAttachments(
      Widget editableText, TextStyle textStyle, TextStyle? placeholderStyle) {
    // If there are no surrounding widgets, just return the core editable text
    // part.
    if (!_hasDecoration) {
      return editableText;
    }

    // Otherwise, listen to the current state of the text entry.
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _effectiveController,
      child: editableText,
      builder: (BuildContext context, TextEditingValue? text, Widget? child) {
        return Row(children: <Widget>[
          // Insert a prefix at the front if the prefix visibility mode matches
          // the current text state.
          if (_showPrefixWidget(text!)) widget.prefix!,
          // In the middle part, stack the placeholder on top of the main EditableText
          // if needed.
          Expanded(
            child: Stack(
              children: <Widget>[
                if (widget.placeholder != null && text.text.isEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: widget.padding,
                      child: Text(
                        widget.placeholder!,
                        maxLines: widget.maxLines,
                        overflow:
                            placeholderStyle?.overflow ?? TextOverflow.ellipsis,
                        style: placeholderStyle,
                        textAlign: widget.textAlign,
                      ),
                    ),
                  ),
                child!,
              ],
            ),
          ),
          // First add the explicit suffix if the suffix visibility mode matches.
          if (_showSuffixWidget(text)) ...[
            widget.suffix!,
            const SizedBox(width: 4.0),
          ]
        ]);
      },
    );
  }

  // AutofillClient implementation start.
  @override
  String get autofillId => _editableText.autofillId;

  @override
  void autofill(TextEditingValue newEditingValue) =>
      _editableText.autofill(newEditingValue);

  @override
  TextInputConfiguration get textInputConfiguration {
    final autofillHints = widget.autofillHints?.toList(growable: false);
    final autofillConfiguration = autofillHints != null
        ? AutofillConfiguration(
            uniqueIdentifier: autofillId,
            autofillHints: autofillHints,
            currentEditingValue: _effectiveController.value,
            hintText: widget.placeholder,
          )
        : AutofillConfiguration.disabled;

    return _editableText.textInputConfiguration
        .copyWith(autofillConfiguration: autofillConfiguration);
  }
  // AutofillClient implementation end.

  @override
  Widget build(BuildContext context) {
    super.build(context); // See AutomaticKeepAliveClientMixin.
    assert(debugCheckHasDirectionality(context));
    assert(debugCheckHasFluentTheme(context));
    final controller = _effectiveController;

    var textSelectionControls = widget.selectionControls;
    VoidCallback? handleDidGainAccessibilityFocus;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
        textSelectionControls ??= fluentTextSelectionControls;
        break;

      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        textSelectionControls ??= fluentTextSelectionControls;
        handleDidGainAccessibilityFocus = () {
          // Automatically activate the TextField when it receives accessibility focus.
          if (!_effectiveFocusNode.hasFocus &&
              _effectiveFocusNode.canRequestFocus) {
            _effectiveFocusNode.requestFocus();
          }
        };
        break;
    }

    final enabled = widget.enabled ?? true;
    const cursorOffset = Offset(0, 0);
    final formatters = <TextInputFormatter>[
      ...?widget.inputFormatters,
      if (widget.maxLength != null)
        LengthLimitingTextInputFormatter(
          widget.maxLength,
          maxLengthEnforcement: _effectiveMaxLengthEnforcement,
        ),
    ];
    final themeData = FluentTheme.of(context);

    final disabledColor = themeData.resources.textFillColorDisabled;
    final textStyle = (themeData.typography.body ?? const TextStyle())
        .merge(TextStyle(
          color: enabled
              ? themeData.resources.textFillColorPrimary
              : disabledColor,
        ))
        .merge(widget.style);

    final keyboardAppearance =
        widget.keyboardAppearance ?? themeData.brightness;
    final cursorColor = widget.cursorColor ??
        DefaultSelectionStyle.of(context).cursorColor ??
        themeData.inactiveColor;

    final selectionColor = DefaultSelectionStyle.of(context).selectionColor ??
        themeData.accentColor.normal;

    // Set configuration as disabled if not otherwise specified. If specified,
    // ensure that configuration uses Fluent text style for misspelled words
    // unless a custom style is specified.
    final spellCheckConfiguration = widget.spellCheckConfiguration != null &&
            widget.spellCheckConfiguration !=
                const SpellCheckConfiguration.disabled()
        ? widget.spellCheckConfiguration!.copyWith(
            misspelledTextStyle:
                widget.spellCheckConfiguration!.misspelledTextStyle ??
                    TextBox.fluentMisspelledTextStyle)
        : const SpellCheckConfiguration.disabled();

    final Widget paddedEditable = Padding(
      padding: widget.padding,
      child: RepaintBoundary(
        child: UnmanagedRestorationScope(
          bucket: bucket,
          child: EditableText(
            key: editableTextKey,
            controller: controller,
            readOnly: widget.readOnly,
            showCursor: widget.showCursor,
            showSelectionHandles: _showSelectionHandles,
            focusNode: _effectiveFocusNode,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            textCapitalization: widget.textCapitalization,
            style: textStyle,
            strutStyle: widget.strutStyle,
            textAlign: widget.textAlign,
            textDirection: widget.textDirection,
            autofocus: widget.autofocus,
            obscuringCharacter: widget.obscuringCharacter,
            obscureText: widget.obscureText,
            autocorrect: widget.autocorrect,
            smartDashesType: widget.smartDashesType,
            smartQuotesType: widget.smartQuotesType,
            enableSuggestions: widget.enableSuggestions,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            expands: widget.expands,
            magnifierConfiguration: widget.magnifierConfiguration ??
                TextBox._fluentMagnifierConfiguration,
            // Only show the selection highlight when the text field is focused.
            selectionColor:
                _effectiveFocusNode.hasFocus ? selectionColor : null,
            selectionControls:
                widget.selectionEnabled ? textSelectionControls : null,
            onChanged: widget.onChanged,
            onSelectionChanged: _handleSelectionChanged,
            onEditingComplete: widget.onEditingComplete,
            onSubmitted: widget.onSubmitted,
            onTapOutside: widget.onTapOutside,
            inputFormatters: formatters,
            rendererIgnoresPointer: true,
            cursorWidth: widget.cursorWidth,
            cursorHeight: widget.cursorHeight,
            cursorRadius: widget.cursorRadius,
            cursorColor: cursorColor,
            cursorOpacityAnimates: true,
            cursorOffset: cursorOffset,
            paintCursorAboveText: true,
            autocorrectionTextRectColor: selectionColor,
            backgroundCursorColor: disabledColor,
            selectionHeightStyle: widget.selectionHeightStyle,
            selectionWidthStyle: widget.selectionWidthStyle,
            scrollPadding: widget.scrollPadding,
            keyboardAppearance: keyboardAppearance,
            dragStartBehavior: widget.dragStartBehavior,
            scrollController: widget.scrollController,
            scrollPhysics: widget.scrollPhysics,
            enableInteractiveSelection: widget.enableInteractiveSelection,
            autofillClient: this,
            clipBehavior: widget.clipBehavior,
            restorationId: 'editable',
            scribbleEnabled: widget.scribbleEnabled,
            enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
            contextMenuBuilder: widget.contextMenuBuilder,
            spellCheckConfiguration: spellCheckConfiguration,
          ),
        ),
      ),
    );

    Color backgroundColor(Set<ButtonStates> states) {
      final res = FluentTheme.of(context).resources;

      if (!enabled) {
        return res.controlFillColorDisabled;
      } else if (states.isPressing || states.isFocused) {
        return res.controlFillColorInputActive;
      } else if (states.isHovering) {
        return res.controlFillColorSecondary;
      } else {
        return res.controlFillColorDefault;
      }
    }

    TextStyle placeholderStyle(Set<ButtonStates> states) {
      return textStyle
          .copyWith(
            color: !enabled
                ? disabledColor
                : (states.isPressing || states.isFocused)
                    ? themeData.resources.textFillColorTertiary
                    : themeData.resources.textFillColorSecondary,
            fontWeight: FontWeight.w400,
          )
          .merge(widget.placeholderStyle);
    }

    final foregroundDecoration = BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: _effectiveFocusNode.hasFocus
              ? widget.highlightColor ??
                  themeData.accentColor.defaultBrushFor(
                    themeData.brightness,
                  )
              : !enabled
                  ? Colors.transparent
                  : widget.unfocusedColor ??
                      (themeData.brightness.isLight
                          ? const Color.fromRGBO(0, 0, 0, 0.45)
                          : const Color.fromRGBO(255, 255, 255, 0.54)),
          width: _effectiveFocusNode.hasFocus ? 2 : 0,
        ),
      ),
    ).copyWith(
      backgroundBlendMode: widget.foregroundDecoration?.backgroundBlendMode,
      border: widget.foregroundDecoration?.border,
      borderRadius: widget.foregroundDecoration?.borderRadius,
      boxShadow: widget.foregroundDecoration?.boxShadow,
      color: widget.foregroundDecoration?.color,
      gradient: widget.foregroundDecoration?.gradient,
      image: widget.foregroundDecoration?.image,
      shape: widget.foregroundDecoration?.shape,
    );

    final radius =
        widget.decoration?.borderRadius?.resolve(Directionality.of(context)) ??
            BorderRadius.circular(4.0);

    return Semantics(
      enabled: enabled,
      onTap: !enabled || widget.readOnly
          ? null
          : () {
              if (!controller.selection.isValid) {
                controller.selection =
                    TextSelection.collapsed(offset: controller.text.length);
              }
              _requestKeyboard();
            },
      onDidGainAccessibilityFocus: handleDidGainAccessibilityFocus,
      child: TextFieldTapRegion(
        child: IgnorePointer(
          ignoring: !enabled,
          child: ClipRRect(
            borderRadius: radius,
            clipBehavior: widget.clipBehavior,
            child: HoverButton(
              focusEnabled: false,
              forceEnabled: enabled,
              hitTestBehavior: HitTestBehavior.translucent,
              builder: (context, states) {
                // Since we manage focus outside of the HoverButton (see focusEnabled: false)
                // we need to add the focused state when the field is focused
                //
                // widgets below this can call `HoverButton.of(context).states.isFocused`
                // and have the correct value
                if (_effectiveFocusNode.hasFocus) {
                  states = {...states, ButtonStates.focused};
                }

                return DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    border: Border.all(
                      color: themeData.resources.controlStrokeColorDefault,
                    ),
                    color: backgroundColor(states),
                  ).copyWith(
                    backgroundBlendMode: widget.decoration?.backgroundBlendMode,
                    border: widget.decoration?.border,

                    /// This border radius can't be applied, otherwise the error "A borderRadius
                    /// can only be given for a uniform Border." will be thrown. Instead,
                    /// [radius] is already set to get the value from [widget.decoration?.borderRadius],
                    /// if any.
                    // borderRadius: widget.decoration?.borderRadius,
                    boxShadow: widget.decoration?.boxShadow,
                    color: widget.decoration?.color,
                    gradient: widget.decoration?.gradient,
                    image: widget.decoration?.image,
                    shape: widget.decoration?.shape,
                  ),
                  child: Container(
                    foregroundDecoration: foregroundDecoration,
                    constraints: const BoxConstraints(
                      minHeight: 32.0,
                    ),
                    child:
                        _selectionGestureDetectorBuilder.buildGestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: Align(
                        alignment: Alignment(-1.0, _textAlignVertical.y),
                        widthFactor: 1.0,
                        heightFactor: 1.0,
                        child: SmallIconButton(
                          child: _addTextDependentAttachments(
                            paddedEditable,
                            textStyle,
                            placeholderStyle(states),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
