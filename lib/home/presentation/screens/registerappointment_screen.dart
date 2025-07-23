import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:paciente_citas_1/auth/presentation/providers/auth_provider.dart';
import 'package:paciente_citas_1/home/presentation/providers/appointments_form_provider.dart';
import 'package:paciente_citas_1/shared/presentation/widgets/custom_date_form_field.dart';
import 'package:paciente_citas_1/shared/presentation/widgets/custom_dropdown_form_field.dart';
import 'package:paciente_citas_1/shared/presentation/widgets/custom_filled_button.dart';
import 'package:paciente_citas_1/shared/presentation/widgets/custom_text_form_fiield.dart';
import 'package:paciente_citas_1/shared/presentation/widgets/header.dart';
import 'package:paciente_citas_1/shared/presentation/widgets/snackbar.dart';

class RegisterAppointment extends ConsumerWidget {
  const RegisterAppointment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    final authState = ref.watch(authProvider);
    if (authState.user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: colors.error,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Usuario no autenticado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go('/login'),
                icon: const Icon(Icons.login),
                label: const Text('Iniciar sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final appointmentFormState = ref.watch(appointmentFormProvider);
    final appointmentFormNotifier = ref.read(appointmentFormProvider.notifier);

    // Escuchar cambios de estado para mostrar el Snackbar
    ref.listen<AppointmentFormState>(appointmentFormProvider, (prev, next) {
      if (prev?.loading == true && next.loading == false) {
        if (next.errorMessage.isNotEmpty &&
            prev?.errorMessage != next.errorMessage) {
          showCustomSnackbar(context,
              message: next.errorMessage, isError: true);
          ref.read(appointmentFormProvider.notifier).clearErrorMessage();
        } else if (next.successMessage.isNotEmpty &&
            prev?.successMessage != next.successMessage) {
          showCustomSnackbar(context, message: next.successMessage);
          ref.read(appointmentFormProvider.notifier).clearSuccessMessage();
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors.primary.withOpacity(0.05),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        toolbarHeight: 100,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.primary.withOpacity(0.1),
                colors.primary.withOpacity(0.05),
              ],
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.only(top: 20, left: 40),
            child: Header(
              heightScale: 0.80,
              imagePath: 'assets/images/logo.png',
              title: 'Fundación de niños especiales',
              subtitle: '"SAN MIGUEL" FUNESAMI',
              item: 'Centro de Terapias',
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.primary.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Espacio adicional para bajar el contenido
                const SizedBox(height: 25),

                // Título con animación
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.calendar_month_rounded,
                          color: colors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Agendar Cita',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Complete el formulario para agendar su cita',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Formulario
                Card(
                  elevation: 4,
                  shadowColor: colors.primary.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: colors.primary, size: 18),
                            const SizedBox(width: 10),
                            Text(
                              'Información de la Cita',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Fecha de la cita
                        CustomDateFormField(
                          lastDate: false,
                          isDatePicker: true,
                          errorMessage: appointmentFormState.isFormPosted
                              ? (appointmentFormState.selectedDate == null
                                  ? 'Seleccione una fecha'
                                  : null)
                              : null,
                          prefixIcon:
                              Icon(Icons.calendar_today, color: colors.primary),
                          label: 'Fecha de la Cita',
                          hint: 'Seleccione la fecha',
                          initialValue: appointmentFormState.selectedDate !=
                                  null
                              ? DateFormat('dd/MM/yyyy')
                                  .format(appointmentFormState.selectedDate!)
                              : '',
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              try {
                                final date =
                                    DateFormat('dd/MM/yyyy').parse(value);
                                appointmentFormNotifier.onDateChanged(date);
                                // Limpiar la hora seleccionada cuando se cambia la fecha
                                appointmentFormNotifier.onTimeChanged('');
                              } catch (e) {
                                debugPrint('Error al convertir fecha: $e');
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 20),

                        // Hora de la cita
                        if (appointmentFormState.selectedDate !=
                            null) // Solo mostrar si hay fecha seleccionada
                          CustomDateFormField(
                            isDatePicker: false,
                            errorMessage: appointmentFormState.isFormPosted
                                ? (appointmentFormState.selectedTime == null
                                    ? 'Seleccione una hora'
                                    : null)
                                : null,
                            prefixIcon:
                                Icon(Icons.access_time, color: colors.primary),
                            label: 'Hora de la Cita',
                            hint: 'Seleccione la hora',
                            initialValue:
                                appointmentFormState.selectedTime ?? '',
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                appointmentFormNotifier.onTimeChanged(value);
                              }
                            },
                          ),
                        if (appointmentFormState.selectedDate != null)
                          const SizedBox(height: 20),

                        // Especialidad
                        CustomDropdownFormField(
                          value: appointmentFormState.specialtyTherapyId,
                          errorMessage: appointmentFormState.isFormPosted
                              ? (appointmentFormState.specialtyTherapyId == null
                                  ? 'Seleccione una especialidad'
                                  : null)
                              : null,
                          prefixIcon: Icon(Icons.medical_services_outlined,
                              color: colors.primary),
                          label: 'Especialidad',
                          hint: 'Seleccione una especialidad',
                          items: appointmentFormState.areas.map((area) {
                            return DropdownMenuItem(
                                value: area.id, child: Text(area.name));
                          }).toList(),
                          onChanged: (value) {
                            appointmentFormNotifier.onAreaChanged(value ?? '');
                          },
                        ),
                        const SizedBox(height: 20),

                        // Diagnóstico
                        CustomTextFormField(
                          initialValue: appointmentFormState.diagnosis,
                          errorMessage: appointmentFormState.isFormPosted
                              ? (appointmentFormState.diagnosis.isEmpty
                                  ? 'Ingrese un sintoma'
                                  : null)
                              : null,
                          prefixIcon: Icon(Icons.description_outlined,
                              color: colors.primary),
                          label: 'Sintoma',
                          hint: 'Ingrese el sintoma',
                          keyboardType: TextInputType.text,
                          onChanged: appointmentFormNotifier.onDiagnosisChanged,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Información adicional
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: colors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información importante',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Su cita quedará en estado pendiente hasta que sea confirmada por el personal de la fundación.',
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: CustomFilledButton(
                        text: 'Cancelar',
                        isTonal: true,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomFilledButton(
                        text: 'Guardar Cita',
                        isLoading: appointmentFormState.loading,
                        onPressed: appointmentFormState.loading
                            ? null
                            : () {
                                appointmentFormNotifier
                                    .saveAppointment(context);
                              },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> _getAvailableHours(DateTime? selectedDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = selectedDate != null &&
        selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;

    final allHours = [
      '08:00',
      '08:30',
      '09:00',
      '09:30',
      '10:00',
      '10:30',
      '11:00',
      '11:30',
      '12:00',
      '12:30',
      '13:00',
      '13:30',
      '14:00',
      '14:30',
      '15:00',
      '15:30',
      '16:00',
      '16:30',
    ];

    if (!isToday) return allHours;

    // Si es hoy, filtrar las horas que ya pasaron
    return allHours.where((hour) {
      final parts = hour.split(':');
      final hourTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      // Agregar un margen de 30 minutos
      return hourTime.isAfter(now.add(const Duration(minutes: 30)));
    }).toList();
  }
}
