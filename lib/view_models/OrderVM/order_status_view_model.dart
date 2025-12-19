// lib/blocs/order_status_bloc/order_status_view_model.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/order_service/order_status_service.dart';
import '../../models/OrderM/order_status_model.dart';

// --- 1. Events ---
abstract class OrderStatusEvent {}

class UpdateOrderStatusRequested extends OrderStatusEvent {
  final int orderId;
  final int statusType;

  UpdateOrderStatusRequested({required this.orderId, required this.statusType});
}

// --- 2. States ---
abstract class OrderStatusState {}

class OrderStatusInitial extends OrderStatusState {}

class OrderStatusLoading extends OrderStatusState {}

class OrderStatusSuccess extends OrderStatusState {
  final OrderStatusUpdateResponse response;
  OrderStatusSuccess(this.response);
}

class OrderStatusFailure extends OrderStatusState {
  final String error;
  OrderStatusFailure(this.error);
}

// --- 3. BLoC ---
class OrderStatusBloc extends Bloc<OrderStatusEvent, OrderStatusState> {
  final OrderStatusService _service;

  OrderStatusBloc(this._service) : super(OrderStatusInitial()) {
    on<UpdateOrderStatusRequested>(_onUpdateOrderStatusRequested);
  }

  Future<void> _onUpdateOrderStatusRequested(
      UpdateOrderStatusRequested event,
      Emitter<OrderStatusState> emit,
      ) async {
    emit(OrderStatusLoading());
    try {
      final response = await _service.updateOrderStatus(
        orderId: event.orderId,
        statusType: event.statusType,
      );
      emit(OrderStatusSuccess(response));
    } catch (e) {
      emit(OrderStatusFailure(e.toString()));
    }
  }
}