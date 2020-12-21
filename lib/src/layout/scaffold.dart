import 'package:fluent_ui/fluent_ui.dart';

class Scaffold extends StatelessWidget {
  const Scaffold({
    Key key,
    this.header,
    this.body,
    this.footer,
    this.backgroundColor,
    this.expandBody = true,
  })  : assert(expandBody != null),
        super(key: key);

  final Widget header;
  final Widget body;
  final Widget footer;

  final Color backgroundColor;

  /// Wheter the body expands. Set to false 
  final bool expandBody;

  @override
  Widget build(BuildContext context) {
    final color = backgroundColor ??
        context.theme?.scaffoldBackgroundColor ??
        Colors.white;
    return Container(
      color: color,
      child: Column(
        children: [
          if (header != null) header,
          if (body != null) Expanded(child: body),
          if (footer != null) footer,
        ],
      ),
    );
  }

}
