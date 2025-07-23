import 'package:flutter/material.dart';
import 'package:paciente_citas_1/home/domain/entities/cita.entity.dart';
import 'package:paciente_citas_1/home/presentation/widgets/appointment_detail_dialog.dart';

class AppointmentList extends StatelessWidget {
  final List<Appointments> appointments;

  const AppointmentList({super.key, required this.appointments});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];

        // Determinar el color según el estado
        Color statusColor;
        IconData statusIcon;

        switch (appointment.status.toLowerCase()) {
          case 'agendado':
            statusColor = Colors.green.shade600;
            statusIcon = Icons.check_circle_outline;
            break;
          case 'pendiente':
            statusColor = Colors.orange.shade600;
            statusIcon = Icons.pending_outlined;
            break;
          case 'cancelado':
            statusColor = Colors.red.shade600;
            statusIcon = Icons.cancel_outlined;
            break;
          default:
            statusColor = colors.primary;
            statusIcon = Icons.event_note;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Card(
            elevation: 4,
            shadowColor: colors.primary.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: statusColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      AppointmentDetailDialog(appointment: appointment),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Icono de estado
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: statusColor,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(statusIcon, color: statusColor, size: 22),
                        ),
                        const SizedBox(width: 12),
                        // Información principal
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cita con ${appointment.doctor}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: colors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    appointment.appointmentTime,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colors.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: statusColor.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      appointment.status,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Botón de detalles
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AppointmentDetailDialog(
                                  appointment: appointment),
                            );
                          },
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: colors.primary,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: colors.primary.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Información adicional
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 44),
                      child: Text(
                        'Especialidad: ${appointment.specialtyTherapy}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
