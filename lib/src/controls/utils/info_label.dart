import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// An info label lets the user know what an element of the ui
/// do as a short description of its functionality. It can be
/// either rendered above its child or on the side of it.
///
/// ![InfoLabel above a TextBox](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/text-box-ex1.png)
///
/// See also:
///
///  * [Text], a widget for showing text.
class InfoLabel extends StatelessWidget {
  /// Creates an info label.
  InfoLabel({
    required String label,
    super.key,
    this.child,
    TextStyle? labelStyle,
    this.isHeader = true,
  }) : label = TextSpan(text: label, style: labelStyle);

  /// Creates an info label.
  const InfoLabel.rich({
    required this.label,
    super.key,
    this.child,
    this.isHeader = true,
  });

  /// The label to display.
  final InlineSpan label;

  /// The widget to apply the label.
  final Widget? child;

  /// Whether to render the [label] above [child] or on its side.
  final bool isHeader;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<InlineSpan>('label', label))
      ..add(FlagProperty('isHeader', value: isHeader, ifFalse: 'isSide'));
  }

  @override
  Widget build(BuildContext context) {
    final labelWidget = Text.rich(
      label,
      style: FluentTheme.maybeOf(context)?.typography.body,
    );
    return Flex(
      direction: isHeader ? Axis.vertical : Axis.horizontal,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isHeader
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        if (isHeader)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 4),
            child: labelWidget,
          ),
        if (child != null) Flexible(child: child!),
        if (!isHeader)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4),
            child: labelWidget,
          ),
      ],
    );
  }
}
