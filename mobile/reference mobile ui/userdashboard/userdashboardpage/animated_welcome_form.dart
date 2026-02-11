import 'package:flutter/material.dart';
import 'package:mobileapplication/userdashboard/userdashboardpage/user_notification_bell.dart';
import 'package:mobileapplication/userdashboard/config/user_dashboard_fonts.dart';
import 'package:mobileapplication/userdashboard/usersettingsv2/usersettings_provider_v2.dart';
import 'package:provider/provider.dart';

/// Enhanced animated welcome form with modern UI/UX
class AnimatedWelcomeForm extends StatefulWidget {
  final String userName;
  final bool isLoading;
  final String? userPhotoUrl;
  final String currentQuote;

  const AnimatedWelcomeForm({
    super.key,
    required this.userName,
    required this.isLoading,
    this.userPhotoUrl,
    required this.currentQuote,
  });

  @override
  State<AnimatedWelcomeForm> createState() => _AnimatedWelcomeFormState();
}

class _AnimatedWelcomeFormState extends State<AnimatedWelcomeForm>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _quoteController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _quoteAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  @override
  void didUpdateWidget(AnimatedWelcomeForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If quote changed from empty to non-empty, start quote animation
    if (oldWidget.currentQuote.isEmpty && widget.currentQuote.isNotEmpty) {
      _startQuoteAnimation();
    }
  }

  void _initializeAnimations() {
    // Main container animation
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Quote animation
    _quoteController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Main animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    ));

    // Quote animation
    _quoteAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _quoteController,
      curve: Curves.easeOut,
    ));
  }

  void _startAnimations() {
    // Start main animation
    _mainController.forward();

    // Start quote animation after a delay
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted && widget.currentQuote.isNotEmpty) {
        _quoteController.forward();
      }
    });
  }

  void _startQuoteAnimation() {
    if (mounted && widget.currentQuote.isNotEmpty) {
      _quoteController.reset();
      _quoteController.forward();
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _quoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final hour = now.hour;

    final settingsProvider =
        Provider.of<SettingsProviderV2>(context, listen: true);
    final themeColors = settingsProvider.getCurrentThemeColors(isDarkMode);

    // Theme-based colors for gradient background
    final Color gradientStart = themeColors['gradientStart']!;
    final Color gradientEnd = themeColors['gradientEnd']!;

    // Personalized greeting based on time of day
    String getTimeBasedGreeting() {
      if (hour < 12) return 'Good morning';
      if (hour < 17) return 'Good afternoon';
      return 'Good evening';
    }

    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [gradientStart, gradientEnd],
                    stops: const [0.0, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: gradientStart.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 2),
                      spreadRadius: -1,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Decorative background elements (smaller)
                      Positioned(
                        top: -30,
                        right: -30,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -20,
                        left: -20,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.04),
                          ),
                        ),
                      ),
                      // Main content
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header row with avatar and greeting
                            _buildHeaderSection(
                              getTimeBasedGreeting(),
                              gradientStart,
                            ),

                            // Inspirational quote section
                            if (widget.currentQuote.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildQuoteSection(),
                            ] else ...[
                              // Show placeholder or loading state for quotes
                              const SizedBox(height: 12),
                              _buildQuotePlaceholder(),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(String greeting, Color gradientStart) {
    return Semantics(
      label: 'User profile section with greeting and status',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Enhanced avatar with animation-ready container
          Hero(
            tag: 'user_avatar',
            child: Semantics(
              label: 'User profile picture',
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  backgroundImage: widget.userPhotoUrl != null &&
                          widget.userPhotoUrl!.isNotEmpty
                      ? NetworkImage(widget.userPhotoUrl!)
                      : null,
                  child: widget.userPhotoUrl == null ||
                          widget.userPhotoUrl!.isEmpty
                      ? Icon(
                          Icons.person_rounded,
                          color: gradientStart,
                          size: 24,
                        )
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time-based greeting
                Semantics(
                  label: 'Time-based greeting',
                  child: Text(
                    greeting,
                    style: UserDashboardFonts.bodyTextMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                // User name with enhanced typography
                Semantics(
                  label: 'User name',
                  child: Text(
                    widget.isLoading ? 'Loading...' : widget.userName,
                    style: UserDashboardFonts.titleTextBold.copyWith(
                      color: Colors.white,
                      height: 1.1,
                      fontSize: 18,
                      letterSpacing: 0.2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                // Status indicator
                Semantics(
                  label: 'User status: Active',
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF4ADE80), // Green for active
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Active',
                        style: UserDashboardFonts.smallText.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Enhanced notification bell
          const UserNotificationBellStyled(),
        ],
      ),
    );
  }

  Widget _buildQuoteSection() {
    return AnimatedBuilder(
      animation: _quoteAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 15 * (1 - _quoteAnimation.value)),
          child: Opacity(
            opacity: _quoteAnimation.value,
            child: Semantics(
              label: 'Inspirational quote',
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.format_quote_rounded,
                        color: Colors.white.withOpacity(0.9),
                        size: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.currentQuote,
                        style: UserDashboardFonts.bodyTextMedium.copyWith(
                          color: Colors.white.withOpacity(0.95),
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                          fontSize: 11,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuotePlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.format_quote_rounded,
              color: Colors.white.withOpacity(0.5),
              size: 12,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Loading inspirational quote...',
              style: UserDashboardFonts.bodyTextMedium.copyWith(
                color: Colors.white.withOpacity(0.6),
                fontStyle: FontStyle.italic,
                height: 1.4,
                fontSize: 11,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
