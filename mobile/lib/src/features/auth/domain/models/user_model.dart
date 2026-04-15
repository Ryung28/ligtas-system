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
    @Default([]) List<String> providers, // ['email', 'google', etc]
    String? assignedWarehouse, // warehouse assignment for equipment managers
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  factory UserModel.fromSupabase(Map<String, dynamic> json, [List<String>? providers]) {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      displayName: (json['display_name'] ?? json['full_name'] ?? '?').toString(),
      phoneNumber: (json['phone_number'] ?? '').toString(),
      organization: (json['organization'] ?? json['department'] ?? '').toString(),
      role: (json['role'] ?? 'viewer').toString(),
      status: (json['status'] ?? 'pending').toString(),
      providers: providers ?? [],
      assignedWarehouse: json['assigned_warehouse'] as String?,
    );
  }

  /// Capability Check: Prevent password changes for social/google users
  bool get canChangePassword {
    // If no providers are found, default to true (legacy or email check)
    if (providers.isEmpty) return true;
    
    // Explicitly check for Google/Social providers
    if (providers.contains('google')) return false;
    
    // Return true for email-based accounts
    return providers.contains('email');
  }


  /// User-friendly name accessors
  String get fullName => (displayName != null && displayName!.isNotEmpty && displayName != '?') 
    ? displayName! 
    : 'User';
  
  String get firstName => fullName.split(' ').first;

  /// Check if user has active access
  bool get isActive => status.toLowerCase() == 'active';
  
  /// Check if user is waiting for approval
  bool get isPending => status.toLowerCase() == 'pending';
  
  /// Check if user is suspended/rejected
  bool get isSuspended => status.toLowerCase() == 'suspended';
  
  /// Check if user has admin privileges
  bool get isAdmin => (role.toLowerCase() == 'admin') && isActive;
  
  /// Check if user can edit (admin, editor, or manager variant)
  bool get canEdit {
    final r = role.toLowerCase();
    return (r == 'admin' || 
            r == 'editor' || 
            r == 'manager' || 
            r == 'inventory_manager' || 
            r == 'inventory manager') && isActive;
  }
  
  /// Check if user is equipment manager (editor role)
  bool get isEquipmentManager => role.toLowerCase() == 'editor' && isActive;
  
  /// Check if manager has warehouse assigned
  bool get hasWarehouseAssigned => assignedWarehouse != null && assignedWarehouse!.isNotEmpty;
}
