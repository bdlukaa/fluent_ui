import 'package:fluent_ui/fluent_ui.dart';

class DropDownButton extends StatefulWidget {
  const DropDownButton({
    Key? key,
    required this.content,
    required this.dropdown,
    this.style,
    this.disabled = false,
    this.focusNode,
    this.startOpen = false,
    this.adoptDropdownWidth = true,
    this.horizontal = false,
    this.semanticsLabel,
    this.openWhen,
  }) : super(key: key);

  final ButtonStyle? style;

  final Widget content;
  final Widget? dropdown;
  final bool adoptDropdownWidth;
  final bool horizontal;
  final String? semanticsLabel;

  final bool disabled;
  final bool startOpen;
  final FocusNode? focusNode;

  final List<ButtonState>? openWhen;

  @override
  _DropDownButtonState createState() => _DropDownButtonState();
}

class _DropDownButtonState extends State<DropDownButton> {
  GlobalKey _key = LabeledGlobalKey(UniqueKey().toString());
  late Offset buttonPosition;
  late Size buttonSize;
  OverlayEntry? _overlayEntry;

  bool isOpen = false;
  bool get isClosed => !isOpen;

  @override
  void initState() {
    if (widget.startOpen)
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        open();
      });
    super.initState();
  }

  void findButton() {
    RenderBox renderBox = _key.currentContext!.findRenderObject() as RenderBox;
    buttonSize = renderBox.size;
    buttonPosition = renderBox.localToGlobal(Offset.zero);
  }

  void close() {
    if (isClosed) return;
    setState(() => _overlayEntry?.remove());
    _overlayEntry = null;
    isOpen = false;
  }

  void open() {
    if (isOpen) return;
    findButton();
    _overlayEntry = _overlayEntryBuilder();
    Overlay.of(context)!.insert(_overlayEntry!);
    isOpen = true;
  }

  void toggle() {
    if (isOpen)
      close();
    else
      open();
  }

  ButtonStyle style(BuildContext context) =>
      context.theme!.buttonStyle!.copyWith(widget.style!);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.style?.margin ?? EdgeInsets.zero,
      child: HoverButton(
        onPressed: widget.disabled ? null : toggle,
        builder: (c, states) {
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            final openWhen = widget.openWhen ??
                <ButtonStates>[
                  ButtonStates.hovering,
                  ButtonStates.pressing,
                ];
            if (openWhen.contains(states)) {
              open();
            } else {
              close();
            }
          });
          return Button(
            key: _key,
            focusNode: widget.focusNode,
            text: widget.content,
            style: (widget.style ?? Theme.of(context)!.buttonStyle)!
                .copyWith(ButtonStyle(margin: EdgeInsets.zero)),
            semanticsLabel: widget.semanticsLabel,
            onPressed: widget.disabled ? null : () {},
          );
        },
      ),
    );
  }

  OverlayEntry _overlayEntryBuilder() {
    return OverlayEntry(
      builder: (context) {
        final style = this.style(context);
        double? top, bottom, right, left, width;
        if (widget.adoptDropdownWidth) {
          width = buttonSize.width - (style.margin?.horizontal ?? 0);
        }

        if (widget.horizontal) {
          left = buttonPosition.dx + buttonSize.width;
          top = buttonPosition.dy + (style.margin?.vertical ?? 0) / 2;
        } else {
          top = buttonPosition.dy + buttonSize.height;
          left = buttonPosition.dx + (style.margin?.horizontal ?? 0) / 2;
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

class Dropdown extends StatefulWidget {
  const Dropdown({Key? key, required this.child}) : super(key: key);

  final Widget child;

  Dropdown.sections({
    Key? key,
    Widget? divider,
    required List<Widget> sectionTitles,
    required List<Widget> sectionBodies,
  })   : assert(sectionBodies.length == sectionTitles.length),
        child = Column(
          children: List.generate(sectionTitles.length, (index) {
            divider ??= Divider();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sectionTitles[index],
                sectionBodies[index],
                if (sectionTitles.length - 1 != index) divider!,
              ],
            );
          }),
        ),
        super(key: key);

  @override
  _DropdownState createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: controller,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, -0.1),
          end: Offset(0, 0.01),
        ).animate(controller),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white),
          child: PhysicalModel(
            color: Colors.black,
            elevation: 6,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
