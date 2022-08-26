import 'dart:io';
import 'dart:ui';

import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart' as window;

import '../storage/storage_service.dart';

final appWindow = AppWindow();

class AppWindow {
  AppWindow._() {
    instance = this;
  }

  static late final AppWindow instance;
  static bool _initialized = false;

  factory AppWindow() {
    if (_initialized) return instance;

    _initialized = true;
    return AppWindow._();
  }

  void close() => exit(0);

  Future<void> resetPosition() async {
    print('Centering widget.');
    Offset position = await windowManager.getPosition();
    print('x: ${position.dx}, y: ${position.dy}');
    await windowManager.center();
    position = await windowManager.getPosition();
    print('Widget has been centered. New position:');
    print('x: ${position.dx}, y: ${position.dy}');
  }

  Future<String> _getScreenConfigId() async {
    final screenList = await window.getScreenList();
    return screenList.map((e) => e.frame.toString()).toList().toString();
  }

  Future<Rect?> getSavedWindowSizeAndPosition() async {
    final savedPosition = await StorageService.instance! //
        .getValue(await _getScreenConfigId());
    if (savedPosition == null) return null;

    final positionMap = Map<String, double>.from(savedPosition);
    final windowRect = Rect.fromLTWH(
      positionMap['left']!,
      positionMap['top']!,
      positionMap['width']!,
      positionMap['height']!,
    );

    return windowRect;
  }

  Future<void> saveWindowSizeAndPosition() async {
    print('Saving window size and position');
    final Rect bounds = await windowManager.getBounds();

    await StorageService.instance!.saveValue(
      key: await _getScreenConfigId(),
      value: {
        'left': bounds.left,
        'top': bounds.top,
        'width': bounds.width,
        'height': bounds.height,
      },
    );
  }

  Future<void> setWindowSizeAndPosition() async {
    print('Setting window size and position.');
    Rect currentWindowFrame = await windowManager.getBounds();
    print(
      'Current: ${currentWindowFrame.left}, ${currentWindowFrame.top}, ${currentWindowFrame.width}, ${currentWindowFrame.height}',
    );

    Rect? targetWindowFrame = await getSavedWindowSizeAndPosition();
    targetWindowFrame ??= const Rect.fromLTWH(0, 0, 300, 180);

    if (targetWindowFrame == currentWindowFrame) {
      print('Target matches current window frame, nothing to do.');
      return;
    }

    window.setWindowFrame(targetWindowFrame);

    currentWindowFrame = await windowManager.getBounds();
    print(
      'New: ${currentWindowFrame.left}, ${currentWindowFrame.top}, ${currentWindowFrame.width}, ${currentWindowFrame.height}',
    );
  }
}
