import 'package:freezed_annotation/freezed_annotation.dart';
import 'manager_action_mode.dart';

part 'manager_action_form_state.freezed.dart';

/// Single source of truth for all form input across every mode of the
/// Manager Action Sheet V2. Widgets read this; the controller mutates it.
@freezed
class ManagerActionFormState with _$ManagerActionFormState {
  const factory ManagerActionFormState({
    // ── Active mode ──
    @Default(ManagerMode.edit) ManagerMode mode,

    // ── Shared across all modes ──
    @Default('') String note,
    String? localImageUrl,

    // ── Restock + Edit: bucket distribution ──
    @Default(0) int qtyGood,
    @Default(0) int qtyDamaged,
    @Default(0) int qtyMaintenance,
    @Default(0) int qtyLost,
    @Default('') String storageLocation,
    int? locationRegistryId,

    // ── Handover + Reserve: dispatch fields ──
    @Default(1) int quantity,
    @Default('') String recipientName,
    @Default('') String recipientOffice,
    @Default('') String recipientContact,
    @Default('') String approvedBy,
    @Default('') String releasedBy,
    DateTime? expectedReturnDate,
    DateTime? pickupScheduledAt,
    @Default(false) bool isDateReturn,

    // ── Edit: metadata fields ──
    @Default('') String itemName,
    @Default('') String category,
    @Default('') String serial,
    @Default('') String model,
    @Default(0) int targetStock,
    @Default(0) int minStock,

    // ── UI lifecycle ──
    @Default(false) bool isEditLoading,
    @Default(false) bool isSubmitting,
    String? submitError,
  }) = _ManagerActionFormState;
}
