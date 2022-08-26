part of 'wrapper_cubit.dart';

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
