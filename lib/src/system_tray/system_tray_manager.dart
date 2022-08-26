import 'dart:io';

import 'package:tray_manager/tray_manager.dart';

import '../window/app_window.dart';

class SystemTrayManager {
  final AppWindow _window;

  SystemTrayManager(this._window);

  Future<void> initialize() async {
    String iconPath = Platform.isWindows
        ? 'assets/icons/desktop_clock.ico'
        : 'assets/icons/desktop_clock.png';

    await trayManager.setIcon(iconPath);

    final Menu menu = Menu(
      items: [
        MenuItem(
          label: 'Reset position',
          onClick: (menuItem) => _window.resetPosition(),
        ),
        MenuItem(label: 'Exit', onClick: (menuItem) => _window.close()),
      ],
    );

    await trayManager.setContextMenu(menu);
  }
}
