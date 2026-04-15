import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/features_v2/loans/presentation/providers/loan_provider.dart';
import 'package:mobile/src/features_v2/chat/presentation/screens/chat_screen.dart';
import 'package:mobile/src/features_v2/chat/presentation/providers/chat_providers.dart';
import 'package:mobile/src/core/design_system/widgets/app_toast.dart';

class ChatRoomsList extends ConsumerWidget {
  final VoidCallback? onRoomTap;

  const ChatRoomsList({
    super.key,
    this.onRoomTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLoans = ref.watch(myActiveItemsProvider);
    final pendingLoans = ref.watch(myPendingItemsProvider);
    final overdueLoans = ref.watch(myOverdueItemsProvider);
    
    final allRooms = [...activeLoans, ...pendingLoans, ...overdueLoans];

    if (allRooms.isEmpty) {
      return const Center(
        child: Text(
          'No active conversations yet.',
          style: TextStyle(color: AppTheme.neutralGray500),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: allRooms.length,
      itemBuilder: (context, index) {
        final loan = allRooms[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () async {
              // 1. Trigger optional callback (e.g., to close drawer)
              onRoomTap?.call();
              
              // 2. Fetch room ID
              final roomId = await ref.read(chatRepositoryProvider).getRoomIdForLoan(int.parse(loan.id));
              
              if (roomId != null && context.mounted) {
                // 3. Navigate to Chat
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      roomId: roomId,
                      title: loan.itemName,
                    ),
                  ),
                );
              } else if (context.mounted) {
                AppToast.showError(context, 'Chat channel not ready yet.');
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Icon(Icons.shield_rounded, color: AppTheme.primaryBlue),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loan.itemName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          'Coordinating for ${loan.itemCode}',
                          style: TextStyle(
                            color: AppTheme.neutralGray500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.neutralGray300),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
      },
    );
  }
}
