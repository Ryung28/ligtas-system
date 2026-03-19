import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'borrow_repository.dart';

class BorrowScreen extends ConsumerWidget {
  const BorrowScreen({super.key});

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              // Constraint: Asymmetrical Geometry using specific Radius.circular(24)
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              // Constraint: Soft Neumorphism with EXACTLY 0.05-0.08 opacity, blurRadius 24, offset 0,8
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06), // Set to exactly 0.06
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Error Initializing Request',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Dismiss'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Borrow Equipment')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Initiate Pre-Borrow',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // Call restricted to Presentation layer via Riverpod provider -> Repository
                    await ref.read(borrowRepositoryProvider).submitPreBorrowRequest({
                      'item_name': 'Projector A',
                      'quantity': 1,
                    });
                    
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Request submitted successfully')),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    // Provide the user with the structured and typed repository exception
                    _showErrorDialog(context, e.toString());
                  }
                },
                child: const Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
