// lib/blocs/order_status_bloc/order_status_view_model.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/order_service/order_status_service.dart';
import '../../models/OrderM/order_status_model.dart';

// --- 1. Events ---
abstract class OrderStatusEvent {}

class UpdateOrderStatusRequested extends OrderStatusEvent {
  final int orderId;
  final int statusType;
  final String? orderDate; // Changed to nullable String?
  final String? orderTime; // Changed to nullable String?
  final int sumbitUserId;

  UpdateOrderStatusRequested({
    required this.orderId,
    required this.statusType,
    this.orderDate, // Removed 'required'
    this.orderTime, // Removed 'required'
    required this.sumbitUserId,
  });
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
      // The service will now receive null for date/time if not provided
      final response = await _service.updateOrderStatus(
        orderId: event.orderId,
        statusType: event.statusType,
        orderDate: event.orderDate,
        orderTime: event.orderTime,
        sumbitUserId: event.sumbitUserId,
      );
      emit(OrderStatusSuccess(response));
    } catch (e) {
      emit(OrderStatusFailure(e.toString()));
    }
  }
}