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
}
