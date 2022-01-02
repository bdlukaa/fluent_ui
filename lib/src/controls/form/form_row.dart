import 'package:fluent_ui/fluent_ui.dart';

const EdgeInsetsGeometry _kDefaultPadding =
    EdgeInsetsDirectional.fromSTEB(20.0, 6.0, 6.0, 6.0);

class FormRow extends StatelessWidget {
  const FormRow({
    Key? key,
    required this.child,
    this.prefix,
    this.padding,
    this.helper,
    this.error,
    this.textStyle,
  }) : super(key: key);

  final Widget? prefix;

  final EdgeInsetsGeometry? padding;

  final TextStyle? textStyle;

  final Widget? helper;

  final Widget? error;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? _kDefaultPadding,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              if (prefix != null)
                DefaultTextStyle(
                  style: textStyle!,
                  child: prefix!,
                ),
              Flexible(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: child,
                ),
              ),
            ],
          ),
          if (helper != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: DefaultTextStyle(
                style: textStyle!,
                child: helper!,
              ),
            ),
          if (error != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.warningPrimaryColor,
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
