import 'dart:ui' as ui;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:math_expressions/math_expressions.dart';

const kNumberBoxOverlayWidth = 60.0;
const kNumberBoxOverlayHeight = 100.0;

typedef NumberBoxFormatFunction = String? Function(num? number);

abstract interface class NumberBoxFormatter {
  String format(dynamic number);
}

enum SpinButtonPlacementMode {
  /// Two buttons will be added as a suffix of the number box field. A button
  /// for increment the value and a button for decrement the value.
  inline,

  /// An overlay is open when the widget has the focus with a "up" and a
  /// "down" buttons are added for increment or decrement the value
  /// of the number box.
  compact,

  /// No buttons are added to the text field.
  none,
}

/// A fluent design input form for numbers.
///
/// A NumberBox lets the user enter a number. If the user input a wrong value
/// (a NaN value), the previous valid value is used.
///
///
/// The value can be changed in several ways:
///   - by input a new value in the text field
///   - with increment/decrement buttons (only with modes
///     [SpinButtonPlacementMode.inline] or [SpinButtonPlacementMode.compact]).
///   - by use the wheel scroll on the number box when he have the focus
///   - with the shortcut [LogicalKeyboardKey.pageUp] and
///     [LogicalKeyboardKey.pageDown].
///
/// Modes:
///  [SpinButtonPlacementMode.inline] : Show two icons as a suffix of the text
///  field. With for increment the value and one for decrement the value.
///  [SpinButtonPlacementMode.compact] : Without the focus, it's appears like
///  a normal text field. But when the widget has the focus, an overlay is
///  visible with a button for increment the value and another for decrement
///  the value.
///  [SpinButtonPlacementMode.none] : Don't show any additional button on the
///  text field.
///
/// If the parameter [clearButton] is enabled, an additional icon is shown
/// for clear the value when the widget has the focus.
///
/// See also:
///
///  * https://learn.microsoft.com/en-us/windows/apps/design/controls/number-box
class NumberBox<T extends num> extends StatefulWidget {
  /// The value of the number box. When this value is null, the number box field
  /// is empty.
  final T? value;

  /// Called when the value of the number box change.
  /// The callback is fired only if the user click on a button or the focus is
  /// lost.
  ///
  /// If the [onChanged] callback is null then the number box widget will
  /// be disabled, i.e. its buttons will be displayed in grey and it will not
  /// respond to input.
  ///
  /// See also:
  ///
  ///   * [onChanging], called when the text of the number box change.
  final ValueChanged<T?>? onChanged;

  /// Called when the text of the number box change.
  final ValueChanged<String>? onTextChange;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// Display modes for the Number Box.
  final SpinButtonPlacementMode mode;

  /// When false, it disable the suffix button with a cross for remove the
  /// content of the number box.
  final bool clearButton;

  /// The value that is incremented or decremented when the user click on the
  /// buttons or when he scroll on the number box.
  final num smallChange;

  /// The value that is incremented when the user click on the shortcut
  /// [LogicalKeyboardKey.pageUp] and decremented when the user lick on the
  /// shortcut [LogicalKeyboardKey.pageDown].
  final num largeChange;

  /// The precision indicates the number of digits that's accepted for double
  /// value.
  ///
  /// If set, [pattern], [formatter] and [format] must be `null`.
  ///
  /// Default is 2.
  final int? precision;

  /// The parttern for the number box. The pattern is used to format the number
  /// when the user inputs a value.
  ///
  /// If set, [precision], [formatter] and [format] must be `null`.
  final String? pattern;

  /// The formatter for the number box. The formatter is used to format the
  /// number when the user inputs a value.
  ///
  /// If set, [pattern], [precision] and [format] must be `null`.
  final NumberBoxFormatter? formatter;

  /// The format function for the number box. The format function is used to
  /// format the number when the user input a value.
  ///
  /// If set, [pattern], [formatter] and [precision] must be `null`.
  final NumberBoxFormatFunction? format;

  /// The minimum value allowed. If the user input a value below than min,
  /// the value is replaced by min.
  /// If min is null, there is no lowest limit.
  final num? min;

  /// The maximum value allowed. If the user input a value greater than max,
  /// the value is replaced by max.
  /// If max is null, there is no upper limit.
  final num? max;

  /// When true, if something else than a number is specified, the content of
  /// the text box is interpreted as a math expression when the focus is lost.
  ///
  /// See also:
  ///
  ///   * <https://pub.dev/packages/math_expressions>
  final bool allowExpressions;

  /// A widget displayed at the start of the text box
  ///
  /// Usually an [IconButton] or [Icon]
  final Widget? leadingIcon;

  /// {@macro flutter.widgets.editableText.autofocus}
  final bool autofocus;

  /// {@macro flutter.widgets.editableText.inputFormatters}
  final List<TextInputFormatter>? inputFormatters;

  /// The text shown when the text box is empty
  ///
  /// See also:
  ///
  ///  * [TextBox.placeholder]
  final String? placeholder;

  /// The style of [placeholder]
  ///
  /// See also:
  ///
  ///  * [TextBox.placeholderStyle]
  final TextStyle? placeholderStyle;

  /// {@macro flutter.widgets.editableText.cursorWidth}
  final double cursorWidth;

  /// {@macro flutter.widgets.editableText.cursorRadius}
  final Radius cursorRadius;

  /// {@macro flutter.widgets.editableText.cursorHeight}
  final double? cursorHeight;

  /// The color of the cursor.
  ///
  /// The cursor indicates the current location of text insertion point in
  /// the field.
  final Color? cursorColor;

  /// {@macro flutter.widgets.editableText.showCursor}
  final bool? showCursor;

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

  /// The style to use for the text being edited.
  ///
  /// Also serves as a base for the [placeholder] text's style.
  ///
  /// Defaults to the standard font style from [FluentTheme] if null.
  final TextStyle? style;

  /// {@macro flutter.widgets.editableText.textAlign}
  final TextAlign? textAlign;

  /// {@macro flutter.widgets.editableText.keyboardType}
  final TextInputType? keyboardType;

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

  /// {@macro flutter.widgets.editableText.textDirection}
  final TextDirection? textDirection;

  /// The type of action button to use for the keyboard.
  ///
  /// Defaults to [TextInputAction.newline] if [keyboardType] is
  /// [TextInputType.multiline] and [TextInputAction.done] otherwise.
  final TextInputAction? textInputAction;

  /// {@macro flutter.widgets.editableText.onEditingComplete}
  final VoidCallback? onEditingComplete;

  /// Creates a number box.
  const NumberBox({
    super.key,
    required this.value,
    required this.onChanged,
    this.onTextChange,
    this.focusNode,
    this.mode = SpinButtonPlacementMode.compact,
    this.clearButton = true,
    this.smallChange = 1,
    this.largeChange = 10,
    this.precision,
    this.pattern,
    this.formatter,
    this.format,
    this.min,
    this.max,
    this.allowExpressions = false,
    this.leadingIcon,
    this.autofocus = false,
    this.inputFormatters,
    this.placeholder,
    this.placeholderStyle,
    this.cursorWidth = 1.5,
    this.cursorRadius = const Radius.circular(2.0),
    this.cursorHeight,
    this.cursorColor,
    this.showCursor,
    this.highlightColor,
    this.unfocusedColor,
    this.style,
    this.textAlign,
    this.keyboardType = TextInputType.number,
    this.dragStartBehavior = DragStartBehavior.start,
    this.enableInteractiveSelection = true,
    this.keyboardAppearance,
    this.scrollController,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.scrollPhysics,
    this.selectionControls,
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.textDirection,
    this.textInputAction,
    this.onEditingComplete,
  }) : assert((precision != null &&
                pattern == null &&
                formatter == null &&
                format == null) ||
            (precision == null &&
                pattern != null &&
                formatter == null &&
                format == null) ||
            (precision == null &&
                pattern == null &&
                formatter != null &&
                format == null) ||
            (precision == null &&
                pattern == null &&
                formatter == null &&
                format != null) ||
            (precision == null &&
                pattern == null &&
                formatter == null &&
                format == null));

  @override
  State<NumberBox<T>> createState() => NumberBoxState<T>();
}

class NumberBoxState<T extends num> extends State<NumberBox<T>> {
  FocusNode? _internalNode;

  FocusNode get focusNode => (widget.focusNode ?? _internalNode)!;

  OverlayEntry? _entry;

  bool _hasPrimaryFocus = false;

  late num? previousValidValue = widget.value;

  // use dynamic to simulate duck typing
  late final dynamic _formatter;
  late final NumberBoxFormatFunction _format;

  final controller = TextEditingController();

  final LayerLink _layerLink = LayerLink();
  final GlobalKey _textBoxKey = GlobalKey(
    debugLabel: "NumberBox's TextBox Key",
  );

  // Only used if needed to create _internalNode.
  FocusNode _createFocusNode() {
    return FocusNode(debugLabel: '${widget.runtimeType}');
  }

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _internalNode ??= _createFocusNode();
    }
    focusNode.addListener(_handleFocusChanged);

    if (widget.precision == null &&
        widget.pattern == null &&
        widget.formatter == null) {
      _formatter = NumberFormat('#.${List.filled(2, '#').join()}') as dynamic;
    }
    if (widget.precision != null) {
      final pattern = '#.${List.filled(widget.precision!, '#').join()}';
      _formatter = NumberFormat(pattern) as dynamic;
    }
    if (widget.pattern != null) {
      _formatter = NumberFormat(widget.pattern) as dynamic;
    }
    if (widget.formatter != null) {
      _formatter = widget.formatter!;
    }
    if (widget.format != null) {
      _format = widget.format!;
    } else {
      _format = (num? value) {
        if (value == null) return null;
        if (value is int) {
          return value.toString();
        }
        return _formatter.format(value);
      };
    }
    controller.text = widget.value?.toString() ?? '';
  }

  @override
  void dispose() {
    _dismissOverlay();
    focusNode.removeListener(_handleFocusChanged);
    _internalNode?.dispose();
    controller.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (_hasPrimaryFocus != focusNode.hasPrimaryFocus) {
      setState(() {
        _hasPrimaryFocus = focusNode.hasPrimaryFocus;
      });

      if (widget.mode == SpinButtonPlacementMode.compact) {
        if (_hasPrimaryFocus && _entry == null) {
          _insertOverlay();
        } else if (!_hasPrimaryFocus && _entry != null) {
          _dismissOverlay();
        }
      }

      if (!_hasPrimaryFocus) {
        updateValue();
      }
    }
  }

  @override
  void didUpdateWidget(NumberBox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChanged);
      if (widget.focusNode == null) {
        _internalNode ??= _createFocusNode();
      }
      _hasPrimaryFocus = focusNode.hasPrimaryFocus;
      focusNode.addListener(_handleFocusChanged);
    }

    if (oldWidget.value != widget.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.value != null) {
          _updateController(widget.value!);
        } else {
          controller.text = '';
        }

        if ((oldWidget.min != widget.min && widget.min != null) ||
            (oldWidget.max != widget.max && widget.max != null)) {
          updateValue();
        }
      });
    }
  }

  void _insertOverlay() {
    _entry = OverlayEntry(builder: (context) {
      assert(debugCheckHasMediaQuery(context));
      assert(debugCheckHasFluentTheme(context));

      final boxContext = _textBoxKey.currentContext;
      if (boxContext == null) return const SizedBox.shrink();
      final box = boxContext.findRenderObject() as RenderBox;

      Widget child = PositionedDirectional(
        width: kNumberBoxOverlayWidth,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(box.size.width - kNumberBoxOverlayWidth,
              box.size.height / 2 - kNumberBoxOverlayHeight / 2),
          child: SizedBox(
            width: kNumberBoxOverlayWidth,
            child: FluentTheme(
              data: FluentTheme.of(context),
              child: TextFieldTapRegion(
                child: _NumberBoxCompactOverlay(
                  onIncrement: incrementSmall,
                  onDecrement: decrementSmall,
                ),
              ),
            ),
          ),
        ),
      );

      return child;
    });

    if (_textBoxKey.currentContext != null) {
      Overlay.of(context).insert(_entry!);
      if (mounted) setState(() {});
    }
  }

  void _dismissOverlay() {
    _entry?.remove();
    _entry = null;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasOverlay(context));

    final textFieldSuffix = <Widget>[
      if (widget.clearButton && _hasPrimaryFocus)
        IconButton(
          icon: const Icon(FluentIcons.clear),
          onPressed: _clearValue,
        ),
    ];

    switch (widget.mode) {
      case SpinButtonPlacementMode.inline:
        textFieldSuffix.addAll([
          IconButton(
            icon: const Icon(FluentIcons.chevron_up),
            onPressed: widget.onChanged != null ? incrementSmall : null,
          ),
          IconButton(
            icon: const Icon(FluentIcons.chevron_down),
            onPressed: widget.onChanged != null ? decrementSmall : null,
          ),
        ]);
        break;
      case SpinButtonPlacementMode.compact:
        textFieldSuffix.add(const SizedBox(width: kNumberBoxOverlayWidth));
        break;
      case SpinButtonPlacementMode.none:
        break;
    }

    final child = TextBox(
      key: _textBoxKey,
      autofocus: widget.autofocus,
      inputFormatters: widget.inputFormatters,
      placeholder: widget.placeholder,
      placeholderStyle: widget.placeholderStyle,
      showCursor: widget.showCursor,
      cursorColor: widget.cursorColor,
      cursorHeight: widget.cursorHeight,
      cursorRadius: widget.cursorRadius,
      cursorWidth: widget.cursorWidth,
      highlightColor: widget.highlightColor,
      prefix: widget.leadingIcon,
      focusNode: focusNode,
      controller: controller,
      keyboardType: widget.keyboardType,
      enabled: widget.onChanged != null,
      suffix:
          textFieldSuffix.isNotEmpty ? Row(children: textFieldSuffix) : null,
      unfocusedColor: widget.unfocusedColor,
      style: widget.style,
      textAlign: widget.textAlign ?? TextAlign.start,
      keyboardAppearance: widget.keyboardAppearance,
      scrollPadding: widget.scrollPadding,
      scrollController: widget.scrollController,
      scrollPhysics: widget.scrollPhysics,
      dragStartBehavior: widget.dragStartBehavior,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      selectionControls: widget.selectionControls,
      selectionHeightStyle: widget.selectionHeightStyle,
      selectionWidthStyle: widget.selectionWidthStyle,
      textDirection: widget.textDirection,
      onSubmitted: (_) => updateValue(),
      onTap: updateValue,
      onTapOutside: (_) => updateValue(),
      onEditingComplete: widget.onEditingComplete != null
          ? () {
              updateValue();
              widget.onEditingComplete!();
            }
          : null,
      onChanged: widget.onTextChange,
      textInputAction: widget.textInputAction,
    );

    return CompositedTransformTarget(
      link: _layerLink,
      child: Focus(
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
            return KeyEventResult.ignored;
          }

          if (event.logicalKey == LogicalKeyboardKey.pageUp) {
            incrementLarge();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.pageDown) {
            decrementLarge();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            incrementSmall();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            decrementSmall();
            return KeyEventResult.handled;
          }

          return KeyEventResult.ignored;
        },
        child: Listener(
          onPointerSignal: (event) {
            if (_hasPrimaryFocus && event is PointerScrollEvent) {
              GestureBinding.instance.pointerSignalResolver.register(event,
                  (PointerSignalEvent event) {
                if (event is PointerScrollEvent) {
                  if (event.scrollDelta.direction < 0) {
                    incrementSmall();
                  } else {
                    decrementSmall();
                  }
                }
              });
            }
          },
          child: child,
        ),
      ),
    );
  }

  void _clearValue() {
    controller.text = '';
    updateValue();
  }

  void incrementSmall() {
    final value = (num.tryParse(controller.text) ?? widget.value ?? 0) +
        widget.smallChange;
    _updateController(value);
    updateValue();
  }

  void decrementSmall() {
    final value = (num.tryParse(controller.text) ?? widget.value ?? 0) -
        widget.smallChange;
    _updateController(value);
    updateValue();
  }

  void incrementLarge() {
    final value = (num.tryParse(controller.text) ?? widget.value ?? 0) +
        widget.largeChange;
    _updateController(value);
    updateValue();
  }

  void decrementLarge() {
    final value = (num.tryParse(controller.text) ?? widget.value ?? 0) -
        widget.largeChange;
    _updateController(value);
    updateValue();
  }

  void _updateController(num value) {
    controller
      ..text = _format(value) ?? ''
      ..selection = TextSelection.collapsed(offset: controller.text.length);
  }

  void updateValue() {
    num? value;
    if (controller.text.isNotEmpty) {
      value = num.tryParse(controller.text);
      if (value == null && widget.allowExpressions) {
        try {
          value = Parser()
              .parse(controller.text)
              .evaluate(EvaluationType.REAL, ContextModel());
          // If the value is infinite or not a number, we reset the value with
          // the previous valid value. For example, if the user tap 1024^200
          // (the result is too big), the condition value.isInfinite is true.
          if (value!.isInfinite || value.isNaN) {
            value = previousValidValue;
          }
        } catch (_) {
          value = previousValidValue;
        }
      } else {
        value ??= previousValidValue;
      }

      if (value != null && widget.max != null && value > widget.max!) {
        value = widget.max;
      } else if (value != null && widget.min != null && value < widget.min!) {
        value = widget.min;
      }

      if (T == int) {
        value = value?.toInt();
      } else {
        value = value?.toDouble();
      }

      controller.text = _format(value) ?? '';
    }
    previousValidValue = value;

    if (widget.onChanged != null) {
      widget.onChanged!(value as T?);
    }
  }
}

class _NumberBoxCompactOverlay extends StatelessWidget {
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _NumberBoxCompactOverlay({
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 10),
      child: PhysicalModel(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        elevation: 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: kNumberBoxOverlayHeight,
            width: kNumberBoxOverlayWidth,
            decoration: BoxDecoration(
              color: FluentTheme.of(context).menuColor,
              border: Border.all(
                width: 0.25,
                color: FluentTheme.of(context).inactiveBackgroundColor,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(
                    FluentIcons.chevron_up,
                    size: 16,
                  ),
                  onPressed: onIncrement,
                  iconButtonMode: IconButtonMode.large,
                ),
                IconButton(
                  icon: const Icon(
                    FluentIcons.chevron_down,
                    size: 16,
                  ),
                  onPressed: onDecrement,
                  iconButtonMode: IconButtonMode.large,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A [FormField] that contains a [NumberBox].
///
/// This is a convenience widget that wraps a [NumberBox] widget in a
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
///   * [NumberBox], which is the underlying number box without the [Form]
///    integration.
///   * <https://docs.microsoft.com/en-us/windows/apps/design/controls/number-box>
class NumberFormBox<T extends num> extends ControllableFormBox {
  /// Creates a [FormField] that contains a [NumberBox].
  ///
  /// When a [controller] is specified, [initialValue] must be null (the
  /// default). If [controller] is null, then a [TextEditingController]
  /// will be constructed automatically and its `text` will be initialized
  /// to [initialValue] or the empty string.
  ///
  /// For documentation about the various parameters, see the [NumberBox] class
  /// and [NumberBox.new], the constructor.
  NumberFormBox({
    super.key,
    super.autovalidateMode,
    super.initialValue,
    super.onSaved,
    super.restorationId,
    super.validator,
    ValueChanged<T?>? onChanged,
    FocusNode? focusNode,
    bool autofocus = false,
    bool? showCursor,
    double cursorWidth = 2.0,
    double? cursorHeight,
    Radius cursorRadius = const Radius.circular(2.0),
    Color? cursorColor,
    Color? highlightColor,
    Color? errorHighlightColor,
    String? placeholder,
    TextStyle? placeholderStyle,
    Widget? leadingIcon,
    List<TextInputFormatter>? inputFormatters,
    T? value,
    bool allowExpressions = false,
    bool clearButton = true,
    num largeChange = 10,
    num smallChange = 1,
    num? max,
    num? min,
    int precision = 2,
    SpinButtonPlacementMode mode = SpinButtonPlacementMode.compact,
  }) : super(builder: (FormFieldState<String> field) {
          assert(debugCheckHasFluentTheme(field.context));
          final theme = FluentTheme.of(field.context);
          void onChangedHandler(T? value) {
            field.didChange(value.toString());
            onChanged?.call(value);
          }

          return UnmanagedRestorationScope(
            bucket: field.bucket,
            child: FormRow(
              padding: EdgeInsets.zero,
              error: (field.errorText == null) ? null : Text(field.errorText!),
              child: NumberBox<T>(
                focusNode: focusNode,
                autofocus: autofocus,
                showCursor: showCursor,
                cursorColor: cursorColor,
                cursorHeight: cursorHeight,
                cursorRadius: cursorRadius,
                cursorWidth: cursorWidth,
                onChanged: onChanged == null ? null : onChangedHandler,
                highlightColor: (field.errorText == null)
                    ? highlightColor
                    : errorHighlightColor ??
                        Colors.red.defaultBrushFor(theme.brightness),
                placeholder: placeholder,
                placeholderStyle: placeholderStyle,
                leadingIcon: leadingIcon,
                value: value,
                max: max,
                min: min,
                allowExpressions: allowExpressions,
                clearButton: clearButton,
                largeChange: largeChange,
                smallChange: smallChange,
                precision: precision,
                inputFormatters: inputFormatters,
                mode: mode,
              ),
            ),
          );
        });

  @override
  FormFieldState<String> createState() => TextFormBoxState();
}
