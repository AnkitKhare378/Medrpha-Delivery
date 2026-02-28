import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/lab_service/get_package_by_lab_service.dart';
import '../../models/LabM/lab_package_model.dart';

// Events
abstract class LabPackageEvent {}
class LoadLabPackages extends LabPackageEvent {}

// States
abstract class LabPackageState {}
class LabPackageLoading extends LabPackageState {}
class LabPackageLoaded extends LabPackageState {
  final List<LabPackageModel> packages;
  LabPackageLoaded(this.packages);
}
class LabPackageError extends LabPackageState {
  final String message;
  LabPackageError(this.message);
}

// Bloc
class LabPackageBloc extends Bloc<LabPackageEvent, LabPackageState> {
  final LabPackageService service;
  LabPackageBloc(this.service) : super(LabPackageLoading()) {
    on<LoadLabPackages>((event, emit) async {
      emit(LabPackageLoading());
      try {
        final packages = await service.fetchPackagesByLab();
        emit(LabPackageLoaded(packages));
      } catch (e) {
        emit(LabPackageError(e.toString()));
      }
    });
  }
}