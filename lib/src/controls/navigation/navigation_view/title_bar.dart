import 'package:fluent_ui/fluent_ui.dart';

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
    this.isPaneToggleButtonVisible,
    this.onPaneToggleRequested,
    this.paneToggleButton,
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

  /// Whether the pane toggle button is visible.
  ///
  /// If not provided, the pane toggle button is visible if the parent
  /// [NavigationView] allows.
  final bool? isPaneToggleButtonVisible;

  /// The callback to call when the pane toggle button is pressed.
  final VoidCallback? onPaneToggleRequested;

  /// The pane toggle button widget.
  ///
  /// If provided, [onPaneToggleRequested] will not be called.
  ///
  /// Usually a [PaneToggleButton] widget.
  final Widget? paneToggleButton;

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
    assert(debugCheckHasFluentLocalizations(context));
    final theme = FluentTheme.of(context);
    final localizations = FluentLocalizations.of(context);
    final view = NavigationView.dataOf(context);

    final isBackButtonEnabled =
        this.isBackButtonEnabled ?? Navigator.of(context).canPop();

    final isPaneToggleButtonVisible =
        this.isPaneToggleButtonVisible ?? view.isTogglePaneButtonVisible;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (_) => onDragStarted?.call(),
      onPanEnd: (_) => onDragEnded?.call(),
      onPanCancel: () => onDragCancelled?.call(),
      onPanUpdate: (_) => onDragUpdated?.call(),
      child: Container(
        constraints: BoxConstraints(
          // according to documentation, increase the size of the title bar if
          // there is content
          minHeight: content != null ? 48 : 32,
          maxHeight: 48,
        ),
        child: Row(
          spacing: 16,
          children: [
            Expanded(
              child: Row(
                children: [
                  if (isBackButtonVisible)
                    Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 6,
                      ),
                      width:
                          view.pane?.size?.compactWidth ??
                          kCompactNavigationPaneWidth,
                      child: Tooltip(
                        message: localizations.backButtonTooltip,
                        child: IconButton(
                          icon: const Icon(WindowsIcons.back),
                          onPressed: isBackButtonEnabled
                              ? onBackRequested
                              : null,
                        ),
                      ),
                    ),
                  if (isPaneToggleButtonVisible)
                    paneToggleButton ??
                        PaneToggleButton(onPressed: onPaneToggleRequested),
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
                  if (title != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 6,
                      ),
                      child: DefaultTextStyle.merge(
                        style: theme.typography.body?.copyWith(
                          color: theme.resources.textFillColorPrimary,
                        ),
                        child: title!,
                      ),
                    ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 6),
                      child: DefaultTextStyle.merge(
                        style: theme.typography.body?.copyWith(
                          color: theme.resources.textFillColorSecondary,
                        ),
                        child: subtitle!,
                      ),
                    ),
                ],
              ),
            ),
            if (content != null) Expanded(child: content!),
            Expanded(
              child: Row(
                spacing: 16,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (endHeader != null) endHeader!,
                  // min drag region
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 48),
                  ),
                  if (captionControls != null) captionControls!,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
