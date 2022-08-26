import 'package:desktop_clock/src/storage/storage_service.dart';
import 'package:desktop_clock/src/window/app_window.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'src/app.dart';
import 'src/system_tray/system_tray_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  await StorageService.initialize();
  await AppWindow().setWindowSizeAndPosition();

  WindowOptions windowOptions = const WindowOptions(
    backgroundColor: Colors.transparent,
    skipTaskbar: true,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    // await windowManager.setMaximizable(false); // Not implemented.
    await windowManager.setAlwaysOnBottom(true);
    await windowManager.setMaximumSize(const Size(800, 800));
    await windowManager.setMinimumSize(const Size(260, 168));
    await windowManager.show();
  });

  windowManager.setBackgroundColor(Colors.transparent);

  runApp(const MyApp());

  final systemTray = SystemTrayManager(AppWindow());
  await systemTray.initialize();
}
