import 'dart:async';

import 'package:desktop_clock/src/storage/storage_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'package:desktop_clock/src/clock/clock_widget.dart';
import 'package:desktop_clock/src/window/app_window.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'app',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
      ],
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)!.appTitle,
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      onGenerateRoute: (RouteSettings routeSettings) {
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (BuildContext context) {
            switch (routeSettings.name) {
              default:
                return const HomeWidget();
            }
          },
        );
      },
    );
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

Timer? timer;

class _HomeWidgetState extends State<HomeWidget>
    with TrayListener, WindowListener {
  @override
  void initState() {
    trayManager.addListener(this);
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowEvent(String eventName) {
    if (eventName == 'move' || eventName == 'resize') {
      if (timer?.isActive == false) {
        appWindow.setWindowSizeAndPosition();
      }

      timer?.cancel();
      timer = Timer(
        const Duration(seconds: 30),
        () {
          print('Timer triggered!');
          appWindow.setWindowSizeAndPosition();
        },
      );
    }
    super.onWindowEvent(eventName);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: WrapperWidget(),
    );
  }
}

late final WrapperCubit desktopWidgetCubit;

class WrapperCubit extends Cubit<WrapperState> {
  WrapperCubit() : super(WrapperState.initial()) {
    desktopWidgetCubit = this;
    _initialize();
  }

  Future<void> _initialize() async {
    final bool? isLocked = await StorageService //
        .instance
        ?.getValue('isLocked') as bool?;
    emit(state.copyWith(isLocked: isLocked));
  }

  void toggleIsLocked() {
    emit(state.copyWith(isLocked: !state.isLocked));
    StorageService.instance?.saveValue(key: 'isLocked', value: state.isLocked);
  }

  void updateIsHovered(bool value) {
    emit(state.copyWith(isHovered: value));
  }
}

class WrapperState extends Equatable {
  final bool isHovered;
  final bool isLocked;

  const WrapperState({
    required this.isHovered,
    required this.isLocked,
  });

  factory WrapperState.initial() {
    return const WrapperState(
      isHovered: false,
      isLocked: false,
    );
  }

  @override
  List<Object> get props => [isHovered, isLocked];

  WrapperState copyWith({
    bool? isHovered,
    bool? isLocked,
  }) {
    return WrapperState(
      isHovered: isHovered ?? this.isHovered,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

class WrapperWidget extends StatelessWidget {
  const WrapperWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WrapperCubit(),
      child: MouseRegion(
        onEnter: (_) => desktopWidgetCubit.updateIsHovered(true),
        onExit: (_) => desktopWidgetCubit.updateIsHovered(false),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                ClockWidget(),
                _WrapperControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WrapperControls extends StatefulWidget {
  const _WrapperControls({
    Key? key,
  }) : super(key: key);

  @override
  State<_WrapperControls> createState() => _WrapperControlsState();
}

class _WrapperControlsState extends State<_WrapperControls> {
  // bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WrapperCubit, WrapperState>(
      builder: (context, state) {
        return Opacity(
          opacity: state.isHovered ? 1 : 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => desktopWidgetCubit.toggleIsLocked(),
                child: Icon(
                  state.isLocked ? Icons.lock : Icons.lock_open,
                ),
              ),
              GestureDetector(
                onTapDown: (details) {
                  if (state.isLocked) return;

                  windowManager.startDragging();
                  appWindow.saveWindowSizeAndPosition();
                },
                child: const Icon(Icons.drag_indicator),
              ),
              GestureDetector(
                onTapDown: (details) {
                  if (state.isLocked) return;

                  windowManager.startResizing(ResizeEdge.bottomRight);
                  appWindow.saveWindowSizeAndPosition();
                },
                child: const Icon(Icons.aspect_ratio),
              ),
            ],
          ),
        );
      },
    );
  }
}
