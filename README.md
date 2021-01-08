# fluent_ui

Implements Fluent UI to flutter. This library can be considered as an alternative to react's fluent ui lib. It's based on the official documentation: https://developer.microsoft.com/en-us/fluentui#/styles/web.

## Motivation

Since flutter has Windows support, it's necessary to have support to its ui guidelines (as it has Material and Cupertino support) to build apps with fidelity.
See [this](https://github.com/flutter/flutter/issues/46481) for more info on the offical fluent ui support

## Documentation

### Layout

You can use a `Scaffold` to create your layout.

```dart
Scaffold(
  header: AppBar(
    title: Text('Fluent UI App Showcase'),
    bottom: Pivot(
      currentIndex: index,
      onChanged: (i) => setState(() => index = i),
      pivots: [
        PivotItem(text: Text('Buttons')),
        PivotItem(text: Text('Surfaces')),
      ],
    ),
  ),
  body: PivotView(
    currentIndex: index,
    pages: <Widget>[
      Page1(),
      Page2(),
    ]
  ),
)
```

### [Icons](https://developer.microsoft.com/en-us/fluentui#/styles/web/icons#available-icons)

To use icons, add `fluentui_system_icons` to your dependencies in `pubspec.yaml` file:

```yaml
dependencies:
    ...
    fluentui_system_icons: ^1.1.89
```

Simple usage example:

```dart
import 'package:fluentui_system_icons/fluent_icons.dart';

class MyFlutterWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return IconButton(
      // Use the FluentIcons. + name of the icon you want
      icon: Icon(FluentIcons.access_time_24_regular),
      onPressed: () => print("Button pressed"),
    );
  }
}
```

For more info see [this](https://pub.dev/packages/fluentui_system_icons)

### [Colors](https://developer.microsoft.com/en-us/fluentui#/styles/web/colors/)

To use a Color, just call `Colors.(colorName)`.

```dart
final black = Colors.black;
final blue = Colors.blue;
```

### [Motion](https://docs.microsoft.com/en-us/windows/uwp/design/motion/)

Flutter already provides a great set of Motion/Animation Widgets. All of them are supported.
[Learn more](https://flutter.dev/docs/development/ui/widgets/animation)

### [Page transition](https://docs.microsoft.com/en-us/windows/uwp/design/motion/page-transitions)

#### [Page refresh](https://docs.microsoft.com/en-us/windows/uwp/design/motion/page-transitions#page-refresh)

Use an AnimatedSwitcher to achieve the same effect:
```dart
AnimatedSwitcher(
  child: [widget1(), widget2()][currentPage],
  transitionBuilder: (child, animation) {
    return PageRefreshTransition(child: child, animation: animation);
  }
)
```

#### [Drill](https://docs.microsoft.com/en-us/windows/uwp/design/motion/page-transitions#drill)

It's the same as a [Hero](https://flutter.dev/docs/development/ui/animations/hero-animations) animation.

### [Buttons](https://developer.microsoft.com/en-us/fluentui#/controls/web/button)

You can create the buttons using the `Button` widget. It's the default implementation for `DefaultButton`, `PrimaryButton`, `CompoundButton`, `ActionButton` and `ContextualButton`

- Button
  ```dart
  Button(
    text: Text('I am your button :)'),
    onPressed: () => print('pressed'),
  ),
  Button.action(...), // Creates an ActionButton
  Button.compound(...), // Creates a CompoundButton
  Button.contextual(...), // Creates a ContextualButton
  Button.icon(...) /// Creates an IconButton
  Button.primary(...) /// Creates a PrimaryButton
  ```
- IconButton
  ```dart
  IconButton(
    icon: MyIcon(),
    onPressed: () {},
  ),
  IconButton.menu(
    icon: MyIcon(),
    menu: MyMenu(),
    onPressed: openMenu,
  ),
  ```
- [Checkbox](https://developer.microsoft.com/en-us/fluentui#/controls/web/checkbox#usage)
  ```dart
  bool value = true;
  Checkbox(
    checked: value,
    onChange: (v) => setState(() => value = v),
  ),
  ```

### ListCells

The implementation for `ListCell`. You can create cells with `checkbox`es and `toggle`s

```dart
ListCell(title: Text('MyList')),
Divider(),
ListCell.checkbox(...),
Divider(),
ListCell.toggle(...),
```

### Pop-ups

- `Dialog` and `Modal`
  ```dart
  showDialog(
    context: context,
    builder: (context) => Dialog(
      title: Text('My title'),
      body: Text('The body'),
      footer: [
        Button.primary(text: Text('Button 1')),
        Button(text: Text('Button 1')),
      ],
    ),
  );
  ```
- `Snackbar`
  ```dart
  showSnackbar(
    context: context,
    snackbar: Snackbar(
      title: Text('My beautiful snackbar'),
        button: Button.primary(
          text: Text('Button'),
          onPressed: () {},
        ),
      ),
    );
  ```

## Theming

Almost every widget has a style in `Theme`. There isn't a specific class for any widget theme, all of them are in `Theme`.

```dart
Theme(
  cardStyle: CardStyle(...),
),
```

### ButtonState

You'll find `ButtonState<T>` in some props in `Style`. That's because you need to handle what will be rendered in different button states. For example:

```dart
ButtonStyle(
  color: (state) {
    if (state.isDisabled) return disabledColor;
    else if (state.isHovering) return hoveringColor;
    else if (state.isPressing) return pressingColor;
    else return defaultColor;
  },
),
```

There are four states:

- Disabled - When the button is disabled. Usually when `onPressed` is `null`
- Hovering - When the mouse is over the button. This collor is lighter than `pressing`'s
- Pressing - When the mouse is clicking the button or when the screen is being tapped.
- None - When nothing is happening to the button.

# Material equivalents

| Material            | Fluent           |
| :------------------ | :--------------- |
| Scaffold            | Scaffold         |
| AppBar              | AppBar           |
| Dialog              | Dialog           |
| Card                | Card             |
| Checkbox            | Checkbox         |
| Divider             | Divider          |
| TabBar              | Pivot            |
| TabBarView          | PivotView        |
| ListTile            | ListCell         |
| Switch              | Toggle           |
| Icon                | Icon             |
| IconButton          | IconButton       |
| TextButton          | Button           |
| Snackbar            | Snackbar         |
| BottomNavigationBar | BottomNavigation |

## Avaiable widgets

- Scaffold
- AppBar. Implementation for [Android Top App Bar](https://developer.microsoft.com/en-us/fluentui#/controls/android/topappbar) and [iOS Navigation Bar](https://developer.microsoft.com/en-us/fluentui#/controls/ios/navigationbar)
- BottomNavigation. Implementation for [Android Bottom Navigation](https://developer.microsoft.com/en-us/fluentui#/controls/android/bottomnavigation) and [iOS Tab Bar](https://developer.microsoft.com/en-us/fluentui#/controls/ios/tabbar)
- Button
- IconButton
- [Card](https://developer.microsoft.com/en-us/fluentui#/controls/web/modal)
- [Checkbox](https://developer.microsoft.com/en-us/fluentui#/controls/web/checkbox#usage)
- [Dialog](https://developer.microsoft.com/en-us/fluentui#/controls/web/dialog)
- Divider
- [Pivot](https://developer.microsoft.com/en-us/fluentui#/controls/web/pivot), PivotView
- ListCell
- CheckboxListCell
- [Snackbar](https://developer.microsoft.com/en-us/fluentui#/controls/android/snackbar)
- ToggleListCell

# Other

### Null safety

Null safety support will be avaiable once it reaches stable

### TODO:

- Fix tooltip fidelity
- Implement slider
- Implement dropdown
- [Sound](https://docs.microsoft.com/en-us/windows/uwp/design/style/sound)