import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// Defines the localized resource values used by the fluent widgets
///
/// See also:
///   * [DefaultFluentLocalizations], the default, English-only, implementation
///    of this interface.
abstract class FluentLocalizations {
  const FluentLocalizations._();

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

/// US English strings for the fluent widgets.
///
/// See also:
///
///  * [FluentApp.localizationsDelegates], which automatically includes
///  * [DefaultFluentLocalizations.delegate] by default.
class DefaultFluentLocalizations implements FluentLocalizations {
  const DefaultFluentLocalizations();

  @override
  String get backButtonTooltip => 'Back';

  @override
  String get closeButtonLabel => 'Close';

  @override
  String get searchLabel => 'Search';

  @override
  String get closeNavigationTooltip => 'Close Navigation';

  @override
  String get openNavigationTooltip => 'Open Navigation';

  @override
  String get clickToSearch => 'Click to search';

  @override
  String get modalBarrierDismissLabel => 'Dismiss';

  @override
  String get minimizeWindowTooltip => 'Minimze';

  @override
  String get restoreWindowTooltip => 'Restore';

  @override
  String get closeWindowTooltip => 'Close';

  @override
  String get dialogLabel => 'Dialog';

  @override
  String get cutActionLabel => 'Cut';

  @override
  String get copyActionLabel => 'Copy';

  @override
  String get pasteActionLabel => 'Paste';

  @override
  String get selectAllActionLabel => 'Select all';

  @override
  String get newTabLabel => 'Add new tab';

  @override
  String get closeTabLabel => 'Close tab (Ctrl+F4)';

  @override
  String get scrollTabBackwardLabel => 'Scroll tab list backward';

  @override
  String get scrollTabForwardLabel => 'Scroll tab list forward';

  @override
  String get noResultsFoundLabel => 'No results found';

  String get _ctrlCmd {
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      return 'Cmd';
    }
    return 'Ctrl';
  }

  @override
  String get cutShortcut => '$_ctrlCmd+X';

  @override
  String get copyShortcut => '$_ctrlCmd+C';

  @override
  String get pasteShortcut => '$_ctrlCmd+V';

  @override
  String get selectAllShortcut => '$_ctrlCmd+A';

  @override
  String get copyActionTooltip => 'Copy the selected content to the clipboard';

  @override
  String get cutActionTooltip =>
      'Remove the selected content and put it in the clipboard';

  @override
  String get pasteActionTooltip =>
      'Inserts the contents of the clipboard at the current location';

  @override
  String get selectAllActionTooltip => 'Select all content';

  /// Creates an object that provides US English resource values for the fluent
  /// library widgets.
  ///
  /// The [locale] parameter is ignored.
  ///
  /// This method is typically used to create a [LocalizationsDelegate].
  /// The [FluentApp] does so by default.
  static Future<FluentLocalizations> load(Locale locale) {
    return SynchronousFuture<FluentLocalizations>(
        const DefaultFluentLocalizations());
  }

  static const LocalizationsDelegate<FluentLocalizations> delegate =
      _FluentLocalizationsDelegate();
}

class _FluentLocalizationsDelegate
    extends LocalizationsDelegate<FluentLocalizations> {
  const _FluentLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<FluentLocalizations> load(Locale locale) =>
      DefaultFluentLocalizations.load(locale);

  @override
  bool shouldReload(_FluentLocalizationsDelegate old) => false;

  @override
  String toString() => 'DefaultFluentLocalizations.delegate(en_US)';
}
