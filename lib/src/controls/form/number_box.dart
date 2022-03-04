import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

enum SpinButtonPlacementMode {
  inline,
  compact,
}

class NumberBox extends StatefulWidget {
  const NumberBox({
    Key? key,
    required this.value,
    required this.onChanged,
    this.spinButtonPlacementMode = SpinButtonPlacementMode.inline,
    this.smallChange = 1,
    this.largeChange = 10,
  }) : super(key: key);

  final int? value;
  final ValueChanged<int?>? onChanged;
  final SpinButtonPlacementMode spinButtonPlacementMode;

  final int smallChange;
  final int largeChange;

  @override
  State<StatefulWidget> createState() => _NumberBoxState();
}

class _NumberBoxState extends State<NumberBox> {
  final controller = TextEditingController();
  final focus = FocusNode();
  final flyoutController = FlyoutController();
  bool clearBox = false;

  @override
  void initState() {
    controller.text = widget.value?.toString() ?? "";
    flyoutController.addListener(() {
      print('FLYOUTCONTROLLER EVENT: ${flyoutController.open}');
    });
    focus.addListener(() {
      /*setState(() {
        clearBox = focus.hasFocus;
      });*/
      if (focus.hasFocus && !flyoutController.open) {
        setState(() {
          flyoutController.open = true;
        });
      }

      if (controller.text.isEmpty) {
        _updateValue(null, false);
      } else {
        _updateValue(int.tryParse(controller.text) ?? widget.value, false);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    flyoutController.dispose();
    controller.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /*if (int.tryParse(controller.text) != widget.value) {
      controller.text = widget.value.toString();
    }*/
    Row? suffix;

    if (widget.spinButtonPlacementMode == SpinButtonPlacementMode.compact) {
      suffix = Row(
        children: [
          _clearIcon(focus, () {
            _updateValue(null, true);
          }),
          const Icon(FluentIcons.chevron_unfold10, size: 12),
          Flyout(
            verticalOffset: -50,
            child: const SizedBox.shrink(),
            contentWidth: 60,
            controller: flyoutController,
            content: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: PhysicalModel(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                shadowColor: Colors.black,
                elevation: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 100,
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
                          onPressed: _incrementSmall,
                          iconButtonMode: IconButtonMode.large,
                        ),
                        IconButton(
                          icon: const Icon(
                            FluentIcons.chevron_down,
                            size: 16,
                          ),
                          onPressed: _decrementSmall,
                          iconButtonMode: IconButtonMode.large,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (widget.spinButtonPlacementMode == SpinButtonPlacementMode.inline) {
      suffix = Row(children: [
        if (clearBox)
          IconButton(
            icon: const Icon(
              FluentIcons.clear,
              size: 8,
            ),
            iconButtonMode: IconButtonMode.large,
            onPressed: () {
              _updateValue(null, true);
            },
          ),
        IconButton(
          icon: const Icon(FluentIcons.chevron_up, size: 12),
          onPressed: _incrementSmall,
          iconButtonMode: IconButtonMode.large,
        ),
        IconButton(
          icon: const Icon(FluentIcons.chevron_down, size: 12),
          onPressed: _decrementSmall,
          iconButtonMode: IconButtonMode.large,
        ),
      ]);
    }

    return RawKeyboardListener(
      focusNode: FocusNode(skipTraversal: true),
      onKey: (key) {
        if (key.isAltPressed ||
            key.isShiftPressed ||
            key.isControlPressed ||
            key.isMetaPressed ||
            !key.isKeyPressed(key.logicalKey)) {
          return;
        }

        if (key.logicalKey == LogicalKeyboardKey.pageUp) {
          _incrementLarge();
        } else if (key.logicalKey == LogicalKeyboardKey.pageDown) {
          _decrementLarge();
        }
      },
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: Listener(
          onPointerSignal: (pointerSignal) {
            if (pointerSignal is PointerScrollEvent) {
              pointerSignal.scrollDelta.dy > 0
                  ? _decrementSmall()
                  : _incrementSmall();
            }
          },
          child: TextBox(
            controller: controller,
            focusNode: focus,
            suffix: suffix,
          ),
        ),
      ),
    );
  }

  Widget _clearIcon(FocusNode focus, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 10),
      child: IconButton(
        icon: const Icon(
          FluentIcons.clear,
          size: 8,
        ),
        iconButtonMode: IconButtonMode.large,
        onPressed: onPressed,
      ),
    );
  }

  void _incrementSmall() {
    _updateValue(
        (int.tryParse(controller.text) ?? 0) + widget.smallChange, true);
  }

  void _decrementSmall() {
    _updateValue(
        (int.tryParse(controller.text) ?? 0) - widget.smallChange, true);
  }

  void _incrementLarge() {
    _updateValue(
        (int.tryParse(controller.text) ?? 0) + widget.largeChange, true);
  }

  void _decrementLarge() {
    _updateValue(
        (int.tryParse(controller.text) ?? 0) - widget.largeChange, true);
  }

  void _updateValue(int? value, bool bt) {
    if (value == null && controller.text.isNotEmpty) {
      controller.clear();
    } else if (value != null && controller.text != value.toString()) {
      controller.text = value.toString();
    }
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }

    if (bt) {
      focus.requestFocus();
    }
  }
}
