import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const UserModel._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserModel({
    required String id,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? organization,
    @Default('viewer') String role, // admin, editor, viewer
    @Default('pending') String status, // pending, active, suspended
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  factory UserModel.fromSupabase(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['display_name'] as String? ?? json['full_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      organization: json['organization'] as String? ?? json['department'] as String?,
      role: json['role'] as String? ?? 'viewer',
      status: json['status'] as String? ?? 'pending',
    );
  }

  /// Check if user has active access
  bool get isActive => status == 'active';
  
  /// Check if user is waiting for approval
  bool get isPending => status == 'pending';
  
  /// Check if user is suspended/rejected
  bool get isSuspended => status == 'suspended';
  
  /// Check if user has admin privileges
  bool get isAdmin => role == 'admin' && isActive;
  
  /// Check if user can edit (admin or editor)
  bool get canEdit => (role == 'admin' || role == 'editor') && isActive;
}
