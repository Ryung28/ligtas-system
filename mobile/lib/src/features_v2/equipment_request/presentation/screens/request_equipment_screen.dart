import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/src/features/navigation/providers/navigation_provider.dart';
import 'package:mobile/src/features_v2/loans/presentation/providers/borrow_request_provider.dart';
import 'package:mobile/src/features_v2/loans/presentation/providers/borrow_request_state.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/mission_cart_provider.dart';
import 'package:mobile/src/features_v2/equipment_request/presentation/components/request_form_step.dart';
import 'package:mobile/src/features_v2/equipment_request/presentation/components/request_review_step.dart';
import 'package:mobile/src/features_v2/equipment_request/presentation/widgets/tactile_buttons.dart';

class _NoGlowBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
}

class RequestEquipmentScreen extends ConsumerStatefulWidget {
  final List<CartItem>? cartItems;
  const RequestEquipmentScreen({super.key, this.cartItems});

  @override
  ConsumerState<RequestEquipmentScreen> createState() => _RequestEquipmentScreenState();
}

class _RequestEquipmentScreenState extends ConsumerState<RequestEquipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _contactController;
  late final TextEditingController _emailController;
  late final TextEditingController _officeController;
  late final TextEditingController _purposeController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _contactController = TextEditingController(text: user?.phoneNumber ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _officeController = TextEditingController(text: user?.organization ?? 'CDRRMO');
    _purposeController = TextEditingController();

    Future.microtask(() {
      if (mounted) {
        ref.read(isDockSuppressedProvider.notifier).state = true;
        if (widget.cartItems != null && widget.cartItems!.isNotEmpty) {
          ref.read(borrowRequestNotifierProvider.notifier).reset();
          ref.read(borrowRequestNotifierProvider.notifier).initiateWithCart(widget.cartItems!);
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _officeController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;
    final requestState = ref.watch(borrowRequestNotifierProvider);
    final notifier = ref.read(borrowRequestNotifierProvider.notifier);

    ref.listen(borrowRequestNotifierProvider, (prev, next) {
      if (prev?.isSuccess != true && next.isSuccess) {
        context.pop();
        ref.read(isDockSuppressedProvider.notifier).state = false;
      }
    });

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) ref.read(isDockSuppressedProvider.notifier).state = false;
      },
      child: Scaffold(
        backgroundColor: sentinel.surface,
        body: ScrollConfiguration(
          behavior: _NoGlowBehavior(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
            physics: const BouncingScrollPhysics(),
            child: requestState.currentStep == BorrowStep.review
                ? RequestReviewStep(state: requestState, notifier: notifier)
                : RequestFormStep(
                    formKey: _formKey,
                    nameController: _nameController,
                    contactController: _contactController,
                    emailController: _emailController,
                    officeController: _officeController,
                    purposeController: _purposeController,
                    state: requestState,
                    notifier: notifier,
                  ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: ReviewButton(
              text: requestState.currentStep == BorrowStep.review
                  ? (requestState.isSubmitting ? 'PROCESSING...' : 'SUBMIT REQUEST')
                  : 'REVIEW DETAILS',
              isLoading: requestState.isSubmitting,
              onPressed: () => _handlePrimaryAction(requestState, notifier),
            ),
          ),
        ),
        floatingActionButton: requestState.submissionError != null
            ? _buildErrorOverlay(requestState.submissionError!)
            : null,
      ),
    );
  }

  void _handlePrimaryAction(BorrowRequestState state, BorrowRequestNotifier notifier) {
    if (state.currentStep == BorrowStep.review) {
      notifier.submitRequest();
    } else {
      if (_formKey.currentState!.validate()) {
        notifier.updateBorrowerName(_nameController.text);
        notifier.updateBorrowerContact(_contactController.text);
        notifier.updateBorrowerEmail(_emailController.text);
        notifier.updateBorrowerOrganization(_officeController.text);
        notifier.updatePurpose(_purposeController.text);
        notifier.proceedToReview();
      }
    }
  }

  Widget _buildErrorOverlay(String error) {
    return Positioned(
      top: 100, left: 24, right: 24,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
        child: Text(error, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
