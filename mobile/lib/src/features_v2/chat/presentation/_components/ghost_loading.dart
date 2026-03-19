import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart';

// =============================================================================
// GhostLoading
// ─────────────────────────────────────────────────────────────────────────────
// Extracted from chat_screen.dart. Organism-level loading skeleton.
// Renders a shimmer layout matching the chat screen structure.
// =============================================================================

class GhostLoading extends StatelessWidget {
  const GhostLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Shimmer.fromColors(
        baseColor: const Color(0xFFF1F5F9),
        highlightColor: Colors.white,
        child: Column(
          children: [
            // Header Mock
            Container(
              height: 70,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(8),
                ),
              ),
            ),
            const Gap(24),
            // Bubble Mocks
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 6,
                itemBuilder: (context, index) {
                  final isMe = index % 2 == 0;
                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      width: 150 + (index * 20).toDouble(),
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft:
                              isMe ? const Radius.circular(16) : Radius.zero,
                          bottomRight:
                              isMe ? Radius.zero : const Radius.circular(16),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Input Mock
            Container(
              height: 80,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
