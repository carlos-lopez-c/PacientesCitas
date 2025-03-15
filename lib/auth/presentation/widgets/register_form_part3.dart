import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fundacion_paciente_app/auth/presentation/providers/page_register.dart';
import 'package:fundacion_paciente_app/auth/presentation/providers/register_form_provider.dart';
import 'package:fundacion_paciente_app/shared/presentation/widgets/custom_dropdown_form_field.dart';
import 'package:fundacion_paciente_app/shared/presentation/widgets/custom_filled_button.dart';
import 'package:fundacion_paciente_app/shared/presentation/widgets/snackbar.dart';

class RegisterFormPart3 extends ConsumerWidget {
  const RegisterFormPart3({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<FormularioState>(registerFormProvider, (prev, next) {
      if (prev?.isPosting == true && next.isPosting == false) {
        if (next.errorMessage.isNotEmpty &&
            prev?.errorMessage != next.errorMessage) {
          showCustomSnackbar(context,
              message: next.errorMessage, isError: true);
          ref
              .read(registerFormProvider.notifier)
              .clearErrorMessage(); // ✅ Limpiar mensaje después de mostrar
        } else if (next.successMessage.isNotEmpty &&
            prev?.successMessage != next.successMessage) {
          showCustomSnackbar(context, message: next.successMessage);
          ref
              .read(registerFormProvider.notifier)
              .clearSuccessMessage(); // ✅ Limpiar mensaje después de mostrar
        }
      }
    });
    final typeTeraphy = [
      {'name': 'Issfa', 'value': 'ISSFA'},
      {'name': 'Ninguno', 'value': 'NINGUNO'},
    ];
    final pageState = ref.watch(pageControllerProvider);
    final registerForm = ref.watch(registerFormProvider);
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final scrollController = ScrollController();
    final currentPage = pageState.currentPage;
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          const Text(
            'Información Médica del Paciente',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Seguro Social
          CustomDropdownFormField(
            value: registerForm.health_insurance_patient.value.isNotEmpty
                ? registerForm.health_insurance_patient.value
                : null,
            errorMessage: registerForm.isFormPostedStep3
                ? registerForm.health_insurance_patient.errorMessage
                : null,
            prefixIcon:
                Icon(Icons.health_and_safety_outlined, color: colors.primary),
            label: 'Seguro Social',
            onChanged: (value) {
              if (value != null) {
                ref
                    .read(registerFormProvider.notifier)
                    .onHealthInsurancePatientChanged(value);
              }
            },
            hint: 'Seleccione el seguro social',
            items: const [
              DropdownMenuItem(value: 'ISSFA', child: Text('ISSFA')),
              DropdownMenuItem(value: 'NINGUNO', child: Text('Ninguno')),
            ],
          ),
          const SizedBox(height: 20),

          // Medicación Actual
          _buildChipInput(
            context: context,
            title: 'Medicación Actual',
            items: registerForm.current_medications_patient,
            onAdd: (value) {
              final updatedList = [
                ...registerForm.current_medications_patient,
                value
              ];
              ref
                  .read(registerFormProvider.notifier)
                  .onCurrentMedicationsPatientChanged(updatedList);
            },
            onDelete: (index) {
              final updatedList =
                  List<String>.from(registerForm.current_medications_patient)
                    ..removeAt(index);
              ref
                  .read(registerFormProvider.notifier)
                  .onCurrentMedicationsPatientChanged(updatedList);
            },
            hintText: 'Agregar medicación',
          ),

          // Alergias
          _buildChipInput(
            context: context,
            title: 'Alergias',
            items: registerForm.allergies_patient,
            onAdd: (value) {
              final updatedList = [...registerForm.allergies_patient, value];
              ref
                  .read(registerFormProvider.notifier)
                  .onAllergiesPatientChanged(updatedList);
            },
            onDelete: (index) {
              final updatedList =
                  List<String>.from(registerForm.allergies_patient)
                    ..removeAt(index);
              ref
                  .read(registerFormProvider.notifier)
                  .onAllergiesPatientChanged(updatedList);
            },
            hintText: 'Agregar alergias',
          ),

          // Discapacidades
          _buildChipInput(
            context: context,
            title: 'Discapacidades',
            items: registerForm.disabilities_patient,
            onAdd: (value) {
              final updatedList = [...registerForm.disabilities_patient, value];
              ref
                  .read(registerFormProvider.notifier)
                  .onDisabilitiesPatientChanged(updatedList);
            },
            onDelete: (index) {
              final updatedList =
                  List<String>.from(registerForm.disabilities_patient)
                    ..removeAt(index);
              ref
                  .read(registerFormProvider.notifier)
                  .onDisabilitiesPatientChanged(updatedList);
            },
            hintText: 'Agregar discapacidades',
          ),

          const SizedBox(height: 20),

          // Botones de navegación
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: CustomFilledButton(
                    text: 'Anterior',
                    isTonal: true,
                    onPressed: () {
                      ref.read(pageControllerProvider.notifier).previousPage();
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: CustomFilledButton(
                    text: 'Registrar',
                    onPressed: registerForm.isPosting
                        ? null
                        : () => ref
                            .read(registerFormProvider.notifier)
                            .onFormSubmit(),
                    isLoading: registerForm.isPosting,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildChipInput({
    required BuildContext context,
    required String title,
    required List<String> items,
    required Function(String) onAdd,
    required Function(int) onDelete,
    required String hintText,
  }) {
    final colors = Theme.of(context).colorScheme;
    final controller = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...items.asMap().entries.map((entry) {
              return Chip(
                label: Text(
                  entry.value,
                  style: const TextStyle(fontSize: 12),
                ),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => onDelete(entry.key),
                backgroundColor: colors.primaryContainer,
                side: BorderSide.none,
              );
            }),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Agregar $title'),
                    content: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: hintText,
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          onAdd(value);
                          controller.clear();
                          Navigator.pop(context);
                        }
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      CustomFilledButton(
                        text: 'Agregar',
                        width: 120,
                        onPressed: () {
                          if (controller.text.isNotEmpty) {
                            onAdd(controller.text);
                            controller.clear();
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
              child: Chip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      size: 18,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hintText,
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                backgroundColor: colors.primaryContainer.withOpacity(0.3),
                side: BorderSide(
                  color: colors.primary.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
