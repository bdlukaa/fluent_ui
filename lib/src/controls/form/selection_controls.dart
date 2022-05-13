// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';

const double _kToolbarScreenPadding = 8.0;
const double _kToolbarWidth = 180.0;

class _FluentTextSelectionControls extends TextSelectionControls {
  /// Fluent has no text selection handles.
  @override
  Size getHandleSize(double textLineHeight) {
    return Size.zero;
  }

  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset selectionMidpoint,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ClipboardStatusNotifier? clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) {
    return _FluentTextSelectionControlsToolbar(
      clipboardStatus: clipboardStatus,
      endpoints: endpoints,
      globalEditableRegion: globalEditableRegion,
      handleCut:
          canCut(delegate) ? () => handleCut(delegate, clipboardStatus) : null,
      handleCopy: canCopy(delegate)
          ? () => handleCopy(delegate, clipboardStatus)
          : null,
      handlePaste: canPaste(delegate) ? () => handlePaste(delegate) : null,
      handleSelectAll:
          canSelectAll(delegate) ? () => handleSelectAll(delegate) : null,
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
    final TextEditingValue value = delegate.textEditingValue;
    return delegate.selectAllEnabled &&
        value.text.isNotEmpty &&
        !(value.selection.start == 0 &&
            value.selection.end == value.text.length);
  }
}

/// Text selection controls that loosely follows Fluent design conventions.
final TextSelectionControls fluentTextSelectionControls =
    _FluentTextSelectionControls();

// Generates the child that's passed into FluentTextSelectionToolbar.
class _FluentTextSelectionControlsToolbar extends StatefulWidget {
  const _FluentTextSelectionControlsToolbar({
    Key? key,
    required this.clipboardStatus,
    required this.endpoints,
    required this.globalEditableRegion,
    required this.handleCopy,
    required this.handleCut,
    required this.handlePaste,
    required this.handleSelectAll,
    required this.selectionMidpoint,
    required this.textLineHeight,
    required this.lastSecondaryTapDownPosition,
  }) : super(key: key);

  final ClipboardStatusNotifier? clipboardStatus;
  final List<TextSelectionPoint> endpoints;
  final Rect globalEditableRegion;
  final VoidCallback? handleCopy;
  final VoidCallback? handleCut;
  final VoidCallback? handlePaste;
  final VoidCallback? handleSelectAll;
  final Offset? lastSecondaryTapDownPosition;
  final Offset selectionMidpoint;
  final double textLineHeight;

  @override
  _FluentTextSelectionControlsToolbarState createState() =>
      _FluentTextSelectionControlsToolbarState();
}

class _FluentTextSelectionControlsToolbarState
    extends State<_FluentTextSelectionControlsToolbar> {
  ClipboardStatusNotifier? _clipboardStatus;

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
      _clipboardStatus!.update();
    }
  }

  @override
  void didUpdateWidget(_FluentTextSelectionControlsToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clipboardStatus != widget.clipboardStatus) {
      if (_clipboardStatus != null) {
        _clipboardStatus!.removeListener(_onChangedClipboardStatus);
        _clipboardStatus!.dispose();
      }
      _clipboardStatus = widget.clipboardStatus;
      _clipboardStatus!.addListener(_onChangedClipboardStatus);
      if (widget.handlePaste != null) {
        _clipboardStatus!.update();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    // When used in an Overlay, this can be disposed after its creator has
    // already disposed _clipboardStatus.
    if (_clipboardStatus != null && !_clipboardStatus!.disposed) {
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
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final Offset midpointAnchor = Offset(
      (widget.selectionMidpoint.dx - widget.globalEditableRegion.left).clamp(
        mediaQuery.padding.left,
        mediaQuery.size.width - mediaQuery.padding.right,
      ),
      widget.selectionMidpoint.dy - widget.globalEditableRegion.top,
    );

    assert(debugCheckHasFluentLocalizations(context));
    final FluentLocalizations localizations = FluentLocalizations.of(context);
    final List<Widget> items = <Widget>[];

    void addToolbarButton(
      String text,
      IconData? icon,
      String shortcut,
      String tooltip,
      VoidCallback onPressed,
    ) {
      items.add(_FluentTextSelectionToolbarButton(
        onPressed: onPressed,
        icon: icon,
        shortcut: shortcut,
        tooltip: tooltip,
        text: text,
      ));
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
      return const SizedBox(width: 0.0, height: 0.0);
    }

    return _FluentTextSelectionToolbar(
      anchor: widget.lastSecondaryTapDownPosition ?? midpointAnchor,
      children: items,
    );
  }
}

/// A Fluent-style desktop text selection toolbar.
///
/// Typically displays buttons for text manipulation, e.g. copying and pasting
/// text.
///
/// Tries to position itself as closesly as possible to [anchor] while remaining
/// fully on-screen.
///
/// See also:
///
///  * [_FluentTextSelectionControls.buildToolbar], where this is used by
///    default to build a Fluent-style desktop toolbar.
///  * [TextSelectionToolbar], which is similar, but builds an Android-style
///    toolbar.
class _FluentTextSelectionToolbar extends StatelessWidget {
  /// Creates an instance of _FluentTextSelectionToolbar.
  const _FluentTextSelectionToolbar({
    Key? key,
    required this.anchor,
    required this.children,
  })  : assert(children.length > 0),
        super(key: key);

  /// The point at which the toolbar will attempt to position itself as closely
  /// as possible.
  final Offset anchor;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final double paddingAbove = mediaQuery.padding.top + _kToolbarScreenPadding;
    final Offset localAdjustment = Offset(_kToolbarScreenPadding, paddingAbove);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        _kToolbarScreenPadding,
        paddingAbove,
        _kToolbarScreenPadding,
        _kToolbarScreenPadding,
      ),
      child: CustomSingleChildLayout(
        delegate: DesktopTextSelectionToolbarLayoutDelegate(
          anchor: anchor - localAdjustment,
        ),
        child: PhysicalModel(
          elevation: 4.0,
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6.0),
          child: Container(
            decoration: BoxDecoration(
              color: FluentTheme.of(context).micaBackgroundColor,
              borderRadius: BorderRadius.circular(6.0),
              border: Border.all(
                width: 0.25,
                color: FluentTheme.of(context).inactiveBackgroundColor,
              ),
            ),
            padding: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
            child: SizedBox(
              width: _kToolbarWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A [TextButton] for the Fluent desktop text selection toolbar.
class _FluentTextSelectionToolbarButton extends StatelessWidget {
  const _FluentTextSelectionToolbarButton({
    Key? key,
    required this.onPressed,
    required this.text,
    required this.icon,
    required this.shortcut,
    required this.tooltip,
  }) : super(key: key);

  final VoidCallback onPressed;
  final String text;
  final IconData? icon;
  final String shortcut;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return HoverButton(
      key: key,
      onPressed: onPressed,
      builder: (context, states) {
        final theme = FluentTheme.of(context);
        final radius = BorderRadius.circular(4.0);
        return Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: FocusBorder(
            focused: states.isFocused,
            renderOutside: true,
            style: FocusThemeData(borderRadius: radius),
            child: Tooltip(
              message: tooltip,
              child: Container(
                decoration: BoxDecoration(
                  color: ButtonThemeData.uncheckedInputColor(theme, states),
                  borderRadius: radius,
                ),
                padding: const EdgeInsets.only(
                  top: 4.0,
                  bottom: 4.0,
                  left: 10.0,
                  right: 8.0,
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 10.0),
                    child: Icon(icon, size: 16.0),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 10.0),
                      child: Text(
                        text,
                        style: TextStyle(
                          inherit: false,
                          fontSize: 14.0,
                          letterSpacing: -0.15,
                          color: theme.inactiveColor,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    shortcut,
                    style: TextStyle(
                      inherit: false,
                      fontSize: 12.0,
                      color: theme.borderInputColor,
                      height: 0.7,
                    ),
                  ),
                ]),
              ),
            ),
          ),
        );
      },
    );
  }
}
