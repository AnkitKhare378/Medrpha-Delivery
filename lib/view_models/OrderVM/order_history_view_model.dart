// file: lib/blocs/order_history_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/order_service/order_history_service.dart';
import '../../models/OrderM/order_history_model.dart';

// --- Events ---
abstract class OrderHistoryEvent {}

class FetchOrderHistoryEvent extends OrderHistoryEvent {
  final int userId;
  final int? orderId;
  FetchOrderHistoryEvent({required this.userId, this.orderId});
}

// --- States ---
abstract class OrderHistoryState {}

class OrderHistoryInitial extends OrderHistoryState {}

class OrderHistoryLoading extends OrderHistoryState {}

class OrderHistoryLoaded extends OrderHistoryState {
  final List<OrderHistoryModel> orders;
  OrderHistoryLoaded(this.orders);
}

class OrderHistoryError extends OrderHistoryState {
  final String message;
  OrderHistoryError(this.message);
}

// --- BLoC ---
class OrderHistoryBloc extends Bloc<OrderHistoryEvent, OrderHistoryState> {
  final OrderHistoryService _service;

  OrderHistoryBloc(this._service) : super(OrderHistoryInitial()) {
    on<FetchOrderHistoryEvent>(_onFetchOrderHistory);
  }

  void _onFetchOrderHistory(
      FetchOrderHistoryEvent event, Emitter<OrderHistoryState> emit) async {
    emit(OrderHistoryLoading());
    try {
      // Pass the orderId from the event to the service layer
      final orders = await _service.fetchOrderHistory(
        userId: event.userId,
        orderId: event.orderId,
      );
      emit(OrderHistoryLoaded(orders));
    } catch (e) {
      emit(OrderHistoryError('Failed to load orders. Error: ${e.toString()}'));
    }
  }
}