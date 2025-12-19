import 'package:equatable/equatable.dart';

class DashboardState extends Equatable {
  final int currentIndex;
  final bool showLabsDialog;

  const DashboardState({
    required this.currentIndex,
    required this.showLabsDialog,
  });

  DashboardState copyWith({
    int? currentIndex,
    bool? showLabsDialog,
  }) {
    return DashboardState(
      currentIndex: currentIndex ?? this.currentIndex,
      showLabsDialog: showLabsDialog ?? this.showLabsDialog,
    );
  }

  @override
  List<Object?> get props => [currentIndex, showLabsDialog];
}
