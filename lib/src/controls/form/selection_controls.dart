// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter/rendering.dart';

const double _kToolbarScreenPadding = 8.0;
const double _kToolbarWidth = 180.0;

class _FluentTextSelectionControls extends TextSelectionControls {
  /// Fluent has no text selection handles.
  @override
  Size getHandleSize(double textLineHeight) {
    return Size.zero;
  }

  /// Builder for the Material-style desktop copy/paste text selection toolbar.
  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset selectionMidpoint,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ClipboardStatusNotifier clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) {
    return _FluentTextSelectionControlsToolbar(
      clipboardStatus: clipboardStatus,
      endpoints: endpoints,
      globalEditableRegion: globalEditableRegion,
      handleCut: canCut(delegate) ? () => handleCut(delegate) : null,
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
  ]) {
    return const SizedBox.shrink();
  }

  /// Gets the position for the text selection handles, but desktop has none.
  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) {
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

/// Text selection controls that loosely follows Material design conventions.
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
    extends State<_FluentTextSelectionControlsToolbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  ClipboardStatusNotifier? _clipboardStatus;

  void _onChangedClipboardStatus() {
    setState(() {
      // Inform the widget that the value of clipboardStatus has changed.
    });
  }

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
    if (widget.handlePaste != null) {
      _clipboardStatus = widget.clipboardStatus ?? ClipboardStatusNotifier();
      _clipboardStatus!.addListener(_onChangedClipboardStatus);
      _clipboardStatus!.update();
    }
    _ac.forward();
  }

  @override
  void didUpdateWidget(_FluentTextSelectionControlsToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clipboardStatus != widget.clipboardStatus) {
      if (_clipboardStatus != null) {
        _clipboardStatus!.removeListener(_onChangedClipboardStatus);
        _clipboardStatus!.dispose();
      }
      _clipboardStatus = widget.clipboardStatus ?? ClipboardStatusNotifier();
      _clipboardStatus!.addListener(_onChangedClipboardStatus);
      if (widget.handlePaste != null) {
        _clipboardStatus!.update();
      }
    }
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
    // When used in an Overlay, this can be disposed after its creator has
    // already disposed _clipboardStatus.
    if (_clipboardStatus != null && !_clipboardStatus!.disposed) {
      _clipboardStatus!.removeListener(_onChangedClipboardStatus);
      if (widget.clipboardStatus == null) {
        _clipboardStatus!.dispose();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't render the menu until the state of the clipboard is known.
    if (widget.handlePaste != null &&
        _clipboardStatus!.value == ClipboardStatus.unknown) {
      return const SizedBox(width: 0.0, height: 0.0);
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
      IconData icon,
      String tooltip,
      VoidCallback onPressed,
    ) {
      items.add(_FluentTextSelectionToolbarButton(
        onPressed: onPressed,
        icon: icon,
        tooltip: tooltip,
        text: text,
      ));
    }

    if (widget.handleCut != null) {
      addToolbarButton(
        localizations.cutButtonLabel,
        FluentIcons.cut,
        "Ctrl+X",
        widget.handleCut!,
      );
    }
    if (widget.handleCopy != null) {
      addToolbarButton(
        localizations.copyButtonLabel,
        FluentIcons.copy,
        "Ctrl+C",
        widget.handleCopy!,
      );
    }
    if (widget.handlePaste != null &&
        _clipboardStatus!.value == ClipboardStatus.pasteable) {
      addToolbarButton(
        localizations.pasteButtonLabel,
        FluentIcons.paste,
        "Ctrl+V",
        widget.handlePaste!,
      );
    }
    if (widget.handleSelectAll != null) {
      addToolbarButton(
        localizations.selectAllButtonLabel,
        FluentIcons.select_all,
        "Ctrl+A",
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
      animation: CurvedAnimation(
        parent: _ac.view,
        curve: Curves.decelerate,
      ),
    );
  }
}

/// A Material-style desktop text selection toolbar.
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
///    default to build a Material-style desktop toolbar.
///  * [TextSelectionToolbar], which is similar, but builds an Android-style
///    toolbar.
class _FluentTextSelectionToolbar extends StatelessWidget {
  /// Creates an instance of _FluentTextSelectionToolbar.
  const _FluentTextSelectionToolbar({
    Key? key,
    required this.anchor,
    required this.children,
    required this.animation,
  })  : assert(children.length > 0),
        super(key: key);

  /// The point at which the toolbar will attempt to position itself as closely
  /// as possible.
  final Offset anchor;

  /// {@macro flutter.material.TextSelectionToolbar.children}
  ///
  /// See also:
  ///   * [FluentTextSelectionToolbarButton], which builds a default
  ///     Material-style desktop text selection toolbar text button.
  final List<Widget> children;

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final double paddingAbove = mediaQuery.padding.top + _kToolbarScreenPadding;
    final Offset localAdjustment = Offset(_kToolbarScreenPadding, paddingAbove);
    final bool isDark = FluentTheme.of(context).brightness == Brightness.dark;

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
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Acrylic(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
                side: BorderSide(
                  width: 1,
                  color: Colors.black.withOpacity(isDark ? 0.36 : 0.14),
                ),
              ),
              elevation: 32.0,
              tint: isDark ? Color(0xFF2F2F2F) : Color(0xFFEFEFEF),
              child: Align(
                alignment: Alignment.topLeft,
                widthFactor: animation.value,
                heightFactor: animation.value,
                child: SizedBox(
                  width: _kToolbarWidth,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: children,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

const TextStyle _kToolbarButtonFontStyle = TextStyle(
  inherit: false,
  fontSize: 14.0,
  letterSpacing: -0.15,
  fontWeight: FontWeight.w400,
);

/// A [TextButton] for the Material desktop text selection toolbar.
class _FluentTextSelectionToolbarButton extends StatelessWidget {
  _FluentTextSelectionToolbarButton({
    Key? key,
    required this.onPressed,
    required this.text,
    required this.icon,
    required this.tooltip,
  }) : super(key: key);

  final VoidCallback onPressed;
  final String text;
  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = FluentTheme.of(context);
    final Brightness acrylicBrightness =
        m.ThemeData.estimateBrightnessForColor(theme.acrylicBackgroundColor);
    final Color primary =
        acrylicBrightness.isDark ? Colors.white : Colors.black;

    return Button(
      style: ButtonStyle(
        backgroundColor: ButtonState.resolveWith(
          (states) {
            if (states.contains(ButtonStates.pressing)) {
              return primary.withOpacity(0.2);
            }
            if (states.contains(ButtonStates.hovering) ||
                states.contains(ButtonStates.focused)) {
              return primary.withOpacity(0.1);
            }
            return Colors.transparent;
          },
        ),
        padding: ButtonState.all(EdgeInsets.zero),
        zFactor: ButtonState.all(1),
      ),
      onPressed: onPressed,
      child: Container(
        constraints: BoxConstraints(
          minWidth: kMinInteractiveDimension,
          minHeight: 32,
        ),
        padding: EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: primary.withOpacity(1),
            ),
            SizedBox(width: 12),
            Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: _kToolbarButtonFontStyle.copyWith(
                color: primary.withOpacity(1),
              ),
            ),
            Spacer(),
            Text(
              tooltip,
              style: _kToolbarButtonFontStyle.copyWith(
                color: primary.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
