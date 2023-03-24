import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

const kNumberBoxOverlayWidth = 60.0;
const kNumberBoxOverlayHeight = 100.0;

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
  final ValueChanged<T?>? onChanged;

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

  const NumberBox({
    super.key,
    required this.value,
    required this.onChanged,
    this.focusNode,
    this.mode = SpinButtonPlacementMode.compact,
    this.clearButton = true,
    this.smallChange = 1,
    this.largeChange = 10,
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
  });

  @override
  State<NumberBox<T>> createState() => NumberBoxState<T>();
}

class NumberBoxState<T extends num> extends State<NumberBox<T>> {
  FocusNode? _internalNode;

  FocusNode? get focusNode => widget.focusNode ?? _internalNode;

  OverlayEntry? _entry;

  bool _hasPrimaryFocus = false;

  late num? previousValidValue = widget.value;

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
    if (widget.focusNode == null) {
      _internalNode ??= _createFocusNode();
    }
    focusNode!.addListener(_handleFocusChanged);

    controller.text = widget.value?.toString() ?? '';
    super.initState();
  }

  @override
  void dispose() {
    _dismissOverlay();
    focusNode!.removeListener(_handleFocusChanged);
    _internalNode?.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (_hasPrimaryFocus != focusNode!.hasPrimaryFocus) {
      setState(() {
        _hasPrimaryFocus = focusNode!.hasPrimaryFocus;
      });

      if (widget.mode == SpinButtonPlacementMode.compact) {
        if (_hasPrimaryFocus && _entry == null) {
          _insertOverlay();
        } else if (!_hasPrimaryFocus && _entry != null) {
          _dismissOverlay();
        }
      }

      if (!_hasPrimaryFocus) {
        _updateValue();
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
      _hasPrimaryFocus = focusNode!.hasPrimaryFocus;
      focusNode!.addListener(_handleFocusChanged);
    }

    if (oldWidget.value != widget.value) {
      if (widget.value != null) {
        _updateController(widget.value!);
      } else {
        controller.text = '';
      }
    }
  }

  void _insertOverlay() {
    _entry = OverlayEntry(builder: (context) {
      assert(debugCheckHasMediaQuery(context));

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
                  onIncrement: _incrementSmall,
                  onDecrement: _decrementSmall,
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
            onPressed: widget.onChanged != null ? _incrementSmall : null,
          ),
          IconButton(
            icon: const Icon(FluentIcons.chevron_down),
            onPressed: widget.onChanged != null ? _decrementSmall : null,
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
      cursorColor: widget.cursorColor,
      cursorHeight: widget.cursorHeight,
      cursorRadius: widget.cursorRadius,
      cursorWidth: widget.cursorWidth,
      highlightColor: widget.highlightColor,
      prefix: widget.leadingIcon,
      focusNode: focusNode,
      controller: controller,
      keyboardType: TextInputType.number,
      enabled: widget.onChanged != null,
      suffix:
          textFieldSuffix.isNotEmpty ? Row(children: textFieldSuffix) : null,
    );

    return CompositedTransformTarget(
      link: _layerLink,
      child: Focus(
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
            return KeyEventResult.ignored;
          }

          if (event.logicalKey == LogicalKeyboardKey.pageUp) {
            _incrementLarge();
          } else if (event.logicalKey == LogicalKeyboardKey.pageDown) {
            _decrementLarge();
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            _incrementSmall();
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            _decrementSmall();
          } else {
            return KeyEventResult.ignored;
          }

          return KeyEventResult.handled;
        },
        child: Listener(
          onPointerSignal: (event) {
            if (_hasPrimaryFocus && event is PointerScrollEvent) {
              GestureBinding.instance.pointerSignalResolver.register(event,
                  (PointerSignalEvent event) {
                if (event is PointerScrollEvent) {
                  if (event.scrollDelta.direction < 0) {
                    _incrementSmall();
                  } else {
                    _decrementSmall();
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
    _updateValue();
  }

  void _incrementSmall() {
    final value = (int.tryParse(controller.text) ?? widget.value ?? 0) +
        widget.smallChange;
    _updateController(value);
    _updateValue();
  }

  void _decrementSmall() {
    final value = (int.tryParse(controller.text) ?? widget.value ?? 0) -
        widget.smallChange;
    _updateController(value);
    _updateValue();
  }

  void _incrementLarge() {
    final value = (int.tryParse(controller.text) ?? widget.value ?? 0) +
        widget.largeChange;
    _updateController(value);
    _updateValue();
  }

  void _decrementLarge() {
    final value = (int.tryParse(controller.text) ?? widget.value ?? 0) -
        widget.largeChange;
    _updateController(value);
    _updateValue();
  }

  void _updateController(num value) {
    controller
      ..text = value.toString()
      ..selection = TextSelection.collapsed(offset: controller.text.length);
  }

  void _updateValue() {
    num? value;
    if (controller.text.isNotEmpty) {
      value = num.tryParse(controller.text) ?? previousValidValue;
      if(T == int){
        value = value?.toInt();
      }else{
        value = value?.toDouble();
      }

      controller.text = value.toString();
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
    return Padding(
      padding: const EdgeInsets.only(left: 10),
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
