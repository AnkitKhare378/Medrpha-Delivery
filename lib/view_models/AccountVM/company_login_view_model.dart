// company_login_view_model.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ NEW IMPORT

import '../../data/repositories/account_service/company_login_service.dart';
import '../../models/AccountM/company_login_model.dart';

// --- State ---
abstract class CompanyLoginState extends Equatable {
  const CompanyLoginState();

  @override
  List<Object?> get props => [];
}

class CompanyLoginInitial extends CompanyLoginState {}

class CompanyLoginLoading extends CompanyLoginState {}

class CompanyLoginSuccess extends CompanyLoginState {
  final CompanyLoginModel user;
  const CompanyLoginSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class CompanyLoginFailure extends CompanyLoginState {
  final String error;
  const CompanyLoginFailure(this.error);

  @override
  List<Object?> get props => [error];
}

// --- Event ---
abstract class CompanyLoginEvent extends Equatable {
  const CompanyLoginEvent();

  @override
  List<Object> get props => [];
}

class CompanyLoginSubmitted extends CompanyLoginEvent {
  final String email;
  final String password;
  final String deviceToken;
  final String deviceType;

  const CompanyLoginSubmitted({required this.email, required this.password, required this.deviceType, required this.deviceToken});

  @override
  List<Object> get props => [email, password];
}

// --- BLoC ---
class CompanyLoginBloc extends Bloc<CompanyLoginEvent, CompanyLoginState> {
  final CompanyLoginService _loginService = CompanyLoginService();

  CompanyLoginBloc() : super(CompanyLoginInitial()) {
    on<CompanyLoginSubmitted>(_onLoginSubmitted);
  }

  void _onLoginSubmitted(
      CompanyLoginSubmitted event,
      Emitter<CompanyLoginState> emit,
      ) async {
    emit(CompanyLoginLoading());
    try {
      final CompanyLoginModel user = await _loginService.companyUserLogin(
        email: event.email,
        password: event.password,
        deviceToken: event.deviceToken, // Pass from event
        deviceType: event.deviceType,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', user.id);
      await prefs.setInt('lab_id', user.labId);
      await prefs.setString('user_image', user.image);
      await prefs.setString('user_phone', user.phone);
      await prefs.setString('user_email', user.email);
      await prefs.setString('user_address', user.address);
      await prefs.setString('user_company_name', user.companyName);
      await prefs.setString('user_name', user.userName);
      print("🔑 Saved user_id: ${user.id}");

      emit(CompanyLoginSuccess(user));
    } catch (e) {
      // Use the error message from the service, or a default one
      emit(CompanyLoginFailure(e.toString().replaceAll("Exception: ", "")));
    }
  }
}
