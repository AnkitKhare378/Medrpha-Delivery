import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/order_service/order_start_service.dart';
import '../../models/OrderM/order_start_model.dart';

// --- Events ---
abstract class OrderStartEvent {}
class StartOrderRequested extends OrderStartEvent {
  final int orderId;
  final int statusType;
  final int paymentType;
  StartOrderRequested(this.orderId, this.statusType, this.paymentType);
}

// --- States ---
abstract class OrderStartState {}
class OrderStartInitial extends OrderStartState {}
class OrderStartLoading extends OrderStartState {}
class OrderStartSuccess extends OrderStartState {
  final OrderStartResponse response;
  OrderStartSuccess(this.response);
}
class OrderStartFailure extends OrderStartState {
  final String error;
  OrderStartFailure(this.error);
}

// --- BLoC ---
class OrderStartBloc extends Bloc<OrderStartEvent, OrderStartState> {
  final OrderStartService service;

  OrderStartBloc(this.service) : super(OrderStartInitial()) {
    on<StartOrderRequested>((event, emit) async {
      emit(OrderStartLoading());
      try {
        final result = await service.startOrder(event.orderId, event.statusType, event.paymentType );
        if (result.status) {
          emit(OrderStartSuccess(result));
        } else {
          emit(OrderStartFailure(result.message));
        }
      } catch (e) {
        emit(OrderStartFailure(e.toString()));
      }
    });
  }
}


// end


// --- Events ---
abstract class OrderEndEvent {}
class EndOrderRequested extends OrderEndEvent {
  final int orderId;
  final int statusType;
  final int paymentType;
  EndOrderRequested(this.orderId, this.statusType, this.paymentType);
}


// --- States ---
abstract class OrderEndState {}
class OrderEndInitial extends OrderEndState {}
class OrderEndLoading extends OrderEndState {}
class OrderEndSuccess extends OrderEndState {
  final OrderStartResponse response;
  OrderEndSuccess(this.response);
}
class OrderEndFailure extends OrderEndState {
  final String error;
  OrderEndFailure(this.error);
}

// --- BLoC ---
class OrderEndBloc extends Bloc<OrderEndEvent, OrderEndState> {
  final OrderStartService service;

  OrderEndBloc(this.service) : super(OrderEndInitial()) {
    on<EndOrderRequested>((event, emit) async {
      emit(OrderEndLoading());
      try {
        final result = await service.startOrder(event.orderId, event.statusType, event.paymentType);
        if (result.status) {
          emit(OrderEndSuccess(result));
        } else {
          emit(OrderEndFailure(result.message));
        }
      } catch (e) {
        emit(OrderEndFailure(e.toString()));
      }
    });
  }
}