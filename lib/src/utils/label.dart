import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// An info label lets the user know what an element of the ui
/// do as a short description of its functionality. It can be
/// either rendered above its child or on the side of it.
///
/// ![InfoLabel above a TextBox](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/text-box-ex1.png)
class InfoLabel extends StatelessWidget {
  /// Creates an info label.
  const InfoLabel({
    Key? key,
    this.child,
    required this.label,
    this.labelStyle,
    this.isHeader = true,
  }) : super(key: key);

  /// The text of the label. It'll be styled acorrding to
  /// [labelStyle]. If this is empty, a blank space will
  /// be rendered.
  final String label;

  /// The style of the text. If null, [Typography.body] is used
  final TextStyle? labelStyle;

  /// The widget to apply the label.
  final Widget? child;

  /// Whether to render [header] above [child] or on the side of it.
  final bool isHeader;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('label', label));
    properties.add(DiagnosticsProperty<TextStyle>('labelStyle', labelStyle));
  }

  @override
  Widget build(BuildContext context) {
    final labelWidget = Text(
      label,
      style: labelStyle ?? FluentTheme.maybeOf(context)?.typography.body,
    );
    return Flex(
      direction: isHeader ? Axis.vertical : Axis.horizontal,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          isHeader ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        if (isHeader)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: labelWidget,
          ),
        if (child != null) child!,
        if (!isHeader)
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: labelWidget,
          ),
      ],
    );
  }
}
