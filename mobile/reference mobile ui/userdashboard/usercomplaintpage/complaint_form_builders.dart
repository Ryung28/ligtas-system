// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:mobileapplication/userdashboard/usercomplaintpage/enhanced_complaint_provider.dart';
import 'package:mobileapplication/userdashboard/config/user_dashboard_fonts.dart';

class ComplaintFormBuilders {
  static Widget buildNameField(
      BuildContext context, EnhancedComplaintProvider state) {
    return _buildField(
      context: context,
      label: 'Full Name',
      icon: CupertinoIcons.person_alt_circle_fill,
      validator: (value) => value?.isEmpty ?? true
          ? 'Please enter your name'
          : (value!.length < 2 ? 'Name must be at least 2 characters' : null),
      onSaved: (value) => state.updateName(value ?? ''),
      textCapitalization: TextCapitalization.words,
    );
  }

  static Widget buildDateOfBirthField(
      BuildContext context, EnhancedComplaintProvider state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Consistent with ReusableComplaintPage's marine theme
    final Color pickerPrimaryColor = isDark
        ? const Color(0xFF64B5F6) // Light blue for dark mode picker
        : const Color(0xFF005CB8); // Deep blue for light mode picker
    final Color pickerSurfaceColor = isDark
        ? const Color(0xFF162A45) // Dark card color
        : Colors.white;
    final Color pickerOnSurfaceColor =
        isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF0D2540);
    final Color pickerBackgroundColor = isDark
        ? const Color(0xFF0D1B2A).withOpacity(0.95)
        : Colors.white.withOpacity(0.98);

    return _buildField(
      context: context,
      label: 'Date of Birth',
      icon: CupertinoIcons.calendar_today,
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
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

        if (date != null) {
          state.updateDateOfBirth(date);
        }
      },
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
    return _buildField(
      context: context,
      label: 'Phone Number',
      icon: CupertinoIcons.phone_fill,
      hintText: '09XXXXXXXXX',
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Please enter your phone number';
        final phoneRegex = RegExp(r'^09[0-9]{9}$');
        if (!phoneRegex.hasMatch(value!.replaceAll(RegExp(r'[\s-]'), ''))) {
          return 'Please enter a valid phone number (e.g., 09123456789)';
        }
        return null;
      },
      onSaved: (value) =>
          state.updatePhone(value?.replaceAll(RegExp(r'[\s-]'), '') ?? ''),
      maxLength: 11,
      showCounter: false,
    );
  }

  static Widget buildEmailField(
      BuildContext context, EnhancedComplaintProvider state) {
    return _buildField(
      context: context,
      label: 'Email Address',
      icon: CupertinoIcons.mail_solid,
      hintText: 'example@youremail.com',
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Please enter your email';
        final emailRegex = RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
          caseSensitive: false,
        );
        return !emailRegex.hasMatch(value!)
            ? 'Please enter a valid email address'
            : null;
      },
      onSaved: (value) => state.updateEmail(value ?? ''),
      maxLength: 100,
      showCounter: false,
    );
  }

  static Widget buildAddressField(
      BuildContext context, EnhancedComplaintProvider state) {
    return _buildField(
      context: context,
      label: 'Complete Address (Street, Barangay, City/Municipality, Province)',
      icon: CupertinoIcons.location_solid,
      hintText:
          'e.g., Purok 1, Poblacion, Brgy. Marina, Seaside City, Coral Province',
      maxLines: 3,
      textCapitalization: TextCapitalization.sentences,
      validator: (value) =>
          value?.isEmpty ?? true ? 'Please enter your address' : null,
      onSaved: (value) => state.updateAddress(value ?? ''),
    );
  }

  static Widget buildComplaintField(
      BuildContext context, EnhancedComplaintProvider state) {
    return _buildField(
      context: context,
      label: 'Incident Details',
      icon: CupertinoIcons.doc_text_fill,
      hintText:
          'Describe the incident: What happened? Where and when did it occur? Who was involved? Any other important details.',
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
      maxLength: 1000,
      showCounter: true,
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Please describe the incident';
        if (value!.length < 20)
          return 'Please provide more details (minimum 20 characters)';
        if (value.length > 1000)
          return 'Description is too long (maximum 1000 characters)';
        return null;
      },
      onSaved: (value) => state.updateComplaint(value?.trim() ?? ''),
    );
  }

  static Widget _buildField({
    required BuildContext context,
    required String label,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    int? maxLines = 1,
    int? maxLength,
    bool showCounter = false,
    bool readOnly = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
    TextEditingController? controller,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Marine theme colors consistent with ReusableComplaintPage
    final Color accentColor = isDark
        ? const Color(0xFF64B5F6) // Light blue for dark mode accents
        : const Color(
            0xFF1E88E5); // Medium, vibrant blue for light mode accents

    final Color fieldBackgroundColor = isDark
        ? const Color(0xFF0D1B2A)
            .withOpacity(0.5) // Darker, slightly transparent field background
        : const Color(0xFFEAF2FA); // Light blue-grey for field background

    final Color textColor =
        isDark ? Colors.white.withOpacity(0.85) : const Color(0xFF0D2540);

    final Color borderColor =
        isDark ? accentColor.withOpacity(0.3) : Colors.blueGrey.shade200;

    final Color focusedBorderColor = accentColor;
    final Color errorColor = isDark ? Colors.red.shade300 : Colors.red.shade700;

    // Determine input field height based on maxLines
    final double minHeight = maxLines == 1
        ? 56
        : (maxLines! * 24.0 + 32.0); // Adjusted calculation for better padding

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        style: UserDashboardFonts.bodyText.copyWith(
          color: textColor,
          height: 1.5,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          alignLabelWithHint: maxLines != null && maxLines > 1,
          filled: true,
          fillColor: fieldBackgroundColor,
          contentPadding: EdgeInsets.symmetric(
              horizontal: 20, vertical: maxLines == 1 ? 16 : 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide
                .none, // No border by default, rely on enabled/focused
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: borderColor,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: focusedBorderColor,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: errorColor.withOpacity(0.6),
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: errorColor,
              width: 1.5,
            ),
          ),
          prefixIcon: Container(
            margin:
                const EdgeInsets.only(left: 12, right: 10, top: 2, bottom: 2),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: accentColor,
            ),
          ),
          labelStyle: UserDashboardFonts.formLabel.copyWith(
            color: isDark
                ? Colors.white.withOpacity(0.6)
                : Colors.blueGrey.shade700,
          ),
          floatingLabelStyle: UserDashboardFonts.formLabel.copyWith(
            color: accentColor,
            fontSize: 15, // Slightly larger for floating label
            fontWeight: FontWeight.w600,
          ),
          hintStyle: UserDashboardFonts.formHint.copyWith(
            color: isDark
                ? Colors.white.withOpacity(0.4)
                : Colors.blueGrey.shade400,
          ),
          counterText: showCounter ? null : '',
          errorStyle: UserDashboardFonts.smallText.copyWith(
            color: errorColor,
            fontWeight: FontWeight.w500,
          ),
          constraints: BoxConstraints(
            minHeight: minHeight,
          ),
        ),
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        validator: validator,
        onSaved: onSaved,
        controller: controller,
        maxLength: maxLength,
        cursorColor: accentColor,
        cursorWidth: 1.5,
        cursorRadius: const Radius.circular(2),
      ),
    );
  }
}
