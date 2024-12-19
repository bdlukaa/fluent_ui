part of 'tab_view.dart';

enum CloseButtonVisibilityMode {
  /// The close button will never be visible
  never,

  /// The close button will always be visible
  always,

  /// The close button will only be shown on hover
  onHover,
}

/// Determines how the tab sizes itself
enum TabWidthBehavior {
  /// The tab will fit its content
  sizeToContent,

  /// If not scrollable, the tabs will have the same size
  equal,

  /// If not selected, the [Tab]'s text is hidden. The tab will fit its content
  compact,
}

/// The data that is passed to the [Tab] widget.
///
/// This is used to determine the state of the tab, such as if it's selected,
/// if it's reorderable, and more.
///
/// See also:
///
///   * [Tab], the widget that uses this data.
///   * [TabView], the widget that uses the [Tab] widget.
class TabData extends InheritedWidget {
  const TabData({
    super.key,
    required super.child,
    required this.selected,
    required this.onPressed,
    required this.onClose,
    required this.reorderIndex,
    required this.animationDuration,
    required this.animationCurve,
    required this.visibilityMode,
    required this.tabWidthBehavior,
  });

  /// Whether the tab is selected or not.
  final bool selected;

  /// Called when the tab is pressed.
  ///
  /// If null, the tab is not pressable or disabled.
  final VoidCallback? onPressed;

  /// Called when the tab is closed.
  ///
  /// If null, the tab is not closeable.
  final VoidCallback? onClose;

  /// The index of the tab in the list of tabs.
  final int? reorderIndex;

  /// The duration of the animation when the tab is closed.
  final Duration animationDuration;

  /// The curve of the animation when the tab is closed.
  final Curve animationCurve;

  /// The visibility mode of the close button.
  ///
  /// See also:
  ///
  ///   * [TabView.closeButtonVisibility], the property that determines the
  ///     visibility mode of the close button.
  final CloseButtonVisibilityMode visibilityMode;

  /// The behavior of the tab width.
  ///
  /// See also:
  ///
  ///   * [TabView.tabWidthBehavior], the property that determines the behavior
  ///     of the tab width.
  final TabWidthBehavior tabWidthBehavior;

  static TabData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TabData>()!;
  }

  @override
  bool updateShouldNotify(TabData oldWidget) {
    return true;
  }
}

class _TabBody extends StatefulWidget {
  final int index;
  final List<Tab> tabs;

  const _TabBody({required this.index, required this.tabs});

  @override
  State<_TabBody> createState() => __TabBodyState();
}

class __TabBodyState extends State<_TabBody> {
  final _pageKey = GlobalKey<State<PageView>>();
  PageController? _pageController;

  PageController get pageController => _pageController!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pageController ??= PageController(initialPage: widget.index);
  }

  @override
  void didUpdateWidget(_TabBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (pageController.hasClients) {
      if (oldWidget.index != widget.index ||
          pageController.page != widget.index) {
        pageController.jumpToPage(widget.index);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      key: _pageKey,
      physics: const NeverScrollableScrollPhysics(),
      controller: pageController,
      itemCount: widget.tabs.length,
      itemBuilder: (context, index) {
        final isSelected = widget.index == index;
        final item = widget.tabs[index];

        return ExcludeFocus(
          key: ValueKey(index),
          excluding: !isSelected,
          child: FocusTraversalGroup(
            child: item.body,
          ),
        );
      },
    );
  }
}

/// Represents a single tab within a [TabView].
class Tab extends StatefulWidget {
  final _tabKey = GlobalKey<TabState>(debugLabel: 'Tab key');

  /// Creates a tab.
  Tab({
    super.key,
    this.icon = const SizedBox.shrink(),
    required this.text,
    required this.body,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.outlineColor,
    this.closeIcon = const Icon(FluentIcons.chrome_close),
    this.onClosed,
    this.semanticLabel,
    this.disabled = false,
    this.gestures = const {},
  });

  /// the IconSource to be displayed within the tab.
  ///
  /// Usually an [Icon] widget
  final Widget? icon;

  /// The content that appears inside the tab strip to represent the tab.
  ///
  /// Usually a [Text] widget
  final Widget text;

  /// The close icon of the tab.
  ///
  /// Usually an [Icon] widget.
  final Widget? closeIcon;

  /// Called when clicking x-to-close button or when the `Ctrl + T` or
  /// `Ctrl + F4` is executed
  ///
  /// If null, the tab is not closeable and the close button will not be shown.
  final VoidCallback? onClosed;

  /// {@macro fluent_ui.controls.inputs.HoverButton.semanticLabel}
  final String? semanticLabel;

  /// The body of the view attached to this tab
  final Widget body;

  /// The background color of the tab.
  final Color? backgroundColor;

  /// The background color of the tab if it is selected.
  final Color? selectedBackgroundColor;

  /// The outline color of the tab.
  final Color? outlineColor;

  /// Whether the tab is disabled or not.
  ///
  /// If true, the tab will be greyed out.
  final bool disabled;

  /// The gestures that this widget will attempt to recognize.
  ///
  /// This should be a map from [GestureRecognizer] subclasses to
  /// [GestureRecognizerFactory] subclasses specialized with the same type.
  ///
  /// This value can be late-bound at layout time using
  /// [RawGestureDetectorState.replaceGestureRecognizers].
  ///
  /// See also:
  ///
  ///   * [RawGestureDetector.gestures], which this value is passed to.
  final Map<Type, GestureRecognizerFactory> gestures;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(FlagProperty(
        'disabled',
        value: disabled,
        defaultValue: false,
        ifFalse: 'enabled',
      ))
      ..add(ObjectFlagProperty(
        'onClosed',
        onClosed,
        ifNull: 'not closeable',
      ))
      ..add(ColorProperty('backgroundColor', backgroundColor))
      ..add(ColorProperty('selectedBackgroundColor', selectedBackgroundColor))
      ..add(ColorProperty('outlineColor', outlineColor))
      ..add(DiagnosticsProperty<Widget>('text', text))
      ..add(DiagnosticsProperty<Widget>('body', body))
      ..add(DiagnosticsProperty<Widget>('icon', icon))
      ..add(DiagnosticsProperty<Widget>('closeIcon', closeIcon))
      ..add(StringProperty('semanticLabel', semanticLabel));
  }

  @override
  State<Tab> createState() => TabState();
}

class TabState extends State<Tab>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final controller = AnimationController(vsync: this);

  TabData get tab => TabData.of(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (controller.duration == null) {
      controller
        ..duration = tab.animationDuration
        ..forward();
    } else {
      controller.duration = tab.animationDuration;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final res = theme.resources;
    final localizations = FluentLocalizations.of(context);

    // The text of the tab, if a [Text] widget is used
    final text = () {
      if (widget.text is Text) {
        return (widget.text as Text).data ??
            (widget.text as Text).textSpan?.toPlainText();
      } else if (widget.text is RichText) {
        return (widget.text as RichText).text.toPlainText();
      }
    }();

    return HoverButton(
      key: widget.key,
      semanticLabel: widget.semanticLabel ?? text,
      onPressed: widget.disabled ? null : tab.onPressed,
      gestures: widget.gestures,
      builder: (context, states) {
        // https://github.com/microsoft/microsoft-ui-xaml/blob/main/dev/TabView/TabView_themeresources.xaml#L15-L19
        final foregroundColor =
            WidgetStateProperty.resolveWith<Color>((states) {
          if (tab.selected) {
            return res.textFillColorPrimary;
          } else if (states.isPressed) {
            return res.textFillColorSecondary;
          } else if (states.isHovered) {
            return res.textFillColorPrimary;
          } else if (states.isDisabled) {
            return res.textFillColorDisabled;
          } else {
            return res.textFillColorSecondary;
          }
        }).resolve(states);

        /// https://github.com/microsoft/microsoft-ui-xaml/blob/main/dev/TabView/TabView_themeresources.xaml#L10-L14
        final backgroundColor =
            WidgetStateProperty.resolveWith<Color>((states) {
          if (tab.selected) {
            return res.solidBackgroundFillColorTertiary;
          } else if (states.isPressed) {
            return res.layerOnMicaBaseAltFillColorDefault;
          } else if (states.isHovered) {
            return res.layerOnMicaBaseAltFillColorSecondary;
          } else if (states.isDisabled) {
            return res.layerOnMicaBaseAltFillColorTransparent;
          } else {
            return res.layerOnMicaBaseAltFillColorTransparent;
          }
        }).resolve(states);

        const borderRadius = BorderRadius.vertical(top: Radius.circular(6));
        Widget child = FocusBorder(
          focused: states.isFocused,
          renderOutside: false,
          style: const FocusThemeData(borderRadius: borderRadius),
          child: Container(
            key: widget._tabKey,
            height: _kTileHeight,
            constraints: tab.tabWidthBehavior == TabWidthBehavior.sizeToContent
                ? const BoxConstraints(minHeight: 28.0)
                : const BoxConstraints(
                    maxWidth: _kMaxTileWidth,
                    minHeight: 28.0,
                  ),
            padding: tab.selected
                ? const EdgeInsetsDirectional.only(
                    start: 9,
                    top: 3,
                    end: 5,
                    bottom: 4,
                  )
                : const EdgeInsetsDirectional.only(
                    start: 8,
                    top: 3,
                    end: 4,
                    bottom: 3,
                  ),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              // if selected, the background is painted by _TabPainter
              color: (tab.selected
                      ? widget.selectedBackgroundColor
                      : widget.backgroundColor) ??
                  backgroundColor,
            ),
            child: () {
              final result = ClipRect(
                child: DefaultTextStyle.merge(
                  style: (theme.typography.body ?? const TextStyle()).copyWith(
                    fontSize: 12.0,
                    fontWeight: tab.selected ? FontWeight.w600 : null,
                    color: foregroundColor,
                  ),
                  child: IconTheme.merge(
                    data: IconThemeData(
                      color: foregroundColor,
                      size: 16.0,
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      if (widget.icon != null)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 10.0),
                          child: widget.icon!,
                        ),
                      if (tab.tabWidthBehavior != TabWidthBehavior.compact ||
                          (tab.tabWidthBehavior == TabWidthBehavior.compact &&
                              tab.selected))
                        Flexible(
                          fit: tab.tabWidthBehavior == TabWidthBehavior.equal
                              ? FlexFit.tight
                              : FlexFit.loose,
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(end: 4.0),
                            child: DefaultTextStyle.merge(
                              softWrap: false,
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: const TextStyle(fontSize: 12.0),
                              child: widget.text,
                            ),
                          ),
                        ),
                      if (widget.onClosed != null &&
                          widget.closeIcon != null &&
                          (tab.visibilityMode ==
                                  CloseButtonVisibilityMode.always ||
                              (tab.visibilityMode ==
                                      CloseButtonVisibilityMode.onHover &&
                                  states.isHovered)))
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 4.0),
                          child: FocusTheme(
                            data: const FocusThemeData(
                              primaryBorder: BorderSide.none,
                              secondaryBorder: BorderSide.none,
                            ),
                            child: Tooltip(
                              message: localizations.closeTabLabel,
                              child: SizedBox(
                                height: 24.0,
                                width: 32.0,
                                child: IconButton(
                                  icon: widget.closeIcon!,
                                  onPressed: tab.onClose,
                                  focusable: false,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ]),
                  ),
                ),
              );
              if (tab.reorderIndex != null) {
                return ReorderableDragStartListener(
                  index: tab.reorderIndex!,
                  enabled: !widget.disabled,
                  child: result,
                );
              }
              return result;
            }(),
          ),
        );
        if (text != null) {
          child = Tooltip(
            message: text,
            style: const TooltipThemeData(preferBelow: true),
            child: child,
          );
        }
        if (tab.selected) {
          child = CustomPaint(
            painter: _TabPainter(backgroundColor, widget.outlineColor),
            child: child,
          );
        }
        return Semantics(
          selected: tab.selected,
          focusable: true,
          focused: states.isFocused,
          child: SmallIconButton(child: child),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _TabPainter extends CustomPainter {
  final Color color;
  final Color? outlineColor;

  const _TabPainter(this.color, this.outlineColor);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    const radius = 6.0;
    path
      ..moveTo(-radius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - radius)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, size.height - radius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width + radius,
        size.height,
      );

    if (outlineColor != null) {
      final outlinePaint = Paint()
        ..color = outlineColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawPath(path, outlinePaint);
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_TabPainter oldDelegate) => color != oldDelegate.color;

  @override
  bool shouldRebuildSemantics(_TabPainter oldDelegate) => false;
}

class _TabViewScrollBehavior extends ScrollBehavior {
  const _TabViewScrollBehavior();

  @override
  Widget buildScrollbar(context, child, details) {
    return child;
  }
}
