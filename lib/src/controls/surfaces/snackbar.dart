import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

const Duration snackbarShortDuration = Duration(seconds: 2);
const Duration snackbarLongDuration = Duration(seconds: 2);

/// Shows a snackbar on the given context.
///
/// There must be an [Overlay] above in provided [context] tree, otherwise
/// an asserion error is thrown.
///
/// [duration] defaults to [snackbarShortDuration]. It's recommended
/// to use [snackbarLongDuration] for a extended snackbar duration. If null,
/// the snackbar will long forever, and have to be dismissed manually.
///
/// [alignment] is used to align the snackbar within the screen. Defaults
/// to [Alignment.bottomCenter]
///
/// [margin] is the margin applied to snackbar. Defaults to 16 logical
/// pixels on all sides
///
/// [onDismiss] is called when the snackbar is dismissed after [duration].
/// It's not called if dismissed manually.
///
/// To dismiss the snackbar manually, use the following code:
///
/// ```dart
/// final result = showSnackbar(context, snackbar);
/// result.remove();
/// ```
OverlayEntry showSnackbar(
  BuildContext context,
  Widget snackbar, {
  Duration? duration = snackbarShortDuration,
  Alignment alignment = Alignment.bottomCenter,
  EdgeInsetsGeometry margin = const EdgeInsets.all(16.0),
  VoidCallback? onDismiss,
}) {
  assert(debugCheckHasOverlay(context));
  final GlobalKey<SnackbarState> key = snackbar.key is GlobalKey<SnackbarState>
      ? snackbar.key as GlobalKey<SnackbarState>
      : GlobalKey<SnackbarState>();
  final entry = OverlayEntry(builder: (context) {
    if (snackbar is Snackbar) {
      return Padding(
        padding: margin,
        child: Align(
          alignment: alignment,
          child: Snackbar(
            key: key,
            content: snackbar.content,
            action: snackbar.action,
            extended: snackbar.extended,
          ),
        ),
      );
    }
    return Padding(
      padding: margin,
      child: Align(
        alignment: alignment,
        child: snackbar,
      ),
    );
  });
  Overlay.of(context)!.insert(entry);
  if (duration != null) {
    Future.delayed(duration).then((value) async {
      if (entry.mounted) {
        if (snackbar is Snackbar) await key.currentState?.controller.reverse();
      }
      if (entry.mounted) {
        entry.remove();
        onDismiss?.call();
      }
    });
  }
  return entry;
}

/// Snackbars provide a brief message about an operation at the
/// bottom of the screen. They can contain a custom action or
/// view or use a style geared towards making special announcements
/// to your users.
class Snackbar extends StatefulWidget {
  /// Creates a snackbar.
  const Snackbar({
    Key? key,
    required this.content,
    this.action,
    this.extended = false,
  }) : super(key: key);

  /// The content of the snackbar.
  ///
  /// Typically a [Text]
  final Widget content;

  /// The action of the snackbar.
  ///
  /// Typically a [Button]
  final Widget? action;

  /// Whether the snackbar should be extended or not.
  final bool extended;

  @override
  SnackbarState createState() => SnackbarState();
}

class SnackbarState extends State<Snackbar>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
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
    assert(debugCheckHasFluentTheme(context));
    final SnackbarThemeData theme = SnackbarTheme.of(context);
    final VisualDensity visualDensity = FluentTheme.of(context).visualDensity;
    return FadeTransition(
      opacity: controller,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300.0, minWidth: 32.0),
        decoration: theme.decoration,
        padding: theme.padding,
        child: DefaultTextStyle(
          style: TextStyle(color: theme.decoration?.color?.basedOnLuminance()),
          child: Flex(
            direction: widget.extended ? Axis.vertical : Axis.horizontal,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: widget.extended
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.center,
            children: [
              widget.content,
              if (widget.action != null)
                Padding(
                  padding: EdgeInsets.only(
                    left: widget.extended ? 0 : 16.0 + visualDensity.horizontal,
                    top: !widget.extended ? 0 : 8.0 + visualDensity.vertical,
                  ),
                  child: ButtonTheme.merge(
                    data: theme.actionStyle ?? const ButtonThemeData(),
                    child: widget.action!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// An inherited widget that defines the configuration for
/// [Snackbar]s in this widget's subtree.
///
/// Values specified here are used for [Snackbar] properties that are not
/// given an explicit non-null value.
class SnackbarTheme extends InheritedTheme {
  /// Creates a info bar theme that controls the configurations for
  /// [Snackbar].
  const SnackbarTheme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  /// The properties for descendant [Snackbar] widgets.
  final SnackbarThemeData data;

  /// Creates a button theme that controls how descendant [Snackbar]s should
  /// look like, and merges in the current toggle button theme, if any.
  static Widget merge({
    Key? key,
    required SnackbarThemeData data,
    required Widget child,
  }) {
    return Builder(builder: (BuildContext context) {
      return SnackbarTheme(
        key: key,
        data: _getInheritedThemeData(context).merge(data),
        child: child,
      );
    });
  }

  static SnackbarThemeData _getInheritedThemeData(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<SnackbarTheme>();
    return theme?.data ?? FluentTheme.of(context).snackbarTheme;
  }

  /// Returns the [data] from the closest [SnackbarTheme] ancestor. If there is
  /// no ancestor, it returns [ThemeData.snackbarTheme]. Applications can assume
  /// that the returned value will not be null.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// SnackbarThemeData theme = SnackbarTheme.of(context);
  /// ```
  static SnackbarThemeData of(BuildContext context) {
    return SnackbarThemeData.standard(FluentTheme.of(context)).merge(
      _getInheritedThemeData(context),
    );
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return SnackbarTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(SnackbarTheme oldWidget) => data != oldWidget.data;
}

class SnackbarThemeData with Diagnosticable {
  final BoxDecoration? decoration;
  final ButtonThemeData? actionStyle;
  final EdgeInsetsGeometry? padding;

  const SnackbarThemeData({
    this.decoration,
    this.actionStyle,
    this.padding,
  });

  factory SnackbarThemeData.standard(ThemeData style) {
    return SnackbarThemeData(
      padding: EdgeInsets.symmetric(
        vertical: 8.0 + style.visualDensity.vertical,
        horizontal: 16.0 + style.visualDensity.horizontal,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        color: style.brightness == Brightness.light
            ? Colors.black
            : const Color(0xFF212121),
      ),
    );
  }

  static SnackbarThemeData lerp(
    SnackbarThemeData? a,
    SnackbarThemeData? b,
    double t,
  ) {
    return SnackbarThemeData(
      actionStyle: ButtonThemeData.lerp(a?.actionStyle, b?.actionStyle, t),
      padding: EdgeInsetsGeometry.lerp(a?.padding, b?.padding, t),
      decoration: BoxDecoration.lerp(a?.decoration, b?.decoration, t),
    );
  }

  SnackbarThemeData merge(SnackbarThemeData? style) {
    if (style == null) return this;
    return SnackbarThemeData(
      actionStyle: style.actionStyle ?? actionStyle,
      padding: style.padding ?? padding,
      decoration: style.decoration ?? decoration,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ButtonThemeData>(
      'actionStyle',
      actionStyle,
      ifNull: 'no style',
    ));
    properties.add(DiagnosticsProperty('padding', padding));
    properties.add(DiagnosticsProperty('decoration', decoration));
  }
}
