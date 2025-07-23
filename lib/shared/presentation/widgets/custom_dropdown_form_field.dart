import 'package:flutter/material.dart';

class CustomDropdownFormField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorMessage;
  final String? value;
  final Icon? prefixIcon;
  final List<DropdownMenuItem<String>>? items;
  final Function(String?)? onChanged;

  const CustomDropdownFormField({
    super.key,
    this.label,
    this.hint,
    this.errorMessage,
    this.value,
    this.prefixIcon,
    this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: errorMessage != null ? Colors.red : colors.primary,
              ),
            ),
          ),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorMessage != null
                  ? Colors.red.withOpacity(0.5)
                  : colors.primary.withOpacity(0.2),
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items,
            onChanged: onChanged,
            style: TextStyle(
              fontSize: 14,
              color: colors.onSurface,
            ),
            icon: Icon(
              Icons.arrow_drop_down,
              color: colors.primary,
              size: 24,
            ),
            decoration: InputDecoration(
              prefixIcon: prefixIcon != null
                  ? IconTheme(
                      data: IconThemeData(
                        size: 20,
                        color:
                            errorMessage != null ? Colors.red : colors.primary,
                      ),
                      child: prefixIcon!,
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
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 14,
                color: colors.onSurface.withOpacity(0.5),
              ),
              border: InputBorder.none,
            ),
            dropdownColor: colors.surface,
            borderRadius: BorderRadius.circular(12),
            isExpanded: true,
          ),
        ),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 4),
            child: Text(
              errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
