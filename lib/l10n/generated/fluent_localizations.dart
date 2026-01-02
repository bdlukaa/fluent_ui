import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'fluent_localizations_ar.dart';
import 'fluent_localizations_be.dart';
import 'fluent_localizations_bn.dart';
import 'fluent_localizations_ca.dart';
import 'fluent_localizations_cs.dart';
import 'fluent_localizations_de.dart';
import 'fluent_localizations_el.dart';
import 'fluent_localizations_en.dart';
import 'fluent_localizations_es.dart';
import 'fluent_localizations_fa.dart';
import 'fluent_localizations_fr.dart';
import 'fluent_localizations_he.dart';
import 'fluent_localizations_hi.dart';
import 'fluent_localizations_hr.dart';
import 'fluent_localizations_hu.dart';
import 'fluent_localizations_id.dart';
import 'fluent_localizations_it.dart';
import 'fluent_localizations_ja.dart';
import 'fluent_localizations_ko.dart';
import 'fluent_localizations_ku.dart';
import 'fluent_localizations_ms.dart';
import 'fluent_localizations_my.dart';
import 'fluent_localizations_ne.dart';
import 'fluent_localizations_nl.dart';
import 'fluent_localizations_pl.dart';
import 'fluent_localizations_pt.dart';
import 'fluent_localizations_ro.dart';
import 'fluent_localizations_ru.dart';
import 'fluent_localizations_sk.dart';
import 'fluent_localizations_sv.dart';
import 'fluent_localizations_ta.dart';
import 'fluent_localizations_th.dart';
import 'fluent_localizations_tl.dart';
import 'fluent_localizations_tr.dart';
import 'fluent_localizations_ug.dart';
import 'fluent_localizations_uk.dart';
import 'fluent_localizations_ur.dart';
import 'fluent_localizations_uz.dart';
import 'fluent_localizations_vi.dart';
import 'fluent_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of FluentLocalizations
/// returned by `FluentLocalizations.of(context)`.
///
/// Applications need to include `FluentLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
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
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
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
    Locale('be'),
    Locale('bn'),
    Locale('ca'),
    Locale('cs'),
    Locale('de'),
    Locale('el'),
    Locale('es'),
    Locale('fa'),
    Locale('fr'),
    Locale('he'),
    Locale('hi'),
    Locale('hr'),
    Locale('hu'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('ku'),
    Locale('ms'),
    Locale('my'),
    Locale('ne'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('ro'),
    Locale('ru'),
    Locale('sk'),
    Locale('sv'),
    Locale('ta'),
    Locale('th'),
    Locale('tl'),
    Locale('tr'),
    Locale('ug'),
    Locale('uk'),
    Locale('ur'),
    Locale('uz'),
    Locale('vi'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
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

  /// The label for the undo button on the text selection controls.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoActionLabel;

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

  /// The tooltip for the undo action on the text selection controls.
  ///
  /// In en, this message translates to:
  /// **'Undo the last action'**
  String get undoActionTooltip;

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

  /// The text used by [CalendarDatePicker] to prompt the user to pick a date.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get pickADate;

  /// The text used by [CommandBar] to show more items.
  ///
  /// In en, this message translates to:
  /// **'See more'**
  String get seeMore;

  /// The text used by [CommandBar] to show less items.
  ///
  /// In en, this message translates to:
  /// **'See less'**
  String get seeLess;

  /// Label for red color component in color picker
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get redLabel;

  /// Label for green color component in color picker
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get greenLabel;

  /// Label for blue color component in color picker
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get blueLabel;

  /// Label for opacity component in color picker
  ///
  /// In en, this message translates to:
  /// **'Opacity'**
  String get opacityLabel;

  /// Label for hue component in color picker
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get hueLabel;

  /// Label for saturation component in color picker
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get saturationLabel;

  /// Label for value component in color picker
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get valueLabel;

  /// Text for expanding color picker options
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreText;

  /// Text for collapsing color picker options
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get lessText;

  /// No description provided for @valueSliderTooltip.
  ///
  /// In en, this message translates to:
  /// **'Value {value} ({colorName})'**
  String valueSliderTooltip(int value, String colorName);

  /// No description provided for @alphaSliderTooltip.
  ///
  /// In en, this message translates to:
  /// **'{value}% opacity'**
  String alphaSliderTooltip(int value);

  /// The name of the color, Black.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get colorBlack;

  /// The name of the color, Navy.
  ///
  /// In en, this message translates to:
  /// **'Dark blue'**
  String get colorNavy;

  /// The name of the color, Dark Blue.
  ///
  /// In en, this message translates to:
  /// **'Dark blue'**
  String get colorDarkBlue;

  /// The name of the color, Medium Blue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorMediumBlue;

  /// The name of the color, Blue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorBlue;

  /// The name of the color, Dark Green.
  ///
  /// In en, this message translates to:
  /// **'Dark green'**
  String get colorDarkGreen;

  /// The name of the color, Green.
  ///
  /// In en, this message translates to:
  /// **'Dark green'**
  String get colorGreen;

  /// The name of the color, Teal.
  ///
  /// In en, this message translates to:
  /// **'Dark teal'**
  String get colorTeal;

  /// The name of the color, Dark Cyan.
  ///
  /// In en, this message translates to:
  /// **'Dark teal'**
  String get colorDarkCyan;

  /// The name of the color, Deep Sky Blue.
  ///
  /// In en, this message translates to:
  /// **'Turquoise'**
  String get colorDeepSkyBlue;

  /// The name of the color, Dark Turquoise.
  ///
  /// In en, this message translates to:
  /// **'Aqua'**
  String get colorDarkTurquoise;

  /// The name of the color, Medium Spring Green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorMediumSpringGreen;

  /// The name of the color, Lime.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorLime;

  /// The name of the color, Spring Green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorSpringGreen;

  /// The name of the color, Cyan.
  ///
  /// In en, this message translates to:
  /// **'Aqua'**
  String get colorCyan;

  /// The name of the color, Midnight Blue.
  ///
  /// In en, this message translates to:
  /// **'Dark blue'**
  String get colorMidnightBlue;

  /// The name of the color, Dodger Blue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorDodgerBlue;

  /// The name of the color, Light Sea Green.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get colorLightSeaGreen;

  /// The name of the color, Forest Green.
  ///
  /// In en, this message translates to:
  /// **'Dark green'**
  String get colorForestGreen;

  /// The name of the color, Sea Green.
  ///
  /// In en, this message translates to:
  /// **'Dark green'**
  String get colorSeaGreen;

  /// The name of the color, Dark Slate Gray.
  ///
  /// In en, this message translates to:
  /// **'Dark teal'**
  String get colorDarkSlateGray;

  /// The name of the color, Lime Green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorLimeGreen;

  /// The name of the color, Medium Sea Green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorMediumSeaGreen;

  /// The name of the color, Turquoise.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get colorTurquoise;

  /// The name of the color, Royal Blue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorRoyalBlue;

  /// The name of the color, Steel Blue.
  ///
  /// In en, this message translates to:
  /// **'Blue-gray'**
  String get colorSteelBlue;

  /// The name of the color, Dark Slate Blue.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get colorDarkSlateBlue;

  /// The name of the color, Medium Turquoise.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get colorMediumTurquoise;

  /// The name of the color, Indigo.
  ///
  /// In en, this message translates to:
  /// **'Dark purple'**
  String get colorIndigo;

  /// The name of the color, Dark Olive Green.
  ///
  /// In en, this message translates to:
  /// **'Dark green'**
  String get colorDarkOliveGreen;

  /// The name of the color, Cadet Blue.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get colorCadetBlue;

  /// The name of the color, Cornflower Blue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorCornflowerBlue;

  /// The name of the color, Medium Aquamarine.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorMediumAquamarine;

  /// The name of the color, Dim Gray.
  ///
  /// In en, this message translates to:
  /// **'Gray'**
  String get colorDimGray;

  /// The name of the color, Slate Blue.
  ///
  /// In en, this message translates to:
  /// **'Indigo'**
  String get colorSlateBlue;

  /// The name of the color, Olive Drab.
  ///
  /// In en, this message translates to:
  /// **'Dark green'**
  String get colorOliveDrab;

  /// The name of the color, Slate Gray.
  ///
  /// In en, this message translates to:
  /// **'Blue-gray'**
  String get colorSlateGray;

  /// The name of the color, Light Slate Gray.
  ///
  /// In en, this message translates to:
  /// **'Blue-gray'**
  String get colorLightSlateGray;

  /// The name of the color, Medium Slate Blue.
  ///
  /// In en, this message translates to:
  /// **'Light blue'**
  String get colorMediumSlateBlue;

  /// The name of the color, Lawn Green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorLawnGreen;

  /// The name of the color, Chartreuse.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorChartreuse;

  /// The name of the color, Aquamarine.
  ///
  /// In en, this message translates to:
  /// **'Light green'**
  String get colorAquamarine;

  /// The name of the color, Maroon.
  ///
  /// In en, this message translates to:
  /// **'Dark red'**
  String get colorMaroon;

  /// The name of the color, Purple.
  ///
  /// In en, this message translates to:
  /// **'Dark purple'**
  String get colorPurple;

  /// The name of the color, Olive.
  ///
  /// In en, this message translates to:
  /// **'Dark yellow'**
  String get colorOlive;

  /// The name of the color, Gray.
  ///
  /// In en, this message translates to:
  /// **'Gray'**
  String get colorGray;

  /// The name of the color, Sky Blue.
  ///
  /// In en, this message translates to:
  /// **'Light turquoise'**
  String get colorSkyBlue;

  /// The name of the color, Light Sky Blue.
  ///
  /// In en, this message translates to:
  /// **'Light blue'**
  String get colorLightSkyBlue;

  /// The name of the color, Blue Violet.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get colorBlueViolet;

  /// The name of the color, Dark Red.
  ///
  /// In en, this message translates to:
  /// **'Dark red'**
  String get colorDarkRed;

  /// The name of the color, Dark Magenta.
  ///
  /// In en, this message translates to:
  /// **'Dark purple'**
  String get colorDarkMagenta;

  /// The name of the color, Saddle Brown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get colorSaddleBrown;

  /// The name of the color, Dark Sea Green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorDarkSeaGreen;

  /// The name of the color, Light Green.
  ///
  /// In en, this message translates to:
  /// **'Light green'**
  String get colorLightGreen;

  /// The name of the color, Medium Purple.
  ///
  /// In en, this message translates to:
  /// **'Lavender'**
  String get colorMediumPurple;

  /// The name of the color, Dark Violet.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get colorDarkViolet;

  /// The name of the color, Pale Green.
  ///
  /// In en, this message translates to:
  /// **'Light green'**
  String get colorPaleGreen;

  /// The name of the color, Dark Orchid.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get colorDarkOrchid;

  /// The name of the color, Yellow Green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorYellowGreen;

  /// The name of the color, Sienna.
  ///
  /// In en, this message translates to:
  /// **'Tan'**
  String get colorSienna;

  /// The name of the color, Brown.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorBrown;

  /// The name of the color, Dark Gray.
  ///
  /// In en, this message translates to:
  /// **'Gray'**
  String get colorDarkGray;

  /// The name of the color, Light Blue.
  ///
  /// In en, this message translates to:
  /// **'Sky blue'**
  String get colorLightBlue;

  /// The name of the color, Green Yellow.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreenYellow;

  /// The name of the color, Pale Turquoise.
  ///
  /// In en, this message translates to:
  /// **'Aqua'**
  String get colorPaleTurquoise;

  /// The name of the color, Light Steel Blue.
  ///
  /// In en, this message translates to:
  /// **'Ice blue'**
  String get colorLightSteelBlue;

  /// The name of the color, Powder Blue.
  ///
  /// In en, this message translates to:
  /// **'Sky blue'**
  String get colorPowderBlue;

  /// The name of the color, Firebrick.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorFirebrick;

  /// The name of the color, Dark Goldenrod.
  ///
  /// In en, this message translates to:
  /// **'Dark yellow'**
  String get colorDarkGoldenrod;

  /// The name of the color, Medium Orchid.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get colorMediumOrchid;

  /// The name of the color, Rosy Brown.
  ///
  /// In en, this message translates to:
  /// **'Coral'**
  String get colorRosyBrown;

  /// The name of the color, Dark Khaki.
  ///
  /// In en, this message translates to:
  /// **'Tan'**
  String get colorDarkKhaki;

  /// The name of the color, Silver.
  ///
  /// In en, this message translates to:
  /// **'Light gray'**
  String get colorSilver;

  /// The name of the color, Medium Violet Red.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colorMediumVioletRed;

  /// The name of the color, Indian Red.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorIndianRed;

  /// The name of the color, Peru.
  ///
  /// In en, this message translates to:
  /// **'Tan'**
  String get colorPeru;

  /// The name of the color, Chocolate.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get colorChocolate;

  /// The name of the color, Tan.
  ///
  /// In en, this message translates to:
  /// **'Tan'**
  String get colorTan;

  /// The name of the color, Light Gray.
  ///
  /// In en, this message translates to:
  /// **'Light gray'**
  String get colorLightGray;

  /// The name of the color, Thistle.
  ///
  /// In en, this message translates to:
  /// **'Lavender'**
  String get colorThistle;

  /// The name of the color, Orchid.
  ///
  /// In en, this message translates to:
  /// **'Lavender'**
  String get colorOrchid;

  /// The name of the color, Goldenrod.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get colorGoldenrod;

  /// The name of the color, Pale Violet Red.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get colorPaleVioletRed;

  /// The name of the color, Crimson.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorCrimson;

  /// The name of the color, Gainsboro.
  ///
  /// In en, this message translates to:
  /// **'Light gray'**
  String get colorGainsboro;

  /// The name of the color, Plum.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colorPlum;

  /// The name of the color, Burly Wood.
  ///
  /// In en, this message translates to:
  /// **'Tan'**
  String get colorBurlyWood;

  /// The name of the color, Light Cyan.
  ///
  /// In en, this message translates to:
  /// **'Sky blue'**
  String get colorLightCyan;

  /// The name of the color, Lavender.
  ///
  /// In en, this message translates to:
  /// **'Light blue'**
  String get colorLavender;

  /// The name of the color, Dark Salmon.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get colorDarkSalmon;

  /// The name of the color, Violet.
  ///
  /// In en, this message translates to:
  /// **'Lavender'**
  String get colorViolet;

  /// The name of the color, Pale Goldenrod.
  ///
  /// In en, this message translates to:
  /// **'Light yellow'**
  String get colorPaleGoldenrod;

  /// The name of the color, Light Coral.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get colorLightCoral;

  /// The name of the color, Khaki.
  ///
  /// In en, this message translates to:
  /// **'Light yellow'**
  String get colorKhaki;

  /// The name of the color, Alice Blue.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colorAliceBlue;

  /// The name of the color, Honeydew.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colorHoneydew;

  /// The name of the color, Azure.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colorAzure;

  /// The name of the color, Sandy Brown.
  ///
  /// In en, this message translates to:
  /// **'Light orange'**
  String get colorSandyBrown;

  /// The name of the color, Wheat.
  ///
  /// In en, this message translates to:
  /// **'Light yellow'**
  String get colorWheat;

  /// The name of the color, Beige.
  ///
  /// In en, this message translates to:
  /// **'Light yellow'**
  String get colorBeige;

  /// The name of the color, White Smoke.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colorWhiteSmoke;

  /// The name of the color, Mint Cream.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colorMintCream;

  /// The name of the color, Ghost White.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colorGhostWhite;

  /// The name of the color, Salmon.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get colorSalmon;

  /// The name of the color, Antique White.
  ///
  /// In en, this message translates to:
  /// **'Light orange'**
  String get colorAntiqueWhite;

  /// The name of the color, Linen.
  ///
  /// In en, this message translates to:
  /// **'Light orange'**
  String get colorLinen;

  /// The name of the color, Light Goldenrod Yellow.
  ///
  /// In en, this message translates to:
  /// **'Light yellow'**
  String get colorLightGoldenrodYellow;

  /// The name of the color, Old Lace.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colorOldLace;

  /// The name of the color, Red.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorRed;

  /// The name of the color, Magenta.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get colorMagenta;

  /// The name of the color, Deep Pink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colorDeepPink;

  /// The name of the color, Orange Red.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorOrangeRed;

  /// The name of the color, Tomato.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorTomato;

  /// The name of the color, Hot Pink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colorHotPink;

  /// The name of the color, Coral.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorCoral;

  /// The name of the color, Dark Orange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get colorDarkOrange;

  /// The name of the color, Light Salmon.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get colorLightSalmon;

  /// The name of the color, Orange.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get colorOrange;

  /// The name of the color, Light Pink.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get colorLightPink;

  /// The name of the color, Pink.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get colorPink;

  /// The name of the color, Gold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get colorGold;

  /// The name of the color, Peach Puff.
  ///
  /// In en, this message translates to:
  /// **'Light orange'**
  String get colorPeachPuff;

  /// The name of the color, Navajo White.
  ///
  /// In en, this message translates to:
  /// **'Light orange'**
  String get colorNavajoWhite;

  /// The name of the color, Moccasin.
  ///
  /// In en, this message translates to:
  /// **'Light orange'**
  String get colorMoccasin;

  /// The name of the color, Bisque.
  ///
  /// In en, this message translates to:
  /// **'Light orange'**
  String get colorBisque;

  /// The name of the color, Misty Rose.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get colorMistyRose;

  /// The name of the color, Blanched Almond.
  ///
  /// In en, this message translates to:
  /// **'Light orange'**
  String get colorBlanchedAlmond;

  /// The name of the color, Papaya Whip.
  ///
  /// In en, this message translates to:
  /// **'Light orange'**
  String get colorPapayaWhip;

  /// The name of the color, Lavender Blush.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colorLavenderBlush;

  /// The name of the color, Sea Shell.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colorSeaShell;

  /// The name of the color, Cornsilk.
  ///
  /// In en, this message translates to:
  /// **'Light yellow'**
  String get colorCornsilk;

  /// The name of the color, Lemon Chiffon.
  ///
  /// In en, this message translates to:
  /// **'Light yellow'**
  String get colorLemonChiffon;

  /// The name of the color, Floral White.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colorFloralWhite;

  /// The name of the color, Snow.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colorSnow;

  /// The name of the color, Yellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get colorYellow;

  /// The name of the color, Light Yellow.
  ///
  /// In en, this message translates to:
  /// **'Light yellow'**
  String get colorLightYellow;

  /// The name of the color, Ivory.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colorIvory;

  /// The name of the color, White.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colorWhite;
}

class _FluentLocalizationsDelegate
    extends LocalizationsDelegate<FluentLocalizations> {
  const _FluentLocalizationsDelegate();

  @override
  Future<FluentLocalizations> load(Locale locale) {
    return SynchronousFuture<FluentLocalizations>(
      lookupFluentLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'be',
    'bn',
    'ca',
    'cs',
    'de',
    'el',
    'en',
    'es',
    'fa',
    'fr',
    'he',
    'hi',
    'hr',
    'hu',
    'id',
    'it',
    'ja',
    'ko',
    'ku',
    'ms',
    'my',
    'ne',
    'nl',
    'pl',
    'pt',
    'ro',
    'ru',
    'sk',
    'sv',
    'ta',
    'th',
    'tl',
    'tr',
    'ug',
    'uk',
    'ur',
    'uz',
    'vi',
    'zh',
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
    case 'be':
      return FluentLocalizationsBe();
    case 'bn':
      return FluentLocalizationsBn();
    case 'ca':
      return FluentLocalizationsCa();
    case 'cs':
      return FluentLocalizationsCs();
    case 'de':
      return FluentLocalizationsDe();
    case 'el':
      return FluentLocalizationsEl();
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
    case 'hr':
      return FluentLocalizationsHr();
    case 'hu':
      return FluentLocalizationsHu();
    case 'id':
      return FluentLocalizationsId();
    case 'it':
      return FluentLocalizationsIt();
    case 'ja':
      return FluentLocalizationsJa();
    case 'ko':
      return FluentLocalizationsKo();
    case 'ku':
      return FluentLocalizationsKu();
    case 'ms':
      return FluentLocalizationsMs();
    case 'my':
      return FluentLocalizationsMy();
    case 'ne':
      return FluentLocalizationsNe();
    case 'nl':
      return FluentLocalizationsNl();
    case 'pl':
      return FluentLocalizationsPl();
    case 'pt':
      return FluentLocalizationsPt();
    case 'ro':
      return FluentLocalizationsRo();
    case 'ru':
      return FluentLocalizationsRu();
    case 'sk':
      return FluentLocalizationsSk();
    case 'sv':
      return FluentLocalizationsSv();
    case 'ta':
      return FluentLocalizationsTa();
    case 'th':
      return FluentLocalizationsTh();
    case 'tl':
      return FluentLocalizationsTl();
    case 'tr':
      return FluentLocalizationsTr();
    case 'ug':
      return FluentLocalizationsUg();
    case 'uk':
      return FluentLocalizationsUk();
    case 'ur':
      return FluentLocalizationsUr();
    case 'uz':
      return FluentLocalizationsUz();
    case 'vi':
      return FluentLocalizationsVi();
    case 'zh':
      return FluentLocalizationsZh();
  }

  throw FlutterError(
    'FluentLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
