// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobileapplication/authenticationpages/registerpage/modal.dart';
import 'package:mobileapplication/authenticationpages/loginpage/login_page.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/admindashboard_page.dart';
import 'package:mobileapplication/services/google_auth_service.dart';
import 'package:mobileapplication/adminmobileapplication/features/dashboard/presentation/screens/admin_mobile_dashboard.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:mobileapplication/authenticationpages/loginpage/services/auth_persistence_service.dart';
import 'package:mobileapplication/services/user_cache_service.dart';
import 'package:provider/provider.dart';
import 'package:mobileapplication/providers/navigation_provider.dart';
import 'package:mobileapplication/main_app_shell.dart';
import 'package:mobileapplication/userdashboard/usersettingsv2/usersettings_provider_v2.dart';
import 'package:mobileapplication/userdashboard/usersettingspage/sms_verification_dialog.dart';
import 'package:mobileapplication/widgets/universal_sms_verification_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobileapplication/widgets/floating_message.dart';

AppBar myAppbar(Color color,
    {Widget? title,
    required bool isAdmin,
    bool isEditing = false,
    VoidCallback? onEditPressed,
    VoidCallback? onSavePressed,
    Widget? leading,
    Color? backgroundColor,
    bool? centerTitle,
    double height = kToolbarHeight}) {
  return AppBar(
    toolbarHeight: height,
    title: title ??
        Text(isAdmin && isEditing
            ? 'Edit Educational Information'
            : 'Educational Information'),
    leading: leading,
    actions: isAdmin
        ? [
            IconButton(
              icon: Icon(isEditing ? Icons.save : Icons.edit),
              onPressed: () {
                if (isEditing) {
                  onSavePressed?.call();
                } else {
                  onEditPressed?.call();
                }
              },
            )
          ]
        : null,
    backgroundColor: backgroundColor ?? color,
    centerTitle: true,
  );
}

Icon myIcon(IconData icon, {Color? color, double? size}) {
  return Icon(
    icon,
    color: color,
    size: size,
  );
}

IconButton myIconbutton(
  IconData icons,
  VoidCallback onTap, {
  Color? colors,
}) {
  return IconButton(
    icon: Icon(icons),
    onPressed: onTap,
  );
}

logoWidget(fname, double height, double width) {
  return GestureDetector(
      child: Image.asset(
    fname,
    height: height,
    width: width,
  ));
}

Widget myTextform({
  IconData? icons,
  bool obscure = false,
  bool isPassword = false,
  String? label,
  VoidCallback? onVisible,
  TextStyle? labelStyle,
  TextStyle? style,
  TextEditingController? controller,
  FormFieldValidator<String>? validator,
  String? validation,
  int? maxLines,
  bool alignLabelWithHint = false,
  InputDecoration? inputDecoration,
  TextInputType? keyboardType,
  TextInputAction? textInputAction,
  Function(String)? onFieldSubmitted,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 8, bottom: 4),
        child: Text(
          label ?? '',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 0),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          obscureText: obscure,
          maxLines: isPassword ? 1 : maxLines,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          style: style ?? const TextStyle(color: Colors.black87),
          decoration: inputDecoration ??
              InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(
                  icons,
                  color: const Color.fromARGB(255, 25, 115, 232),
                  size: 22,
                ),
                suffixIcon: isPassword
                    ? IconButton(
                        icon: Icon(
                          obscure ? Icons.visibility_off : Icons.visibility,
                          color: const Color.fromARGB(255, 25, 115, 232),
                          size: 22,
                        ),
                        onPressed: onVisible,
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 25, 115, 232),
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.red.shade300),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.red.shade400),
                ),
              ),
        ),
      ),
    ],
  );
}

Container myButton2(
  BuildContext context,
  String label,
  VoidCallback? onTap, {
  TextStyle? labelStyle,
  Decoration? decoration,
  Color? color,
  Color? iconColor,
  IconData? icon,
  double? width = 200,
  double? height = 50,
  BorderRadius? borderRadius, // Changed from BorderRadiusGeometry
  bool isResponsive = true,
}) {
  return Container(
    width: isResponsive
        ? MediaQuery.of(context).size.width * 1 // 90% of screen width
        : width,
    height: height,
    margin: const EdgeInsets.symmetric(vertical: 8),
    decoration: decoration ??
        BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: borderRadius ??
              BorderRadius.circular(12), // This should now work correctly
          border: Border.all(
            color: const Color.fromARGB(255, 255, 255, 255),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: iconColor ?? Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: labelStyle ??
                      TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

TextButton myButton(String label,
    {TextStyle? labelstyle, VoidCallback? onTap}) {
  return TextButton(
    onPressed: onTap ?? () {},
    child: Text(
      label,
      style:
          labelstyle ?? const TextStyle(color: Colors.white, fontFamily: 'R'),
    ),
  );
}

Row bottomIcons() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      logoWidget(
          'assets/png-clipart-facebook-logo-facebook-computer-icons-desktop-s-icon-facebook-blue-text.png',
          60,
          60),
      logoWidget('assets/pngwing.com.png', 60, 60)
    ],
  );
}

Container myText(
  String text, {
  TextStyle? labelstyle,
  TextAlign? textAlign,
  TextOverflow? overflow,
  int? maxLines,
}) {
  // ignore: avoid_unnecessary_containers
  return Container(
    child: Text(
      text,
      style: labelstyle ??
          const TextStyle(
              fontSize: 75,
              fontFamily: 'Poppins',
              color: Color.fromARGB(255, 34, 38, 71),
              height: 0.9),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    ),
  );
}

Widget buildRegistrationHeader() {
  return const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Create Account",
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      SizedBox(height: 8),
      Text(
        "Sign up to get started!",
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    ],
  );
}

Widget myregisterButtonregister({VoidCallback? onPressed, String? label}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      minimumSize: const Size(double.infinity, 55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    child: Text(
      label ?? "",
      style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
    ),
  );
}

Widget myLoginredirect({
  VoidCallback? onLoginTap,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        "Already have an account? ",
        style: TextStyle(color: Colors.grey),
      ),
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onLoginTap,
          child: const Text(
            "Login",
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ],
  );
}

//complain page reusable code
Widget myFilepicker(
  BuildContext context,
  ImagePicker picker,
  List<File> attachedFiles,
  Function updatedAttachedFiles,
) {
  return Container(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Choose File Type',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _myFiletypebutton(
              context: context,
              icon: Icons.image,
              label: 'Photos',
              onTap: () async {
                Navigator.pop(context);
                await _pickImages(picker, attachedFiles, updatedAttachedFiles);
              },
            ),
            _myFiletypebutton(
              context: context,
              icon: Icons.video_collection,
              label: 'Videos',
              onTap: () async {
                Navigator.pop(context);
                await _pickVideos(picker, attachedFiles, updatedAttachedFiles);
              },
            ),
          ],
        ),
        SizedBox(height: 20),
      ],
    ),
  );
}

Widget _myFiletypebutton({
  BuildContext? context,
  IconData? icon,
  String? label,
  VoidCallback? onTap,
}) {
  return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            )
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 29),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            SizedBox(height: 8),
            myText(label ?? '', labelstyle: TextStyle(color: Colors.blue)),
          ],
        ),
      ));
}

//image and video picking logic
Future<void> _pickImages(ImagePicker picker, List<File> attachedFiles,
    Function updateAttachedFiles) async {
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    attachedFiles.add(File(pickedFile.path));
    updateAttachedFiles(); // Call the function to update the state
  }
}

Future<void> _pickVideos(ImagePicker picker, List<File> attachedFiles,
    Function updateAttachedFiles) async {
  final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
  if (pickedFile != null) {
    attachedFiles.add(File(pickedFile.path));
    updateAttachedFiles();
  }
}

String? validateField(String? value, String fieldName) {
  if (value == null || value.isEmpty) {
    return "Please enter your $fieldName";
  }
  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return "Please enter your email";
  }
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return "Please enter a valid email address";
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return "Please enter your password";
  }
  if (value.length < 6) {
    return "Password must be at least 6 characters long";
  }
  return null;
}

// Registration Form Widget
class RegistrationForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController surnameController;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscure;
  final VoidCallback togglePasswordVisibility;
  final VoidCallback onRegister;
  final bool isLoading;
  final VoidCallback onLoginTap;
  final BuildContext context;
  final bool mounted;
  final Function(bool) setLoading;

  const RegistrationForm({
    Key? key,
    required this.formKey,
    required this.nameController,
    required this.surnameController,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.obscure,
    required this.togglePasswordVisibility,
    required this.onRegister,
    required this.isLoading,
    required this.onLoginTap,
    required this.context,
    required this.mounted,
    required this.setLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          myTextform(
            controller: nameController,
            icons: Icons.person_outline,
            label: "First Name",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your first name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          myTextform(
            controller: surnameController,
            icons: Icons.person_outline,
            label: "Last Name",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your last name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          myTextform(
            controller: usernameController,
            icons: Icons.alternate_email,
            label: "Username",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a username';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          myTextform(
            controller: emailController,
            icons: Icons.email_outlined,
            label: "Email",
            validator: validateEmail,
          ),
          const SizedBox(height: 16),
          myTextform(
            controller: passwordController,
            icons: Icons.lock_outline,
            label: "Password",
            isPassword: true,
            obscure: obscure,
            validator: validatePassword,
            onVisible: togglePasswordVisibility,
          ),
          const SizedBox(height: 24),
          myregisterButtonregister(
            onPressed: isLoading
                ? null
                : () {
                    if (formKey.currentState!.validate()) {
                      onRegister();
                    }
                  },
            label: isLoading ? 'Registering...' : 'Register',
          ),
          const SizedBox(height: 24),
          myLoginredirect(onLoginTap: onLoginTap),
        ],
      ),
    );
  }
}

// Registration Handler Mixin
mixin RegistrationHandler {
  Future<void> handleRegistration({
    required BuildContext context,
    required TextEditingController nameController,
    required TextEditingController surnameController,
    required TextEditingController usernameController,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required Function(bool) setLoading,
    required bool mounted,
  }) async {
    try {
      setLoading(true);

      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'firstName': nameController.text.trim(),
        'lastName': surnameController.text.trim(),
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
        'isAdmin': false,
        'firebaseUID': userCredential.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'fullName':
            '${nameController.text.trim()} ${surnameController.text.trim()}',
      });

      if (mounted) {
        // Show success modal
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return SuccessDialog(
              onContinue: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Registration failed';
        if (e.toString().contains('email-already-in-use')) {
          errorMessage = 'This email is already registered';
        } else if (e.toString().contains('invalid-email')) {
          errorMessage = 'Please enter a valid email address';
        } else if (e.toString().contains('weak-password')) {
          errorMessage = 'Password should be at least 6 characters';
        }

        FloatingMessageService().showError(context, errorMessage);
      }
    } finally {
      if (mounted) {
        setLoading(false);
      }
    }
  }
}

// Error Modal
void showErrorModal(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color.fromARGB(255, 34, 38, 71),
              ),
            ),
          ),
        ],
      );
    },
  );
}

//social login button
Widget socialLoginButton({
  required VoidCallback onPressed,
  String? icon,
  required String label,
  Color? backgroundColor,
  Color? textColor,
  double? width,
  double? iconSize,
}) {
  return Container(
    width: width ?? double.infinity,
    height: 50,
    margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.white,
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  ClipOval(
                    child: Image.asset(
                      icon,
                      height: iconSize ?? 24,
                      width: iconSize ?? 24,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: textColor ?? Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// Change from mixin to class
class OAuthHandler {
  static Future<void> handleGoogleSignIn({
    required BuildContext context,
    required Function(bool) setLoading,
    required bool mounted,
    bool rememberMe = false,
  }) async {
    try {
      setLoading(true);

      final result = await GoogleAuthService.signIn();

      if (!mounted) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(result.docId)
          .get();

      if (!mounted) return;

      if (!userDoc.exists) {
        throw 'User document not found';
      }

      // CRITICAL FIX: Use admin status from GoogleAuthService result
      // This ensures we use the properly checked admin status (checks both collections)
      // Don't re-check from document as it might be stale
      final userData = userDoc.data();
      final isAdmin = result.isAdmin || 
          userData?['isAdmin'] == true ||
          userData?['role'] == 'admin' ||
          userData?['role'] == 'superAdmin' ||
          userData?['role'] == 'super_admin';

      // For admins, use admin-specific fields; for users, use user-specific fields
      final has2FA = isAdmin
          ? (userData?['requires2FASetup'] == true ||
              userData?['2FAEnabled'] == true)
          : (userData?['is2FAEnabled'] ?? false);

      final twoFactorMethod = isAdmin
          ? (userData?['2FAMethod'] ?? 'none')
          : (userData?['selected2FAMethod'] ?? 'none');

      final isFirstTimeLogin = isAdmin
          ? (userData?['isFirstLogin'] ?? false)
          : (userData?['isFirstTimeLogin'] ?? false);

      final phoneVerified = userData?['phoneVerified'] ?? false;

      // Check Remember Me status
      final isRemembered =
          await _checkRememberMeStatus(userData?['email'] ?? '');

      // Debug logging
      print('DEBUG: Google Sign-In 2FA Check:');
      print('  - isAdmin: $isAdmin');
      print('  - has2FA: $has2FA');
      print('  - twoFactorMethod: $twoFactorMethod');
      print('  - isFirstTimeLogin: $isFirstTimeLogin');
      print('  - phoneVerified: $phoneVerified');
      print('  - phoneNumber: ${userData?['phoneNumber']}');
      print('  - rememberMe: $rememberMe');
      print('  - isRemembered: $isRemembered');

      // Check if user needs first-time login verification
      if (isFirstTimeLogin && !phoneVerified) {
        setLoading(false);
        // Show first-time login SMS verification dialog
        if (mounted) {
          await _showFirstTimeLoginSMSDialog(context, userDoc);
        }
      } else if (has2FA && twoFactorMethod == 'sms' && !isRemembered) {
        setLoading(false);
        // Show SMS 2FA verification dialog
        if (mounted) {
          await _showSMS2FADialog(context, userDoc);
        }
      } else {
        // No 2FA required or Remember Me is active, proceed with normal login
        setLoading(false);

        // CRITICAL FIX: Enable persistent authentication for Google Sign-In users
        // This ensures users stay logged in even after closing the app
        final userEmail = userData?['email'] ?? result.user.email ?? '';
        if (userEmail.isNotEmpty) {
          // Cache user data for offline access
          try {
            final cacheService = await UserCacheService.init();
            await cacheService.cacheUser(result.user);
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ Error caching user data: $e');
            }
          }
          
          // Enable persistent authentication with correct user type
          await AuthPersistenceService.enableRememberMe(
            userEmail: userEmail,
            userType: isAdmin ? 'admin' : 'user',
          );
          await AuthPersistenceService.markSessionActive();
          
          if (kDebugMode) {
            print('✅ Google Sign-In persistence enabled for: $userEmail (${isAdmin ? 'admin' : 'user'})');
          }
        }

        // Save Remember Me status if checked
        if (rememberMe) {
          await _saveRememberMeStatus(userEmail);
        }

        if (isRemembered) {
          print('DEBUG: Skipping 2FA due to Remember Me status');
        }

        await _handleLoginSuccess(context, userDoc);
      }
    } catch (e) {
      if (mounted) {
        FloatingMessageService().showError(context, e.toString());
      }
    } finally {
      if (mounted) {
        setLoading(false);
      }
    }
  }

  // Handle successful login navigation
  static Future<void> _handleLoginSuccess(
      BuildContext context, DocumentSnapshot userDoc) async {
    final userData = userDoc.data() as Map<String, dynamic>?;
    
    // CRITICAL FIX: Enhanced admin check - check both users and admins collections
    // Also check by email and Firebase UID to handle promoted users
    final bool isAdminUser = await _checkAdminStatusComprehensive(
      userData: userData,
      userEmail: userData?['email'],
      firebaseUID: userData?['firebaseUID'],
    );
    
    final bool isMobileDevice =
        !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    Widget destinationPage;
    if (isAdminUser) {
      if (isMobileDevice) {
        destinationPage = const AdminMobileDashboard(); // Admin on Mobile
      } else {
        destinationPage = const AdmindashboardPage(); // Admin on Web/Desktop
      }
    } else {
      destinationPage = const MainAppShell(
          isAdmin: false); // Non-admin goes to MainAppShell with bottom nav
    }

    // Reset NavigationProvider to ensure navbar is visible after login
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    navProvider.reset(); // This sets isVisible = true and currentIndex = 0

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => destinationPage,
      ),
    );
  }

  // Show SMS 2FA verification dialog during Google Sign-In
  static Future<void> _showSMS2FADialog(
      BuildContext context, DocumentSnapshot userData) async {
    final data = userData.data() as Map<String, dynamic>?;
    final phoneNumber = data?['phoneNumber'] ?? '';

    if (phoneNumber.isEmpty) {
      FloatingMessageService().showError(
        context,
        'Phone number not found. Please contact support.',
      );
      await FirebaseAuth.instance.signOut();
      return;
    }

    // Get SettingsProvider from context
    final provider = Provider.of<SettingsProviderV2>(context, listen: false);

    // Send SMS verification code for login
    try {
      final result = await provider.sendSMSVerificationCode(phoneNumber);
      if (!result['success']) {
        FloatingMessageService().showError(
          context,
          'Failed to send verification code: ${result['message']}',
        );
        await FirebaseAuth.instance.signOut();
        return;
      }
    } catch (e) {
      FloatingMessageService().showError(
        context,
        'Error sending verification code: $e',
      );
      await FirebaseAuth.instance.signOut();
      return;
    }

    // Show SMS verification dialog
    final verified = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SMSVerificationDialog(
        phoneNumber: phoneNumber,
        provider: provider,
      ),
    );

    if (verified == true) {
      // 2FA verification successful, proceed with login
      // CRITICAL FIX: Enable persistent authentication after 2FA verification
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userEmail = currentUser.email ?? '';
        if (userEmail.isNotEmpty) {
          final userDocData = data;
          final isAdmin = userDocData?['isAdmin'] == true ||
              userDocData?['role'] == 'admin' ||
              userDocData?['role'] == 'superAdmin';
          
          // Cache user data
          try {
            final cacheService = await UserCacheService.init();
            await cacheService.cacheUser(currentUser);
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ Error caching user data after 2FA: $e');
            }
          }
          
          // Enable persistent authentication
          await AuthPersistenceService.enableRememberMe(
            userEmail: userEmail,
            userType: isAdmin ? 'admin' : 'user',
          );
          await AuthPersistenceService.markSessionActive();
          
          if (kDebugMode) {
            print('✅ Google Sign-In persistence enabled after 2FA for: $userEmail');
          }
        }
      }
      
      await _handleLoginSuccess(context, userData);
    } else {
      // 2FA verification failed or cancelled, sign out the user
      await FirebaseAuth.instance.signOut();
      FloatingMessageService().showError(
        context,
        'Login cancelled. Please try again.',
      );
    }
  }

  // Show first-time login SMS verification dialog
  static Future<void> _showFirstTimeLoginSMSDialog(
      BuildContext context, DocumentSnapshot userData) async {
    final userId = userData.id;
    final data = userData.data() as Map<String, dynamic>?;
    final phoneNumber = data?['phoneNumber'] ?? '';

    if (phoneNumber.isEmpty) {
      FloatingMessageService().showError(
        context,
        'Phone number not found. Please contact support.',
      );
      await FirebaseAuth.instance.signOut();
      return;
    }

    // Show first-time login SMS verification dialog
    final verified = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => UniversalSMSVerificationDialog(
        phoneNumber: phoneNumber,
        userId: userId,
        isFirstTimeLogin: true,
        onSuccess: () async {
          // Update user as verified
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({
            'phoneVerified': true,
            'isFirstTimeLogin': false,
          });
        },
      ),
    );

    if (verified == true) {
      // First-time verification successful, proceed with login
      // CRITICAL FIX: Enable persistent authentication after first-time verification
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userEmail = currentUser.email ?? '';
        if (userEmail.isNotEmpty) {
          final userDocData = data;
          final isAdmin = userDocData?['isAdmin'] == true ||
              userDocData?['role'] == 'admin' ||
              userDocData?['role'] == 'superAdmin';
          
          // Cache user data
          try {
            final cacheService = await UserCacheService.init();
            await cacheService.cacheUser(currentUser);
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ Error caching user data after first-time verification: $e');
            }
          }
          
          // Enable persistent authentication
          await AuthPersistenceService.enableRememberMe(
            userEmail: userEmail,
            userType: isAdmin ? 'admin' : 'user',
          );
          await AuthPersistenceService.markSessionActive();
          
          if (kDebugMode) {
            print('✅ Google Sign-In persistence enabled after first-time verification for: $userEmail');
          }
        }
      }
      
      await _handleLoginSuccess(context, userData);
    } else {
      // Verification failed or cancelled, sign out the user
      await FirebaseAuth.instance.signOut();
      FloatingMessageService().showError(
        context,
        'Phone verification cancelled. Please try again.',
      );
    }
  }

  // Check if Remember Me is still valid for the user
  static Future<bool> _checkRememberMeStatus(String userEmail) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMeExpiry = prefs.getString('remember_me_2fa');
      final rememberedUserId = prefs.getString('remember_me_user_id');

      if (rememberMeExpiry == null || rememberedUserId == null) {
        return false;
      }

      // Check if the remembered user matches current user
      if (rememberedUserId != userEmail) {
        return false;
      }

      // Check if Remember Me hasn't expired
      final expiryDate = DateTime.parse(rememberMeExpiry);
      final now = DateTime.now();

      if (now.isAfter(expiryDate)) {
        // Expired, clear the preference
        await prefs.remove('remember_me_2fa');
        await prefs.remove('remember_me_user_id');
        return false;
      }

      print('DEBUG: Remember Me valid until ${expiryDate.toIso8601String()}');
      return true;
    } catch (e) {
      print('DEBUG: Error checking Remember Me status: $e');
      return false;
    }
  }

  // Save Remember Me status for the user
  static Future<void> _saveRememberMeStatus(String userEmail) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryDate = DateTime.now().add(const Duration(days: 7)); // 7 days

      await prefs.setString('remember_me_2fa', expiryDate.toIso8601String());
      await prefs.setString('remember_me_user_id', userEmail);

      print('DEBUG: Remember Me saved until ${expiryDate.toIso8601String()}');
    } catch (e) {
      print('DEBUG: Error saving Remember Me status: $e');
    }
  }

  /// Comprehensive admin status check - checks both users and admins collections
  static Future<bool> _checkAdminStatusComprehensive({
    required Map<String, dynamic>? userData,
    String? userEmail,
    String? firebaseUID,
  }) async {
    try {
      // First, check userData from the document
      if (userData != null) {
        final isAdminFromData = userData['isAdmin'] == true ||
            userData['role'] == 'admin' ||
            userData['role'] == 'superAdmin' ||
            userData['role'] == 'super_admin';
        
        if (isAdminFromData) {
          print('DEBUG: Admin status found in userData');
          return true;
        }
      }

      // Check admins collection by email
      if (userEmail != null && userEmail.isNotEmpty) {
        final normalizedEmail = userEmail.toLowerCase().trim();
        final adminQuery = await FirebaseFirestore.instance
            .collection('admins')
            .where('email', isEqualTo: normalizedEmail)
            .limit(1)
            .get();
        
        if (adminQuery.docs.isNotEmpty) {
          final adminData = adminQuery.docs.first.data();
          final isAdmin = adminData['isAdmin'] == true ||
              adminData['role'] == 'admin' ||
              adminData['role'] == 'superAdmin' ||
              adminData['role'] == 'super_admin';
          
          if (isAdmin) {
            print('DEBUG: Admin status found in admins collection by email');
            return true;
          }
        }
      }

      // Check admins collection by Firebase UID
      if (firebaseUID != null && firebaseUID.isNotEmpty) {
        final adminDoc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(firebaseUID)
            .get();
        
        if (adminDoc.exists) {
          final adminData = adminDoc.data();
          final isAdmin = adminData?['isAdmin'] == true ||
              adminData?['role'] == 'admin' ||
              adminData?['role'] == 'superAdmin' ||
              adminData?['role'] == 'super_admin';
          
          if (isAdmin) {
            print('DEBUG: Admin status found in admins collection by UID');
            return true;
          }
        }
      }

      // Also check current Firebase Auth user UID
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final adminDoc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(currentUser.uid)
            .get();
        
        if (adminDoc.exists) {
          final adminData = adminDoc.data();
          final isAdmin = adminData?['isAdmin'] == true ||
              adminData?['role'] == 'admin' ||
              adminData?['role'] == 'superAdmin' ||
              adminData?['role'] == 'super_admin';
          
          if (isAdmin) {
            print('DEBUG: Admin status found in admins collection by current user UID');
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      print('DEBUG: Error in comprehensive admin check: $e');
      // Fallback to userData check if error occurs
      return userData?['isAdmin'] == true ||
          userData?['role'] == 'admin' ||
          userData?['role'] == 'superAdmin' ||
          userData?['role'] == 'super_admin';
    }
  }
}
