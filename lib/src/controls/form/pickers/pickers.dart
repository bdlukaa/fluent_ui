import 'package:fluent_ui/fluent_ui.dart';

const kPickerContentPadding = EdgeInsets.symmetric(
  horizontal: 8.0,
  vertical: 4.0,
);

const kPickerHeight = 32.0;
const kPickerDiameterRatio = 100.0;

const kPopupHeight = kOneLineTileHeight * 10;

BoxDecoration kPickerBackgroundDecoration(BuildContext context) =>
    BoxDecoration(
      color: FluentTheme.of(context).acrylicBackgroundColor,
      borderRadius: BorderRadius.circular(4.0),
      border: Border.all(
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
  return BoxDecoration(
    borderRadius: BorderRadius.circular(4.0),
    border: Border.all(
      color: () {
        late Color color;
        if (states.isHovering) {
          color = FluentTheme.of(context).inactiveColor;
        } else if (states.isDisabled) {
          color = FluentTheme.of(context).disabledColor;
        } else {
          color = FluentTheme.of(context).inactiveColor.withOpacity(0.75);
        }
        return color;
      }(),
      width: 1.0,
    ),
    color: () {
      if (states.isPressing)
        return FluentTheme.of(context).disabledColor.withOpacity(0.2);
      else if (states.isFocused) {
        return FluentTheme.of(context).disabledColor.withOpacity(0.2);
      }
    }(),
  );
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

    ButtonThemeData style(BorderRadiusGeometry radius) {
      return ButtonThemeData(
        margin: EdgeInsets.zero,
        decoration: ButtonState.resolveWith((states) => BoxDecoration(
              color: ButtonThemeData.uncheckedInputColor(
                  FluentTheme.of(context), states),
              borderRadius: radius,
            )),
        scaleFactor: 1.0,
      );
    }

    return FocusTheme(
      data: FocusThemeData(renderOutside: false),
      child: Row(children: [
        Expanded(
          child: SizedBox(
            height: kOneLineTileHeight,
            child: Button(
              child: Icon(Icons.check),
              onPressed: onChanged,
              style: style(BorderRadius.only(
                bottomLeft: Radius.circular(4.0),
              )),
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: kOneLineTileHeight,
            child: Button(
              child: Icon(Icons.close),
              onPressed: onCancel,
              style: style(BorderRadius.only(
                bottomRight: Radius.circular(4.0),
              )),
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
          data: ButtonThemeData(
            padding: const EdgeInsets.all(2.0),
            margin: EdgeInsets.zero,
            scaleFactor: 1.0,
          ),
          child: FocusTheme(
            data: FocusThemeData(renderOutside: false),
            child: Stack(children: [
              child,
              if (show)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Button(
                    child:
                        Center(child: Icon(Icons.keyboard_arrow_up, size: 14)),
                    onPressed: onBackward,
                  ),
                ),
              if (show)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Button(
                    child: Center(
                        child: Icon(Icons.keyboard_arrow_down, size: 14)),
                    onPressed: onForward,
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
