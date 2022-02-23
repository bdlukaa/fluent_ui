import 'package:fluent_ui/fluent_ui.dart';

import 'package:flutter/foundation.dart';

enum TextChangedReason {
  /// Whether the text in an [AutoSuggestBox] was changed by user input
  userInput,

  /// Whether the text in an [AutoSuggestBox] was changed because the user
  /// chose the suggestion
  suggestionChosen,
}

// TODO: Navigate through items using keyboard (https://github.com/bdlukaa/fluent_ui/issues/19)

/// An AutoSuggestBox provides a list of suggestions for a user to select
/// from as they type.
///
/// ![AutoSuggestBox Preview](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/controls-autosuggest-expanded-01.png)
///
/// See also:
///
///   * <https://docs.microsoft.com/en-us/windows/apps/design/controls/auto-suggest-box>
///   * [TextBox], which is used by this widget to enter user text input
///   * [Overlay], which is used to show the suggestion popup
class AutoSuggestBox extends StatefulWidget {
  /// Creates a fluent-styled auto suggest box.
  const AutoSuggestBox({
    Key? key,
    required this.items,
    this.controller,
    this.onChanged,
    this.onSelected,
    this.trailingIcon,
    this.clearButtonEnabled = true,
    this.placeholder,
    this.placeholderStyle,
  }) : super(key: key);

  /// The list of items to display to the user to pick
  final List<String> items;

  /// The controller used to have control over what to show on
  /// the [TextBox].
  final TextEditingController? controller;

  /// Called when the text is updated
  final void Function(String text, TextChangedReason reason)? onChanged;

  /// Called when the user selected a value.
  final ValueChanged<String>? onSelected;

  /// A widget displayed in the end of the [TextBox]
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

  @override
  _AutoSuggestBoxState createState() => _AutoSuggestBoxState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<String>('items', items));
    properties.add(ObjectFlagProperty<ValueChanged<String>?>(
      'onSelected',
      onSelected,
      ifNull: 'disabled',
    ));
    properties.add(FlagProperty(
      'clearButtonEnabled',
      value: clearButtonEnabled,
      defaultValue: true,
      ifFalse: 'clear button disabled',
    ));
  }

  static List defaultItemSorter<T>(String text, List items) {
    return items.where((element) {
      return element.toString().toLowerCase().contains(text.toLowerCase());
    }).toList();
  }
}

class _AutoSuggestBoxState<T> extends State<AutoSuggestBox> {
  final FocusNode focusNode = FocusNode();
  OverlayEntry? _entry;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _textBoxKey = GlobalKey();

  late TextEditingController controller;

  final FocusScopeNode overlayNode = FocusScopeNode();

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? TextEditingController();
    controller.addListener(() {
      if (!mounted) return;
      if (controller.text.length < 2) setState(() {});
    });
    focusNode.addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    focusNode.removeListener(_handleFocusChanged);
    if (widget.controller == null) {
      controller.dispose();
    }
    super.dispose();
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

  void _insertOverlay() {
    _entry = OverlayEntry(builder: (context) {
      final context = _textBoxKey.currentContext;
      if (context == null) return const SizedBox.shrink();
      final box = _textBoxKey.currentContext!.findRenderObject() as RenderBox;
      final child = Positioned(
        width: box.size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, box.size.height + 0.8),
          child: SizedBox(
            width: box.size.width,
            child: _AutoSuggestBoxOverlay(
              node: overlayNode,
              controller: controller,
              items: widget.items,
              onSelected: (String item) {
                widget.onSelected?.call(item);
                controller.text = item;
                controller.selection = TextSelection.collapsed(
                  offset: item.length,
                );
                widget.onChanged?.call(item, TextChangedReason.userInput);

                // After selected, the overlay is dismissed and the text box is
                // unfocused
                _dismissOverlay();
                focusNode.unfocus();
              },
            ),
          ),
        ),
      );

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
  }

  void _showOverlay() {
    if (_entry == null && !(_entry?.mounted ?? false)) {
      _insertOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasFluentLocalizations(context));

    return CompositedTransformTarget(
      link: _layerLink,
      child: Actions(
        actions: {
          DirectionalFocusIntent: _DirectionalFocusAction(),
        },
        child: TextBox(
          key: _textBoxKey,
          controller: controller,
          focusNode: focusNode,
          placeholder: widget.placeholder,
          placeholderStyle: widget.placeholderStyle,
          clipBehavior:
              _entry != null ? Clip.none : Clip.antiAliasWithSaveLayer,
          suffix: Row(children: [
            if (widget.trailingIcon != null) widget.trailingIcon!,
            if (widget.clearButtonEnabled &&
                controller.text.isNotEmpty &&
                focusNode.hasFocus)
              Padding(
                padding: const EdgeInsets.only(left: 2.0),
                child: IconButton(
                  icon: const Icon(FluentIcons.chrome_close),
                  onPressed: () {
                    controller.clear();
                    focusNode.unfocus();
                  },
                ),
              ),
          ]),
          suffixMode: OverlayVisibilityMode.always,
          onChanged: (text) {
            widget.onChanged?.call(text, TextChangedReason.userInput);
            _showOverlay();
          },
        ),
      ),
    );
  }
}

class _DirectionalFocusAction extends DirectionalFocusAction {
  @override
  void invoke(covariant DirectionalFocusIntent intent) {
    // if (!intent.ignoreTextFields || !_isForTextField) {
    //   primaryFocus!.focusInDirection(intent.direction);
    // }
    debugPrint(intent.direction.toString());
  }
}

class _AutoSuggestBoxOverlay extends StatelessWidget {
  const _AutoSuggestBoxOverlay({
    Key? key,
    required this.items,
    required this.controller,
    required this.onSelected,
    required this.node,
  }) : super(key: key);

  final List items;
  final TextEditingController controller;
  final ValueChanged<String> onSelected;
  final FocusScopeNode node;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final localizations = FluentLocalizations.of(context);
    return FocusScope(
      node: node,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 380),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(4.0),
            ),
            side: BorderSide(
              color: theme.scaffoldBackgroundColor,
              width: 0.8,
            ),
          ),
          color: theme.menuColor,
        ),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            final items =
                AutoSuggestBox.defaultItemSorter(value.text, this.items);
            late Widget result;
            if (items.isEmpty) {
              result = Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: _AutoSuggestBoxOverlayTile(
                    text: localizations.noResultsFoundLabel),
              );
            } else {
              result = ListView(
                key: ValueKey<int>(items.length),
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 4.0),
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  return _AutoSuggestBoxOverlayTile(
                    text: '$item',
                    onSelected: () => onSelected(item),
                  );
                }),
              );
            }
            return result;
          },
        ),
      ),
    );
  }
}

class _AutoSuggestBoxOverlayTile extends StatefulWidget {
  const _AutoSuggestBoxOverlayTile({
    Key? key,
    required this.text,
    this.onSelected,
  }) : super(key: key);

  final String text;
  final VoidCallback? onSelected;

  @override
  __AutoSuggestBoxOverlayTileState createState() =>
      __AutoSuggestBoxOverlayTileState();
}

class __AutoSuggestBoxOverlayTileState extends State<_AutoSuggestBoxOverlayTile>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final node = FocusNode();

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
    node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return HoverButton(
      focusNode: node,
      onPressed: widget.onSelected,
      margin: const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
      builder: (context, states) => Stack(
        children: [
          Container(
            height: 36.0,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.0),
              color: ButtonThemeData.uncheckedInputColor(
                theme,
                states.isDisabled ? {ButtonStates.none} : states,
              ),
            ),
            alignment: AlignmentDirectional.centerStart,
            child: EntrancePageTransition(
              child: Text(
                widget.text,
                style: theme.typography.body,
              ),
              animation: Tween<double>(
                begin: 0.75,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: controller,
                curve: Curves.easeOut,
              )),
              vertical: true,
            ),
          ),
          if (states.isFocused)
            Positioned(
              top: 11.0,
              bottom: 11.0,
              left: 0.0,
              child: Container(
                width: 3.0,
                decoration: BoxDecoration(
                  color: theme.accentColor,
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
