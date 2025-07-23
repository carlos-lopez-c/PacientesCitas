import 'package:flutter/material.dart';
import 'package:paciente_citas_1/home/domain/entities/cita.entity.dart';

class AppointmentDetailDialog extends StatelessWidget {
  final Appointments appointment;

  const AppointmentDetailDialog({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Encabezado con estado
              Row(
                children: [
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
                    child: Icon(statusIcon, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detalles de la Cita',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
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
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Divider
              Divider(color: colors.primary.withOpacity(0.2), thickness: 1),

              const SizedBox(height: 10),

              // Información principal
              _buildDetailCard(
                context,
                'Información de la Cita',
                [
                  _buildDetailRow(context, Icons.calendar_today, 'Fecha:',
                      appointment.date),
                  _buildDetailRow(context, Icons.access_time, 'Hora:',
                      appointment.appointmentTime),
                  _buildDetailRow(context, Icons.medical_services_outlined,
                      'Especialidad:', appointment.specialtyTherapy),
                ],
              ),

              const SizedBox(height: 15),

              // Información del paciente y doctor
              _buildDetailCard(
                context,
                'Personas Involucradas',
                [
                  _buildDetailRow(
                      context, Icons.person, 'Paciente:', appointment.patient),
                  _buildDetailRow(context, Icons.medical_services, 'Doctor:',
                      appointment.doctor),
                ],
              ),

              const SizedBox(height: 15),

              // Información adicional
              _buildDetailCard(
                context,
                'Información Adicional',
                [
                  _buildDetailRow(context, Icons.description, 'Diagnóstico:',
                      appointment.diagnosis),
                  _buildDetailRow(context, Icons.security, 'Seguro Médico:',
                      appointment.medicalInsurance),
                ],
              ),

              const SizedBox(height: 20),

              // Botón de cerrar
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'CERRAR',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget para construir una tarjeta de detalles
  Widget _buildDetailCard(
      BuildContext context, String title, List<Widget> children) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.primary.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  /// Widget para construir filas de detalles
  Widget _buildDetailRow(
      BuildContext context, IconData icon, String label, String value) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurface.withOpacity(0.7),
                  ),
                ),
                Text(
                  value.isEmpty ? 'No especificado' : value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
