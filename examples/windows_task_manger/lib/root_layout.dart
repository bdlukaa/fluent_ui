import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as system;
import 'package:windows_task_manger/app_history/app_history_view.dart';
import 'package:windows_task_manger/details/details_view.dart';
import 'package:windows_task_manger/performance/performance_view.dart';
import 'package:windows_task_manger/processes/processes_view.dart';
import 'package:windows_task_manger/services/services_view.dart';
import 'package:windows_task_manger/settings/settings_view.dart';
import 'package:windows_task_manger/startup_apps/startup_apps_view.dart';
import 'package:windows_task_manger/users/users_view.dart';
import 'package:windows_task_manger/windows_buttons.dart';

class RootLayout extends StatefulWidget {
  const RootLayout({super.key});

  @override
  State<RootLayout> createState() => _RootLayoutState();
}

class _RootLayoutState extends State<RootLayout> with WindowListener {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: NavigationView(
        appBar: NavigationAppBar(
          backgroundColor: Colors.transparent,
          height: 52,

          automaticallyImplyLeading: false,
          actions: WindowsButtons(),

          title: DragToMoveArea(
            child: Container(
              color: Colors.transparent,
              height: 32,
              child: Row(
                children: [
                  Image.asset('assets/logo.png', width: 16, height: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Task Manager',
                    style: FluentTheme.of(context).typography.caption,
                  ),

                  const SizedBox(width: 8),
                  const Spacer(),
                  Expanded(
                    flex: 2,
                    child: TextBox(
                      placeholder: 'Type a a name,publisher, or PID to search',
                      prefix: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 8.0),
                        child: IconButton(
                          iconButtonMode: IconButtonMode.large,
                          icon: Icon(
                            system.FluentIcons.search_48_regular,
                            size: 14,
                          ),

                          onPressed: () {},
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
        pane: NavigationPane(
          size: const NavigationPaneSize(compactWidth: 48),
          selected: _selectedIndex,
          displayMode: PaneDisplayMode.auto,
          onChanged: (int index) {
            setState(() {
              // Update the selected index when a pane item is clicked
              _selectedIndex = index;
            });
          },

          items: [
            PaneItem(
              icon: const Icon(FluentIcons.app_icon_default),
              title: const Text('Processes'),
              body: ProcessesView(),
            ),
            PaneItem(
              icon: SizedBox(
                child: const Icon(
                  system.FluentIcons.pulse_square_24_regular,
                  size: 18,
                ),
              ),
              title: const Text('Performance'),
              body: PerformanceView(),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.history),
              title: const Text('App History'),
              body: AppHistoryView(),
            ),
            PaneItem(
              icon: const Icon(
                system.FluentIcons.top_speed_24_regular,
                size: 18,
              ),
              title: const Text('Startup Apps'),
              body: StartupAppsView(),
            ),
            PaneItem(
              icon: const Icon(system.FluentIcons.people_24_regular, size: 18),
              title: Text('Users'),
              body: UsersView(),
            ),
            PaneItem(
              icon: const Icon(
                system.FluentIcons.text_bullet_list_24_regular,
                size: 18,
              ),
              title: const Text('Details'),
              body: DetailsView(),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.puzzle, size: 18),
              title: const Text('Services'),
              body: ServicesView(),
            ),
          ],
          footerItems: [
            PaneItem(
              icon: const Icon(
                system.FluentIcons.settings_24_regular,
                size: 18,
              ),
              title: const Text('Settings'),
              body: SettingsView(),
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
