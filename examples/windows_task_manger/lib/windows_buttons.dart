import 'package:fluent_ui/fluent_ui.dart' hide FluentIcons;
import 'package:window_manager/window_manager.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class WindowsButtons extends StatefulWidget {
  const WindowsButtons({super.key});

  @override
  State<WindowsButtons> createState() => _WindowsButtonsState();
}

class _WindowsButtonsState extends State<WindowsButtons> with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    windowManager.addListener(this);
    windowManager.isMaximized().then((value) {
      setState(() {
        _isMaximized = value;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  void toggleToolbarMaximizedState() {
    if (_isMaximized) {
      windowManager.restore();
    } else {
      windowManager.maximize();
    }
  }

  @override
  void onWindowMinimize() {
    setState(() {
      _isMaximized = false;
    });
    super.onWindowMinimize();
  }

  @override
  void onWindowRestore() {
    setState(() {
      _isMaximized = false;
    });
    super.onWindowRestore();
  }

  @override
  void onWindowMaximize() {
    setState(() {
      _isMaximized = true;
    });
    super.onWindowMaximize();
  }

  @override
  void onWindowUnmaximize() {
    setState(() {
      _isMaximized = false;
    });
    super.onWindowUnmaximize();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 144,
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 28,
            child: IconButton(
              iconButtonMode: IconButtonMode.large,
              onPressed: () {
                windowManager.minimize();
              },
              icon: Icon(FluentIcons.subtract_48_regular),
            ),
          ),
          SizedBox(
            width: 48,
            height: 28,
            child: IconButton(
              iconButtonMode: IconButtonMode.large,
              onPressed: () {
                toggleToolbarMaximizedState();
              },
              icon: Icon(
                _isMaximized
                    ? FluentIcons.square_multiple_48_regular
                    : FluentIcons.square_48_regular,
              ),
            ),
          ),
          SizedBox(
            width: 48,
            height: 28,
            child: IconButton(
              style: ButtonStyle(
                shape: const WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(0)),
                  ),
                ),
                foregroundColor: WidgetStateColor.resolveWith(
                  (states) =>
                      states.isHovered || states.isPressed || states.isFocused
                          ? FluentTheme.of(
                            context,
                          ).resources.textOnAccentFillColorPrimary
                          : FluentTheme.of(
                            context,
                          ).resources.textFillColorPrimary,
                ),
                backgroundColor: WidgetStateColor.resolveWith(
                  (states) =>
                      states.isHovered || states.isPressed || states.isFocused
                          ? FluentTheme.of(
                            context,
                          ).resources.systemFillColorCritical
                          : Colors.transparent,
                ),
              ),
              iconButtonMode: IconButtonMode.large,
              onPressed: () {
                windowManager.close();
              },
              icon: const Icon(FluentIcons.dismiss_48_regular),
            ),
          ),
        ],
      ),
    );
  }
}
