import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

import '../../clock/clock_widget.dart';
import '../../window/app_window.dart';
import '../wrapper.dart';

class WrapperWidget extends StatelessWidget {
  const WrapperWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WrapperCubit(),
      child: MouseRegion(
        onEnter: (_) => wrapperCubit.updateIsHovered(true),
        onExit: (_) => wrapperCubit.updateIsHovered(false),
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
                onTap: () => wrapperCubit.toggleIsLocked(),
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
