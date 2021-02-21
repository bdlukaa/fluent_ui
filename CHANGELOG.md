Date format: DD/MM/YYYY

## [0.0.3] - Theming update - [21/02/2021]

- **HIGHLIGHT** A whole new [documentation](https://github.com/bdlukaa/fluent_ui/wiki)
- Scaffold now works as expected.
- Improved theming checking
- **NEW**
  - `null` (thirdstate) design on `Checkbox`. (Follows [this](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/checkbox))
  - Now you can use the `Decoration` to style the inputs
- **BREAKING**:
  - Removed `Button.action`
  - Removed `Button.compound`
  - Removed `Button.primary`
  - Removed `Button.contextual`
  - Removed `AppBar`
  - Now the default theme uses accent color instead of a predefined color (Follows [this](https://docs.microsoft.com/en-us/windows/uwp/design/style/color#accent-color))
- **FIXED**:
  - `ToggleSwitch` can NOT receive null values

## [0.0.2] - [18/02/2021]

- The whole library was rewritten following [this](https://docs.microsoft.com/en-us/windows/uwp/design/)
- Tooltip's background color is now opaque (Follows [this](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/tooltips))
- Dropdown button now works as expected
- **FIXED**:
  - Snackbar now is dismissed even if pressing or hovering
  - Margin is no longer used as part of the clickable button
- **BREAKING**:
  - Renamed `Toggle` to `ToggleSwitch` (Follows [this](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/toggles))
  - Removed `BottomNavigationBar`. It's recommended to use top navigation (pivots)
  - Removed `IconButton.menu`
- **NEW**:
  - NavigationPanel (Follows [this](https://docs.microsoft.com/en-us/windows/uwp/design/layout/page-layout#left-nav))
  - Windows project on example
  - RadioButton (Follows [this](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/radio-button))

## [0.0.1]

- Initial release
