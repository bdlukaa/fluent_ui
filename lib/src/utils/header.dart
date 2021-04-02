import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

class InfoHeader extends StatelessWidget {
  const InfoHeader({
    Key? key,
    this.child,
    required this.header,
    this.headerStyle,
  }) : super(key: key);

  final String header;
  final TextStyle? headerStyle;
  final Widget? child;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('header', header));
    properties.add(DiagnosticsProperty('headerStyle', headerStyle));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            header,
            style: headerStyle ?? context.theme.typography?.body,
          ),
        ),
        if (child != null) child!,
      ],
    );
  }
}
