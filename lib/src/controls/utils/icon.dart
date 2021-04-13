import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/widgets.dart' as w;

/// A graphical icon widget drawn with a glyph from a font described in
/// an [IconData] such as the predefined [IconData]s in [Icons].
///
/// Icons are not interactive. For an interactive icon, consider using
/// [IconButton]
///
/// There must be an ambient [Directionality] widget when using [Icon].
/// Typically this is introduced automatically by the [WidgetsApp] or
/// [FluentApp].
///
/// This widget assumes that the rendered icon is squared. Non-squared icons may
/// render incorrectly.
class Icon extends StatelessWidget {
  /// Creates an icon.
  ///
  /// The [size] and [color] default to the given value by [Style.iconTheme]
  const Icon(
    this.icon, {
    Key? key,
    this.size,
    this.color,
    this.semanticLabel,
    this.textDirection,
  }) : super(key: key);

  /// The icon to display. The available icons are described in [Icons].
  ///
  /// The icon can be null, in which case the widget will render as an empty
  /// space of the specified [size].
  final IconData? icon;

  /// The size of the icon in logical pixels.
  ///
  /// Icons occupy a square with width and height equal to size.
  ///
  /// Defaults to the current [Style.iconTheme] size, if any. If there is no
  /// [Style.iconTheme], or it does not specify an explicit size, then it defaults to
  /// 22.0.
  final double? size;

  /// The color to use when drawing the icon.
  ///
  /// Defaults to the current [Style.color] color, if any.
  final Color? color;

  /// Semantic label for the icon.
  ///
  /// Announced in accessibility modes (e.g TalkBack/VoiceOver).
  /// This label does not show in the UI.
  ///
  ///  * [SemanticsProperties.label], which is set to [semanticLabel] in the
  ///    underlying	 [Semantics] widget.
  final String? semanticLabel;

  /// The text direction to use for rendering the icon.
  ///
  /// If this is null, the ambient [Directionality] is used instead.
  ///
  /// Some icons follow the reading direction. For example, "back" buttons point
  /// left in left-to-right environments and right in right-to-left
  /// environments. Such icons have their [IconData.matchTextDirection] field
  /// set to true, and the [Icon] widget uses the [textDirection] to determine
  /// the orientation in which to draw the icon.
  ///
  /// This property has no effect if the [icon]'s [IconData.matchTextDirection]
  /// field is false, but for consistency a text direction value must always be
  /// specified, either directly using this property or using [Directionality].
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme.iconStyle;
    return w.Icon(
      icon,
      size: size ?? style?.size ?? 22.0,
      color: color ?? style?.color ?? context.theme.inactiveColor,
      semanticLabel: semanticLabel,
      textDirection: textDirection,
    );
  }
}

class IconStyle with Diagnosticable {
  /// The color of the icon. If `null`, [Style.inactiveColor] is used
  final Color? color;

  /// The size of the icon. If `null`, 22 is used
  final double? size;

  const IconStyle({this.color, this.size});

  factory IconStyle.standard(Style style) {
    return IconStyle(
      size: 22.0,
      color: style.inactiveColor,
    );
  }

  IconStyle copyWith(IconStyle? style) {
    return IconStyle(
      color: style?.color ?? color,
      size: style?.size ?? size,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('color', color));
    properties.add(DoubleProperty('size', size, defaultValue: 22.0));
  }
}
