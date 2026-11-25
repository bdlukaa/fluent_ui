import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// Represents a Windows icon.
///
/// This widget is used to display icons that are part of the Windows icon set.
/// On Windows it renders [icon]. On other platforms it renders [fallbackIcon]
/// when one is given, otherwise the icon returned by [fallbackResolver], and
/// otherwise [icon] as given.
///
/// ```dart
/// const WindowsIcon(WindowsIcons.add, fallbackIcon: FluentIcons.add)
/// ```
///
/// See also:
///
///  * [Icon], which is the base class for all icon widgets.
///  * [WindowsIcons], which provides a collection of Windows icons.
///  * [FluentIcons], which is a collection of Fluent Design icons.
class WindowsIcon extends Icon {
  /// The icon rendered instead of [icon] on platforms other than Windows.
  final IconData? fallbackIcon;

  /// Resolves the icon rendered off Windows for a [WindowsIcon] built without
  /// a [fallbackIcon].
  ///
  /// Null by default, so such an icon renders [icon] as given. To substitute
  /// the [FluentIcons] glyph that has the same name as the [WindowsIcons]
  /// glyph, as earlier versions did implicitly, set it once before `runApp`:
  ///
  /// ```dart
  /// import 'package:fluent_ui/windows_icon_fallback.dart';
  ///
  /// WindowsIcon.fallbackResolver = fluentIconFallback;
  /// ```
  ///
  /// Name-based lookup references every glyph of both icon fonts, so the icon
  /// tree shaker keeps both fonts whole. Prefer passing [fallbackIcon].
  static IconData? Function(IconData icon)? fallbackResolver;

  static final Set<IconData> _debugUnresolvedIcons = {};

  /// Creates a windows icon.
  const WindowsIcon(
    super.icon, {
    super.key,
    this.fallbackIcon,
    super.size,
    super.applyTextScaling,
    super.blendMode,
    super.color,
    super.semanticLabel,
    super.textDirection,
    super.fill,
    super.grade,
    super.shadows,
    super.opticalSize,
    super.weight,
  });

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<IconData>('fallbackIcon', fallbackIcon));
  }

  IconData? _resolveIcon() {
    final icon = this.icon;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      return icon;
    }
    if (fallbackIcon != null || icon == null) return fallbackIcon ?? icon;
    final resolved = fallbackResolver?.call(icon);
    if (resolved != null) return resolved;
    assert(() {
      if (icon.fontFamily == 'SegoeIcons' &&
          icon.fontPackage == 'fluent_ui' &&
          _debugUnresolvedIcons.add(icon)) {
        debugPrint(
          'WindowsIcon(U+${icon.codePoint.toRadixString(16).toUpperCase()}) '
          'has no fallbackIcon and renders the Windows glyph on this '
          'platform. Pass fallbackIcon:, or set WindowsIcon.fallbackResolver '
          'from package:fluent_ui/windows_icon_fallback.dart.',
        );
      }
      return true;
    }());
    return icon;
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      _resolveIcon(),
      key: key,
      size: size,
      applyTextScaling: applyTextScaling,
      blendMode: blendMode,
      color: color,
      semanticLabel: semanticLabel,
      textDirection: textDirection,
      fill: fill,
      grade: grade,
      shadows: shadows,
      opticalSize: opticalSize,
      weight: weight,
    );
  }
}
