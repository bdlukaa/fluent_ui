<div align="center">
  <h1>fluent_ui</h1>
  <div>
    <a title="pub.dev" href="https://pub.dartlang.org/packages/fluent_ui" >
      <img src="https://img.shields.io/pub/v/fluent_ui.svg?style=flat-square&include_prereleases&color=dc143c" />
    </a>
    <a title="GitHub License" href="https://github.com/bdlukaa/fluent_ui/blob/master/LICENSE">
      <img src="https://img.shields.io/github/license/bdlukaa/fluent_ui?style=flat-square&color=f12253" />
    </a>
    <a title="Made with Windows Design" href="https://github.com/bdlukaa/fluent_ui">
      <img src="https://img.shields.io/badge/fluent-design-blue?style=flat-square&color=gray&labelColor=0078D7">
    </a>
    <a title="Web Example" href="https://bdlukaa.github.io/fluent_ui">
      <img src="https://img.shields.io/badge/documentation---?style=flat-square&color=e88d0c" />
    </a>
  </div>
  <div>
    <a title="Discord" href="https://discord.gg/674gpDQUVq">
      <img src="https://img.shields.io/discord/809528329337962516?style=flat-square&label=discord&color=7289da&logo=discord&logoColor=white" />
    </a>
    <a title="Patreon" href="https://www.patreon.com/bdlukaa">
      <img src="https://img.shields.io/badge/sponsor-Patreon-FF424D?style=flat-square" />
    </a>
  </div>
  <br/>
  <p>
  Design beautiful native Windows apps using <a href="https://flutter.dev">Flutter</a>
  </p>

  <p>
  Unofficial implementation of Windows UI for <a href="https://flutter.dev">Flutter</a>. It's written based on the <a href="https://learn.microsoft.com/en-us/windows/apps/develop/ui/controls/">official documentation</a>.
  </p>
  <h3>
  Read the <a href="https://bdlukaa.github.io/fluent_ui/">documentation</a>
  </h3>
</div>

<div align="center">
  <a href="https://bdlukaa.github.io/fluent_ui">
    <img src="https://raw.githubusercontent.com/bdlukaa/fluent_ui/master/images/example-showcase.png" />
  </a>
</div>

---

### Content

- [Motivation and maintenance](#motivation-and-maintenance)
- [Installation](#installation)
  - [Badge](#badge)
  - [Accent color](#accent-color)
- [Localization](#localization)
- [Contribution](#contribution)
  - [Contributing new localizations](#contributing-new-localizations)
  - [Acknowledgements](#acknowledgements)

## Motivation and maintenance

Since Flutter has stable Windows support, it's necessary to have support to its UI guidelines to build apps with fidelity, the same way it has support for Material and Cupertino.
See [this](https://github.com/flutter/flutter/issues/46481) for more info on the offical fluent ui support

See also:

- [Material UI for Flutter](https://flutter.dev/docs/development/ui/widgets/material)
- [Cupertino UI for Flutter](https://flutter.dev/docs/development/ui/widgets/cupertino)
- [MacOS UI for Flutter](https://github.com/GroovinChip/macos_ui)

---

This is an open-source package, which means that anyone can contribute to it. However, I, [bdlukaa](https://github.com/bdlukaa), am the only one actively maintaining it, so it may take some time to review and merge pull requests. If you want to support the project, you can [become a patron](https://www.patreon.com/bdlukaa):

<div align="center">
  <a title="Patreon" href="https://www.patreon.com/bdlukaa">
    <img src="https://img.shields.io/badge/sponsor-Patreon-FF424D?style=flat-square" />
  </a>
</div>

## Installation

Add the package to your dependencies:

```yaml
dependencies:
  fluent_ui: ^4.4.0
```

<p align="center">OR</p>

```yaml
dependencies:
  fluent_ui:
    git: https://github.com/bdlukaa/fluent_ui.git
```

Finally, run `dart pub get` to download the package.

Projects using this library should use the stable channel of Flutter

### Badge

Are you using this library on your app? You can use a badge to tell others:

<a title="Made with Windows Design" href="https://github.com/bdlukaa/fluent_ui">
  <img
    src="https://img.shields.io/badge/fluent-design-blue?style=flat-square&color=gray&labelColor=0078D7"
  >
</a>

Add the following code to your `README.md` or to your website:

```html
<a title="Made with Windows Design" href="https://github.com/bdlukaa/fluent_ui">
  <img
    src="https://img.shields.io/badge/fluent-design-blue?style=flat-square&color=gray&labelColor=0078D7"
  />
</a>
```

---

### Accent color

Common controls use an accent color to convey state information. [Learn more](https://docs.microsoft.com/en-us/windows/uwp/design/style/color#accent-color).

By default, the accent color is `Colors.blue`. However, you can also customize your app's accent color to reflect your brand:

```dart
FluentThemeData(
  accentColor: Colors.blue,
)
```

To use the system's accent color, you can use the plugin [system_theme](https://pub.dev/packages/system_theme) made by me :). It has support for (as of 21/01/2023) Android, Web, MacOS, Windows, Xbox and Linux (GTK 3+).

```dart
import 'package:system_theme/system_theme.dart';

FluentThemeData(
  accentColor: SystemTheme.accentColor.accent.toAccentColor(),
)
```

## Localization

FluentUI widgets currently supports out-of-the-box an wide number of languages, including:

- Arabic (@dmakwt)
- Bahasa Indonesia (@ekasetiawans)
- Belarusian (@superkeka)
- Czech (@morning4coffe-dev)
- Croatian (@ZeroMolecule)
- Dutch (@h3x4d3c1m4l)
- English
- French (@WinXaito)
- German (@larsb24)
- Greek (@pana-g)
- Hebrew (@yehudakremer)
- Hindi (@alexmercerind)
- Hungarian (@RedyAu)
- Italian (@patricknicolosi)
- Japanese (@chari8)
- Korean (@dubh3)
- Malay (@jonsaw)
- Nepali (@larence-cres)
- Persian (@xmine64)
- Polish (@madik7)
- Portuguese (@bdlukaa)
- Romanian (@antoniocranga)
- Russian (@raitonoberu)
- Simplified Chinese (@zacksleo, @rk0cc)
- Tagalog (@Yivan000)
- Tamil (@sarankumar-ns)
- Traditional Chinese (@zacksleo, @rk0cc)
- Thai (@lines-of-codes)
- Turkish (@timurturbil)
- Spanish (@henry2man)
- Ukranian (@vadimbarda)
- Urdu (@sherazahmad720)
- Uzbek (@bobobekturdiyev)

If a language is not supported, your app may crash. You can [add support for a new language](#contributing-new-localizations) or use a supported language. [Learn more](https://github.com/bdlukaa/fluent_ui/issues/371)

## Contribution

Feel free to [file an issue](https://github.com/bdlukaa/fluent_ui/issues/new) if you find a problem or [make pull requests](https://github.com/bdlukaa/fluent_ui/pulls).

All contributions are welcome :)

### Contributing new localizations

In [PR#216](https://github.com/bdlukaa/fluent_ui/pull/216) we added support for new localizations in FluentUI Widgets.

If you want to contribute adding new localizations please follow this steps:

- [Fork the repo](https://github.com/bdlukaa/fluent_ui/fork)
- Copy `lib/l10n/intl_en.arb` file into `lib/l10n` folder with a new language code, following [this list of ISO 859-1 codes](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)
- Update the contents in the newly created file. Specially, please update the `@locale` value with the corresponding ISO code.
- Run your project and code generation will take place or run command `flutter gen-l10n`
- When you're done, [make a new pull request](https://github.com/bdlukaa/fluent_ui/pulls)

More about [Localization in the Flutter Official Documentation](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)

### Acknowledgements

Irrespective of order, thanks to all the people below for contributing with the project. It means a lot to me :)

- [@HrX03](https://github.com/HrX03) for the `Acrylic`, `FluentIcons` generator and `_FluentTextSelectionControls` implementation.
- [@raitonubero](https://github.com/raitonoberu) `ProgressBar` and `ProgressRing` implementation
- [@alexmercerind](https://github.com/alexmercerind) for the [flutter_acrylic](https://github.com/alexmercerind/flutter_acrylic) plugin, used on the example app
- [@leanflutter](https://github.com/leanflutter) for the [window_manager](https://github.com/leanflutter/window_manager) plugin, used on the example app.
- [@henry2man](https://github.com/henry2man) for the [localization support](https://github.com/bdlukaa/fluent_ui/pull/216)
- [@klondikedragon](https://github.com/klondikedragon) for [`CommandBar` implementation](https://github.com/bdlukaa/fluent_ui/pull/232)
