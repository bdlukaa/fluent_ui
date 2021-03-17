<div>
  <h1 align="center">fluent_ui</h1>
  <p align="center" >
    <a title="Discord" href="https://discord.gg/674gpDQUVq">
      <img src="https://img.shields.io/discord/809528329337962516?label=discord&logo=discord" />
    </a>
    <a title="Pub" href="https://pub.dartlang.org/packages/fluent_ui" >
      <img src="https://img.shields.io/pub/v/fluent_ui.svg?style=popout&include_prereleases" />
    </a>
    <a title="Github License">
      <img src="https://img.shields.io/github/license/bdlukaa/fluent_ui" />
    </a>
    <a title="PRs are welcome">
      <img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" />
    </a>
  </p>
  <p align="center">
    <a title="Buy me a coffee" href="https://www.buymeacoffee.com/bdlukaa">
      <img src="https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&emoji=&slug=bdlukaa&button_colour=FF5F5F&font_colour=ffffff&font_family=Lato&outline_colour=000000&coffee_colour=FFDD00">
    </a>
  </p>
  <p align="center">
  Design beautiful native windows apps using Flutter
  </p>
</div>

Unofficial implementation of Fluent UI for [Flutter](flutter.dev). It's written based on the [official documentation](https://docs.microsoft.com/en-us/windows/uwp/design/)

## Motivation

Since flutter has Windows support (currently in stable under an early release flag as of 11/03/2021), it's necessary to have support to its UI guidelines to build apps with fidelity, since it has support for Material and Cupertino.
See [this](https://github.com/flutter/flutter/issues/46481) for more info on the offical fluent ui support

See also:

- [Material UI for Flutter](https://flutter.dev/docs/development/ui/widgets/material)
- [Cupertino UI for Flutter](https://flutter.dev/docs/development/ui/widgets/cupertino)

### Roadmap

Currently, we've only done the desktop part of the library, so you can import the library as one itself:

```dart
import 'package:fluent_ui/fluent_ui';
```

Note: this does not mean you can't use this library anywhere else. You can use it wherever you want

Futurely, once the desktop part of this library gets mature, web and mobile will also be supported. See also:

- [Fluent UI Windows](https://docs.microsoft.com/en-us/windows/uwp/design/)
- [Fluent UI Web](https://developer.microsoft.com/pt-br/fluentui#/controls/web)
- [Fluent UI iOS](https://developer.microsoft.com/pt-br/fluentui#/controls/ios)
- [Fluent UI Android](https://developer.microsoft.com/pt-br/fluentui#/controls/android)
- [Fluent UI macOS](https://developer.microsoft.com/pt-br/fluentui#/controls/mac)

Also, futurely there will be a way to get the current device accent color. For more info, see [accent color](#accent-color)

## Usage

![Inputs Preview](screenshots/inputs.png)
![Forms Preview](screenshots/forms.png)

### Style

[Learn more about Fluent Style](https://docs.microsoft.com/en-us/windows/uwp/design/style/)

You can use the `Theme` widget to, well... theme your widgets. You can style your widgets in two ways:

1. Using the `FluentApp` widget

```dart
FluentApp(
  title: 'MyApp',
  style: Style(
    ...
  ),
)
```

2. Using the `Theme` widget

```dart
Theme(
  style: Style(
    ...
  ),
  child: ...,
),
```

### Icons

![Icons Preview](https://github.com/microsoft/fluentui-system-icons/raw/master/art/readme-banner.png)

Inside your app, you use icons to represent an action, such as copying text or navigating to the settings page. This library includes an icon library with it, so you can just call `Icons.[icon_name]` in any `Icon` widget:

```dart
Icon(Icons.add_regular)
```

To style icons, you can use `IconStyle` in the app `Style` or use the property `style` in the `Icon` widget. You can see the list of icons [here](https://github.com/microsoft/fluentui-system-icons/blob/master/icons.md)

![](https://docs.microsoft.com/en-us/windows/uwp/design/style/images/icons/inside-icons.png)

### Colors

This library also includes the Fluent UI colors with it, so you can just call `Colors.[color_name]`:

```dart
TextStyle(color: Colors.black)
```

Avaiable colors:

- `Colors.transparent`
- `Colors.white`
- `Colors.black`
- `Colors.grey`
- `Colors.yellow`
- `Colors.orange`
- `Colors.red`
- `Colors.magenta`
- `Colors.purple`
- `Colors.blue`
- `Colors.teal`
- `Colors.green`

#### Accent color

Common controls use an accent color to convey state information. By default, the accent color is `Colors.blue`. However, you can also customize your app's accent color to reflect your brand:

```dart
Style(
  accentColor: Colors.blue,
)
```

[Learn more](https://docs.microsoft.com/en-us/windows/uwp/design/style/color#accent-color)

### Brightness

You can change the style brightness to change the color of your app.

1. `Brightness.light`
![Light theme](https://docs.microsoft.com/en-us/windows/uwp/design/style/images/color/light-theme.svg)
2. `Brightness.dark`
![Dark theme](https://docs.microsoft.com/en-us/windows/uwp/design/style/images/color/dark-theme.svg)

It defaults to the brightness of the device. (`MediaQuery.of(context).brightness`)

### Typography

To set a typography, you can use the `Style` class combined with the `Typography` class:

```dart
Style(
  typography: Typography(
    caption: TextStyle(
      fontSize: 12,
      color: Colors.black,
      fontWeight: FontWeight.normal,
    ),
  ),
)
```

#### Font

You should use one font throughout your app's UI, and we recommend sticking with the default font for Windows apps, **Segoe UI**. It's designed to maintain optimal legibility across sizes and pixel densities and offers a clean, light, and open aesthetic that complements the content of the system.

![](https://docs.microsoft.com/en-us/windows/uwp/design/style/images/type/segoe-sample.svg)

[Learn more](https://docs.microsoft.com/en-us/windows/uwp/design/style/typography#font)

#### Type ramp

The Windows type ramp establishes crucial relationships between the type styles on a page, helping users read content easily.

![Type ramp](https://docs.microsoft.com/en-us/windows/uwp/design/style/images/type/type-ramp.png)

[Learn more](https://docs.microsoft.com/en-us/windows/uwp/design/style/typography#type-ramp)

### Widgets:

(1) = High priority\
(2) = Medium priority\
(3) = Low priority

**NOTE**: The code for all the images below can be found on the [example folder](example/)

| Widget                                                                                                                             | Preview                                                                                                                                     |
| ---------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| [Button](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/buttons#create-a-button)                        | ![Button Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/controls/button.png)                     |
| [Checkbox](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/checkbox)                                     | ![Checkbox Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/templates-checkbox-states-default.png) |
| [RadioButton](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/radio-button)                              | ![Radion Button Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/controls/radio-button.png)        |
| [Slider](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/slider)                                      | ![Slider Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/controls/slider.png)                     |
| [ToggleButton](https://docs.microsoft.com/en-us/uwp/api/windows.ui.xaml.controls.primitives.togglebutton?view=winrt-19041)         |                                                                                                                                             |
| [ToggleSwitch](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/toggles)                                  | ![Toggle Switch Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/toggleswitches01.png)             |
| (3) [DropDownButton](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/buttons#example---drop-down-button) |                                                                                                                                             |
| [SplitButton](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/buttons#example---split-button)            | ![Split Button Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/split-button-rtb.png)              |
| [RatingControl](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/rating)                                  | ![Rating Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/rating_rs2_doc_ratings_intro.png)        |

[Forms](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/forms):

| Widget                                                 | Preview                                                  |
| ----------------------------------------------------- | ------------------------------------------------------- |
| [TextBox](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/forms)                         | ![TextBox Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/text-box.png) |
| (3) [Auto suggest box](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/auto-suggest-box) |                                                                                                                   |
| (2) [ComboBox](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/combo-box)                |                                                                                                                   |

[Overlays](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/dialogs-and-flyouts/):

| Widget                | Preview                |
| ---------------------- | --------------------------- |
| [Dialogs](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/dialogs-and-flyouts/dialogs)               | ![Dialog preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/dialogs/dialog_rs2_delete_file.png) |
| (3) [Flyouts](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/dialogs-and-flyouts/flyouts)           |                                                                                                                                        |
| (3) [Teaching tip](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/dialogs-and-flyouts/teaching-tip) |                                                                                                                                        |
| [Tooltip](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/tooltips)                               | ![Tooltip Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/controls/tool-tip.png)             |     |

[Navigation](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/master-details):

| Widget                                                                                                      | Preview                                                                                                                                        |
| ----------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| [Navigation View](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/navigationview) | ![Navigation View preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/navview-pane-anatomy-vertical.png) |
| (3) [Pivot](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/pivot)                |                                                                                                                                                |
| (3) [TabView](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/tab-view)           |                                                                                                                                                |

Pickers:

- (3) [Date and time](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/date-and-time)
- (3) [Calendar date picker](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/calendar-date-picker) (Depends on ComboBox)
- (3) [Calendar view](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/calendar-view)
- (2) [Date picker](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/date-picker) (Depends on ComboBox)
- (2) [Time picker](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/time-picker) (Depends on ComboBox)

Others:

- (1) [Progress indicators](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/progress-controls)
- ✔️ [Acrylic](https://docs.microsoft.com/en-us/windows/uwp/design/style/acrylic)
- (3) [Reveal Highlight](https://docs.microsoft.com/en-us/windows/uwp/design/style/reveal)
- (3) [Reveal Focus](https://docs.microsoft.com/en-us/windows/uwp/design/style/reveal-focus)
- (3) [Info bar](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/infobar)
- (3) [Badges](https://docs.microsoft.com/en-us/windows/uwp/design/shell/tiles-and-notifications/badges)
- (3) [Sound](https://docs.microsoft.com/en-us/windows/uwp/design/style/sound)
- (3) [Contact card](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/contact-card)
- (3) [Flip View](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/flipview)
- (3) [Tree View](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/tree-view)
- (3) [Pull to refresh](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/pull-to-refresh)

# Contribution

Feel free to [open an issue](https://github.com/bdlukaa/fluent_ui/issues/new) if you find an error or [make pull requests](https://github.com/bdlukaa/fluent_ui/pulls).

All the widgets above with the mark of (3) will not be implemented soon, so you can create a pull request with the implementation for them :)