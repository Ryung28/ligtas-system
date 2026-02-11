// ignore_for_file: use_super_parameters, deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:mobileapplication/userdashboard/usercomplaintpage/reusable_complaintpage.dart';
import 'package:provider/provider.dart';
import 'package:mobileapplication/providers/navigation_provider.dart';
import 'package:mobileapplication/userdashboard/usercomplaintpage/enhanced_complaint_provider.dart';
import 'package:mobileapplication/userdashboard/config/user_dashboard_fonts.dart';

class ComplaintPage extends StatefulWidget {
  const ComplaintPage({Key? key}) : super(key: key);

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  late EnhancedComplaintProvider _complaintProvider;

  @override
  void initState() {
    super.initState();
    _complaintProvider = EnhancedComplaintProvider();

    // Initialize navigation provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final navigationProvider =
            Provider.of<NavigationProvider>(context, listen: false);
        navigationProvider.initialize();
      }
    });
  }

  @override
  void dispose() {
    _complaintProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final Size screenSize = MediaQuery.of(context).size;

    // Enhanced premium color palette for marine theme
    final Color primaryBlue = isLightTheme
        ? const Color(0xFF005CB8) // Deep blue for light mode
        : const Color(0xFF3F8CFF); // Bright blue for dark mode

    final Color accentBlue = isLightTheme
        ? const Color(0xFF1E88E5) // Medium blue for light mode
        : const Color(0xFF64B5F6); // Lighter blue for dark mode

    final Color secondaryAccentColor = isLightTheme
        ? const Color(0xFF039BE5) // Light blue for light mode
        : const Color(0xFF26A69A); // Teal for dark mode

    final Color backgroundColor = isLightTheme
        ? const Color(
            0xFFF0F7FF) // Light background - slightly more premium tone
        : const Color(0xFF0A192F); // Dark background - deep navy

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark, // Dark (black) icons
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      // Simple and reliable: No back button handling here - MainAppShell handles it
      // This prevents conflicts and black screen issues
      child: ChangeNotifierProvider.value(
        value: _complaintProvider,
        child: Scaffold(
          backgroundColor: Colors.white, // White background
          extendBody: true, // Ensure body extends behind the custom nav bar
          body: Stack(
            children: [
              // Base background color
              Container(
                height: screenSize.height,
                width: screenSize.width,
                color: backgroundColor,
              ),

              // Simplified static wave-like gradient background
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: screenSize.height * 0.65, // Same height as before
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isLightTheme
                          ? [
                              backgroundColor
                                  .withOpacity(0.0), // Fade from transparent
                              accentBlue.withOpacity(0.1),
                              primaryBlue.withOpacity(0.2),
                            ]
                          : [
                              backgroundColor
                                  .withOpacity(0.0), // Fade from transparent
                              accentBlue.withOpacity(0.15),
                              primaryBlue.withOpacity(0.25),
                            ],
                      stops: const [
                        0.0,
                        0.5,
                        1.0
                      ], // Adjust stops for desired effect
                    ),
                  ),
                ),
              ),

              // Subtle blended circles for modern look - top right
              Positioned(
                top: -screenSize.width * 0.15,
                right: -screenSize.width * 0.15,
                child: Container(
                  width: screenSize.width * 0.4,
                  height: screenSize.width * 0.4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        primaryBlue.withOpacity(isLightTheme ? 0.08 : 0.1),
                        primaryBlue.withOpacity(0.0),
                      ],
                      stops: const [0.2, 1.0],
                    ),
                  ),
                ),
              ),

              // Subtle blended circles for modern look - bottom left
              Positioned(
                bottom: screenSize.height * 0.3,
                left: -screenSize.width * 0.15,
                child: Container(
                  width: screenSize.width * 0.35,
                  height: screenSize.width * 0.35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        secondaryAccentColor
                            .withOpacity(isLightTheme ? 0.06 : 0.08),
                        secondaryAccentColor.withOpacity(0.0),
                      ],
                      stops: const [0.3, 1.0],
                    ),
                  ),
                ),
              ),

              // Main content with gesture detection
              const ReusableComplaintPage(),
            ],
          ),
        ),
      ),
    );
  }

  // Form field builders
  static Widget buildNameField(
      BuildContext context, EnhancedComplaintProvider state) {
    return _buildFormField(
      context: context,
      label: 'Full Name',
      icon: Icons.person_rounded,
      validator: (value) =>
          value?.isEmpty ?? true ? 'Please enter your name' : null,
      onSaved: (value) => state.updateName(value ?? ''),
    );
  }

  static Widget buildDateOfBirthField(
      BuildContext context, EnhancedComplaintProvider state) {
    return _buildFormField(
      context: context,
      label: 'Date of Birth',
      icon: Icons.event_rounded,
      readOnly: true,
      onTap: () => _showDatePicker(context, state),
      validator: (value) =>
          value?.isEmpty ?? true ? 'Please select your date of birth' : null,
      controller: TextEditingController(
        text: state.dateOfBirth != null
            ? DateFormat('MMMM dd, yyyy').format(state.dateOfBirth!)
            : '',
      ),
    );
  }

  static Widget buildPhoneField(
      BuildContext context, EnhancedComplaintProvider state) {
    return _buildFormField(
      context: context,
      label: 'Phone Number',
      icon: Icons.phone_rounded,
      keyboardType: TextInputType.phone,
      validator: (value) =>
          value?.isEmpty ?? true ? 'Please enter your phone number' : null,
      onSaved: (value) => state.updatePhone(value ?? ''),
    );
  }

  static Widget buildEmailField(
      BuildContext context, EnhancedComplaintProvider state) {
    return _buildFormField(
      context: context,
      label: 'Email Address',
      icon: Icons.email_rounded,
      keyboardType: TextInputType.emailAddress,
      validator: (value) =>
          value?.isEmpty ?? true ? 'Please enter your email' : null,
      onSaved: (value) => state.updateEmail(value ?? ''),
    );
  }

  static Widget buildAddressField(
      BuildContext context, EnhancedComplaintProvider state) {
    return _buildFormField(
      context: context,
      label: 'Complete Address',
      icon: Icons.location_on_rounded,
      maxLines: 3,
      validator: (value) =>
          value?.isEmpty ?? true ? 'Please enter your address' : null,
      onSaved: (value) => state.updateAddress(value ?? ''),
    );
  }

  static Widget buildComplaintField(
      BuildContext context, EnhancedComplaintProvider state) {
    return _buildFormField(
      context: context,
      label: 'Complaint Details',
      icon: Icons.description_rounded,
      maxLines: 5,
      hintText: 'Please provide detailed information about your complaint...',
      validator: (value) =>
          value?.isEmpty ?? true ? 'Please enter your complaint' : null,
      onSaved: (value) => state.updateComplaint(value ?? ''),
    );
  }

  static Widget buildFileUploadButton(
      BuildContext context, EnhancedComplaintProvider state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF64B5F6), const Color(0xFF42A5F5)]
              : [const Color(0xFF1E88E5), const Color(0xFF1976D2)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : const Color(0xFF1E88E5).withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _pickFile(state),
        icon: const Icon(Icons.file_upload_rounded,
            color: Colors.white, size: 20),
        label: const Text(
          'Upload Documents',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // Helper methods
  static Future<void> _showDatePicker(
      BuildContext context, EnhancedComplaintProvider state) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF003366),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      state.updateDateOfBirth(date);
    }
  }

  static Future<void> _pickFile(EnhancedComplaintProvider state) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      state.addFile(File(pickedFile.path));
    }
  }

  static Widget _buildFormField({
    required BuildContext context,
    required String label,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    int? maxLines,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextFormField(
        style: UserDashboardFonts.bodyText,
        decoration: inputDecoration(label, icon, context).copyWith(
          hintText: hintText,
          alignLabelWithHint: maxLines != null && maxLines > 1,
          isDense: true,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        readOnly: readOnly,
        onTap: onTap,
        validator: validator,
        onSaved: onSaved,
        controller: controller,
      ),
    );
  }

  static InputDecoration inputDecoration(
      String label, IconData icon, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? const Color(0xFF64B5F6) : const Color(0xFF1E88E5);

    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[50],
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primaryColor, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.red.shade300, width: 0.5),
      ),
      prefixIcon: Container(
        margin: const EdgeInsets.only(left: 8, right: 6),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: primaryColor, size: 18),
      ),
      labelStyle: UserDashboardFonts.formLabel.copyWith(
        color: isDark ? Colors.grey[300] : Colors.grey[700],
      ),
      floatingLabelStyle: UserDashboardFonts.formLabel.copyWith(
        color: primaryColor,
      ),
    ).copyWith(
      constraints: const BoxConstraints(
        minHeight: 40,
        maxHeight: 40,
      ),
    );
  }
}

// Premium, non-animated wave painter for a clean, modern look
// This class is no longer used after the simplification,
// but I'll keep it here for now in case it's needed elsewhere or for reference.
// Consider removing if fully deprecated.
class PremiumWavePainter extends CustomPainter {
  final bool isDark;
  final Color primaryColor;
  final Color secondaryColor;

  PremiumWavePainter({
    required this.isDark,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Create paths for multiple static waves
    final path1 = Path(); // Bottom wave
    final path2 = Path(); // Middle wave
    final path3 = Path(); // Top wave

    // Bottom wave - smooth and gentle
    path1.moveTo(0, height * 0.75);

    // Bezier curve for bottom wave
    final controlPoint1a = Offset(width * 0.25, height * 0.70);
    final controlPoint1b = Offset(width * 0.75, height * 0.80);
    final endPoint1 = Offset(width, height * 0.75);

    path1.quadraticBezierTo(
        controlPoint1a.dx, controlPoint1a.dy, width * 0.5, height * 0.75);
    path1.quadraticBezierTo(
        controlPoint1b.dx, controlPoint1b.dy, endPoint1.dx, endPoint1.dy);

    path1.lineTo(width, height);
    path1.lineTo(0, height);
    path1.close();

    // Middle wave - slightly higher and more pronounced
    path2.moveTo(0, height * 0.85);

    // Bezier curve for middle wave
    final controlPoint2a = Offset(width * 0.20, height * 0.78);
    final controlPoint2b = Offset(width * 0.60, height * 0.88);
    final endPoint2 = Offset(width, height * 0.82);

    path2.quadraticBezierTo(
        controlPoint2a.dx, controlPoint2a.dy, width * 0.4, height * 0.83);
    path2.quadraticBezierTo(
        controlPoint2b.dx, controlPoint2b.dy, endPoint2.dx, endPoint2.dy);

    path2.lineTo(width, height);
    path2.lineTo(0, height);
    path2.close();

    // Top wave - subtlest wave at the top
    path3.moveTo(0, height * 0.95);

    // Simple curve for top wave
    final controlPoint3 = Offset(width * 0.5, height * 0.92);
    final endPoint3 = Offset(width, height * 0.95);

    path3.quadraticBezierTo(
        controlPoint3.dx, controlPoint3.dy, endPoint3.dx, endPoint3.dy);

    path3.lineTo(width, height);
    path3.lineTo(0, height);
    path3.close();

    // Paint with premium gradient fills
    final paint1 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withOpacity(isDark ? 0.20 : 0.25),
          primaryColor.withOpacity(isDark ? 0.08 : 0.15),
        ],
      ).createShader(Rect.fromLTWH(0, height * 0.7, width, height * 0.3))
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          secondaryColor.withOpacity(isDark ? 0.18 : 0.22),
          secondaryColor.withOpacity(isDark ? 0.05 : 0.10),
        ],
      ).createShader(Rect.fromLTWH(0, height * 0.8, width, height * 0.2))
      ..style = PaintingStyle.fill;

    final paint3 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withOpacity(isDark ? 0.12 : 0.15),
          primaryColor.withOpacity(isDark ? 0.02 : 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, height * 0.9, width, height * 0.1))
      ..style = PaintingStyle.fill;

    // Draw waves from back to front
    canvas.drawPath(path3, paint3);
    canvas.drawPath(path2, paint2);
    canvas.drawPath(path1, paint1);

    // Add subtle highlight for light mode
    if (!isDark) {
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      // Highlight just the top of the main wave
      final highlightPath = Path();
      highlightPath.moveTo(0, height * 0.75);
      highlightPath.quadraticBezierTo(
          controlPoint1a.dx, controlPoint1a.dy, width * 0.5, height * 0.75);
      highlightPath.quadraticBezierTo(
          controlPoint1b.dx, controlPoint1b.dy, endPoint1.dx, endPoint1.dy);

      canvas.drawPath(highlightPath, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PremiumWavePainter oldDelegate) => false;
}
