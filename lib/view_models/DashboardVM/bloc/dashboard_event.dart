import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardTabChanged extends DashboardEvent {
  final int index;
  DashboardTabChanged(this.index);

  @override
  List<Object?> get props => [index];
}

class DashboardShowLabsDialog extends DashboardEvent {}
