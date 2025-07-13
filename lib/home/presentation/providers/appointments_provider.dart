import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fundacion_paciente_app/auth/presentation/providers/auth_provider.dart';
import 'package:fundacion_paciente_app/home/domain/entities/cita.entity.dart';
import 'package:fundacion_paciente_app/home/domain/entities/registerCita.entity.dart';
import 'package:fundacion_paciente_app/home/infrastructure/repositories/appointment_repository_impl.dart';
import 'package:fundacion_paciente_app/config/routes/app_routes.dart';
import 'package:fundacion_paciente_app/home/domain/usecases/appointment_usecase.dart';
import 'package:flutter/material.dart';
import 'package:fundacion_paciente_app/shared/infrastructure/errors/custom_error.dart';
import 'package:fundacion_paciente_app/home/presentation/providers/appointment_notification_provider.dart';

// 🔹 Provider del estado de citas médicas
final appointmentProvider =
    StateNotifierProvider<AppointmentNotifier, AppointmentState>((ref) {
  final repository = AppointmentRepositoryImpl();
  final useCase = AppointmentUseCase(repository);
  final patientId = ref.watch(authProvider).user?.patientID ?? '';
  return AppointmentNotifier(useCase, ref, patientId);
});

// 🔹 Notifier que maneja el estado de citas médicas en tiempo real
class AppointmentNotifier extends StateNotifier<AppointmentState> {
  final AppointmentUseCase _useCase;
  final Ref ref;
  final String patientId;
  StreamSubscription<List<Appointments>>? _subscription;
  AppointmentNotificationService? _notificationService;

  AppointmentNotifier(this._useCase, this.ref, this.patientId)
      : super(AppointmentState()) {
    if (patientId.isNotEmpty) {
      _notificationService = ref.read(appointmentNotificationProvider);
      _listenToAppointments(); // Escuchar cambios en tiempo real
    }
  }

  /// 🔹 Escucha en tiempo real los cambios en Firestore
  void _listenToAppointments() {
    _subscription =
        _useCase.streamAppointments(patientId).listen((appointments) {
      // Detectar cambios para notificaciones
      _notificationService?.handleAppointmentChanges(appointments);
      
      state = state.copyWith(appointments: appointments);
    });
  }

  /// 🔹 Manejo de errores centralizado
  void _handleError(CustomError error) {
    state = state.copyWith(loading: false, errorMessage: error.message);
  }

  /// 🔹 Obtener citas por fecha
  Future<void> getAppointmentsByDate(DateTime date) async {
    try {
      state = state.copyWith(loading: true);
      final appointments =
          await _useCase.fetchAppointmentsByDate(date, patientId);
      state = state.copyWith(
        loading: false,
        appointmentsByDate: appointments,
        calendarioCitaSeleccionada: date,
      );
    } on CustomError catch (e) {
      _handleError(e);
    }
  }

  /// 🔹 Crear nueva cita con notificación UI
  Future<void> createAppointment(CreateAppointments newAppointment,
      String patientName, BuildContext context) async {
    try {
      state = state.copyWith(loading: true, errorMessage: '');
      await _useCase.createAppointment(newAppointment, patientName);
      state = state.copyWith(
          loading: false, successMessage: '✅ Cita creada exitosamente');
      ref.read(goRouterProvider).pop();
    } on CustomError catch (e) {
      state = state.copyWith(
          loading: false, errorMessage: e.message); // ✅ SOLO actualizar estado
    }
  }

  /// 🔹 Cambiar fecha seleccionada y cargar citas por fecha
  void onDateSelected(DateTime date) async {
    state = state.copyWith(calendarioCitaSeleccionada: date);
    await getAppointmentsByDate(date);
  }

  /// 🔹 Seleccionar una cita específica
  void selectAppointment(Appointments appointment) {
    state = state.copyWith(selectedAppointment: appointment);
  }

  @override
  void dispose() {
    _subscription
        ?.cancel(); // 🛑 Cancelar la suscripción cuando se elimine el Provider
    super.dispose();
  }
}

// 📌 Estado del provider de citas médicas con Equatable
class AppointmentState extends Equatable {
  final List<Appointments> appointments;
  final List<Appointments> appointmentsByDate;
  final Appointments? selectedAppointment;
  final DateTime calendarioCitaSeleccionada;
  final bool loading;
  final String errorMessage;
  final String successMessage;

  AppointmentState({
    this.appointments = const [],
    this.appointmentsByDate = const [],
    this.selectedAppointment,
    DateTime? calendarioCitaSeleccionada,
    this.loading = false,
    this.errorMessage = '',
    this.successMessage = '',
  }) : calendarioCitaSeleccionada =
            calendarioCitaSeleccionada ?? DateTime.now();

  AppointmentState copyWith({
    List<Appointments>? appointments,
    List<Appointments>? appointmentsByDate,
    Appointments? selectedAppointment,
    DateTime? calendarioCitaSeleccionada,
    bool? loading,
    String? errorMessage,
    String? successMessage,
  }) {
    return AppointmentState(
      appointments: appointments ?? this.appointments,
      appointmentsByDate: appointmentsByDate ?? this.appointmentsByDate,
      selectedAppointment: selectedAppointment ?? this.selectedAppointment,
      calendarioCitaSeleccionada:
          calendarioCitaSeleccionada ?? this.calendarioCitaSeleccionada,
      successMessage: successMessage ?? this.successMessage,
      loading: loading ?? this.loading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        appointments,
        appointmentsByDate,
        selectedAppointment,
        calendarioCitaSeleccionada,
        loading,
        errorMessage,
        successMessage,
      ];
}
