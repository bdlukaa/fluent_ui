import 'package:fluent_ui/l10n/generated/fluent_localizations.dart';
import 'package:flutter/foundation.dart';

// Special cases - Those that include operating system dependent messages
extension FluentLocalizationsExtension on FluentLocalizations {
  String get _ctrlCmd {
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      return 'Cmd';
    }
    return 'Ctrl';
  }

  String get _closeTabCmd {
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      return 'W';
    }
    return 'F4';
  }

  // Close tab => <Message> (<shortcut>)
  /// The label used by [TabView]'s close button.
  String get closeTabLabel {
    return '$closeTabLabelSuffix ($_ctrlCmd+$_closeTabCmd)';
  }

  /// The cut shortcut label used by text selection controls.
  String get cutShortcut => '$_ctrlCmd+X';

  /// The copy shortcut label used by text selection controls.
  String get copyShortcut => '$_ctrlCmd+C';

  /// The paste shortcut label used by text selection controls.
  String get pasteShortcut => '$_ctrlCmd+V';

  /// The select all shortcut label used by text selection controls.
  String get selectAllShortcut => '$_ctrlCmd+A';

  /// The select all shortcut label used by text selection controls.
  String get undoShortcut => '$_ctrlCmd+Z';

  /// Returns DisplayName of the color
  ///
  /// This method checks if the provided `colorKey` starts with 'color'.
  /// If not, it will prepend 'color' to the key and attempt to fetch the corresponding color display name
  /// from the available localization resources.
  ///
  /// Example:
  /// ```dart
  /// final localizations = FluentLocalizations.of(context);
  /// final colorName = localizations.getLocalizedColorDisplayName('DarkBlue');
  /// // This will return the localized name for Dark Blue.
  /// ```
  ///
  /// [colorKey] is the key for the color whose localized name is to be fetched.
  /// The key should either already start with 'color' or will be automatically prefixed with 'color'
  /// if it does not. The method expects the color key to be in Pascal case (e.g., 'DarkGreen', 'LightBlue', 'RoyalBlue').
  /// The method will return an empty string if the color key is not recognized.
  ///
  /// Throws [ArgumentError] if the colorKey is null or empty.
  String getColorDisplayName(String colorKey) {
    if (colorKey.isEmpty) {
      throw ArgumentError('Color key cannot be null or empty');
    }

    if (!colorKey.startsWith('color')) {
      colorKey = 'color$colorKey';
    }

    return switch (colorKey) {
      'colorBlack' => colorBlack,
      'colorNavy' => colorNavy,
      'colorDarkBlue' => colorDarkBlue,
      'colorMediumBlue' => colorMediumBlue,
      'colorBlue' => colorBlue,
      'colorDarkGreen' => colorDarkGreen,
      'colorGreen' => colorGreen,
      'colorTeal' => colorTeal,
      'colorDarkCyan' => colorDarkCyan,
      'colorDeepSkyBlue' => colorDeepSkyBlue,
      'colorDarkTurquoise' => colorDarkTurquoise,
      'colorMediumSpringGreen' => colorMediumSpringGreen,
      'colorLime' => colorLime,
      'colorSpringGreen' => colorSpringGreen,
      'colorCyan' => colorCyan,
      'colorMidnightBlue' => colorMidnightBlue,
      'colorDodgerBlue' => colorDodgerBlue,
      'colorLightSeaGreen' => colorLightSeaGreen,
      'colorForestGreen' => colorForestGreen,
      'colorSeaGreen' => colorSeaGreen,
      'colorDarkSlateGray' => colorDarkSlateGray,
      'colorLimeGreen' => colorLimeGreen,
      'colorMediumSeaGreen' => colorMediumSeaGreen,
      'colorTurquoise' => colorTurquoise,
      'colorRoyalBlue' => colorRoyalBlue,
      'colorSteelBlue' => colorSteelBlue,
      'colorDarkSlateBlue' => colorDarkSlateBlue,
      'colorMediumTurquoise' => colorMediumTurquoise,
      'colorIndigo' => colorIndigo,
      'colorDarkOliveGreen' => colorDarkOliveGreen,
      'colorCadetBlue' => colorCadetBlue,
      'colorCornflowerBlue' => colorCornflowerBlue,
      'colorMediumAquamarine' => colorMediumAquamarine,
      'colorDimGray' => colorDimGray,
      'colorSlateBlue' => colorSlateBlue,
      'colorOliveDrab' => colorOliveDrab,
      'colorSlateGray' => colorSlateGray,
      'colorLightSlateGray' => colorLightSlateGray,
      'colorMediumSlateBlue' => colorMediumSlateBlue,
      'colorLawnGreen' => colorLawnGreen,
      'colorChartreuse' => colorChartreuse,
      'colorAquamarine' => colorAquamarine,
      'colorMaroon' => colorMaroon,
      'colorPurple' => colorPurple,
      'colorOlive' => colorOlive,
      'colorGray' => colorGray,
      'colorSkyBlue' => colorSkyBlue,
      'colorLightSkyBlue' => colorLightSkyBlue,
      'colorBlueViolet' => colorBlueViolet,
      'colorDarkRed' => colorDarkRed,
      'colorDarkMagenta' => colorDarkMagenta,
      'colorSaddleBrown' => colorSaddleBrown,
      'colorDarkSeaGreen' => colorDarkSeaGreen,
      'colorLightGreen' => colorLightGreen,
      'colorMediumPurple' => colorMediumPurple,
      'colorDarkViolet' => colorDarkViolet,
      'colorPaleGreen' => colorPaleGreen,
      'colorDarkOrchid' => colorDarkOrchid,
      'colorYellowGreen' => colorYellowGreen,
      'colorSienna' => colorSienna,
      'colorBrown' => colorBrown,
      'colorDarkGray' => colorDarkGray,
      'colorLightBlue' => colorLightBlue,
      'colorGreenYellow' => colorGreenYellow,
      'colorPaleTurquoise' => colorPaleTurquoise,
      'colorLightSteelBlue' => colorLightSteelBlue,
      'colorPowderBlue' => colorPowderBlue,
      'colorFirebrick' => colorFirebrick,
      'colorDarkGoldenrod' => colorDarkGoldenrod,
      'colorMediumOrchid' => colorMediumOrchid,
      'colorRosyBrown' => colorRosyBrown,
      'colorDarkKhaki' => colorDarkKhaki,
      'colorSilver' => colorSilver,
      'colorMediumVioletRed' => colorMediumVioletRed,
      'colorIndianRed' => colorIndianRed,
      'colorPeru' => colorPeru,
      'colorChocolate' => colorChocolate,
      'colorTan' => colorTan,
      'colorLightGray' => colorLightGray,
      'colorThistle' => colorThistle,
      'colorOrchid' => colorOrchid,
      'colorGoldenrod' => colorGoldenrod,
      'colorPaleVioletRed' => colorPaleVioletRed,
      'colorCrimson' => colorCrimson,
      'colorGainsboro' => colorGainsboro,
      'colorPlum' => colorPlum,
      'colorBurlyWood' => colorBurlyWood,
      'colorLightCyan' => colorLightCyan,
      'colorLavender' => colorLavender,
      'colorDarkSalmon' => colorDarkSalmon,
      'colorViolet' => colorViolet,
      'colorPaleGoldenrod' => colorPaleGoldenrod,
      'colorLightCoral' => colorLightCoral,
      'colorKhaki' => colorKhaki,
      'colorAliceBlue' => colorAliceBlue,
      'colorHoneydew' => colorHoneydew,
      'colorAzure' => colorAzure,
      'colorSandyBrown' => colorSandyBrown,
      'colorWheat' => colorWheat,
      'colorBeige' => colorBeige,
      'colorWhiteSmoke' => colorWhiteSmoke,
      'colorMintCream' => colorMintCream,
      'colorGhostWhite' => colorGhostWhite,
      'colorSalmon' => colorSalmon,
      'colorAntiqueWhite' => colorAntiqueWhite,
      'colorLinen' => colorLinen,
      'colorLightGoldenrodYellow' => colorLightGoldenrodYellow,
      'colorOldLace' => colorOldLace,
      'colorRed' => colorRed,
      'colorMagenta' => colorMagenta,
      'colorDeepPink' => colorDeepPink,
      'colorOrangeRed' => colorOrangeRed,
      'colorTomato' => colorTomato,
      'colorHotPink' => colorHotPink,
      'colorCoral' => colorCoral,
      'colorDarkOrange' => colorDarkOrange,
      'colorLightSalmon' => colorLightSalmon,
      'colorOrange' => colorOrange,
      'colorLightPink' => colorLightPink,
      'colorPink' => colorPink,
      'colorGold' => colorGold,
      'colorPeachPuff' => colorPeachPuff,
      'colorNavajoWhite' => colorNavajoWhite,
      'colorMoccasin' => colorMoccasin,
      'colorBisque' => colorBisque,
      'colorMistyRose' => colorMistyRose,
      'colorBlanchedAlmond' => colorBlanchedAlmond,
      'colorPapayaWhip' => colorPapayaWhip,
      'colorLavenderBlush' => colorLavenderBlush,
      'colorSeaShell' => colorSeaShell,
      'colorCornsilk' => colorCornsilk,
      'colorLemonChiffon' => colorLemonChiffon,
      'colorFloralWhite' => colorFloralWhite,
      'colorSnow' => colorSnow,
      'colorYellow' => colorYellow,
      'colorLightYellow' => colorLightYellow,
      'colorIvory' => colorIvory,
      'colorWhite' => colorWhite,
      _ => throw ArgumentError('Invalid color key: $colorKey'),
    };
  }
}
