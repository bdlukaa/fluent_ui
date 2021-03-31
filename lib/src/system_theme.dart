import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

/// Platform channel handler for invoking native methods.
final MethodChannel channel = new MethodChannel('fluent_ui');

/// Class to return current system theme state on Windows.
///
/// [SystemTheme.darkMode] returns whether currently dark mode is enabled or not.
///
/// [SystemTheme.accentColor] returns the current accent color as [AccentColor].
///
class SystemTheme {
  static Future<bool> get darkMode async {
    return await channel.invokeMethod('SystemTheme.darkMode');
  }

  static AccentColor accent = new AccentColor();
}

/// Defines accent colors & its variants on Windows.
/// Colors are cached by default, call [AccentColor.refresh] to the updated colors.
///
class AccentColor {
  /// Base accent color.
  late Color accent;

  /// Light shade.
  late Color light;

  /// Lighter shade.
  late Color lighter;

  /// Lighest shade.
  late Color lightest;

  /// Darkest shade.
  late Color dark;

  /// Darker shade.
  late Color darker;

  /// Darkest shade.
  late Color darkest;

  AccentColor() {
    refresh();
  }

  /// Updates the fetched accent colors on Windows.
  Future<void> refresh() async {
    dynamic colors = await channel.invokeMethod('SystemTheme.accentColor');
    accent = _retrieve(colors['accent']);
    light = _retrieve(colors['light']);
    lighter = _retrieve(colors['lighter']);
    lightest = _retrieve(colors['lightest']);
    dark = _retrieve(colors['dark']);
    darker = _retrieve(colors['darker']);
    darkest = _retrieve(colors['darkest']);
  }

  Color _retrieve(dynamic map) {
    return Color.fromRGBO(
      map['R'],
      map['G'],
      map['B'],
      1.0,
    );
  }
}
