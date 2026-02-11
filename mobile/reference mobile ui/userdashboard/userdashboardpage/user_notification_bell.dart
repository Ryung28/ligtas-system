import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import 'package:mobileapplication/userdashboard/usercomplaintpage/firestore_service.dart';
import 'package:mobileapplication/userdashboard/banperioidpage/banperiodcalender_page.dart';
import 'package:mobileapplication/userdashboard/ocean_educations_hub.dart';
import 'package:mobileapplication/userdashboard/usercomplaintpage/reusable_complaintpage.dart';

class UserNotificationBell extends StatelessWidget {
  const UserNotificationBell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<int>(
      stream: FirestoreService.getUnreadUserNotificationsCount(user.uid),
      builder: (context, snapshot) {
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.black87,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                onPressed: () => _showNotificationsDialog(context, user.uid),
                tooltip: 'Notifications',
              ),
              if (snapshot.hasData && snapshot.data! > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 10,
                      minHeight: 10,
                    ),
                    child: Text(
                      '${snapshot.data}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 6,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showNotificationsDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => NotificationsDialog(userId: userId),
    );
  }
}

class UserNotificationBellStyled extends StatefulWidget {
  const UserNotificationBellStyled({Key? key}) : super(key: key);

  @override
  State<UserNotificationBellStyled> createState() => _UserNotificationBellStyledState();
}

class _UserNotificationBellStyledState extends State<UserNotificationBellStyled> 
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleNotifications() {
    if (_isExpanded) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
    setState(() => _isExpanded = !_isExpanded);
  }

  void _showOverlay() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _overlayEntry = _createOverlayEntry(user.uid);
    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
  }

  void _removeOverlay() {
    _animationController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  OverlayEntry _createOverlayEntry(String userId) {
    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _toggleNotifications,
        behavior: HitTestBehavior.translucent,
        child: Container(
          color: Colors.black.withOpacity(0),
          child: Stack(
            children: [
              // Backdrop
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
              // Centered notification panel
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: GestureDetector(
                      onTap: () {}, // Prevent taps from closing
                      child: Container(
                        width: MediaQuery.of(context).size.width > 600 
                            ? 480 
                            : MediaQuery.of(context).size.width - 32,
                        height: MediaQuery.of(context).size.height * 0.75,
                        child: _ModernNotificationPanel(
                          userId: userId,
                          onClose: _toggleNotifications,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return CompositedTransformTarget(
      link: _layerLink,
      child: StreamBuilder<int>(
        stream: FirestoreService.getUnreadUserNotificationsCount(user.uid),
        builder: (context, snapshot) {
          final unreadCount = snapshot.data ?? 0;
          final hasNotifications = unreadCount > 0;

          return GestureDetector(
            onTap: _toggleNotifications,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: _isExpanded ? const Color(0xFF1976D2) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isExpanded ? const Color(0xFF1976D2) : Colors.grey[200]!,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isExpanded 
                        ? const Color(0xFF1976D2).withOpacity(0.3)
                        : Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      key: ValueKey(_isExpanded),
                      _isExpanded
                          ? Icons.notifications_active_rounded
                          : (hasNotifications
                              ? Icons.notifications_rounded
                              : Icons.notifications_none_rounded),
                      color: _isExpanded 
                          ? Colors.white
                          : (hasNotifications
                              ? const Color(0xFF1976D2)
                              : Colors.grey[600]),
                      size: 22,
                    ),
                  ),
                  if (hasNotifications && !_isExpanded)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[600],
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            unreadCount > 9 ? '9+' : '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Modern expandable notification panel with premium design
class _ModernNotificationPanel extends StatefulWidget {
  final String userId;
  final VoidCallback onClose;

  const _ModernNotificationPanel({
    required this.userId,
    required this.onClose,
  });

  @override
  State<_ModernNotificationPanel> createState() => _ModernNotificationPanelState();
}

class _ModernNotificationPanelState extends State<_ModernNotificationPanel> {
  bool _showUnreadOnly = false;
  String _sortBy = 'newest';
  Map<String, dynamic>? _selectedNotification;
  String? _selectedNotificationId;

  void _showNotificationDetail(Map<String, dynamic> notification, String notificationId) {
    setState(() {
      _selectedNotification = notification;
      _selectedNotificationId = notificationId;
    });
    
    // Mark as read when viewing details
    final isRead = notification['isRead'] as bool? ?? false;
    if (!isRead) {
      FirestoreService.markUserNotificationAsRead(notificationId);
    }
  }

  void _backToList() {
    setState(() {
      _selectedNotification = null;
      _selectedNotificationId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 40,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _selectedNotification != null
              ? _buildDetailView()
              : Column(
                  children: [
                    _buildModernHeader(),
                    _buildQuickFilters(),
                    Expanded(child: _buildNotificationsList()),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildDetailView() {
    if (_selectedNotification == null) return const SizedBox.shrink();

    final notification = _selectedNotification!;
    final timestamp = notification['createdAt'] as Timestamp?;
    final type = notification['type'] as String? ?? '';
    final title = notification['title'] as String? ?? '';
    final message = notification['message'] as String? ?? '';
    final expandedContent = notification['expandedContent'] as String? ?? '';

    return Column(
      children: [
        // Header with back button
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getNotificationColor(type),
                _getNotificationColor(type).withOpacity(0.8),
              ],
            ),
          ),
          child: Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _backToList,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Notification Details',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (_selectedNotificationId != null) {
                      FirestoreService.deleteUserNotification(_selectedNotificationId!);
                      _backToList();
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.delete_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon and Type Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getNotificationColor(type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _getNotificationIcon(type),
                        color: _getNotificationColor(type),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getNotificationColor(type).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getTypeLabel(type),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _getNotificationColor(type),
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (timestamp != null)
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDetailedTime(timestamp.toDate()),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    fontFamily: 'Inter',
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                // Message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[800],
                      height: 1.6,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                // Expanded Content
                if (expandedContent.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getNotificationColor(type).withOpacity(0.05),
                          _getNotificationColor(type).withOpacity(0.02),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getNotificationColor(type).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: _getNotificationColor(type),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Additional Details',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _getNotificationColor(type),
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          expandedContent,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            height: 1.6,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Action Buttons
                const SizedBox(height: 24),
                _buildActionButtons(type, notification),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(String type, Map<String, dynamic> notification) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.touch_app_rounded, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: 'Close',
                  icon: Icons.close_rounded,
                  color: Colors.grey[600]!,
                  onTap: _backToList,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDetailedTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1976D2),
            const Color(0xFF1976D2).withOpacity(0.8),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                ),
                StreamBuilder<int>(
                  stream: FirestoreService.getUnreadUserNotificationsCount(widget.userId),
                  builder: (context, snapshot) {
                    final unreadCount = snapshot.data ?? 0;
                    return Text(
                      unreadCount > 0 ? '$unreadCount unread' : 'All caught up',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          _buildHeaderButton(
            icon: Icons.done_all_rounded,
            onTap: _markAllAsRead,
            tooltip: 'Mark all read',
          ),
          const SizedBox(width: 8),
          _buildHeaderButton(
            icon: Icons.close_rounded,
            onTap: widget.onClose,
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildFilterChip(
            label: 'Unread',
            icon: Icons.circle,
            isSelected: _showUnreadOnly,
            onTap: () => setState(() => _showUnreadOnly = !_showUnreadOnly),
          ),
          const SizedBox(width: 8),
          _buildSortDropdown(),
          const Spacer(),
          _buildClearAllButton(),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1976D2) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1976D2) : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[700],
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sortBy,
          isDense: true,
          icon: Icon(Icons.arrow_drop_down_rounded, size: 18, color: Colors.grey[700]),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            fontFamily: 'Inter',
          ),
          items: const [
            DropdownMenuItem(value: 'newest', child: Text('Newest')),
            DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
            DropdownMenuItem(value: 'type', child: Text('Type')),
          ],
          onChanged: (value) => setState(() => _sortBy = value!),
        ),
      ),
    );
  }

  Widget _buildClearAllButton() {
    return GestureDetector(
      onTap: _clearAllNotifications,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_sweep_rounded, size: 14, color: Colors.red[600]),
            const SizedBox(width: 4),
            Text(
              'Clear',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.red[600],
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService.getUserNotifications(widget.userId),
      builder: (context, snapshot) {
        // 🔥 FIX: Better error handling - only show error if it's a real error, not just connection issues
        if (snapshot.hasError) {
          debugPrint('❌ Notification stream error: ${snapshot.error}');
          // If we have data, show it even if there's an error (might be a transient issue)
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            final notifications = snapshot.data!.docs;
            final filteredNotifications = _filterAndSortNotifications(notifications);
            if (filteredNotifications.isNotEmpty) {
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                itemCount: filteredNotifications.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final notification = filteredNotifications[index].data() as Map<String, dynamic>;
                  final notificationId = filteredNotifications[index].id;
                  return _buildCompactNotificationCard(notification, notificationId);
                },
              );
            }
          }
          return _buildErrorState();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        final notifications = snapshot.data?.docs ?? [];
        if (notifications.isEmpty) {
          return _buildEmptyState();
        }

        final filteredNotifications = _filterAndSortNotifications(notifications);

        if (filteredNotifications.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          itemCount: filteredNotifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final notification = filteredNotifications[index].data() as Map<String, dynamic>;
            final notificationId = filteredNotifications[index].id;
            return _buildCompactNotificationCard(notification, notificationId);
          },
        );
      },
    );
  }

  List<QueryDocumentSnapshot> _filterAndSortNotifications(List<QueryDocumentSnapshot> notifications) {
    var filtered = notifications.where((doc) {
      if (_showUnreadOnly) {
        final docData = doc.data() as Map<String, dynamic>?;
        final isRead = docData?['isRead'] as bool? ?? false;
        return !isRead;
      }
      return true;
    }).toList();

    // 🔥 FIX: Always sort by createdAt first (newest first) as default, then apply user's sort preference
    filtered.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;

      // First, sort by createdAt (newest first) as primary sort
      final aTime = aData['createdAt'] as Timestamp?;
      final bTime = bData['createdAt'] as Timestamp?;
      int timeComparison = 0;
      if (aTime == null && bTime == null) {
        timeComparison = 0;
      } else if (aTime == null) {
        timeComparison = 1; // null timestamps go to end
      } else if (bTime == null) {
        timeComparison = -1; // null timestamps go to end
      } else {
        timeComparison = bTime.compareTo(aTime); // Descending (newest first)
      }

      // Then apply user's sort preference
      switch (_sortBy) {
        case 'newest':
          return timeComparison; // Already sorted newest first
        case 'oldest':
          return -timeComparison; // Reverse to oldest first
        case 'type':
          final aType = aData['type'] as String? ?? '';
          final bType = bData['type'] as String? ?? '';
          final typeComparison = aType.compareTo(bType);
          // If types are equal, use time as secondary sort
          return typeComparison != 0 ? typeComparison : timeComparison;
        default:
          return timeComparison; // Default to newest first
      }
    });

    return filtered;
  }

  Widget _buildCompactNotificationCard(Map<String, dynamic> notification, String notificationId) {
    final timestamp = notification['createdAt'] as Timestamp?;
    final isRead = notification['isRead'] as bool? ?? false;
    final type = notification['type'] as String? ?? '';
    final title = notification['title'] as String? ?? '';
    final message = notification['message'] as String? ?? '';

    return Dismissible(
      key: Key(notificationId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red[400]!, Colors.red[600]!],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 24),
      ),
      onDismissed: (direction) {
        FirestoreService.deleteUserNotification(notificationId);
      },
      child: GestureDetector(
        onTap: () => _showNotificationDetail(notification, notificationId),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRead ? Colors.grey[200]! : Colors.blue[200]!,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _getNotificationColor(type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getNotificationIcon(type),
                  color: _getNotificationColor(type),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                              color: Colors.black87,
                              fontFamily: 'Inter',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (timestamp != null)
                          Text(
                            _formatTime(timestamp.toDate()),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                              fontFamily: 'Inter',
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.3,
                        fontFamily: 'Inter',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getNotificationColor(type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getTypeLabel(type),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: _getNotificationColor(type),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red[400], size: 48),
            const SizedBox(height: 12),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                _showUnreadOnly
                    ? Icons.done_all_rounded
                    : Icons.notifications_off_outlined,
                color: Colors.grey[400],
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _showUnreadOnly ? 'All caught up!' : 'No notifications',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _showUnreadOnly
                  ? 'You\'ve read all notifications'
                  : 'Notifications will appear here',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Now';
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'ban_period_update':
        return 'Ban Period';
      case 'education_content':
      case 'education_category':
        return 'Education';
      case 'marine_conditions':
        return 'Ocean';
      case 'complaint_status':
        return 'Complaint';
      case 'system_announcement':
        return 'Announcement';
      default:
        return 'Info';
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'ban_period_update':
        return Icons.block_rounded;
      case 'education_content':
      case 'education_category':
        return Icons.menu_book_rounded;
      case 'marine_conditions':
        return Icons.waves_rounded;
      case 'system_announcement':
        return Icons.campaign_rounded;
      case 'complaint_status':
      case 'report_submission':
        return Icons.check_circle_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'ban_period_update':
        return const Color(0xFF2196F3);
      case 'education_content':
      case 'education_category':
        return const Color(0xFF4CAF50);
      case 'marine_conditions':
        return const Color(0xFF00BCD4);
      case 'system_announcement':
        return const Color(0xFFFF9800);
      case 'complaint_status':
        return const Color(0xFFF44336);
      case 'report_submission':
        return const Color(0xFF4CAF50); // Green for success
      default:
        return const Color(0xFF1976D2);
    }
  }

  void _markAllAsRead() async {
    try {
      final unreadNotifications =
          await FirestoreService.getUserNotifications(widget.userId).first;

      for (final doc in unreadNotifications.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (!(data['isRead'] as bool? ?? false)) {
          await FirestoreService.markUserNotificationAsRead(doc.id);
        }
      }
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  void _clearAllNotifications() async {
    try {
      final allNotifications =
          await FirestoreService.getUserNotifications(widget.userId).first;

      for (final doc in allNotifications.docs) {
        await FirestoreService.deleteUserNotification(doc.id);
      }
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }

  void _navigateToNotificationContent(Map<String, dynamic> notification) {
    final String type = notification['type'] as String? ?? '';

    switch (type) {
      case 'ban_period_update':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BanPeriodCalendar(isAdmin: false),
          ),
        );
        break;
      case 'education_content':
      case 'education_category':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const OceanEducationHub(),
          ),
        );
        break;
      case 'complaint_status':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ReusableComplaintPage(),
          ),
        );
        break;
      default:
        break;
    }
  }
}

class NotificationsDialog extends StatefulWidget {
  final String userId;

  const NotificationsDialog({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<NotificationsDialog> createState() => _NotificationsDialogState();
}

class _NotificationsDialogState extends State<NotificationsDialog> {
  bool _showUnreadOnly = false;
  String _sortBy = 'newest'; // newest, oldest, type

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with actions
            _buildHeader(),
            // Filter and sort controls
            _buildControls(),
            // Notifications list
            Expanded(child: _buildNotificationsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF1976D2),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontFamily: 'Inter',
                  ),
                ),
                StreamBuilder<int>(
                  stream: FirestoreService.getUnreadUserNotificationsCount(
                      widget.userId),
                  builder: (context, snapshot) {
                    final unreadCount = snapshot.data ?? 0;
                    return Text(
                      unreadCount > 0 ? '$unreadCount unread' : 'All caught up',
                      style: TextStyle(
                        fontSize: 12,
                        color: unreadCount > 0
                            ? Colors.red[600]
                            : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Compact action buttons
          Row(
            children: [
              _buildCompactActionButton(
                icon: Icons.checklist_rounded,
                tooltip: 'Mark all as read',
                label: 'Read',
                onTap: _markAllAsRead,
              ),
              const SizedBox(width: 6),
              _buildCompactActionButton(
                icon: Icons.clear_all_rounded,
                tooltip: 'Clear all',
                label: 'Clear',
                onTap: _clearAllNotifications,
              ),
              const SizedBox(width: 6),
              _buildCompactActionButton(
                icon: Icons.close_rounded,
                tooltip: 'Close',
                label: 'Close',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactActionButton({
    required IconData icon,
    required String tooltip,
    required String label,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 2),
              Icon(
                icon,
                color: Colors.grey[700],
                size: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Filter toggle
          InkWell(
            onTap: () => setState(() => _showUnreadOnly = !_showUnreadOnly),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _showUnreadOnly
                    ? const Color(0xFF1976D2)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _showUnreadOnly
                      ? const Color(0xFF1976D2)
                      : Colors.grey[300]!,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_list_rounded,
                    size: 14,
                    color: _showUnreadOnly ? Colors.white : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Unread',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _showUnreadOnly ? Colors.white : Colors.grey[600],
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Sort dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sortBy,
                isDense: true,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[700],
                  fontFamily: 'Inter',
                ),
                items: const [
                  DropdownMenuItem(value: 'newest', child: Text('Newest')),
                  DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
                  DropdownMenuItem(value: 'type', child: Text('Type')),
                ],
                onChanged: (value) => setState(() => _sortBy = value!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService.getUserNotifications(widget.userId),
      builder: (context, snapshot) {
        // 🔥 FIX: Better error handling - only show error if it's a real error, not just connection issues
        if (snapshot.hasError) {
          debugPrint('❌ Notification stream error: ${snapshot.error}');
          // If we have data, show it even if there's an error (might be a transient issue)
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            final notifications = snapshot.data!.docs;
            final filteredNotifications = _filterAndSortNotifications(notifications);
            if (filteredNotifications.isNotEmpty) {
              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: filteredNotifications.length,
                separatorBuilder: (context, index) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final notification = filteredNotifications[index].data() as Map<String, dynamic>;
                  final notificationId = filteredNotifications[index].id;
                  return _buildNotificationCard(notification, notificationId);
                },
              );
            }
          }
          return _buildErrorState();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        final notifications = snapshot.data?.docs ?? [];

        if (notifications.isEmpty) {
          return _buildEmptyState();
        }

        // Filter and sort notifications
        final filteredNotifications =
            _filterAndSortNotifications(notifications);

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: filteredNotifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: 6),
          itemBuilder: (context, index) {
            final notification =
                filteredNotifications[index].data() as Map<String, dynamic>;
            final notificationId = filteredNotifications[index].id;
            return _buildNotificationCard(notification, notificationId);
          },
        );
      },
    );
  }

  List<QueryDocumentSnapshot> _filterAndSortNotifications(
      List<QueryDocumentSnapshot> notifications) {
    var filtered = notifications.where((doc) {
      if (_showUnreadOnly) {
        final docData = doc.data() as Map<String, dynamic>?;
        final isRead = docData?['isRead'] as bool? ?? false;
        return !isRead;
      }
      return true;
    }).toList();

    // 🔥 FIX: Always sort by createdAt first (newest first) as default, then apply user's sort preference
    filtered.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;

      // First, sort by createdAt (newest first) as primary sort
      final aTime = aData['createdAt'] as Timestamp?;
      final bTime = bData['createdAt'] as Timestamp?;
      int timeComparison = 0;
      if (aTime == null && bTime == null) {
        timeComparison = 0;
      } else if (aTime == null) {
        timeComparison = 1; // null timestamps go to end
      } else if (bTime == null) {
        timeComparison = -1; // null timestamps go to end
      } else {
        timeComparison = bTime.compareTo(aTime); // Descending (newest first)
      }

      // Then apply user's sort preference
      switch (_sortBy) {
        case 'newest':
          return timeComparison; // Already sorted newest first
        case 'oldest':
          return -timeComparison; // Reverse to oldest first
        case 'type':
          final aType = aData['type'] as String? ?? '';
          final bType = bData['type'] as String? ?? '';
          final typeComparison = aType.compareTo(bType);
          // If types are equal, use time as secondary sort
          return typeComparison != 0 ? typeComparison : timeComparison;
        default:
          return timeComparison; // Default to newest first
      }
    });

    return filtered;
  }

  Widget _buildNotificationCard(
      Map<String, dynamic> notification, String notificationId) {
    final timestamp = notification['createdAt'] as Timestamp?;
    final isRead = notification['isRead'] as bool? ?? false;
    final type = notification['type'] as String? ?? '';
    final title = notification['title'] as String? ?? '';
    final message = notification['message'] as String? ?? '';
    final expandedContent = notification['expandedContent'] as String? ?? '';
    final hasExpandedContent = expandedContent.isNotEmpty;

    print('📋 Building notification card:');
    print('   Title: $title');
    print('   Type: $type');
    print('   Has expanded content: $hasExpandedContent');
    print('   Expanded content length: ${expandedContent.length}');

    return Dismissible(
      key: Key(notificationId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: Colors.red[600],
          size: 24,
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(notificationId);
      },
      onDismissed: (direction) {
        _deleteNotification(notificationId);
      },
      child: _ExpandableNotificationCard(
        notification: notification,
        notificationId: notificationId,
        timestamp: timestamp,
        isRead: isRead,
        type: type,
        title: title,
        message: message,
        expandedContent: expandedContent,
        hasExpandedContent: hasExpandedContent,
        onTap: () =>
            _handleNotificationTap(notification, notificationId, isRead),
        onMarkAsRead: () =>
            FirestoreService.markUserNotificationAsRead(notificationId),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red[400],
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading notifications...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            color: Colors.grey[400],
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            _showUnreadOnly
                ? 'No unread notifications'
                : 'No notifications yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _showUnreadOnly
                ? 'You\'re all caught up!'
                : 'You\'ll see notifications here when they arrive',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'ban_period_update':
        return 'Ban';
      case 'education_content':
      case 'education_category':
        return 'Learn';
      case 'marine_conditions':
        return 'Ocean';
      case 'complaint_status':
        return 'Report';
      case 'system_announcement':
        return 'News';
      default:
        return 'Info';
    }
  }

  void _showSuccessFloatingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green[600],
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Success',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'Inter',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorFloatingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_rounded,
                  color: Colors.red[600],
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Error',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'Inter',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(String notificationId) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Notification'),
            content: const Text(
                'Are you sure you want to delete this notification?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _deleteNotification(String notificationId) async {
    try {
      await FirestoreService.deleteUserNotification(notificationId);
      if (mounted) {
        _showSuccessFloatingDialog('Notification deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        _showErrorFloatingDialog('Failed to delete notification: $e');
      }
    }
  }

  void _markAllAsRead() async {
    try {
      // Get all unread notifications for the user
      final unreadNotifications =
          await FirestoreService.getUserNotifications(widget.userId).first;

      // Mark each unread notification as read
      for (final doc in unreadNotifications.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (!(data['isRead'] as bool? ?? false)) {
          await FirestoreService.markUserNotificationAsRead(doc.id);
        }
      }

      if (mounted) {
        _showSuccessFloatingDialog('All notifications marked as read');
      }
    } catch (e) {
      if (mounted) {
        _showErrorFloatingDialog('Failed to mark notifications as read: $e');
      }
    }
  }

  void _clearAllNotifications() async {
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Clear All Notifications'),
          content: const Text(
            'Are you sure you want to delete all notifications? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Clear All'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Get all notifications for the user
        final allNotifications =
            await FirestoreService.getUserNotifications(widget.userId).first;

        // Delete each notification
        for (final doc in allNotifications.docs) {
          await FirestoreService.deleteUserNotification(doc.id);
        }

        if (mounted) {
          _showSuccessFloatingDialog('All notifications cleared successfully');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorFloatingDialog('Failed to clear notifications: $e');
      }
    }
  }

  void _handleNotificationTap(
      Map<String, dynamic> notification, String notificationId, bool isRead) {
    if (!isRead) {
      FirestoreService.markUserNotificationAsRead(notificationId);
    }
    _navigateToNotificationContent(notification);
    Navigator.pop(context);
  }

  void _navigateToNotificationContent(Map<String, dynamic> notification) {
    final String type = notification['type'] as String? ?? '';
    final String? referenceId = notification['referenceId'] as String?;

    switch (type) {
      case 'ban_period_update':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BanPeriodCalendar(isAdmin: false),
          ),
        );
        break;
      case 'education_content':
      case 'education_category':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const OceanEducationHub(),
          ),
        );
        break;
      case 'complaint_status':
        if (referenceId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReusableComplaintPage(),
            ),
          );
        }
        break;
      default:
        // Stay on dashboard for other types
        break;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'ban_period_update':
        return Icons.block_rounded;
      case 'education_content':
      case 'education_category':
        return Icons.menu_book_rounded;
      case 'marine_conditions':
        return Icons.waves_rounded;
      case 'system_announcement':
        return Icons.campaign_rounded;
      case 'complaint_status':
        return Icons.feedback_rounded;
      case 'status_update':
        return Icons.update_rounded;
      case 'complaint':
        return Icons.report_problem_rounded;
      case 'system':
        return Icons.info_outline_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'ban_period_update':
        return Colors.blueAccent;
      case 'education_content':
      case 'education_category':
        return Colors.greenAccent;
      case 'marine_conditions':
        return Colors.cyanAccent;
      case 'system_announcement':
        return Colors.orangeAccent;
      case 'complaint_status':
        return Colors.redAccent;
      case 'status_update':
        return Colors.greenAccent;
      case 'complaint':
        return Colors.orangeAccent;
      case 'system':
        return Colors.blueAccent;
      default:
        return Colors.white;
    }
  }
}

/// Expandable notification card with clean design
class _ExpandableNotificationCard extends StatefulWidget {
  final Map<String, dynamic> notification;
  final String notificationId;
  final Timestamp? timestamp;
  final bool isRead;
  final String type;
  final String title;
  final String message;
  final String expandedContent;
  final bool hasExpandedContent;
  final VoidCallback onTap;
  final VoidCallback onMarkAsRead;

  const _ExpandableNotificationCard({
    required this.notification,
    required this.notificationId,
    required this.timestamp,
    required this.isRead,
    required this.type,
    required this.title,
    required this.message,
    required this.expandedContent,
    required this.hasExpandedContent,
    required this.onTap,
    required this.onMarkAsRead,
  });

  @override
  State<_ExpandableNotificationCard> createState() =>
      _ExpandableNotificationCardState();
}

class _ExpandableNotificationCardState
    extends State<_ExpandableNotificationCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    print(
        '🔄 Toggling notification expansion: $_isExpanded -> ${!_isExpanded}');
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
        print('📖 Expanding notification content');
      } else {
        _animationController.reverse();
        print('📕 Collapsing notification content');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // If has expanded content, toggle expansion instead of navigating
        // Only navigate if already expanded or no expanded content
        if (widget.hasExpandedContent && !_isExpanded) {
          _toggleExpanded();
        } else {
          widget.onTap();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isRead ? Colors.white : Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isRead ? Colors.grey[200]! : Colors.blue[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with icon, content, and expand button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Clean notification icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(widget.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getNotificationIcon(widget.type),
                    color: _getNotificationColor(widget.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and time row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: widget.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w600,
                                color: Colors.black87,
                                height: 1.2,
                                fontFamily: 'Inter',
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (widget.timestamp != null)
                            Text(
                              _formatTime(widget.timestamp!.toDate()),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Inter',
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Message preview
                      Text(
                        widget.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.3,
                          fontFamily: 'Inter',
                        ),
                        maxLines: _isExpanded ? null : 2,
                        overflow: _isExpanded ? null : TextOverflow.ellipsis,
                      ),
                      // Show "Tap to expand" hint for notifications with expanded content
                      if (widget.hasExpandedContent && !_isExpanded) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: Colors.blue[600],
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Tap arrow to see full details',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue[600],
                                fontStyle: FontStyle.italic,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Expand button (only if has expanded content)
                if (widget.hasExpandedContent) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      print('🎯 Expand button tapped!');
                      _toggleExpanded();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey[700],
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // Expanded content
            if (widget.hasExpandedContent)
              SizeTransition(
                sizeFactor: _expandAnimation,
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Colors.grey[600],
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Full Details',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.expandedContent,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.4,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 8),

            // Footer with type badge and read status
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getNotificationColor(widget.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getTypeLabel(widget.type),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getNotificationColor(widget.type),
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                const Spacer(),
                // Mark as read button (only for unread notifications)
                if (!widget.isRead)
                  InkWell(
                    onTap: widget.onMarkAsRead,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            color: Colors.blue[700],
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Mark Read',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue[700],
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Read indicator
                if (widget.isRead)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green[700],
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Read',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.green[700],
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'ban_period_update':
        return 'Ban Period';
      case 'education_content':
      case 'education_category':
        return 'Education';
      case 'marine_conditions':
        return 'Ocean';
      case 'complaint_status':
        return 'Complaint';
      case 'system_announcement':
        return 'Announcement';
      default:
        return 'Notification';
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'ban_period_update':
        return Icons.block_rounded;
      case 'education_content':
      case 'education_category':
        return Icons.menu_book_rounded;
      case 'marine_conditions':
        return Icons.waves_rounded;
      case 'system_announcement':
        return Icons.campaign_rounded;
      case 'complaint_status':
        return Icons.feedback_rounded;
      case 'status_update':
        return Icons.update_rounded;
      case 'complaint':
        return Icons.report_problem_rounded;
      case 'system':
        return Icons.info_outline_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'ban_period_update':
        return Colors.blueAccent;
      case 'education_content':
      case 'education_category':
        return Colors.greenAccent;
      case 'marine_conditions':
        return Colors.cyanAccent;
      case 'system_announcement':
        return Colors.orangeAccent;
      case 'complaint_status':
        return Colors.redAccent;
      case 'status_update':
        return Colors.greenAccent;
      case 'complaint':
        return Colors.orangeAccent;
      case 'system':
        return Colors.blueAccent;
      default:
        return Colors.white;
    }
  }
}
