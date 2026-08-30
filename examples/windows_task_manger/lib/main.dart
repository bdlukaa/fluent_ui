import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:window_manager/window_manager.dart';

import 'task_manger_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeWindowSettings();
  runApp(const TaskMangerApp());
}

Future<void> initializeWindowSettings() async {
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = WindowOptions(
    size: Size(800, 600),
    center: true,

    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  await Window.initialize();
  await Window.hideWindowControls();
  await Window.setEffect(
    effect: WindowEffect.acrylic,
    color: Colors.transparent,
  );
}
