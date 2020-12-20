# fluent_ui

Implements Fluent UI to flutter. This library can be considered as an alternative to react's fluent ui lib. It's based on the official documentation: https://developer.microsoft.com/en-us/fluentui#/styles/web.

## Motivation

Since flutter has Windows support, it's necessary to have support to its ui guidelines (as it has Material and Cupertino support) to build apps with fidelity.
See [this](https://github.com/flutter/flutter/issues/46481) for more info on the offical fluent ui support

## Documentation
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

### [Buttons](https://developer.microsoft.com/en-us/fluentui#/controls/web/button) 
You can create the buttons using the `Button` widget. It's the default implementation for `DefaultButton`, `PrimaryButton` and `CompoundButton`
- Button
  ```dart
  Button(
    text: Text('I am your button :)'),
    onPressed: () => print('pressed'),
  ),
  Button.compound(
    text: Text('I am the title'),
    subtext: Text('I am the subtitle'),
    onPressed: null, // disable the button
  )
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

## Avaiable widgets
- Scaffold
- [AppBar](https://developer.microsoft.com/en-us/fluentui#/controls/android/topappbar)
- Button
- IconButton
- [Card](https://developer.microsoft.com/en-us/fluentui#/controls/web/modal)