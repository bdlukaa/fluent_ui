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
class NumberBox extends StatefulWidget {
  /// The value of the number box. When this value is null, the number box field
  /// is empty.
  final int? value;

  /// Event fired when the value of the number box is changed.
  /// Note: only when the user click on a button (for increment, decrement or
  /// clear the content) and when the focus is lost.
  final ValueChanged<int?>? onChanged;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// Display modes for the Number Box.
  final SpinButtonPlacementMode mode;

  /// When false, it disable the suffix button with a cross for remove the
  /// content of the number box.
  final bool clearButton;

  /// The value that is incremented or decremented when the user click on the
  /// buttons or when he scroll on the number box.
  final int smallChange;

  /// The value that is incremented when the user click on the shortcut
  /// [LogicalKeyboardKey.pageUp] and decremented when the user lick on the
  /// shortcut [LogicalKeyboardKey.pageDown].
  final int largeChange;

  const NumberBox({
    super.key,
    required this.value,
    required this.onChanged,
    this.focusNode,
    this.mode = SpinButtonPlacementMode.compact,
    this.clearButton = true,
    this.smallChange = 1,
    this.largeChange = 10,
  });

  @override
  State<StatefulWidget> createState() => _NumberBoxState();
}

class _NumberBoxState extends State<NumberBox> {
  FocusNode? _internalNode;
  FocusNode? get focusNode => widget.focusNode ?? _internalNode;

  OverlayEntry? _entry;

  bool _hasPrimaryFocus = false;

  late int? previousValidValue = widget.value;

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
  void didUpdateWidget(NumberBox oldWidget) {
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
    final textFieldSuffix = <Widget>[
      if(widget.clearButton && _hasPrimaryFocus)
        IconButton(
          icon: const Icon(FluentIcons.clear),
          onPressed: _clearValue,
        ),
    ];

    switch(widget.mode){
      case SpinButtonPlacementMode.inline:
        textFieldSuffix.addAll([
          IconButton(
            icon: const Icon(FluentIcons.chevron_up),
            onPressed: _incrementSmall,
          ),
          IconButton(
            icon: const Icon(FluentIcons.chevron_down),
            onPressed: _decrementSmall,
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
      focusNode: focusNode,
      controller: controller,
      suffix: textFieldSuffix.isNotEmpty ? Row(children: textFieldSuffix) : null,
    );

    return CompositedTransformTarget(
      link: _layerLink,
      child: Focus(
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent) {
            return KeyEventResult.ignored;
          }

          if (event.logicalKey == LogicalKeyboardKey.pageUp) {
            _incrementLarge();
          } else if (event.logicalKey == LogicalKeyboardKey.pageDown) {
            _decrementLarge();
          }

          return KeyEventResult.ignored;
        },
        child: Listener(
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              if (event.scrollDelta.direction < 0) {
                _incrementSmall();
              } else {
                _decrementSmall();
              }
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

  void _updateController(int value) {
    controller
      ..text = value.toString()
      ..selection = TextSelection.collapsed(offset: controller.text.length);
  }

  void _updateValue() {
    int? value;
    if(controller.text.isNotEmpty){
      value = int.tryParse(controller.text) ?? previousValidValue;
      controller.text = value.toString();
    }
    previousValidValue = value;

    if (widget.onChanged != null) {
      widget.onChanged!(value);
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
