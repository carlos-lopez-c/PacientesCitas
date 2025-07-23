import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paciente_citas_1/auth/presentation/providers/page_register.dart';
import 'package:paciente_citas_1/auth/presentation/providers/register_form_provider.dart';
import 'package:paciente_citas_1/shared/presentation/widgets/custom_birth_date_form_field.dart';
import 'package:paciente_citas_1/shared/presentation/widgets/custom_dropdown_form_field.dart';
import 'package:paciente_citas_1/shared/presentation/widgets/custom_filled_button.dart';
import 'package:paciente_citas_1/shared/presentation/widgets/custom_text_form_fiield.dart';


class RegisterFormPart2 extends ConsumerStatefulWidget {
  const RegisterFormPart2({super.key});

  @override
  ConsumerState<RegisterFormPart2> createState() => _RegisterFormPart2State();
}

class _RegisterFormPart2State extends ConsumerState<RegisterFormPart2> {
  late TextEditingController guardianLegalController;

  @override
  void initState() {
    super.initState();
    guardianLegalController = TextEditingController();
  }

  @override
  void dispose() {
    guardianLegalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registerForm = ref.watch(registerFormProvider);
    final colors = Theme.of(context).colorScheme;

    // Actualizar el valor del guardián legal y notificar al provider
    final guardianName =
        "${registerForm.firstname_user.value} ${registerForm.lastname_user.value}";
    if (guardianLegalController.text != guardianName) {
      guardianLegalController.text = guardianName;
      // Notificar al provider del cambio
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(registerFormProvider.notifier)
            .onGuardianLegalPatientChanged(guardianName);
      });
    }

    final genders = [
      {'name': 'Masculino', 'value': 'HOMBRE'},
      {'name': 'Femenino', 'value': 'MUJER'},
    ];

    final relations = [
      {'name': 'Padre', 'value': 'PADRE'},
      {'name': 'Madre', 'value': 'MADRE'},
      {'name': 'Hermano', 'value': 'HERMANO'},
      {'name': 'Hermana', 'value': 'HERMANA'},
      {'name': 'Tio', 'value': 'TIO'},
      {'name': 'Tia', 'value': 'TIA'},
      {'name': 'Abuelo', 'value': 'ABUELO'},
      {'name': 'Abuela', 'value': 'ABUELA'},
      {'name': 'Guardian Legal', 'value': 'GUARDIAN_LEGAL'},
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        const Text(
          'Información Personal del Paciente',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        CustomTextFormField(
          initialValue: registerForm.cedula_patient.value,
          errorMessage: registerForm.isFormPostedStep2
              ? registerForm.cedula_patient.errorMessage
              : null,
          prefixIcon: Icon(Icons.badge_outlined, color: colors.primary),
          label: 'Cédula de Ciudadanía',
          hint: 'Ingrese la cédula',
          keyboardType: TextInputType.number,
          onChanged:
              ref.read(registerFormProvider.notifier).onCedulaPatientChanged,
        ),
        const SizedBox(height: 15),
        CustomTextFormField(
          initialValue: registerForm.firstname_patient.value,
          errorMessage: registerForm.isFormPostedStep2
              ? registerForm.firstname_patient.errorMessage
              : null,
          prefixIcon: Icon(Icons.person_outline, color: colors.primary),
          label: 'Nombre',
          hint: 'Ingrese el nombre',
          keyboardType: TextInputType.name,
          onChanged:
              ref.read(registerFormProvider.notifier).onFirstnamePatientChanged,
        ),
        const SizedBox(height: 15),
        CustomTextFormField(
          initialValue: registerForm.lastname_patient.value,
          errorMessage: registerForm.isFormPostedStep2
              ? registerForm.lastname_patient.errorMessage
              : null,
          prefixIcon: Icon(Icons.person_outline, color: colors.primary),
          label: 'Apellido',
          hint: 'Ingrese el apellido',
          keyboardType: TextInputType.name,
          onChanged:
              ref.read(registerFormProvider.notifier).onLastnamePatientChanged,
        ),
        const SizedBox(height: 15),
        CustomBirthDateFormField(
          errorMessage: registerForm.isFormPostedStep2
              ? registerForm.date_patient.errorMessage
              : null,
          prefixIcon:
              Icon(Icons.calendar_today_outlined, color: colors.primary),
          label: 'Fecha de Nacimiento',
          hint: 'Seleccione la fecha',
          keyboardType: TextInputType.text,
          onChanged:
              ref.read(registerFormProvider.notifier).onDatePatientChanged,
          initialValue: registerForm.date_patient.value,
        ),
        const SizedBox(height: 15),
        // Radio buttons para género
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: registerForm.isFormPostedStep2 &&
                      registerForm.gender_patient.error != null
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
                  Icon(Icons.person_outline, color: colors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Género',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...genders.map((gender) => RadioListTile<String>(
                    title: Text(gender['name']!),
                    value: gender['value']!,
                    groupValue: registerForm.gender_patient.value.isNotEmpty
                        ? registerForm.gender_patient.value
                        : null,
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(registerFormProvider.notifier)
                            .onGenderPatientChanged(value);
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    visualDensity: VisualDensity.compact,
                  )),
              if (registerForm.isFormPostedStep2 &&
                  registerForm.gender_patient.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    registerForm.gender_patient.errorMessage ??
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
        const SizedBox(height: 15),
        CustomDropdownFormField(
          value: registerForm.relation_legal_guardian_patient.value.isNotEmpty
              ? registerForm.relation_legal_guardian_patient.value
              : null,
          errorMessage: registerForm.isFormPostedStep2
              ? registerForm.relation_legal_guardian_patient.errorMessage
              : null,
          prefixIcon: Icon(Icons.family_restroom, color: colors.primary),
          label: 'Relación con el Paciente',
          items: relations.map((relation) {
            return DropdownMenuItem(
              value: relation['value'],
              child: Text(relation['name']!),
            );
          }).toList(),
          hint: 'Seleccione la relación',
          onChanged: (value) {
            final valueD = value ?? '';
            ref
                .read(registerFormProvider.notifier)
                .onRelationLegalGuardianPatientChanged(valueD);
          },
        ),
        const SizedBox(height: 15),
        CustomTextFormField(
          controller: guardianLegalController,
          errorMessage: registerForm.isFormPostedStep2
              ? registerForm.guardian_legal_patient.errorMessage
              : null,
          prefixIcon: Icon(Icons.person_2_outlined, color: colors.primary),
          label: 'Guardián Legal',
          hint: 'Nombre del guardián legal',
          keyboardType: TextInputType.name,
          onChanged: ref
              .read(registerFormProvider.notifier)
              .onGuardianLegalPatientChanged,
        ),
        const SizedBox(height: 20),
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
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: CustomFilledButton(
                  text: 'Siguiente',
                  onPressed: () {
                    // Primero validamos
                    ref.read(registerFormProvider.notifier).OnNextPage3();

                    // Verificamos específicamente la cédula
                    if (registerForm.cedula_patient.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              registerForm.cedula_patient.errorMessage ??
                                  'Cédula inválida'),
                          backgroundColor: Colors.red.shade300,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    // Verificamos el resto de campos
                    if (!ref.read(registerFormProvider).isValid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                              'Por favor, complete todos los campos correctamente'),
                          backgroundColor: Colors.red.shade300,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    // Solo si todo es válido, avanzamos
                    ref.read(pageControllerProvider.notifier).nextPage();
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
