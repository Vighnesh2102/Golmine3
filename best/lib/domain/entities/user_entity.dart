class UserEntity {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final DateTime createdAt;

  UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.createdAt,
  });
}
