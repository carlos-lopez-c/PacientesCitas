import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paciente_citas_1/auth/presentation/providers/page_register.dart';
import 'package:paciente_citas_1/auth/presentation/providers/register_form_provider.dart';
import 'package:paciente_citas_1/shared/presentation/widgets/custom_filled_button.dart';
import 'package:paciente_citas_1/shared/presentation/widgets/custom_text_form_fiield.dart';


class RegisterFormPart1 extends ConsumerStatefulWidget {
  const RegisterFormPart1({super.key});

  @override
  ConsumerState<RegisterFormPart1> createState() => _RegisterFormPart1State();
}

class _RegisterFormPart1State extends ConsumerState<RegisterFormPart1> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final registerForm = ref.watch(registerFormProvider);
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        const SizedBox(height: 10),
        const Center(
          child: Text(
            'Información del Representante',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          initialValue: registerForm.email_user.value,
          prefixIcon: Icon(Icons.email_outlined, color: colors.primary),
          errorMessage: registerForm.isFormPostedStep1
              ? registerForm.email_user.errorMessage
              : null,
          label: 'Correo Electrónico',
          hint: 'ejemplo@correo.com',
          keyboardType: TextInputType.emailAddress,
          onChanged: ref.read(registerFormProvider.notifier).onEmailUserChanged,
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          initialValue: registerForm.password_user.value,
          errorMessage: registerForm.isFormPostedStep1
              ? registerForm.password_user.errorMessage
              : null,
          obscureText: !_showPassword,
          prefixIcon: Icon(Icons.lock_outline, color: colors.primary),
          suffixIcon: IconButton(
            icon: Icon(
              _showPassword ? Icons.visibility_off : Icons.visibility,
              color: colors.primary,
            ),
            onPressed: () {
              setState(() {
                _showPassword = !_showPassword;
              });
            },
          ),
          label: 'Contraseña',
          hint: '',
          onChanged:
              ref.read(registerFormProvider.notifier).onPasswordUserChanged,
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          initialValue: registerForm.username_user.value,
          errorMessage: registerForm.isFormPostedStep1
              ? registerForm.username_user.errorMessage
              : null,
          prefixIcon: Icon(Icons.person_outline, color: colors.primary),
          label: 'Nombre de Usuario',
          hint: 'Ingrese su nombre de usuario',
          keyboardType: TextInputType.name,
          onChanged:
              ref.read(registerFormProvider.notifier).onUsernameUserChanged,
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          initialValue: registerForm.firstname_user.value,
          errorMessage: registerForm.isFormPostedStep1
              ? registerForm.firstname_user.errorMessage
              : null,
          prefixIcon: Icon(Icons.person_2_outlined, color: colors.primary),
          label: 'Nombre',
          hint: 'Ingrese su nombre',
          keyboardType: TextInputType.name,
          onChanged:
              ref.read(registerFormProvider.notifier).onFirstnameUserChanged,
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          initialValue: registerForm.lastname_user.value,
          errorMessage: registerForm.isFormPostedStep1
              ? registerForm.lastname_user.errorMessage
              : null,
          prefixIcon: Icon(Icons.person_2_outlined, color: colors.primary),
          label: 'Apellido',
          hint: 'Ingrese su apellido',
          keyboardType: TextInputType.name,
          onChanged:
              ref.read(registerFormProvider.notifier).onLastnameUserChanged,
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          initialValue: registerForm.phone_user.value,
          errorMessage: registerForm.isFormPostedStep1
              ? registerForm.phone_user.errorMessage
              : null,
          prefixIcon: Icon(Icons.phone_outlined, color: colors.primary),
          label: 'Teléfono',
          hint: 'Ingrese su teléfono',
          keyboardType: TextInputType.phone,
          onChanged: ref.read(registerFormProvider.notifier).onPhoneUserChanged,
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          initialValue: registerForm.address_user.value,
          errorMessage: registerForm.isFormPostedStep1
              ? registerForm.address_user.errorMessage
              : null,
          prefixIcon: Icon(Icons.location_on_outlined, color: colors.primary),
          label: 'Dirección',
          hint: 'Ingrese su dirección',
          keyboardType: TextInputType.streetAddress,
          onChanged:
              ref.read(registerFormProvider.notifier).onAddressUserChanged,
        ),
        const SizedBox(height: 20),
        CustomFilledButton(
          text: 'Siguiente',
          width: 180,
          onPressed: () {
            ref.read(registerFormProvider.notifier).OnNextPage2();

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

            ref.read(pageControllerProvider.notifier).nextPage();
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
