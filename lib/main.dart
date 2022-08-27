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

  final appWindow = AppWindow();
  final systemTray = SystemTrayManager(appWindow);
  await systemTray.initialize();

  runApp(const MyApp());
}
