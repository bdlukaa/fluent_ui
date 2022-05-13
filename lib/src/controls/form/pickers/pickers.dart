import 'package:fluent_ui/fluent_ui.dart';

const kPickerContentPadding = EdgeInsets.symmetric(
  horizontal: 8.0,
  vertical: 4.0,
);

const kPickerHeight = 32.0;
const kPickerDiameterRatio = 100.0;

const kPopupHeight = kOneLineTileHeight * 10;

Color kPickerBackgroundColor(BuildContext context) =>
    FluentTheme.of(context).menuColor;

ShapeBorder kPickerShape(BuildContext context) => RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4.0),
      side: BorderSide(
        color: FluentTheme.of(context).scaffoldBackgroundColor,
        width: 0.6,
      ),
    );

TextStyle? kPickerPopupTextStyle(BuildContext context) {
  return FluentTheme.of(context).typography.body?.copyWith(fontSize: 16);
}

Decoration kPickerDecorationBuilder(
    BuildContext context, Set<ButtonStates> states) {
  assert(debugCheckHasFluentTheme(context));
  final theme = FluentTheme.of(context);
  return BoxDecoration(
    borderRadius: BorderRadius.circular(4.0),
    color: ButtonThemeData.buttonColor(theme.brightness, states),
  );
}

Widget kHighlightTile() {
  return Builder(builder: (context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final highlightTileColor =
        theme.accentColor.resolveFromBrightness(theme.brightness);
    return Positioned(
      top: 0,
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        alignment: Alignment.center,
        height: kOneLineTileHeight,
        padding: const EdgeInsets.all(6.0),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          tileColor: highlightTileColor,
        ),
      ),
    );
  });
}

class YesNoPickerControl extends StatelessWidget {
  const YesNoPickerControl({
    Key? key,
    required this.onChanged,
    required this.onCancel,
  }) : super(key: key);

  final VoidCallback onChanged;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));

    ButtonStyle style() {
      return ButtonStyle(
        backgroundColor: ButtonState.resolveWith(
          (states) => ButtonThemeData.uncheckedInputColor(
            FluentTheme.of(context),
            states,
          ),
        ),
        border: ButtonState.all(BorderSide.none),
      );
    }

    return FocusTheme(
      data: const FocusThemeData(renderOutside: false),
      child: Row(children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(4.0),
            height: kOneLineTileHeight / 1.2,
            child: Button(
              onPressed: onChanged,
              style: style(),
              child: const Icon(FluentIcons.check_mark),
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(4.0),
            height: kOneLineTileHeight / 1.2,
            child: Button(
              onPressed: onCancel,
              style: style(),
              child: const Icon(FluentIcons.chrome_close),
            ),
          ),
        ),
      ]),
    );
  }
}

class PickerNavigatorIndicator extends StatelessWidget {
  const PickerNavigatorIndicator({
    Key? key,
    required this.child,
    required this.onBackward,
    required this.onForward,
  }) : super(key: key);

  final Widget child;
  final VoidCallback onForward;
  final VoidCallback onBackward;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return HoverButton(
      onPressed: () {},
      builder: (context, state) {
        final show = state.isHovering || state.isPressing || state.isFocused;
        return ButtonTheme.merge(
          data: ButtonThemeData.all(ButtonStyle(
            padding: ButtonState.all(const EdgeInsets.all(2.0)),
            backgroundColor: ButtonState.all(kPickerBackgroundColor(context)),
            border: ButtonState.all(BorderSide.none),
          )),
          child: FocusTheme(
            data: const FocusThemeData(renderOutside: false),
            child: Stack(children: [
              child,
              if (show)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: kOneLineTileHeight,
                  child: Button(
                    onPressed: onBackward,
                    child: const Center(
                      child: Icon(FluentIcons.chevron_up, size: 12),
                    ),
                  ),
                ),
              if (show)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: kOneLineTileHeight,
                  child: Button(
                    onPressed: onForward,
                    child: const Center(
                      child: Icon(FluentIcons.chevron_down, size: 12),
                    ),
                  ),
                ),
            ]),
          ),
        );
      },
    );
  }
}

void navigateSides(
  BuildContext context,
  FixedExtentScrollController controller,
  bool forward,
  int amount,
) {
  assert(debugCheckHasFluentTheme(context));
  final duration = FluentTheme.of(context).fasterAnimationDuration;
  final curve = FluentTheme.of(context).animationCurve;
  if (forward) {
    final currentItem = controller.selectedItem;
    int to = currentItem + 1;
    if (currentItem == amount - 1) to = 0;
    controller.animateToItem(
      to,
      duration: duration,
      curve: curve,
    );
  } else {
    final currentItem = controller.selectedItem;
    int to = currentItem - 1;
    if (currentItem == 0) to = amount - 1;
    controller.animateToItem(
      to,
      duration: duration,
      curve: curve,
    );
  }
}
