// File: lib/view_models/OrderVM/insert_order_view_model.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/order_service/insert_order_service.dart';
import '../../models/OrderM/insert_order_model.dart';

// --- Events ---
abstract class InsertOrderEvent {}

class PerformInsertOrderItem extends InsertOrderEvent {
  final InsertOrderItemRequest request;
  PerformInsertOrderItem(this.request);
}

// --- States ---
abstract class InsertOrderState {}

class InsertOrderInitial extends InsertOrderState {}

class InsertOrderLoading extends InsertOrderState {}

class InsertOrderSuccess extends InsertOrderState {
  final String message;
  InsertOrderSuccess(this.message);
}

class InsertOrderFailure extends InsertOrderState {
  final String error;
  InsertOrderFailure(this.error);
}

// --- BLoC ---
class InsertOrderBloc extends Bloc<InsertOrderEvent, InsertOrderState> {
  final InsertOrderService service;

  InsertOrderBloc(this.service) : super(InsertOrderInitial()) {
    on<PerformInsertOrderItem>(_onPerformInsertOrderItem);
  }

  void _onPerformInsertOrderItem(
      PerformInsertOrderItem event,
      Emitter<InsertOrderState> emit,
      ) async {
    emit(InsertOrderLoading());
    try {
      final response = await service.insertOrderItem(event.request);

      if (response.status) {
        emit(InsertOrderSuccess(response.message));
      } else {
        emit(InsertOrderFailure(response.message));
      }
    } catch (e) {
      emit(InsertOrderFailure(e.toString()));
    }
  }
}