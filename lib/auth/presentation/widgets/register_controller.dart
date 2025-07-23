import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paciente_citas_1/auth/presentation/providers/page_register.dart';
import 'package:paciente_citas_1/auth/presentation/widgets/register_form_part1.dart';
import 'package:paciente_citas_1/auth/presentation/widgets/register_form_part2.dart';
import 'package:paciente_citas_1/auth/presentation/widgets/register_form_part3.dart';

class RegisterController extends ConsumerWidget {
  const RegisterController({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageState = ref.watch(pageControllerProvider);
    final colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Indicador de progreso
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _StepIndicator(
                isActive: pageState.currentPage >= 0,
                isCompleted: pageState.currentPage > 0,
                stepNumber: 1,
                label: 'Usuario',
                color: colors.primary,
              ),
              _StepConnector(
                isCompleted: pageState.currentPage > 0,
                color: colors.primary,
              ),
              _StepIndicator(
                isActive: pageState.currentPage >= 1,
                isCompleted: pageState.currentPage > 1,
                stepNumber: 2,
                label: 'Paciente',
                color: colors.primary,
              ),
              _StepConnector(
                isCompleted: pageState.currentPage > 1,
                color: colors.primary,
              ),
              _StepIndicator(
                isActive: pageState.currentPage >= 2,
                isCompleted: pageState.currentPage > 2,
                stepNumber: 3,
                label: 'Médico',
                color: colors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        // Contenido del formulario con animación
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(
                    animation.status == AnimationStatus.forward ? 1.0 : -1.0,
                    0.0,
                  ),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                )),
                child: child,
              ),
            );
          },
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          child: KeyedSubtree(
            key: ValueKey<int>(pageState.currentPage),
            child: _getStepContent(pageState.currentPage),
          ),
        ),
      ],
    );
  }

  Widget _getStepContent(int step) {
    switch (step) {
      case 0:
        return const RegisterFormPart1();
      case 1:
        return const RegisterFormPart2();
      case 2:
        return const RegisterFormPart3();
      default:
        return const RegisterFormPart1();
    }
  }
}

class _StepIndicator extends StatelessWidget {
  final bool isActive;
  final bool isCompleted;
  final int stepNumber;
  final String label;
  final Color color;

  const _StepIndicator({
    required this.isActive,
    required this.isCompleted,
    required this.stepNumber,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? color
                  : isActive
                      ? color.withOpacity(0.2)
                      : Colors.grey.shade200,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? color : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    )
                  : Text(
                      stepNumber.toString(),
                      style: TextStyle(
                        color: isActive ? color : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? color : Colors.grey,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  final bool isCompleted;
  final Color color;

  const _StepConnector({
    required this.isCompleted,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 2,
      color: isCompleted ? color : Colors.grey.shade300,
    );
  }
}
