import 'dart:ui' show lerpDouble;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

class SplitButton extends StatefulWidget {
  final Widget child;
  final Widget flyout;

  final bool enabled;

  const SplitButton({
    super.key,
    required this.child,
    required this.flyout,
    this.enabled = true,
  });

  @override
  State<SplitButton> createState() => _SplitButtonState();
}

class _SplitButtonState extends State<SplitButton> {
  late final FlyoutController flyoutController = FlyoutController();

  bool _showFocusHighlight = false;

  @override
  void dispose() {
    flyoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    final radius = BorderRadius.circular(6.0);

    return FocusBorder(
      focused: _showFocusHighlight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(
            color: theme.resources.controlStrokeColorDefault,
          ),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: IntrinsicHeight(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              widget.child,
              const Divider(
                direction: Axis.vertical,
                style: DividerThemeData(
                  horizontalMargin: EdgeInsets.zero,
                  verticalMargin: EdgeInsets.zero,
                ),
              ),
              HoverButton(
                onPressed: widget.enabled
                    ? () {
                        flyoutController.showFlyout(
                          autoModeConfiguration: FlyoutAutoConfiguration(
                            preferredMode: FlyoutPlacementMode.bottomCenter,
                          ),
                          builder: (context) {
                            return widget.flyout;
                          },
                        );
                      }
                    : null,
                onFocusChange: (v) => setState(() => _showFocusHighlight = v),
                builder: (context, states) {
                  return FlyoutTarget(
                    controller: flyoutController,
                    child: Container(
                      color: ButtonThemeData.buttonColor(context, states),
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 12.0,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        FluentIcons.chevron_down,
                        size: 8.0,
                      ),
                    ),
                  );
                },
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
