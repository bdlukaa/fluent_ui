<div>
  <h1 align="center">fluent_ui</h1>
  <p align="center" >
    <a title="Discord" href="https://discord.gg/674gpDQUVq">
      <img src="https://img.shields.io/discord/809528329337962516?label=discord&logo=discord" />
    </a>
    <a title="Pub" href="https://pub.dartlang.org/packages/fluent_ui" >
      <img src="https://img.shields.io/pub/v/fluent_ui.svg?style=popout&include_prereleases" />
    </a>
    <a title="Made with Fluent Design" href="https://github.com/bdlukaa/fluent_ui">
      <img src="https://img.shields.io/badge/fluent-design-blue?style=flat-square&color=7A7574&labelColor=0078D7">
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

### You can check the web version of it [here](https://bdlukaa.github.io/fluent_ui/)

### Content

- [Motivation](#motivation)
- [Installation](#installation)
  - [Badge](#badge)
- [Style](#style)
  - [Icons](#icons)
  - [Colors](#colors)
    - [Accent color](#accent-color)
  - [Brightness](#brightness)
  - [Visual Density](#visual-density)
  - [Typograpy](#typography)
    - [Font](#font)
    - [Type ramp](#type-ramp)
  - [Reveal Focus](#reveal-focus)
  - **TODO** [Reveal Highlight](https://docs.microsoft.com/en-us/windows/uwp/design/style/reveal)
- [Motion](#motion)
  - [Page Transitions](#page-transitions)
- [Navigation](#navigation)
  - [Navigation View](#navigation-view)
    - [App Bar](#app-bar)
    - [Navigation Pane](#navigation-pane)
    - [Navigation Body](#navigation-body)
  - [Tab View](#tab-view)
  - [Bottom Navigation](#bottom-navigation)
- [Inputs](#inputs)
  - [Button](#button)
  - [Split Button](#split-button)
  - [Toggle Button](#toggle-button)
  - [Checkbox](#checkbox)
  - [Toggle Switches](#toggle-switches)
  - [Radio Buttons](#radio-buttons)
  - [Slider](#slider)
- [Forms](#forms)
  - [TextBox](#textbox)
  - [Auto Suggest Box](#auto-suggest-box)
  - [Combo Box](#combo-box)
- [Widgets](#widgets)
  - [Tooltip](#tooltip)
  - [Content Dialog](#content-dialog)
  - [Flyout](#flyout)
  - **TODO** [Teaching tip]()
  - [Acrylic](#acrylic)
  - [InfoBar](#infobar)
  - **TODO** [Calendar View](#calendar-view)
  - **TODO** [Calendar Date Picker]()
  - [Date Picker](#date-picker)
  - [Time Picker](#time-picker)
  - [Progress Bar and Progress Ring](#progress-bar-and-progress-ring)
  - [Scrollbar](#scrollbar)
  - [List Tile](#list-tile)
  - [Info Header](#info-header)
- [Mobile Widgets](#mobile-widgets)
  - [Chip](#chip)
  - [Pill Button Bar](#pill-button-bar)
  - [Snackbar](#snackbar)
- [Equivalents with the material library](#equivalents-with-the-material-library)
- [Contribution](#contribution)
  - [Acknowledgements](#acknowledgements)

## Motivation

Since flutter has Windows support (currently in stable under an early release flag as of 30/03/2021), it's necessary to have support to its UI guidelines to build apps with fidelity, since it has support for Material and Cupertino.
See [this](https://github.com/flutter/flutter/issues/46481) for more info on the offical fluent ui support

See also:

- [Material UI for Flutter](https://flutter.dev/docs/development/ui/widgets/material)
- [Cupertino UI for Flutter](https://flutter.dev/docs/development/ui/widgets/cupertino)
- [MacOS UI for Flutter](https://github.com/GroovinChip/macos_ui)

## Installation

You can use two versions of this package:

1. You can use the [github version](https://github.com/bdlukaa/fluent_ui):

```yaml
dependencies:
  fluent_ui:
    git: https://github.com/bdlukaa/fluent_ui.git
```

Note that this version is not stable. You can see the example app deplyed using the github version [here](https://bdlukaa.github.io/fluent_ui/#/)

2. You can use the [pub version](https://pub.dev/packages/fluent_ui/install):

```yaml
dependencies:
  fluent_ui: ^2.1.1
```

Versions published to pub are stable and fully tested.

Finally, run `dart pub get` to downlaod the package.

Projects using this library should use the stable channel of Flutter

### Badge

Are you using this library on your app? You can use a badge to tell others:

<a title="Made with Fluent Design" href="https://github.com/bdlukaa/fluent_ui">
  <img src="https://img.shields.io/badge/fluent-design-blue?style=flat-square&color=7A7574&labelColor=0078D7">
</a>

Add the following code to your `README.md` or to your website:

```html
<a title="Made with Fluent Design" href="https://github.com/bdlukaa/fluent_ui">
  <img
    src="https://img.shields.io/badge/fluent-design-blue?style=flat-square&color=7A7574&labelColor=0078D7"
  />
</a>
```

---

# Style

[Learn more about Fluent Style](https://docs.microsoft.com/en-us/windows/uwp/design/style/)

You can use the `FluentTheme` widget to, well... theme your widgets. You can style your widgets in two ways:

1. Using the `FluentApp` widget

```dart
FluentApp(
  title: 'MyApp',
  theme: ThemeData(
    ...
  ),
)
```

2. Using the `FluentTheme` widget

```dart
FluentTheme(
  theme: ThemeData(
    ...
  ),
  child: ...,
),
```

## Icons

![Icons Preview](https://github.com/microsoft/fluentui-system-icons/raw/master/art/readme-banner.png)

Inside your app, you use icons to represent an action, such as copying text or navigating to the settings page. This library includes an icon library with it, so you can just call `Icons.[icon_name]` in any `Icon` widget:

```dart
Icon(Icons.add),
```

To style icons, you can use `IconTheme` in the app `ThemeData` or use the property `style` in the `Icon` widget. You can see the list of icons [here](https://github.com/microsoft/fluentui-system-icons/blob/master/icons.md)

![](https://docs.microsoft.com/en-us/windows/uwp/design/style/images/icons/inside-icons.png)

## Colors

This library also includes the Fluent UI colors with it, so you can just call `Colors.[color_name]`:

```dart
TextStyle(color: Colors.black),
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

### Accent color

Common controls use an accent color to convey state information. [Learn more](https://docs.microsoft.com/en-us/windows/uwp/design/style/color#accent-color).

By default, the accent color is `Colors.blue`. However, you can also customize your app's accent color to reflect your brand:

```dart
ThemeData(
  accentColor: Colors.blue,
)
```

To use the system's accent color, you can use the plugin [system_theme](https://pub.dev/packages/system_theme) made by me :). It has support for (04/01/2021) Android, Web and Windows.

```dart
import 'package:system_theme/system_theme.dart';

ThemeData(
  accentColor: SystemTheme.accentInstance.accent.toAccentColor(),
)
```

## Brightness

You can change the theme brightness to change the color of your app to

1. `Brightness.light`

   ![Light theme](https://docs.microsoft.com/en-us/windows/uwp/design/style/images/color/light-theme.svg)

2. `Brightness.dark`

   ![Dark theme](https://docs.microsoft.com/en-us/windows/uwp/design/style/images/color/dark-theme.svg)

It defaults to the brightness of the device. (`MediaQuery.of(context).brightness`)

```dart
ThemeData(
  brightness: Brightness.light, // or Brightness.dark
),
```

## Visual Density

Density, in the context of a UI, is the vertical and horizontal "compactness" of the components in the UI. It is unitless, since it means different things to different UI components.

The default for visual densities is zero for both vertical and horizontal densities. It does not affect text sizes, icon sizes, or padding values.

For example, for buttons, it affects the spacing around the child of the button. For lists, it affects the distance between baselines of entries in the list. For chips, it only affects the vertical size, not the horizontal size.

```dart
ThemeData(
  visualDensity: VisualDensity.adaptivePlatformDensity,
),
```

The following widgets make use of visual density:

- Chip
- PillButtonBar
- Snackbar

## Typography

To set a typography, you can use the `ThemeData` class combined with the `Typography` class:

```dart
ThemeData(
  typography: Typography(
    caption: TextStyle(
      fontSize: 12,
      color: Colors.black,
      fontWeight: FontWeight.normal,
    ),
  ),
)
```

### Font

You should use one font throughout your app's UI, and we recommend sticking with the default font for Windows apps, **Segoe UI**. It's designed to maintain optimal legibility across sizes and pixel densities and offers a clean, light, and open aesthetic that complements the content of the system.

![Font Segoe UI Showcase](https://docs.microsoft.com/en-us/windows/uwp/design/style/images/type/segoe-sample.svg)

[Learn more](https://docs.microsoft.com/en-us/windows/uwp/design/style/typography#font)

### Type ramp

The Windows type ramp establishes crucial relationships between the type styles on a page, helping users read content easily. [Learn more](https://docs.microsoft.com/en-us/windows/uwp/design/style/typography#type-ramp)

![Windows Type Ramp](https://docs.microsoft.com/en-us/windows/uwp/design/style/images/type/type-ramp.png)

## Reveal Focus

Reveal Focus is a lighting effect for [10-foot experiences](https://docs.microsoft.com/en-us/windows/uwp/design/devices/designing-for-tv), such as Xbox One and television screens. It animates the border of focusable elements, such as buttons, when the user moves gamepad or keyboard focus to them. It's turned off by default, but it's simple to enable. [Learn more](https://docs.microsoft.com/en-us/windows/uwp/design/style/reveal-focus)

Reveal Focus calls attention to focused elements by adding an animated glow around the element's border:

![Reveal Focus Preview](https://docs.microsoft.com/en-us/windows/uwp/design/style/images/traveling-focus-fullscreen-light-rf.gif)

This is especially helpful in 10-foot scenarios where the user might not be paying full attention to the entire TV screen.

### Enabling it

Reveal Focus is off by default. To enable it, change the `focusStyle` in your app `ThemeData`:

```dart
theme: ThemeData(
  focusTheme: FocusStyle(
    glowFactor: 4.0,
  ),
),
```

To enable it in a 10 foot screen, use the method `is10footScreen`:

```dart
import 'dart:ui' as ui;

theme: ThemeData(
  focusStyle: FocusStyle(
    glowFactor: is10footScreen(ui.window.physicalSize.width) ? 2.0 : 0.0,
  ),
),
```

Go to the [example](/example) project to a full example

### Why isn't Reveal Focus on by default?

As you can see, it's fairly easy to turn on Reveal Focus when the app detects it's running on 10 foot screen. So, why doesn't the system just turn it on for you? Because Reveal Focus increases the size of the focus visual, which might cause issues with your UI layout. In some cases, you'll want to customize the Reveal Focus effect to optimize it for your app.

### Customizing Reveal Focus

You can customize the focus border, border radius and glow color:

```dart
focusTheme: FocusStyle(
  borderRadius: BorderRadius.zero,
  glowColor: theme.accentColor?.withOpacity(0.2),
  glowFactor: 0.0,
  border: BorderSide(
    width: 2.0,
    color: theme.inactiveColor ?? Colors.transparent,
  ),
),
```

To customize it to a single widget, wrap the widget in a `FocusTheme` widget, and change the options you want:

```dart
FocusTheme(
  data: FocusThemeData(...),
  child: Button(
    text: Text('Custom Focus Button'),
    onPressed: () {},
  )
),
```

# Motion

This package widely uses animation in the widgets. The animation duration and curve can be defined on the app theme.

## Page transitions

Page transitions navigate users between pages in an app, providing feedback as the relationship between pages. Page transitions help users understand if they are at the top of a navigation hierarchy, moving between sibling pages, or navigating deeper into the page hierarchy.

It's recommended to widely use page transitions on `NavigationView`, that can be implemented using the widget `NavigationBody`.

This library gives you the following implementations to navigate between your pages:

#### Entrance

Entrance is a combination of a slide up animation and a fade in animation for the incoming content. Use entrance when the user is taken to the top of a navigational stack, such as navigating between tabs or left-nav items.

The desired feeling is that the user has started over.

Avaiable with the widget `EntrancePageTransition`, it produces the following effect:

![Entrance Page Transition Preview](https://docs.microsoft.com/en-us/windows/uwp/design/motion/images/page-refresh.gif)

#### Drill In

Use drill when users navigate deeper into an app, such as displaying more information after selecting an item.

The desired feeling is that the user has gone deeper into the app.

Avaiable with the widget `DrillInPageTransition`, it produces the following effect:

![Drill Page Transition Preview](https://docs.microsoft.com/en-us/windows/uwp/design/motion/images/drill.gif)

#### Horizontal

It's avaiable with the widget `HorizontalSlidePageTransition`.

# Navigation

The default Flutter Navigation is available on the `FluentApp` widget, that means you can simply call `Navigator.push` and `Navigator.pop` to navigate between routes. See [navigate to a new screen and back](https://flutter.dev/docs/cookbook/navigation/navigation-basics)

## Navigation View

The NavigationView control provides top-level navigation for your app. It adapts to a variety of screen sizes and supports both _top_ and _left_ navigation styles.

![Navigation Panel](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/nav-view-header.png)

The navigation view also handle the app bar and its content. You can enable the acrylic blur effect by setting `useAcrylic` to true.

### App Bar

The app bar is the top app bar that every desktop nowadays have.

```dart
NavigationView(
  appBar: NavigationAppBar(
    title: Text('Nice App Title :)'),
    actions: Row(children: [
      /// These actions are usually the minimize, maximize and close window
    ]),
    /// If automaticallyImplyLeading is true, a 'back button' will be added to
    /// app bar. This property can be overritten by [leading]
    automaticallyImplyLeading: true,
  ),
  ...
)
```

### Navigation Pane

The pane is the pane that can be displayed at the left or at the top.

```dart
NavigationView(
  ...,
  pane: NavigationPane(
    /// The current selected index
    selected: index,
    /// Called whenever the current index changes
    onChanged: (i) => setState(() => index = i),
    displayMode: PaneDisplayMode.auto,
  ),
  ...
)
```

You can change the `displayMode` to make it fit the screen.

| Name    | Screenshot                                                                                                        | Info                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| ------- | ----------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Top     | ![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/displaymode-top.png)         | The pane is positioned above the content. We recommend top navigation when: <br>- You have 5 or fewer top-level navigation categories that are equally important, and any additional top-level navigation categories that end up in the dropdown overflow menu are considered less important.</br> - You need to show all navigation options on screen. - You want more space for your app content. <br>- Icons cannot clearly describe your app's navigation categories.</br> |
| Open    | ![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/displaymode-left.png)        | The pane is expanded and positioned to the left of the content. We recommend _open_ navigation when: <br>- You have 5-10 equally important top-level navigation categories.</br>- You want navigation categories to be very prominent, with less space for other app content.                                                                                                                                                                                                  |
| Compact | ![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/displaymode-leftcompact.png) | The pane shows only icons until opened and is positioned to the left of the content.                                                                                                                                                                                                                                                                                                                                                                                           |
| Minimal | ![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/displaymode-leftminimal.png) | Only the menu button is shown until the pane is opened. When opened, it's positioned to the left of the content.                                                                                                                                                                                                                                                                                                                                                               |
| Auto    | ![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/displaymode-auto.png)        | By default, `displayMode` is set to `auto`. In Auto mode, the NavigationView adapts between `minimal` when the window is narrow, to `compact`, and then `open` as the window gets wider.                                                                                                                                                                                                                                                                                       |

You can customize the selected indicator. By default `StickyNavigationIndicator` is used, but you can also use the old windows indicator:

```dart
pane: NavigationPane(
  indicatorBuilder: ({
    required BuildContext context,
    /// The current selected index
    int? index,
    /// The y axis to take into consideration when calculating the
    /// position
    double? y,
    /// A function that, when executed, returns the position of all the
    /// PaneItems. This function must be called after the widget was
    /// rendered at least once
    required List<Offset> Function() offsets,
    /// A function that, when executed, returns the size of all the
    /// PaneItems. This function must be called after the widget was
    /// rendered at least once
    required List<Size> Function() sizes,
    /// Corresponds to the current display mode. If top, Axis.vertical
    /// is passed, otherwise Axis.vertical
    required Axis axis,
    /// Corresponds to the pane itself as a widget. The indicator is
    /// rendered over the whole pane.
    required Widget child,
  }) {
    if (index == null) return child;
    assert(debugCheckHasFluentTheme(context));
    final theme = NavigationPaneThemeData.of(context);
    return EndNavigationIndicator(
      index: index,
      offsets: offsets,
      sizes: sizes,
      child: child,
      color: theme.highlightColor,
      curve: theme.animationCurve ?? Curves.linear,
      y: y ?? 0,
      axis: axis,
    );
  },
)
```

### Navigation body

A navigation body is used to implement page transitions into a navigation view. It knows what is the current diplay mode of the parent `NavigationView`, if any, and define the page transitions accordingly.

For top mode, the horizontal page transition is used. For the others, drill in page transition is used.

```dart
int _currentIndex = 0;

NavigationView(
  ...,
  content: NavigationBody(index: _currentIndex, children: [...]),
)
```

`ScaffoldPage` is usually used with the navigation body as its children:

```dart
NavigationBody(
  index: _currentIndex,
  children: [
    ScaffoldPage(
      topBar: PageTopBar(header: Text('Your Songs'))
    )
  ],
)
```

## Tab View

The TabView control is a way to display a set of tabs and their respective content. TabViews are useful for displaying several pages (or documents) of content while giving a user the capability to rearrange, open, or close new tabs. [Learn more](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/tab-view)

Here's an example of how to create a tab view:

```dart
SizedBox(
  height: 600,
  child: TabView(
    currentIndex: currentIndex,
    onChanged: (index) => setState(() => currentIndex = index),
    onNewPressed: () {
      setState(() => tabs++);
    },
    tabs: List.generate(tabs, (index) {
      return Tab(
        text: Text('Tab $index'),
        closeIcon: Tooltip(
          message: 'Close tab',
          child: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              setState(() => tabs--);
              if (currentIndex > tabs - 1) currentIndex--;
            },
          ),
        ),
      );
    }),
    bodies: List.generate(
      tabs,
      (index) => Container(
        color: index.isEven ? Colors.red : Colors.yellow,
      ),
    ),
  ),
),
```

The code above produces the following:

![TabView Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/tabview/tab-introduction.png)

## Bottom Navigation

The bottom navigation displays icons and optional text at the bottom of the screen for switching between different primary destinations in an app. This is commomly used on small screens. [Learn more](https://developer.microsoft.com/pt-br/fluentui#/controls/android/bottomnavigation)

Here's an example of how to create a bottom navigation:

```dart
int index = 0;

ScaffoldPage(
  content: NavigationBody(index: index, children: [
    Container(),
    Container(),
    Container(),
  ]),
  bottomBar: BottomNavigation(
    index: index,
    onChanged: (i) => setState(() => index = i),
    items: [
      BottomNavigationItem(
        icon: Icon(Icons.two_k),
        selectedIcon: Icon(Icons.two_k_plus),
        title: Text('Both'),
      ),
      BottomNavigationItem(
        icon: Icon(Icons.phone_android_outlined),
        selectedIcon: Icon(Icons.phone_android),
        title: Text('Android'),
      ),
      BottomNavigationItem(
        icon: Icon(Icons.phone_iphone_outlined),
        selectedIcon: Icon(Icons.phone_iphone),
        title: Text('iOS'),
      ),
    ],
  )
)

```

# Inputs

Inputs are widgets that reacts to user interection. On most of the inputs you can set `onPressed` or `onChanged` to `null` to disable it.

## Button

A button gives the user a way to trigger an immediate action. [Learn more](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/buttons)

Here's an example of how to create a basic button:

```dart
Button(
  text: Text('Button'),
  onPressed: () {
    print('button pressed'),
  }
)
```

The code above produces the following:

![Button](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/controls/button.png)

You can also use some alternative buttons:

- `FilledButton`
  ```dart
  FilledButton(
    child: Text('FILLED BUTTON'),
    onPressed: () {
      print('pressed filled button');
    },
  ),
  ```
  ![Filled Button](https://user-images.githubusercontent.com/45696119/120252437-e0d78d00-c25a-11eb-8122-56457c782fbd.png)
- `IconButton`

  ```dart
  IconButton(
    Icon: Icon(Icons.add),
    onPressed: () {
      print('pressed filled button');
    },
  ),
  ```

- `OutlinedButton`

  ```dart
  OutlinedButton(
    child: Text('OUTLINED BUTTON'),
    onPressed: () {
      print('pressed filled button');
    },
  ),
  ```

  ![Outlined Button](https://user-images.githubusercontent.com/45696119/120252439-e339e700-c25a-11eb-9695-6d5c3c471166.png)

- `TextButton`

  ```dart
  TextButton(
    child: Text('TEXT BUTTON'),
    onPressed: () {
      print('pressed text button');
    },
  ),
  ```

  ![Text Button](https://user-images.githubusercontent.com/45696119/120252431-de753300-c25a-11eb-8055-531abd25e5d3.png)

## Split Button

A Split Button has two parts that can be invoked separately. One part behaves like a standard button and invokes an immediate action. The other part invokes a flyout that contains additional options that the user can choose from. [Learn more](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/buttons#create-a-split-button)

You can use a `SplitButtonBar` to create a Split Button. It usually takes `Button`s in the `buttons` property. You can also customize the button spacing by changing the property `interval` in its theme.

Here's an example of how to create a split button:

```dart
const double splitButtonHeight = 50.0;

SplitButtonBar(
  theme: SplitButtonThemeData(
    interval: 1, // the default value is one
  ),
  // There need to be at least 2 items in the buttons, and they must be non-null
  buttons: [
    SizedBox(
      height: splitButtonHeight,
      child: Button(
        text: Container(
          height: 24,
          width: 24,
          color: FluentTheme.of(context).accentColor,
        ),
        onPressed: () {},
      ),
    ),
    SizedBox(
      height: splitButtonHeight,
      child: Button(
        text: Icon(Icons.keyboard_arrow_down),
        onPressed: () {
          // TODO: open the color list here
        },
        theme: ButtonThemeData(padding: EdgeInsets.all(6)),
      )
    )
  ],
)
```

The code above produces the following button:

![SplitButtonBar preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/split-button-rtb.png)

## Toggle Button

A button that can be on or off.

Here's an example of how to create a basic toggle button:

```dart
bool _value = false;

ToggleButton(
  child: Text('Toggle Button'),
  checked: _value,
  onChanged: (value) => setState(() => _value = value),
)
```

## Checkbox

A check box is used to select or deselect action items. It can be used for a single item or for a list of multiple items that a user can choose from. The control has three selection states: unselected, selected, and indeterminate. Use the indeterminate state when a collection of sub-choices have both unselected and selected states. [Learn more](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/checkbox)

Here's an example of how to create a checkbox:

```dart
bool _checked = true;

Checkbox(
  checked: _checked,
  onChanged: (value) => setState(() => _checked = value),
)
```

#### Handling its states

| State         | Property  | Value    |
| ------------- | --------- | -------- |
| checked       | checked   | `true`   |
| unchecked     | checked   | `false`  |
| indeterminate | checked   | `null`   |
| enabled       | onChanged | non-null |
| disabled      | onChanged | `null`   |

### Screenshots

![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/templates-checkbox-states-default.png)
![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/checkbox1.png)
![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/checkbox3.png)

## Toggle Switches

The toggle switch represents a physical switch that allows users to turn things on or off, like a light switch. Use toggle switch controls to present users with two mutually exclusive options (such as on/off), where choosing an option provides immediate results. [Learn more](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/toggles)

### Example

```dart
bool _checked = false;

ToggleSwitch(
  checked: _checked,
  onChanged: (v) => setState(() => _checked = v),
)
```

![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/toggleswitches01.png)

| Toggle Switch                                                                                                  | Checkbox                                                                                                                                                                                |
| -------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Use a toggle switch for binary settings when changes become effective immediately after the user changes them. | Use check boxes for optional ("nice to have") items.                                                                                                                                    |
|                                                                                                                | Use a checkbox when the user has to perform extra steps for changes to be effective. For example, if the user must click a "submit" or "next" button to apply changes, use a check box. |
|                                                                                                                | Use check boxes when the user can select multiple items that are related to a single setting or feature.                                                                                |

## Radio Buttons

Radio buttons, also called option buttons, let users select one option from a collection of two or more mutually exclusive, but related, options. Radio buttons are always used in groups, and each option is represented by one radio button in the group.

In the default state, no radio button in a RadioButtons group is selected. That is, all radio buttons are cleared. However, once a user has selected a radio button, the user can't deselect the button to restore the group to its initial cleared state.

The singular behavior of a RadioButtons group distinguishes it from check boxes, which support multi-selection and deselection, or clearing.

[Learn more](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/radio-button)

### Example

```dart
int _currentIndex = -1;

final radioButtons = [
  'RadioButton 1',
  'RadioButton 2',
  'RadioButton 3',
];

Column(
  children: List.generate(radioButtons.length, (index) {
    return Row(children: [
      RadioButton(
        selected: _currentIndex == index,
        // set onChanged to null to disable the button
        onChanged: () => setState(() => _currentIndex = index),
      ),
      SizedBox(width: 4),
      Text(radioButtons[index])
    ]);
  }),
),
```

The code above produces the following:

![Radio Buttons](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/controls/radio-button.png)

- [Is this the right control for you?](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/radio-button#is-this-the-right-control)

### Screenshots

![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/radiobuttons-default-group.png)
![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/radiobuttons-symbolicon.png)
![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/radiobuttons-multi-column.png)
![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/radio-button-groups.png)
![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/radiobutton-layout.png)

## Slider

A slider is a control that lets the user select from a range of values by moving a thumb control along a track. [Learn more](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/slider)

A slider is a good choice when you know that users think of the value as a relative quantity, not a numeric value. For example, users think about setting their audio volume to low or medium—not about setting the value to 2 or 5.

Don't use a slider for binary settings. Use a [toggle switch](#toggle-switches) instead.

### Creating

```dart
double _value = 0;

Container(
  // The default width is 200.
  // The slider does not have its own widget, so you have to add it yourself.
  // The slider always try to be as big as possible
  width: 200,
  child: Slider(
    max: 100,
    value: _value,
    onChanged: (v) => setState(() => value = v),
    // Label is the text displayed above the slider when the user is interacting with it.
    label: '${sliderValue.toInt()}',
  ),
)
```

The code above produces the following:

![Slider preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/controls/slider.png)

You can set `vertical` to `true` to create a vertical slider

### Choosing between vertical and horizontal sliders

| Horizontal                                                        | Vertical                                                                                             |
| ----------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| If the control is used to seek within media, like in a video app. | if the slider represents a real-world value that is normally shown vertically (such as temperature). |

## Rating Bar

> The property `starSpacing` was not implemented yet

The rating control allows users to view and set ratings that reflect degrees of satisfaction with content and services. [Learn more](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/rating)

### Example

```dart
double rating = 0.0;

RatingBar(
  rating: rating,
  onChanged: (v) => setState(() => rating = v),
)
```

You can set `amount` to change the amount of stars. The `rating` must be less than the stars and more than 0. You can also change the `icon`, its size and color. You can make the bar read only by setting `onChanged` to `null`.

![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/rating_rs2_doc_ratings_intro.png)

# Forms

A form is a group of controls that collect and submit data from users. Forms are typically used for settings pages, surveys, creating accounts, and much more.

## TextBox

The TextBox control lets a user type text into an app. It's typically used to capture a single line of text, but can be configured to capture multiple lines of text. The text displays on the screen in a simple, uniform, plaintext format. [Learn more](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/text-box)

You can use the [forms screen](example/lib/screens/forms.dart) in the example app for reference.

### Creating

You can use the widget `TextBox` to create text boxes:

```dart
TextBox(
  controller: ...,
  header: 'Notes',
  placeholder: 'Type your notes here',
),
```

### Screenshots

![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/text-box.png)\
![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/text-box-ex1.png)\
![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/text-box-clear-all.png)\
![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/text-box-multi-line.png)

## Auto Suggest Box

Use an AutoSuggestBox to provide a list of suggestions for a user to select from as they type. [Learn more](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/auto-suggest-box)

### Example

```dart
final autoSuggestBox = TextEditingController();

AutoSuggestBox<String>(
  controller: autoSuggestBox,
  items: [
    'Blue',
    'Green',
    'Red',
    'Yellow',
    'Grey',
  ],
  onSelected: (text) {
    print(text);
  },
  textBoxBuilder: (context, controller, focusNode, key) {
    const BorderSide _kDefaultRoundedBorderSide = BorderSide(
      style: BorderStyle.solid,
      width: 0.8,
    );
    return TextBox(
      key: key,
      controller: controller,
      focusNode: focusNode,
      suffixMode: OverlayVisibilityMode.editing,
      suffix: IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          controller.clear();
          focusNode.unfocus();
        },
      ),
      placeholder: 'Type a color',
      decoration: BoxDecoration(
        border: Border(
          top: _kDefaultRoundedBorderSide,
          bottom: _kDefaultRoundedBorderSide,
          left: _kDefaultRoundedBorderSide,
          right: _kDefaultRoundedBorderSide,
        ),
        borderRadius: focusNode.hasFocus
            ? BorderRadius.vertical(top: Radius.circular(3.0))
            : BorderRadius.all(Radius.circular(3.0)),
      ),
    );
  },
)
```

The code above produces the following:

![Auto suggest box example](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/controls_autosuggest_expanded01.png)

### Screenshots

![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/control-examples/auto-suggest-box-groove.png)
![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/controls_autosuggest_noresults.png)

## Combo Box

Use a combo box to present a list of items that a user can select from. A combo box starts in a compact state and expands to show a list of selectable items. When the combo box is closed, it either displays the current selection or is empty if there is no selected item. When the user expands the combo box, it displays the list of selectable items. [Learn more](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/combo-box)

### Example

```dart

final values = ['Blue', 'Green', 'Yellow', 'Red'];
String? comboBoxValue;

SizedBox(
  width: 200,
  child: ComboBox<String>(
    header: 'Colors',
    placeholder: 'Selected list item',
    isExpanded: true,
    items: values
        .map((e) => ComboboxMenuItem<String>(
              value: e,
              child: Text(e),
            ))
        .toList(),
    value: comboBoxValue,
    onChanged: (value) {
      print(value);
      if (value != null) setState(() => comboBoxValue = value);
    },
  ),
),
```

The code above produces the following:

![Combo box example](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/combo-box-expand.gif)

### Screenshots

![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/combo_box_collapsed.png)\
![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/combo_box_listitemstate.png)\
![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/combo_box_scroll.png)

# Widgets

## Tooltip

A tooltip is a short description that is linked to another control or object. Tooltips help users understand unfamiliar objects that aren't described directly in the UI. They display automatically when the user moves focus to, presses and holds, or hovers the mouse pointer over a control. The tooltip disappears after a few seconds, or when the user moves the finger, pointer or keyboard/gamepad focus. [Learn more](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/controls/tool-tip.png)

To add a tooltip to a widget, wrap it in a `Tooltip` widget:

```dart
Tooltip(
  message: 'Click to perform action.',
  child: Button(
    text: Text('Button with tooltip'),
    onPressed: () {
      print('pressed button with tooltip');
    }
  ),
)
```

It's located above or below the `child` widget. You can specify the preffered location when both locations are available using the `preferBelow` property.

![Tooltip Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/controls/tool-tip.png)

## Content Dialog

Dialogs are modal UI overlays that provide contextual app information. They block interactions with the app window until being explicitly dismissed. They often request some kind of action from the user. [Learn more](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/dialogs-and-flyouts/dialogs)

You can create a Dialog with the widget `ContentDialog`:

```dart
ContentDialog(
  title: Text('No WiFi connection'),
  content: Text('Check your connection and try again'),
  actions: [
    Button(
      text: Text('Ok'),
      onPressed: () {
        Navigator.pop(context);
      }
    )
  ],
),
```

The code above produces the following:

![No Wifi Connection Dialog](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/dialogs/dialog_rs2_one_button.png)

You can display the dialog as an overlay by calling the function `showDialog`:

```dart
showDialog(
  context: context,
  builder: (context) {
    return ContentDialog(...);
  },
);
```

![Delete File Dialog](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/dialogs/dialog_rs2_delete_file.png)\
![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/dialogs/dialog_rs2_two_button.png)\
![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/dialogs/dialog_rs2_three_button.png)\
![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/dialogs/dialog_rs2_three_button_default.png)

## Flyout

A flyout is a light dismiss container that can show arbitrary UI as its content. Flyouts can contain other flyouts or context menus to create a nested experience.

### Example

```dart
final flyoutController = FlyoutController();

Flyout(
  controller: flyoutController,
  contentWidth: 450,
  content: FlyoutContent(
    child: Text(
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.'),
  ),
  child: Button(
    text: Text('Open flyout'),
    onPressed: () {
      flyoutController.open = true;
    },
  ),
);

@override
void dispose() {
  flyoutController.dispose();
  super.dispose();
}
```

The code above produces the following:

![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/flyout-wrapping-text.png)

### Screenshots

![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/flyout-nested.png)\
![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/flyout-smoke.png)

## Acrylic

Acrylic is a type of Brush that creates a translucent texture. You can apply acrylic to app surfaces to add depth and help establish a visual hierarchy. [Learn more](https://docs.microsoft.com/en-us/windows/uwp/design/style/acrylic)

![Acrylic](https://docs.microsoft.com/en-us/windows/uwp/design/style/images/header-acrylic.svg)

| Do                                                                                                                                  | Don't                                                                                                                                                     |
| ----------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Do use acrylic as the background material of non-primary app surfaces like navigation panes.                                        | Don't put desktop acrylic on large background surfaces of your app - this breaks the mental model of acrylic being used primarily for transient surfaces. |
| Do extend acrylic to at least one edge of your app to provide a seamless experience by subtly blending with the app’s surroundings. | Don’t place in-app and background acrylics directly adjacent to avoid visual tension at the seams.                                                        |
|                                                                                                                                     | Don't place multiple acrylic panes with the same tint and opacity next to each other because this results in an undesirable visible seam.                 |
|                                                                                                                                     | Don’t place accent-colored text over acrylic surfaces.                                                                                                    |

```dart
Acrylic(
  child: Button(
    text: Text('Mom it\'s me hehe <3'),
    onPressed: () {
      print('button inside acrylic pressed');
    }
  ),
  color: ...,
  width: ...,
  height: ...,
),
```

### Widgets using Acrylic

Currently, the following widgets use acrylic in its implementation:

- [InfoBar](#infobar)
- [Navigation View](#navigation-view)
- [TabView](#tab-view)

### Screenshots

![Acrylic preview](https://docs.microsoft.com/en-us/windows/uwp/design/style/images/luminosityversustint.png)

## InfoBar

The `InfoBar` widget is for displaying app-wide status messages to users that are highly visible yet non-intrusive. There are built-in Severity levels to easily indicate the type of message shown as well as the option to include your own call to action or hyperlink button. Since the InfoBar is inline with other UI content the option is there for the control to always be visible or dismissed by the user.

#### Usage

You can easility create it using the `InfoBar` widget and theme it using `InfoBarThemeData`. It has built-in support for both light and dark theme:

```dart
InfoBar(
  title: Text('Update available'),
  content: Text('Restart the app to apply the latest update.'), // optional
  severity: InfoBarSeverity.info, // optional. Default to InfoBarSeverity.info
),
```

#### Some screenshots

![Info InfoBar Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/infobar-default-title-message.png)\
![Long Info InfoBar Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/infobar-default-hyperlink.png)\
![Warning InfoBar Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/infobar-warning-title-message.png)\
![Long Success InfoBar Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/infobar-success-content-wrapping.png)\
![Error InfoBar Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/infobar-error-action-button.png)\
![Custom InfoBar Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/infobar-custom-icon-color.png)

## Date Picker

The date picker gives you a standardized way to let users pick a localized date value using touch, mouse, or keyboard input. [Learn more](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/date-picker)

The entry point displays the chosen date, and when the user selects the entry point, a picker surface expands vertically from the middle for the user to make a selection. The date picker overlays other UI; it doesn't push other UI out of the way.

![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/controls_datepicker_expand.png)

We use [intl](https://pub.dev/packages/intl) to format the dates. You can [change the current locale](https://pub.dev/packages/intl#current-locale) to change formatting

### Example

```dart
DateTime date = DateTime.now();

SizedBox(
  width: 295,
  child: DatePicker(
    header: 'Date of birth',
    selected: date,
    onChanged: (v) => setState(() => date = v),
  ),
);
```

The code above produces the following:

![DatePicker Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/date-picker-closed.png)

## Time Picker

The time picker gives you a standardized way to let users pick a time value using touch, mouse, or keyboard input. [Learn more](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/time-picker)

Use a time picker to let a user pick a single time value.

![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/controls_timepicker_expand.png)

### Example

```dart
DateTime date = DateTime.now();

SizedBox(
  width: 240,
  child: TimePicker(
    header: 'Arrival time',
    selected: date,
    onChanged: (v) => setState(() => date = v),
  ),
),
```

The code above produces the following:

![Time Picker Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/time-picker-closed.png)

## Progress Bar and Progress Ring

A progress control provides feedback to the user that a long-running operation is underway. It can mean that the user cannot interact with the app when the progress indicator is visible, and can also indicate how long the wait time might be, depending on the indicator used.

### Example

Creating a ProgressBar:

```dart
ProgressBar(value: 35)
```

![Determinate Progress Bar](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/progressbar-determinate.png)

You can omit the `value` property to create an indeterminate progress bar:

![Indeterminate Progress Bar](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/progressbar-indeterminate.gif)

Indeterminate Progress Bar is a courtesy of [@raitonubero](https://github.com/raitonoberu). Show him some love

Creating a ProgressRing:

```dart
ProgressRing(value: 35)
```

![Determinate Progress Ring](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/progress_ring.jpg)

You can omit the `value` property to create an indeterminate progress ring:

![Indeterminate Progress Ring](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/progressring-indeterminate.gif)

Both Indeterminate ProgressBar and Indeterminate ProgressRing is a courtesy of [@raitonubero](https://github.com/raitonoberu). Show him some love ❤

### Screenshots

![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/progress-bar-determinate-example.png)
![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/progress-bar-indeterminate-example.png)
![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/progress_ring_determinate_example.png)

## Scrollbar

A scrollbar thumb indicates which portion of a [ScrollView] is actually visible. [Learn more](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/scroll-controls)

Depending on the situation, the scrollbar uses two different visualizations, shown in the following illustration: the panning indicator (left) and the traditional scrollbar (right).

![Scrollbar Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/scrollbar.png)

> When the scrollbar is visible it is overlaid as 16px on top of the content inside your ScrollView. In order to ensure good UX design you will want to ensure that no interactive content is obscured by this overlay. Additionally if you would prefer not to have UX overlap, leave 16px of padding on the edge of the viewport to allow for the scrollbar.

### Example

```dart
final _controller = ScrollController();

Scrollbar(
  controller: controller,
  child: ListView.builder(
    /// You can add a padding to the view to avoid having the scrollbar over the UI elements
    padding: EdgeInsets.only(right: 16.0),
    itemCount: 100,
    builder: (context, index) {
      return ListTile(title: Text('$index'));
    }
  ),
)
```

Which produces the following:

![Scrollbar Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/conscious-scroll.gif)

You can change the `isAlwaysVisible` property to either enable or disable the fade effect. It's disabled by default.

> Note: Currently, the leading and trailing arrows are not implemented. See [this issue](https://github.com/bdlukaa/fluent_ui/issues/14) to learn more

## List Tile

You can use a `ListTile` in a `ListView`.

### Example

```dart
final people = {
  'Mass in B minor': 'Johann Sebastian Bach',
  'Third Symphony': 'Ludwig van Beethoven',
  'Serse': 'George Frideric Hendel',
};

ListView.builder(
  itemCount: people.length,
  itemBuilder: (context, index) {
    final title = people.keys[index];
    final subtitle = people[title];
    return ListTile(
      leading: CircleAvatar(),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
),
```

The code above produces the following:

![Double Line Example](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/listitems/doublelineexample.png)

If you want to create a tappable tile, use `TappableListTile` instead.

You can create the following variations of a `ListTile`:

- CheckboxListTile: a `TappableListTile` with a `Checkbox` in the leading.
- SwitchListTile: a `TappableListTile` with a `ToggleSwitch` in the leading.
- RadioListTile: a `TappableListTile` with a `RadioButton` in the leading.

They share a single pattern. Here's how to implement the following image:

![CheckboxListTile Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/checkbox1.png)

```dart
CheckboxListTile(
  value: true,
  onChanged: (v) => print(v),
  title: Text(
    'I agree to the terms of service for this site',
    style: TextStyle(fontWeight: FontWeight.normal),
  ),
)
```

### Screenshots

![Single line](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/listitems/singlelineicon.png)\
![Double line](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/listitems/doublelineicon.png)\
![Three line](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/listitems/tripleline.png)

## Info Header

You can use an `InfoHeader` to tell the user the purpose of something

### Example

```dart
InfoHeader(
  header: 'Control header',
  child: ComboBox(...),
),
```

The code above produces the following:

![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/combo_box_collapsed.png)

Some widgets, such as `ComboBox` and `TextBox`, already come with a `header` property, so you can use them easily with them:

```dart
ComboBox(
  header: 'Control header',
  ...
)
```

This will produce the same as the image above.

# Mobile Widgets

Widgets with focus on mobile. Based on the official documentation and source code for [iOS](https://developer.microsoft.com/pt-br/fluentui#/controls/ios) and [Android](https://developer.microsoft.com/pt-br/fluentui#/controls/android). Most of the widgets above can adapt to small screens, and will fit on all your devices.

## Bottom Sheet

Bottom Sheet is used to display a modal list of menu items. They slide up over the main app content as a result of a user triggered action. [Learn more](https://developer.microsoft.com/pt-br/fluentui#/controls/android/bottomsheet)

Here's an example of how to display a bottom sheet:

```dart
showBottomSheet(
  context: context,
  builder: (context) {
    return BottomSheet(
      // header: ...,
      description: Text('Description or Details here'),
      children: [
        ...,
        // Usually a `ListTile` or `TappableListTile`
      ],
    );
  },
),
```

To close it, just call `Navigator.of(context).pop()`

![Bottom Sheet Showcase](https://static2.sharepointonline.com/files/fabric/fabric-website/images/controls/android/updated/img_bottomsheet_01_light.png?text=LightMode)

## Chip

Chips are compact representations of entities (most commonly, people) that can be clicked, deleted, or dragged easily.

Here's an example of how to create a chip:

```dart
Chip(
  image: CircleAvatar(size: 12.0),
  text: Text('Chip'),
),
Chip.selected(
  image: FlutterLogo(size: 14.0),
  text: Text('Chip'),
)
```

![Light Chips](https://user-images.githubusercontent.com/45696119/119724339-f9a00700-be44-11eb-940b-1966eefe3798.png)

![Dark Chips](https://user-images.githubusercontent.com/45696119/119724337-f9077080-be44-11eb-9b73-e1dc4ffbeefd.png)

## Pill Button Bar

A Pill Button Bar is a horizontal scrollable list of pill-shaped text buttons in which only one button can be selected at a given time.

Here's an example of how to create a pill button bar:

```dart
int index = 0;

PillButtonBar(
  selected: index,
  onChanged: (i) => setState(() => index = i),
  items: [
    PillButtonBarItem(text: Text('All')),
    PillButtonBarItem(text: Text('Mail')),
    PillButtonBarItem(text: Text('Peopl')),
    PillButtonBarItem(text: Text('Events')),
  ]
)
```

![Light PillButtonBar](https://static2.sharepointonline.com/files/fabric/fabric-website/images/controls/ios/updated/img_pillbar_01_light.png?text=LightMode)

![Dark PillButtonBar](https://static2.sharepointonline.com/files/fabric/fabric-website/images/controls/ios/updated/img_pillbar_01_dark.png?text=DarkMode)

## Snackbar

Snackbars provide a brief message about an operation at the bottom of the screen. They can contain a custom action or view or use a style geared towards making special announcements to your users.

Here's an example of how to display a snackbar at the bottom of the screen:

```dart
showSnackbar(
  context,
  Snackbar(
    content: Text('A new update is available!'),
  ),
);
```

![Snackbar Example](https://static2.sharepointonline.com/files/fabric/fabric-website/images/controls/android/updated/img_snackbar_01_standard_dark.png?text=DarkMode)

---

### Equivalents with the material library

The list of equivalents between this library and `flutter/material.dart`

| Material                  | Fluent           |
| ------------------------- | ---------------- |
| TextButton                | Button           |
| IconButton                | IconButton       |
| Checkbox                  | Checkbox         |
| RadioButton               | RadioButton      |
| -                         | RatingBar        |
| -                         | SplitButton      |
| -                         | ToggleButton     |
| Switch                    | ToggleSwitch     |
| TextField                 | TextBox          |
| DropdownButton            | ComboBox         |
| -                         | AutoSuggestBox   |
| AlertDialog               | ContentDialog    |
| MaterialBanner            | InfoBar          |
| Tooltip                   | Tooltip          |
| -                         | Flyout           |
| Drawer                    | NavigationPane   |
| BottomNavigation          | BottomNavigation |
| Divider                   | Divider          |
| VerticalDivider           | Divider          |
| Material                  | Acrylic          |
| ListTile                  | ListTile         |
| RadioListTile             | RadioListTile    |
| CheckboxListTile          | CheckboxListTile |
| SwitchListTile            | SwitchListTile   |
| LinearProgressIndicator   | ProgressBar      |
| CircularProgressIndicator | ProgressRing     |
| \_DatePickerDialog        | DatePicker       |
| \_TimePickerDialog        | TimePicker       |
| Scaffold                  | ScaffoldPage     |
| AppBar                    | NavigationAppBar |
| Drawer                    | NavigationView   |
| Chip                      | Chip             |
| Snackbar                  | Snackbar         |
| -                         | PillButtonBar    |

## Contribution

Feel free to [file an issue](https://github.com/bdlukaa/fluent_ui/issues/new) if you find a problem or [make pull requests](https://github.com/bdlukaa/fluent_ui/pulls).

All contributions are welcome :)

### Acknowledgements

Irrespective of order, thanks to all the people below for contributing with the project. It means a lot to me :)

- [@HrX03](https://github.com/HrX03) for the `Acrylic` implementation.
- [@raitonubero](https://github.com/raitonoberu) for `StickyNavigationIndicator`, `ProgressBar` and `ProgressRing`
- [@alexmercerind](https://github.com/alexmercerind) for the [flutter_acrylic](https://github.com/alexmercerind/flutter_acrylic) plugin, used on the example app
- [@bitsdojo](https://github.com/bitsdojo) for the [bitsdojo_window](https://github.com/bitsdojo/bitsdojo_window) plugin, used on the example app.
