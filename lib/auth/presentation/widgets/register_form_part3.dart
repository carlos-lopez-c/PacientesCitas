import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paciente_citas_1/auth/presentation/providers/auth_provider.dart';
import 'package:paciente_citas_1/auth/presentation/providers/page_register.dart';
import 'package:paciente_citas_1/auth/presentation/providers/register_form_provider.dart';
import 'package:paciente_citas_1/shared/presentation/widgets/custom_filled_button.dart';
import 'package:paciente_citas_1/shared/presentation/widgets/snackbar.dart';

class RegisterFormPart3 extends ConsumerStatefulWidget {
  const RegisterFormPart3({super.key});

  @override
  ConsumerState<RegisterFormPart3> createState() => _RegisterFormPart3State();
}

class _RegisterFormPart3State extends ConsumerState<RegisterFormPart3> {
  bool _isRegistering = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<FormularioState>(registerFormProvider, (prev, next) {
      if (!mounted) return;

      if (prev?.isPosting == true && next.isPosting == false) {
        if (next.errorMessage.isNotEmpty &&
            prev?.errorMessage != next.errorMessage) {
          showCustomSnackbar(context,
              message: next.errorMessage, isError: true);
          ref.read(registerFormProvider.notifier).clearErrorMessage();
          setState(() {
            _isRegistering = false;
          });
        } else if (next.successMessage.isNotEmpty &&
            prev?.successMessage != next.successMessage) {
          showCustomSnackbar(context, message: next.successMessage);

          setState(() {
            _isRegistering = false;
          });

          // Esperar a que el proceso de registro realmente termine
          // y luego redirigir al login después de mostrar el mensaje de éxito
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          });
        }
      }
    });

    final registerForm = ref.watch(registerFormProvider);
    final authState = ref.watch(authProvider);
    final colors = Theme.of(context).colorScheme;
    final scrollController = ScrollController();

    final healthInsuranceOptions = [
      {'name': 'ISSFA', 'value': 'ISSFA'},
      {'name': 'Ninguno', 'value': 'NINGUNO'},
    ];

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

          // Seguro Social con Radio Buttons
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: registerForm.isFormPostedStep3 &&
                        registerForm.health_insurance_patient.error != null
                    ? Colors.red
                    : Colors.grey.shade400,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.health_and_safety_outlined,
                        color: colors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Seguro Social',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...healthInsuranceOptions.map((option) => RadioListTile<String>(
                      title: Text(option['name']!),
                      value: option['value']!,
                      groupValue:
                          registerForm.health_insurance_patient.value.isNotEmpty
                              ? registerForm.health_insurance_patient.value
                              : null,
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(registerFormProvider.notifier)
                              .onHealthInsurancePatientChanged(value);
                        }
                      },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      visualDensity: VisualDensity.compact,
                    )),
                if (registerForm.isFormPostedStep3 &&
                    registerForm.health_insurance_patient.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      registerForm.health_insurance_patient.errorMessage ??
                          'Campo requerido',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (registerForm.health_insurance_patient.value == 'ISSFA')
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colors.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: colors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Acérquese a la Fundación para entregar los documentos correspondientes',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
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
                    onPressed: _isRegistering
                        ? null
                        : () {
                            ref
                                .read(pageControllerProvider.notifier)
                                .previousPage();
                          },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: CustomFilledButton(
                    text: _isRegistering ? 'Registrando...' : 'Registrar',
                    onPressed: (registerForm.isPosting || authState.isLoading)
                        ? null
                        : () async {
                            await ref
                                .read(registerFormProvider.notifier)
                                .onFormSubmit();
                          },
                    isLoading: registerForm.isPosting || authState.isLoading,
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
