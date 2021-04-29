import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// An info header lets the user know what an element of the ui
/// do as a short description of its functionality.
///
/// ![InfoHeader in a TextBox](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/text-box-ex1.png)
class InfoHeader extends StatelessWidget {
  /// Creates an info header.
  const InfoHeader({
    Key? key,
    this.child,
    required this.header,
    this.headerStyle,
  }) : super(key: key);

  /// The text of the header.
  final String header;

  /// The style of the text. If null, [Typography.body] is used
  final TextStyle? headerStyle;

  /// The widget to apply the header above of.
  final Widget? child;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('header', header));
    properties.add(DiagnosticsProperty('headerStyle', headerStyle));
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            header,
            style: headerStyle ?? context.maybeTheme?.typography.body,
          ),
        ),
        if (child != null) child!,
      ],
    );
  }
}
