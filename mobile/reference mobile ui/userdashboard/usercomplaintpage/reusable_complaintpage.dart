import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mobileapplication/userdashboard/usercomplaintpage/enhanced_complaint_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobileapplication/userdashboard/usersettingsv2/usersettings_provider_v2.dart';
import 'package:mobileapplication/userdashboard/usercomplaintpage/services/file_upload_service.dart';
import 'package:mobileapplication/userdashboard/config/user_dashboard_fonts.dart';
import 'dart:math' as math;
import 'dart:io';

class ReusableComplaintPage extends StatefulWidget {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  const ReusableComplaintPage({super.key});

  @override
  State<ReusableComplaintPage> createState() => _ReusableComplaintPageState();
}

class _ReusableComplaintPageState extends State<ReusableComplaintPage> {
  // Text controllers for form fields
  late TextEditingController _descriptionController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _locationController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProviderV2>(
      builder: (context, settingsProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final themeColors = settingsProvider.getCurrentThemeColors(isDark);
        final primaryColor = themeColors['primary']!;
        final accentColor = themeColors['accent']!;
        final backgroundColor = themeColors['background']!;
        final textColor = themeColors['text']!;

        return Consumer<EnhancedComplaintProvider>(
          builder: (context, state, child) {
            return Scaffold(
              backgroundColor: backgroundColor,
              body: SafeArea(
                child: Form(
                  key: state.formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Header with Gradient Background and Corner Circles
                        _buildWelcomeHeader(
                            primaryColor, accentColor, textColor, isDark),
                        const SizedBox(height: 20),

                        // Quick Report Section
                        _buildQuickReportSection(state, primaryColor,
                            accentColor, textColor, isDark),
                        const SizedBox(height: 16),

                        // Evidence Section
                        _buildEvidenceSection(state, primaryColor, accentColor,
                            textColor, isDark),
                        const SizedBox(height: 16),

                        // Contact Section
                        _buildContactSection(state, primaryColor, accentColor,
                            textColor, isDark),
                        const SizedBox(height: 20),

                        // Submit Button
                        _buildSubmitButton(
                            context, state, primaryColor, accentColor),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  TextEditingController _getControllerForField(
      String label, String? fieldValue) {
    TextEditingController controller;

    switch (label) {
      case 'Description':
        controller = _descriptionController;
        break;
      case 'Name':
        controller = _nameController;
        break;
      case 'Phone':
        controller = _phoneController;
        break;
      case 'Location':
        controller = _locationController;
        break;
      default:
        controller = TextEditingController();
    }

    // Update controller text if it's different from current value
    if (controller.text != (fieldValue ?? '')) {
      controller.text = fieldValue ?? '';
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }

    return controller;
  }

  Widget _buildWelcomeHeader(
      Color primaryColor, Color accentColor, Color textColor, bool isDark) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        // Use same theme colors as submit button for consistent darker gradient blue
        final Color gradientStart = primaryColor;
        final Color gradientEnd = accentColor;

        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 8),
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
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: gradientStart.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 4),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Decorative background circles
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),
                    // Main content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Icon container
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 1000),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, scale, child) {
                                  return Transform.scale(
                                    scale: scale,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white.withOpacity(0.25),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.white,
                                        ),
                                        child: Icon(
                                          CupertinoIcons.doc_text_fill,
                                          color: gradientStart,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Report title
                                    TweenAnimationBuilder<double>(
                                      duration:
                                          const Duration(milliseconds: 1200),
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      builder: (context, value, child) {
                                        return Transform.translate(
                                          offset: Offset(20 * (1 - value), 0),
                                          child: Opacity(
                                            opacity: value,
                                            child: Text(
                                              'Report Incident',
                                              style: UserDashboardFonts
                                                  .titleTextBold
                                                  .copyWith(
                                                color: Colors.white,
                                                height: 1.1,
                                                fontSize: 22,
                                                letterSpacing: 0.3,
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    offset: const Offset(0, 1),
                                                    blurRadius: 2,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 4),
                                    // Professional report number preview
                                    TweenAnimationBuilder<double>(
                                      duration:
                                          const Duration(milliseconds: 1400),
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      builder: (context, value, child) {
                                        return Transform.translate(
                                          offset: Offset(20 * (1 - value), 0),
                                          child: Opacity(
                                            opacity: value,
                                            child: Text(
                                              'Report ID: ${DateTime.now().year}MGXXX',
                                              style: UserDashboardFonts
                                                  .smallText
                                                  .copyWith(
                                                color: Colors.white
                                                    .withOpacity(0.8),
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
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

  Widget _buildQuickReportSection(EnhancedComplaintProvider state,
      Color primaryColor, Color accentColor, Color textColor, bool isDark) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isDark ? const Color(0xFF162A45) : Colors.white,
                    isDark ? const Color(0xFF1E3A5F) : Colors.grey[50]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: accentColor.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: accentColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          CupertinoIcons.info_circle_fill,
                          color: accentColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Incident Details',
                        style: UserDashboardFonts.largeTextSemiBold.copyWith(
                          color: textColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Incident Type
                  _buildAnimatedDropdown(
                    'Incident Type',
                    state.incidentType,
                    [
                      'Illegal Fishing',
                      'Pollution',
                      'Safety Violation',
                      'Other'
                    ],
                    (value) => state.updateIncidentType(value),
                    accentColor,
                    textColor,
                  ),
                  const SizedBox(height: 16),

                  // Location
                  _buildLocationField(state, accentColor, textColor),
                  const SizedBox(height: 16),

                  // Description
                  _buildAnimatedTextField(
                    'Description',
                    state.complaint,
                    (value) => state.updateComplaint(value),
                    'Brief description',
                    accentColor,
                    textColor,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEvidenceSection(EnhancedComplaintProvider state,
      Color primaryColor, Color accentColor, Color textColor, bool isDark) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isDark ? const Color(0xFF162A45) : Colors.white,
                    isDark ? const Color(0xFF1E3A5F) : Colors.grey[50]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: accentColor.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: accentColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          CupertinoIcons.camera_fill,
                          color: accentColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Evidence',
                        style: UserDashboardFonts.largeTextSemiBold.copyWith(
                          color: textColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Evidence Type Selection
                  _buildEvidenceTypeSelection(state, accentColor, textColor),
                  const SizedBox(height: 16),

                  // Photo Upload
                  if (state.uploadedFiles
                      .any((file) => file.type == FileType.image))
                    _buildPhotoUpload(state, accentColor, textColor),

                  // Video Upload
                  if (state.uploadedFiles
                      .any((file) => file.type == FileType.video))
                    _buildVideoUpload(state, accentColor, textColor),

                  // Empty State
                  if (state.uploadedFiles.isEmpty)
                    _buildEmptyEvidenceState(state, accentColor, textColor),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactSection(EnhancedComplaintProvider state,
      Color primaryColor, Color accentColor, Color textColor, bool isDark) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isDark ? const Color(0xFF162A45) : Colors.white,
                    isDark ? const Color(0xFF1E3A5F) : Colors.grey[50]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: accentColor.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: accentColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              CupertinoIcons.person_fill,
                              color: accentColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Contact Info',
                            style: UserDashboardFonts.largeTextSemiBold.copyWith(
                              color: textColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      // Auto-fill button
                      Consumer<SettingsProviderV2>(
                        builder: (context, settingsProvider, _) {
                          return TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 600),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: GestureDetector(
                                  onTap: () {
                                    // Auto-fill form with user data
                                    state.autoFillForm(
                                      name: settingsProvider.username.isNotEmpty
                                          ? settingsProvider.username
                                          : null,
                                      email: settingsProvider.email.isNotEmpty
                                          ? settingsProvider.email
                                          : null,
                                      phone: settingsProvider.phoneNumber != null &&
                                              settingsProvider.phoneNumber!.isNotEmpty
                                          ? settingsProvider.phoneNumber
                                          : null,
                                    );
                                    // Show success feedback
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons.check_mark_circled_solid,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Form auto-filled successfully',
                                              style: UserDashboardFonts.bodyText.copyWith(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: accentColor,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        margin: const EdgeInsets.all(16),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          accentColor.withOpacity(0.15),
                                          accentColor.withOpacity(0.1),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: accentColor.withOpacity(0.3),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: accentColor.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          CupertinoIcons.arrow_clockwise,
                                          color: accentColor,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Auto Fill',
                                          style: UserDashboardFonts.smallText.copyWith(
                                            color: accentColor,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Name
                  _buildAnimatedTextField(
                    'Name',
                    state.name,
                    (value) => state.updateName(value),
                    'Your name',
                    accentColor,
                    textColor,
                  ),
                  const SizedBox(height: 16),

                  // Phone - with +63 format and numbers only
                  _buildPhoneTextField(
                    state,
                    accentColor,
                    textColor,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  _buildAnimatedTextField(
                    'Email',
                    state.email,
                    (value) => state.updateEmail(value),
                    'Email address',
                    accentColor,
                    textColor,
                  ),
                  const SizedBox(height: 16),

                  // Date of Birth
                  _buildDateOfBirthField(state, accentColor, textColor),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactDropdown(
      String label,
      String? value,
      List<String> options,
      Function(String?) onChanged,
      Color accentColor,
      Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: UserDashboardFonts.bodyTextMedium.copyWith(
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: accentColor.withOpacity(0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option,
                    style: UserDashboardFonts.bodyText.copyWith(
                      color: textColor,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactTextField(
      String label,
      String? value,
      Function(String) onChanged,
      String hint,
      Color accentColor,
      Color textColor,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: UserDashboardFonts.bodyTextMedium.copyWith(
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: accentColor.withOpacity(0.3)),
          ),
          child: TextField(
            controller: TextEditingController(text: value ?? ''),
            onChanged: onChanged,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: UserDashboardFonts.bodyText.copyWith(
                color: textColor.withOpacity(0.5),
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            style: UserDashboardFonts.bodyText.copyWith(
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoUpload(
      EnhancedComplaintProvider state, Color accentColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Photo Evidence',
              style: UserDashboardFonts.bodyTextMedium.copyWith(
                color: textColor,
              ),
            ),
            if (state.uploadedFiles.isNotEmpty)
              GestureDetector(
                onTap: () async {
                  try {
                    await state.replaceImage(ImageSource.gallery);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to change photo: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: accentColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Change Photo',
                    style: UserDashboardFonts.smallText.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Image Display with Better Sizing
        if (state.uploadedFiles.isNotEmpty)
          GestureDetector(
            onTap: () =>
                _showImagePreview(context, state.uploadedFiles.first.file),
            child: Container(
              height: 200, // Increased height for better visibility
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: accentColor.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.file(
                      state.uploadedFiles.first.file,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    // Overlay with tap hint
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          CupertinoIcons.fullscreen,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          GestureDetector(
            onTap: () async {
              try {
                await state.pickImage(ImageSource.gallery);
                // Force a rebuild to ensure UI updates
                if (mounted) {
                  setState(() {});
                }
              } catch (e) {
                // Handle error if needed
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add photo: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: accentColor.withOpacity(0.3),
                  style: BorderStyle.solid,
                  width: 1,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.camera_fill,
                      color: accentColor,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to add photo',
                      style: UserDashboardFonts.bodyText.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to view full size',
                      style: UserDashboardFonts.smallText.copyWith(
                        color: textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showImagePreview(BuildContext context, File imageFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              // Full-screen image
              Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      imageFile,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              // Close button
              Positioned(
                top: 40,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      CupertinoIcons.xmark,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              // Tap to close hint
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Tap outside to close',
                      style: UserDashboardFonts.bodyText.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context,
      EnhancedComplaintProvider state, Color primaryColor, Color accentColor) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 60 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    accentColor,
                    primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: state.isSubmitting
                      ? null
                      : () => state.submitComplaint(context),
                  child: Center(
                    child: state.isSubmitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 1000),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, value, child) {
                                  return Transform.rotate(
                                    angle: value * 2 * math.pi,
                                    child: const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Submitting...',
                                style: UserDashboardFonts.largeTextSemiBold
                                    .copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Submit Report',
                                style: UserDashboardFonts.largeTextSemiBold
                                    .copyWith(
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 12),
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 2000),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                        5 * math.sin(value * 2 * math.pi), 0),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        CupertinoIcons.arrow_right,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedDropdown(
      String label,
      String? dropdownValue,
      List<String> options,
      Function(String?) onChanged,
      Color accentColor,
      Color textColor,
      {String? Function(String?)? validator}) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animationValue, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: UserDashboardFonts.bodyTextMedium.copyWith(
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey[100]!,
                        Colors.grey[50]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: accentColor.withOpacity(0.2), width: 1),
                  ),
                  child: FormField<String>(
                    initialValue: dropdownValue,
                    validator: validator ??
                        (value) {
                          if (label == 'Incident Type' &&
                              (value == null || value.isEmpty)) {
                            return 'Please select an incident type';
                          }
                          return null;
                        },
                    builder: (FormFieldState<String> state) {
                      return DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: dropdownValue,
                          isExpanded: true,
                          items: options.map((String option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Text(
                                option,
                                style: UserDashboardFonts.bodyText.copyWith(
                                  color: textColor,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            onChanged(newValue);
                            state.didChange(newValue);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTextField(
      String label,
      String? fieldValue,
      Function(String) onChanged,
      String hint,
      Color accentColor,
      Color textColor,
      {int maxLines = 1}) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animationValue, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: UserDashboardFonts.bodyTextMedium.copyWith(
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey[100]!,
                        Colors.grey[50]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: accentColor.withOpacity(0.2), width: 1),
                  ),
                  child: TextFormField(
                    controller: _getControllerForField(label, fieldValue),
                    onChanged: onChanged,
                    maxLines: maxLines,
                    validator: (value) {
                      if (label == 'Description' &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Please provide a description';
                      }
                      if (label == 'Name' &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Please enter your name';
                      }
                      if (label == 'Phone' &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Please enter your phone number';
                      }
                      if (label == 'Email' &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: UserDashboardFonts.bodyText.copyWith(
                        color: textColor.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    style: UserDashboardFonts.bodyText.copyWith(
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Phone number field with +63 prefix and numbers-only input
  Widget _buildPhoneTextField(
      EnhancedComplaintProvider state, Color accentColor, Color textColor) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animationValue, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phone',
                  style: UserDashboardFonts.bodyTextMedium.copyWith(
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey[100]!,
                        Colors.grey[50]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: accentColor.withOpacity(0.2), width: 1),
                  ),
                  child: TextFormField(
                    controller: _getControllerForField('Phone', state.phone),
                    onChanged: (value) => state.updatePhone(value),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // Numbers only
                      LengthLimitingTextInputFormatter(10), // Max 10 digits after +63
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (value.length < 10) {
                        return 'Please enter a valid 10-digit phone number';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'XXXXXXXXXX',
                      hintStyle: UserDashboardFonts.bodyText.copyWith(
                        color: textColor.withOpacity(0.5),
                      ),
                      prefixIcon: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '+63',
                              style: UserDashboardFonts.bodyTextMedium.copyWith(
                                color: textColor,
                              ),
                            ),
                            Container(
                              height: 20,
                              width: 1,
                              margin: const EdgeInsets.only(left: 8),
                              color: textColor.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    style: UserDashboardFonts.bodyText.copyWith(
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateOfBirthField(
      EnhancedComplaintProvider state, Color accentColor, Color textColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animationValue, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date of Birth',
                  style: UserDashboardFonts.bodyTextMedium.copyWith(
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey[100]!,
                        Colors.grey[50]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: accentColor.withOpacity(0.2), width: 1),
                  ),
                  child: TextFormField(
                    controller: TextEditingController(
                      text: state.dateOfBirth != null
                          ? '${state.dateOfBirth!.day}/${state.dateOfBirth!.month}/${state.dateOfBirth!.year}'
                          : '',
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await _showModernDatePicker(
                        context: context,
                        initialDate: DateTime.now().subtract(const Duration(
                            days: 365 * 18)), // Default to 18 years ago
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        accentColor: accentColor,
                        textColor: textColor,
                        isDark: isDark,
                      );
                      if (date != null) {
                        state.updateDateOfBirth(date);
                      }
                    },
                    validator: (value) {
                      if (state.dateOfBirth == null) {
                        return 'Please select your date of birth';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Select your date of birth',
                      hintStyle: UserDashboardFonts.bodyText.copyWith(
                        color: textColor.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          CupertinoIcons.calendar,
                          color: accentColor,
                          size: 18,
                        ),
                      ),
                    ),
                    style: UserDashboardFonts.bodyText.copyWith(
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Show a modern, beautiful date picker
  Future<DateTime?> _showModernDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required Color accentColor,
    required Color textColor,
    required bool isDark,
  }) async {
    final Color pickerPrimaryColor = accentColor;
    final Color pickerSurfaceColor = isDark
        ? const Color(0xFF1E3A5F)
        : Colors.white;
    final Color pickerOnSurfaceColor = textColor;
    final Color pickerBackgroundColor = isDark
        ? const Color(0xFF0D1B2A).withOpacity(0.95)
        : Colors.white.withOpacity(0.98);

    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: pickerPrimaryColor,
              onPrimary: Colors.white,
              secondary: pickerPrimaryColor.withOpacity(0.8),
              onSecondary: Colors.white,
              surface: pickerSurfaceColor,
              onSurface: pickerOnSurfaceColor,
              background: pickerBackgroundColor,
              error: Colors.red.shade400,
              onError: Colors.white,
              brightness: isDark ? Brightness.dark : Brightness.light,
            ),
            dialogBackgroundColor: pickerBackgroundColor,
            scaffoldBackgroundColor: pickerBackgroundColor,
            textTheme: Theme.of(context).textTheme.copyWith(
                  headlineLarge: UserDashboardFonts.extraLargeHeadingText.copyWith(
                    color: pickerOnSurfaceColor,
                    fontWeight: FontWeight.bold,
                  ),
                  headlineMedium: UserDashboardFonts.largeTextSemiBold.copyWith(
                    color: pickerOnSurfaceColor,
                    fontWeight: FontWeight.w600,
                  ),
                  bodyLarge: UserDashboardFonts.bodyText.copyWith(
                    color: pickerOnSurfaceColor,
                  ),
                  bodyMedium: UserDashboardFonts.bodyTextMedium.copyWith(
                    color: pickerOnSurfaceColor,
                  ),
                  labelLarge: UserDashboardFonts.bodyTextMedium.copyWith(
                    color: pickerPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            // Enhanced date picker styling
            datePickerTheme: DatePickerThemeData(
              backgroundColor: pickerBackgroundColor,
              headerBackgroundColor: pickerPrimaryColor,
              headerForegroundColor: Colors.white,
              headerHeadlineStyle: UserDashboardFonts.largeTextSemiBold.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              headerHelpStyle: UserDashboardFonts.bodyTextMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
              weekdayStyle: UserDashboardFonts.bodyTextMedium.copyWith(
                color: pickerOnSurfaceColor.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
              dayStyle: UserDashboardFonts.bodyText.copyWith(
                color: pickerOnSurfaceColor,
              ),
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                if (states.contains(WidgetState.disabled)) {
                  return pickerOnSurfaceColor.withOpacity(0.3);
                }
                return pickerOnSurfaceColor;
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return pickerPrimaryColor;
                }
                if (states.contains(WidgetState.hovered)) {
                  return pickerPrimaryColor.withOpacity(0.1);
                }
                return Colors.transparent;
              }),
              todayForegroundColor: WidgetStateProperty.all(pickerPrimaryColor),
              todayBackgroundColor: WidgetStateProperty.all(
                pickerPrimaryColor.withOpacity(0.1),
              ),
              yearStyle: UserDashboardFonts.bodyText.copyWith(
                color: pickerOnSurfaceColor,
              ),
              yearForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return pickerOnSurfaceColor;
              }),
              yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return pickerPrimaryColor;
                }
                if (states.contains(WidgetState.hovered)) {
                  return pickerPrimaryColor.withOpacity(0.1);
                }
                return Colors.transparent;
              }),
              rangeSelectionBackgroundColor: pickerPrimaryColor.withOpacity(0.2),
              rangeSelectionOverlayColor: WidgetStateProperty.all(
                pickerPrimaryColor.withOpacity(0.1),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: pickerPrimaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              rangePickerShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              dayOverlayColor: WidgetStateProperty.all(
                pickerPrimaryColor.withOpacity(0.1),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: pickerSurfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: pickerPrimaryColor.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: pickerPrimaryColor.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: pickerPrimaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),
            // Dialog styling
            dialogTheme: DialogTheme(
              backgroundColor: pickerBackgroundColor,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: pickerPrimaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              titleTextStyle: UserDashboardFonts.largeTextSemiBold.copyWith(
                color: pickerOnSurfaceColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Button themes
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: pickerPrimaryColor,
                foregroundColor: Colors.white,
                elevation: 2,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: UserDashboardFonts.bodyTextMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: pickerPrimaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: UserDashboardFonts.bodyTextMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  Widget _buildLocationField(
      EnhancedComplaintProvider state, Color accentColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: UserDashboardFonts.bodyTextMedium.copyWith(
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accentColor.withOpacity(0.3)),
                ),
                child: TextField(
                  controller:
                      TextEditingController(text: state.locationText ?? ''),
                  onChanged: (value) => state.updateLocationText(value),
                  decoration: InputDecoration(
                    hintText: 'Enter location or tap GPS',
                    hintStyle: UserDashboardFonts.bodyText.copyWith(
                      color: textColor.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  style: UserDashboardFonts.bodyText.copyWith(
                    color: textColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: state.isLocationLoading
                  ? null
                  : () => state.initializeLocation(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: state.isLocationLoading
                      ? accentColor.withOpacity(0.3)
                      : accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: accentColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: state.isLocationLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(accentColor),
                        ),
                      )
                    : Icon(
                        CupertinoIcons.location_fill,
                        color: accentColor,
                        size: 16,
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build evidence type selection with camera, gallery, and video buttons
  /// Industry-standard 3-button layout for clear user experience
  Widget _buildEvidenceTypeSelection(
      EnhancedComplaintProvider state, Color accentColor, Color textColor) {
    // Define button colors for visual distinction
    const Color cameraColor = Color(0xFF1976D2);  // Blue - Take Photo
    const Color galleryColor = Color(0xFF10B981); // Green - Gallery
    const Color videoColor = Color(0xFF8B5CF6);   // Purple - Video

    return Row(
      children: [
        // Take Photo Button - Opens device camera
        Expanded(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: _buildEvidenceButton(
                  icon: CupertinoIcons.camera_fill,
                  label: 'Camera',
                  color: cameraColor,
                  onTap: () async {
                    await state.pickImage(ImageSource.camera);
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        // Gallery Button - Pick from photo library
        Expanded(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: _buildEvidenceButton(
                  icon: CupertinoIcons.photo_fill,
                  label: 'Gallery',
                  color: galleryColor,
                  onTap: () async {
                    await state.pickImage(ImageSource.gallery);
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        // Video Button - Pick/record video
        Expanded(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: _buildEvidenceButton(
                  icon: CupertinoIcons.videocam_fill,
                  label: 'Video',
                  color: videoColor,
                  onTap: () async {
                    await state.pickVideo(ImageSource.gallery);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Reusable evidence button widget with gradient styling
  Widget _buildEvidenceButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: UserDashboardFonts.smallText.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoUpload(
      EnhancedComplaintProvider state, Color accentColor, Color textColor) {
    final videoFiles = state.uploadedFiles
        .where((file) => file.type == FileType.video)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Video Evidence',
              style: UserDashboardFonts.bodyTextMedium.copyWith(
                color: textColor,
              ),
            ),
            if (videoFiles.isNotEmpty)
              GestureDetector(
                onTap: () async {
                  try {
                    await state.replaceVideo(ImageSource.gallery);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to change video: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: accentColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Change Video',
                    style: UserDashboardFonts.smallText.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (videoFiles.isNotEmpty)
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: accentColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.play_circle_fill,
                      color: accentColor,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Video Added',
                      style: UserDashboardFonts.bodyTextMedium.copyWith(
                        color: textColor,
                      ),
                    ),
                    Text(
                      videoFiles.first.name,
                      style: UserDashboardFonts.smallText.copyWith(
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyEvidenceState(
      EnhancedComplaintProvider state, Color accentColor, Color textColor) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          style: BorderStyle.solid,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.doc_text_fill,
              color: accentColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'No evidence added yet',
              style: UserDashboardFonts.bodyTextMedium.copyWith(
                color: textColor.withOpacity(0.7),
              ),
            ),
            Text(
              'Tap buttons above to add photo or video',
              style: UserDashboardFonts.smallText.copyWith(
                color: textColor.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}