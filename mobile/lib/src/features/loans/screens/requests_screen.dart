import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/app_theme.dart';
import '../models/loan_model.dart';
import '../providers/loan_providers.dart';
import '../providers/loan_filter_provider.dart';

class RequestsScreen extends ConsumerStatefulWidget {
  const RequestsScreen({super.key});

  @override
  ConsumerState<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends ConsumerState<RequestsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch pending requests (Now centralized in loan_providers)
    final pendingRequests = ref.watch(myPendingItemsProvider);
    final allLoansAsync = ref.watch(myBorrowedItemsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Light background
      body: Stack(
        children: [
          // ── Layer 1: Ambient Background ──
          const _RequestsBackground(),
          
          // ── Layer 2: Main Content ──
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Requests',
                            style: TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w800,
                              fontSize: 34,
                              color: AppTheme.neutralGray900.withOpacity(0.9),
                              letterSpacing: -1.0,
                            ),
                          ),
                          Text(
                            'Pending admin approval',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _GlassSearchBar(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() => _searchQuery = val.toLowerCase());
                      ref.read(loanFilterProvider.notifier).updateQuery(val);
                    },
                  ),
                ),

                const Gap(24),

                // List of Requests
                Expanded(
                  child: allLoansAsync.when(
                    data: (_) {
                      if (pendingRequests.isEmpty) {
                        return _buildEmptyState();
                      }
                      
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                        physics: const BouncingScrollPhysics(),
                        itemCount: pendingRequests.length,
                        itemBuilder: (context, index) {
                          return _RequestCard(request: pendingRequests[index])
                             .animate()
                             .fadeIn(duration: 400.ms, delay: (50 * index).ms)
                             .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                    error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[300]),
          ),
          const Gap(20),
          Text(
            _searchQuery.isNotEmpty ? 'No requests found' : 'No pending requests',
            style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const Gap(8),
          Text(
            'Borrow items from the inventory\nto see them here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final LoanModel request;

  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.hourglass_empty_rounded, color: AppTheme.warningAmber, size: 28),
            ),
            const Gap(16),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.itemName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.4,
                    ),
                  ),
                  const Gap(4),
                  Row(
                    children: [
                      Text(
                        'Qty: ${request.quantityBorrowed}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w600),
                      ),
                      const Gap(8),
                      Container(width: 4, height: 4, decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle)),
                      const Gap(8),
                      Text(
                        request.purpose,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.warningAmber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text(
                'PENDING',
                style: TextStyle(
                  color: AppTheme.warningAmber,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _GlassSearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.6)),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Search requests...',
              hintStyle: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500),
              prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[600]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestsBackground extends StatelessWidget {
  const _RequestsBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blue Blob
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFE3F2FD).withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Amber/Gold Blob (for "Pending")
        Positioned(
          bottom: -50,
          left: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFFF8E1).withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Mesh Blur
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }
}
