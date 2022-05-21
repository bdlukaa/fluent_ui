import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluent_ui/generated/l10n.dart';
import 'package:flutter/foundation.dart';

/// Defines the localized resource values used by the fluent widgets
///
/// See also:
///   * [DefaultFluentLocalizations], the default implementation
///    of this interface.
abstract class FluentLocalizations {
  FluentLocalizations._();

  /// Label for "close" buttons and menu items.
  String get closeButtonLabel;

  /// Label for "search" text fields.
  String get searchLabel;

  /// The tooltip for the back button on [NavigationAppBar].
  String get backButtonTooltip;

  /// The tooltip for the toggle navigation button.
  String get closeNavigationTooltip;

  /// The tooltip for the toogle navigation button.
  String get openNavigationTooltip;

  /// The tooltip for the "Click to Search" button.
  String get clickToSearch;

  /// Label read out by accessibility tools (TalkBack or VoiceOver) for a modal
  /// barrier to indicate that a tap dismisses the barrier.
  ///
  /// A modal barrier can for example be found behind an alert or popup to block
  /// user interaction with elements behind it.
  String get modalBarrierDismissLabel;

  /// The tooltip used by the "Minimize" button on desktop windows.
  String get minimizeWindowTooltip;

  /// The tooltip used by the "Restore" button on desktop windows.
  String get restoreWindowTooltip;

  /// The tooltip used by the "Close" button on desktop windows.
  String get closeWindowTooltip;

  /// The dialog label
  String get dialogLabel;

  /// The label used by [TabView]'s new button
  String get newTabLabel;

  /// The label used by [TabView]'s close button
  String get closeTabLabel;

  /// The label used by [TabView]'s scroll backward button
  String get scrollTabBackwardLabel;

  /// The label used by [TabView]'s scroll forward button
  String get scrollTabForwardLabel;

  /// The label used by [AutoSuggestBox] when the results can't be found
  String get noResultsFoundLabel;

  /// The label for the cut action on the text selection controls
  String get cutActionLabel;

  /// The cut shortcut label used by text selection controls
  String get cutShortcut;

  /// The tooltip for the cut action on the text selection controls
  String get cutActionTooltip;

  /// The label for the copy action on the text selection controls
  String get copyActionLabel;

  /// The copy shortcut label used by text selection controls
  String get copyShortcut;

  /// The tooltip for the copy action on the text selection controls
  String get copyActionTooltip;

  /// The label for the paste button on the text selection controls
  String get pasteActionLabel;

  /// The paste shortcut label used by text selection controls
  String get pasteShortcut;

  /// The tooltip for the paste action on the text selection controls
  String get pasteActionTooltip;

  /// The label for the select all button on the text selection controls
  String get selectAllActionLabel;

  /// The select all shortcut label used by text selection controls
  String get selectAllShortcut;

  /// The tooltip for the select all action on the text selection controls
  String get selectAllActionTooltip;

  /// The `FluentLocalizations` from the closest [Localizations] instance
  /// that encloses the given context.
  ///
  /// If no [FluentLocalizations] are available in the given `context`, this
  /// method throws an exception.
  ///
  /// This method is just a convenient shorthand for:
  /// `Localizations.of<FluentLocalizations>(context, FluentLocalizations)!`.
  ///
  /// References to the localized resources defined by this class are typically
  /// written in terms of this method. For example:
  ///
  /// ```dart
  /// tooltip: FluentLocalizations.of(context).backButtonTooltip,
  /// ```
  static FluentLocalizations of(BuildContext context) {
    assert(debugCheckHasFluentLocalizations(context));
    return Localizations.of<FluentLocalizations>(context, FluentLocalizations)!;
  }
}

// List of supported locales. This MUST be on sync with available intl_xx.arb
// files in lib/l10n folder
//
// NOTE: This should be INTO DefaultFluentLocalizations as an static member but,
// for some strange reason, doing so results in a very strange compile error.
// This has been the only way to get it working without errors.

// I tried to replace this with S.delegate.supportedLocales, but doing this
// din't let me set the default value in FluentApp.supportedLocales
const List<Locale> defaultSupportedLocales = <Locale>[
  Locale('ar'),
  Locale('de'),
  Locale('en'),
  Locale('es'),
  Locale('fa'),
  Locale('fr'),
  Locale('hi'),
  Locale('it'),
  Locale('nl'),
  Locale('pt'),
  Locale('ru'),
  Locale('zh'),
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
];

/// Strings for the fluent widgets.
///
/// See also:
///
///  * [FluentApp.localizationsDelegates], which automatically includes
///  * [DefaultFluentLocalizations.delegate] by default.
class DefaultFluentLocalizations extends S implements FluentLocalizations {
  final Locale locale;

  DefaultFluentLocalizations._defaultFluentLocalizations(this.locale) {
    S.load(locale);
  }

  static bool supports(Locale locale) {
    return S.delegate.supportedLocales.contains(locale);
  }

  // Special cases - Those that include operating system dependent messages

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
  @override
  String get closeTabLabel {
    return '${super.closeTabLabelSuffix} ($_ctrlCmd+$_closeTabCmd)';
  }

  @override
  String get cutShortcut => '$_ctrlCmd+X';

  @override
  String get copyShortcut => '$_ctrlCmd+C';

  @override
  String get pasteShortcut => '$_ctrlCmd+V';

  @override
  String get selectAllShortcut => '$_ctrlCmd+A';

  /// Creates an object that provides localized resource values for the fluent
  /// library widgets.
  ///
  /// This method is typically used to create a [LocalizationsDelegate].
  /// The [FluentApp] does so by default.
  static Future<FluentLocalizations> load(Locale locale) {
    return SynchronousFuture<FluentLocalizations>(
        DefaultFluentLocalizations._defaultFluentLocalizations(locale));
  }

  static const LocalizationsDelegate<FluentLocalizations> delegate =
      _FluentLocalizationsDelegate();
}

class _FluentLocalizationsDelegate
    extends LocalizationsDelegate<FluentLocalizations> {
  const _FluentLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return DefaultFluentLocalizations.supports(locale);
  }

  @override
  Future<FluentLocalizations> load(Locale locale) {
    return DefaultFluentLocalizations.load(locale);
  }

  @override
  bool shouldReload(_FluentLocalizationsDelegate old) => false;

  @override
  String toString() => 'DefaultMaterialLocalizations.delegate(en_US)';
}
