import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

const kNumberBoxOverlayWidth = 60.0;
const kNumberBoxOverlayHeight = 100.0;

enum SpinButtonPlacementMode {
  inline,
  compact,
}

class NumberBox extends StatefulWidget {
  final int? value;
  final ValueChanged<int?>? onChanged;
  final String placeholderText;
  final SpinButtonPlacementMode mode;
  final FocusNode? focusNode;

  final bool clearButton;

  final int smallChange;
  final int largeChange;

  const NumberBox({
    super.key,
    required this.value,
    required this.onChanged,
    this.placeholderText = '',
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
    Widget child;

    if (widget.mode == SpinButtonPlacementMode.inline) {
      child = TextBox(
        focusNode: focusNode,
        controller: controller,
        suffix: Row(
          children: [
            if (widget.clearButton && _hasPrimaryFocus)
              IconButton(
                icon: const Icon(FluentIcons.clear),
                onPressed: _clearValue,
              ),
            IconButton(
              icon: const Icon(FluentIcons.chevron_up),
              onPressed: _incrementSmall,
            ),
            IconButton(
              icon: const Icon(FluentIcons.chevron_down),
              onPressed: _decrementSmall,
            ),
          ],
        ),
      );
    } else {
      child = TextBox(
        key: _textBoxKey,
        focusNode: focusNode,
        controller: controller,
      );
    }

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
    final value = int.tryParse(controller.text);

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
