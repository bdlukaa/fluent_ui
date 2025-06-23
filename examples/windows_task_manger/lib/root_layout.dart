import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as system;
import 'package:windows_task_manger/windows_buttons.dart';

class RootLayout extends StatefulWidget {
  const RootLayout({super.key});

  @override
  State<RootLayout> createState() => _RootLayoutState();
}

class _RootLayoutState extends State<RootLayout> with WindowListener {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: NavigationView(
        appBar: NavigationAppBar(
          backgroundColor: Colors.transparent,
          height: 48,

          automaticallyImplyLeading: false,
          actions: WindowsButtons(),

          title: DragToMoveArea(
            child: Container(
              color: Colors.transparent,
              height: 40,
              child: Row(
                children: [
                  Image.asset('assets/logo.png', width: 16, height: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Task Manager',
                    style: FluentTheme.of(context).typography.caption,
                  ),

                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
        pane: NavigationPane(
          selected: 2,
          displayMode: PaneDisplayMode.auto,

          items: [
            PaneItem(
              icon: const Icon(FluentIcons.app_icon_default),
              title: const Text('Processes'),
              body: Card(
                child: const Center(
                  child: Text('Task Manager Content Goes Here'),
                ),
              ),
            ),
            PaneItem(
              icon: const Icon(system.FluentIcons.pulse_square_20_regular),
              title: const Text('Performance'),
              body: Card(
                child: const Center(
                  child: Text('Task Manager Content Goes Here'),
                ),
              ),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.history),
              title: const Text('App History'),
              body: Card(
                child: const Center(
                  child: Text('Task Manager Content Goes Here'),
                ),
              ),
            ),
            PaneItem(
              icon: const Icon(system.FluentIcons.fast_acceleration_24_filled),
              title: const Text('Startup Apps'),
              body: Card(
                child: const Center(
                  child: Text('Task Manager Content Goes Here'),
                ),
              ),
            ),
            PaneItem(
              icon: const Icon(system.FluentIcons.people_48_regular, size: 24),
              title: Text('Users'),
              body: Card(
                child: Center(child: Text('Task Manager Content Goes Here')),
              ),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.a_t_p_logo),
              title: const Text('Details'),
              body: Card(
                child: const Center(child: Text('Settings Content Goes Here')),
              ),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.a_a_d_logo),
              title: const Text('Services'),
              body: Card(
                child: const Center(child: Text('About Content Goes Here')),
              ),
            ),
          ],
          footerItems: [
            PaneItem(
              icon: const Icon(FluentIcons.a_a_d_logo),
              title: const Text('Settings'),
              body: Card(
                child: const Center(child: Text('Help Content Goes Here')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
