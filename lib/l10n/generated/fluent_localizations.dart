import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'fluent_localizations_ar.dart';
import 'fluent_localizations_cs.dart';
import 'fluent_localizations_de.dart';
import 'fluent_localizations_en.dart';
import 'fluent_localizations_es.dart';
import 'fluent_localizations_fa.dart';
import 'fluent_localizations_fr.dart';
import 'fluent_localizations_he.dart';
import 'fluent_localizations_hi.dart';
import 'fluent_localizations_hu.dart';
import 'fluent_localizations_it.dart';
import 'fluent_localizations_ja.dart';
import 'fluent_localizations_ko.dart';
import 'fluent_localizations_ms.dart';
import 'fluent_localizations_nl.dart';
import 'fluent_localizations_pl.dart';
import 'fluent_localizations_pt.dart';
import 'fluent_localizations_ru.dart';
import 'fluent_localizations_tr.dart';
import 'fluent_localizations_zh.dart';

/// Callers can lookup localized strings with an instance of FluentLocalizations returned
/// by `FluentLocalizations.of(context)`.
///
/// Applications need to include `FluentLocalizations.delegate()` in their app's
/// localizationDelegates list, and the locales they support in the app's
/// supportedLocales list. For example:
///
/// ```
/// import 'generated/fluent_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: FluentLocalizations.localizationsDelegates,
///   supportedLocales: FluentLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the FluentLocalizations.supportedLocales
/// property.
abstract class FluentLocalizations {
  FluentLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static FluentLocalizations of(BuildContext context) {
    return Localizations.of<FluentLocalizations>(context, FluentLocalizations)!;
  }

  static const LocalizationsDelegate<FluentLocalizations> delegate =
      _FluentLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
    Locale('cs'),
    Locale('de'),
    Locale('es'),
    Locale('fa'),
    Locale('fr'),
    Locale('he'),
    Locale('hi'),
    Locale('hu'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('ms'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
  ];

  /// The tooltip for the back button on [NavigationAppBar].
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButtonTooltip;

  /// Label for "close" buttons and menu items.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButtonLabel;

  /// Label for "search" text fields.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchLabel;

  /// The tooltip for the toggle navigation button.
  ///
  /// In en, this message translates to:
  /// **'Close Navigation'**
  String get closeNavigationTooltip;

  /// The tooltip for the toogle navigation button.
  ///
  /// In en, this message translates to:
  /// **'Open Navigation'**
  String get openNavigationTooltip;

  /// The tooltip for the "Click to Search" button.
  ///
  /// In en, this message translates to:
  /// **'Click to search'**
  String get clickToSearch;

  /// Label read out by accessibility tools (TalkBack or VoiceOver) for a modal barrier to indicate that a tap dismisses the barrier. A modal barrier can for example be found behind an alert or popup to block user interaction with elements behind it.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get modalBarrierDismissLabel;

  /// The tooltip used by the "Minimize" button on desktop windows.
  ///
  /// In en, this message translates to:
  /// **'Minimize'**
  String get minimizeWindowTooltip;

  /// The tooltip used by the "Restore" button on desktop windows.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreWindowTooltip;

  /// The tooltip used by the "Close" button on desktop windows.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeWindowTooltip;

  /// The dialog label.
  ///
  /// In en, this message translates to:
  /// **'Dialog'**
  String get dialogLabel;

  /// The label for the cut action on the text selection controls.
  ///
  /// In en, this message translates to:
  /// **'Cut'**
  String get cutActionLabel;

  /// The label for the copy action on the text selection controls.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyActionLabel;

  /// The label for the paste button on the text selection controls.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get pasteActionLabel;

  /// The label for the select all button on the text selection controls.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAllActionLabel;

  /// The label used by [TabView]'s new button.
  ///
  /// In en, this message translates to:
  /// **'Add new tab'**
  String get newTabLabel;

  /// The label used by [TabView]'s close button.
  ///
  /// In en, this message translates to:
  /// **'Close tab'**
  String get closeTabLabelSuffix;

  /// The label used by [TabView]'s scroll backward button.
  ///
  /// In en, this message translates to:
  /// **'Scroll tab list backward'**
  String get scrollTabBackwardLabel;

  /// The label used by [TabView]'s scroll forward button.
  ///
  /// In en, this message translates to:
  /// **'Scroll tab list forward'**
  String get scrollTabForwardLabel;

  /// The label used by [AutoSuggestBox] when the results can't be found.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFoundLabel;

  /// The tooltip for the copy action on the text selection controls.
  ///
  /// In en, this message translates to:
  /// **'Copy the selected content to the clipboard'**
  String get copyActionTooltip;

  /// The tooltip for the cut action on the text selection controls.
  ///
  /// In en, this message translates to:
  /// **'Remove the selected content and put it in the clipboard'**
  String get cutActionTooltip;

  /// The tooltip for the paste action on the text selection controls.
  ///
  /// In en, this message translates to:
  /// **'Inserts the contents of the clipboard at the current location'**
  String get pasteActionTooltip;

  /// The tooltip for the select all action on the text selection controls.
  ///
  /// In en, this message translates to:
  /// **'Select all content'**
  String get selectAllActionTooltip;

  /// The text used by [TimePicker] for the hour field.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hour;

  /// The text used by [TimePicker] for the minute field.
  ///
  /// In en, this message translates to:
  /// **'minute'**
  String get minute;

  /// The text used by [TimePicker] for the AM field.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get am;

  /// The text used by [TimePicker] for the PM field.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get pm;

  /// The text used by [DatePicker] for the month field
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get month;

  /// The text used by [DatePicker] for the day field
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// The text used by [DatePicker] for the year field
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get year;
}

class _FluentLocalizationsDelegate
    extends LocalizationsDelegate<FluentLocalizations> {
  const _FluentLocalizationsDelegate();

  @override
  Future<FluentLocalizations> load(Locale locale) {
    return SynchronousFuture<FluentLocalizations>(
        lookupFluentLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'cs',
        'de',
        'en',
        'es',
        'fa',
        'fr',
        'he',
        'hi',
        'hu',
        'it',
        'ja',
        'ko',
        'ms',
        'nl',
        'pl',
        'pt',
        'ru',
        'tr',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_FluentLocalizationsDelegate old) => false;
}

FluentLocalizations lookupFluentLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return FluentLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return FluentLocalizationsAr();
    case 'cs':
      return FluentLocalizationsCs();
    case 'de':
      return FluentLocalizationsDe();
    case 'en':
      return FluentLocalizationsEn();
    case 'es':
      return FluentLocalizationsEs();
    case 'fa':
      return FluentLocalizationsFa();
    case 'fr':
      return FluentLocalizationsFr();
    case 'he':
      return FluentLocalizationsHe();
    case 'hi':
      return FluentLocalizationsHi();
    case 'hu':
      return FluentLocalizationsHu();
    case 'it':
      return FluentLocalizationsIt();
    case 'ja':
      return FluentLocalizationsJa();
    case 'ko':
      return FluentLocalizationsKo();
    case 'ms':
      return FluentLocalizationsMs();
    case 'nl':
      return FluentLocalizationsNl();
    case 'pl':
      return FluentLocalizationsPl();
    case 'pt':
      return FluentLocalizationsPt();
    case 'ru':
      return FluentLocalizationsRu();
    case 'tr':
      return FluentLocalizationsTr();
    case 'zh':
      return FluentLocalizationsZh();
  }

  throw FlutterError(
      'FluentLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
