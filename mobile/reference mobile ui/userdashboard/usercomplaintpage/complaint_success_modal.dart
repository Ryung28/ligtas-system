import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mobileapplication/userdashboard/config/user_dashboard_fonts.dart';

class ComplaintSuccessModal extends StatelessWidget {
  final String complaintNumber;
  final VoidCallback? onDismissed;

  const ComplaintSuccessModal({
    super.key,
    required this.complaintNumber,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color successColor =
        isDark ? const Color(0xFF00D0B5) : const Color(0xFF00A896);
    final Color backgroundColor =
        isDark ? const Color(0xFF1A2436) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF0E1C36);
    final Color subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = kIsWeb && screenSize.width > 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
          horizontal: isLargeScreen ? 40.0 : 16.0, vertical: 24.0),
      child: Container(
        width: isLargeScreen ? 500 : double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Success animation
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: successColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.checkmark_seal_fill,
                color: successColor,
                size: 56,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Report Successfully Submitted!',
              style: UserDashboardFonts.titleTextBold.copyWith(
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'Thank you for reporting this incident. Your report has been received and will be reviewed by our marine protection team.',
              textAlign: TextAlign.center,
              style: UserDashboardFonts.largeText.copyWith(
                color: subtitleColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Report number section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF1E293B),
                          const Color(0xFF334155),
                        ]
                      : [
                          const Color(0xFFF0F7FF),
                          const Color(0xFFE0F2FE),
                        ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF3F8CFF).withOpacity(0.3)
                      : const Color(0xFF005CB8).withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark
                            ? const Color(0xFF3F8CFF)
                            : const Color(0xFF005CB8))
                        .withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.doc_text_fill,
                        size: 20,
                        color: isDark
                            ? const Color(0xFF3F8CFF)
                            : const Color(0xFF005CB8),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Report Reference ID',
                        style: UserDashboardFonts.bodyTextMedium.copyWith(
                          color: isDark
                              ? const Color(0xFF3F8CFF)
                              : const Color(0xFF005CB8),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF3F8CFF).withOpacity(0.2)
                            : const Color(0xFF005CB8).withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SelectableText(
                          complaintNumber,
                          style: UserDashboardFonts.extraLargeTextSemiBold
                              .copyWith(
                            color: textColor,
                            letterSpacing: 2,
                            fontFamily: 'Courier',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF3F8CFF)
                                : const Color(0xFF005CB8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(
                              CupertinoIcons.doc_on_clipboard,
                              size: 18,
                              color: Colors.white,
                            ),
                            tooltip: 'Copy Reference ID',
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: complaintNumber));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.checkmark_alt,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Reference ID copied to clipboard',
                                        style: UserDashboardFonts.smallText,
                                      ),
                                    ],
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: successColor,
                                  duration: const Duration(seconds: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Keep this reference ID for tracking your report status',
                    textAlign: TextAlign.center,
                    style: UserDashboardFonts.smallText.copyWith(
                      color: subtitleColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // What happens next section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF1E293B) : const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.clock_fill,
                        size: 20,
                        color: isDark
                            ? const Color(0xFF3F8CFF)
                            : const Color(0xFF005CB8),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Next Steps',
                        style: UserDashboardFonts.largeTextSemiBold.copyWith(
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStepItem(
                    '1',
                    'Initial Review',
                    'Our marine protection team will review your report within 24 hours.',
                    isDark,
                    textColor,
                    subtitleColor,
                  ),
                  const SizedBox(height: 8),
                  _buildStepItem(
                    '2',
                    'Investigation',
                    'If needed, our team will conduct a thorough investigation of the incident.',
                    isDark,
                    textColor,
                    subtitleColor,
                  ),
                  const SizedBox(height: 8),
                  _buildStepItem(
                    '3',
                    'Status Updates',
                    'You can track your report status in the "My Reports" section of your dashboard.',
                    isDark,
                    textColor,
                    subtitleColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Note to click button
            Text(
              'Thank you for helping protect our marine environment!',
              textAlign: TextAlign.center,
              style: UserDashboardFonts.bodyText.copyWith(
                fontStyle: FontStyle.italic,
                color: subtitleColor,
              ),
            ),

            const SizedBox(height: 20),

            // Dismiss button - updated to be more prominent
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (onDismissed != null) onDismissed!();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: isDark
                      ? const Color(0xFF3F8CFF)
                      : const Color(0xFF005CB8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  shadowColor: (isDark
                          ? const Color(0xFF3F8CFF)
                          : const Color(0xFF005CB8))
                      .withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.house_fill,
                      size: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Return to Dashboard',
                      style: UserDashboardFonts.largeTextSemiBold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem(
    String stepNumber,
    String title,
    String description,
    bool isDark,
    Color textColor,
    Color subtitleColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF3F8CFF) : const Color(0xFF005CB8),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: UserDashboardFonts.smallText.copyWith(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: UserDashboardFonts.bodyTextMedium.copyWith(
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: UserDashboardFonts.smallText.copyWith(
                  color: subtitleColor,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
