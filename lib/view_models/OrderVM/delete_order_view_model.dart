// lib/blocs/order/delete_order_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/repositories/order_service/delete_order_service.dart';
import '../../models/OrderM/delete_order_model.dart';

// --- BLoC Events ---
abstract class DeleteOrderEvent extends Equatable {
  const DeleteOrderEvent();

  @override
  List<Object> get props => [];
}

/// Event to trigger the deletion of an order item.
class DeleteOrderItemRequested extends DeleteOrderEvent {
  final int itemId;

  const DeleteOrderItemRequested({required this.itemId});

  @override
  List<Object> get props => [itemId];
}

// --- BLoC States ---
abstract class DeleteOrderState extends Equatable {
  const DeleteOrderState();

  @override
  List<Object> get props => [];
}

/// Initial state before any operation.
class DeleteOrderInitial extends DeleteOrderState {}

/// State when the deletion request is in progress.
class DeleteOrderLoading extends DeleteOrderState {}

/// State when the order item is successfully deleted.
class DeleteOrderSuccess extends DeleteOrderState {
  final DeleteOrderResponseModel response;

  const DeleteOrderSuccess({required this.response});

  @override
  List<Object> get props => [response];
}

/// State when an error occurs during deletion.
class DeleteOrderFailure extends DeleteOrderState {
  final String error;

  const DeleteOrderFailure({required this.error});

  @override
  List<Object> get props => [error];
}

// --- BLoC Class ---
class DeleteOrderBloc extends Bloc<DeleteOrderEvent, DeleteOrderState> {
  final DeleteOrderService _service;

  DeleteOrderBloc(this._service) : super(DeleteOrderInitial()) {
    on<DeleteOrderItemRequested>(_onDeleteOrderItemRequested);
  }

  void _onDeleteOrderItemRequested(
      DeleteOrderItemRequested event,
      Emitter<DeleteOrderState> emit,
      ) async {
    emit(DeleteOrderLoading());
    try {
      final response = await _service.deleteOrderItem(event.itemId);
      emit(DeleteOrderSuccess(response: response));
    } catch (e) {
      // The service throws an Exception with a message
      emit(DeleteOrderFailure(error: e.toString()));
    }
  }
}