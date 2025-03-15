import 'package:flutter/material.dart';

class CustomFilledButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isTonal;
  final double? width;
  final double height;
  final double fontSize;
  final double letterSpacing;
  final FontWeight fontWeight;

  const CustomFilledButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isTonal = false,
    this.width,
    this.height = 48,
    this.fontSize = 16,
    this.letterSpacing = 1.2,
    this.fontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: isTonal
          ? FilledButton.tonal(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: _buildChild(colors),
            )
          : FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: _buildChild(colors),
            ),
    );
  }

  Widget _buildChild(ColorScheme colors) {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
      ),
    );
  }
}
