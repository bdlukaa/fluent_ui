import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';

/// The title bar sits at the top of an app on the base layer. Its main purpose
/// is to allow users to be able to identify the app via its title, move the app
/// window, and minimize, maximize, or close the app.
///
/// ![](https://learn.microsoft.com/en-us/windows/apps/develop/ui/controls/images/titlebar/title-bar-custom.png)
///
/// A titlebar is divided into these areas:
///
/// ![](https://learn.microsoft.com/en-us/windows/apps/develop/ui/controls/images/titlebar/title-bar-parts.png)
///
/// See also:
///
///   * [NavigationView], for the container that holds the title bar
///   * <https://learn.microsoft.com/en-us/windows/apps/design/basics/titlebar-design>
///   * <https://learn.microsoft.com/en-us/windows/apps/develop/title-bar>
///   * <https://learn.microsoft.com/en-us/windows/apps/develop/ui/controls/title-bar>
class TitleBar extends StatelessWidget {
  /// Creates a title bar.
  const TitleBar({
    super.key,
    this.isBackButtonEnabled,
    this.isBackButtonVisible = true,
    this.backButton,
    this.onBackRequested,
    this.leftHeader,
    this.icon,
    this.title,
    this.subtitle,
    this.content,
    this.endHeader,
    this.captionControls,
    this.onDragStarted,
    this.onDragEnded,
    this.onDragCancelled,
    this.onDragUpdated,
  });

  /// Whether the back button is enabled.
  ///
  /// If not provided, the back button is enabled if the navigator can pop.
  final bool? isBackButtonEnabled;

  /// Whether the back button is visible.
  final bool isBackButtonVisible;

  /// The back button widget.
  ///
  /// Usually a [PaneBackButton] widget.
  final Widget? backButton;

  /// The callback to call when the back button is pressed.
  ///
  /// If not provided, the back button will not be displayed.
  final VoidCallback? onBackRequested;

  /// The left header widget.
  ///
  /// Usually an [Icon] widget.
  final Widget? leftHeader;

  /// The leading widget.
  ///
  /// Usually an [Icon] widget.
  final Widget? icon;

  /// The title widget.
  ///
  /// Usually a [Text] or [RichText] widget.
  final Widget? title;

  /// The subtitle widget.
  ///
  /// Usually a [Text] or [RichText] widget.
  final Widget? subtitle;

  /// The content widget.
  ///
  /// ![](https://learn.microsoft.com/en-us/windows/apps/design/basics/images/titlebar/search.png)
  ///
  /// Usually an [AutoSuggestBox] widget.
  final Widget? content;

  final Widget? endHeader;

  /// The controls of the window, if any.
  final Widget? captionControls;

  /// The callback to call when the drag starts.
  final VoidCallback? onDragStarted;

  /// The callback to call when the drag ends.
  final VoidCallback? onDragEnded;

  /// The callback to call when the drag is cancelled.
  final VoidCallback? onDragCancelled;

  /// The callback to call when the drag is updated.
  final VoidCallback? onDragUpdated;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final view = NavigationView.dataOf(context);

    final isPaneToggleButtonVisible =
        view.toggleButtonPosition == PaneToggleButtonPosition.titleBar;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (_) => onDragStarted?.call(),
      onPanEnd: (_) => onDragEnded?.call(),
      onPanCancel: () => onDragCancelled?.call(),
      onPanUpdate: (_) => onDragUpdated?.call(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          // according to documentation, increase the size of the title bar if
          // there is content
          minHeight: content != null ? 48 : 32,
          maxHeight: 48,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  if (isBackButtonVisible)
                    backButton ?? PaneBackButton(onPressed: onBackRequested),
                  if (isPaneToggleButtonVisible) ?view.pane?.toggleButton,
                  if (leftHeader != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 16),
                      child: leftHeader,
                    ),
                  if (icon != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 16),
                      child: icon,
                    ),
                  if (title != null || subtitle != null)
                    Flexible(
                      child: _TitleSubtitleOverflow(
                        title: title != null
                            ? DefaultTextStyle.merge(
                                style: theme.typography.body?.copyWith(
                                  color: theme.resources.textFillColorPrimary,
                                ),
                                maxLines: 1,
                                softWrap: false,
                                child: title!,
                              )
                            : null,
                        subtitle: subtitle != null
                            ? DefaultTextStyle.merge(
                                style: theme.typography.body?.copyWith(
                                  color: theme.resources.textFillColorSecondary,
                                ),
                                maxLines: 1,
                                softWrap: false,
                                child: subtitle!,
                              )
                            : null,
                      ),
                    ),
                ],
              ),
            ),
            if (content != null) Expanded(child: content!),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ?endHeader,
                  // min drag region
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 48),
                  ),
                  if (captionControls != null)
                    Flexible(child: captionControls!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A widget that handles overflow for title and subtitle widgets.
///
/// If there is not enough space, the subtitle is hidden first, and then
/// the title if still not enough space.
class _TitleSubtitleOverflow extends MultiChildRenderObjectWidget {
  /// Creates a title/subtitle overflow widget.
  const _TitleSubtitleOverflow({required this.title, required this.subtitle});

  /// The title widget.
  final Widget? title;

  /// The subtitle widget.
  final Widget? subtitle;

  @override
  List<Widget> get children {
    final result = <Widget>[];
    if (title != null) {
      result.add(
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 6),
          child: title,
        ),
      );
    }
    if (subtitle != null) {
      result.add(
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 6),
          child: subtitle,
        ),
      );
    }
    return result;
  }

  @override
  _RenderTitleSubtitleOverflow createRenderObject(BuildContext context) {
    return _RenderTitleSubtitleOverflow(
      hasTitle: title != null,
      hasSubtitle: subtitle != null,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderTitleSubtitleOverflow renderObject,
  ) {
    renderObject
      ..hasTitle = title != null
      ..hasSubtitle = subtitle != null;
  }
}

/// Parent data for [_TitleSubtitleOverflow] children.
class _TitleSubtitleOverflowParentData
    extends ContainerBoxParentData<RenderBox> {
  /// Whether this child is currently hidden due to overflow.
  bool isHidden = false;
}

/// Render object that handles overflow detection for title and subtitle.
class _RenderTitleSubtitleOverflow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _TitleSubtitleOverflowParentData>,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          _TitleSubtitleOverflowParentData
        > {
  _RenderTitleSubtitleOverflow({
    required bool hasTitle,
    required bool hasSubtitle,
  }) : _hasTitle = hasTitle,
       _hasSubtitle = hasSubtitle;

  bool _hasTitle;
  bool get hasTitle => _hasTitle;
  set hasTitle(bool value) {
    if (_hasTitle != value) {
      _hasTitle = value;
      markNeedsLayout();
    }
  }

  bool _hasSubtitle;
  bool get hasSubtitle => _hasSubtitle;
  set hasSubtitle(bool value) {
    if (_hasSubtitle != value) {
      _hasSubtitle = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _TitleSubtitleOverflowParentData) {
      child.parentData = _TitleSubtitleOverflowParentData();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    var width = 0.0;
    var child = firstChild;
    while (child != null) {
      width += child.getMinIntrinsicWidth(height);
      child = childAfter(child);
    }
    return width;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    var width = 0.0;
    var child = firstChild;
    while (child != null) {
      width += child.getMaxIntrinsicWidth(height);
      child = childAfter(child);
    }
    return width;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    var height = 0.0;
    var child = firstChild;
    while (child != null) {
      final childParentData =
          child.parentData! as _TitleSubtitleOverflowParentData;
      if (!childParentData.isHidden) {
        height = height > child.getMinIntrinsicHeight(width)
            ? height
            : child.getMinIntrinsicHeight(width);
      }
      child = childAfter(child);
    }
    return height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    var height = 0.0;
    var child = firstChild;
    while (child != null) {
      final childParentData =
          child.parentData! as _TitleSubtitleOverflowParentData;
      if (!childParentData.isHidden) {
        height = height > child.getMaxIntrinsicHeight(width)
            ? height
            : child.getMaxIntrinsicHeight(width);
      }
      child = childAfter(child);
    }
    return height;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _performLayout(constraints, dry: true);
  }

  Size _performLayout(BoxConstraints constraints, {required bool dry}) {
    if (firstChild == null) {
      return constraints.smallest;
    }

    // Get title and subtitle children
    RenderBox? titleChild;
    RenderBox? subtitleChild;
    var child = firstChild;
    var index = 0;
    while (child != null) {
      if (index == 0 && hasTitle) {
        titleChild = child;
      } else if ((index == 0 && !hasTitle && hasSubtitle) ||
          (index == 1 && hasTitle && hasSubtitle)) {
        subtitleChild = child;
      }
      child = childAfter(child);
      index++;
    }

    // Try to fit both title and subtitle
    var titleWidth = 0.0;
    var subtitleWidth = 0.0;
    var maxHeight = 0.0;

    if (titleChild != null) {
      // Measure with unlimited width to get true intrinsic width
      final titleConstraints = BoxConstraints(maxHeight: constraints.maxHeight);
      final titleSize = titleChild.getDryLayout(titleConstraints);
      titleWidth = titleSize.width;
      maxHeight = maxHeight > titleSize.height ? maxHeight : titleSize.height;
    }

    if (subtitleChild != null) {
      // Measure with unlimited width to get true intrinsic width
      final subtitleConstraints = BoxConstraints(
        maxHeight: constraints.maxHeight,
      );
      final subtitleSize = subtitleChild.getDryLayout(subtitleConstraints);
      subtitleWidth = subtitleSize.width;
      maxHeight = maxHeight > subtitleSize.height
          ? maxHeight
          : subtitleSize.height;
    }

    final totalWidth = titleWidth + subtitleWidth;
    final availableWidth = constraints.maxWidth;

    // Determine visibility
    var showTitle = true;
    var showSubtitle = true;

    // Only check overflow if we have finite constraints
    if (availableWidth.isFinite) {
      if (totalWidth > availableWidth) {
        // Hide subtitle first
        showSubtitle = false;
        // Check if title alone fits
        if (titleWidth > availableWidth) {
          // If title still doesn't fit, hide it too
          showTitle = false;
        }
      } else if (hasTitle && !hasSubtitle && titleWidth > availableWidth) {
        // Edge case: only title exists and it overflows
        showTitle = false;
      }
    }

    // Update parent data
    if (!dry) {
      child = firstChild;
      index = 0;
      while (child != null) {
        final childParentData =
            child.parentData! as _TitleSubtitleOverflowParentData;
        // Determine if this child should be hidden
        if (index == 0 && hasTitle) {
          // First child is title
          childParentData.isHidden = !showTitle;
        } else if ((index == 0 && !hasTitle && hasSubtitle) ||
            (index == 1 && hasTitle && hasSubtitle)) {
          // This child is subtitle
          childParentData.isHidden = !showSubtitle;
        } else {
          // Should not happen, but ensure it's visible
          childParentData.isHidden = false;
        }
        child = childAfter(child);
        index++;
      }
    }

    // Calculate final size
    final finalWidth = showTitle && showSubtitle
        ? totalWidth
        : showTitle
        ? titleWidth
        : 0.0;

    return Size(
      constraints.constrainWidth(finalWidth),
      constraints.constrainHeight(maxHeight),
    );
  }

  @override
  void performLayout() {
    final constraints = this.constraints;
    size = _performLayout(constraints, dry: false);

    // Layout visible children
    var child = firstChild;
    while (child != null) {
      final childParentData =
          child.parentData! as _TitleSubtitleOverflowParentData;
      if (!childParentData.isHidden) {
        final childConstraints = BoxConstraints.loose(size);
        child.layout(childConstraints, parentUsesSize: true);
        childParentData.offset = Offset.zero;
      }
      child = childAfter(child);
    }

    // Position children horizontally
    var offset = 0.0;
    child = firstChild;
    while (child != null) {
      final childParentData =
          child.parentData! as _TitleSubtitleOverflowParentData;
      if (!childParentData.isHidden) {
        childParentData.offset = Offset(offset, 0);
        offset += child.size.width;
      }
      child = childAfter(child);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    var child = firstChild;
    while (child != null) {
      final childParentData =
          child.parentData! as _TitleSubtitleOverflowParentData;
      if (!childParentData.isHidden) {
        final isHit = result.addWithPaintOffset(
          offset: childParentData.offset,
          position: position,
          hitTest: (result, transformed) {
            assert(transformed == position - childParentData.offset);
            return child!.hitTest(result, position: transformed);
          },
        );
        if (isHit) return true;
      }
      child = childAfter(child);
    }
    return false;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    var child = firstChild;
    while (child != null) {
      final childParentData =
          child.parentData! as _TitleSubtitleOverflowParentData;
      if (!childParentData.isHidden) {
        context.paintChild(child, offset + childParentData.offset);
      }
      child = childAfter(child);
    }
  }
}

/// The preferred position for the pane toggle button.
enum PaneToggleButtonPreferredPosition {
  /// Let the [NavigationView] decide what position should be used based on
  /// the current context.
  auto,

  /// The pane toggle button is positioned in the pane.
  pane,

  /// The pane toggle button is positioned in the title bar.
  titleBar,
}

enum PaneToggleButtonPosition {
  /// The pane toggle button is not positioned.
  none,

  /// The pane toggle button is positioned in the pane.
  pane,

  /// The pane toggle button is positioned in the title bar.
  titleBar,
}

/// A button that toggles the pane navigation.
///
/// See also:
///
///   * [TitleBar], for the title bar that contains the pane toggle button
///   * [NavigationView], for the container that holds the title bar
class PaneToggleButton extends StatelessWidget {
  /// Creates a pane toggle button.
  const PaneToggleButton({super.key, this.onPressed});

  /// The callback to call when the pane toggle button is pressed.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final view = NavigationView.dataOf(context);

    final width = view.pane?.size?.compactWidth ?? kCompactNavigationPaneWidth;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 6),
      constraints: BoxConstraints(
        minWidth: width,
        maxWidth: width,
        // minHeight: kPaneItemMinHeight,
        maxHeight: kPaneItemMinHeight,
      ),
      child: Tooltip(
        message: 'Toggle navigation',
        child: IconButton(
          icon: const Icon(WindowsIcons.global_nav_button),
          onPressed:
              onPressed ??
              () {
                NavigationView.maybeOf(context)?.togglePane();
              },
        ),
      ),
    );
  }
}

/// A button that navigates back in the pane.
///
/// See also:
///
///   * [TitleBar], for the title bar that contains the pane back button
///   * [NavigationView], for the container that holds the title bar
class PaneBackButton extends StatelessWidget {
  /// Creates a pane back button.
  const PaneBackButton({
    super.key,
    this.onPressed,
    this.enabled = true,
    this.backIcon = const Icon(WindowsIcons.back),
  });

  /// The callback to call when the pane back button is pressed.
  final VoidCallback? onPressed;

  /// Whether the back button is enabled.
  final bool enabled;

  final Widget backIcon;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentLocalizations(context));
    final localizations = FluentLocalizations.of(context);
    final view = NavigationView.of(context);
    final viewData = NavigationView.dataOf(context);
    final canPop = viewData.canPop;

    final width =
        viewData.pane?.size?.compactWidth ?? kCompactNavigationPaneWidth;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 6),
      constraints: BoxConstraints(
        minWidth: width,
        maxWidth: width,
        // minHeight: kPaneItemMinHeight,
        maxHeight: kPaneItemMinHeight,
      ),
      child: Tooltip(
        message: localizations.backButtonTooltip,
        child: IconButton(
          icon: backIcon,
          onPressed: enabled ? (onPressed ?? (canPop ? view.pop : null)) : null,
        ),
      ),
    );
  }
}
