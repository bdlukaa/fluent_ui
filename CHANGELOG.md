## 4.0.1

- `PaneItemAction.body` is no longer required ([#545](https://github.com/bdlukaa/fluent_ui/issues/545))
- Added `DropDownButton.onOpen` and `DropDownButton.onClose` callbacks ([#537](https://github.com/bdlukaa/fluent_ui/issues/537))
- Ensure `MenuFlyoutItem.onPressed` is called after the flyout is closed if `DropDownButton.closeAfterClick` is true ([#520](https://github.com/bdlukaa/fluent_ui/issues/520))
- Ensure the `TimePicker` and `DatePicker` popups will fit if the screen is small ([#544](https://github.com/bdlukaa/fluent_ui/issues/544))
- Do not apply padding to `NavigationAppBar.leading` ([#539](https://github.com/bdlukaa/fluent_ui/issues/539))
- Added `AutoSuggestBox.noResultsFoundBuilder` ([#542](https://github.com/bdlukaa/fluent_ui/issues/542))
- Added `AutoSuggestBox.inputFormatters` ([#542](https://github.com/bdlukaa/fluent_ui/issues/542))
- Added support for Hebrew language

## 4.0.0

- **BREAKING** Removed `NavigationBody`. Use `PaneItem.body` instead ([#510](https://github.com/bdlukaa/fluent_ui/pull/510)/[#531](https://github.com/bdlukaa/fluent_ui/pull/531)):  
  Before:
  ```dart
  NavigationView(
    pane: NavigationPane(
      items: [
        PaneItem(icon: Icon(FluentIcons.add)),
        PaneItem(icon: Icon(FluentIcons.add)),
        PaneItem(icon: Icon(FluentIcons.add)),
      ],
    ),
    content: NavigationBody(
      children: [
        _Item1(),
        _Item2(),
        _Item3(),
      ],
    ),
  ),
  ```

  Now:  
  ```dart
  NavigationView(
    ...
    pane: NavigationPane(
      items: [
        PaneItem(
          icon: Icon(FluentIcons.add),
          body: _Item1(),
        ),
        PaneItem(
          icon: Icon(FluentIcons.add),
          body: _Item2(),
        ),
        PaneItem(
          icon: Icon(FluentIcons.add),
          body: _Item3(),
        ),
      ],
    ),
  ),
  ```
  
  Or if you don't have a pane, you can use the content like the following:  
  ```dart
  NavigationView(
    content: ScaffoldPage(
      header: PageHeader(
        title: titleRow,
      ),
      content: child,
    ),
  ),
  ```
  *either one attribute of pane or content must not be null*

  Use `NavigationView.transitionsBuilder` to create custom transitions
- Added `PaneItem.onTap` ([#533](https://github.com/bdlukaa/fluent_ui/issues/533))
- Compact pane is no longer toggled when item is selected ([#533](https://github.com/bdlukaa/fluent_ui/issues/533)).
  To toggle it programatically, use `NavigationViewState.toggleCompactOpenMode` when an item is tapped
- Dynamic header height for open pane ([#530](https://github.com/bdlukaa/fluent_ui/issues/530))
- Fixes memory leaks on `NavigationView`
- `TreeView` updates: 
  - All items of the same depth level now have the same indentation. Before, only items with the same parent were aligned.
  - The hitbox for the expand icon of each item now uses the item's full height and is three times wider than the actual icon. This corresponds to the implementation in the explorer of Windows 10/11.
  - You can now choose whether the items of a TreeView should use narrow or wide spacing.
  - Do not invoke the tree view item on secondary tap ([#526](https://github.com/bdlukaa/fluent_ui/issues/526))
  - **BREAKING** `TreeView.onSecondaryTap` is now a `(TreeViewItem item, TapDownDetails details)` callback:
    Before:
    ```dart
    TreeView(
      ...,
      onSecondaryTap: (item, offset) async {}
    ),
    ```

    Now:
    ```dart
    TreeView(
      ...,
      onSecondaryTap: (item, details) {
        final offset = details.globalPosition;
      },
    )
    ```
  - Expand/collape items with right and left arrow keys, respectively ([#517](https://github.com/bdlukaa/fluent_ui/issues/517))
  - Added `TreeView.onItemExpandToggle` and `TreeViewItem.onExpandToggle` ([#522](https://github.com/bdlukaa/fluent_ui/issues/522))
- **BREAKING** `AutoSuggestBox` dynamic type support ([#441](https://github.com/bdlukaa/fluent_ui/issues/441)):

  Before:
  ```dart
  AutoSuggestBox(
    items: cats.map((cat) {
      return AutoSuggestBoxItem(
        value: cat,
        onFocusChange: (focused) {
          if (focused) debugPrint('Focused $cat');
        }
      );
    }).toList(),
    onSelected: (item) {
      setState(() => selected = item);
    },
  ),
  ```
  
  Now:
  ```dart
  AutoSuggestBox<String>(
    items: cats.map((cat) {
      return AutoSuggestBoxItem<String>(
        value: cat,
        label: cat,
        onFocusChange: (focused) {
          if (focused) debugPrint('Focused \$cat');
        }
      );
    }).toList(),
    onSelected: (item) {
      setState(() => selected = item);
    },
  ),
  ```

## [4.0.0-pre.4] - Almost there - [02/09/2022]

- `DisableAcrylic` now fully disable transparency of its decendents `Acrylic`s ([#468](https://github.com/bdlukaa/fluent_ui/issues/468))
- Do not interpolate between infinite constraints on `TabView` ([#430](https://github.com/bdlukaa/fluent_ui/issues/430))
- Do not rebuild the `TimePicker` popup when already rebuilding ([#437](https://github.com/bdlukaa/fluent_ui/issues/437))
- `ToggleSwitch` updates:
  - Use the correct color for `DefaultToggleSwitchThumb` ([#463](https://github.com/bdlukaa/fluent_ui/issues/463))
  - Added `ToggleSwitch.leadingContent`, which positions the content before the switch ([#464](https://github.com/bdlukaa/fluent_ui/issues/464))
  - Added `ToggleSwitch.thumbBuilder`, which builds the thumb based on the current state
- Added `TextChangedReason.cleared`, which is called when the text is cleared by the user in an `AutoSuggestBox` ([#461](https://github.com/bdlukaa/fluent_ui/issues/461))
- Call `AutoSuggestBox.onChanged` when an item is selected using the keyboard ([#483](https://github.com/bdlukaa/fluent_ui/issues/483))
- `Tooltip` overlay is now ignored when hovered ([#443](https://github.com/bdlukaa/fluent_ui/issues/443))
- Do not add unnecessary padding in `DropdownButton` ([#475](https://github.com/bdlukaa/fluent_ui/issues/475))
- `ComboBox` updates:
  - **BREAKING** Renamed `Combobox` to `ComboBox`
  - **BREAKING** Renamed `ComboboxItem` to `ComboBoxItem`
  - **BREAKING** Renamed `ComboBox.backgroundColor` to `ComboBox.popupColor`
  - Implement `EditableComboBox`, a combo box that accepts items that aren't listed ([#244](https://github.com/bdlukaa/fluent_ui/issues/244))
  - `ComboBox.isExpanded: false` now correctly sets the button width ([#382](https://github.com/bdlukaa/fluent_ui/issues/382))
  - `ComboBox`'s items height are correctly calculated, as well as initial scroll offset ([#472](https://github.com/bdlukaa/fluent_ui/issues/478))
  - **BREAKING** `ComboBox.disabledHint` was renamed to `ComboBox.disabledPlaceholder`
  - Added `ComboBoxFormField` and `EditableComboBoxFormField` ([#373](https://github.com/bdlukaa/fluent_ui/issues/373))
  - `ComboBox.comboBoxColor` is now correctly applied ([#468](https://github.com/bdlukaa/fluent_ui/issues/468))
  - `ComboBox` popup can't be opened if disabled
- Implemented `PaneItemExpander` ([#299](https://github.com/bdlukaa/fluent_ui/pull/299))
- `TimePicker` and `DatePicker` popup now needs a minimum width of 260 ([#494](https://github.com/bdlukaa/fluent_ui/pull/494))
- Correctly align `NavigationAppBar` content ([#494](https://github.com/bdlukaa/fluent_ui/pull/494))
- **BREAKING** Added `InfoLabel.rich`. `InfoLabel` is no longer a constant contructor ([#494](https://github.com/bdlukaa/fluent_ui/pull/494))
- Always add `GlobalMaterialLocalizations` above `ReorderableListView` ([#492](https://github.com/bdlukaa/fluent_ui/issues/492))
- **BREAKING** Removed `ContentDialog.backgroundDismiss`. Use `showDialog.barrierDismissable` ([#490](https://github.com/bdlukaa/fluent_ui/issues/490))
- Reviewed focus ([#496](https://github.com/bdlukaa/fluent_ui/issues/496))
  - `DatePicker` and `TimePicker` now show the focus highlight.
    Their popup now can be controlled using the keyboard
  - `NavigationBody` now uses a `FocusTraversalGroup` to handle focus
    This means the the content of the body will be fully traversed before moving on to another widget or group of widgets. [Learn more](https://docs.flutter.dev/development/ui/advanced/focus#focustraversalgroup-widget)
  - `TreeViewItem` now shows the focus highlight. They can also be selected using the keyboard
  - `Expander` now shows the focus highlight
- Progress Indicators velocity is no longer affected by device frame rate ([#502](https://github.com/bdlukaa/fluent_ui/pull/502))
- Added `AutoSuggestBox.enabled` ([#504](https://github.com/bdlukaa/fluent_ui/issues/504))
- Correctly keep the `NavigationView` animation state ([cf0fae1](https://github.com/bdlukaa/fluent_ui/commit/cf0fae16ce9a8879653606571e90af12f711bb84) ,[bd89ba6](https://github.com/bdlukaa/fluent_ui/commit/bd89ba6791dfe2762b37b3e291d8d1a7979cb3f5))
- Calculate `selected` for all parents as soon as the `TreeView` is built

## [4.0.0-pre.3] - Top navigation and auto suggestions - [13/08/2022]

- `NavigationView` mode fixes:
  - When top overflow menu is opened, `PaneItemHeader` no longer throws an unsupported error
  - When on top mode, `PaneItemHeader` is properly aligned to the other items.
  - Added `NavigationPaneThemeData.headerPadding`, which is applied to `PaneItemHeader` on open, compact and minimal mode. It defaults to 10 pixels at the top
  - **BREAKING** `PaneItem.getPropertyFromTitle` is now `widget.getProperty`:

  Before:
  `getPropertyFromTitle<TextStyle>()`

  Now:
  `title.getProperty<TextStyle>()`

  This was changed because the properties of `PaneItemHeader` needed to be accessed, but the old version only supported to get the properties of `PaneItem.title`. It can be called on a `Text`, `RichText` or in an `Icon` widget
  - `InheritedNavigationView` is now accessible on the top overflow menu
  - Added `NavigationPaneThemeData.selectedTopTextStyle` and `NavigationPaneThemeData.unselectedTopTextStyle`, which is applied to the items on top mode
  - Fixed `content` focus on minimal mode
  - Updated default transitions for top mode: `HorizontalSlidePageTransition`
- Fix incorrect translation of `TimePicker` in Traditional Chinese.
- Added `ScaffoldPage.resizeToAvoidBottomInset` ([#444](https://github.com/bdlukaa/fluent_ui/issues/444))
- Consider view padding for `NavigationAppBar`
- `Scrollbar` updates ([#356](https://github.com/bdlukaa/fluent_ui/pull/356)):
  - Correctly use `backgroundColor` to display the track color
  - Added `padding` and `hoveringPadding`
  - Check if animation is disposed before using it ([#446](https://github.com/bdlukaa/fluent_ui/issues/446))
- Update `AutoSuggestBox` ([#450](https://github.com/bdlukaa/fluent_ui/pull/450)):
  - Added `.enableKeyboardControls`. When true, items can be selected using the keyboard ([#19](https://github.com/bdlukaa/fluent_ui/issues/19))
  - Added `.sorter`, which lets you set a custom sort function for the suggestions. `AutoSuggestBox.defaultItemSorter` is used by default
  - Overlay's height is now correctly calculated based on the screen size. It no longer overlaps the screen. `viewPadding` is also taken into consideration
  - Close the overlay if the textbox width is changes ([#456](https://github.com/bdlukaa/fluent_ui/issues/456))
  - `.items` can be dynamically loaded ([#387](https://github.com/bdlukaa/fluent_ui/issues/387))
  - **BREAKING** `.items` is now a `List<AutoSuggestBoxItem>`:
    Before:
  ```dart
  AutoSuggestBox(
    items: [
      'Cat',
      'Dog',
      'Bird',
      'Horse',
    ],
    ...
  ),
  ```
  Now:
  ```dart
  AutoSuggestBox(
    items: [
      'Cat',
      'Dog',
      'Bird',
      'Horse',
    ].map((animal) {
      return AutoSuggestBoxItem(
        value: animal, // this takes a String
        child: Text('Animal $animal'), // this takes a Widget. If null, value is displayed as a text
        onFocusChange: (focused) {
          // this is called when the item is focused using the keyboard arrow keys
          if (focused) debugPrint('Focused animal $animal');
        },
        onSelected: () {
          // this is called when the item is selected
          debugPrint('Selected animal $animal');
        }
      );
    }).toList(),
    ...
  )
  ```
- `Combobox` updates ([#454](https://github.com/bdlukaa/fluent_ui/pull/454)):
  - Popup size is now correctly calculated ([#413](https://github.com/bdlukaa/fluent_ui/issues/413))
  - Correctly clip the popup while performing the animation ([#379](https://github.com/bdlukaa/fluent_ui/issues/379))
- Correctly check if a locale is supported ([#455](https://github.com/bdlukaa/fluent_ui/issues/455))

## [4.0.0-pre.2] - Tabs, Tiles and Bugs - [23/07/2022]

- Remove whitespace on `ContentDialog` if title is omitted ([#418](https://github.com/bdlukaa/fluent_ui/issues/418))
- Apply correct color to the Date and Time Pickers button when selected ([#415](https://github.com/bdlukaa/fluent_ui/issues/415), [#417](https://github.com/bdlukaa/fluent_ui/issues/417))
- Expose more useful properties to `AutoSuggestBox` ([#419](https://github.com/bdlukaa/fluent_ui/issues/419))
- **BREAKING** `PopupContentSizeInfo` was renamed to `ContentSizeInfo`
- Reworked `ListTile` ([#422](https://github.com/bdlukaa/fluent_ui/pull/422)):
  - **BREAKING** Removed `TappableListTile`
  - Added support for single and multiple selection. Use `ListTile.selectable` ([#409](https://github.com/bdlukaa/fluent_ui/issues/409))
  - Added focus support
  - Use the Win UI design
- Reviewed animation durations ([#421](https://github.com/bdlukaa/fluent_ui/issues/421))
  - **BREAKING** Removed `.animationDuration` and `.animationCurve` from `ScrollbarThemeData`
  - Added `expandContractAnimationDuration` and `contractDelay` to `ScrollbarThemeData`
- `NavigationPaneSize` constraints are now correctly applied when in open mode ([#336](https://github.com/bdlukaa/fluent_ui/issues/336))
- `NavigationIndicator` can't be invisble anymore when animation is stale ([#335](https://github.com/bdlukaa/fluent_ui/issues/335))
- Updated `TabView`:
  - **BREAKING** Removed `TabView.bodies`. Now, `Tab.body` is used.
    Before
    ```dart
    TabView(
      tabs: [
        Tab(text: Text('Tab 1')),
        Tab(text: Text('Tab 2')),
      ],
      bodies: [
        Tab1Body(),
        Tab2Body(),
      ],
    ),
    ```

    Now:
    ```dart
    TabView(
      tabs: [
        Tab(
          text: Text('Tab 1'),
          body: Tab1Body(),
        ),
        Tab(
          text: Text('Tab 2'),
          body: Tab2Body(),
        ),
      ],
    ),
    ```
  - Updated `TabView` tabs' constraints and padding
  - Fixed tab width when `TabWidthBehavior` is `compact`
  - `FlutterLogo` is no longer the default tab Icon
- `DropDownButton` menu is now sized correctly according to the screen size
- If there isn't enough space to display the menu on the preferred position, `Flyout` will display on the opposite position ([#435](https://github.com/bdlukaa/fluent_ui/pull/435))

## [4.0.0-pre.1] - Materials and Pickers - [29/06/2022]

- Exposed private properties that makes it easier to create custom panes for `NavigationView` ([#365](https://github.com/bdlukaa/fluent_ui/issues/365)):
  - `kCompactNavigationPaneWidth`
  - `kOpenNavigationPaneWidth`
  - `NavigationPane.changeTo`
  - `PaneItem.getPropertyFromTitle`
- `PaneScrollConfiguration` is now applied to custom pane on `NavigationView`
- Added `NavigationViewState.displayMode`. It results in the current display mode used by the view, including the automatic display mode ([#360](https://github.com/bdlukaa/fluent_ui/issues/360)):
  ```dart
  // Define the key
  final key = GlobalKey<NavigationViewState>();

  NavigationView(
    // pass the key to the view
    key: key,
    ...,
  )

  // Get the current display mode. Note that, in order to find out the automatic display mode,
  // the widget must have been built at least once
  final PaneDisplayMode currentDisplayMode = key.currentState.displayMode;
  ```
- The app bar action no longer overflow when minimal pane/compact overlay is open ([#361](https://github.com/bdlukaa/fluent_ui/issues/361))
- Update `AutoSuggestBox`:
  - It now uses `Acrylic`, but it can be disabled using `DisableAcrylic`
  - `TextChangedReason.suggestionChoosen` is now called properly
- Updated `TextBox`:
  - `TextBox` colors were updated to match the Win 11 design.
  - Fluent Text Selection Control now make use of `Acrylic`. Its items were also updated
- Updated pickers ([#406](https://github.com/bdlukaa/fluent_ui/pull/406)):
  - If `selected` is null, a placeholder text is shown ([#306](https://github.com/bdlukaa/fluent_ui/issues/306))
  - Added new localization messages: `hour`, `minute`, `AM`, `PM`, `month`, `day`and `year`.
  - **BREAKING** Removed `.hourPlaceholder`, `.minutePlaceholder`, `.amText`, `.pmText` from `TimePicker`. It was replaced, respectivelly, by the `hour`, `minute`, `AM`, `PM` localization messages
  - On `DatePicker`, it's now possible to change the order of the fields:
  ```dart
  DatePicker(
    ...,
    fieldOrder: [
      DatePickerField.day,
      DatePickerField.month,
      DatePickerField.year,
    ],
  )
  ```

  The fields are ordered based on the current locale by default
  - On `DatePicker`, the day and year fields are now formatted based on the current locale (`getDateOrderFromLocale`)
- Update `Slider` ([#405](https://github.com/bdlukaa/fluent_ui/issues/405)):
  - Added `.thumbRadius` and `.trackHeight` to `SliderThemeData`
  - The active track now isn't taller than the inactive track

## [4.0.0-pre.0] - [07/06/2022]

- Show menu button on automatic minimal display mode ([#350](https://github.com/bdlukaa/fluent_ui/pull/350))
- **BREAKING** `Map<ShortcutActivator, Intent>?` is now the typed used on `FluentApp.shortcuts` ([#351](https://github.com/bdlukaa/fluent_ui/pull/351))
- `TextBox` review ([#352](https://github.com/bdlukaa/fluent_ui/pull/352)):
  - Added `.initialValue`, `.selectionControls`, `.mouseCursor`, `.textDirection`, `.scribbleEnabled` and `.enableIMEPersonalizedLearning` to `TextBox`
  - Added `AutoFillClient` to `TextBox`
  - Added `UnmanagedRestorationScope` to `TextFormBox`
- Added `AutoSuggestBox.form`, that uses `TextFormBox` instead of `TextBox` ([#353](https://github.com/bdlukaa/fluent_ui/pull/353))
- Do not overflow when text is too long on `Chip` ([#322](https://github.com/bdlukaa/fluent_ui/issues/322))
- Add RTL support for `Chip`
- `Card` updates:
  - Updated card's background colors
  - **BREAKING** Removed `Card.elevation`
  - Added `Card.margin`, which is the margin around the card
- Updated `Combobox` and `Button` designs
- Updated `NavigationPane` behaviour. Now, if the header is null, the space it should have taken will be removed from the pane (display mode affected: minimal, open only) ([#359](https://github.com/bdlukaa/fluent_ui/pull/359))
- Reviewed `DatePicker` and `TimePicker` ([#357](https://github.com/bdlukaa/fluent_ui/pull/357))
  - Correctly apply dimensions and positions to both pickers
  - Update the picker popup style and behavior
- Colors Update ([#368](https://github.com/bdlukaa/fluent_ui/pull/368)):
  - Added `ResourceDictionary`, which provides default colors to be used on components
  - (forms) Updated `Combobox` style. It now uses `Acrylic` on the combobox popup menu
  - (buttons) Updated `Button`, `FilledButton`, `IconButton` and `TextButton` styles
  - (toggleable inputs) Updated `Checkbox`, `Chip`, `RadioButton`, `RatingBar`, `ToggleButton` and `ToggleSwitch`
    - **BREAKING** Updated `Slider`:
      - `SliderThemeData.thumbColor`, `SliderThemeData.activeColor` and `SliderThemeData.inactiveColor` now are of type `ButtonState<Color?>?`, which handles the button color on different states. `SliderThemeData.disabledThumbColor`, `SliderThemeData.disabledActiveColor` and `SliderThemeData.disabledInactiveColor` were removed
      - Before:
      ```dart
      SliderThemeData(
        thumbColor: Colors.green,
      ),
      ```
      - Now:
      ```dart
      SliderThemeData(
        // Apply Colors.green for all button states. Instead you can use ButtonState.resolveWith to use different values according to the current state
        thumbColor: ButtonState.all(Colors.green),
      ),
      ```
  - (navigation) Updated `NavigationView`, `PaneItem` and `ScaffoldPage`
    - Updated `TabView` and its tabs styles. A `FocusBorder` is now used to display the focus highlight of the tabs
    - All combinations of `BorderRadius` can now be used on `FocusBorder`
  - (surfaces) Updated `Card`, `ContentDialog`, `InfoBar`, `Expander`, `Flyout` and `Divider``
    - Added `InfoBar.isIconVisible`
  - (indicators) Updated `ProgressBar`, `ProgressRing` and `InfoBadge`
  - (other) Added helper methods for `AccentColor`: `AccentColor.defaultBrushFor`, `AccentColor.secondaryBrushFor` and `AccentColor.tertiaryBrushFor`
  - Polish translation added

## [3.12.0] - Flutter 3.0 - [13/05/2022]

- Add support for Flutter 3.0 (Fixes [#186](https://github.com/bdlukaa/fluent_ui/issues/186), [#327](https://github.com/bdlukaa/fluent_ui/issues/327))

## [3.11.1] - [30/04/2022]

- Reworked `DropDownButton` ([#297](https://github.com/bdlukaa/fluent_ui/pull/297)):
  - `DropDownButton` now uses `Flyout` and `MenuFlyout` to display the menu
  - Added scrolling features and style to `MenuFlyout`
  - `MenuFlyout` content height is now properly calculated (Fixes [#210](https://github.com/bdlukaa/fluent_ui/issues/210))
  - `DropDownButtonItem` is deprecated. `MenuFlyoutItem` should be used instead
  - Added `DropDownButton.buttonBuilder`, which is able to style the button as you wish. `DropDownButton.buttonStyle` is now deprecated
  ```dart
  DropDownButton(
    items: [...],
    // onOpen should be called to open the flyout. If onOpen is null, it means the button
    // should be disabled
    buttonBuilder: (context, onOpen) {
      return Button(
        ...,
        onPressed: onOpen,
      );
    }
  )
  ```
- `TextButton` now uses `textButtonStyle` instead of `outlinedButtonStyle`
- Add `TextFormBox.decoration` ([#312](https://github.com/bdlukaa/fluent_ui/pull/312))

## [3.11.0] - Menu Flyouts - [23/04/2022]

- Implemented `MenuFlyout` ([#266](https://github.com/bdlukaa/fluent_ui/pull/266))
  - Implemented `FlyoutPosition`, which controls where the flyout will be opened according to the child. It can be `above`, `below` or `side`
  - `FlyoutOpenMode.longHover`, which makes possible to open the flyout when the user performs a long hover
  - Added `Flyout.onOpen` and `Flyout.onClose`. Some convenience callbacks that are called when the flyout is opened or closed, respectively
  - Implement `PopupContentSizeInfo`, which provides the information about the content size
  - Implemented `MenuFlyoutItem`, `MenuFlyoutSeparator` and `MenuFlyoutSubItem`. They are used inside `MenuFlyout` to render the menu items
  - `horizontalPositionDependentBox` is now globally available for use as a top function
- Implemented overflow popup on `NavigationView` for top mode ([#277](https://github.com/bdlukaa/fluent_ui/pull/277))
- `InfoBadge` now is correctly positioned on top mode ([#296](https://github.com/bdlukaa/fluent_ui/pull/296))

## [3.10.3] - [15/04/2022]

- Do not use duplicated `Scrollbar`s ([#279](https://github.com/bdlukaa/fluent_ui/pull/279/))
- Allow custom height on `NavigationPane` header. ([#260](https://github.com/bdlukaa/fluent_ui/pull/260/))
- Allow to define the minimal tab width ([#282](https://github.com/bdlukaa/fluent_ui/pull/282/))
- Allow applying custom leading Widget to NavigationPane ([#288](https://github.com/bdlukaa/fluent_ui/pull/288/))
- `TextFormBox.expands` now works properly ([#291]](https://github.com/bdlukaa/fluent_ui/pull/291))
- Focus on `TextBox` is no longer duplicated ([#290](https://github.com/bdlukaa/fluent_ui/pull/290))

## [3.10.2] - [09/04/2022]

- `NavigationView` without pane no longer throws error ([#276](https://github.com/bdlukaa/fluent_ui/issues/276))

## [3.10.1] - [06/04/2022]

- Fix overflow behavior for `TreeViewItem` ([#270](https://github.com/bdlukaa/fluent_ui/pull/270))
- Do not animate sticky indicators when parent is updated ([#273](https://github.com/bdlukaa/fluent_ui/pull/273))
- Add Arabic(ar) localization ([#268](https://github.com/bdlukaa/fluent_ui/pull/268))

## [3.10.0] - Localization, Indicators, CommandBar and Flyouts - [02/04/2022]

- Improves `icons.dart` formatting and its generation ([#215](https://github.com/bdlukaa/fluent_ui/pull/215))
- Use correct color on `FilledButton` when disabled ([209](https://github.com/bdlukaa/fluent_ui/pull/209))
- Built-in support for new languages ([#216](https://github.com/bdlukaa/fluent_ui/pull/216)):
  - English
  - Spanish (reviewed by [@henry2man](https://github.com/henry2man))
  - French (reviewed by [@WinXaito](https://github.com/WinXaito))
  - Brazilian Portuguese (reviewed by [@bdlukaa](https://github.com/bdlukaa))
  - Russian (reviewed by [@raitonoberu](https://github.com/raitonoberu))
  - German (reviewed by [@larsb24](https://github.com/larsb24))
  - Hindi (reviewed by [@alexmercerind](https://github.com/alexmercerind))
  - Simplified Chinese (reviewed by [@zacksleo](https://github.com/zacksleo))
- Add `useInheritedMediaQuery` property to `FluentApp` ([#211](https://github.com/bdlukaa/fluent_ui/pull/211))
- `TreeView` updates ([#255](https://github.com/bdlukaa/fluent_ui/pull/225)):
  - Optional vertical scrolling by setting `shrinkWrap` to `false`
  - TreeViewItem now has a custom primary key (`value` field)
  - Added `onSelectionChanged` callback, called when the selection is changed
- Account for enabled on pressing states ([#233](https://github.com/bdlukaa/fluent_ui/pull/233))
- Implement `CommandBar` ([#232](https://github.com/bdlukaa/fluent_ui/pull/232))
  - Add `DynamicOverflow` layout widget, for one-run horizontal or vertical layout with an overflow widget
  - Add `HorizontalScrollView` helper widget, with mouse wheel horizontal scrolling
- Long `content` widget no longer overflow in `ContentDialog` ([#242](https://github.com/bdlukaa/fluent_ui/issues/242))
- Content state is no longer lost when the pane display mode is changed ([#250](https://github.com/bdlukaa/fluent_ui/pull/250))
- **BREAKING** Update indicators ([#248](https://github.com/bdlukaa/fluent_ui/pull/248)):
  - Added `InheritedNavigationView`
  - Updated sticky indicator to match the latest Win 11 UI ([#173](https://github.com/bdlukaa/fluent_ui/issues/173))
  - **BREAKING** Renamed `NavigationPane.indicatorBuilder` to `NavigationPane.indicator`
  - **BREAKING** Indicators are no longer built with functions
    Before:
    ```dart
    indicatorBuilder: ({
      required BuildContext context,
      required NavigationPane pane,
      required Axis axis,
      required Widget child,
    }) {
      if (pane.selected == null) return child;
      assert(debugCheckHasFluentTheme(context));
      final theme = NavigationPaneTheme.of(context);

      final left = theme.iconPadding?.left ?? theme.labelPadding?.left ?? 0;
      final right = theme.labelPadding?.right ?? theme.iconPadding?.right ?? 0;

      return StickyNavigationIndicator(
        index: pane.selected!,
        pane: pane,
        child: child,
        color: theme.highlightColor,
        curve: Curves.easeIn,
        axis: axis,
        topPadding: EdgeInsets.only(left: left, right: right),
      );
    }
    ```

    Now:
    ```dart
    indicator: StickyNavigationIndicator(
      color: Colors.blue.lighter, // optional
    ),
    ```
- `initiallyExpanded` property on `Expander` works properly ([#252](https://github.com/bdlukaa/fluent_ui/pull/252))
- **BREAKING** Flyout changes:
  - Removed `Flyout.contentWidth` and added `FlyoutContent.constraints`. Now the content will be automatically sized and layed out according to the placement
  - Added `Flyout.placement` which takes a `FlyoutPlacement`
  - Added `Flyout.openMode` which takes a `FlyoutOpenMode`
  - `Flyout.controller` is no longer required. If not provided, a local controller is created to handle the `Flyout.openMode` settings
  - **Breaking** `FlyoutController.open` is now a function
  - Added `FlyoutController.isOpen`, `FlyoutController.isClosed`, `FlyoutController.close()`, `FlyoutController.open()` and `FlyoutController.toggle()`
  - **Breaking** Removed `Popup.contentHeight`
- **BREAKING** Updated typography ([#261](https://github.com/bdlukaa/fluent_ui/pull/261)):
  - Renamed `Typography.standart` to `Typography.fromBrightness`
  - Renamed `Typography` constructor to `Typography.raw`
  - Default color for dark mode is now `const Color(0xE4000000)`
  - Updated default font sizes for `display`, `titleLarge`, `title` and `subtitle`
- `TabWidthBehavior.sizeToContent` now works properly ([#218](https://github.com/bdlukaa/fluent_ui/issues/218))

## [3.9.1] - Input Update - [25/02/2022]

- `TextBox` updates: ([#179](https://github.com/bdlukaa/fluent_ui/pull/179))
  - Correctly apply the `style` property
  - Correctly apply `decoration` to the background
  - Added `foregroundDecoration` and `highlightColor` property. They can not be specified at the same time
  - **BREAKING** replaced `maxLengthEnforeced` with `maxLengthEnforcement`
- Expose more propertied to `TextFormBox`
- `AutoSuggestBox` updates:
  - Improved fidelity of the suggestions overlay expose more customization properties ([#174](https://github.com/bdlukaa/fluent_ui/issues/174))
  - When a suggestion is picked, the overlay is automatically closed and the text box is unfocused
  - Clear button now only shows when the text box is focused
- Add directionality support ([#184](https://github.com/bdlukaa/fluent_ui/pull/184))
- Correctly apply elevation for `DropDownButton` overlay ([#182](https://github.com/bdlukaa/fluent_ui/issues/182))
- Show app bar even if `NavigationPane` is not provided on `NavigationView` ([#187](https://github.com/bdlukaa/fluent_ui/issues/187))
- Ensure `NavigationAppBar.actions` are rendered on the top of the other widgets ([#177](https://github.com/bdlukaa/fluent_ui/issues/177))
- All Form widgets now have the same height by default
- Only show one scrollbar on `ComboBox` overlay
- Fix opened pane opacity
- Added `menuColor` for theme, which is now used by dropdown button, auto suggest box, tooltip and content dialog
- Added `Card` and `cardColor` for theme
- Update fluent text controls and added support for `SelectableText` ([#196](https://github.com/bdlukaa/fluent_ui/pull/196))

## [3.9.0] - Fidelity - [10/02/2022]

- **BREAKING** Renamed `standartCurve` to `standardCurve`
- **BREAKING** Completly rework `DropDownButton`
- **BREAKING** Removed `CheckboxThemeData.thirdStateIcon`

  Currently, there isn't a fluent icon that is close to the native icon. A local widget *`_ThirdStateDash`* is used
- Do not override material `Theme` on `FluentApp` ([#155](https://github.com/bdlukaa/fluent_ui/pull/154))
- Slider thumb now doesn't change inner size if hovered while disabled
- Uniform foreground color on `Checkbox`
- Updated `FilledButton` Style
- `ToggleButton` and `FilledButton` now share the same style
- `ScaffoldPage.scrollable` and `ScaffoldPage.withPadding`
- Ensure we use `Typography.body` as the default text style on `BaseButton` ([#120](https://github.com/bdlukaa/fluent_ui/issues/160))
- Update `ButtonThemeData.uncheckedInputColor`

## [3.8.0] - Flutter Favorite - [03/02/2022]

- Tests ([#142](https://github.com/bdlukaa/fluent_ui/pull/142))
- Added Material Theme to Fluent Theme Builder ([#133](https://github.com/bdlukaa/fluent_ui/issues/133))
- Add more customization options to PaneItem ([#111](https://github.com/bdlukaa/fluent_ui/issues/111), [#144](https://github.com/bdlukaa/fluent_ui/issues/144))
- `NavigationView` updates **BREAKING**:
  - Properly add item key to `PaneItem` in top mode ([#143](https://github.com/bdlukaa/fluent_ui/issues/143))
  - Items bounds and positions are fetched when the item list is scrolled as well to prevent misalignment
  - Added the helper functions `NavigationIndicator.end` and `NavigationIndicator.sticky`
  - Use `Curves.easeIn` for sticky navigation indicator by default
  - Use the correct accent color for navigation indicators by default
  - `EntrancePageTransition` is now the correct page transition used when display mode is top
  - Apply correct press effect for `PaneItem` when display mode is top
  - **BREAKING** Removed `NavigationPane.defaultNavigationIndicator`
  - **BREAKING** Replaced `offsets` and `sizes` with `pane` in `NavigationPane`

  Before:
  ```dart
  pane: NavigationPane(
    indicatorBuilder: ({
      required BuildContext context,
      /// The navigation pane corresponding to this indicator
      required NavigationPane pane,
      /// Corresponds to the current display mode. If top, Axis.vertical
      /// is passed, otherwise Axis.vertical
      Axis? axis,
      /// Corresponds to the pane itself as a widget. The indicator is
      /// rendered over the whole pane.
      required Widget child,
    }) {
      if (pane.selected == null) return child;
      assert(debugCheckHasFluentTheme(context));
      final theme = NavigationPaneThemeData.of(context);

      axis??= Axis.horizontal;

      return EndNavigationIndicator(
        index: pane.selected,
        offsets: () => pane.effectiveItems.getPaneItemsOffsets  (pane.paneKey),
        sizes: pane.effectiveItems.getPaneItemsSizes,
        child: child,
        color: theme.highlightColor,
        curve: theme.animationCurve ?? Curves.linear,
        axis: axis,
      );
    },
  ),
  ```

  Now:
  ```dart
  pane: NavigationPane(
    indicatorBuilder: ({
      required BuildContext context,
      /// The navigation pane corresponding to this indicator
      required NavigationPane pane,
      /// Corresponds to the current display mode. If top, Axis.vertical
      /// is passed, otherwise Axis.vertical
      required Axis axis,
      /// Corresponds to the pane itself as a widget. The indicator is
      /// rendered over the whole pane.
      required Widget child,
    }) {
      if (pane.selected == null) return child;
      assert(debugCheckHasFluentTheme(context));
      final theme = NavigationPaneThemeData.of(context);

      return EndNavigationIndicator(
        index: pane.selected,
        pane: pane,
        child: child,
        color: theme.highlightColor,
        curve: theme.animationCurve ?? Curves.linear,
        axis: axis,
      );
    },
  ),
  ```

## [3.7.0] - Breaking changes - [21/01/2022]

- AutoSuggestBox: ([#130](https://github.com/bdlukaa/fluent_ui/pull/130))
  - It gets opened automatically when it gets focus
  - When an item is tapped, the cursor is positioned correctly at the end of the text
  - **BREAKING** Now it's not possible to assign a type to `AutoSuggestBox`:
    Before:
    ```dart
    AutoSuggestBox<String>(...),
    ```
    Now:
    ```dart
    AutoSuggestBox(...),
    ```
- Added TextFormBox witch integrates with the Form widget. It has the ability to be validated and to show an error message.
- New FluentIcons gallery showcase in example project ([#123](https://github.com/bdlukaa/fluent_ui/issues/123))
- Updated FluentIcons as per 30/12/2021
- **BREAKING** Renamed `FluentIcons.close` to `FluentIcons.chrome_close`
- Fixed rounded corners on the ComboBox widget
- Fixed missing padding before close button on `TabView` ([#122](https://github.com/bdlukaa/fluent_ui/issues/122))
- Readded tab minimal size for `equal` and `sizeToContent` tab width behaviours ([#122](https://github.com/bdlukaa/fluent_ui/issues/122))
- `TabView`'s close button now uses `SmallIconButton`
- If a tab is partially off the view, it's scrolled until it's visible
- Fix `IconButton`'s icon size
- Update `OutlinedButton`, `FilledButton` and `TextButton` styles
- Implement lazy tree view ([#139](https://github.com/bdlukaa/fluent_ui/pull/139))

## [3.6.0] - TabView Update - [25/12/2021]

- Implement `TreeView` ([#120](https://github.com/bdlukaa/fluent_ui/pull/120))
- Fix `Tooltip.useMousePosition`
- Fix `Slider` and `RatingBar` ([#116](https://github.com/bdlukaa/fluent_ui/issues/116))
- Fix scroll buttons when there are too many tabs in `TabView` ([#92](https://github.com/bdlukaa/fluent_ui/issues/92))
- Fix button style on tab in `TabView` ([#90](https://github.com/bdlukaa/fluent_ui/issues/90))
- Added *Close on middle click* on tabs in `TabView` ([#91](https://github.com/bdlukaa/fluent_ui/issues/91))
- Added `newTabLabel`, `closeTabLabel`, `scrollTabBackward`, `scrollTabForward` to `FluentLocalizations`
- Fix `TabView`'s text when it's too long. Now it's clipped when overflow and line doesn't break
- Added `TabView.closeButtonVisibility`. Defaults to `CloseButtonVisibilityMode.always`
- Updated selected tab paint
- Added `TabView.tabWidthBehavior`. Defaults to `TabWidthBehavior.equal`
- Added `TabView.header` and `TabView.footer`
- `Slider`'s mouse cursor is now [MouseCursor.defer]
- Added `SmallIconButton`, which makes an [IconButton] small if wrapped. It's used by `TextBox`
- Added `ButtonStyle.iconSize`
- **BREAKING** `AutoSuggestBox` updates:
  - Added `FluentLocalizations.noResultsFoundLabel`. "No results found" is the default text
  - Removed `itemBuilder`, `sorter`, `noResultsFound`, `textBoxBuilder`, `defaultNoResultsFound` and `defaultTextBoxBuilder`
  - Added `onChanged`, `trailingIcon`, `clearButtonEnabled` and `placeholder`
  - `controller` is now nullable. If null, an internal controller is creted

## [3.5.2] - [17/12/2021]

- **BREAKING** Removed `ThemeData.inputMouseCursor`
- **BREAKING** Removed `cursor` from `DatePicker`, `TimePicker`, `ButtonStyle`, `CheckboxThemeData`, `RadioButtonThemeData`, `SliderThemeData`, `ToggleSwitchThemeData`, `NavigationPaneThemeData`
- Scrollbar is not longer shown if `PaneDisplayMode` is `top`
- If open the compact pane, it's not always a overlay
- Added `triggerMode` and `enableFeedback` to `Tooltip`.
- Added `Tooltip.dismissAllToolTips`

## [3.5.1] - [15/12/2021]

- Update inputs colors
- `Expander` now properly disposes its resources
- Add the `borderRadius` and `shape` attributes to the `Mica` widget
- Implement `DropDownButton` ([#85](https://github.com/bdlukaa/fluent_ui/issues/85))

## [3.5.0] - Flutter 2.8 - [09/12/2021]

- **BREAKING** Minimal Flutter version is now 2.8
- `NavigationAppBar.backgroundColor` is now applied correctly. ([#100](https://github.com/bdlukaa/fluent_ui/issues/100))
- ComboBox's Popup Acrylic can now be disabled if wrapped in a `DisableAcrylic` ([#105](https://github.com/bdlukaa/fluent_ui/issues/105))
- `NavigationPane` width can now be customizable ([#99](https://github.com/bdlukaa/fluent_ui/issues/99))
- Implement `PaneItemAction` for `NavigationPane` ([#104](https://github.com/bdlukaa/fluent_ui/issues/104))

## [3.4.1] - [08/11/2021]

- `ContentDialog` constraints can now be customizable ([#86](https://github.com/bdlukaa/fluent_ui/issues/86))
- Add possibility to disable acrylic by wrapping it in a `DisableAcrylic` ([#89](https://github.com/bdlukaa/fluent_ui/issues/89))
- Fix `onReaorder null exception` ([#88](https://github.com/bdlukaa/fluent_ui/issues/88))
- Implement `InfoBadge`
- Implement `Expander` ([#85](https://github.com/bdlukaa/fluent_ui/issues/85))
- Default `inputMouseCursor` is now `MouseCursor.defer`
- `NavigationView.contentShape` is now rendered at the foreground

## [3.4.0] - Flexibility - [22/10/2021]

- `ProgressRing` now spins on the correct direction ([#83](https://github.com/bdlukaa/fluent_ui/issues/83))
- Added the `backwards` property to `ProgressRing`
- `FluentApp.builder` now works as expected ([#84](https://github.com/bdlukaa/fluent_ui/issues/84))
- Implemented `NavigationPane.customPane`, which now gives you the ability to create custom panes for `NavigationView`
- **BREAKING** `sizes`, `offsets` and `index` parameters from `NavigationIndicatorBuilder` were replaced by `pane`

## [3.3.0] - [12/10/2021]

- Back button now isn't forced when using top navigation mode ([#74](https://github.com/bdlukaa/fluent_ui/issues/74))
- `PilButtonBar` now accept 2 items ([#66](https://github.com/bdlukaa/fluent_ui/issues/66))
- Added builder variant to `NavigationBody`.
- Fixed content bug when `AppBar` was not supplied too `NavigationView`

## [3.2.0] - Flutter 2.5.0 - [15/09/2021]

- Added missing parameters in `_FluentTextSelectionControls` methods ([#67](https://github.com/bdlukaa/fluent_ui/issues/67))
- Min Flutter version is now 2.5.0
- **EXAMPLE APP** Updated the url strategy on web.
- **EXAMPLE APP** Upgraded dependencies
- Format code according to flutter_lints

## [3.1.0] - Texts and Fixes - [25/08/2021]

- Updated Typography:
  - **BREAKING** Renamed `header` -> `display`
  - **BREAKING** Renamed `subHeader` -> `titleLarge`
  - **BREAKING** Renamed `base` -> `bodyStrong`
  - Added `bodyLarge`
  - Updated font size and weight for most of the text styles
- Update `SplitButton` design
- Update `IconButton` design
- Fixed `ToggleSwitch` not showing expanded thumb mode when dragging
- **BREAKING** Remove `CheckboxListTile`, `RadioListTile` and `SwitchListTile`. Use the respective widget with the `content` property

## [3.0.0] - Windows 11 - [24/08/2021]

- Update `ToggleButton` design.
- Update `Button` design.
- Update `RadioButton` design.
- Update `ContentDialog` design.
- Update `NavigationView` design:
  - **BREAKING:** Acryic is not used anymore. Consequently, `useAcrylic` method was removed.
- Implemented `Mica`, used by the new `NavigationView`
- Added support for horizontal tooltips. Set `Tooltip.displayHorizontally` to true to enable it.
- Updated Acrylic to support the web
- Update `Checkbox` design
- Update `ToggleSwitch` design
- Update `Scrollbar` design
- Update `Slider` design
- Update `InfoBar` design
- Update pickers design (`Combobox`, `DatePicker` and `TimePicker`)

## [2.2.1] - [26/06/2021]

- Implement Fluent Selection Controls for `TextBox` ([#49](https://github.com/bdlukaa/fluent_ui/pull/49))
- `Tooltip` is now displayed when focused ([#45](https://github.com/bdlukaa/fluent_ui/issues/45))
- AppBar is now displayed when minimal pane is open.
- AppBar's animation now follows the pane animation

## [2.2.0] - BREAKING CHANGES - [25/06/2021]

- **BREAKING:** Material `Icons` are not used anymore. Use `FluentIcons` instead.
- **BREAKING:** Reworked the `Acrylic` widget implementation ([#47](https://github.com/bdlukaa/fluent_ui/pull/47))
- **BREAKING:** Removed the `useAcrylic` property from `NavigationView`. Acrylic is now used by default.
- `PaneDisplayMode.compact` has now a width of 40, not 50.
- Removed `SizeTransition` from `TabView`.

## [2.1.1] - [03/06/2021]

- Option to set a default font family on the theme data (`ThemeData.fontFamily`)
- `indicatorBuilder` is correctly applied to the automatic display mode in `NavigationView`
- An overlay is open when the toggle button is pressed on the compact display mode ([#43](https://github.com/bdlukaa/fluent_ui/issues/43))

## [2.1.0] - Mobile Update - [01/06/2021]

- Implemented `BottomNavigation`
- Implemented `BottomSheet`
- Implemented `Chip`
- Implemented `Snackbar`
- Implemented `PillButtonBar`
- New buttons variations:
  - `FillButton`
  - `OutlinedButton`
  - `TextButton`

---

- `PaneItem`s' `build` method is now overridable. You can know customize how the items in `NavigationView` should look like by overriding the method.
- Fixed bug that navigation indicator was not showing on the first frame
- Fixed minimal tooltip not updating when closed the overlay
- **EXAMPLE APP:** Navigation indicator is now configurable on the `Settings` page

## [2.0.3] - [28/05/2021]

- Correctly apply items positions to pane indicators, regardless of external factors, such as navigation view app bar ([#41](https://github.com/bdlukaa/fluent_ui/issues/41))
- Improved `NavigationIndicator`s performance

## [2.0.2] - [23/05/2021]

- **BREAKING CHANGES:** Reworked the theme api ([#39](https://github.com/bdlukaa/fluent_ui/pull/39)):

  - Removed the theme extension (`context.theme`). Use `FluentTheme.of(context)` instead
  - `ButtonState` is now a class that can receive a value. It now allows lerping between values, making `AnimatedFluentTheme` possible.

    Here's an example of how to migrate your code:

    _Before_: `cursor: (_) => SystemMouseCursors.click,`\
    _Now_: `cursor: ButtonState.all(SystemMouseCursors.click),`

  - All theme datas and `AccentColor` have now a lerp method, in order to make `AnimatedFluentTheme` possible.
  - Implemented `AnimatedFluentTheme`, in order to replace `AnimateContainer`s all around the library
  - Dedicated theme for each theme data ([#37](https://github.com/bdlukaa/fluent_ui/issues/37)):
    - IconTheme
    - ButtonTheme
    - RadioButtonTheme
    - CheckboxTheme
    - FocusTheme
    - SplitButtonTheme
    - ToggleButtonTheme
    - ToggleSwitchTheme
    - NavigationPaneTheme
    - InfoBarTheme
    - TooltipTheme
    - DividerTheme
    - ScrollbarTheme
  - `DividerThemeData` now has `verticalMargin` and `horizontalMargin` instead of an axis callback.
  - Updated button colors.
  - Removed `animationDuration` and `animationCurve` from theme datas (except from `NavigationPaneThemeData`).
  - Renamed `copyWith` to `merge` on theme datas (except from `ThemeData`)
  - Fixed typo `standart` -> `standard`
  - Implement `AnimatedAcrylic`

## [2.0.1] - [21/05/2021]

- Minimal flutter version is now 2.2
- Implement `FluentScrollBehavior`, that automatically adds a scrollbar into listviews ([#35](https://github.com/bdlukaa/fluent_ui/pull/35))
- Reworked the inputs api ([#38](https://github.com/bdlukaa/fluent_ui/pull/38)):
  - A input can have multiple states. Now, if the widget is focused and pressed at the same time, it doesn't lose its focused border.
  - Now, the focus is not requested twice when the button is pressed, only once. This fixes a bug introduced in a previous version that combo boxes items we're not being focused.
  - Semantics (acessibility) is now applied on all inputs

## [2.0.0] - [20/05/2021]

- New way to disable the acrylic blur effect. Just wrap the acrylic widget in a `NoAcrylicBlurEffect` to have it disabled.
- Reworked the Navigation Panel from scratch ([#31](https://github.com/bdlukaa/fluent_ui/pull/31)):
  - The legacy `NavigationPanel` and `Scaffold` were removed. Use `NavigationView` and `ScaffoldPage` instead
  - Implemented open, compact, top and minimal display modes.
  - Custom Selected Indicators
- Implemented fluent localizations ([#30](https://github.com/bdlukaa/fluent_ui/issues/30))

## [1.10.1] - [05/05/2021]

- **FIX** Reworked the combo box widget to improve fidelity. ([#25](https://github.com/bdlukaa/fluent_ui/pull/25))
- **FIX** Improved `HoverButton` focus management.
- **FIX** Reworked the tooltip widget. Now, if any mouse is connected, the tooltip is displaying according to the pointer position, not to the child's. ([#26](https://github.com/bdlukaa/fluent_ui/pull/26))
- **FIX** TabView is now scrollable if the size of the tabs overflow the width

## [1.10.0] - **BREAKING CHANGES** - [03/05/2021]

- **BREAKING** `InfoHeader` was renamed to `InfoLabel`. You can now set if the label will be rendered above the child or on the side of it.
- **FIX** Fixed `RadioButton` inner color overlaping the border.
- **NEW** `ThemeData.inputMouseCursor`
- **FIDELITY** Switch thumb is now draggable. (Fixes [#22](https://github.com/bdlukaa/fluent_ui/issues/22))
- **EXAMPLE** Reworked the example app inputs page

## [1.9.4] - [02/05/2021]

- **FIX** `CheckboxListTile`, `SwitchListTile` and `RadioListTile` now doesn't focus its leading widget.
- **FIX** `TabView` is now not scrollable
- **FIX** Fixed `Acrylic` blur effect being disabled by default.
- **FIDELITY** Improved `ContentDialog` transition fidelity
- **FIX** Fixed `FocusBorder` for some widgets. It was affecting layout when it shouldn't
- **FIX** `RatingBar` and `Slider` weren't working due to `FocusBorder`
- **NEW** | **FIDELITY** New `Slider` thumb

## [1.9.3] - [01/05/2021]

- **NEW** `FocusBorder.renderOutside`. With this property, you can control if the FocusBorder will be rendered over the widget or outside of it.
- **FIX** Fixed `RadioButton`s border when focused
- **FIX** `Color.resolve` now doesn't throw a stack overflow error.
- **BREAKING** Removed `Color.resolveFromBrightness`. This is only available on `AccentColor`
- **EXAMPLE APP** Hability to change the app accent color
- **NEW** `darkest` and `lightest` colors variants in `AccentColor`
- **FIX** Fixed `InfoBar`'s error icon. It now uses `Icons.cancel_outlined` instead of `Icons.close`
- **NEW** `NavigationPanel` now has a `Scrollbar` and the `bottom` property is now properly styled if selected

## [1.9.2] - [30/04/2021]

- **FIX** `TabView` tabs can now be reordered (Fixes [#10](https://github.com/bdlukaa/fluent_ui/issues/10))
- **FIDELITY** If a new `Tab` is added, its now animated
- **FIX** `FocusBorder` now doesn't change the size of the widgets
- **BREAKING** `buttonCursor`, `uncheckedInputColor` and `checkedInputColor` are now moved to `ButtonThemeData` as static functions.

## [1.9.1] - [29/04/2021]

- **FIX** Fixed diagnostic tree. (Fixes [#17](https://github.com/bdlukaa/fluent_ui/issues/17))
- **FIX** | **FIDELITY** `TappableListTile` now changes its color when focused instead of having a border
- **FIDELITY** Improved `Acrylic`'s blur effect fidelity
- **FIX** `Acrylic`'s elevation was being applying margin
- **NEW** `ThemeData.shadowColor`, which is now used by `Acrylic`
- **NEW** You can now globally disable the acrylic blur effect by changing `Acrylic.acrylicEnabled`

## [1.9.0] - **BREAKING CHANGES** - Theme Update - [29/04/2021]

The whole theme implementation was reworked on this change.

- **BREAKING** Renamed `Theme` to `FluentTheme`
- **BREAKING** All the properties in `FluentTheme` now can't be null
- **BREAKING** Renamed all the `Style` occurrences to `ThemeData`
- **BREAKING** `ThemeData.accentColor` is now an `AccentColor`
- **FIX** When providing a custom style to a tooltip, it's now correctly applied to `ThemeData.tooltipStyle`
- **FIX** `debugCheckHasFluentTheme` has now a better error message
- **FIX** `FluentApp` now doesn't throw an error if no `theme` is provided
- **FIX** Reworked `Scrollbar` to improve fidelity.
- **NEW** Color extension methods: `Color.toAccentColor` and `Color.basedOnLuminance`
- **NEW** `Button.builder`

## [1.8.1] - [16/04/2021]

- **NEW** In `TabView`, it's now possible use the following shortcuts if `TabView.shortcutsEnabled` is `true` (Follows [this](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/tab-view#closing-a-tab)):
  1. `Ctrl + F4` or `Ctrl + W` to close the current tab
  2. `Ctrl + T` to create a new tab
  3. `1-8` to navigate to a tab with the pressed number
  4. `9` to navigate to the last tab and navigate to the last tab
- **NEW** `IconButton.autofocus`, `ToggleButton.autofocus`
- **BREAKING** Renamed all the `semanticsLabel` to `semanticLabel`

## [1.8.0] - Color Update - [14/04/2021]

- **NEW** Web version hosted at https://bdlukaa.github.io/fluent_ui
- **NEW** Colors showcase page in example app
- **NEW** Info Colors:
  - `Colors.warningPrimaryColor`
  - `Colors.warningSecondaryColor`
  - `Colors.errorPrimaryColor`
  - `Colors.errorSecondaryColor`
  - `Colors.successPrimaryColor`
  - `Colors.successSecondaryColor`
- **FIX** Reworked all the accent colors (`Colors.accentColors`) with `darkest`, `dark`, `normal`, `light` and `lighter`
- **BREAKING** `Colors.blue` is now an `AccentColor`

## [1.7.6] - [13/04/2021]

- **NEW** `Checkbox.autofocus`
- **BREAKING** `Button` refactor:
  - Removed `Button.icon` and `Button.trailingIcon`
  - Renamed `Button.text` to `Button.child`
- You can now disable the acrylic backdrop effect by setting `enabled` to false
- **NEW** `NavigationPanelBody.animationCurve` and `NavigationPanelBody.animationDuration`

## [1.7.5] - [13/04/2021]

- **NEW** `Scrollbar` and `ScrollbarStyle`
- Reworked `FluentApp` to not depend of material anymore.

## [1.7.4] - [10/04/2021]

- **FIX** Updated `Icon` widget to use Flutter's default icon widget
- **NEW** Documentation

## [1.7.3] - [07/04/2021]

- **FIX** Improved `ListTile` sizing ([#Spacing](https://docs.microsoft.com/en-us/windows/uwp/design/style/spacing))
- **NEW** `FocusStyle` and support for glow focus
- **NEW** `RatingBar.starSpacing`

## [1.7.2] - [06/04/2021]

- **FIX** Animation when using `NavigationPanelBody` now works as expected
- **NEW** `CheckboxListTile`, `SwitchListTile` and `RadioListTile`
- **FIX** It's now not possible to focus a disabled `TextBox`

## [1.7.1] - [06/04/2021]

- **FIX** The mouse cursor in a disabled input is now `basic` instead of `forbidden`
- **FIX** `NavigationPanelBody` now doesn't use a `IndexedStack` under the hood because it was interfering in the focus scope
- **FIX** The color of the focus now is the `Style.inactiveColor`
- **FIX** `RadioButton`'s cursor was not being applied correctly
- **NEW** `Button.toggle`
- **FIX** The state provided by `HoverButton` was being `focused` when it shouldn't be
- **FIX** TimePicker showing wrong minute count. It should start from 00 and end in 59
- **NEW** `TimePicker.minuteIncrement`

## [1.7.0] - Focus Update - [05/04/2021]

- **FIXED** Fixed the possibility to give a elevation lower than 0 in `Acrylic`
- **NEW** It's now possible to change the rating of `RatingBar` using the keyboard arrows
- **NEW** Now it's possible to navigate using the keyboard with all focusable widgets

## [1.6.0] - BREAKING CHANGES - [03/04/2021]

- Added the missing `Diagnostics`
- Updated all the screenshots
- **BREAKING CHANGE** Uses the material icon library now

  **DEVELOPER NOTE** This was a hard choice, but the material icon library is a robust, bigger library. It contains all the icons the previous library has, and a few many more.

## [1.5.0] - [02/04/2021]

- Added `Diagnostics` to many widgets
- **NEW** `AutoSuggestBox` (Follows [this](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/auto-suggest-box))
- **NEW** `Flyout` and `FlyoutContent` (Folllows [this](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/dialogs-and-flyouts/flyouts))
- **FIXED** Popup was being shown off-screen.

  **DEVELOPER NOTE** The solution for this was to make it act like a tooltip: only show the popup above or under the `child`. This was a hard choice, but the only viable option that would work on small screens/devices. This also made `Flyout` easier to implement. This should be changed when multi-window support is available.

- **FIXED** `DatePicker` incorrectly changing hour
- **NEW** `Colors.accentColors`
- Documentation about [system_theme](https://pub.dev/packages/system_theme)
- **BREAKING** Removed `Pivot` because it's deprecated

## [1.4.1] - Pickers Update - [30/03/2021]

- **NEW** `Style.fasterAnimationDuration`
- **FIX** `ComboBox` press effect
- **NEW** `TimePicker` (Follows [this](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/time-picker))
- **NEW** `DatePicker` (Follows [this](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/date-picker))

## [1.4.0] - [28/03/2021]

- **NEW** `InfoHeader`
- **NEW** `ComboBox` (Follows [this](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/checkbox))
- **NEW** `TappableListTile`
- **BREAKING** Removed `DropdownButton` and `Button.dropdown`

## [1.3.4] - [28/03/2021]

- **NEW** Vertical Slider

## [1.3.3] - [25/03/2021]

- **NEW** Indeterminate `ProgressRing` ([@raitonoberu](https://github.com/raitonoberu))
- **NEW** `ListTile`
- **DIAGNOSTICS** Provide `Diagnostics` support to:
  - `Style`
  - `NavigationPanelStyle`
  - `TooltipStyle`

## [1.3.2] - Accessibility update - [24/03/2021]

This version provides the fix for [#5](https://github.com/bdlukaa/fluent_ui/issues/5)

- `Theme.of` can't be null anymore. Use `Theme.maybeOf` for such
- **NEW** `Style.inactiveBackgroundColor`
- **BREAKING** Replaced `color`, `border`, `borderRadius` from `IconButtonStyle` to `decoration`
- **DIAGNOSTICS** Provide `Diagnostics` support to the following classes:
  - ButtonStyle
  - Checkbox
  - CheckboxStyle
  - IconButtonStyle
  - RadioButtonStyle
  - RatingBar
  - SplitButtonStyle
  - ToggleButton
  - ToggleButtonStyle
  - ToggleSwitch
  - ToggleSwitchStyle
  - Slider
  - SliderStyle
  - Typography
  - Divider
  - DividerStyle
- Provide accessibility support to the following widgets:
  - Button
  - Checkbox
  - IconButton
  - RadioButton
  - RatingBar
  - Slider
  - ToggleButton
  - ToggleSwitch
  - TabView

## [1.3.1] - [23/03/2021]

- **FIX** `IconButtonStyle`'s `iconStyle` now works properly
- Improved `TabView` icon styling
- **NEW** Indeterminate `ProgressBar` ([@raitonoberu](https://github.com/raitonoberu))

## [1.3.0] - [22/03/2021]

- **NEW** Determinate `ProgressBar` and `ProgressRing`
- **NEW** `TabView` ([#TabView](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/tab-view))

## [1.2.5] - [21/03/2021]

- **FIX** Fixed `InfoBar`'s overflow

## [1.2.4] - [21/03/2021]

- **BREAKING** `RadioButton`'s `selected` property was renamed to `checked` to match a single pattern between all the other widgets.

## [1.2.3] - [19/03/2021]

- **NEW** | **EXAMPLE APP** `Settings` screen
- Improved theme changing
- **FIX** `FluentApp` doesn't lose its state anymore, possibiliting hot relaod.
- **NEW** `showDialog` rework:
  - `showDialog` now can return data. (Fixes [#2](https://github.com/bdlukaa/fluent_ui/issues/2))
  - `showDialog.transitionBuilder`
  - `showDialog.useRootNavigator`
  - `showDialog.routeSettings`
  - It's no longer necessary to have the fluent theme to display dialogs using this function.

## [1.2.2] - [17/03/2021]

- **BREAKING** Removed `_regular` from the name of the icons.
- **NEW** `InfoBar` (Follows [this](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/infobar))

## [1.2.1] - [16/03/2021]

- **NEW** `Divider`

## [1.2.0] - Timing and easing - Page transitioning - [15/03/2021]

- **FIDELITY** Improved `ToggleButton` fidelity
- **NEW** `NavigationPanelBody`
- **NEW** Page transitions
  - `EntrancePageTransition` ([#PageRefresh](https://docs.microsoft.com/en-us/windows/uwp/design/motion/page-transitions#page-refresh))
  - `DrillInPageTransition` ([#Drill](https://docs.microsoft.com/en-us/windows/uwp/design/motion/page-transitions#drill))
  - `HorizontalSlidePageTransition` ([#HorizontalSlide](https://docs.microsoft.com/en-us/windows/uwp/design/motion/page-transitions#horizontal-slide))
  - `SuppressPageTransition` ([#Supress](https://docs.microsoft.com/en-us/windows/uwp/design/motion/page-transitions#suppress))
- Add timing and easing to style. (Follows [this](https://docs.microsoft.com/en-us/windows/uwp/design/motion/timing-and-easing))
  - **NEW** `Style.fastAnimationDuration` (Defaults to 150ms)
  - **NEW** `Style.mediumAnimationDuration` (Defaults to 300ms)
  - **NEW** `Style.slowAnimationDuration` (Defaults to 500ms)
  - Default `animationCurve` is now `Curves.easeInOut` (standard) instead of `Curves.linear`
  - **BREAKING** Removed `Style.animationDuration`
- Refactored Navigation Panel

## [1.1.0] - Fidelity update - [14/03/2021]

- **BREAKING** Removed `Card` widget. Use `Acrylic` instead
- **NEW** `Acrylic` widget ([#Acrylic](https://docs.microsoft.com/en-us/windows/uwp/design/style/acrylic))
- **NEW** **NAVIGATION PANEL** `bottom` property
- **FIDELITY** Improved the corder radius of some widgets (Follows [this](https://docs.microsoft.com/en-us/windows/uwp/design/style/rounded-corner#page-or-app-wide-cornerradius-changes))
- **FIX** **FIDELITY** Dark theme hovering color
- Improved documentation

## [1.0.2] - Typography update - [11/03/2021]

- **NEW** Typography
  - Migrated all the widgets to use typography
- **NEW** Tooltip
- **NEW** Dark theme
- **FIX** Disabled button press effect if disabled
- **FIX** Grey color resulting in green color

## [1.0.1+1] - [09/03/2021]

- **NEW** Screenshots

## [1.0.1] - [07/03/2021]

- **FIX** `NavigationPanel` navigation index
- **FIX** `Slider`'s inactive color
- **FIDELITY** Scale animation of button press
- **FIDELITY** Improved `Slider` label fidelity
- **NEW** Split Button

## [1.0.0] - [05/03/2021]

- **NEW** Null-safety
- **NEW** New Icons Library
- **NEW** `NavigationPanelSectionHeader` and `NavigationPanelTileSeparator`
- **BREAKING** Removed `Snackbar`

## [0.0.9] - [03/03/2021]

- Export the icons library
- **NEW** `TextBox`

## [0.0.8] - [01/03/2021]

- **NEW** `ContentDialog` 🎉
- **NEW** `RatingControl` 🎉
- **NEW** `NavigationPanel` 🎉
- Improved `Button` fidelity

## [0.0.7] - [28/02/2021]

- **NEW** `Slider` 🎉
- Use physical model for elevation instead of box shadows
- Improved TODO

## [0.0.6] - [27/02/2021]

- **FIXED** Button now detect pressing
- **FIXED** `ToggleSwitch` default thumb is now animated
- **FIXED** Improved `ToggleSwitch` fidelity
  **FIXED** Darker color for button press.
- **NEW** **THEMING**
  - `Style.activeColor`
  - `Style.inactiveColor`
  - `Style.disabledColor`
  - `Style.animationDuration`
  - `Style.animationCurve`

## [0.0.5] - [27/02/2021]

- `ToggleSwitch` is now stable 🎉
- **NEW** `DefaultToggleSwitchThumb`
- **NEW** `ToggleButton`
- New toast lib: [fl_toast](https://pub.dev/packages/fl_toast)
- Screenshot on the readme. (Fixes [#1](https://github.com/bdlukaa/fluent_ui/issues/1))

## [0.0.4] - [22/02/2021]

- New fluent icons library: [fluentui_icons](https://pub.dev/packages/fluentui_icons)
- Re-made checkbox with more fidelity
- Refactored the following widgets to follow the theme accent color:
  - `Checkbox`
  - `ToggleSwitch`
  - `RadioButton`
- Added accent colors to widget. Use [this](https://docs.microsoft.com/en-us/windows/uwp/design/style/images/color/windows-controls.svg) as a base

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