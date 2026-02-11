class UserModel {
  final String id;
  final String? email;
  final String? displayName;
  final String? phoneNumber;
  final String? organization;

  const UserModel({
    required this.id,
    this.email,
    this.displayName,
    this.phoneNumber,
    this.organization,
  });

  factory UserModel.fromSupabase(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      organization: json['organization'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'phone_number': phoneNumber,
      'organization': organization,
    };
  }
}
