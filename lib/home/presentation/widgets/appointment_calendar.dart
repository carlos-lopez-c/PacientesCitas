import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paciente_citas_1/home/presentation/providers/appointments_provider.dart';
import 'package:paciente_citas_1/home/presentation/widgets/appointment_list.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class AppointmentCalendar extends ConsumerWidget {
  const AppointmentCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentState = ref.watch(appointmentProvider);
    final notifier = ref.read(appointmentProvider.notifier);
    final selectedDate = appointmentState.calendarioCitaSeleccionada;
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Título con animación
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.8, end: 1),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.primary.withOpacity(0.7),
                    colors.primary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'CALENDARIO DE CITAS',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Calendario con estilo mejorado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Card(
              elevation: 4,
              shadowColor: colors.primary.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TableCalendar(
                  availableGestures: AvailableGestures.all,
                  locale: "es_EC",
                  rowHeight: 40,
                  daysOfWeekHeight: 20,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      color: colors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    leftChevronIcon: Icon(Icons.chevron_left,
                        color: colors.primary, size: 20),
                    rightChevronIcon: Icon(Icons.chevron_right,
                        color: colors.primary, size: 20),
                    headerPadding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    weekendStyle: TextStyle(
                      color: colors.primary.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle:
                        TextStyle(color: Colors.red, fontSize: 14),
                    defaultTextStyle: const TextStyle(fontSize: 14),
                    todayTextStyle:
                        const TextStyle(fontSize: 14, color: Colors.white),
                    selectedTextStyle:
                        const TextStyle(fontSize: 14, color: Colors.white),
                    todayDecoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: colors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  focusedDay: selectedDate,
                  firstDay: DateTime.utc(2020, 10, 16),
                  lastDay: DateTime.utc(2040, 3, 14),
                  selectedDayPredicate: (day) => isSameDay(day, selectedDate),
                  onDaySelected: (selectedDay, focusedDay) {
                    notifier.onDateSelected(selectedDay);
                  },
                  // Personalización de los días con colores según estado
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, date, _) {
                      try {
                        final citasDelDia =
                            appointmentState.appointments.where((cita) {
                          try {
                            final citaDate =
                                DateFormat('yyyy-MM-dd').parse(cita.date);
                            return isSameDay(date, citaDate);
                          } catch (_) {
                            return false;
                          }
                        }).toList();

                        Color? backgroundColor;
                        if (citasDelDia
                            .any((cita) => cita.status == 'Agendado')) {
                          backgroundColor = Colors.green.shade600; // ✅ Agendado
                        } else if (citasDelDia
                            .any((cita) => cita.status == 'Pendiente')) {
                          backgroundColor =
                              Colors.orange.shade600; // ⏳ Pendiente
                        }

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.all(4),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: backgroundColor ?? Colors.transparent,
                            shape: BoxShape.circle,
                            boxShadow: backgroundColor != null
                                ? [
                                    BoxShadow(
                                      color: backgroundColor.withOpacity(0.4),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : null,
                          ),
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              color: backgroundColor != null
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        );
                      } catch (_) {
                        return null;
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Sección de citas del día
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.primary.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.event_note,
                      color: colors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Citas para ${DateFormat('EEEE, d MMMM yyyy', 'es_EC').format(selectedDate)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Lista de citas
          Expanded(
            child: appointmentState.loading
                ? Center(
                    child: CircularProgressIndicator(
                      color: colors.primary,
                    ),
                  )
                : appointmentState.appointmentsByDate.isEmpty
                    ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: size.height * 0.05,
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colors.primary.withOpacity(0.2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.primary.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colors.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.event_busy,
                                    size: 40,
                                    color: colors.primary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No tienes citas agendadas para esta fecha',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: colors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Selecciona otra fecha en el calendario para ver tus citas',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colors.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: AppointmentList(
                          appointments: appointmentState.appointmentsByDate,
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
