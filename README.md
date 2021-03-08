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

Implements Fluent UI to [Flutter](flutter.dev).
It's written based on the following documentations:

- https://docs.microsoft.com/en-us/windows/uwp/design/
- https://developer.microsoft.com/pt-br/fluentui#/controls/web

## Motivation

Since flutter has Windows support (currently in alpha as of 18/02/2021), it's necessary to have support to its UI guidelines to build apps with fidelity, since it has support for Material and Cupertino.
See [this](https://github.com/flutter/flutter/issues/46481) for more info on the offical fluent ui support

See also:

- [Material UI for Flutter](https://flutter.dev/docs/development/ui/widgets/material)
- [Cupertino UI for Flutter](https://flutter.dev/docs/development/ui/widgets/cupertino)

## Usage

To use this package, please [read the documentation](https://github.com/bdlukaa/fluent_ui/wiki)

![Inputs Preview](screenshots/inputs.png)
![Forms Preview](screenshots/forms.png)

### Widgets:

✔️ = Done\
(1) = High priority\
(2) = Medium priority\
(3) = Low priority

**NOTE**: The code for all the images below can be found on the [example folder](example/)

Basic Inputs:

- ✔️ [Button](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/buttons#create-a-button)
  1. ![Button Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/controls/button.png)
- ✔️ [Checkbox](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/checkbox)
  1. ![Checkbox Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/templates-checkbox-states-default.png)
- ✔️ [RadioButton](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/radio-button)
  1. ![Radion Button Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/controls/radio-button.png)
- ✔️ [Slider](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/slider)
  1. ![Slider Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/controls/slider.png)
- ✔️ [ToggleButton](https://docs.microsoft.com/en-us/uwp/api/windows.ui.xaml.controls.primitives.togglebutton?view=winrt-19041)
- ✔️ [ToggleSwitch](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/toggles)
  1. ![Toggle Switch Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/toggleswitches01.png)
- (3) [DropDownButton](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/buttons#example---drop-down-button)
- ✔️ [SplitButton](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/buttons#example---split-button)
  1. ![Split Button Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/split-button-rtb.png)
- ✔️ [RatingControl](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/rating)
  1. ![Rating Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/rating_rs2_doc_ratings_intro.png)

[Forms](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/forms): 
- ✔️ [TextBox](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/forms)
  1. ![TextBox Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/text-box.png)
- (3) [Auto suggest box](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/auto-suggest-box)
- (2) [ComboBox](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/combo-box)

[Overlays](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/dialogs-and-flyouts/):

- ✔️ [Dialogs](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/dialogs-and-flyouts/dialogs)
  1. ![Dialog preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/dialogs/dialog_rs2_delete_file.png)
- (3) [Flyouts](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/dialogs-and-flyouts/flyouts)
- (3) [Teaching tip](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/dialogs-and-flyouts/teaching-tip)
- (2) [Tooltip](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/tooltips)

[Navigation](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/master-details):

- ✔️ [Navigation View](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/navigationview)
  1. ![Navigation View preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/navview-pane-anatomy-vertical.png)
- (3) [Pivot](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/pivot)
- (3) [TabView](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/tab-view)

Pickers:

- (3) [Date and time](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/date-and-time)
- (3) [Calendar date picker](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/calendar-date-picker) (Depends on ComboBox)
- (3) [Calendar view](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/calendar-view)
- (2) [Date picker](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/date-picker) (Depends on ComboBox)
- (2) [Time picker](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/time-picker) (Depends on ComboBox)

Others:

- (1) [Progress indicators](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/progress-controls)
- (3) [Info bar](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/infobar)
- (3) [Badges](https://docs.microsoft.com/en-us/windows/uwp/design/shell/tiles-and-notifications/badges)
- (3) [Sound](https://docs.microsoft.com/en-us/windows/uwp/design/style/sound)
- (3) [Contact card](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/contact-card)
- (3) [Flip View](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/flipview)
- (3) [Tree View](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/tree-view)
- (3) [Pull to refresh](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/pull-to-refresh)

# Contribution

Feel free to [open an issue](https://github.com/bdlukaa/fluent_ui/issues/new) if you find an error or [make pull requests](https://github.com/bdlukaa/fluent_ui/pulls).
