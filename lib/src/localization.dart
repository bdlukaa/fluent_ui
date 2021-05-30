import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// Defines the localized resource values used by the fluent widgets
///
/// See also:
///   * [DefaultFluentLocalizations], the default, English-only, implementation
///    of this interface.
abstract class FluentLocalizations {
  /// Label for "close" buttons and menu items.
  String get closeButtonLabel;

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
///    [DefaultFluentLocalizations.delegate] by default.
class DefaultFluentLocalizations implements FluentLocalizations {
  const DefaultFluentLocalizations();

  @override
  String get backButtonTooltip => 'Back';

  @override
  String get closeButtonLabel => 'Close';

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

  /// Creates an object that provides US English resource values for the material
  /// library widgets.
  ///
  /// The [locale] parameter is ignored.
  ///
  /// This method is typically used to create a [LocalizationsDelegate].
  /// The [MaterialApp] does so by default.
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
