// lab_test_view_model.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/lab_service/lab_test_service.dart';
import '../../models/LabM/lab_test_model.dart';

// --- 1. Events ---
abstract class LabTestEvent extends Equatable {
  const LabTestEvent();
  @override
  List<Object> get props => [];
}

class LoadLabTests extends LabTestEvent {
  final String name;
  final int labId;
  final int symptomId;

  const LoadLabTests({
    this.name = "",
    required this.labId,
    this.symptomId = 0,
  });

  @override
  List<Object> get props => [name, labId, symptomId];
}

// --- 2. States ---
abstract class LabTestState extends Equatable {
  const LabTestState();
  @override
  List<Object> get props => [];
}

class LabTestInitial extends LabTestState {}

class LabTestLoading extends LabTestState {}

class LabTestLoaded extends LabTestState {
  final List<LabTest> tests;
  const LabTestLoaded(this.tests);
  @override
  List<Object> get props => [tests];
}

class LabTestError extends LabTestState {
  final String message;
  const LabTestError(this.message);
  @override
  List<Object> get props => [message];
}

// --- 3. BLoC ---
class LabTestBloc extends Bloc<LabTestEvent, LabTestState> {
  final LabTestService _service;

  LabTestBloc({required LabTestService service})
      : _service = service,
        super(LabTestInitial()) {
    on<LoadLabTests>(_onLoadLabTests);
  }

  void _onLoadLabTests(
      LoadLabTests event,
      Emitter<LabTestState> emit,
      ) async {
    emit(LabTestLoading());
    try {
      final tests = await _service.searchTests(
        name: event.name,
        labId: event.labId,
        symptomId: event.symptomId,
      );
      emit(LabTestLoaded(tests));
    } catch (e) {
      emit(LabTestError(e.toString()));
    }
  }
}