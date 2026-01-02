import 'package:fluent_ui/fluent_ui.dart';

const EdgeInsetsGeometry _kDefaultPadding = EdgeInsetsDirectional.fromSTEB(
  20,
  6,
  6,
  6,
);

/// A row widget used in forms to display a child with optional helper and error text.
///
/// This widget wraps a form field and provides consistent padding and styling
/// for helper text and error messages.
class FormRow extends StatelessWidget {
  /// Creates a form row.
  const FormRow({
    required this.child,
    super.key,
    this.padding = _kDefaultPadding,
    this.helper,
    this.error,
    this.textStyle,
  });

  /// The padding around the form row.
  ///
  /// Defaults to [EdgeInsetsDirectional.fromSTEB(20, 6, 6, 6)].
  final EdgeInsetsGeometry padding;

  /// The text style for the helper text.
  final TextStyle? textStyle;

  /// The helper text displayed below the child.
  final Widget? helper;

  /// The error text displayed below the child in red.
  final Widget? error;

  /// The main content of the form row.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(child: child),
          if (helper != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: DefaultTextStyle.merge(style: textStyle, child: helper!),
            ),
          if (error != null)
            Container(
              margin: const EdgeInsetsDirectional.only(top: 2),
              alignment: AlignmentDirectional.centerStart,
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  color: Colors.red.defaultBrushFor(theme.brightness),
                  fontWeight: FontWeight.w500,
                ),
                child: error!,
              ),
            ),
        ],
      ),
    );
  }
}
