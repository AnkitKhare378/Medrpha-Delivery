import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/order_service/store_shift_service.dart';
import '../../models/OrderM/store_holiday_model.dart';
import '../../models/OrderM/store_shift_model.dart';

// Events
abstract class StoreShiftEvent {}
class FetchStoreShifts extends StoreShiftEvent {
  final int storeId;
  FetchStoreShifts(this.storeId);
}

// States
abstract class StoreShiftState {}
class StoreShiftInitial extends StoreShiftState {}
class StoreShiftLoading extends StoreShiftState {}
class StoreShiftLoaded extends StoreShiftState {
  final List<StoreShiftModel> shifts;
  final List<StoreHolidayModel> holidays;
  StoreShiftLoaded(this.shifts, this.holidays);
}
class StoreShiftError extends StoreShiftState {
  final String message;
  StoreShiftError(this.message);
}

// Bloc
class StoreShiftBloc extends Bloc<StoreShiftEvent, StoreShiftState> {
  final StoreShiftService service;

  StoreShiftBloc(this.service) : super(StoreShiftInitial()) {
    on<FetchStoreShifts>((event, emit) async {
      emit(StoreShiftLoading());
      try {
        final shifts = await service.fetchStoreShifts(event.storeId);
        final holidays = await service.fetchStoreHolidays(event.storeId);
        emit(StoreShiftLoaded(shifts, holidays));
      } catch (e) {
        emit(StoreShiftError(e.toString()));
      }
    });
  }
}