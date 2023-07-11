import 'package:fluent_ui/fluent_ui.dart';

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
          color: theme.resources.controlFillColorDefault,
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
                    ? () async {
                        setState(() {});
                        await flyoutController.showFlyout(
                          barrierColor: Colors.transparent,
                          autoModeConfiguration: FlyoutAutoConfiguration(
                            preferredMode: FlyoutPlacementMode.bottomCenter,
                          ),
                          builder: (context) {
                            return widget.flyout;
                          },
                        );
                        if (mounted) setState(() {});
                      }
                    : null,
                onFocusChange: (v) => setState(() => _showFocusHighlight = v),
                builder: (context, states) {
                  return FlyoutTarget(
                    controller: flyoutController,
                    child: Container(
                      color: ButtonThemeData.buttonColor(
                        context,
                        flyoutController.isOpen
                            ? {ButtonStates.pressing}
                            : states,
                      ),
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 12.0,
                      ),
                      alignment: Alignment.center,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 100),
                        opacity: flyoutController.isOpen ? 0.5 : 1,
                        child: const ChevronDown(),
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
