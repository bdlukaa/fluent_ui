import 'dart:async';
import 'dart:ui' as ui;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef AutoSuggestBoxSorter<T> = List<AutoSuggestBoxItem<T>> Function(
  String text,
  List<AutoSuggestBoxItem<T>> items,
);

typedef OnChangeAutoSuggestBox<T> = void Function(
  String text,
  TextChangedReason reason,
);

enum TextChangedReason {
  /// Whether the text in an [AutoSuggestBox] was changed by user input
  userInput,

  /// Whether the text in an [AutoSuggestBox] was changed because the user
  /// chose the suggestion
  suggestionChosen,

  /// Whether the text in an [AutoSuggestBox] was cleared by the user
  cleared,
}

/// An item used in [AutoSuggestBox]
class AutoSuggestBoxItem<T> {
  /// The value attached to this item
  final T? value;

  /// The label that identifies this item
  ///
  /// The data is filtered based on this label
  final String label;

  /// The widget to be shown.
  ///
  /// If null, [label] is displayed
  ///
  /// Usually a [Text]
  final Widget? child;

  /// Called when this item's focus is changed.
  final ValueChanged<bool>? onFocusChange;

  /// Called when this item is selected
  final VoidCallback? onSelected;

  bool _selected = false;

  /// Creates an auto suggest box item
  AutoSuggestBoxItem({
    required this.value,
    required this.label,
    this.child,
    this.onFocusChange,
    this.onSelected,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AutoSuggestBoxItem && other.value == value;
  }

  @override
  int get hashCode {
    return value.hashCode;
  }
}

/// An AutoSuggestBox provides a list of suggestions for a user to select from
/// as they type.
///
/// ![AutoSuggestBox Preview](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/controls-autosuggest-expanded-01.png)
///
/// See also:
///
///  * [TextBox], which is used by this widget to enter user text input
///  * [TextFormBox], which is used by this widget by Form
///  * [Overlay], which is used to show the suggestion popup
///  * <https://docs.microsoft.com/en-us/windows/apps/design/controls/auto-suggest-box>
class AutoSuggestBox<T> extends StatefulWidget {
  /// Creates a fluent-styled auto suggest box.
  const AutoSuggestBox({
    Key? key,
    required this.items,
    this.controller,
    this.onChanged,
    this.onSelected,
    this.noResultsFoundBuilder,
    this.sorter,
    this.leadingIcon,
    this.trailingIcon,
    this.clearButtonEnabled = true,
    this.placeholder,
    this.placeholderStyle,
    this.style,
    this.decoration,
    this.foregroundDecoration,
    this.highlightColor,
    this.cursorColor,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorWidth = 1.5,
    this.showCursor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
    this.enableKeyboardControls = true,
    this.enabled = true,
    this.inputFormatters,
  })  : autovalidateMode = AutovalidateMode.disabled,
        validator = null,
        super(key: key);

  /// Creates a fluent-styled auto suggest form box.
  const AutoSuggestBox.form({
    Key? key,
    required this.items,
    this.controller,
    this.onChanged,
    this.onSelected,
    this.noResultsFoundBuilder,
    this.sorter,
    this.leadingIcon,
    this.trailingIcon,
    this.clearButtonEnabled = true,
    this.placeholder,
    this.placeholderStyle,
    this.style,
    this.decoration,
    this.foregroundDecoration,
    this.highlightColor,
    this.cursorColor,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorWidth = 1.5,
    this.showCursor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.validator,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
    this.enableKeyboardControls = true,
    this.enabled = true,
    this.inputFormatters,
  }) : super(key: key);

  /// The list of items to display to the user to pick
  final List<AutoSuggestBoxItem<T>> items;

  /// The controller used to have control over what to show on the [TextBox].
  final TextEditingController? controller;

  /// Called when the text is updated
  final OnChangeAutoSuggestBox? onChanged;

  /// Called when the user selected a value.
  final ValueChanged<AutoSuggestBoxItem<T>>? onSelected;

  /// Widget to be displayed when none of the items fit the [sorter]
  final WidgetBuilder? noResultsFoundBuilder;

  /// Sort the [items] based on the current query text
  ///
  /// See also:
  ///
  ///  * [AutoSuggestBox.defaultItemSorter], the default item sorter
  final AutoSuggestBoxSorter<T>? sorter;

  /// A widget displayed at the start of the text box
  ///
  /// Usually an [IconButton] or [Icon]
  final Widget? leadingIcon;

  /// A widget displayed at the end of the text box
  ///
  /// Usually an [IconButton] or [Icon]
  final Widget? trailingIcon;

  /// Whether the close button is enabled
  ///
  /// Defauls to true
  final bool clearButtonEnabled;

  /// The text shown when the text box is empty
  ///
  /// See also:
  ///
  ///  * [TextBox.placeholder]
  final String? placeholder;

  /// The style of [placeholder]
  ///
  /// See also:
  ///
  ///  * [TextBox.placeholderStyle]
  final TextStyle? placeholderStyle;

  /// The style to use for the text being edited.
  final TextStyle? style;

  /// Controls the [BoxDecoration] of the box behind the text input.
  final BoxDecoration? decoration;

  /// Controls the [BoxDecoration] of the box in front of the text input.
  ///
  /// If [highlightColor] is provided, this must not be provided
  final BoxDecoration? foregroundDecoration;

  /// The highlight color of the text box.
  ///
  /// If [foregroundDecoration] is provided, this must not be provided.
  final Color? highlightColor;

  /// {@macro flutter.widgets.editableText.cursorWidth}
  final double cursorWidth;

  /// {@macro flutter.widgets.editableText.cursorHeight}
  final double? cursorHeight;

  /// {@macro flutter.widgets.editableText.cursorRadius}
  final Radius? cursorRadius;

  /// The color of the cursor.
  ///
  /// The cursor indicates the current location of text insertion point in
  /// the field.
  final Color? cursorColor;

  /// {@macro flutter.widgets.editableText.showCursor}
  final bool? showCursor;

  /// Controls how tall the selection highlight boxes are computed to be.
  ///
  /// See [ui.BoxHeightStyle] for details on available styles.
  final ui.BoxHeightStyle selectionHeightStyle;

  /// Controls how wide the selection highlight boxes are computed to be.
  ///
  /// See [ui.BoxWidthStyle] for details on available styles.
  final ui.BoxWidthStyle selectionWidthStyle;

  /// The appearance of the keyboard.
  ///
  /// This setting is only honored on iOS devices.
  ///
  /// If unset, defaults to the brightness of [ThemeData.brightness].
  final Brightness? keyboardAppearance;

  /// {@macro flutter.widgets.editableText.scrollPadding}
  final EdgeInsets scrollPadding;

  /// An optional method that validates an input. Returns an error string to
  /// display if the input is invalid, or null otherwise.
  final FormFieldValidator<String>? validator;

  /// Used to enable/disable this form field auto validation and update its
  /// error text.
  final AutovalidateMode autovalidateMode;

  /// The type of action button to use for the keyboard.
  ///
  /// Defaults to [TextInputAction.newline] if [keyboardType] is
  /// [TextInputType.multiline] and [TextInputAction.done] otherwise.
  final TextInputAction? textInputAction;

  /// An object that can be used by a stateful widget to obtain the keyboard focus
  /// and to handle keyboard events.
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.editableText.autofocus}
  final bool autofocus;

  /// Whether the items can be selected using the keyboard
  ///
  /// Arrow Up - focus the item above
  /// Arrow Down - focus the item below
  /// Enter - select the current focused item
  /// Escape - close the suggestions overlay
  ///
  /// Defaults to `true`
  final bool enableKeyboardControls;

  /// Whether the text box is enabled
  ///
  /// See also:
  ///  * [TextBox.enabled]
  final bool enabled;

  /// {@macro flutter.widgets.editableText.inputFormatters}
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<AutoSuggestBox<T>> createState() => _AutoSuggestBoxState<T>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<AutoSuggestBoxItem<T>>('items', items))
      ..add(ObjectFlagProperty<ValueChanged<AutoSuggestBoxItem<T>>?>(
        'onSelected',
        onSelected,
        ifNull: 'disabled',
      ))
      ..add(FlagProperty(
        'clearButtonEnabled',
        value: clearButtonEnabled,
        defaultValue: true,
        ifFalse: 'clear button disabled',
      ));
  }

  List<AutoSuggestBoxItem<T>> defaultItemSorter(
    String text,
    List<AutoSuggestBoxItem<T>> items,
  ) {
    text = text.trim();
    if (text.isEmpty) return items;

    return items.where((element) {
      return element.label.toLowerCase().contains(text.toLowerCase());
    }).toList();
  }
}

class _AutoSuggestBoxState<T> extends State<AutoSuggestBox<T>> {
  late FocusNode focusNode = widget.focusNode ?? FocusNode();
  OverlayEntry? _entry;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _textBoxKey = GlobalKey();

  late TextEditingController controller;
  final FocusScopeNode overlayNode = FocusScopeNode();
  final _focusStreamController = StreamController<int>.broadcast();
  final _dynamicItemsController =
      StreamController<List<AutoSuggestBoxItem<T>>>.broadcast();

  AutoSuggestBoxSorter<T> get sorter =>
      widget.sorter ?? widget.defaultItemSorter;

  Size _boxSize = Size.zero;

  late List<AutoSuggestBoxItem<T>> _localItems;

  void updateLocalItems() {
    if (!mounted) return;
    setState(() => _localItems = sorter(controller.text, widget.items));
  }

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? TextEditingController();

    controller.addListener(_handleTextChanged);
    focusNode.addListener(_handleFocusChanged);

    _localItems = sorter(controller.text, widget.items);

    // Update the overlay when the text box size has changed
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final box = _textBoxKey.currentContext!.findRenderObject() as RenderBox;
      if (_boxSize != box.size) {
        _dismissOverlay();
        _boxSize = box.size;
      }
    });
  }

  @override
  void dispose() {
    focusNode.removeListener(_handleFocusChanged);
    controller.removeListener(_handleTextChanged);
    _focusStreamController.close();
    _dynamicItemsController.close();
    _unselectAll();

    {
      // If the TextEditingController and FocusNode objects are created locally,
      // we must dispose them.
      if (widget.controller == null) controller.dispose();
      if (widget.focusNode == null) focusNode.dispose();
    }

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AutoSuggestBox<T> oldWidget) {
    {
      // if the focusNode or controller objects were changed, we must reflect the
      // changes here. This is mostly used for a good dev-experience with hot
      // reload, but can also be used to create fancy focus effects
      if (widget.focusNode != oldWidget.focusNode) {
        if (oldWidget.focusNode == null) focusNode.dispose();
        focusNode = widget.focusNode ?? FocusNode();
      }

      if (widget.controller != oldWidget.controller) {
        if (oldWidget.controller == null) controller.dispose();
        controller = widget.controller ?? TextEditingController();
      }
    }

    if (widget.items != oldWidget.items) {
      _dynamicItemsController.add(widget.items);
    }

    super.didUpdateWidget(oldWidget);
  }

  void _handleFocusChanged() {
    final hasFocus = focusNode.hasFocus;
    if (!hasFocus) {
      _dismissOverlay();
    } else {
      _showOverlay();
    }
    setState(() {});
  }

  void _handleTextChanged() {
    if (!mounted) return;
    if (controller.text.length < 2) setState(() {});

    updateLocalItems();

    // Update the overlay when the text box size has changed
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      updateLocalItems();
    });
  }

  void _insertOverlay() {
    _entry = OverlayEntry(builder: (context) {
      assert(debugCheckHasMediaQuery(context));

      final boxContext = _textBoxKey.currentContext;
      if (boxContext == null) return const SizedBox.shrink();
      final box = boxContext.findRenderObject() as RenderBox;
      final globalOffset = box.localToGlobal(Offset.zero);

      final mediaQuery = MediaQuery.of(context);
      final screenHeight =
          mediaQuery.size.height - mediaQuery.viewPadding.bottom;
      final overlayY = globalOffset.dy + box.size.height;
      final maxHeight = screenHeight - overlayY;

      Widget child = Positioned(
        width: box.size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, box.size.height + 0.8),
          child: SizedBox(
            width: box.size.width,
            child: FluentTheme(
              data: FluentTheme.of(context),
              child: _AutoSuggestBoxOverlay<T>(
                maxHeight: maxHeight,
                node: overlayNode,
                controller: controller,
                items: widget.items,
                focusStream: _focusStreamController.stream,
                itemsStream: _dynamicItemsController.stream,
                sorter: sorter,
                onSelected: (AutoSuggestBoxItem<T> item) {
                  item.onSelected?.call();
                  widget.onSelected?.call(item);
                  controller
                    ..text = item.label
                    ..selection = TextSelection.collapsed(
                      offset: item.label.length,
                    );
                  widget.onChanged?.call(
                    item.label,
                    TextChangedReason.suggestionChosen,
                  );

                  // After selected, the overlay is dismissed and the text box is
                  // unfocused
                  _dismissOverlay();
                  focusNode.unfocus();
                },
                noResultsFoundBuilder: widget.noResultsFoundBuilder,
              ),
            ),
          ),
        ),
      );

      if (DisableAcrylic.of(context) != null) {
        child = DisableAcrylic(child: child);
      }

      return child;
    });

    if (_textBoxKey.currentContext != null) {
      Overlay.of(context)?.insert(_entry!);
      if (mounted) setState(() {});
    }
  }

  void _dismissOverlay() {
    _entry?.remove();
    _entry = null;
    _unselectAll();
  }

  void _showOverlay() {
    if (_entry == null && !(_entry?.mounted ?? false)) {
      _insertOverlay();
    }
  }

  void _unselectAll() {
    for (final item in _localItems) {
      item._selected = false;
      item.onFocusChange?.call(false);
    }
  }

  void _onChanged(String text) {
    widget.onChanged?.call(text, TextChangedReason.userInput);
    _showOverlay();
  }

  void _onSubmitted() {
    final currentlySelectedIndex = _localItems.indexWhere(
      (item) => item._selected,
    );
    if (currentlySelectedIndex.isNegative) return;

    final item = _localItems[currentlySelectedIndex];
    widget.onSelected?.call(item);
    item.onSelected?.call();

    controller.text = item.label;
    widget.onChanged?.call(controller.text, TextChangedReason.suggestionChosen);
  }

  /// Whether a [TextFormBox] is used instead of a [TextBox]
  bool get useForm => widget.validator != null;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasFluentLocalizations(context));

    final suffix = Row(mainAxisSize: MainAxisSize.min, children: [
      if (widget.trailingIcon != null) widget.trailingIcon!,
      if (widget.clearButtonEnabled && controller.text.isNotEmpty)
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 2.0),
          child: IconButton(
            icon: const Icon(FluentIcons.chrome_close),
            onPressed: () {
              controller.clear();
              widget.onChanged?.call(
                controller.text,
                TextChangedReason.cleared,
              );
              focusNode.unfocus();
            },
          ),
        ),
    ]);

    return CompositedTransformTarget(
      link: _layerLink,
      child: Focus(
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent || !widget.enableKeyboardControls) {
            return KeyEventResult.ignored;
          }

          if (event.logicalKey == LogicalKeyboardKey.escape) {
            _dismissOverlay();
            return KeyEventResult.handled;
          }

          if (_localItems.isEmpty) return KeyEventResult.ignored;

          final currentlySelectedIndex = _localItems.indexWhere(
            (item) => item._selected,
          );

          void select(int index) {
            _unselectAll();
            final item = _localItems[index];
            item._selected = true;
            item.onFocusChange?.call(true);
            _focusStreamController.add(index);
          }

          final lastIndex = _localItems.length - 1;

          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // if nothing is selected, select the first
            if (currentlySelectedIndex == -1 ||
                currentlySelectedIndex == lastIndex) {
              select(0);
            } else if (currentlySelectedIndex >= 0) {
              select(currentlySelectedIndex + 1);
            }
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // if nothing is selected, select the last
            if (currentlySelectedIndex == -1 || currentlySelectedIndex == 0) {
              select(_localItems.length - 1);
            } else {
              select(currentlySelectedIndex - 1);
            }
            return KeyEventResult.handled;
          } else {
            return KeyEventResult.ignored;
          }
        },
        child: useForm
            ? TextFormBox(
                key: _textBoxKey,
                controller: controller,
                focusNode: focusNode,
                autofocus: widget.autofocus,
                placeholder: widget.placeholder,
                placeholderStyle: widget.placeholderStyle,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                prefix: widget.leadingIcon,
                suffix: suffix,
                suffixMode: OverlayVisibilityMode.always,
                onChanged: _onChanged,
                onFieldSubmitted: (text) => _onSubmitted(),
                style: widget.style,
                decoration: widget.decoration,
                highlightColor: widget.highlightColor,
                cursorColor: widget.cursorColor,
                cursorHeight: widget.cursorHeight,
                cursorRadius: widget.cursorRadius ?? const Radius.circular(2.0),
                cursorWidth: widget.cursorWidth,
                showCursor: widget.showCursor,
                scrollPadding: widget.scrollPadding,
                selectionHeightStyle: widget.selectionHeightStyle,
                selectionWidthStyle: widget.selectionWidthStyle,
                validator: widget.validator,
                autovalidateMode: widget.autovalidateMode,
                textInputAction: widget.textInputAction,
                keyboardAppearance: widget.keyboardAppearance,
                enabled: widget.enabled,
                inputFormatters: widget.inputFormatters,
              )
            : TextBox(
                key: _textBoxKey,
                controller: controller,
                focusNode: focusNode,
                autofocus: widget.autofocus,
                placeholder: widget.placeholder,
                placeholderStyle: widget.placeholderStyle,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                prefix: widget.leadingIcon,
                suffix: suffix,
                suffixMode: OverlayVisibilityMode.always,
                onChanged: _onChanged,
                onSubmitted: (text) => _onSubmitted(),
                style: widget.style,
                decoration: widget.decoration,
                foregroundDecoration: widget.foregroundDecoration,
                highlightColor: widget.highlightColor,
                cursorColor: widget.cursorColor,
                cursorHeight: widget.cursorHeight,
                cursorRadius: widget.cursorRadius,
                cursorWidth: widget.cursorWidth,
                showCursor: widget.showCursor,
                scrollPadding: widget.scrollPadding,
                selectionHeightStyle: widget.selectionHeightStyle,
                selectionWidthStyle: widget.selectionWidthStyle,
                textInputAction: widget.textInputAction,
                keyboardAppearance: widget.keyboardAppearance,
                enabled: widget.enabled,
                inputFormatters: widget.inputFormatters,
              ),
      ),
    );
  }
}

class _AutoSuggestBoxOverlay<T> extends StatefulWidget {
  const _AutoSuggestBoxOverlay({
    Key? key,
    required this.items,
    required this.controller,
    required this.onSelected,
    required this.node,
    required this.focusStream,
    required this.itemsStream,
    required this.sorter,
    required this.maxHeight,
    required this.noResultsFoundBuilder,
  }) : super(key: key);

  final List<AutoSuggestBoxItem<T>> items;
  final TextEditingController controller;
  final ValueChanged<AutoSuggestBoxItem<T>> onSelected;
  final FocusScopeNode node;
  final Stream<int> focusStream;
  final Stream<List<AutoSuggestBoxItem<T>>> itemsStream;
  final AutoSuggestBoxSorter<T> sorter;
  final double maxHeight;
  final WidgetBuilder? noResultsFoundBuilder;

  @override
  State<_AutoSuggestBoxOverlay<T>> createState() =>
      _AutoSuggestBoxOverlayState<T>();
}

class _AutoSuggestBoxOverlayState<T> extends State<_AutoSuggestBoxOverlay<T>> {
  late final StreamSubscription focusSubscription;
  late final StreamSubscription itemsSubscription;
  final ScrollController scrollController = ScrollController();

  /// Tile height + padding
  static const tileHeight = (kOneLineTileHeight + 2.0);

  late List<AutoSuggestBoxItem<T>> items = widget.items;

  @override
  void initState() {
    super.initState();
    focusSubscription = widget.focusStream.listen((index) {
      if (!mounted) return;

      final currentSelectedOffset = tileHeight * index;

      scrollController.animateTo(
        currentSelectedOffset,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
      setState(() {});
    });
    itemsSubscription = widget.itemsStream.listen((items) {
      this.items = items;
    });
  }

  @override
  void dispose() {
    focusSubscription.cancel();
    itemsSubscription.cancel();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasFluentLocalizations(context));

    final theme = FluentTheme.of(context);
    final localizations = FluentLocalizations.of(context);

    return FocusScope(
      node: widget.node,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: widget.maxHeight.clamp(0, 380.0),
        ),
        decoration: ShapeDecoration(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(4.0),
            ),
          ),
          color: theme.resources.cardBackgroundFillColorDefault,
          shadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(-1, 1),
              blurRadius: 2.0,
              spreadRadius: 3.0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(1, 1),
              blurRadius: 2.0,
              spreadRadius: 3.0,
            ),
          ],
        ),
        child: Acrylic(
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller,
            builder: (context, value, _) {
              final sortedItems = widget.sorter(value.text, items);
              late Widget result;
              if (sortedItems.isEmpty) {
                result = widget.noResultsFoundBuilder?.call(context) ??
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: _AutoSuggestBoxOverlayTile(
                        text: Text(localizations.noResultsFoundLabel),
                        selected: false,
                      ),
                    );
              } else {
                result = ListView.builder(
                  itemExtent: tileHeight,
                  controller: scrollController,
                  key: ValueKey<int>(sortedItems.length),
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 4.0),
                  itemCount: sortedItems.length,
                  itemBuilder: (context, index) {
                    final item = sortedItems[index];
                    return _AutoSuggestBoxOverlayTile(
                      text: item.child ?? Text(item.label),
                      selected: item._selected,
                      onSelected: () => widget.onSelected(item),
                    );
                  },
                );
              }
              return result;
            },
          ),
        ),
      ),
    );
  }
}

class _AutoSuggestBoxOverlayTile extends StatefulWidget {
  const _AutoSuggestBoxOverlayTile({
    Key? key,
    required this.text,
    this.selected = false,
    this.onSelected,
  }) : super(key: key);

  final Widget text;
  final VoidCallback? onSelected;
  final bool selected;

  @override
  State<_AutoSuggestBoxOverlayTile> createState() =>
      __AutoSuggestBoxOverlayTileState();
}

class __AutoSuggestBoxOverlayTileState extends State<_AutoSuggestBoxOverlayTile>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 125),
    );
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return ListTile.selectable(
      title: EntrancePageTransition(
        animation: Tween<double>(
          begin: 0.75,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: Curves.easeOut,
        )),
        vertical: true,
        child: DefaultTextStyle(
          style: theme.typography.body ?? const TextStyle(),
          child: widget.text,
        ),
      ),
      selected: widget.selected,
      selectionMode: ListTileSelectionMode.single,
      onPressed: widget.onSelected,
    );
  }
}
