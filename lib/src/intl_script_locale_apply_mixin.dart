import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// Ensure `intl` package return correct format when applied [Locale.scriptCode].
///
/// It shoulde be implemented to [Diagnosticable] which required to uses `intl`
/// feature like `DateFormat`.
mixin IntlScriptLocaleApplyMixin on Diagnosticable {
  /// Return a default country code if [Locale] doesn't applied.
  static final Map<Locale, String> _defaultCountryCode = <Locale, String>{
    const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'): 'TW'
  };

  /// Get a [String] which recognizable for `intl` pakcage.
  ///
  /// It return `null` if no script code is specified in [Locale].
  String? getIntlLocale(BuildContext context) {
    assert(_defaultCountryCode.keys
        .every((element) => element.scriptCode != null));

    final locale = Localizations.localeOf(context);
    final noCountryLocale = Locale.fromSubtags(
        languageCode: locale.languageCode, scriptCode: locale.scriptCode);

    if (_defaultCountryCode.containsKey(noCountryLocale)) {
      return '${locale.languageCode}_${locale.countryCode ?? _defaultCountryCode[noCountryLocale]}';
    }

    return null;
  }
}
