// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Back`
  String get backButtonTooltip {
    return Intl.message(
      'Back',
      name: 'backButtonTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get closeButtonLabel {
    return Intl.message(
      'Close',
      name: 'closeButtonLabel',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get searchLabel {
    return Intl.message(
      'Search',
      name: 'searchLabel',
      desc: '',
      args: [],
    );
  }

  /// `Close Navigation`
  String get closeNavigationTooltip {
    return Intl.message(
      'Close Navigation',
      name: 'closeNavigationTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Open Navigation`
  String get openNavigationTooltip {
    return Intl.message(
      'Open Navigation',
      name: 'openNavigationTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Click to search`
  String get clickToSearch {
    return Intl.message(
      'Click to search',
      name: 'clickToSearch',
      desc: '',
      args: [],
    );
  }

  /// `Dismiss`
  String get modalBarrierDismissLabel {
    return Intl.message(
      'Dismiss',
      name: 'modalBarrierDismissLabel',
      desc: '',
      args: [],
    );
  }

  /// `Minimize`
  String get minimizeWindowTooltip {
    return Intl.message(
      'Minimize',
      name: 'minimizeWindowTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Restore`
  String get restoreWindowTooltip {
    return Intl.message(
      'Restore',
      name: 'restoreWindowTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get closeWindowTooltip {
    return Intl.message(
      'Close',
      name: 'closeWindowTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Dialog`
  String get dialogLabel {
    return Intl.message(
      'Dialog',
      name: 'dialogLabel',
      desc: '',
      args: [],
    );
  }

  /// `Cut`
  String get cutActionLabel {
    return Intl.message(
      'Cut',
      name: 'cutActionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get copyActionLabel {
    return Intl.message(
      'Copy',
      name: 'copyActionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Paste`
  String get pasteActionLabel {
    return Intl.message(
      'Paste',
      name: 'pasteActionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Select all`
  String get selectAllActionLabel {
    return Intl.message(
      'Select all',
      name: 'selectAllActionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Add new tab`
  String get newTabLabel {
    return Intl.message(
      'Add new tab',
      name: 'newTabLabel',
      desc: '',
      args: [],
    );
  }

  /// `Close tab`
  String get closeTabLabelSuffix {
    return Intl.message(
      'Close tab',
      name: 'closeTabLabelSuffix',
      desc: '',
      args: [],
    );
  }

  /// `Scroll tab list backward`
  String get scrollTabBackwardLabel {
    return Intl.message(
      'Scroll tab list backward',
      name: 'scrollTabBackwardLabel',
      desc: '',
      args: [],
    );
  }

  /// `Scroll tab list forward`
  String get scrollTabForwardLabel {
    return Intl.message(
      'Scroll tab list forward',
      name: 'scrollTabForwardLabel',
      desc: '',
      args: [],
    );
  }

  /// `No results found`
  String get noResultsFoundLabel {
    return Intl.message(
      'No results found',
      name: 'noResultsFoundLabel',
      desc: '',
      args: [],
    );
  }

  /// `Copy the selected content to the clipboard`
  String get copyActionTooltip {
    return Intl.message(
      'Copy the selected content to the clipboard',
      name: 'copyActionTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Remove the selected content and put it in the clipboard`
  String get cutActionTooltip {
    return Intl.message(
      'Remove the selected content and put it in the clipboard',
      name: 'cutActionTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Inserts the contents of the clipboard at the current location`
  String get pasteActionTooltip {
    return Intl.message(
      'Inserts the contents of the clipboard at the current location',
      name: 'pasteActionTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Select all content`
  String get selectAllActionTooltip {
    return Intl.message(
      'Select all content',
      name: 'selectAllActionTooltip',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'fa'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'hi'),
      Locale.fromSubtags(languageCode: 'it'),
      Locale.fromSubtags(languageCode: 'nl'),
      Locale.fromSubtags(languageCode: 'pt'),
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'zh'),
      Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
