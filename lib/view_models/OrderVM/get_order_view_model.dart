// get_order_view_model.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/order_service/get_order_service.dart';
import '../../models/OrderM/get_order_model.dart';

// --- State ---
abstract class GetOrderState extends Equatable {
  const GetOrderState();
  @override
  List<Object?> get props => [];
}

class GetOrderInitial extends GetOrderState {}

class GetOrderLoading extends GetOrderState {}

class GetOrderSuccess extends GetOrderState {
  final List<AssignedOrder> orders;
  const GetOrderSuccess(this.orders);

  @override
  List<Object?> get props => [orders];
}

class GetOrderFailure extends GetOrderState {
  final String error;
  const GetOrderFailure(this.error);

  @override
  List<Object?> get props => [error];
}

// --- Event ---
abstract class GetOrderEvent extends Equatable {
  const GetOrderEvent();
  @override
  List<Object> get props => [];
}

class FetchAssignedOrders extends GetOrderEvent {}

// --- BLoC ---
class GetOrderBloc extends Bloc<GetOrderEvent, GetOrderState> {
  final GetOrderService _orderService = GetOrderService();

  GetOrderBloc() : super(GetOrderInitial()) {
    on<FetchAssignedOrders>(_onFetchAssignedOrders);
  }

  void _onFetchAssignedOrders(
      FetchAssignedOrders event,
      Emitter<GetOrderState> emit,
      ) async {
    emit(GetOrderLoading());
    try {
      final List<AssignedOrder> orders = await _orderService.getAssignedOrders();
      emit(GetOrderSuccess(orders));
    } catch (e) {
      // Use the error message from the service
      emit(GetOrderFailure(e.toString().replaceAll("Exception: ", "")));
    }
  }
}