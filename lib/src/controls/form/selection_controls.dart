// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

// The minimum padding from all edges of the selection toolbar to all edges of
// the screen.
const double _kToolbarScreenPadding = 8;

// These values were measured from a screenshot of TextBox on Windows 11.
const double _kToolbarWidth = 222;

/// A Windows-styled text selection toolbar.
///
/// This toolbar appears when text is selected in a [TextBox] or [EditableText],
/// providing options like cut, copy, paste, and select all.
class FluentTextSelectionToolbar extends StatelessWidget {
  /// {@macro flutter.material.AdaptiveTextSelectionToolbar.buttonItems}
  final List<ContextMenuButtonItem> buttonItems;

  /// {@macro flutter.material.AdaptiveTextSelectionToolbar.anchors}
  final TextSelectionToolbarAnchors anchors;

  /// Creates a Fluent text selection toolbar.
  const FluentTextSelectionToolbar({
    required this.buttonItems,
    required this.anchors,
    super.key,
  });

  /// Create an instance of [FluentTextSelectionToolbar] with the default
  /// children for an [EditableText].
  ///
  /// See also:
  ///
  /// {@macro flutter.material.AdaptiveTextSelectionToolbar.new}
  /// {@macro flutter.material.AdaptiveTextSelectionToolbar.editable}
  /// {@macro flutter.material.AdaptiveTextSelectionToolbar.buttonItems}
  /// {@macro flutter.material.AdaptiveTextSelectionToolbar.selectable}
  FluentTextSelectionToolbar.editableText({
    required EditableTextState editableTextState,
    super.key,
  }) : buttonItems = editableTextState.contextMenuButtonItems,
       anchors = editableTextState.contextMenuAnchors;

  /// Returns the icon for a context menu button type.
  IconData? contextMenuTypeToIcon(ContextMenuButtonType type) {
    return switch (type) {
      ContextMenuButtonType.cut => FluentIcons.cut,
      ContextMenuButtonType.copy => FluentIcons.copy,
      ContextMenuButtonType.paste => FluentIcons.paste,
      ContextMenuButtonType.selectAll => null,
      ContextMenuButtonType.delete => FluentIcons.delete,
      ContextMenuButtonType.lookUp => FluentIcons.search,
      ContextMenuButtonType.searchWeb => FluentIcons.search,
      ContextMenuButtonType.share => FluentIcons.share,
      ContextMenuButtonType.liveTextInput => FluentIcons.live_site,
      ContextMenuButtonType.custom => null,
    };
  }

  /// Returns the localized label for a context menu button type.
  String? contextMenuTypeToLabel(
    ContextMenuButtonType type,
    BuildContext context,
  ) {
    final localizations = FluentLocalizations.of(context);
    return switch (type) {
      ContextMenuButtonType.cut => localizations.cutActionLabel,
      ContextMenuButtonType.copy => localizations.copyActionLabel,
      ContextMenuButtonType.paste => localizations.pasteActionLabel,
      ContextMenuButtonType.selectAll => localizations.selectAllActionLabel,
      ContextMenuButtonType.delete => 'Delete',
      ContextMenuButtonType.lookUp => 'Lookup',
      ContextMenuButtonType.searchWeb => 'Search Wep',
      ContextMenuButtonType.share => 'Share',
      ContextMenuButtonType.liveTextInput => 'Live Text Input',
      ContextMenuButtonType.custom => null,
    };
  }

  /// Returns the localized tooltip for a context menu button type.
  String? contextMenuTypeToTooltip(
    ContextMenuButtonType type,
    BuildContext context,
  ) {
    final localizations = FluentLocalizations.of(context);
    return switch (type) {
      ContextMenuButtonType.cut => localizations.cutActionTooltip,
      ContextMenuButtonType.copy => localizations.copyActionTooltip,
      ContextMenuButtonType.paste => localizations.pasteActionTooltip,
      ContextMenuButtonType.selectAll => localizations.selectAllActionTooltip,
      ContextMenuButtonType.delete => 'Delete',
      ContextMenuButtonType.lookUp => 'Lookup',
      ContextMenuButtonType.searchWeb => 'Search Wep',
      ContextMenuButtonType.share => 'Share',
      ContextMenuButtonType.liveTextInput => 'Live Text Input',
      ContextMenuButtonType.custom => null,
    };
  }

  /// Returns the keyboard shortcut text for a context menu button type.
  String? contextMenuTypeToShortcut(
    ContextMenuButtonType type,
    BuildContext context,
  ) {
    final localizations = FluentLocalizations.of(context);
    return switch (type) {
      ContextMenuButtonType.cut => localizations.cutShortcut,
      ContextMenuButtonType.copy => localizations.copyShortcut,
      ContextMenuButtonType.paste => localizations.pasteShortcut,
      ContextMenuButtonType.selectAll => localizations.selectAllShortcut,
      ContextMenuButtonType.delete => null,
      ContextMenuButtonType.lookUp => null,
      ContextMenuButtonType.searchWeb => null,
      ContextMenuButtonType.share => null,
      ContextMenuButtonType.liveTextInput => null,
      ContextMenuButtonType.custom => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasFluentLocalizations(context));
    final paddingAbove =
        MediaQuery.paddingOf(context).top + _kToolbarScreenPadding;
    final localAdjustment = Offset(_kToolbarScreenPadding, paddingAbove);

    final localization = FluentLocalizations.of(context);

    final orderedButtons = buttonItems
        .where((item) => item.type == ContextMenuButtonType.cut)
        .followedBy(
          buttonItems.where((item) => item.type == ContextMenuButtonType.copy),
        )
        .followedBy(
          buttonItems.where((item) => item.type == ContextMenuButtonType.paste),
        )
        .followedBy(
          buttonItems.where(
            (item) =>
                item.type == ContextMenuButtonType.custom &&
                item.label == 'Undo',
          ),
        )
        .followedBy(
          buttonItems.where(
            (item) => item.type == ContextMenuButtonType.selectAll,
          ),
        )
        .followedBy(
          buttonItems.where(
            (item) =>
                item.type == ContextMenuButtonType.custom &&
                item.label != 'Undo',
          ),
        )
        .toList();

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        _kToolbarScreenPadding,
        paddingAbove,
        _kToolbarScreenPadding,
        _kToolbarScreenPadding,
      ),
      child: CustomSingleChildLayout(
        delegate: DesktopTextSelectionToolbarLayoutDelegate(
          anchor: anchors.primaryAnchor - localAdjustment,
        ),
        child: SizedBox(
          width: _kToolbarWidth,
          child: FlyoutContent(
            child: Column(
              spacing: 4,
              mainAxisSize: MainAxisSize.min,
              children: orderedButtons.map((item) {
                if (item is UndoContextMenuButtonItem) {
                  return _FluentTextSelectionToolbarButton(
                    onPressed: item.onPressed,
                    icon: FluentIcons.undo,
                    shortcut: localization.undoShortcut,
                    tooltip: localization.undoActionLabel,
                    text: localization.undoActionLabel,
                  );
                }
                return _FluentTextSelectionToolbarButton(
                  onPressed: item.onPressed,
                  icon: contextMenuTypeToIcon(item.type),
                  shortcut: contextMenuTypeToShortcut(item.type, context) ?? '',
                  tooltip: contextMenuTypeToTooltip(item.type, context),
                  text:
                      item.label ??
                      contextMenuTypeToLabel(item.type, context) ??
                      '',
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

/// The default [FluentTextSelectionControls] instance.
final fluentTextSelectionControls = FluentTextSelectionControls();

/// Windows styled text selection handle controls.
///
/// Specifically does not manage the toolbar, which is left to
/// [EditableText.contextMenuBuilder].
class FluentTextSelectionHandleControls extends FluentTextSelectionControls
    with TextSelectionHandleControls {
  /// Creates Fluent text selection handle controls.
  FluentTextSelectionHandleControls({super.undoHistoryController});
}

/// Windows-styled text selection controls.
///
/// Provides the selection handles and gesture handling for text selection.
class FluentTextSelectionControls extends TextSelectionControls {
  /// The undo history controller for undo/redo functionality.
  final UndoHistoryController? undoHistoryController;

  /// Creates Fluent text selection controls.
  FluentTextSelectionControls({this.undoHistoryController});

  /// Windows has no text selection handles.
  @override
  Size getHandleSize(double textLineHeight) {
    return Size.zero;
  }

  @override
  @Deprecated(
    'Use `contextMenuBuilder` instead. '
    'This feature was deprecated after v3.3.0-0.5.pre.',
  )
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset selectionMidpoint,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ValueListenable<ClipboardStatus>? clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) {
    return _FluentTextSelectionControlsToolbar(
      clipboardStatus: clipboardStatus,
      endpoints: endpoints,
      globalEditableRegion: globalEditableRegion,
      handleCut: canCut(delegate) ? () => handleCut(delegate) : null,
      handleCopy: canCopy(delegate) ? () => handleCopy(delegate) : null,
      handlePaste: canPaste(delegate) ? () => handlePaste(delegate) : null,
      handleSelectAll: canSelectAll(delegate)
          ? () => handleSelectAll(delegate)
          : null,
      handleUndo: undoHistoryController == null
          ? null
          : undoHistoryController!.value.canUndo
          ? () => undoHistoryController!.undo()
          : null,
      selectionMidpoint: selectionMidpoint,
      lastSecondaryTapDownPosition: lastSecondaryTapDownPosition,
      textLineHeight: textLineHeight,
    );
  }

  /// Builds the text selection handles, but desktop has none.
  @override
  Widget buildHandle(
    BuildContext context,
    TextSelectionHandleType type,
    double textLineHeight, [
    VoidCallback? onTap,
    double? startGlyphHeight,
    double? endGlyphHeight,
  ]) {
    return const SizedBox.shrink();
  }

  /// Gets the position for the text selection handles, but desktop has none.
  @override
  Offset getHandleAnchor(
    TextSelectionHandleType type,
    double textLineHeight, [
    double? startGlyphHeight,
    double? endGlyphHeight,
  ]) {
    return Offset.zero;
  }

  @override
  bool canSelectAll(TextSelectionDelegate delegate) {
    // Allow SelectAll when selection is not collapsed, unless everything has
    // already been selected. Same behavior as Android.
    final value = delegate.textEditingValue;
    return delegate.selectAllEnabled &&
        value.text.isNotEmpty &&
        !(value.selection.start == 0 &&
            value.selection.end == value.text.length);
  }
}

// /// Text selection controls that loosely follows Windows design conventions.
// Generates the child that's passed into FluentTextSelectionToolbar.
class _FluentTextSelectionControlsToolbar extends StatefulWidget {
  const _FluentTextSelectionControlsToolbar({
    required this.clipboardStatus,
    required this.endpoints,
    required this.globalEditableRegion,
    required this.handleCopy,
    required this.handleCut,
    required this.handlePaste,
    required this.handleSelectAll,
    required this.handleUndo,
    required this.selectionMidpoint,
    required this.textLineHeight,
    required this.lastSecondaryTapDownPosition,
  });

  final ValueListenable<ClipboardStatus>? clipboardStatus;
  final List<TextSelectionPoint> endpoints;
  final Rect globalEditableRegion;
  final VoidCallback? handleCopy;
  final VoidCallback? handleCut;
  final VoidCallback? handlePaste;
  final VoidCallback? handleSelectAll;
  final VoidCallback? handleUndo;
  final Offset? lastSecondaryTapDownPosition;
  final Offset selectionMidpoint;
  final double textLineHeight;

  @override
  State<_FluentTextSelectionControlsToolbar> createState() =>
      _FluentTextSelectionControlsToolbarState();
}

class _FluentTextSelectionControlsToolbarState
    extends State<_FluentTextSelectionControlsToolbar> {
  ValueListenable<ClipboardStatus>? _clipboardStatus;

  void _onChangedClipboardStatus() {
    setState(() {
      // Inform the widget that the value of clipboardStatus has changed.
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.handlePaste != null) {
      _clipboardStatus = widget.clipboardStatus;
      _clipboardStatus!.addListener(_onChangedClipboardStatus);
    }
  }

  @override
  void didUpdateWidget(_FluentTextSelectionControlsToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clipboardStatus != widget.clipboardStatus) {
      if (_clipboardStatus != null) {
        _clipboardStatus!.removeListener(_onChangedClipboardStatus);
      }
      _clipboardStatus = widget.clipboardStatus;
      _clipboardStatus!.addListener(_onChangedClipboardStatus);
    }
  }

  @override
  void dispose() {
    super.dispose();
    // When used in an Overlay, this can be disposed after its creator has
    // already disposed _clipboardStatus.
    if (_clipboardStatus != null) {
      _clipboardStatus!.removeListener(_onChangedClipboardStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If there are no buttons to be shown, don't render anything.
    if (widget.handleCut == null &&
        widget.handleCopy == null &&
        widget.handlePaste == null &&
        widget.handleSelectAll == null) {
      return const SizedBox.shrink();
    }

    assert(debugCheckHasMediaQuery(context));
    final midpointAnchor = Offset(
      (widget.selectionMidpoint.dx - widget.globalEditableRegion.left).clamp(
        MediaQuery.paddingOf(context).left,
        MediaQuery.sizeOf(context).width - MediaQuery.paddingOf(context).right,
      ),
      widget.selectionMidpoint.dy - widget.globalEditableRegion.top,
    );

    assert(debugCheckHasFluentLocalizations(context));
    final localizations = FluentLocalizations.of(context);
    final items = <Widget>[];

    void addToolbarButton(
      String text,
      IconData? icon,
      String shortcut,
      String tooltip,
      VoidCallback onPressed,
    ) {
      items.add(
        _FluentTextSelectionToolbarButton(
          onPressed: onPressed,
          icon: icon,
          shortcut: shortcut,
          tooltip: tooltip,
          text: text,
        ),
      );
    }

    if (widget.handleCut != null) {
      addToolbarButton(
        localizations.cutActionLabel,
        FluentIcons.cut,
        localizations.cutShortcut,
        localizations.cutActionTooltip,
        widget.handleCut!,
      );
    }
    if (widget.handleCopy != null) {
      addToolbarButton(
        localizations.copyActionLabel,
        FluentIcons.copy,
        localizations.copyShortcut,
        localizations.copyActionTooltip,
        widget.handleCopy!,
      );
    }
    if (widget.handlePaste != null &&
        _clipboardStatus!.value == ClipboardStatus.pasteable) {
      addToolbarButton(
        localizations.pasteActionLabel,
        FluentIcons.paste,
        localizations.pasteShortcut,
        localizations.pasteActionTooltip,
        widget.handlePaste!,
      );
    }
    if (widget.handleUndo != null) {
      addToolbarButton(
        localizations.undoActionLabel,
        FluentIcons.undo,
        localizations.undoShortcut,
        localizations.undoActionTooltip,
        widget.handleUndo!,
      );
    }
    if (widget.handleSelectAll != null) {
      addToolbarButton(
        localizations.selectAllActionLabel,
        null,
        localizations.selectAllShortcut,
        localizations.selectAllActionTooltip,
        widget.handleSelectAll!,
      );
    }

    // If there is no option available, build an empty widget.
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return _FluentTextSelectionToolbar(
      anchor: switch (defaultTargetPlatform) {
        TargetPlatform.android ||
        TargetPlatform.iOS ||
        TargetPlatform.fuchsia => const Offset(100, 100),
        TargetPlatform.windows ||
        TargetPlatform.macOS ||
        TargetPlatform.linux =>
          widget.lastSecondaryTapDownPosition ?? midpointAnchor,
      },
      children: items,
    );
  }
}

/// A Windows-style desktop text selection toolbar.
///
/// Typically displays buttons for text manipulation, e.g. copying and pasting
/// text.
///
/// Tries to position itself as closesly as possible to [anchor] while remaining
/// fully on-screen.
///
class _FluentTextSelectionToolbar extends StatelessWidget {
  /// Creates an instance of _FluentTextSelectionToolbar.
  const _FluentTextSelectionToolbar({
    required this.anchor,
    required this.children,
  }) : assert(children.length > 0);

  /// The point at which the toolbar will attempt to position itself as closely
  /// as possible.
  final Offset anchor;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    final paddingAbove =
        MediaQuery.paddingOf(context).top + _kToolbarScreenPadding * 3;
    final localAdjustment = switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.fuchsia => Offset.zero,
      TargetPlatform.windows ||
      TargetPlatform.macOS ||
      TargetPlatform.linux => Offset(_kToolbarScreenPadding, paddingAbove),
    };

    final radius = BorderRadius.circular(6);

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        _kToolbarScreenPadding,
        paddingAbove,
        _kToolbarScreenPadding,
        _kToolbarScreenPadding,
      ),
      child: CustomSingleChildLayout(
        delegate: DesktopTextSelectionToolbarLayoutDelegate(
          anchor: anchor - localAdjustment,
        ),
        child: Acrylic(
          // elevation: 4.0,
          shape: RoundedRectangleBorder(borderRadius: radius),
          child: Container(
            color: theme.menuColor.withValues(alpha: kMenuColorOpacity),
            padding: const EdgeInsetsDirectional.all(5),
            child: SizedBox(
              width: _kToolbarWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 5,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A button for the Windows desktop text selection toolbar.
class _FluentTextSelectionToolbarButton extends StatelessWidget {
  const _FluentTextSelectionToolbarButton({
    required this.onPressed,
    required this.text,
    required this.icon,
    required this.shortcut,
    required this.tooltip,
  });

  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final String? shortcut;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return HoverButton(
      key: key,
      onPressed: onPressed,
      builder: (context, states) {
        final theme = FluentTheme.of(context);
        final radius = BorderRadius.circular(4);

        final body = theme.typography.body ?? const TextStyle();

        return FocusBorder(
          focused: states.isFocused,
          renderOutside: true,
          style: FocusThemeData(borderRadius: radius),
          child: Builder(
            builder: (context) {
              final widget = Container(
                decoration: BoxDecoration(
                  color: ButtonThemeData.uncheckedInputColor(
                    theme,
                    states,
                    transparentWhenNone: true,
                  ),
                  borderRadius: radius,
                ),
                padding: const EdgeInsetsDirectional.only(
                  top: 4,
                  bottom: 4,
                  start: 10,
                  end: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 10),
                      child: Icon(icon, size: 16),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(end: 10),
                        child: Text(
                          text,
                          style: body.merge(
                            TextStyle(
                              fontSize: 14,
                              letterSpacing: -0.15,
                              color: theme.inactiveColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (shortcut != null)
                      Text(
                        shortcut!,
                        style: body.merge(
                          const TextStyle(fontSize: 10, height: 0.7),
                        ),
                      ),
                  ],
                ),
              );

              if (tooltip != null) {
                return Tooltip(message: tooltip, child: widget);
              }
              return widget;
            },
          ),
        );
      },
    );
  }
}

/// A context menu button item for the undo action.
///
/// See also:
///
/// * [ContextMenuButtonItem], which is the base class for this class.
/// * [FluentTextSelectionToolbar], which is the widget that displays the undo action.
class UndoContextMenuButtonItem extends ContextMenuButtonItem {
  /// Creates a context menu button item for the undo action.
  const UndoContextMenuButtonItem({required super.onPressed})
    : super(type: ContextMenuButtonType.custom, label: 'Undo');
}
