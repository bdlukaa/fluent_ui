import 'package:fluent_ui/fluent_ui.dart';

import 'package:flutter/foundation.dart';

// TODO: Navigate through items using keyboard (https://github.com/bdlukaa/fluent_ui/issues/19)

typedef AutoSuggestBoxItemBuilder<T> = Widget Function(BuildContext, T);
typedef AutoSuggestBoxItemSorter<T> = List<T> Function(String, List<T>);
typedef AutoSuggestBoxTextBoxBuilder<T> = Widget Function(
  BuildContext context,
  TextEditingController controller,
  FocusNode focusNode,
  GlobalKey key,
);

/// An AutoSuggestBox provides a list of suggestions for a user to select
/// from as they type.
///
/// ![AutoSuggestBox Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/controls_autosuggest_expanded01.png)
///
/// See also:
///   - [TextBox]
///   - [ComboBox]
class AutoSuggestBox<T> extends StatefulWidget {
  /// Creates a fluent-styled auto suggest box.
  const AutoSuggestBox({
    Key? key,
    required this.controller,
    required this.items,
    this.itemBuilder,
    this.sorter = defaultItemSorter,
    this.noResultsFound = defaultNoResultsFound,
    this.textBoxBuilder = defaultTextBoxBuilder,
    this.onSelected,
  }) : super(key: key);

  /// The controller used to have control over what to show on
  /// the [TextBox].
  final TextEditingController controller;

  /// The list of items to display to the user to pick. If empty,
  /// [noResultsFound] is used.
  final List<T> items;

  /// The item builder to build [items]. If null, uses a default
  /// internal builder
  final AutoSuggestBoxItemBuilder<T>? itemBuilder;

  /// Sort the items to show. [defaultItemSorter] is used by default
  final AutoSuggestBoxItemSorter sorter;

  /// Build the text box. [defaultTextBoxBuilder] is used by default
  final AutoSuggestBoxTextBoxBuilder<T> textBoxBuilder;

  /// The widget to show when the text the user typed doesn't match with
  /// [items]s. [defaultNoResultsFound] is used by default.
  ///
  /// ![No results found Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/controls_autosuggest_noresults.png)
  final WidgetBuilder noResultsFound;

  /// Called when the user selected a value.
  final ValueChanged<T>? onSelected;

  @override
  _AutoSuggestBoxState<T> createState() => _AutoSuggestBoxState<T>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<T>('items', items));
    properties.add(ObjectFlagProperty<ValueChanged<T>?>(
      'onSelected',
      onSelected,
      ifNull: 'disabled',
    ));
  }

  static List defaultItemSorter<T>(String text, List items) {
    return items.where((element) {
      return element.toString().toLowerCase().contains(text.toLowerCase());
    }).toList();
  }

  /// Creates a 'No results found' tile.
  ///
  /// ![No results found Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/controls_autosuggest_noresults.png)
  static Widget defaultNoResultsFound(context) {
    return const ListTile(
      title: DefaultTextStyle(
        style: TextStyle(fontWeight: FontWeight.normal),
        child: Text('No results found'),
      ),
    );
  }

  static Widget defaultTextBoxBuilder(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
    GlobalKey key,
  ) {
    assert(debugCheckHasFluentLocalizations(context));
    final FluentLocalizations localizations = FluentLocalizations.of(context);
    return TextBox(
      key: key,
      controller: controller,
      focusNode: focusNode,
      placeholder: localizations.searchLabel,
      clipBehavior:
          focusNode.hasFocus ? Clip.none : Clip.antiAliasWithSaveLayer,
    );
  }
}

class _AutoSuggestBoxState<T> extends State<AutoSuggestBox<T>> {
  final FocusNode focusNode = FocusNode();
  OverlayEntry? _entry;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _textBoxKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    focusNode.removeListener(_handleFocusChanged);
    super.dispose();
  }

  void _handleFocusChanged() {
    final hasFocus = focusNode.hasFocus;
    if (hasFocus) {
      if (_entry == null && !(_entry?.mounted ?? false)) {
        _insertOverlay();
      }
    } else {
      _dismissOverlay();
    }
    setState(() {});
  }

  AutoSuggestBoxItemBuilder<T> get itemBuilder =>
      widget.itemBuilder ?? _defaultItemBuilder;

  Widget _defaultItemBuilder(BuildContext context, T value) {
    return TappableListTile(
      onTap: () {
        widget.controller.text = '$value';
        widget.onSelected?.call(value);
        focusNode.unfocus();
      },
      title:
          Text('$value', style: FluentTheme.maybeOf(context)?.typography.body),
    );
  }

  void _insertOverlay() {
    _entry = OverlayEntry(builder: (context) {
      final context = _textBoxKey.currentContext;
      if (context == null) return const SizedBox.shrink();
      final box = _textBoxKey.currentContext!.findRenderObject() as RenderBox;
      return Positioned(
        width: box.size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, box.size.height + 0.8),
          child: SizedBox(
            width: box.size.width,
            child: Acrylic(
              tint: FluentTheme.of(context).acrylicBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(4.0),
                ),
                side: BorderSide(
                  color: FluentTheme.of(context).scaffoldBackgroundColor,
                  width: 0.8,
                ),
              ),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: widget.controller,
                builder: (context, value, _) {
                  final items = widget.sorter(value.text, widget.items);
                  late Widget result;
                  if (items.isEmpty) {
                    result = widget.noResultsFound(context);
                  } else {
                    result = ListView(
                      shrinkWrap: true,
                      children: List.generate(items.length, (index) {
                        final item = items[index];
                        return itemBuilder(context, item);
                      }),
                    );
                  }
                  return AnimatedSwitcher(
                    duration: FluentTheme.of(context).fastAnimationDuration,
                    switchInCurve: FluentTheme.of(context).animationCurve,
                    transitionBuilder: (child, animation) {
                      if (child is ListView) {
                        return child;
                      }
                      return EntrancePageTransition(
                        child: child,
                        animation: animation,
                        vertical: true,
                      );
                    },
                    layoutBuilder: (child, children) =>
                        child ?? const SizedBox(),
                    child: result,
                  );
                },
              ),
            ),
          ),
        ),
      );
    });

    if (_textBoxKey.currentContext != null) {
      Overlay.of(context)?.insert(_entry!);
    }
  }

  void _dismissOverlay() {
    _entry?.remove();
    _entry = null;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return CompositedTransformTarget(
      link: _layerLink,
      child: widget.textBoxBuilder(
        context,
        widget.controller,
        focusNode,
        _textBoxKey,
      ),
    );
  }
}
