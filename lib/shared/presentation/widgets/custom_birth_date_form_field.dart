import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomBirthDateFormField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorMessage;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final Icon? prefixIcon;
  final String initialValue;

  const CustomBirthDateFormField({
    super.key,
    this.label,
    this.hint,
    this.errorMessage,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.initialValue = '',
  });

  @override
  _CustomBirthDateFormFieldState createState() =>
      _CustomBirthDateFormFieldState();
}

class _CustomBirthDateFormFieldState extends State<CustomBirthDateFormField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant CustomBirthDateFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final colors = Theme.of(context).colorScheme;
    final now = DateTime.now();

    try {
      DateTime initialDate;
      if (widget.initialValue.isNotEmpty) {
        try {
          initialDate = DateFormat('dd/MM/yyyy').parse(widget.initialValue);
        } catch (_) {
          initialDate = DateTime(
              now.year - 18, now.month, now.day); // Por defecto 18 años atrás
        }
      } else {
        initialDate = DateTime(now.year - 18, now.month, now.day);
      }

      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(1900), // Permitir fechas desde 1900
        lastDate: now, // La fecha máxima es hoy
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
        final formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
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
          onTap: () => _selectDate(context),
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
                suffixIcon: Icon(
                  Icons.arrow_drop_down,
                  color: colors.primary,
                  size: 24,
                ),
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
