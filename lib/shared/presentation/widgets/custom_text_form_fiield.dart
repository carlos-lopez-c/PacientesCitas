import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorMessage;
  final String? initialValue;
  final bool obscureText;
  //controoler opcional
  final TextEditingController? controller;
  final Icon? prefixIcon;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final int? maxLength;
  final Widget? suffixIcon;

  const CustomTextFormField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.errorMessage,
    this.controller,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.validator,
    this.maxLength,
    this.suffixIcon,
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
          height: 52,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorMessage != null
                  ? Colors.red.withOpacity(0.5)
                  : colors.primary.withOpacity(0.2),
            ),
          ),
          child: TextFormField(
            initialValue: initialValue,
            controller: controller,
            onChanged: onChanged,
            validator: validator,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLength: maxLength,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(
              fontSize: 14,
              color: colors.onSurface,
            ),
            decoration: InputDecoration(
              isDense: true,
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
                vertical: 14,
              ),
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 14,
                color: colors.onSurface.withOpacity(0.5),
              ),
              border: InputBorder.none,
              suffixIcon: suffixIcon,
              counterText: "",
            ),
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
