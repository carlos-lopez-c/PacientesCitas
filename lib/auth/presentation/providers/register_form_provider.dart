import 'dart:math';

import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paciente_citas_1/auth/domain/entities/user_register.dart';
import 'package:paciente_citas_1/auth/presentation/providers/auth_provider.dart';
import 'package:paciente_citas_1/shared/infrastructure/inputs/address_input.dart';
import 'package:paciente_citas_1/shared/infrastructure/inputs/cedula_input.dart';
import 'package:paciente_citas_1/shared/infrastructure/inputs/date_input.dart';
import 'package:paciente_citas_1/shared/infrastructure/inputs/email_input.dart';
import 'package:paciente_citas_1/shared/infrastructure/inputs/gender_input.dart';
import 'package:paciente_citas_1/shared/infrastructure/inputs/last_name_input.dart';
import 'package:paciente_citas_1/shared/infrastructure/inputs/name_input.dart';
import 'package:paciente_citas_1/shared/infrastructure/inputs/password_input.dart';
import 'package:paciente_citas_1/shared/infrastructure/inputs/phone_input.dart';
import 'package:paciente_citas_1/shared/infrastructure/inputs/relation_legal_guardian.dart.dart';
import 'package:paciente_citas_1/shared/infrastructure/inputs/username_input.dart';

class FormularioState {
  final Email email_user;
  final Password password_user;
  final Username username_user;
  final Name firstname_user;
  final Lastname lastname_user;
  final Phone phone_user;
  final Address address_user;

  final Cedula cedula_patient;
  final Name firstname_patient;
  final Lastname lastname_patient;
  final Date date_patient;
  final Gender gender_patient;
  final Name guardian_legal_patient;
  final RelationLegalGuardian relation_legal_guardian_patient;
  final Name health_insurance_patient;
  final List<String> type_therapy_required_patient;
  final List<String> disabilities_patient;
  final List<String> allergies_patient;
  final List<String> current_medications_patient;
  final bool isPosting;
  final bool isFormPostedStep1;
  final bool isFormPostedStep2;
  final bool isFormPostedStep3;
  final bool isValid;
  final String errorMessage;
  final String successMessage;

  const FormularioState({
    this.errorMessage = '',
    this.successMessage = '',
    this.email_user = const Email.pure(),
    this.password_user = const Password.pure(),
    this.username_user = const Username.pure(),
    this.firstname_user = const Name.pure(),
    this.lastname_user = const Lastname.pure(),
    this.phone_user = const Phone.pure(),
    this.address_user = const Address.pure(),
    this.cedula_patient = const Cedula.pure(),
    this.firstname_patient = const Name.pure(),
    this.lastname_patient = const Lastname.pure(),
    this.date_patient = const Date.pure(),
    this.gender_patient = const Gender.pure(),
    this.guardian_legal_patient = const Name.pure(),
    this.relation_legal_guardian_patient = const RelationLegalGuardian.pure(),
    this.health_insurance_patient = const Name.pure(),
    this.disabilities_patient = const [],
    this.allergies_patient = const [],
    this.current_medications_patient = const [],
    this.type_therapy_required_patient = const [],
    this.isPosting = false,
    this.isFormPostedStep1 = false,
    this.isFormPostedStep2 = false,
    this.isFormPostedStep3 = false,
    this.isValid = false,
  });

  FormularioState copyWith({
    String? errorMessage,
    String? successMessage,
    Email? email_user,
    Password? password_user,
    Username? username_user,
    Name? firstname_user,
    Lastname? lastname_user,
    Phone? phone_user,
    Address? address_user,
    Cedula? cedula_patient,
    Name? firstname_patient,
    Lastname? lastname_patient,
    Date? date_patient,
    Gender? gender_patient,
    Name? guardian_legal_patient,
    RelationLegalGuardian? relation_legal_guardian_patient,
    Name? health_insurance_patient,
    List<String>? disabilities_patient,
    List<String>? allergies_patient,
    List<String>? current_medications_patient,
    bool? isPosting,
    bool? isFormPostedStep1,
    bool? isFormPostedStep2,
    bool? isFormPostedStep3,
    bool? isValid,
  }) {
    return FormularioState(
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      email_user: email_user ?? this.email_user,
      password_user: password_user ?? this.password_user,
      username_user: username_user ?? this.username_user,
      firstname_user: firstname_user ?? this.firstname_user,
      lastname_user: lastname_user ?? this.lastname_user,
      phone_user: phone_user ?? this.phone_user,
      address_user: address_user ?? this.address_user,
      cedula_patient: cedula_patient ?? this.cedula_patient,
      firstname_patient: firstname_patient ?? this.firstname_patient,
      lastname_patient: lastname_patient ?? this.lastname_patient,
      date_patient: date_patient ?? this.date_patient,
      gender_patient: gender_patient ?? this.gender_patient,
      guardian_legal_patient:
          guardian_legal_patient ?? this.guardian_legal_patient,
      relation_legal_guardian_patient: relation_legal_guardian_patient ??
          this.relation_legal_guardian_patient,
      health_insurance_patient:
          health_insurance_patient ?? this.health_insurance_patient,
      disabilities_patient: disabilities_patient ?? this.disabilities_patient,
      allergies_patient: allergies_patient ?? this.allergies_patient,
      current_medications_patient:
          current_medications_patient ?? this.current_medications_patient,
      isPosting: isPosting ?? this.isPosting,
      isFormPostedStep1: isFormPostedStep1 ?? this.isFormPostedStep1,
      isFormPostedStep2: isFormPostedStep2 ?? this.isFormPostedStep2,
      isFormPostedStep3: isFormPostedStep3 ?? this.isFormPostedStep3,
      isValid: isValid ?? this.isValid,
    );
  }
}

class FormularioNotifier extends StateNotifier<FormularioState> {
  final Function(RequestData) registerUserCallback;
  FormularioNotifier({required this.registerUserCallback})
      : super(const FormularioState());

  void resetState() {
    state = const FormularioState();
  }

  void onEmailUserChanged(String value) {
    final newEmail = Email.dirty(value);
    state = state.copyWith(
      email_user: newEmail,
      isValid: _validateForm(newEmailUser: newEmail),
      isFormPostedStep1: false,
    );
  }

  void onPasswordUserChanged(String value) {
    final newPassword = Password.dirty(value);
    state = state.copyWith(
      password_user: newPassword,
      isValid: _validateForm(newPasswordUser: newPassword),
      isFormPostedStep1: false,
    );
  }

  void onUsernameUserChanged(String value) {
    final newUsername = Username.dirty(value);
    state = state.copyWith(
      username_user: newUsername,
      isValid: _validateForm(newUsernameUser: newUsername),
      isFormPostedStep1: false,
    );
  }

  void onFirstnameUserChanged(String value) {
    final newFirstname = Name.dirty(value);
    state = state.copyWith(
      firstname_user: newFirstname,
      isValid: _validateForm(newFirstnameUser: newFirstname),
      isFormPostedStep1: false,
    );
  }

  void onLastnameUserChanged(String value) {
    final newLastname = Lastname.dirty(value);
    state = state.copyWith(
      lastname_user: newLastname,
      isValid: _validateForm(newLastnameUser: newLastname),
      isFormPostedStep1: false,
    );
  }

  void onPhoneUserChanged(String value) {
    final newPhone = Phone.dirty(value);
    state = state.copyWith(
      phone_user: newPhone,
      isValid: _validateForm(newPhoneUser: newPhone),
      isFormPostedStep1: false,
    );
  }

  void onAddressUserChanged(String value) {
    final newAddress = Address.dirty(value);
    state = state.copyWith(
      address_user: newAddress,
      isValid: _validateForm(newAddressUser: newAddress),
      isFormPostedStep1: false,
    );
  }

  void onCedulaPatientChanged(String value) {
    final newCedula = Cedula.dirty(value);
    state = state.copyWith(
      cedula_patient: newCedula,
      isValid: _validateForm(newCedulaPatient: newCedula),
      isFormPostedStep2: false,
    );
  }

  void onFirstnamePatientChanged(String value) {
    final newFirstname = Name.dirty(value);
    state = state.copyWith(
      firstname_patient: newFirstname,
      isValid: _validateForm(newFirstnamePatient: newFirstname),
      isFormPostedStep2: false,
    );
  }

  void onLastnamePatientChanged(String value) {
    final newLastname = Lastname.dirty(value);
    state = state.copyWith(
      lastname_patient: newLastname,
      isValid: _validateForm(newLastnamePatient: newLastname),
      isFormPostedStep2: false,
    );
  }

  void onDatePatientChanged(String value) {
    final newDate = Date.dirty(value);
    state = state.copyWith(
      date_patient: newDate,
      isValid: _validateForm(newDatePatient: newDate),
      isFormPostedStep2: false,
    );
  }

  void onGenderPatientChanged(String value) {
    final newGenderPatient = Gender.dirty(value);
    state = state.copyWith(
      gender_patient: newGenderPatient,
      isValid: _validateForm(newGenderPatient: newGenderPatient),
      isFormPostedStep2: false,
    );
  }

  void onGuardianLegalPatientChanged(String value) {
    final newGuardianLegalPatient = Name.dirty(value);
    state = state.copyWith(
      guardian_legal_patient: newGuardianLegalPatient,
      isValid: _validateForm(newGuardianLegalPatient: newGuardianLegalPatient),
      isFormPostedStep2: false,
    );
  }

  void onRelationLegalGuardianPatientChanged(String value) {
    final newRelationLegalGuardianPatient = RelationLegalGuardian.dirty(value);
    state = state.copyWith(
      relation_legal_guardian_patient: newRelationLegalGuardianPatient,
      isValid: _validateForm(
          newRelationLegalGuardianPatient: newRelationLegalGuardianPatient),
      isFormPostedStep2: false,
    );
  }

  void onHealthInsurancePatientChanged(String value) {
    final newHealthInsurancePatient = Name.dirty(value);
    state = state.copyWith(
      health_insurance_patient: newHealthInsurancePatient,
      isValid:
          _validateForm(newHealthInsurancePatient: newHealthInsurancePatient),
      isFormPostedStep3: false,
    );
  }

  void onDisabilitiesPatientChanged(List<String> value) {
    state = state.copyWith(disabilities_patient: value);
  }

  void onAllergiesPatientChanged(List<String> value) {
    state = state.copyWith(allergies_patient: value);
  }

  void onCurrentMedicationsPatientChanged(List<String> value) {
    state = state.copyWith(current_medications_patient: value);
  }

  void OnNextPage2() {
    final email_user = Email.dirty(state.email_user.value);
    final password_user = Password.dirty(state.password_user.value);
    final username_user = Username.dirty(state.username_user.value);
    final firstname_user = Name.dirty(state.firstname_user.value);
    final lastname_user = Lastname.dirty(state.lastname_user.value);
    final phone_user = Phone.dirty(state.phone_user.value);
    final address_user = Address.dirty(state.address_user.value);

    final isValid = Formz.validate([
      email_user,
      password_user,
      username_user,
      firstname_user,
      lastname_user,
      phone_user,
      address_user,
    ]);

    if (!isValid) {
      state = state.copyWith(
        email_user: email_user,
        password_user: password_user,
        username_user: username_user,
        firstname_user: firstname_user,
        lastname_user: lastname_user,
        phone_user: phone_user,
        address_user: address_user,
        isValid: false,
        isFormPostedStep1: true,
        isFormPostedStep2: false,
        isFormPostedStep3: false,
      );
      print(state.isValid);
      return;
    }

    state = state.copyWith(
      email_user: email_user,
      password_user: password_user,
      username_user: username_user,
      firstname_user: firstname_user,
      lastname_user: lastname_user,
      phone_user: phone_user,
      address_user: address_user,
      isValid: true,
      isFormPostedStep1: false,
      isFormPostedStep2: false,
      isFormPostedStep3: false,
    );
    print(state.isValid);
    print("Página 2");
  }

  void OnNextPage3() {
    final cedula_patient = Cedula.dirty(state.cedula_patient.value);
    final firstname_patient = Name.dirty(state.firstname_patient.value);
    final lastname_patient = Lastname.dirty(state.lastname_patient.value);
    final date_patient = Date.dirty(state.date_patient.value);
    final gender_patient = Gender.dirty(state.gender_patient.value);
    final guardian_legal_patient =
        Name.dirty(state.guardian_legal_patient.value);
    final relation_legal_guardian_patient = RelationLegalGuardian.dirty(
        state.relation_legal_guardian_patient.value);

    // Primero validamos la cédula
    if (cedula_patient.error != null) {
      state = state.copyWith(
        cedula_patient: cedula_patient,
        isValid: false,
        isFormPostedStep1: false,
        isFormPostedStep2: true,
        isFormPostedStep3: false,
      );
      return;
    }

    final isValid = Formz.validate([
      cedula_patient,
      firstname_patient,
      lastname_patient,
      date_patient,
      gender_patient,
      guardian_legal_patient,
      relation_legal_guardian_patient,
    ]);

    if (!isValid) {
      print("Página 3");
      print(state.isValid);
      state = state.copyWith(
        cedula_patient: cedula_patient,
        isValid: false,
        isFormPostedStep1: false,
        isFormPostedStep2: true,
        isFormPostedStep3: false,
      );
      return;
    }
    state = state.copyWith(
      cedula_patient: cedula_patient,
      firstname_patient: firstname_patient,
      lastname_patient: lastname_patient,
      date_patient: date_patient,
      gender_patient: gender_patient,
      guardian_legal_patient: guardian_legal_patient,
      relation_legal_guardian_patient: relation_legal_guardian_patient,
      isValid: isValid,
      isFormPostedStep1: true,
      isFormPostedStep2: true,
      isFormPostedStep3: false,
    );
  }

  Future<void> onFormSubmit() async {
    _touchEveryField();

    if (!state.isValid) return;

    state =
        state.copyWith(isPosting: true, errorMessage: '', successMessage: '');

    try {
      final userRegister = RequestData(
        createUser: CreateUser(
          role: 'PACIENTE',
          email: state.email_user.value,
          password: state.password_user.value,
          username: state.username_user.value,
          userInformation: UserInformation(
            firstname: state.firstname_user.value,
            lastname: state.lastname_user.value,
            phone: state.phone_user.value,
            address: state.address_user.value,
          ),
        ),
        createPatient: CreatePatient(
          firstname: state.firstname_patient.value,
          lastname: state.lastname_patient.value,
          birthdate: state.date_patient.value,
          legalGuardian: state.guardian_legal_patient.value,
          dni: state.cedula_patient.value,
          disability: state.disabilities_patient,
          allergies: state.allergies_patient,
          currentMedications: state.current_medications_patient,
          gender: state.gender_patient.value,
          relationshipRepresentativePatient:
              state.relation_legal_guardian_patient.value,
          healthInsurance: state.health_insurance_patient.value,
          historyTreatmentsReceived: ["None"],
        ),
      );

      final success = await registerUserCallback(userRegister);

      if (success) {
        state = state.copyWith(
          successMessage: 'Usuario registrado correctamente',
        );
      } else {
        state = state.copyWith(
          errorMessage: '❗ Error al registrar usuario',
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: '❗ Error al registrar usuario',
      );
    } finally {
      state = state.copyWith(isPosting: false);
    }
  }

  void _touchEveryFieldPart1() {
    final email_user = Email.dirty(state.email_user.value);
    final password_user = Password.dirty(state.password_user.value);
    final username_user = Username.dirty(state.username_user.value);
    final firstname_user = Name.dirty(state.firstname_user.value);
    final lastname_user = Lastname.dirty(state.lastname_user.value);
    final phone_user = Phone.dirty(state.phone_user.value);
    final address_user = Address.dirty(state.address_user.value);

    state = state.copyWith(
      isFormPostedStep1: true,
      email_user: email_user,
      password_user: password_user,
      username_user: username_user,
      firstname_user: firstname_user,
      lastname_user: lastname_user,
      phone_user: phone_user,
      address_user: address_user,
      isValid: _validateFormPart1(
        newEmailUser: email_user,
        newPasswordUser: password_user,
        newUsernameUser: username_user,
        newFirstnameUser: firstname_user,
        newLastnameUser: lastname_user,
        newPhoneUser: phone_user,
        newAddressUser: address_user,
      ),
    );
  }

  void clearErrorMessage() {
    state = state.copyWith(errorMessage: '');
  }

  void clearSuccessMessage() {
    state = state.copyWith(successMessage: '');
  }

  void _touchEveryFieldPart2() {
    final cedula_patient = Cedula.dirty(state.cedula_patient.value);
    final firstname_patient = Name.dirty(state.firstname_patient.value);
    final lastname_patient = Lastname.dirty(state.lastname_patient.value);
    final date_patient = Date.dirty(state.date_patient.value);
    final gender_patient = Gender.dirty(state.gender_patient.value);
    final guardian_legal_patient =
        Name.dirty(state.guardian_legal_patient.value);
    final relation_legal_guardian_patient = RelationLegalGuardian.dirty(
        state.relation_legal_guardian_patient.value);

    state = state.copyWith(
      isFormPostedStep2: true,
      cedula_patient: cedula_patient,
      firstname_patient: firstname_patient,
      lastname_patient: lastname_patient,
      date_patient: date_patient,
      gender_patient: gender_patient,
      guardian_legal_patient: guardian_legal_patient,
      relation_legal_guardian_patient: relation_legal_guardian_patient,
      isValid: _validateFormPart2(
        newCedulaPatient: cedula_patient,
        newFirstnamePatient: firstname_patient,
        newLastnamePatient: lastname_patient,
        newDatePatient: date_patient,
        newGenderPatient: gender_patient,
        newGuardianLegalPatient: guardian_legal_patient,
        newRelationLegalGuardianPatient: relation_legal_guardian_patient,
      ),
    );
  }

  void _touchEveryField() {
    final email_user = Email.dirty(state.email_user.value);
    final password_user = Password.dirty(state.password_user.value);
    final username_user = Username.dirty(state.username_user.value);
    final firstname_user = Name.dirty(state.firstname_user.value);
    final lastname_user = Lastname.dirty(state.lastname_user.value);
    final phone_user = Phone.dirty(state.phone_user.value);
    final address_user = Address.dirty(state.address_user.value);
    final cedula_patient = Cedula.dirty(state.cedula_patient.value);
    final firstname_patient = Name.dirty(state.firstname_patient.value);
    final lastname_patient = Lastname.dirty(state.lastname_patient.value);
    final date_patient = Date.dirty(state.date_patient.value);
    final gender_patient = Gender.dirty(state.gender_patient.value);
    final guardian_legal_patient =
        Name.dirty(state.guardian_legal_patient.value);
    final relation_legal_guardian_patient = RelationLegalGuardian.dirty(
        state.relation_legal_guardian_patient.value);
    final health_insurance_patient =
        Name.dirty(state.health_insurance_patient.value);
    final disabilities_patient = state.disabilities_patient ?? [];
    final allergies_patient = state.allergies_patient ?? [];
    final current_medications_patient = state.current_medications_patient ?? [];

    state = state.copyWith(
      isFormPostedStep3: true,
      email_user: email_user,
      password_user: password_user,
      username_user: username_user,
      firstname_user: firstname_user,
      lastname_user: lastname_user,
      phone_user: phone_user,
      address_user: address_user,
      cedula_patient: cedula_patient,
      firstname_patient: firstname_patient,
      lastname_patient: lastname_patient,
      date_patient: date_patient,
      gender_patient: gender_patient,
      guardian_legal_patient: guardian_legal_patient,
      relation_legal_guardian_patient: relation_legal_guardian_patient,
      health_insurance_patient: health_insurance_patient,
      disabilities_patient: disabilities_patient,
      allergies_patient: allergies_patient,
      current_medications_patient: current_medications_patient,
      isValid: _validateForm(
        newEmailUser: email_user,
        newPasswordUser: password_user,
        newUsernameUser: username_user,
        newFirstnameUser: firstname_user,
        newLastnameUser: lastname_user,
        newPhoneUser: phone_user,
        newAddressUser: address_user,
        newCedulaPatient: cedula_patient,
        newFirstnamePatient: firstname_patient,
        newLastnamePatient: lastname_patient,
        newDatePatient: date_patient,
        newGenderPatient: gender_patient,
        newGuardianLegalPatient: guardian_legal_patient,
        newRelationLegalGuardianPatient: relation_legal_guardian_patient,
        newHealthInsurancePatient: health_insurance_patient,
      ),
    );
  }

  bool _validateFormPart1({
    Email? newEmailUser,
    Password? newPasswordUser,
    Username? newUsernameUser,
    Name? newFirstnameUser,
    Lastname? newLastnameUser,
    Phone? newPhoneUser,
    Address? newAddressUser,
  }) {
    return Formz.validate([
      newEmailUser ?? state.email_user,
      newPasswordUser ?? state.password_user,
      newUsernameUser ?? state.username_user,
      newFirstnameUser ?? state.firstname_user,
      newLastnameUser ?? state.lastname_user,
      newPhoneUser ?? state.phone_user,
      newAddressUser ?? state.address_user,
    ]);
  }

  bool _validateFormPart2({
    Cedula? newCedulaPatient,
    Name? newFirstnamePatient,
    Lastname? newLastnamePatient,
    Date? newDatePatient,
    Gender? newGenderPatient,
    Name? newGuardianLegalPatient,
    RelationLegalGuardian? newRelationLegalGuardianPatient,
  }) {
    final cedula = newCedulaPatient ?? state.cedula_patient;
    final firstname = newFirstnamePatient ?? state.firstname_patient;
    final lastname = newLastnamePatient ?? state.lastname_patient;
    final date = newDatePatient ?? state.date_patient;
    final gender = newGenderPatient ?? state.gender_patient;
    final guardian = newGuardianLegalPatient ?? state.guardian_legal_patient;
    final relation = newRelationLegalGuardianPatient ??
        state.relation_legal_guardian_patient;

    // Validar primero la cédula
    if (cedula.error != null) return false;

    return Formz.validate([
      cedula,
      firstname,
      lastname,
      date,
      gender,
      guardian,
      relation,
    ]);
  }

  bool _validateForm({
    Email? newEmailUser,
    Password? newPasswordUser,
    Username? newUsernameUser,
    Name? newFirstnameUser,
    Lastname? newLastnameUser,
    Phone? newPhoneUser,
    Address? newAddressUser,
    Cedula? newCedulaPatient,
    Name? newFirstnamePatient,
    Lastname? newLastnamePatient,
    Date? newDatePatient,
    Gender? newGenderPatient,
    Name? newGuardianLegalPatient,
    RelationLegalGuardian? newRelationLegalGuardianPatient,
    Name? newHealthInsurancePatient,
  }) {
    return Formz.validate([
      newEmailUser ?? state.email_user,
      newPasswordUser ?? state.password_user,
      newUsernameUser ?? state.username_user,
      newFirstnameUser ?? state.firstname_user,
      newLastnameUser ?? state.lastname_user,
      newPhoneUser ?? state.phone_user,
      newAddressUser ?? state.address_user,
      newCedulaPatient ?? state.cedula_patient,
      newFirstnamePatient ?? state.firstname_patient,
      newLastnamePatient ?? state.lastname_patient,
      newDatePatient ?? state.date_patient,
      newGenderPatient ?? state.gender_patient,
      newGuardianLegalPatient ?? state.guardian_legal_patient,
      newRelationLegalGuardianPatient ?? state.relation_legal_guardian_patient,
      newHealthInsurancePatient ?? state.health_insurance_patient,
    ]);
  }
}

final registerFormProvider =
    StateNotifierProvider.autoDispose<FormularioNotifier, FormularioState>(
        (ref) {
  // Usar read en lugar de watch para evitar recreaciones innecesarias
  final registerCallback = ref.read(authProvider.notifier).registerUser;
  final formularioNotifier =
      FormularioNotifier(registerUserCallback: registerCallback);

  // Modificar el listener para que solo se active cuando sea necesario
  ref.listen<AuthState>(authProvider, (previous, next) {
    // Ignorar completamente cualquier cambio durante el registro
    if (next.isRegisterLoading || previous?.isRegisterLoading == true) return;

    // Solo resetear si estamos en notAuthenticated y no hay operación pendiente
    if (next.authStatus == AuthStatus.notAuthenticated &&
        !next.isRegisterLoading &&
        previous?.isRegisterLoading == false &&
        formularioNotifier.state.successMessage.isEmpty) {
      formularioNotifier.resetState();
    }
  });

  return formularioNotifier;
});
