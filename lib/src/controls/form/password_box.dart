import 'package:fluent_ui/fluent_ui.dart';

enum PasswordRevealMode {
  /// The password reveal button is visible. The password is not obscured while
  /// the button is pressed.
  ///
  /// If the focus is lost, the button will be hidden on next time the focus
  /// is got until the password box is cleared. (This is a security concern).
  ///
  /// If you want to keep the reveal button visible, see [peekAlways].
  peek,

  /// The password reveal button is visible. The button is not obscured while
  /// the button is pressed.
  ///
  /// The reveal button will always be visible if the password box has the focus
  /// and it's not empty. Unlike the [peek] mode, if the focus is regained,
  /// the reveal button will be visible.
  peekAlways,

  /// The password reveal button is not visible. The password is
  /// always obscured.
  hidden,

  /// The password reveal button is not visible. The password is not obscured.
  visible,
}

class PasswordBox extends StatefulWidget {
  final FocusNode? focusNode;
  final bool enabled;
  final String? placeholder;
  final PasswordRevealMode revealMode;

  const PasswordBox({
    super.key,
    this.focusNode,
    this.enabled = true,
    this.placeholder,
    this.revealMode = PasswordRevealMode.peek,
  });

  @override
  State<PasswordBox> createState() => _PasswordBoxState();
}

class _PasswordBoxState extends State<PasswordBox> {
  bool peek = false;
  bool focusCanPeek = true;
  bool textCanPeek = false;

  final TextEditingController controller = TextEditingController();

  FocusNode? _internalNode;

  FocusNode? get focusNode => widget.focusNode ?? _internalNode;

  bool get _isVisible =>
      widget.revealMode == PasswordRevealMode.visible ||
      (widget.revealMode == PasswordRevealMode.peek && peek);

  bool get _canPeek =>
      (widget.revealMode == PasswordRevealMode.peekAlways && textCanPeek) ||
      (widget.revealMode == PasswordRevealMode.peek &&
          focusCanPeek &&
          textCanPeek);

  @override
  void initState() {
    if (widget.focusNode == null) {
      _internalNode ??= _createFocusNode();
    }
    controller.addListener(_handleTextChange);
    focusNode!.addListener(_handleFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode!.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    if (controller.text.isEmpty) {
      // If the text box is empty, then we ignore if the focus has been
      // lost or not previously.
      focusCanPeek = true;
    }

    if (controller.text.isNotEmpty && !textCanPeek) {
      // If the text box is not empty, the reveal button must be visible
      // (it will be only if focusCanPeek is true !)
      setState(() {
        textCanPeek = true;
      });
    } else if (controller.text.isEmpty && textCanPeek) {
      // If the text box is empty, the reveal button must be hidden.
      setState(() {
        textCanPeek = false;
      });
    }
  }

  void _handleFocusChange() {
    if (!focusNode!.hasFocus && controller.text.isNotEmpty) {
      // If the focus is lost and the text box is not empty, then the reveal
      // button must not be hidden.
      setState(() {
        focusCanPeek = false;
      });
    }
  }

  // Only used if needed to create _internalNode.
  FocusNode _createFocusNode() {
    return FocusNode(debugLabel: '${widget.runtimeType}');
  }

  @override
  Widget build(BuildContext context) {
    return TextBox(
      focusNode: focusNode,
      controller: controller,
      enabled: widget.enabled,
      placeholder: widget.placeholder,
      obscureText: !_isVisible,
      suffix: _canPeek
          ? IconButton(
              icon: const Icon(FluentIcons.red_eye),
              // todo: half eye icon, like WinUI3 ?
              onPressed: null,
              onTapDown: widget.enabled
                  ? () {
                      setState(() {
                        peek = true;
                      });
                    }
                  : null,
              onTapUp: widget.enabled
                  ? () {
                      setState(() {
                        peek = false;
                      });
                    }
                  : null,
            )
          : null,
    );
  }
}
