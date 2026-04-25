import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/notification_status_provider.dart';
import '../../../../src/core/design_system/app_theme.dart';

class SyncErrorBanner extends ConsumerWidget {
  const SyncErrorBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 📡 Watch the bridged provider
    final status = ref.watch(notificationSyncStatusProvider);

    // Only show if there's a problem or we're currently retrying
    if (status.isSynced && !status.isRetrying) {
      return const SizedBox.shrink();
    }

    final color = status.isRetrying ? AppTheme.primaryBlue : Colors.redAccent;
    final icon = status.isRetrying ? Icons.sync_rounded : Icons.warning_amber_rounded;
    final message = status.isRetrying 
      ? "Registering notifications..." 
      : (status.errorMessage ?? "Notification setup failed");

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          if (!status.isRetrying)
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          if (status.isRetrying)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBlue),
            )
          else
            Icon(icon, color: color, size: 20),
            
          const Gap(14),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                if (!status.isRetrying)
                  const Text(
                    "You may miss important alerts until this is fixed.",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          
          if (!status.isRetrying)
            Material(
              color: color,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () {
                  // Trigger the "Scenario B" repair logic
                  ref.read(notificationSyncStatusProvider.notifier).retrySync();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Text(
                    "RETRY",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ).animate().slideY(begin: -0.2, end: 0).fadeIn();
  }
}
