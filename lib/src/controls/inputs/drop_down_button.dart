import 'package:fluent_ui/fluent_ui.dart';

class DropDownButton extends StatefulWidget {
  DropDownButton({
    Key key,
    @required this.content,
    @required this.dropdown,
    this.style,
    this.disabled = false,
    this.focusNode,
    this.startOpen = false,
    this.adoptDropdownWidth = true,
    this.horizontal = false,
  })  : assert(content != null),
        assert(dropdown != null),
        assert(disabled != null),
        assert(adoptDropdownWidth != null),
        assert(startOpen != null),
        assert(horizontal != null),
        super(key: key);

  final ButtonStyle style;

  final Widget content;
  final Widget dropdown;
  final bool adoptDropdownWidth;
  final bool horizontal;

  final bool disabled;
  final bool startOpen;
  final FocusNode focusNode;

  @override
  _DropDownButtonState createState() => _DropDownButtonState();
}

class _DropDownButtonState extends State<DropDownButton> {
  FocusNode node = FocusNode();
  GlobalKey _key = LabeledGlobalKey(UniqueKey().toString());
  Offset buttonPosition;
  Size buttonSize;
  OverlayEntry _overlayEntry;
  bool isOpen = false;

  @override
  void initState() {
    if (widget.startOpen)
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        open();
      });
    super.initState();
  }

  void findButton() {
    RenderBox renderBox = _key.currentContext.findRenderObject();
    buttonSize = renderBox.size;
    buttonPosition = renderBox.localToGlobal(Offset.zero);
  }

  void close() {
    if (!isOpen) return;
    setState(() => _overlayEntry?.remove());
    _overlayEntry = null;
    isOpen = false;
    node.unfocus();
  }

  void open() {
    if (isOpen) return;
    findButton();
    _overlayEntry = _overlayEntryBuilder();
    Overlay.of(context).insert(_overlayEntry);
    isOpen = true;
    node.requestFocus();
  }

  void toggle() {
    if (isOpen)
      close();
    else
      open();
  }

  ButtonStyle style(BuildContext context) =>
      context.theme.buttonStyle.copyWith(widget.style);

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: node,
      onFocusChange: (focused) {
        if (!focused && isOpen) close();
      },
      child: Button(
        key: _key,
        text: widget.content,
        style: widget.style,
        onPressed: widget.disabled
            ? null
            : () {
                toggle();
                // if (node.hasFocus)
                //   node.unfocus();
                // else
                //   node.requestFocus();
              },
      ),
    );
  }

  OverlayEntry _overlayEntryBuilder() {
    return OverlayEntry(
      builder: (context) {
        final style = this.style(context);
        double top, bottom, right, left, width;
        if (widget.adoptDropdownWidth) {
          width = buttonSize.width - (style?.margin?.horizontal ?? 0);
        }

        if (widget.horizontal) {
          left = buttonPosition.dx + buttonSize.width;
          top = buttonPosition.dy + (style?.margin?.vertical ?? 0) / 2;
        } else {
          top = buttonPosition.dy + buttonSize.height;
          left = buttonPosition.dx + (style?.margin?.horizontal ?? 0) / 2;
        }

        return Positioned(
          top: top,
          bottom: bottom,
          right: right,
          left: left,
          width: width,
          child: widget.dropdown ?? SizedBox(),
        );
      },
    );
  }
}

class Dropdown extends StatelessWidget {
  const Dropdown({Key key, @required this.child}) : super(key: key);

  final Widget child;

  Dropdown.sections({
    Key key,
    Widget divider,
    List<Widget> sectionTitles,
    List<Widget> sectionBodies,
  })  : assert(sectionBodies.length == sectionTitles.length),
        child = Column(
          children: List.generate(sectionTitles.length, (index) {
            divider ??= Divider();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sectionTitles[index],
                sectionBodies[index],
                if (sectionTitles.length - 1 != index) divider,
              ],
            );
          }),
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: elevationShadow(),
      ),
      child: child,
    );
  }
}
