import 'dart:ui' as ui;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluent_ui/src/controls/form/selection_controls.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter/services.dart';

import 'pickers/pickers.dart';

const kTextBoxPadding = EdgeInsets.symmetric(horizontal: 8.0, vertical: 5);

enum OverlayVisibilityMode {
  never,
  editing,
  notEditing,
  always,
}

class _TextBoxSelectionGestureDetectorBuilder
    extends TextSelectionGestureDetectorBuilder {
  _TextBoxSelectionGestureDetectorBuilder({
    required _TextBoxState state,
  })  : _state = state,
        super(delegate: state);

  final _TextBoxState _state;

  @override
  void onSingleTapUp(TapUpDetails details) {
    if (_state._clearGlobalKey.currentContext != null) {
      final RenderBox renderBox = _state._clearGlobalKey.currentContext!
          .findRenderObject() as RenderBox;
      final Offset localOffset =
          renderBox.globalToLocal(details.globalPosition);
      if (renderBox.hitTest(BoxHitTestResult(), position: localOffset)) {
        return;
      }
    }
    super.onSingleTapUp(details);
    _state._requestKeyboard();
    if (_state.widget.onTap != null) _state.widget.onTap!();
  }

  @override
  void onDragSelectionEnd(DragEndDetails details) {
    _state._requestKeyboard();
  }
}

/// The TextBox control lets a user type text into an app. It's typically used
/// to capture a single line of text, but can be configured to capture multiple
/// lines of text. The text displays on the screen in a simple, uniform,
/// plaintext format.
///
/// ![TextBox Preview](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/text-box-ex1.png)
///
/// See also:
///
///   * [AutoSuggestBox], it lets the user enter search terms or to show the
/// user a list of suggestions to choose from as they type.
class TextBox extends StatefulWidget {
  /// Creates a text box
  const TextBox({
    Key? key,
    this.controller,
    this.focusNode,
    this.padding = kTextBoxPadding,
    this.clipBehavior = Clip.antiAlias,
    this.placeholder,
    this.placeholderStyle,
    this.prefix,
    this.outsidePrefix,
    this.prefixMode = OverlayVisibilityMode.always,
    this.outsidePrefixMode = OverlayVisibilityMode.always,
    this.suffix,
    this.outsideSuffix,
    this.suffixMode = OverlayVisibilityMode.always,
    this.outsideSuffixMode = OverlayVisibilityMode.always,
    TextInputType? keyboardType,
    this.textInputAction,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.readOnly = false,
    ToolbarOptions? toolbarOptions,
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
    this.minHeight,
    this.expands = false,
    this.maxLength,
    this.maxLengthEnforcement,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.inputFormatters,
    this.enabled,
    this.cursorWidth = 1.5,
    this.cursorHeight,
    this.cursorRadius = const Radius.circular(2.0),
    this.cursorColor,
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.dragStartBehavior = DragStartBehavior.start,
    this.enableInteractiveSelection = true,
    this.onTap,
    this.scrollController,
    this.scrollPhysics,
    this.autofillHints,
    this.restorationId,
    this.textCapitalization = TextCapitalization.none,
    this.header,
    this.headerStyle,
    this.iconButtonThemeData,
    this.decoration,
    this.foregroundDecoration,
    this.highlightColor,
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
        assert(
          !identical(textInputAction, TextInputAction.newline) ||
              maxLines == 1 ||
              !identical(keyboardType, TextInputType.text),
          'Use keyboardType TextInputType.multiline when using TextInputAction.newline on a multiline TextField.',
        ),
        assert(
          (highlightColor == null && foregroundDecoration == null) ||
              (highlightColor == null && foregroundDecoration != null) ||
              (highlightColor != null && foregroundDecoration == null),
          'You can not provide both highlightColor and foregroundDecoration',
        ),
        keyboardType = keyboardType ??
            (maxLines == 1 ? TextInputType.text : TextInputType.multiline),
        toolbarOptions = toolbarOptions ??
            (obscureText
                ? const ToolbarOptions(
                    selectAll: true,
                    paste: true,
                  )
                : const ToolbarOptions(
                    copy: true,
                    cut: true,
                    selectAll: true,
                    paste: true,
                  )),
        super(key: key);

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController].
  final TextEditingController? controller;

  /// Defines the keyboard focus for this widget.
  ///
  /// The [focusNode] is a long-lived object that's typically managed by a
  /// [StatefulWidget] parent. See [FocusNode] for more information.
  ///
  /// To give the keyboard focus to this widget, provide a [focusNode] and then
  /// use the current [FocusScope] to request the focus:
  ///
  /// ```dart
  /// FocusScope.of(context).requestFocus(myFocusNode);
  /// ```
  ///
  /// This happens automatically when the widget is tapped.
  ///
  /// To be notified when the widget gains or loses the focus, add a listener
  /// to the [focusNode]:
  ///
  /// ```dart
  /// focusNode.addListener(() { print(myFocusNode.hasFocus); });
  /// ```
  ///
  /// If null, this widget will create its own [FocusNode].
  ///
  /// ## Keyboard
  ///
  /// Requesting the focus will typically cause the keyboard to be shown
  /// if it's not showing already.
  ///
  /// On Android, the user can hide the keyboard - without changing the focus -
  /// with the system back button. They can restore the keyboard's visibility
  /// by tapping on a text field.  The user might hide the keyboard and
  /// switch to a physical keyboard, or they might just need to get it
  /// out of the way for a moment, to expose something it's
  /// obscuring. In this case requesting the focus again will not
  /// cause the focus to change, and will not make the keyboard visible.
  ///
  /// This widget builds an [EditableText] and will ensure that the keyboard is
  /// showing when it is tapped by calling [EditableTextState.requestKeyboard()].
  final FocusNode? focusNode;

  /// Padding around the text entry area between the [prefix] and [suffix].
  ///
  /// Defaults to a padding of 6 pixels on the left and right and 8 pixels on
  /// top and bottom.
  final EdgeInsetsGeometry padding;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.antiAlias].
  final Clip clipBehavior;

  /// A placeholder hint that appears on the first line of the text box when the
  /// text entry is empty.
  ///
  /// Defaults to having no placeholder text.
  final String? placeholder;

  /// The style to use for the placeholder text.
  ///
  /// The [placeholderStyle] is merged with the [style] [TextStyle] when applied
  /// to the [placeholder] text. To avoid merging with [style], specify
  /// [TextStyle.inherit] as false.
  final TextStyle? placeholderStyle;

  /// The label above the text box
  ///
  /// ![TextBox with header](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/text-box-ex1.png)
  ///
  /// See also:
  ///
  ///   * [InfoLabel], which adds a text either above or by the side of its child
  final String? header;

  /// The style used by [header].
  final TextStyle? headerStyle;

  /// An optional [Widget] to display before the text box.
  final Widget? outsidePrefix;

  /// An optional [Widget] to display before the text.
  final Widget? prefix;

  /// Controls the visibility of the [prefix] widget based on the state of
  /// text entry when the [prefix] argument is not null.
  ///
  /// Defaults to [OverlayVisibilityMode.always] and cannot be null.
  ///
  /// Has no effect when [prefix] is null.
  final OverlayVisibilityMode prefixMode;

  /// Controls the visibility of the [outsidePrefix] widget based on the state of
  /// text entry when the [outsidePrefix] argument is not null.
  ///
  /// Defaults to [OverlayVisibilityMode.always] and cannot be null.
  ///
  /// Has no effect when [outsidePrefix] is null.
  final OverlayVisibilityMode outsidePrefixMode;

  /// An optional [Widget] to display after the text box.
  final Widget? outsideSuffix;

  /// An optional [Widget] to display after the text.
  final Widget? suffix;

  /// Controls the visibility of the [suffix] widget based on the state of
  /// text entry when the [suffix] argument is not null.
  ///
  /// Defaults to [OverlayVisibilityMode.always] and cannot be null.
  ///
  /// Has no effect when [suffix] is null.
  final OverlayVisibilityMode suffixMode;

  /// Controls the visibility of the [outsideSuffix] widget based on the state of
  /// text entry when the [outsideSuffix] argument is not null.
  ///
  /// Defaults to [OverlayVisibilityMode.always] and cannot be null.
  ///
  /// Has no effect when [outsideSuffix] is null.
  final OverlayVisibilityMode outsideSuffixMode;

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
  final TextStyle? style;

  /// Controls the [BoxDecoration] of the box behind the text input.
  final BoxDecoration? decoration;

  /// Controls the [BoxDecoration] of the box in front of the text input.
  ///
  /// If [highlightColor] is provided, this must not be provided
  final BoxDecoration? foregroundDecoration;

  /// The highlight color of the text box.
  ///
  /// If [foregroundDecoration] is provided, this must not be provided.
  final Color? highlightColor;

  /// {@macro flutter.widgets.editableText.strutStyle}
  final StrutStyle? strutStyle;

  /// {@macro flutter.widgets.editableText.textAlign}
  final TextAlign textAlign;

  /// Configuration of toolbar options.
  ///
  /// If not set, select all and paste will default to be enabled. Copy and cut
  /// will be disabled if [obscureText] is true. If [readOnly] is true,
  /// paste and cut will be disabled regardless.
  final ToolbarOptions toolbarOptions;

  /// {@macro flutter.material.InputDecorator.textAlignVertical}
  final TextAlignVertical? textAlignVertical;

  /// {@macro flutter.widgets.editableText.readOnly}
  final bool readOnly;

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

  final double? minHeight;

  /// {@macro flutter.widgets.editableText.expands}
  final bool expands;

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
  ///
  /// See also:
  ///
  ///  * [inputFormatters], which are called before [onChanged]
  ///    runs and can validate and change ("format") the input value.
  ///  * [onEditingComplete], [onSubmitted]:
  ///    which are more specialized input change notifications.
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

  /// {@macro flutter.widgets.editableText.inputFormatters}
  final List<TextInputFormatter>? inputFormatters;

  final bool? enabled;

  /// {@macro flutter.widgets.editableText.cursorWidth}
  final double cursorWidth;

  /// {@macro flutter.widgets.editableText.cursorHeight}
  final double? cursorHeight;

  /// {@macro flutter.widgets.editableText.cursorRadius}
  final Radius? cursorRadius;

  /// The color of the cursor.
  ///
  /// The cursor indicates the current location of text insertion point in
  /// the field.
  final Color? cursorColor;

  /// {@macro flutter.widgets.editableText.showCursor}
  final bool? showCursor;

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
  /// If unset, defaults to the brightness of [ThemeData.primaryColorBrightness].
  final Brightness? keyboardAppearance;

  /// {@macro flutter.widgets.editableText.scrollPadding}
  final EdgeInsets scrollPadding;

  /// {@macro flutter.widgets.editableText.enableInteractiveSelection}
  final bool enableInteractiveSelection;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// {@macro flutter.widgets.editableText.scrollPhysics}
  final ScrollPhysics? scrollPhysics;

  /// {@macro flutter.widgets.editableText.scrollController}
  final ScrollController? scrollController;

  /// {@macro flutter.widgets.editableText.selectionEnabled}
  bool get selectionEnabled => enableInteractiveSelection;

  final GestureTapCallback? onTap;

  /// {@macro flutter.widgets.editableText.autofillHints}
  /// {@macro flutter.services.AutofillConfiguration.autofillHints}
  final Iterable<String>? autofillHints;

  /// {@macro flutter.material.textfield.restorationId}
  final String? restorationId;

  final ButtonThemeData? iconButtonThemeData;

  @override
  _TextBoxState createState() => _TextBoxState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<TextEditingController>('controller', controller,
          defaultValue: null))
      ..add(DiagnosticsProperty<FocusNode>('focusNode', focusNode,
          defaultValue: null))
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding))
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
      ..add(FlagProperty('autofocus',
          value: autofocus, ifFalse: 'manual focus', defaultValue: false))
      ..add(StringProperty('obscuringCharacter', obscuringCharacter,
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
      ..add(EnumProperty('maxLengthEnforcement', maxLengthEnforcement,
          defaultValue: null))
      ..add(DoubleProperty('cursorWidth', cursorWidth, defaultValue: 2.0))
      ..add(DoubleProperty('cursorHeight', cursorHeight, defaultValue: null))
      ..add(DiagnosticsProperty<Radius>('cursorRadius', cursorRadius,
          defaultValue: null))
      ..add(FlagProperty(
        'selectionEnabled',
        value: selectionEnabled,
        defaultValue: true,
        ifFalse: 'selection disabled',
      ))
      ..add(DiagnosticsProperty<ScrollController>(
        'scrollController',
        scrollController,
        defaultValue: null,
      ))
      ..add(DiagnosticsProperty<ScrollPhysics>(
        'scrollPhysics',
        scrollPhysics,
        defaultValue: null,
      ))
      ..add(EnumProperty<TextAlign>('textAlign', textAlign,
          defaultValue: TextAlign.start))
      ..add(DiagnosticsProperty<TextAlignVertical>(
        'textAlignVertical',
        textAlignVertical,
        defaultValue: null,
      ));
  }
}

class _TextBoxState extends State<TextBox>
    with RestorationMixin, AutomaticKeepAliveClientMixin
    implements TextSelectionGestureDetectorBuilderDelegate {
  final GlobalKey _clearGlobalKey = GlobalKey();

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

  @override
  bool get forcePressEnabled => true;

  @override
  final GlobalKey<EditableTextState> editableTextKey =
      GlobalKey<EditableTextState>();

  @override
  bool get selectionEnabled => widget.selectionEnabled;

  bool get enabled => widget.enabled ?? true;

  @override
  void initState() {
    super.initState();
    _selectionGestureDetectorBuilder =
        _TextBoxSelectionGestureDetectorBuilder(state: this);
    if (widget.controller == null) {
      _createLocalController();
    }
    _effectiveFocusNode.addListener(_handleFocusChanged);
  }

  void _handleFocusChanged() {
    if (!enabled && _effectiveFocusNode.hasPrimaryFocus) {
      _effectiveFocusNode.nextFocus();
    }
    setState(() {});
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
    final bool isEnabled = widget.enabled ?? true;
    final bool wasEnabled = oldWidget.enabled ?? true;
    if (wasEnabled && !isEnabled) {
      _effectiveFocusNode.unfocus();
    }
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

  bool get showActiveBorder => _effectiveFocusNode.hasFocus;

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_handleFocusChanged);
    _focusNode?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  EditableTextState? get _editableText => editableTextKey.currentState;

  void _requestKeyboard() {
    _editableText?.requestKeyboard();
  }

  bool _shouldShowSelectionHandles(SelectionChangedCause? cause) {
    if (!_selectionGestureDetectorBuilder.shouldShowSelectionToolbar) {
      return false;
    }

    if (_effectiveController.selection.isCollapsed) return false;

    if (cause == SelectionChangedCause.keyboard) return false;

    if (_effectiveController.text.isNotEmpty) return true;

    return false;
  }

  void _handleSelectionChanged(
      TextSelection selection, SelectionChangedCause? cause) {
    if (cause == SelectionChangedCause.longPress) {
      _editableText?.bringIntoView(selection.base);
    }
    final bool willShowSelectionHandles = _shouldShowSelectionHandles(cause);
    if (willShowSelectionHandles != _showSelectionHandles) {
      setState(() {
        _showSelectionHandles = willShowSelectionHandles;
      });
    }
  }

  @override
  bool get wantKeepAlive => _controller?.value.text.isNotEmpty == true;

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

  bool _showOutsidePrefixWidget(TextEditingValue text) {
    return widget.outsidePrefix != null &&
        _shouldShowAttachment(
          attachment: widget.outsidePrefixMode,
          hasText: text.text.isNotEmpty,
        );
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

  bool _showOutsideSuffixWidget(TextEditingValue text) {
    return widget.outsideSuffix != null &&
        _shouldShowAttachment(
          attachment: widget.outsideSuffixMode,
          hasText: text.text.isNotEmpty,
        );
  }

  bool get _hasDecoration {
    return widget.placeholder != null ||
        widget.prefix != null ||
        widget.suffix != null;
  }

  TextAlignVertical get _textAlignVertical {
    return widget.textAlignVertical ?? TextAlignVertical.top;
  }

  Widget _addTextDependentAttachments(
    Widget editableText,
    TextStyle textStyle,
    TextStyle placeholderStyle,
  ) {
    if (!_hasDecoration) {
      return editableText;
    }

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _effectiveController,
      child: editableText,
      builder: (BuildContext context, TextEditingValue text, Widget? child) {
        final result = Stack(children: <Widget>[
          if (widget.placeholder != null && text.text.isEmpty)
            Container(
              width: double.infinity,
              padding: widget.padding,
              child: Text(
                widget.placeholder!,
                maxLines: widget.maxLines,
                overflow: TextOverflow.ellipsis,
                style: placeholderStyle,
                textAlign: widget.textAlign,
              ),
            ),
          if (child != null) child,
        ]);
        // if (!_showPrefixWidget(text) && !_showSuffixWidget(text)) return result;
        return Row(children: <Widget>[
          if (_showPrefixWidget(text)) widget.prefix!,
          Expanded(child: result),
          if (_showSuffixWidget(text))
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: widget.suffix!,
            ),
        ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    assert(debugCheckHasDirectionality(context));
    assert(debugCheckHasFluentTheme(context));
    final ThemeData theme = FluentTheme.of(context);
    final textDirection = Directionality.of(context);
    final TextEditingController controller = _effectiveController;
    final List<TextInputFormatter> formatters =
        widget.inputFormatters ?? <TextInputFormatter>[];
    const Offset cursorOffset = Offset(0, -1);
    if (widget.maxLength != null) {
      formatters.add(LengthLimitingTextInputFormatter(
        widget.maxLength,
        maxLengthEnforcement: _effectiveMaxLengthEnforcement,
      ));
    }

    final defaultTextStyle = TextStyle(
      color: enabled ? theme.inactiveColor : theme.disabledColor,
    );
    final TextStyle textStyle = defaultTextStyle.merge(widget.style);

    final Brightness keyboardAppearance =
        widget.keyboardAppearance ?? theme.brightness;
    final Color cursorColor = widget.cursorColor ?? theme.inactiveColor;
    final Color disabledColor = theme.disabledColor;
    final Color backgroundColor = _effectiveFocusNode.hasFocus
        ? theme.scaffoldBackgroundColor
        : AccentColor('normal', const {
            'normal': Colors.white,
            'dark': Color(0xFF2d2d2d),
          }).resolve(context);

    final TextStyle placeholderStyle = textStyle
        .copyWith(
          color: !enabled
              ? theme.brightness.isLight
                  ? const Color.fromRGBO(0, 0, 0, 0.3614)
                  : const Color.fromRGBO(255, 255, 255, 0.3628)
              : theme.brightness.isLight
                  ? const Color.fromRGBO(0, 0, 0, 0.6063)
                  : const Color.fromRGBO(255, 255, 255, 0.786),
          fontWeight: FontWeight.w400,
        )
        .merge(widget.placeholderStyle);

    final BoxDecoration foregroundDecoration = BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: _effectiveFocusNode.hasFocus
              ? widget.highlightColor ?? theme.accentColor
              : !enabled
                  ? Colors.transparent
                  : theme.brightness.isLight
                      ? const Color.fromRGBO(0, 0, 0, 0.45)
                      : const Color.fromRGBO(255, 255, 255, 0.54),
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

    final Color selectionColor = theme.accentColor
        .resolveFromReverseBrightness(theme.brightness)
        .withOpacity(0.6);

    final Widget paddedEditable = Padding(
      padding: widget.padding,
      child: RepaintBoundary(
        child: UnmanagedRestorationScope(
          bucket: bucket,
          child: EditableText(
            key: editableTextKey,
            controller: controller,
            readOnly: widget.readOnly,
            toolbarOptions: widget.toolbarOptions,
            showCursor: widget.showCursor,
            showSelectionHandles: _showSelectionHandles,
            focusNode: _effectiveFocusNode,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            textCapitalization: widget.textCapitalization,
            style: textStyle,
            strutStyle: widget.strutStyle,
            textAlign: widget.textAlign,
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
            selectionColor: selectionColor,
            onChanged: widget.onChanged,
            onSelectionChanged: _handleSelectionChanged,
            onEditingComplete: widget.onEditingComplete,
            onSubmitted: widget.onSubmitted,
            inputFormatters: formatters,
            rendererIgnoresPointer: true,
            cursorWidth: widget.cursorWidth,
            cursorHeight: widget.cursorHeight,
            cursorRadius: widget.cursorRadius,
            cursorColor: cursorColor,
            cursorOpacityAnimates: true,
            cursorOffset: cursorOffset,
            paintCursorAboveText: false,
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
            autofillHints: widget.autofillHints,
            restorationId: 'editable',
            selectionControls: fluentTextSelectionControls,
          ),
        ),
      ),
    );

    final BorderRadius radius =
        widget.decoration?.borderRadius?.resolve(textDirection) ??
            BorderRadius.circular(4.0);
    final child = Semantics(
      enabled: enabled,
      onTap: !enabled
          ? null
          : () {
              if (!controller.selection.isValid) {
                controller.selection = TextSelection.collapsed(
                  offset: controller.text.length,
                );
              }
              _requestKeyboard();
            },
      child: IgnorePointer(
        ignoring: !enabled,
        child: AnimatedContainer(
          duration: theme.fasterAnimationDuration,
          curve: theme.animationCurve,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              style: _effectiveFocusNode.hasFocus
                  ? BorderStyle.solid
                  : BorderStyle.none,
              width: 1,
              color: theme.brightness.isLight
                  ? const Color.fromRGBO(0, 0, 0, 0.08)
                  : const Color.fromRGBO(255, 255, 255, 0.07),
            ),
            color: enabled
                ? backgroundColor
                : theme.brightness.isLight
                    ? const Color.fromRGBO(249, 249, 249, 0.3)
                    : const Color.fromRGBO(255, 255, 255, 0.04),
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
          foregroundDecoration: foregroundDecoration,
          constraints: BoxConstraints(minHeight: widget.minHeight ?? 0),
          child: _selectionGestureDetectorBuilder.buildGestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Align(
              alignment: Alignment(-1.0, _textAlignVertical.y),
              widthFactor: 1.0,
              heightFactor: 1.0,
              child: _addTextDependentAttachments(
                paddedEditable,
                textStyle,
                placeholderStyle,
              ),
            ),
          ),
        ),
      ),
    );

    Widget listener = ValueListenableBuilder<TextEditingValue>(
      valueListenable: _effectiveController,
      child: () {
        /// This has to be done this way because [ClipRRect] doesn't allow
        /// [Clip.none] as a value to [clipBehavior]
        if (widget.clipBehavior == Clip.none) return child;
        return ClipRRect(
          clipBehavior: widget.clipBehavior,
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: kPickerHeight),
            child: child,
          ),
        );
      }(),
      builder: (context, text, child) {
        if (!_showOutsidePrefixWidget(text) &&
            !_showOutsideSuffixWidget(text)) {
          return child!;
        }
        return Row(children: [
          if (_showOutsidePrefixWidget(text)) widget.outsidePrefix!,
          Expanded(child: child!),
          if (_showOutsideSuffixWidget(text)) widget.outsideSuffix!,
        ]);
      },
    );

    return ButtonTheme.merge(
      data: widget.iconButtonThemeData ?? const ButtonThemeData(),
      child: IconTheme.merge(
        data: const IconThemeData(size: 14),
        child: SmallIconButton(
          child: () {
            if (widget.header != null) {
              return InfoLabel(
                child: listener,
                label: widget.header!,
                labelStyle: widget.headerStyle,
              );
            }
            return listener;
          }(),
        ),
      ),
    );
  }
}
