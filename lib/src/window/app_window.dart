// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart' as window;

import '../storage/storage_service.dart';

final appWindow = AppWindow();

class AppWindow {
  AppWindow._() {
    instance = this;
    initialize();
  }

  static late final AppWindow instance;
  static bool _initialized = false;

  factory AppWindow() {
    if (_initialized) return instance;

    _initialized = true;
    return AppWindow._();
  }

  void initialize() {
    WindowOptions windowOptions = const WindowOptions(
      backgroundColor: Colors.transparent,
      skipTaskbar: true,
      titleBarStyle: TitleBarStyle.hidden,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      // await windowManager.setMaximizable(false); // Not implemented.
      await windowManager.setAlwaysOnBottom(true);
      await windowManager.setBackgroundColor(Colors.transparent);
      await windowManager.setMaximumSize(const Size(800, 800));
      await windowManager.setMinimumSize(const Size(110, 110));
      await AppWindow().setWindowSizeAndPosition();
      await windowManager.show();
    });
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
    final savedPosition = await StorageService //
        .instance!
        .getValue(await _getScreenConfigId());
    if (savedPosition == null) return null;

    final windowRect = rectFromJson(savedPosition);
    return windowRect;
  }

  Future<void> saveWindowSizeAndPosition() async {
    print('Saving window size and position');
    final Rect bounds = await windowManager.getBounds();

    await StorageService.instance!.saveValue(
      key: await _getScreenConfigId(),
      value: bounds.toJson(),
    );
  }

  Future<void> setWindowSizeAndPosition() async {
    print('Setting window size and position.');
    Rect currentWindowFrame = await windowManager.getBounds();

    Rect? targetWindowFrame = await getSavedWindowSizeAndPosition();
    targetWindowFrame ??= const Rect.fromLTWH(0, 0, 300, 180);

    if (targetWindowFrame == currentWindowFrame) {
      print('Target matches current window frame, nothing to do.');
      return;
    }

    assert(targetWindowFrame.size >= const Size(110, 110));

    window.setWindowFrame(targetWindowFrame);
  }
}

extension on Rect {
  Map<String, dynamic> toMap() {
    return {
      'left': left,
      'top': top,
      'right': right,
      'bottom': bottom,
    };
  }

  String toJson() => json.encode(toMap());
}

Rect rectFromJson(String source) {
  final Map<String, dynamic> map = json.decode(source);
  return Rect.fromLTRB(
    map['left'],
    map['top'],
    map['right'],
    map['bottom'],
  );
}
