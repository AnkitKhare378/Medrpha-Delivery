import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/order_service/get_user_by_lab_service.dart';
import '../../models/OrderM/user_by_lab_model.dart';

// Events
abstract class UserSelectionEvent {}
class FetchUsersEvent extends UserSelectionEvent {}

// States
abstract class UserSelectionState {}
class UserInitial extends UserSelectionState {}
class UserLoading extends UserSelectionState {}
class UserLoaded extends UserSelectionState {
  final List<UserByLabModel> users;
  UserLoaded(this.users);
}
class UserError extends UserSelectionState {
  final String message;
  UserError(this.message);
}

// Bloc
class UserSelectionBloc extends Bloc<UserSelectionEvent, UserSelectionState> {
  final GetUserByLabService service;

  UserSelectionBloc(this.service) : super(UserInitial()) {
    on<FetchUsersEvent>((event, emit) async {
      emit(UserLoading());
      try {
        final users = await service.fetchUsersByLab();
        emit(UserLoaded(users));
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });
  }
}