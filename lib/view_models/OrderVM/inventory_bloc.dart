import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/order_service/get_user_inventory_service.dart';
import '../../models/OrderM/get_user_inventory_model.dart';

// Events
abstract class InventoryEvent {}
class FetchInventory extends InventoryEvent {
  final int userId;
  FetchInventory(this.userId);
}

// States
abstract class InventoryState {}
class InventoryInitial extends InventoryState {}
class InventoryLoading extends InventoryState {}
class InventoryLoaded extends InventoryState {
  final List<InventoryData> items;
  InventoryLoaded(this.items);
}
class InventoryError extends InventoryState {
  final String message;
  InventoryError(this.message);
}

// Bloc
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryService service;

  InventoryBloc(this.service) : super(InventoryInitial()) {
    on<FetchInventory>((event, emit) async {
      emit(InventoryLoading());
      try {
        final result = await service.fetchInventory(event.userId);
        emit(InventoryLoaded(result.data ?? []));
      } catch (e) {
        emit(InventoryError(e.toString()));
      }
    });
  }
}