import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:paciente_citas_1/home/domain/entities/patient_entities.dart';
import 'package:paciente_citas_1/type_therapy/domain/entities/type_therapy_entity.dart';
import 'package:paciente_citas_1/type_therapy/domain/repositories/type_therapy_repository.dart';
import 'package:paciente_citas_1/type_therapy/infrastructure/repositories/type_therapy_repository_impl.dart';
import 'package:paciente_citas_1/auth/presentation/providers/auth_provider.dart';
import 'package:paciente_citas_1/home/domain/entities/registerCita.entity.dart';
import 'package:paciente_citas_1/home/domain/repositories/appointment_repository.dart';
import 'package:paciente_citas_1/home/domain/repositories/patient_repository.dart';
import 'package:paciente_citas_1/home/infrastructure/repositories/appointment_repository_impl.dart';
import 'package:paciente_citas_1/home/infrastructure/repositories/patient_repository_impl.dart';
import 'package:paciente_citas_1/home/presentation/providers/appointments_provider.dart';
import 'package:paciente_citas_1/shared/infrastructure/errors/custom_error.dart';


// 🔹 Provider del formulario de citas
final appointmentFormProvider = StateNotifierProvider.autoDispose<
    AppointmentFormNotifier, AppointmentFormState>(
  (ref) {
    final appointmentRepo = AppointmentRepositoryImpl();
    final patientRepo = PatientRepositoryImpl();
    final registerAppointmentCallback =
        ref.watch(appointmentProvider.notifier).createAppointment;
    final typeTherapyRepo = TypeTherapyRepositoryImpl();
    final authState = ref.watch(authProvider);

    return AppointmentFormNotifier(
      appointmentRepository: appointmentRepo,
      patientRepository: patientRepo,
      registerAppointmentCallback: registerAppointmentCallback,
      typeTherapyRepository: typeTherapyRepo,
      patientId: authState.user?.patientID ?? '',
    );
  },
);

// 🔹 Notifier que maneja el estado del formulario de citas
class AppointmentFormNotifier extends StateNotifier<AppointmentFormState> {
  final Function(CreateAppointments, String, BuildContext)
      registerAppointmentCallback;
  final AppointmentRepository appointmentRepository;
  final PatientRepository patientRepository;
  final TypeTherapyRepository typeTherapyRepository;

  AppointmentFormNotifier({
    required this.appointmentRepository,
    required this.registerAppointmentCallback,
    required this.patientRepository,
    required String patientId,
    required this.typeTherapyRepository,
  }) : super(const AppointmentFormState()) {
    if (patientId.isNotEmpty) {
      state = state.copyWith(patientId: patientId);
      getPatient();
    }
    getTypeTherapics();
    initiaValues();
  }

  /// 🔹 Métodos `onChanged`
  void onDateChanged(DateTime date) {
    if (state.selectedDate != date) {
      state = state.copyWith(selectedDate: date);
    }
  }

  void onTimeChanged(String time) {
    if (state.selectedTime != time) {
      state = state.copyWith(selectedTime: time);
    }
  }

  void onAreaChanged(String area) {
    if (state.specialtyTherapyId != area) {
      state = state.copyWith(specialtyTherapyId: area);
    }
  }

  void onDiagnosisChanged(String diagnosis) {
    if (state.diagnosis != diagnosis) {
      state = state.copyWith(diagnosis: diagnosis);
    }
  }

  /// 🔹 Obtener lista de áreas terapéuticas
  Future<void> getTypeTherapics() async {
    try {
      final areas = await typeTherapyRepository.getTypeTherapies();
      state = state.copyWith(areas: areas);
    } on CustomError catch (e) {
      state = state.copyWith(errorMessage: e.message);
    }
  }

  /// 🔹 Obtener información del paciente
  Future<void> getPatient() async {
    try {
      state = state.copyWith(loading: true);
      final patient = await patientRepository.getPatient(state.patientId);
      state = state.copyWith(patientEntity: patient, loading: false);
    } on CustomError catch (e) {
      state = state.copyWith(errorMessage: e.message, loading: false);
    }
  }

  /// 🔹 Inicializar valores
  void initiaValues() {
    state = state.copyWith(selectedDate: DateTime.now());
  }

  /// 🔹 Guardar Cita con notificación UI
  Future<void> saveAppointment(BuildContext context) async {
    if (state.specialtyTherapyId == null ||
        state.selectedDate == null ||
        state.selectedTime == null ||
        state.patientId.isEmpty ||
        state.diagnosis.isEmpty) {
      state = state.copyWith(errorMessage: 'Todos los campos son obligatorios');

      return;
    }

    try {
      state = state.copyWith(
          loading: true, successMessage: ''); // ✅ Reiniciar mensaje de éxito

      final newAppointment = CreateAppointments(
        date: state.selectedDate!,
        appointmentTime: state.selectedTime!,
        medicalInsurance: state.patientEntity?.healthInsurance ?? 'No seguro',
        diagnosis: state.diagnosis,
        patientId: state.patientId,
        specialtyTherapyId: state.specialtyTherapyId!,
      );

      final nombreCompleto =
          '${state.patientEntity!.firstname} ${state.patientEntity!.lastname}';
      await registerAppointmentCallback(
          newAppointment, nombreCompleto, context);

      state = state.copyWith(
          loading: false,
          successMessage: '✅ Cita registrada correctamente'); // ✅ Marcar éxito
    } on CustomError catch (e) {
      state = state.copyWith(errorMessage: e.message, loading: false);
    }
  }

  void clearErrorMessage() {
    state = state.copyWith(errorMessage: '');
  }

  void clearSuccessMessage() {
    state = state.copyWith(successMessage: '');
  }
}

// 📌 Estado del formulario de citas con Equatable
class AppointmentFormState extends Equatable {
  final String cedula;
  final String patientId;
  final Patient? patientEntity;
  final String diagnosis;
  final List<TypeTherapyEntity> areas;
  final String? specialtyTherapyId;
  final DateTime? selectedDate;
  final String? selectedTime;
  final bool isFormPosted;
  final bool loading;
  final String errorMessage;
  final String successMessage; // ✅ Nueva bandera para éxito

  const AppointmentFormState({
    this.cedula = '',
    this.patientId = '',
    this.patientEntity,
    this.diagnosis = '',
    this.areas = const [],
    this.specialtyTherapyId,
    this.selectedDate,
    this.selectedTime,
    this.isFormPosted = false,
    this.loading = false,
    this.errorMessage = '',
    this.successMessage = '', // ✅ Inicializar en vacío
  });

  AppointmentFormState copyWith({
    String? cedula,
    String? patientId,
    Patient? patientEntity,
    String? diagnosis,
    List<TypeTherapyEntity>? areas,
    String? specialtyTherapyId,
    DateTime? selectedDate,
    String? selectedTime,
    bool? loading,
    bool? isFormPosted,
    String? errorMessage,
    String? successMessage, // ✅ Agregado en copyWith
  }) {
    return AppointmentFormState(
      cedula: cedula ?? this.cedula,
      patientId: patientId ?? this.patientId,
      patientEntity: patientEntity ?? this.patientEntity,
      diagnosis: diagnosis ?? this.diagnosis,
      areas: areas ?? this.areas,
      specialtyTherapyId: specialtyTherapyId ?? this.specialtyTherapyId,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      loading: loading ?? this.loading,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage:
          successMessage ?? this.successMessage, // ✅ Mantener el valor
    );
  }

  @override
  List<Object?> get props => [
        cedula,
        patientId,
        patientEntity,
        diagnosis,
        areas,
        specialtyTherapyId,
        selectedDate,
        selectedTime,
        loading,
        isFormPosted,
        errorMessage,
        successMessage, // ✅ Agregar a `props`
      ];
}
