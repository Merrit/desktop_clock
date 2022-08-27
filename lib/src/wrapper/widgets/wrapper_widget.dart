import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        child: Builder(builder: (context) {
          return BlocBuilder<WrapperCubit, WrapperState>(
            builder: (context, state) {
              return Container(
                color: state.isLocked
                    ? Colors.transparent
                    : Colors.grey.withOpacity(0.2),
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  children: const [
                    FittedBox(
                      child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: ClockWidget(),
                      ),
                    ),
                    _LockMoveControls(),
                    _ResizeControl(Alignment.topLeft),
                    _ResizeControl(Alignment.topRight),
                    _ResizeControl(Alignment.bottomRight),
                    _ResizeControl(Alignment.bottomLeft),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class _LockMoveControls extends StatelessWidget {
  const _LockMoveControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.centerRight,
        child: BlocBuilder<WrapperCubit, WrapperState>(
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: (state.isHovered || !state.isLocked) ? 0.8 : 0,
                  child: GestureDetector(
                    onTap: () => wrapperCubit.toggleIsLocked(),
                    child: Icon(
                      state.isLocked ? Icons.lock : Icons.lock_open,
                    ),
                  ),
                ),
                Visibility(
                  visible: !state.isLocked,
                  maintainAnimation: true,
                  maintainSize: true,
                  maintainState: true,
                  child: Opacity(
                    opacity: 0.8,
                    child: GestureDetector(
                      onTapDown: (details) {
                        if (state.isLocked) return;

                        windowManager.startDragging();
                      },
                      onTapUp: (_) => appWindow.saveWindowSizeAndPosition(),
                      child: const Icon(Icons.drag_indicator),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ResizeControl extends StatefulWidget {
  final Alignment alignment;

  const _ResizeControl(
    this.alignment, {
    Key? key,
  }) : super(key: key);

  @override
  State<_ResizeControl> createState() => _ResizeControlState();
}

class _ResizeControlState extends State<_ResizeControl> {
  late final SystemMouseCursor cursor;
  late final ResizeEdge resizeEdge;

  @override
  void initState() {
    if (widget.alignment == Alignment.topLeft) {
      cursor = SystemMouseCursors.resizeUpLeftDownRight;
      resizeEdge = ResizeEdge.topLeft;
    } else if (widget.alignment == Alignment.topRight) {
      cursor = SystemMouseCursors.resizeUpRightDownLeft;
      resizeEdge = ResizeEdge.topRight;
    } else if (widget.alignment == Alignment.bottomRight) {
      cursor = SystemMouseCursors.resizeUpLeftDownRight;
      resizeEdge = ResizeEdge.bottomRight;
    } else if (widget.alignment == Alignment.bottomLeft) {
      cursor = SystemMouseCursors.resizeUpRightDownLeft;
      resizeEdge = ResizeEdge.bottomLeft;
    } else {
      throw Exception('Only corner alignments are supported.');
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: widget.alignment,
        child: MouseRegion(
          cursor: cursor,
          child: BlocBuilder<WrapperCubit, WrapperState>(
            builder: (context, state) {
              return Opacity(
                opacity: state.isLocked ? 0 : 0.8,
                child: GestureDetector(
                  onTapDown: (details) async {
                    if (state.isLocked) return;

                    await windowManager.startResizing(resizeEdge);
                    await appWindow.saveWindowSizeAndPosition();
                  },
                  onTapUp: (_) => appWindow.saveWindowSizeAndPosition(),
                  child: Transform.scale(
                    scale: 0.8,
                    child: const Icon(Icons.circle),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
