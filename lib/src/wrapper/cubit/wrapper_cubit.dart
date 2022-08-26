import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../storage/storage_service.dart';

part 'wrapper_state.dart';

late final WrapperCubit wrapperCubit;

class WrapperCubit extends Cubit<WrapperState> {
  WrapperCubit() : super(WrapperState.initial()) {
    wrapperCubit = this;
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
