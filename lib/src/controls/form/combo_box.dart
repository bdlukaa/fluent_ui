import 'dart:async';
import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluent_ui/src/controls/pickers/pickers.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';

part 'editable_combo_box.dart';

const Duration _kComboBoxMenuDuration = Duration(milliseconds: 300);
const Duration _kComboBoxSearchDuration = Duration(milliseconds: 500);
const double _kMenuItemBottomPadding = 6;
const EdgeInsets _kMenuItemPadding = EdgeInsets.symmetric(horizontal: 12);
const EdgeInsetsGeometry _kAlignedButtonPadding = EdgeInsetsDirectional.only(
  start: 11,
  end: 15,
);
const EdgeInsetsDirectional _kListPadding = EdgeInsetsDirectional.only(
  top: _kMenuItemBottomPadding,
  bottom: _kMenuItemBottomPadding,
);

double _comboBoxEstimatedItemHeight(BuildContext context, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: 'M', style: style),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
  )..layout();
  return math.max<double>(kComboBoxItemHeight, painter.height);
}

/// The default height of a combo box item.
const double kComboBoxItemHeight = kPickerHeight + _kMenuItemBottomPadding;

/// The default corner radius for combo box elements.
const kComboBoxRadius = Radius.circular(4);

/// A builder to customize combo box buttons.
///
/// Used by [ComboBox.selectedItemBuilder].
typedef ComboBoxBuilder = List<Widget> Function(BuildContext context);

// Do not use the platform-specific default scroll configuration.
// ComboBox menus should not overscroll or display an overscroll indicator.
class _ComboBoxScrollBehavior extends FluentScrollBehavior {
  const _ComboBoxScrollBehavior();

  @override
  TargetPlatform getPlatform(BuildContext context) => defaultTargetPlatform;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();
}

class _ComboBoxItemContainer extends StatelessWidget {
  const _ComboBoxItemContainer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final hasPadding = _ContainerWithoutPadding.of(context) == null;
    final states = HoverButton.maybeOf(context)?.states ?? <WidgetState>{};
    final foregroundColor = states.isDisabled
        ? theme.resources.textFillColorDisabled
        : states.isPressed
        ? theme.resources.textFillColorTertiary
        : states.isHovered
        ? theme.resources.textFillColorSecondary
        : theme.resources.textFillColorPrimary;
    final densityAdjustment = theme.visualDensity.baseSizeAdjustment.dy;
    final minimumHeight = math.max<double>(
      0,
      (hasPadding
              ? kComboBoxItemHeight
              : kComboBoxItemHeight - _kMenuItemBottomPadding) +
          densityAdjustment,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minimumHeight),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: DefaultTextStyle.merge(
          style: TextStyle(color: foregroundColor),
          child: IconTheme.merge(
            data: IconThemeData(color: foregroundColor),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _ContainerWithoutPadding extends InheritedWidget {
  const _ContainerWithoutPadding({required super.child});

  static _ContainerWithoutPadding? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ContainerWithoutPadding>();

  @override
  bool updateShouldNotify(_ContainerWithoutPadding oldWidget) => true;
}

/// An item in a menu created by a [ComboBox].
///
/// The type `T` is the type of the value the entry represents. All the entries
/// in a given menu must represent values with consistent types.
class ComboBoxItem<T> extends _ComboBoxItemContainer {
  /// Creates an item for a combo box menu.
  const ComboBoxItem({
    required super.child,
    super.key,
    this.onTap,
    this.value,
    this.enabled = true,
    this.searchLabel,
  });

  /// Called when the combo box menu item is tapped.
  final VoidCallback? onTap;

  /// The value to return if the user selects this menu item.
  final T? value;

  /// Whether this item is enabled.
  final bool enabled;

  /// The text used by keyboard type-ahead search.
  ///
  /// This is useful when [child] is a custom widget. If it is null, a direct
  /// [Text] child is used when one is available.
  final String? searchLabel;
}

class _ComboBoxPopupLayout extends SingleChildLayoutDelegate {
  const _ComboBoxPopupLayout({
    required this.anchorRect,
    required this.bounds,
    required this.popupConstraints,
    required this.preferredWidth,
    required this.textDirection,
    required this.selectedIndex,
    required this.estimatedItemHeight,
    required this.scrollOffset,
  });

  final Rect anchorRect;
  final Rect bounds;
  final BoxConstraints? popupConstraints;
  final double preferredWidth;
  final TextDirection textDirection;
  final int? selectedIndex;
  final double estimatedItemHeight;
  final double scrollOffset;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final availableWidth = math.max<double>(0, bounds.width);
    final availableHeight = math.max<double>(0, bounds.height);
    final requested = popupConstraints;
    final requestedMinWidth = requested?.minWidth ?? 0;
    final desiredWidth = math.max<double>(preferredWidth, requestedMinWidth);
    final maxWidth = math.min<double>(
      availableWidth,
      requested?.hasBoundedWidth ?? false
          ? math.min(requested!.maxWidth, desiredWidth)
          : desiredWidth,
    );
    final maxHeight = math.min<double>(
      availableHeight,
      requested?.hasBoundedHeight ?? false
          ? requested!.maxHeight
          : availableHeight,
    );
    final minWidth = math.min<double>(
      maxWidth,
      math.max<double>(
        requested?.minWidth ?? 0,
        math.min<double>(anchorRect.width, maxWidth),
      ),
    );
    final minHeight = math.min<double>(maxHeight, requested?.minHeight ?? 0);

    return BoxConstraints(
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final maximumLeft = math.max(bounds.left, bounds.right - childSize.width);
    final preferredLeft = textDirection == TextDirection.rtl
        ? anchorRect.right - childSize.width
        : anchorRect.left;
    final left = clampDouble(preferredLeft, bounds.left, maximumLeft);

    final double preferredTop;
    if (selectedIndex == null) {
      final below = anchorRect.bottom;
      final above = anchorRect.top - childSize.height;
      preferredTop =
          below + childSize.height <= bounds.bottom || below <= bounds.top
          ? below
          : above;
    } else {
      final selectedStart =
          _kListPadding.top +
          selectedIndex! * estimatedItemHeight -
          scrollOffset;
      final selectedCenter = selectedStart + estimatedItemHeight / 2;
      preferredTop = anchorRect.center.dy - selectedCenter;
    }

    final maximumTop = math.max(bounds.top, bounds.bottom - childSize.height);
    final top = clampDouble(preferredTop, bounds.top, maximumTop);
    return Offset(left, top);
  }

  @override
  bool shouldRelayout(_ComboBoxPopupLayout oldDelegate) {
    return anchorRect != oldDelegate.anchorRect ||
        bounds != oldDelegate.bounds ||
        popupConstraints != oldDelegate.popupConstraints ||
        preferredWidth != oldDelegate.preferredWidth ||
        textDirection != oldDelegate.textDirection ||
        selectedIndex != oldDelegate.selectedIndex ||
        estimatedItemHeight != oldDelegate.estimatedItemHeight ||
        scrollOffset != oldDelegate.scrollOffset;
  }
}

class _ComboBoxPopup<T> extends StatefulWidget {
  const _ComboBoxPopup({
    required this.items,
    required this.selectedIndex,
    required this.activeIndex,
    required this.animationIndex,
    required this.keyboardActiveIndex,
    required this.itemPadding,
    required this.style,
    required this.popupColor,
    required this.elevation,
    required this.animation,
    required this.scrollController,
    required this.anchorCenterGlobalY,
    required this.searchLabel,
    required this.onActiveChanged,
    required this.onSelected,
    super.key,
  });

  final List<ComboBoxItem<T>> items;
  final int? selectedIndex;
  final int? activeIndex;
  final int? animationIndex;
  final int? keyboardActiveIndex;
  final EdgeInsets itemPadding;
  final TextStyle style;
  final Color? popupColor;
  final int elevation;
  final AnimationController animation;
  final ScrollController scrollController;
  final double anchorCenterGlobalY;
  final String? Function(ComboBoxItem<T>) searchLabel;
  final ValueChanged<int> onActiveChanged;
  final ValueChanged<int> onSelected;

  @override
  State<_ComboBoxPopup<T>> createState() => _ComboBoxPopupState<T>();
}

class _ComboBoxPopupState<T> extends State<_ComboBoxPopup<T>> {
  final GlobalKey _viewportKey = GlobalKey(
    debugLabel: 'ComboBox popup viewport',
  );
  final GlobalKey _activeItemKey = GlobalKey(
    debugLabel: 'ComboBox active item',
  );
  int _correctionAttempts = 0;
  late final CurvedAnimation _fade;
  late final CurvedAnimation _resize;

  @override
  void initState() {
    super.initState();
    _fade = CurvedAnimation(
      parent: widget.animation,
      curve: const Interval(0, .25),
      reverseCurve: const Interval(.75, 1),
    );
    _resize = CurvedAnimation(
      parent: widget.animation,
      curve: const Interval(.25, .5),
      reverseCurve: const Threshold(0),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.animation.value < 1) {
        widget.animation.forward(from: 0);
      }
    });
    _scheduleCorrection();
  }

  @override
  void didUpdateWidget(covariant _ComboBoxPopup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.anchorCenterGlobalY != widget.anchorCenterGlobalY ||
        oldWidget.scrollController != widget.scrollController) {
      _scheduleCorrection();
    }
  }

  @override
  void dispose() {
    _fade.dispose();
    _resize.dispose();
    super.dispose();
  }

  void ensureActiveVisible() => _scheduleCorrection();

  void _scheduleCorrection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.scrollController.hasClients) return;
      final itemContext = _activeItemKey.currentContext;
      final viewportContext = _viewportKey.currentContext;
      if (itemContext == null || viewportContext == null) {
        if (_correctionAttempts++ < 5) _scheduleCorrection();
        return;
      }
      _correctionAttempts = 0;
      final itemBox = itemContext.findRenderObject();
      final viewportBox = viewportContext.findRenderObject();
      if (itemBox is! RenderBox || viewportBox is! RenderBox) return;
      final itemTop = itemBox.localToGlobal(Offset.zero).dy;
      final itemCenter = itemTop + itemBox.size.height / 2;
      final viewportTop = viewportBox.localToGlobal(Offset.zero).dy;
      final viewportBottom = viewportTop + viewportBox.size.height;
      final desiredCenter = clampDouble(
        widget.anchorCenterGlobalY,
        viewportTop + itemBox.size.height / 2,
        viewportBottom - itemBox.size.height / 2,
      );
      final target = clampDouble(
        widget.scrollController.offset + itemCenter - desiredCenter,
        widget.scrollController.position.minScrollExtent,
        widget.scrollController.position.maxScrollExtent,
      );
      if ((target - widget.scrollController.offset).abs() > .5) {
        widget.scrollController.jumpTo(target);
      }
    });
  }

  Widget _buildItem(BuildContext context, int index) {
    final item = widget.items[index];
    final isActive = widget.activeIndex == index;
    final isSelected = widget.selectedIndex == index;
    final isKeyboardActive = widget.keyboardActiveIndex == index;
    final showSelectionIndicator = isSelected || isKeyboardActive;
    final foregroundColor = isActive
        ? FluentTheme.of(context).resources.textFillColorPrimary
        : null;

    final semantics = Semantics(
      button: true,
      enabled: item.enabled,
      selected: isSelected,
      focused: isActive,
      label: widget.searchLabel(item),
      child: HoverButton(
        focusEnabled: false,
        actionsEnabled: false,
        onPointerEnter: item.enabled
            ? (_) => widget.onActiveChanged(index)
            : null,
        onPressed: item.enabled ? () => widget.onSelected(index) : null,
        builder: (context, states) {
          final theme = FluentTheme.of(context);
          final visualStates = <WidgetState>{
            ...states,
            if (isActive) WidgetState.focused,
          };
          final background = ButtonThemeData.uncheckedInputColor(
            theme,
            visualStates,
            transparentWhenNone: true,
          );
          return Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 6),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: EdgeInsetsDirectional.only(
                    start: widget.itemPadding.left,
                    end: widget.itemPadding.right + (isSelected ? 24 : 0),
                  ),
                  child: DefaultTextStyle.merge(
                    style: widget.style.copyWith(color: foregroundColor),
                    child: IconTheme.merge(
                      data: IconThemeData(color: foregroundColor),
                      child: _ComboBoxItemContainer(child: item.child),
                    ),
                  ),
                ),
                if (showSelectionIndicator)
                  PositionedDirectional(
                    top: states.isPressed ? 10 : 8,
                    bottom: states.isPressed ? 10 : 8,
                    start: 0,
                    child: Container(
                      key: const ValueKey('combo-box-selection-indicator'),
                      width: 3,
                      decoration: BoxDecoration(
                        color: theme.accentColor.defaultBrushFor(
                          theme.brightness,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                if (isSelected)
                  PositionedDirectional(
                    end: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: WindowsIcon(
                        WindowsIcons.check_mark,
                        size: 10,
                        color: theme.resources.textFillColorPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
    return KeyedSubtree(
      key: isActive ? _activeItemKey : null,
      child: KeyedSubtree(key: item.key, child: semantics),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final content = ScrollConfiguration(
      behavior: const _ComboBoxScrollBehavior(),
      child: ListView.builder(
        key: _viewportKey,
        controller: widget.scrollController,
        primary: false,
        shrinkWrap: true,
        padding: _kListPadding,
        itemCount: widget.items.length,
        itemBuilder: _buildItem,
      ),
    );
    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.resources.surfaceStrokeColorFlyout),
        borderRadius: const BorderRadius.all(kComboBoxRadius),
        boxShadow: kElevationToShadow[widget.elevation],
        color: widget.popupColor ?? theme.menuColor.withValues(alpha: 1),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(kComboBoxRadius),
        child: Acrylic(
          tintAlpha: widget.popupColor == null ? 1 : 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(kComboBoxRadius),
          ),
          child: DefaultTextStyle.merge(style: widget.style, child: content),
        ),
      ),
    );

    return FadeTransition(
      key: const Key('combo-box-popup-fade'),
      opacity: _fade,
      child: ClipRect(
        key: const Key('combo-box-popup-reveal'),
        clipper: _ComboBoxRevealClipper(
          animation: _resize,
          selectedIndex: widget.animationIndex,
          scrollController: widget.scrollController,
          estimatedItemHeight: _comboBoxEstimatedItemHeight(
            context,
            widget.style,
          ),
        ),
        child: decorated,
      ),
    );
  }
}

class _ComboBoxRevealClipper extends CustomClipper<Rect> {
  const _ComboBoxRevealClipper({
    required this.animation,
    required this.selectedIndex,
    required this.scrollController,
    required this.estimatedItemHeight,
  }) : super(reclip: animation);

  final Animation<double> animation;
  final int? selectedIndex;
  final ScrollController scrollController;
  final double estimatedItemHeight;

  @override
  Rect getClip(Size size) {
    if (selectedIndex == null) return Offset.zero & size;
    final selectedTop = clampDouble(
      _kListPadding.top +
          selectedIndex! * estimatedItemHeight -
          scrollController.initialScrollOffset,
      0,
      math.max(0, size.height - estimatedItemHeight),
    );
    final selectedBottom = math.min(
      size.height,
      selectedTop + estimatedItemHeight,
    );
    return Rect.fromLTRB(
      0,
      Tween<double>(begin: selectedTop, end: 0).evaluate(animation),
      size.width,
      Tween<double>(
        begin: selectedBottom,
        end: size.height,
      ).evaluate(animation),
    );
  }

  @override
  bool shouldReclip(_ComboBoxRevealClipper oldClipper) =>
      oldClipper.animation != animation ||
      oldClipper.selectedIndex != selectedIndex ||
      oldClipper.scrollController != scrollController;
}

/// A combo box (also known as a drop-down list) lets the user select from a
/// list of items.
///
/// The popup is rendered in the nearest [Overlay] using [OverlayPortal]. This
/// keeps a popup attached to a dialog or nested overlay while it is open.
class ComboBox<T> extends StatefulWidget {
  /// Creates a combo box button.
  const ComboBox({
    required this.items,
    super.key,
    this.selectedItemBuilder,
    this.value,
    this.placeholder,
    this.disabledPlaceholder,
    this.onChanged,
    this.onTap,
    this.onOpen,
    this.onClose,
    this.elevation = 8,
    this.style,
    this.icon = const WindowsIcon(WindowsIcons.chevron_down),
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.iconSize = 8.0,
    this.isExpanded = false,
    this.focusColor,
    this.focusNode,
    this.autofocus = false,
    this.popupColor,
    this.popupConstraints,
  });

  /// The list of items the user can select.
  final List<ComboBoxItem<T>>? items;

  /// The value of the currently selected [ComboBoxItem].
  final T? value;

  /// A placeholder displayed when no item is selected.
  final Widget? placeholder;

  /// A placeholder displayed when the combo box is disabled and empty.
  final Widget? disabledPlaceholder;

  /// Called when the user selects an item.
  final ValueChanged<T?>? onChanged;

  /// Called when the combo box control is tapped.
  final VoidCallback? onTap;

  /// Called once after the popup starts opening.
  final VoidCallback? onOpen;

  /// Called once after an opened popup finishes closing.
  final VoidCallback? onClose;

  /// The z-coordinate at which to place the popup when open.
  final int elevation;

  /// The text style used by the control and popup items.
  final TextStyle? style;

  /// The icon displayed at the end of the control.
  final Widget icon;

  /// The color of an icon when the control is disabled.
  final Color? iconDisabledColor;

  /// The color of an icon when the control is enabled.
  final Color? iconEnabledColor;

  /// The size used for the control icon.
  final double iconSize;

  /// Whether the control fills the width available to it.
  final bool isExpanded;

  /// The color used for the control's focused state.
  final Color? focusColor;

  /// The focus node used by the control.
  final FocusNode? focusNode;

  /// Whether the control requests focus when it is first built.
  final bool autofocus;

  /// The background color of the popup.
  final Color? popupColor;

  /// Optional popup size constraints.
  ///
  /// The constraints are intersected with the available overlay bounds. The
  /// popup can therefore never extend outside the application viewport.
  final BoxConstraints? popupConstraints;

  /// A builder for the selected control content.
  final ComboBoxBuilder? selectedItemBuilder;

  @override
  State<ComboBox<T>> createState() => ComboBoxState<T>();
}

/// The state for a [ComboBox].
class ComboBoxState<T> extends State<ComboBox<T>>
    with SingleTickerProviderStateMixin {
  final OverlayPortalController _overlayController = OverlayPortalController(
    debugLabel: 'ComboBox popup',
  );
  final FocusScopeNode _popupScopeNode = FocusScopeNode(
    debugLabel: 'ComboBox popup scope',
  );
  final FocusNode _popupFocusNode = FocusNode(
    debugLabel: 'ComboBox popup focus',
  );
  final GlobalKey<_ComboBoxPopupState<T>> _popupKey = GlobalKey();
  final GlobalKey _controlKey = GlobalKey(debugLabel: 'ComboBox control');

  FocusNode? _internalNode;
  ScrollController? _scrollController;
  late final AnimationController _animationController;
  late int? _selectedIndex;
  int? _activeIndex;
  int? _popupAnchorIndex;
  double _popupAnchorScrollOffset = 0;
  int? _keyboardActiveIndex;
  bool _isOpen = false;
  bool _isClosing = false;
  bool _hasPrimaryFocus = false;
  String _searchBuffer = '';
  Timer? _searchTimer;

  /// The index of the selected item.
  int? get selectedIndex => _selectedIndex;

  /// The focus node for the combo box.
  FocusNode? get focusNode => widget.focusNode ?? _internalNode;

  /// Whether the combo box is enabled.
  bool get isEnabled =>
      widget.items != null &&
      widget.items!.isNotEmpty &&
      widget.onChanged != null;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _findSelectedIndex();
    _internalNode = widget.focusNode == null ? _createFocusNode() : null;
    _animationController = AnimationController(
      vsync: this,
      duration: _kComboBoxMenuDuration,
      reverseDuration: _kComboBoxMenuDuration,
    )..addStatusListener(_handleAnimationStatus);
    focusNode!.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(covariant ComboBox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChanged);
      if (widget.focusNode == null) _internalNode ??= _createFocusNode();
      focusNode!.addListener(_handleFocusChanged);
    }
    _selectedIndex = _findSelectedIndex();
    if (!_isOpen) {
      _activeIndex = null;
      _keyboardActiveIndex = null;
    }
  }

  @override
  void dispose() {
    if (_overlayController.isShowing) _overlayController.hide();
    _searchTimer?.cancel();
    focusNode!.removeListener(_handleFocusChanged);
    _internalNode?.dispose();
    _popupFocusNode.dispose();
    _popupScopeNode.dispose();
    _scrollController?.dispose();
    _animationController
      ..removeStatusListener(_handleAnimationStatus)
      ..dispose();
    super.dispose();
  }

  FocusNode _createFocusNode() =>
      FocusNode(debugLabel: '${widget.runtimeType}');

  int? _findSelectedIndex() {
    final items = widget.items;
    if (widget.value == null || items == null) return null;
    final index = items.indexWhere((item) => item.value == widget.value);
    return index < 0 ? null : index;
  }

  double _estimatedItemHeight(BuildContext context) {
    final style = widget.style ?? FluentTheme.of(context).typography.body!;
    return _comboBoxEstimatedItemHeight(context, style);
  }

  double _initialScrollOffset(BuildContext context, int? selectedIndex) {
    if (selectedIndex == null || widget.items == null) return 0;
    final box = _controlKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return selectedIndex * _estimatedItemHeight(context);
    final globalAnchor = box.localToGlobal(Offset.zero) & box.size;
    final overlay = Overlay.maybeOf(context);
    final overlayBox = overlay?.context.findRenderObject() as RenderBox?;
    final anchor = overlayBox == null
        ? globalAnchor
        : Rect.fromPoints(
            overlayBox.globalToLocal(globalAnchor.topLeft),
            overlayBox.globalToLocal(globalAnchor.bottomRight),
          );
    final media = MediaQuery.of(context);
    final overlaySize = overlayBox?.size ?? media.size;
    final bounds = Rect.fromLTRB(
      media.padding.left,
      media.padding.top,
      overlaySize.width - media.padding.right,
      overlaySize.height - media.padding.bottom,
    );
    final estimate = _estimatedItemHeight(context);
    final preferredHeight =
        _kListPadding.vertical + widget.items!.length * estimate;
    final maxHeight = widget.popupConstraints?.maxHeight ?? bounds.height;
    final height = math.min<double>(
      preferredHeight,
      math.min<double>(maxHeight, bounds.height),
    );
    final maximumTop = math.max(bounds.top, bounds.bottom - height);
    final popupTop = clampDouble(
      anchor.center.dy - height / 2,
      bounds.top,
      maximumTop,
    );
    final selectedStart = _kListPadding.top + selectedIndex * estimate;
    final selectedCenter = selectedStart + estimate / 2;
    final desiredSelectedCenter = anchor.center.dy - popupTop;
    final offset = selectedCenter - desiredSelectedCenter;
    final maximumOffset = math.max<double>(0, preferredHeight - height);
    return clampDouble(offset, 0, maximumOffset);
  }

  /// Opens the combo box popup.
  void openPopup() {
    if (!isEnabled) return;
    if (_isOpen) {
      if (_isClosing) {
        _isClosing = false;
        _animationController.forward();
      }
      return;
    }

    final items = widget.items!;
    _selectedIndex = _findSelectedIndex();
    _activeIndex = _selectedIndex != null && items[_selectedIndex!].enabled
        ? _selectedIndex
        : _firstEnabledIndex();
    _popupAnchorIndex = _activeIndex;
    _keyboardActiveIndex = null;
    _scrollController?.dispose();
    _popupAnchorScrollOffset = _initialScrollOffset(context, _activeIndex);
    _scrollController = ScrollController(
      initialScrollOffset: _popupAnchorScrollOffset,
      keepScrollOffset: false,
    );
    _isOpen = true;
    _isClosing = false;
    _overlayController.show();
    widget.onTap?.call();
    widget.onOpen?.call();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isOpen && !_isClosing) {
        _popupScopeNode.requestFocus(_popupFocusNode);
      }
    });
  }

  /// Closes the combo box popup.
  ///
  /// If the popup is not open, this method does nothing.
  void closePopup() {
    if (!_isOpen || _isClosing) return;
    _isClosing = true;
    _animationController.reverse();
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.dismissed || !_isClosing) return;
    _overlayController.hide();
    _isOpen = false;
    _isClosing = false;
    _scrollController?.dispose();
    _scrollController = null;
    _popupAnchorIndex = null;
    _popupAnchorScrollOffset = 0;
    widget.onClose?.call();
    if (mounted) focusNode?.requestFocus();
  }

  void _handleFocusChanged() {
    final hasFocus = focusNode?.hasPrimaryFocus ?? false;
    if (_hasPrimaryFocus != hasFocus && mounted) {
      setState(() => _hasPrimaryFocus = hasFocus);
    }
  }

  int? _firstEnabledIndex() {
    final items = widget.items;
    if (items == null) return null;
    for (var i = 0; i < items.length; i++) {
      if (items[i].enabled) return i;
    }
    return null;
  }

  int? _moveActive(int direction, {int? pageSize}) {
    final items = widget.items;
    if (items == null || items.isEmpty) return null;
    var index = _activeIndex ?? (direction < 0 ? items.length : -1);
    final step = pageSize ?? 1;
    for (var count = 0; count < step; count++) {
      var candidate = index + direction.sign;
      candidate = candidate.clamp(0, items.length - 1);
      while (candidate != index && !items[candidate].enabled) {
        final next = candidate + direction.sign;
        if (next < 0 || next >= items.length) break;
        candidate = next;
      }
      if (items[candidate].enabled) index = candidate;
    }
    if (index < 0 || index >= items.length || !items[index].enabled) {
      return _firstEnabledIndex();
    }
    return index;
  }

  void _setActiveIndex(
    int? index, {
    bool scrollIntoView = true,
    bool keyboard = false,
  }) {
    if (index == null || widget.items?[index].enabled != true) return;
    if (index == _activeIndex) {
      if (keyboard && _keyboardActiveIndex != index) {
        setState(() => _keyboardActiveIndex = index);
      }
      return;
    }
    setState(() {
      _activeIndex = index;
      if (keyboard) _keyboardActiveIndex = index;
    });
    if (scrollIntoView) {
      _popupKey.currentState?.ensureActiveVisible();
    }
  }

  void _handlePointerActiveChanged(int index) {
    _setActiveIndex(index, scrollIntoView: false);
  }

  void _selectIndex(int index) {
    final items = widget.items;
    if (items == null || !items[index].enabled) return;
    items[index].onTap?.call();
    _onChanged(items[index].value);
    closePopup();
  }

  void _onChanged(T? value) => widget.onChanged?.call(value);

  String? _searchLabel(ComboBoxItem<T> item) {
    if (item.searchLabel != null) return item.searchLabel;
    final child = item.child;
    if (child is Text) return child.data ?? child.textSpan?.toPlainText();
    return null;
  }

  bool _handleTypeAhead(String input) {
    final items = widget.items;
    if (items == null || input.isEmpty) return false;
    final character = input.toLowerCase();
    if (_searchTimer?.isActive != true) {
      _searchBuffer = '';
    }
    if (_searchBuffer.isNotEmpty &&
        _searchBuffer.split('').every((value) => value == character)) {
      _searchBuffer = character;
    } else {
      _searchBuffer += character;
    }
    _searchTimer?.cancel();
    _searchTimer = Timer(_kComboBoxSearchDuration, () {
      _searchBuffer = '';
    });

    final start = (_isOpen ? _activeIndex : _selectedIndex) ?? -1;
    int? match;
    for (var offset = 1; offset <= items.length; offset++) {
      final index = (start + offset) % items.length;
      final label = _searchLabel(items[index]);
      if (items[index].enabled &&
          label != null &&
          label.toLowerCase().startsWith(_searchBuffer)) {
        match = index;
        break;
      }
    }
    if (match == null) return false;
    if (_isOpen) {
      _setActiveIndex(match, keyboard: true);
    } else {
      _onChanged(items[match].value);
    }
    return true;
  }

  KeyEventResult _handleClosedKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
        event.logicalKey == LogicalKeyboardKey.arrowUp) {
      openPopup();
      return KeyEventResult.handled;
    }
    final character = event.character;
    if (character != null && character.trim().isNotEmpty) {
      return _handleTypeAhead(character)
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _handlePopupKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      closePopup();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      final active = _activeIndex;
      if (active != null) _selectIndex(active);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.tab) {
      closePopup();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowUp) {
      _setActiveIndex(
        _moveActive(key == LogicalKeyboardKey.arrowDown ? 1 : -1),
        keyboard: true,
      );
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home) {
      _setActiveIndex(_firstEnabledIndex(), keyboard: true);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      final index = switch (widget.items) {
        final items? => items.lastIndexWhere((item) => item.enabled),
        _ => -1,
      };
      _setActiveIndex(index == -1 ? null : index, keyboard: true);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.pageDown ||
        key == LogicalKeyboardKey.pageUp) {
      final page = math.max(
        1,
        (_popupKey.currentContext?.size?.height ?? 200) ~/ 38,
      );
      _setActiveIndex(
        _moveActive(key == LogicalKeyboardKey.pageDown ? page : -page),
        keyboard: true,
      );
      return KeyEventResult.handled;
    }
    final character = event.character;
    if (character != null && character.trim().isNotEmpty) {
      return _handleTypeAhead(character)
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }
    return KeyEventResult.ignored;
  }

  Color _iconColor(BuildContext context) {
    final resources = FluentTheme.of(context).resources;
    if (!isEnabled) {
      return widget.iconDisabledColor ?? resources.textFillColorDisabled;
    }
    if (widget.iconEnabledColor != null) return widget.iconEnabledColor!;
    final states = HoverButton.maybeOf(context)?.states ?? <WidgetState>{};
    return states.isPressed
        ? resources.textFillColorTertiary
        : resources.textFillColorSecondary;
  }

  double _preferredPopupWidth(
    BuildContext context,
    TextStyle style,
    double minimumWidth,
  ) {
    var width = minimumWidth;
    final textDirection = Directionality.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    for (final item in widget.items ?? <ComboBoxItem<T>>[]) {
      final child = item.child;
      if (child is! Text) continue;
      final text = child.data ?? child.textSpan?.toPlainText();
      if (text == null || text.isEmpty) continue;
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: textDirection,
        textScaler: scaler,
      )..layout();
      width = math.max<double>(
        width,
        painter.width + _kMenuItemPadding.horizontal + 12 + 24,
      );
    }
    return width;
  }

  String? _selectedSearchLabel() {
    final index = _selectedIndex;
    final items = widget.items;
    return index == null || items == null ? null : _searchLabel(items[index]);
  }

  Widget _buildPopup(BuildContext context, OverlayChildLayoutInfo info) {
    final items = widget.items;
    final controller = _scrollController;
    if (items == null || controller == null) return const SizedBox.shrink();
    final transform = info.childPaintTransform;
    final anchorRect = MatrixUtils.transformRect(
      transform,
      Offset.zero & info.childSize,
    );
    final media = MediaQuery.of(context);
    final bounds = Rect.fromLTRB(
      media.padding.left,
      media.padding.top,
      info.overlaySize.width - media.padding.right,
      info.overlaySize.height - media.padding.bottom,
    );
    final overlay = Overlay.maybeOf(context);
    final overlayBox = overlay?.context.findRenderObject() as RenderBox?;
    final anchorCenterGlobalY = overlayBox == null
        ? anchorRect.center.dy
        : overlayBox.localToGlobal(anchorRect.center).dy;
    final textDirection = Directionality.of(context);
    final style = widget.style ?? FluentTheme.of(context).typography.body!;
    final estimate = _estimatedItemHeight(context);
    final preferredWidth = _preferredPopupWidth(
      context,
      style,
      anchorRect.width,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Semantics(
            label: FluentLocalizations.of(context).modalBarrierDismissLabel,
            button: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: closePopup,
              child: const SizedBox.expand(),
            ),
          ),
        ),
        Positioned.fill(
          child: CustomSingleChildLayout(
            delegate: _ComboBoxPopupLayout(
              anchorRect: anchorRect,
              bounds: bounds,
              popupConstraints: widget.popupConstraints,
              preferredWidth: preferredWidth,
              textDirection: textDirection,
              selectedIndex: _popupAnchorIndex,
              estimatedItemHeight: estimate,
              scrollOffset: _popupAnchorScrollOffset,
            ),
            child: FocusScope(
              node: _popupScopeNode,
              child: Focus(
                focusNode: _popupFocusNode,
                onKeyEvent: _handlePopupKey,
                child: Semantics(
                  scopesRoute: true,
                  namesRoute: true,
                  explicitChildNodes: true,
                  label: FluentLocalizations.of(context).dialogLabel,
                  child: _ComboBoxPopup<T>(
                    key: _popupKey,
                    items: items,
                    selectedIndex: _selectedIndex,
                    activeIndex: _activeIndex,
                    animationIndex: _popupAnchorIndex,
                    keyboardActiveIndex: _keyboardActiveIndex,
                    itemPadding: _kMenuItemPadding,
                    style: style,
                    popupColor: widget.popupColor,
                    elevation: widget.elevation,
                    animation: _animationController,
                    scrollController: controller,
                    anchorCenterGlobalY: anchorCenterGlobalY,
                    searchLabel: _searchLabel,
                    onActiveChanged: _handlePointerActiveChanged,
                    onSelected: _selectIndex,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasFluentLocalizations(context));
    assert(debugCheckHasDirectionality(context));

    final theme = FluentTheme.of(context);
    final textStyle = widget.style ?? theme.typography.body!;
    final items = widget.items == null
        ? <Widget>[]
        : widget.selectedItemBuilder == null
        ? List<Widget>.from(widget.items!)
        : List<Widget>.from(widget.selectedItemBuilder!(context));
    int? placeholderIndex;
    if (widget.placeholder != null ||
        (!isEnabled && widget.disabledPlaceholder != null)) {
      final placeholder = isEnabled
          ? widget.placeholder!
          : widget.disabledPlaceholder ?? widget.placeholder!;
      placeholderIndex = items.length;
      items.add(
        DefaultTextStyle.merge(
          style: textStyle.copyWith(
            color: isEnabled
                ? theme.resources.textFillColorSecondary
                : theme.resources.textFillColorDisabled,
          ),
          child: IgnorePointer(child: placeholder),
        ),
      );
    }

    final displayIndex = _selectedIndex ?? placeholderIndex;
    final innerItems = displayIndex == null
        ? const SizedBox.shrink()
        : _ContainerWithoutPadding(child: items[displayIndex]);
    final minimumControlHeight = math.max<double>(
      0,
      kComboBoxItemHeight -
          _kMenuItemBottomPadding +
          theme.visualDensity.baseSizeAdjustment.dy,
    );
    final result = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minimumControlHeight),
      child: DefaultTextStyle.merge(
        style: isEnabled
            ? textStyle
            : textStyle.copyWith(color: theme.resources.textFillColorDisabled),
        child: Padding(
          padding: _kAlignedButtonPadding.resolve(Directionality.of(context)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: widget.isExpanded
                ? MainAxisSize.max
                : MainAxisSize.min,
            children: [
              if (widget.isExpanded)
                Expanded(child: innerItems)
              else
                innerItems,
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 8),
                child: IconTheme.merge(
                  data: IconThemeData(
                    color: _iconColor(context),
                    size: widget.iconSize,
                  ),
                  child: widget.icon,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _handleClosedKey,
      child: Semantics(
        button: true,
        enabled: isEnabled,
        expanded: _isOpen,
        label: _selectedSearchLabel(),
        child: OverlayPortal.overlayChildLayoutBuilder(
          controller: _overlayController,
          overlayChildBuilder: _buildPopup,
          child: Button(
            key: _controlKey,
            onPressed: isEnabled ? openPopup : null,
            autofocus: widget.autofocus,
            focusNode: focusNode,
            style: const ButtonStyle(
              padding: WidgetStatePropertyAll(EdgeInsetsDirectional.zero),
            ),
            child: result,
          ),
        ),
      ),
    );
  }
}
