import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDateFormField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorMessage;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final Icon? prefixIcon;
  final bool isDatePicker;
  final String initialValue;
  final bool lastDate;

  const CustomDateFormField({
    super.key,
    this.label,
    this.hint,
    this.errorMessage,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.isDatePicker = false,
    this.initialValue = '',
    this.lastDate = true,
  });

  @override
  _CustomDateFormFieldState createState() => _CustomDateFormFieldState();
}

class _CustomDateFormFieldState extends State<CustomDateFormField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant CustomDateFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final colors = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    try {
      DateTime initialDate;
      if (widget.initialValue.isNotEmpty) {
        try {
          initialDate = DateFormat('dd/MM/yyyy').parse(widget.initialValue);
        } catch (_) {
          initialDate = today;
        }
      } else {
        initialDate = today;
      }

      // Asegurarse de que la fecha inicial no sea fin de semana
      while (initialDate.weekday == DateTime.saturday ||
          initialDate.weekday == DateTime.sunday) {
        initialDate = initialDate.add(const Duration(days: 1));
      }

      // Asegurarse de que la fecha inicial no sea anterior a hoy
      if (initialDate.isBefore(today)) {
        initialDate = today;
        // Si today es fin de semana, mover al siguiente día hábil
        while (initialDate.weekday == DateTime.saturday ||
            initialDate.weekday == DateTime.sunday) {
          initialDate = initialDate.add(const Duration(days: 1));
        }
      }

      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: today,
        lastDate: DateTime(today.year + 1),
        selectableDayPredicate: (DateTime date) {
          return date.weekday != DateTime.saturday &&
              date.weekday != DateTime.sunday;
        },
        locale: const Locale('es'),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: colors.primary,
                onPrimary: colors.onPrimary,
                surface: colors.surface,
                onSurface: colors.onSurface,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedDate != null) {
        // Formatear la fecha usando DateFormat con locale es
        final formattedDate = DateFormat('dd/MM/yyyy', 'es').format(pickedDate);
        if (mounted) {
          setState(() {
            _controller.text = formattedDate;
          });
          widget.onChanged?.call(formattedDate);
        }
      }
    } catch (e) {
      debugPrint('Error selecting date: $e');
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final colors = Theme.of(context).colorScheme;
    final now = DateTime.now();

    try {
      // Definir horarios disponibles
      final availableHours = [
        TimeOfDay(hour: 8, minute: 0),
        TimeOfDay(hour: 8, minute: 30),
        TimeOfDay(hour: 9, minute: 0),
        TimeOfDay(hour: 9, minute: 30),
        TimeOfDay(hour: 10, minute: 0),
        TimeOfDay(hour: 10, minute: 30),
        TimeOfDay(hour: 11, minute: 0),
        TimeOfDay(hour: 11, minute: 30),
        TimeOfDay(hour: 12, minute: 0),
        TimeOfDay(hour: 12, minute: 30),
        TimeOfDay(hour: 13, minute: 0),
        TimeOfDay(hour: 13, minute: 30),
        TimeOfDay(hour: 14, minute: 0),
        TimeOfDay(hour: 14, minute: 30),
        TimeOfDay(hour: 15, minute: 0),
        TimeOfDay(hour: 15, minute: 30),
        TimeOfDay(hour: 16, minute: 0),
        TimeOfDay(hour: 16, minute: 30),
      ];

      // Obtener hora inicial
      TimeOfDay initialTime;
      if (widget.initialValue.isNotEmpty) {
        try {
          final parts = widget.initialValue.split(':');
          initialTime =
              TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        } catch (_) {
          initialTime = availableHours.first;
        }
      } else {
        initialTime = availableHours.first;
      }

      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: colors.primary,
                onPrimary: colors.onPrimary,
                surface: colors.surface,
                onSurface: colors.onSurface,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        // Verificar si la hora seleccionada está en los horarios disponibles
        bool isAvailableTime = availableHours.any((time) =>
            time.hour == pickedTime.hour && time.minute == pickedTime.minute);

        if (!isAvailableTime) {
          // Si la hora no está disponible, mostrar un mensaje
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Por favor seleccione un horario disponible entre las 8:00 y 16:30 en intervalos de 30 minutos.'),
                backgroundColor: Colors.red.shade300,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          return;
        }

        // Verificar si es el día actual comparando con la fecha seleccionada
        bool isToday = false;
        try {
          if (widget.initialValue.isNotEmpty) {
            final selectedDate =
                DateFormat('dd/MM/yyyy').parse(widget.initialValue);
            isToday = selectedDate.year == now.year &&
                selectedDate.month == now.month &&
                selectedDate.day == now.day;
          }
        } catch (e) {
          debugPrint('Error parsing date: $e');
        }

        // Solo verificar el margen de 30 minutos si es el día actual
        if (isToday) {
          final currentTime = TimeOfDay.now();

          // Convertir las horas a minutos para una comparación más fácil
          final currentMinutes = currentTime.hour * 60 + currentTime.minute;
          final selectedMinutes = pickedTime.hour * 60 + pickedTime.minute;

          // Si la hora seleccionada ya pasó o está dentro de los próximos 30 minutos
          if (selectedMinutes < currentMinutes + 30) {
            // Encontrar el próximo horario disponible
            TimeOfDay nextTime = availableHours.firstWhere(
              (time) {
                final timeMinutes = time.hour * 60 + time.minute;
                return timeMinutes > currentMinutes + 30;
              },
              orElse: () => availableHours.first,
            );

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'La hora seleccionada ya pasó. El próximo horario disponible es ${_formatTimeOfDay(nextTime)}'),
                  backgroundColor: Colors.red.shade300,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
            return;
          }
        }

        final formattedTime = _formatTimeOfDay(pickedTime);
        if (mounted) {
          setState(() {
            _controller.text = formattedTime;
          });
          widget.onChanged?.call(formattedTime);
        }
      }
    } catch (e) {
      debugPrint('Error selecting time: $e');
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              widget.label!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                    widget.errorMessage != null ? Colors.red : colors.primary,
              ),
            ),
          ),
        InkWell(
          onTap: () {
            if (widget.isDatePicker) {
              _selectDate(context);
            } else {
              _selectTime(context);
            }
          },
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.errorMessage != null
                    ? Colors.red.withOpacity(0.5)
                    : colors.primary.withOpacity(0.2),
              ),
            ),
            child: TextFormField(
              controller: _controller,
              readOnly: true,
              enabled: false,
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurface,
              ),
              decoration: InputDecoration(
                prefixIcon: widget.prefixIcon != null
                    ? IconTheme(
                        data: IconThemeData(
                          size: 20,
                          color: widget.errorMessage != null
                              ? Colors.red
                              : colors.primary,
                        ),
                        child: widget.prefixIcon!,
                      )
                    : null,
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: colors.onSurface.withOpacity(0.5),
                ),
                border: InputBorder.none,
                suffixIcon: widget.isDatePicker
                    ? Icon(
                        Icons.arrow_drop_down,
                        color: colors.primary,
                        size: 24,
                      )
                    : null,
              ),
            ),
          ),
        ),
        if (widget.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 4),
            child: Text(
              widget.errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
