import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'wrapper_state.dart';

late final WrapperCubit wrapperCubit;

class WrapperCubit extends Cubit<WrapperState> {
  WrapperCubit() : super(WrapperState.initial()) {
    wrapperCubit = this;
  }

  void toggleIsLocked() => emit(state.copyWith(isLocked: !state.isLocked));

  void updateIsHovered(bool value) => emit(state.copyWith(isHovered: value));
}
