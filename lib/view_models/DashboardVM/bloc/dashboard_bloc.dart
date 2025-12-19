import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(const DashboardState(currentIndex: 0, showLabsDialog: false)) {
    on<DashboardTabChanged>((event, emit) {
      emit(state.copyWith(currentIndex: event.index));
    });

    on<DashboardShowLabsDialog>((event, emit) {
      emit(state.copyWith(showLabsDialog: true));
      emit(state.copyWith(showLabsDialog: false)); // reset after showing
    });
  }
}
