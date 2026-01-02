import 'dart:async';
import 'dart:ui' as ui;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// A function that sorts and filters [AutoSuggestBoxItem]s based on the
/// current text input.
typedef AutoSuggestBoxSorter<T> =
    List<AutoSuggestBoxItem<T>> Function(
      String text,
      List<AutoSuggestBoxItem<T>> items,
    );

/// Called when the text in an [AutoSuggestBox] changes.
typedef OnChangeAutoSuggestBox<T> =
    void Function(String text, TextChangedReason reason);

/// A builder for custom [AutoSuggestBoxItem] widgets in the overlay.
typedef AutoSuggestBoxItemBuilder<T> =
    Widget Function(BuildContext context, AutoSuggestBoxItem<T> item);

/// The reason for the text change in an [AutoSuggestBox].
enum TextChangedReason {
  /// Whether the text in an [AutoSuggestBox] was changed by user input
  userInput,

  /// Whether the text in an [AutoSuggestBox] was changed because the user
  /// chose the suggestion
  suggestionChosen,

  /// Whether the text in an [AutoSuggestBox] was cleared by the user
  cleared,
}

/// The default max height the auto suggest box popup can have
const kAutoSuggestBoxPopupMaxHeight = 380.0;

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

  /// {@macro fluent_ui.controls.inputs.HoverButton.semanticLabel}
  ///
  /// If not provided, [label] is used
  final String? semanticLabel;

  bool _selected = false;

  /// Creates an auto suggest box item
  AutoSuggestBoxItem({
    required this.value,
    required this.label,
    this.child,
    this.onFocusChange,
    this.onSelected,
    this.semanticLabel,
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

/// An auto-suggest box provides a list of suggestions for a user to select
/// from as they type.
///
/// The [AutoSuggestBox] combines a text input with a dropdown list of suggestions
/// that filter as the user types. This is ideal for search scenarios or when
/// users need to select from a large list of options.
///
/// ![AutoSuggestBox Preview](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/controls-autosuggest-expanded-01.png)
///
/// {@tool snippet}
/// This example shows a basic auto-suggest box:
///
/// ```dart
/// AutoSuggestBox<String>(
///   items: [
///     AutoSuggestBoxItem(value: 'apple', label: 'Apple'),
///     AutoSuggestBoxItem(value: 'banana', label: 'Banana'),
///     AutoSuggestBoxItem(value: 'cherry', label: 'Cherry'),
///   ],
///   onSelected: (item) {
///     print('Selected: ${item.value}');
///   },
///   placeholder: 'Search fruits...',
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// This example shows an auto-suggest box with custom item rendering:
///
/// ```dart
/// AutoSuggestBox<Contact>(
///   items: contacts.map((c) => AutoSuggestBoxItem(
///     value: c,
///     label: c.name,
///     child: Row(
///       children: [
///         CircleAvatar(backgroundImage: NetworkImage(c.avatar)),
///         SizedBox(width: 8),
///         Text(c.name),
///       ],
///     ),
///   )).toList(),
///   onSelected: (item) => selectContact(item.value),
/// )
/// ```
/// {@end-tool}
///
/// ## Keyboard navigation
///
/// When [enableKeyboardControls] is true (the default), users can navigate
/// suggestions using:
/// * Arrow Up/Down - Navigate through suggestions
/// * Enter - Select the focused suggestion
/// * Escape - Close the suggestions overlay
///
/// See also:
///
///  * [TextBox], which is used by this widget to enter user text input
///  * [ComboBox], for selecting from a predefined list without typing
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/auto-suggest-box>
class AutoSuggestBox<T> extends StatefulWidget {
  /// Creates a windows-styled auto suggest box.
  const AutoSuggestBox({
    required this.items,
    super.key,
    this.controller,
    this.onChanged,
    this.onSelected,
    this.onOverlayVisibilityChanged,
    this.itemBuilder,
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
    this.unfocusedColor,
    this.cursorColor,
    this.cursorHeight,
    this.cursorRadius = const Radius.circular(2),
    this.cursorWidth = 1.5,
    this.showCursor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsetsDirectional.all(20),
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
    this.enableKeyboardControls = true,
    this.enabled = true,
    this.inputFormatters,
    this.maxPopupHeight = kAutoSuggestBoxPopupMaxHeight,
  }) : autovalidateMode = AutovalidateMode.disabled,
       validator = null;

  /// Creates a windows-styled auto suggest form box.
  const AutoSuggestBox.form({
    required this.items,
    super.key,
    this.controller,
    this.onChanged,
    this.onSelected,
    this.onOverlayVisibilityChanged,
    this.itemBuilder,
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
    this.unfocusedColor,
    this.cursorColor,
    this.cursorHeight,
    this.cursorRadius = const Radius.circular(2),
    this.cursorWidth = 1.5,
    this.showCursor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsetsDirectional.all(20),
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
    this.maxPopupHeight = kAutoSuggestBoxPopupMaxHeight,
  });

  /// The list of items to display to the user to pick
  final List<AutoSuggestBoxItem<T>> items;

  /// The controller used to have control over what to show on the [TextBox].
  final TextEditingController? controller;

  /// Called when the text is updated
  final OnChangeAutoSuggestBox<T>? onChanged;

  /// Called when the user selected a value.
  final ValueChanged<AutoSuggestBoxItem<T>>? onSelected;

  /// Called when the overlay visibility changes
  final ValueChanged<bool>? onOverlayVisibilityChanged;

  /// A callback function that builds the items in the overlay.
  ///
  /// Use [noResultsFoundBuilder] to build the overlay when no item is provided
  final AutoSuggestBoxItemBuilder<T>? itemBuilder;

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
  ///
  /// Defaults to having a rounded rectangle grey border and can be null to have
  /// no box decoration.
  final WidgetStateProperty<BoxDecoration>? decoration;

  /// Controls the [BoxDecoration] of the box in front of the text input.
  ///
  /// If [highlightColor] is provided, this must not be provided
  final WidgetStateProperty<BoxDecoration>? foregroundDecoration;

  /// The highlight color of the text box.
  ///
  /// If [foregroundDecoration] is provided, this must not be provided.
  ///
  /// See also:
  ///  * [unfocusedColor], displayed when the field is not focused
  final Color? highlightColor;

  /// The unfocused color of the highlight border.
  ///
  /// See also:
  ///   * [highlightColor], displayed when the field is focused
  final Color? unfocusedColor;

  /// {@macro flutter.widgets.editableText.cursorWidth}
  final double cursorWidth;

  /// {@macro flutter.widgets.editableText.cursorHeight}
  final double? cursorHeight;

  /// {@macro flutter.widgets.editableText.cursorRadius}
  final Radius cursorRadius;

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
  /// If unset, defaults to the brightness of [FluentThemeData.brightness].
  final Brightness? keyboardAppearance;

  /// {@macro flutter.widgets.editableText.scrollPadding}
  final EdgeInsetsGeometry scrollPadding;

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
  /// * Arrow Up - focus the item above
  /// * Arrow Down - focus the item below
  /// * Enter - select the current focused item
  /// * Escape - close the suggestions overlay
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

  /// The max height the popup can assume.
  ///
  /// The suggestion popup can assume the space available below the text box but,
  /// by default, it's limited to a 380px height. If the value provided is greater
  /// than the available space, the box is limited to the available space.
  final double maxPopupHeight;

  @override
  State<AutoSuggestBox<T>> createState() => AutoSuggestBoxState<T>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<AutoSuggestBoxItem<T>>('items', items))
      ..add(
        ObjectFlagProperty<ValueChanged<AutoSuggestBoxItem<T>>?>(
          'onSelected',
          onSelected,
          ifNull: 'disabled',
        ),
      )
      ..add(
        FlagProperty(
          'clearButtonEnabled',
          value: clearButtonEnabled,
          defaultValue: true,
          ifFalse: 'clear button disabled',
        ),
      )
      ..add(
        FlagProperty(
          'enableKeyboardControls',
          value: enableKeyboardControls,
          defaultValue: true,
          ifFalse: 'keyboard controls disabled',
        ),
      )
      ..add(
        DoubleProperty(
          'maxPopupHeight',
          maxPopupHeight,
          defaultValue: kAutoSuggestBoxPopupMaxHeight,
        ),
      );
  }

  /// The default item sorter.
  ///
  /// This sorter will filter the items based on their label.
  List<AutoSuggestBoxItem<T>> defaultItemSorter(
    String content,
    List<AutoSuggestBoxItem<T>> items,
  ) {
    final text = content.trim();
    if (text.isEmpty) return items;

    return items.where((element) {
      return element.label.toLowerCase().contains(text.toLowerCase());
    }).toList();
  }
}

/// The state for an [AutoSuggestBox] widget.
///
/// This state manages the overlay, text controller, and item selection.
class AutoSuggestBoxState<T> extends State<AutoSuggestBox<T>> {
  late FocusNode _focusNode = widget.focusNode ?? FocusNode();
  OverlayEntry? _entry;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _textBoxKey = GlobalKey(
    debugLabel: "AutoSuggestBox's TextBox Key",
  );

  late TextEditingController _controller;
  final FocusScopeNode _overlayNode = FocusScopeNode();
  final _focusStreamController = StreamController<int>.broadcast();
  final _dynamicItemsController =
      StreamController<List<AutoSuggestBoxItem<T>>>.broadcast();

  /// The sorter function used to filter items based on the current text.
  AutoSuggestBoxSorter<T> get sorter =>
      widget.sorter ?? widget.defaultItemSorter;

  /// The size of the text box.
  ///
  /// Used to determine if the overlay needs to be updated when the text box size
  /// changes.
  Size _boxSize = Size.zero;

  late List<AutoSuggestBoxItem<T>> _localItems;

  void _updateLocalItems() {
    if (!mounted) return;
    setState(() => _localItems = sorter(_controller.text, widget.items));
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();

    _controller.addListener(_handleTextChanged);
    _focusNode.addListener(_handleFocusChanged);

    _localItems = sorter(_controller.text, widget.items);

    // Update the overlay when the text box size has changed
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted ||
          _textBoxKey.currentContext == null ||
          !_textBoxKey.currentContext!.mounted) {
        return;
      }

      final box = _textBoxKey.currentContext!.findRenderObject()! as RenderBox;
      if (_boxSize != box.size) {
        dismissOverlay();
        _boxSize = box.size;
      }
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    _controller.removeListener(_handleTextChanged);
    _focusStreamController.close();
    _dynamicItemsController.close();
    _unselectAll();

    // If the TextEditingController and FocusNode objects are created locally,
    // we must dispose them.
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AutoSuggestBox<T> oldWidget) {
    {
      // if the focusNode or controller objects were changed, we must reflect the
      // changes here. This is mostly used for a good dev-experience with hot
      // reload, but can also be used to create fancy focus effects
      if (widget.focusNode != oldWidget.focusNode) {
        if (oldWidget.focusNode == null) _focusNode.dispose();
        _focusNode = widget.focusNode ?? FocusNode();
      }

      if (widget.controller != oldWidget.controller) {
        if (oldWidget.controller == null) _controller.dispose();
        _controller = widget.controller ?? TextEditingController();
      }
    }

    if (widget.items != oldWidget.items) {
      _dynamicItemsController.add(widget.items);
    }

    super.didUpdateWidget(oldWidget);
  }

  void _handleFocusChanged() {
    final hasFocus = _focusNode.hasFocus;
    if (!hasFocus) {
      dismissOverlay();
    } else if (_controller.text.isNotEmpty) {
      showOverlay();
    }
  }

  void _handleTextChanged() {
    if (!mounted) return;
    _updateLocalItems();

    // Update the overlay when the text box size has changed
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _updateLocalItems();
    });
  }

  /// Whether the overlay is currently visible.
  bool get isOverlayVisible => _entry != null;

  void _insertOverlay() {
    final overlayState = Overlay.of(
      context,
      rootOverlay: true,
      debugRequiredFor: widget,
    );

    _entry = OverlayEntry(
      builder: (context) {
        assert(debugCheckHasMediaQuery(context));
        assert(debugCheckHasFluentTheme(context));

        final boxContext = _textBoxKey.currentContext;
        if (boxContext == null) return const SizedBox.shrink();
        final box = boxContext.findRenderObject()! as RenderBox;

        // ancestor is not necessary here because we are not dealing with routes, but overlays
        final globalOffset = box.localToGlobal(
          Offset.zero,
          ancestor: overlayState.context.findRenderObject(),
        );

        final screenHeight =
            MediaQuery.sizeOf(context).height -
            MediaQuery.viewPaddingOf(context).bottom;
        final overlayY = globalOffset.dy + box.size.height;
        final maxHeight = (screenHeight - overlayY).clamp(
          0.0,
          widget.maxPopupHeight,
        );

        Widget child = PositionedDirectional(
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
                  node: _overlayNode,
                  controller: _controller,
                  items: widget.items,
                  itemBuilder: widget.itemBuilder,
                  focusStream: _focusStreamController.stream,
                  itemsStream: _dynamicItemsController.stream,
                  sorter: sorter,
                  onSelected: (item) {
                    item.onSelected?.call();
                    widget.onSelected?.call(item);
                    _controller
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
                    dismissOverlay();
                    _focusNode.unfocus(
                      disposition: UnfocusDisposition.previouslyFocusedChild,
                    );
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
      },
    );

    if (_textBoxKey.currentContext != null) {
      overlayState.insert(_entry!);
    }
  }

  /// Dismisses the suggestions overlay.
  void dismissOverlay() {
    _entry?.remove();
    _entry = null;
    _unselectAll();
    widget.onOverlayVisibilityChanged?.call(isOverlayVisible);
  }

  /// Shows the suggestions overlay.
  void showOverlay() {
    if (_entry == null && !(_entry?.mounted ?? false)) {
      _insertOverlay();
      widget.onOverlayVisibilityChanged?.call(isOverlayVisible);
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
    showOverlay();
  }

  void _onSubmitted() {
    final currentlySelectedIndex = _localItems.indexWhere(
      (item) => item._selected,
    );
    if (currentlySelectedIndex.isNegative) return;

    final item = _localItems[currentlySelectedIndex];
    widget.onSelected?.call(item);
    item.onSelected?.call();

    _controller.text = item.label;
    widget.onChanged?.call(
      _controller.text,
      TextChangedReason.suggestionChosen,
    );
  }

  /// Whether a [TextFormBox] is used instead of a [TextBox]
  bool get isForm => widget.validator != null;

  double? _width;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasFluentLocalizations(context));

    final suffix = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.clearButtonEnabled && _controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 2),
            child: IconButton(
              icon: const WindowsIcon(WindowsIcons.chrome_close, size: 9),
              onPressed: () {
                _controller.clear();
                widget.onChanged?.call(
                  _controller.text,
                  TextChangedReason.cleared,
                );
              },
            ),
          ),
        if (widget.trailingIcon != null) widget.trailingIcon!,
      ],
    );

    return CompositedTransformTarget(
      link: _layerLink,
      child: Focus(
        skipTraversal: true,
        onKeyEvent: (node, event) {
          if (!(event is KeyDownEvent || event is KeyRepeatEvent) ||
              !widget.enableKeyboardControls) {
            return KeyEventResult.ignored;
          }

          if (event.logicalKey == LogicalKeyboardKey.escape) {
            dismissOverlay();
            return KeyEventResult.handled;
          }

          if (_localItems.isEmpty) return KeyEventResult.ignored;

          final currentlySelectedIndex = _localItems.indexWhere(
            (item) => item._selected,
          );

          void select(int index) {
            _unselectAll();
            final item = (_localItems[index]).._selected = true;
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            _width ??= constraints.maxWidth;
            if (_width! != constraints.maxWidth) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_entry != null && _entry!.mounted) {
                  _entry!.remove();
                  _entry = null;
                  showOverlay();
                }
              });
              _width = constraints.maxWidth;
            }

            if (isForm) {
              return TextFormBox(
                key: _textBoxKey,
                controller: _controller,
                focusNode: _focusNode,
                autofocus: widget.autofocus,
                placeholder: widget.placeholder,
                placeholderStyle: widget.placeholderStyle,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                prefix: widget.leadingIcon,
                suffix: suffix,
                onChanged: _onChanged,
                onFieldSubmitted: (text) => _onSubmitted(),
                style: widget.style,
                decoration: widget.decoration,
                highlightColor: widget.highlightColor,
                unfocusedColor: widget.unfocusedColor,
                cursorColor: widget.cursorColor,
                cursorHeight: widget.cursorHeight,
                cursorRadius: widget.cursorRadius,
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
              );
            }
            return TextBox(
              key: _textBoxKey,
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              placeholder: widget.placeholder,
              placeholderStyle: widget.placeholderStyle,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              prefix: widget.leadingIcon,
              suffix: suffix,
              onChanged: _onChanged,
              onSubmitted: (text) => _onSubmitted(),
              style: widget.style,
              decoration: widget.decoration,
              foregroundDecoration: widget.foregroundDecoration,
              highlightColor: widget.highlightColor,
              unfocusedColor: widget.unfocusedColor,
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
            );
          },
        ),
      ),
    );
  }
}

class _AutoSuggestBoxOverlay<T> extends StatefulWidget {
  const _AutoSuggestBoxOverlay({
    required this.items,
    required this.itemBuilder,
    required this.controller,
    required this.onSelected,
    required this.node,
    required this.focusStream,
    required this.itemsStream,
    required this.sorter,
    required this.maxHeight,
    required this.noResultsFoundBuilder,
    super.key,
  });

  final List<AutoSuggestBoxItem<T>> items;
  final AutoSuggestBoxItemBuilder<T>? itemBuilder;
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
  late final StreamSubscription<void> focusSubscription;
  late final StreamSubscription<void> itemsSubscription;
  final ScrollController scrollController = ScrollController();

  /// Tile height + padding
  static const tileHeight = kOneLineTileHeight + 2.0;

  late List<AutoSuggestBoxItem<T>> items = widget.items;

  @override
  void initState() {
    super.initState();
    focusSubscription = widget.focusStream.listen((index) {
      if (!mounted) return;

      final theme = FluentTheme.of(context);

      final currentSelectedOffset = tileHeight * index;

      scrollController.animateTo(
        currentSelectedOffset,
        duration: theme.fastAnimationDuration,
        curve: Curves.easeInOut,
      );
      if (mounted) setState(() {});
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

    return TextFieldTapRegion(
      child: FocusScope(
        node: widget.node,
        child: Container(
          constraints: BoxConstraints(maxHeight: widget.maxHeight),
          decoration: ShapeDecoration(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
            ),
            color: theme.resources.cardBackgroundFillColorDefault,
            shadows: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: const Offset(-1, 1),
                blurRadius: 2,
                spreadRadius: 3,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: const Offset(1, 1),
                blurRadius: 2,
                spreadRadius: 3,
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
                  result =
                      widget.noResultsFoundBuilder?.call(context) ??
                      Padding(
                        padding: const EdgeInsetsDirectional.only(bottom: 4),
                        child: _AutoSuggestBoxOverlayTile(
                          text: Text(localizations.noResultsFoundLabel),
                        ),
                      );
                } else {
                  result = ListView.builder(
                    itemExtent: tileHeight,
                    controller: scrollController,
                    key: ValueKey<int>(sortedItems.length),
                    shrinkWrap: true,
                    padding: const EdgeInsetsDirectional.only(bottom: 4),
                    itemCount: sortedItems.length,
                    itemBuilder: (context, index) {
                      final item = sortedItems[index];
                      return widget.itemBuilder?.call(context, item) ??
                          _AutoSuggestBoxOverlayTile(
                            text: item.child ?? Text(item.label),
                            semanticLabel: item.semanticLabel ?? item.label,
                            selected: item._selected || widget.node.hasFocus,
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
      ),
    );
  }
}

class _AutoSuggestBoxOverlayTile extends StatefulWidget {
  const _AutoSuggestBoxOverlayTile({
    required this.text,
    this.selected = false,
    this.onSelected,
    this.semanticLabel,
  });

  final Widget text;
  final VoidCallback? onSelected;
  final bool selected;
  final String? semanticLabel;

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
    )..forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = FluentTheme.of(context);
    controller.duration = theme.fastAnimationDuration;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return ListTile.selectable(
      semanticLabel: widget.semanticLabel,
      title: EntrancePageTransition(
        animation: Tween<double>(
          begin: 0.75,
          end: 1,
        ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
        child: DefaultTextStyle.merge(
          style: theme.typography.body,
          child: widget.text,
        ),
      ),
      selected: widget.selected,
      onPressed: widget.onSelected,
    );
  }
}
