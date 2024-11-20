import 'dart:math';

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
    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
  );
}

Decoration kPickerDecorationBuilder(
  BuildContext context,
  Set<WidgetState> states,
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
        alignment: AlignmentDirectional.center,
        height: kOneLineTileHeight,
        padding: const EdgeInsetsDirectional.symmetric(
          vertical: 6.0,
          horizontal: 2.0,
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          tileColor: WidgetStatePropertyAll(highlightTileColor),
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
    super.key,
    required this.onChanged,
    required this.onCancel,
  });

  final VoidCallback onChanged;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));

    final buttonStyle = ButtonStyle(
      elevation: const WidgetStatePropertyAll(0.0),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => ButtonThemeData.uncheckedInputColor(
          FluentTheme.of(context),
          states,
        ),
      ),
      shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
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

/// A helper widget that creates fluent-styled controls for a list
///
/// See also:
///
///  * [TimePicker], which uses this to control its popup's lists
///  * [DatePicker], which uses this to control its popup's lists
class PickerNavigatorIndicator extends StatelessWidget {
  /// Creates a picker navigator indicator
  const PickerNavigatorIndicator({
    super.key,
    required this.child,
    required this.onBackward,
    required this.onForward,
  });

  /// The content of the widget.
  ///
  /// THe indicators will be rendered above this
  final Widget child;

  /// Called when the forward button is pressed
  ///
  /// If null, no forward button is shown
  final VoidCallback onForward;

  /// Called when the backward button is pressed
  ///
  /// If null, no backward button is shown
  final VoidCallback onBackward;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));

    return HoverButton(
      customActions: {
        DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(
          onInvoke: (intent) {
            switch (intent.direction) {
              case TraversalDirection.up:
                onBackward();
                break;
              case TraversalDirection.down:
                onForward();
                break;
              case TraversalDirection.left:
                FocusScope.of(context).previousFocus();
                break;
              case TraversalDirection.right:
                FocusScope.of(context).nextFocus();
                break;
            }
            return null;
          },
        ),
      },
      forceEnabled: true,
      hitTestBehavior: HitTestBehavior.translucent,
      builder: (context, states) {
        final show = states.isHovered || states.isPressed || states.isFocused;
        return FocusBorder(
          focused: states.isFocused,
          child: ButtonTheme.merge(
            data: ButtonThemeData.all(ButtonStyle(
              padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(
                vertical: 10.0,
              )),
              backgroundColor:
                  WidgetStatePropertyAll(FluentTheme.of(context).menuColor),
              shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
              elevation: const WidgetStatePropertyAll(0.0),
              iconSize: WidgetStateProperty.resolveWith((states) {
                if (states.isPressed) {
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
                  PositionedDirectional(
                    top: 0,
                    start: 0,
                    end: 0,
                    height: kOneLineTileHeight,
                    child: Button(
                      focusable: false,
                      onPressed: onBackward,
                      child: const Center(
                        child: Icon(
                          FluentIcons.caret_up_solid8,
                          color: Color(0xFFcfcfcf),
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    bottom: 0,
                    start: 0,
                    end: 0,
                    height: kOneLineTileHeight,
                    child: Button(
                      focusable: false,
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
          ),
        );
      },
    );
  }
}

extension FixedExtentScrollControllerExtension on FixedExtentScrollController {
  /// Navigates a fixed-extent list into a specific direction
  Future<void> navigateSides(
    BuildContext context,
    bool forward,
    int amount, {
    Duration? duration,
    Curve? curve,
  }) {
    assert(debugCheckHasFluentTheme(context));
    duration ??= FluentTheme.of(context).fasterAnimationDuration;
    curve ??= FluentTheme.of(context).animationCurve;

    if (forward) {
      final currentItem = selectedItem;
      var to = currentItem + 1;
      if (currentItem == amount - 1) to = 0;

      return animateToItem(
        to,
        duration: duration,
        curve: curve,
      );
    } else {
      final currentItem = selectedItem;
      var to = currentItem - 1;
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
    super.key,
    required this.child,
    required this.pickerContent,
    required this.pickerHeight,
  });

  final PickerBuilder child;
  final WidgetBuilder pickerContent;
  final double pickerHeight;

  @override
  State<Picker> createState() => _PickerState();
}

class _PickerState extends State<Picker> {
  late final GlobalKey _childKey = GlobalKey(debugLabel: '${widget.child} key');

  Future<void> open() {
    assert(
      _childKey.currentContext != null,
      'The child must have been built at least once',
    );

    final navigator = Navigator.of(context);

    final box = _childKey.currentContext!.findRenderObject() as RenderBox;
    final childOffset = box.localToGlobal(
      Offset.zero,
      ancestor: navigator.context.findRenderObject(),
    );

    final rootBox = navigator.context.findRenderObject() as RenderBox;

    final isAcrylicDisabled = DisableAcrylic.of(context) != null;

    return navigator.push(PageRouteBuilder(
      barrierColor: Colors.transparent,
      opaque: false,
      barrierDismissible: true,
      fullscreenDialog: true,
      pageBuilder: (context, primary, __) {
        assert(debugCheckHasFluentTheme(context));
        assert(debugCheckHasMediaQuery(context));

        final rootHeight = rootBox.size.height;

        // centeredOffset is the y of the highlight tile. 0.41 is a eyeballed
        // value from the Win UI 3 Gallery
        final centeredOffset = widget.pickerHeight * 0.41;
        // the popup menu y is the [button y] - [y of highlight tile]
        var y = childOffset.dy - centeredOffset;

        // if the popup menu [y] + picker height overlaps the screen height, make
        // it to the bottom of the screen
        if (y + widget.pickerHeight > rootHeight) {
          const bottomMargin = 8.0;
          y = rootHeight - widget.pickerHeight - bottomMargin;
          // y = 0;
          // if the popup menu [y] is off screen on the top, make it to the top of
          // the screen
        } else if (y < 0) {
          y = 0;
        }

        y = y.clamp(0.0, rootHeight);

        final theme = FluentTheme.of(context);

        // If the screen is smaller than 260, we ensure the popup will fit in the
        // screen. https://github.com/bdlukaa/fluent_ui/issues/544
        final minWidth = min(260.0, MediaQuery.sizeOf(context).width);
        final width = max(box.size.width, minWidth);
        final x = () {
          if (box.size.width > minWidth) return childOffset.dx;

          // if the box width is less than [minWidth], center the popup
          return childOffset.dx - (width / 4);
        }();

        final view = Stack(children: [
          // We can not use PositionedDirectional here
          // See https://github.com/bdlukaa/fluent_ui/issues/675
          Positioned(
            left: x,
            top: y,
            height: widget.pickerHeight,
            width: width,
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
