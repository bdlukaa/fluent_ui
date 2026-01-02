import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// Represents a Windows icon.
///
/// This widget is used to display icons that are part of the Windows icon set.
/// These icons can only be used in a Windows environment and are not available
/// on other platforms. This widget will automatically resolve the icon to the
/// appropriate icon based on the current platform.
///
/// See also:
///
///  * [Icon], which is the base class for all icon widgets.
///  * [WindowsIcons], which provides a collection of Windows icons.
///  * [FluentIcons], which is a collection of Fluent Design icons.
class WindowsIcon extends Icon {
  /// An optional fallback icon to use if the specified icon is not available
  /// in the current context.
  final IconData? fallbackIcon;

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
  Widget build(BuildContext context) {
    final resolvedIcon = () {
      final isWindows =
          !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

      if (isWindows) {
        return icon;
      } else if (fallbackIcon != null) {
        return fallbackIcon;
      } else {
        final iconId = WindowsIcons.allIcons.entries.firstWhereOrNull((entry) {
          return entry.value == icon;
        });

        if (iconId == null) {
          return icon;
        }

        final fallbackIcon = FluentIcons.allIcons.entries.firstWhereOrNull((
          entry,
        ) {
          return entry.key == iconId.key || entry.value == iconId.value;
        });

        if (fallbackIcon != null) {
          return fallbackIcon.value;
        } else {
          debugPrint(
            'The icon ${iconId.key} is not available in the current context. '
            'Please provide a fallback icon or use a different icon.',
          );
          return icon;
        }
      }
    }();

    return Icon(
      resolvedIcon,
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

extension _Iterable<T> on Iterable<T> {
  /// Returns the first element of the iterable that satisfies the given [test].
  ///
  /// If no element satisfies the test, returns `null`.
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
