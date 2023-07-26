import 'package:fluent_ui/fluent_ui.dart';

const EdgeInsetsGeometry _kDefaultPadding = EdgeInsetsDirectional.fromSTEB(
  20.0,
  6.0,
  6.0,
  6.0,
);

class FormRow extends StatelessWidget {
  const FormRow({
    super.key,
    required this.child,
    this.padding = _kDefaultPadding,
    this.helper,
    this.error,
    this.textStyle,
  });

  final EdgeInsetsGeometry padding;

  final TextStyle? textStyle;

  final Widget? helper;

  final Widget? error;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return Padding(
      padding: padding,
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Flexible(child: child),
        if (helper != null)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: DefaultTextStyle.merge(
              style: textStyle!,
              child: helper!,
            ),
          ),
        if (error != null)
          Container(
            margin: const EdgeInsetsDirectional.only(top: 2.0),
            alignment: AlignmentDirectional.centerStart,
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: Colors.red.defaultBrushFor(theme.brightness),
                fontWeight: FontWeight.w500,
              ),
              child: error!,
            ),
          ),
      ]),
    );
  }
}
