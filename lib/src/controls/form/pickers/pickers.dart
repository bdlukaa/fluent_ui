import 'package:fluent_ui/fluent_ui.dart';

/// The padding used on the content of [DatePicker] and [TimePicker]
const kPickerContentPadding = EdgeInsetsDirectional.only(
  start: 8.0,
  top: 4.0,
  bottom: 4.0,
);

const kPickerHeight = 32.0;
const kPickerDiameterRatio = 100.0;

/// The default popup height
const double kPickerPopupHeight = kOneLineTileHeight * 10;

TextStyle? kPickerPopupTextStyle(BuildContext context, bool isSelected) {
  assert(debugCheckHasFluentTheme(context));
  final theme = FluentTheme.of(context);
  return theme.typography.body?.copyWith(
    // fontSize: 16,
    color: isSelected
        ? theme.resources.textOnAccentFillColorPrimary
        : theme.resources.textFillColorPrimary,
  );
}

Decoration kPickerDecorationBuilder(
  BuildContext context,
  Set<ButtonStates> states,
) {
  assert(debugCheckHasFluentTheme(context));
  final theme = FluentTheme.of(context);
  return BoxDecoration(
    borderRadius: BorderRadius.circular(4.0),
    color: ButtonThemeData.buttonColor(context, states),
    border: Border.all(
      width: 0.15,
      color: theme.inactiveColor.withOpacity(0.2),
    ),
  );
}

// ignore: non_constant_identifier_names
Widget PickerHighlightTile() {
  return Builder(builder: (context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final highlightTileColor = theme.accentColor.defaultBrushFor(
      theme.brightness,
    );
    return Positioned.fill(
      child: Container(
        alignment: Alignment.center,
        height: kOneLineTileHeight,
        padding: const EdgeInsets.all(6.0),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          tileColor: ButtonState.all(highlightTileColor),
        ),
      ),
    );
  });
}

/// A widget used by [TimePicker] and [DateTime] to accept or deny the changes
/// made in the pickers.
///
/// See also:
///
///  * [TimePicker]
///  * [DatePicker]
class YesNoPickerControl extends StatelessWidget {
  /// Creates a control with two choices:
  ///
  /// - continue
  /// - cancel
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

    ButtonStyle buttonStyle = ButtonStyle(
      elevation: ButtonState.all(0.0),
      backgroundColor: ButtonState.resolveWith(
        (states) => ButtonThemeData.uncheckedInputColor(
          FluentTheme.of(context),
          states,
        ),
      ),
      border: ButtonState.all(BorderSide.none),
    );

    return FocusTheme(
      data: const FocusThemeData(renderOutside: false),
      child: Row(children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(4.0),
            height: kOneLineTileHeight / 1.2,
            child: Button(
              onPressed: onChanged,
              style: buttonStyle,
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
              style: buttonStyle,
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
      focusEnabled: false,
      onPressed: () {},
      builder: (context, state) {
        final show = state.isHovering || state.isPressing || state.isFocused;
        return ButtonTheme.merge(
          data: ButtonThemeData.all(ButtonStyle(
            padding: ButtonState.all(const EdgeInsets.symmetric(
              vertical: 10.0,
            )),
            backgroundColor: ButtonState.all(FluentTheme.of(context).menuColor),
            border: ButtonState.all(BorderSide.none),
            elevation: ButtonState.all(0.0),
            iconSize: ButtonState.resolveWith((states) {
              if (states.isPressing) {
                return 8.0;
              } else {
                return 10.0;
              }
            }),
          )),
          child: FocusTheme(
            data: const FocusThemeData(renderOutside: false),
            child: Stack(children: [
              child,
              if (show) ...[
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: kOneLineTileHeight,
                  child: Button(
                    onPressed: onBackward,
                    child: const Center(
                      child: Icon(
                        FluentIcons.caret_up_solid8,
                        color: Color(0xFFcfcfcf),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: kOneLineTileHeight,
                  child: Button(
                    onPressed: onForward,
                    child: const Center(
                      child: Icon(
                        FluentIcons.caret_down_solid8,
                        color: Color(0xFFcfcfcf),
                      ),
                    ),
                  ),
                ),
              ],
            ]),
          ),
        );
      },
    );
  }
}

extension FixedExtentScrollControllerExtension on FixedExtentScrollController {
  Future<void> navigateSides(BuildContext context, bool forward, int amount) {
    assert(debugCheckHasFluentTheme(context));
    final duration = FluentTheme.of(context).fasterAnimationDuration;
    final curve = FluentTheme.of(context).animationCurve;
    if (forward) {
      final currentItem = selectedItem;
      int to = currentItem + 1;
      if (currentItem == amount - 1) to = 0;
      return animateToItem(
        to,
        duration: duration,
        curve: curve,
      );
    } else {
      final currentItem = selectedItem;
      int to = currentItem - 1;
      if (currentItem == 0) to = amount - 1;
      return animateToItem(
        to,
        duration: duration,
        curve: curve,
      );
    }
  }
}

typedef PickerBuilder = Widget Function(
  BuildContext context,
  Future<void> Function() open,
);

class Picker extends StatefulWidget {
  /// Creates a picker flyout
  const Picker({
    Key? key,
    required this.child,
    required this.pickerContent,
    required this.pickerHeight,
  }) : super(key: key);

  final PickerBuilder child;
  final WidgetBuilder pickerContent;
  final double pickerHeight;

  @override
  State<Picker> createState() => _PickerState();
}

class _PickerState extends State<Picker> {
  final GlobalKey _childKey = GlobalKey();

  Future<void> open() {
    assert(
      _childKey.currentContext != null,
      'The child must have been built at least once',
    );
    final box = _childKey.currentContext!.findRenderObject() as RenderBox;
    final childOffset = box.localToGlobal(Offset.zero);

    final navigator = Navigator.of(context);
    final isAcrylicDisabled = DisableAcrylic.of(context) != null;
    return navigator.push(PageRouteBuilder(
      barrierColor: Colors.transparent,
      opaque: false,
      barrierDismissible: true,
      fullscreenDialog: true,
      pageBuilder: (context, primary, __) {
        assert(debugCheckHasMediaQuery(context));
        assert(debugCheckHasFluentTheme(context));

        final screenHeight = MediaQuery.of(context).size.height;

        // centeredOffset is the y of the highlight tile. 0.41 is a eyeballed
        // value from the Win UI 3 Gallery
        final centeredOffset = widget.pickerHeight * 0.41;
        // the popup menu y is the [button y] - [y of highlight tile]
        double y = childOffset.dy - centeredOffset;

        // if the popup menu [y] + picker height overlaps the screen height, make
        // it to the bottom of the screen
        if (y + widget.pickerHeight > screenHeight) {
          y = screenHeight - widget.pickerHeight;
          // if the popup menu [y] is off screen on the top, make it to the top of
          // the screen
        } else if (y < 0) {
          y = 0;
        }

        final theme = FluentTheme.of(context);

        final view = Stack(children: [
          Positioned(
            left: childOffset.dx,
            top: y,
            height: widget.pickerHeight,
            width: box.size.width,
            child: FadeTransition(
              opacity: primary,
              child: Container(
                height: widget.pickerHeight,
                width: box.size.width,
                decoration: ShapeDecoration(
                  color: theme.menuColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    side: BorderSide(
                      color: theme.resources.surfaceStrokeColorFlyout,
                      width: 0.6,
                    ),
                  ),
                ),
                child: widget.pickerContent(context),
              ),
            ),
          ),
        ]);
        if (isAcrylicDisabled) return DisableAcrylic(child: view);
        return view;
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return KeyedSubtree(
      key: _childKey,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 296),
        child: DefaultTextStyle.merge(
          style: TextStyle(
            color: theme.resources.textFillColorPrimary,
          ),
          child: widget.child(context, open),
        ),
      ),
    );
  }
}
