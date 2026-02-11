import 'package:flutter/material.dart';
import '../../../core/design_system/app_theme.dart';
import '../../../core/design_system/app_spacing.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutralGray50,
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 80,
              color: AppTheme.neutralGray300,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No new notifications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.neutralGray600,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Check back later for updates on your requests',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.neutralGray500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
