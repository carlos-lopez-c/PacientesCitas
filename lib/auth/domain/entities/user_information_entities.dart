class UserInformationEntity {
  final String id;
  final String firstName;
  final String lastName;
  final String address;
  final String? phone;
  final String? email;

  UserInformationEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.address,
    this.phone,
    this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'firstname': firstName,
      'lastname': lastName,
      'address': address,
      'phone': phone,
      'email': email,
    };
  }
}
