/// Name-based fallback from [WindowsIcons] to [FluentIcons] for [WindowsIcon].
///
/// This library references every glyph of both icon fonts, so an app that
/// imports it keeps both fonts whole when icons are tree shaken. Passing
/// [WindowsIcon.fallbackIcon] keeps only the glyphs the app uses.
library;

import 'package:fluent_ui/fluent_ui.dart';

/// Returns the [FluentIcons] glyph that has the same name as the
/// [WindowsIcons] glyph [icon].
///
/// Returns null when [icon] is not a [WindowsIcons] glyph or no [FluentIcons]
/// glyph has its name. Use it for one icon:
///
/// ```dart
/// WindowsIcon(icon, fallbackIcon: fluentIconFallback(icon))
/// ```
///
/// or for every [WindowsIcon] built without a [WindowsIcon.fallbackIcon]:
///
/// ```dart
/// WindowsIcon.fallbackResolver = fluentIconFallback;
/// ```
IconData? fluentIconFallback(IconData icon) {
  for (final MapEntry(key: name, value: windowsIcon)
      in WindowsIcons.allIcons.entries) {
    if (windowsIcon == icon) return FluentIcons.allIcons[name];
  }
  return null;
}
