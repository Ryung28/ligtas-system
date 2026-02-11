// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:mobileapplication/providers/theme_provider.dart';
// import 'package:mobileapplication/services/cloudinary_service.dart';
// import 'package:mobileapplication/providers/navigation_provider.dart';
// import 'package:mobileapplication/userdashboard/config/user_dashboard_fonts.dart';

// import 'dart:io';
// import 'package:mobileapplication/userdashboard/usersettingspage/usersettings_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter/services.dart';
// import 'package:mobileapplication/config/theme_config.dart';
// import 'package:mobileapplication/splashscreen/spashscreen_page.dart';
// import 'package:mobileapplication/authenticationpages/loginpage/login_page.dart';
// import 'package:flutter/foundation.dart';
// import 'package:mobileapplication/widgets/floating_message.dart';
// import 'package:mobileapplication/userdashboard/config/language_provider.dart';

// class UsersettingsPage extends StatefulWidget {
//   const UsersettingsPage({super.key});

//   @override
//   _UsersettingsPageState createState() => _UsersettingsPageState();
// }

// class _UsersettingsPageState extends State<UsersettingsPage> {
//   final ImagePicker _picker = ImagePicker();
//   SettingsProvider? _settingsProvider;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   bool _isSigningOut = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
//       _settingsProvider?.loadUserData();

//       // Initialize navigation provider
//       final navigationProvider =
//           Provider.of<NavigationProvider>(context, listen: false);
//       navigationProvider.initialize();
//     });
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final pickedFile = await _picker.pickImage(
//         source: source,
//         maxWidth: 800,
//         maxHeight: 800,
//         imageQuality: 90,
//       );

//       if (pickedFile != null) {
//         final imageFile = File(pickedFile.path);

//         if (!mounted) return;
//         FloatingMessageService().showInfo(
//           context,
//           'Uploading image...',
//           duration: const Duration(seconds: 2),
//         );

//         final imageUrl =
//             await CloudinaryService.uploadFile(imageFile, 'profile_pictures');

//         await _settingsProvider!.updateProfilePicture(imageUrl);

//         if (!mounted) return;
//         FloatingMessageService().showSuccess(
//           context,
//           'Profile picture updated successfully',
//           duration: const Duration(seconds: 3),
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;
//       FloatingMessageService().showError(
//         context,
//         'Error updating profile picture: $e',
//         duration: const Duration(seconds: 4),
//       );
//     }
//   }

//   void _showImageSourceSelection() {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (BuildContext context) {
//         return Container(
//           decoration: BoxDecoration(
//             color: isDark ? ThemeConfig.darkSurface : Colors.white,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 20,
//                 offset: const Offset(0, -5),
//               ),
//             ],
//           ),
//           child: SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Handle bar
//                   Container(
//                     width: 40,
//                     height: 4,
//                     decoration: BoxDecoration(
//                       color: isDark ? Colors.white24 : Colors.grey[300],
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   // Title
//                   Text(
//                     'Change Profile Picture',
//                     style: TextStyle(
//                       color: isDark ? Colors.white : Colors.black87,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     'Choose how you\'d like to update your profile picture',
//                     style: TextStyle(
//                       color: isDark ? Colors.white70 : Colors.grey[600],
//                       fontSize: 13,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 20),
//                   // Options
//                   _buildImageSourceOption(
//                     context: context,
//                     icon: Icons.camera_alt_rounded,
//                     title: 'Take Photo',
//                     subtitle: 'Use your camera to take a new photo',
//                     onTap: () {
//                       Navigator.pop(context);
//                       _pickImage(ImageSource.camera);
//                     },
//                     isDark: isDark,
//                   ),
//                   const SizedBox(height: 12),
//                   _buildImageSourceOption(
//                     context: context,
//                     icon: Icons.photo_library_rounded,
//                     title: 'Choose from Gallery',
//                     subtitle: 'Select an existing photo from your gallery',
//                     onTap: () {
//                       Navigator.pop(context);
//                       _pickImage(ImageSource.gallery);
//                     },
//                     isDark: isDark,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildImageSourceOption({
//     required BuildContext context,
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//     required bool isDark,
//   }) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
//               width: 1,
//             ),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: (isDark
//                           ? ThemeConfig.darkBlueAccent
//                           : _settingsProvider?.deepBlue ?? Colors.blue)
//                       .withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Icon(
//                   icon,
//                   color: isDark
//                       ? ThemeConfig.darkBlueAccent
//                       : _settingsProvider?.deepBlue,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: TextStyle(
//                         color: isDark ? Colors.white : Colors.black87,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                       maxLines: 1,
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       subtitle,
//                       style: TextStyle(
//                         color: isDark ? Colors.white70 : Colors.grey[600],
//                         fontSize: 12,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                       maxLines: 2,
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.arrow_forward_ios,
//                 color: isDark ? Colors.white54 : const Color(0xFF757575),
//                 size: 14,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showAboutApp() {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         backgroundColor: isDark ? ThemeConfig.darkSurface : Colors.white,
//         title: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: (isDark
//                         ? ThemeConfig.darkBlueAccent
//                         : _settingsProvider?.deepBlue ?? Colors.blue)
//                     .withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 Icons.info_outline_rounded,
//                 color: isDark
//                     ? ThemeConfig.darkBlueAccent
//                     : _settingsProvider?.deepBlue,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               'About Marine Guard',
//               style: TextStyle(
//                 color: isDark ? Colors.white : Colors.black87,
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: (isDark
//                         ? ThemeConfig.darkBlueAccent
//                         : _settingsProvider?.deepBlue ?? Colors.blue)
//                     .withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.waves_rounded,
//                     color: isDark
//                         ? ThemeConfig.darkBlueAccent
//                         : _settingsProvider?.deepBlue,
//                     size: 32,
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Marine Guard',
//                           style: TextStyle(
//                             color: isDark ? Colors.white : Colors.black87,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text(
//                           'Version 1.0.0',
//                           style: TextStyle(
//                             color: isDark ? Colors.white70 : Colors.grey[600],
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'An innovative application designed to protect and preserve marine life through technology and community engagement.',
//               style: TextStyle(
//                 color: isDark ? Colors.white70 : const Color(0xFF424242),
//                 fontSize: 16,
//                 height: 1.5,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Features:',
//               style: TextStyle(
//                 color: isDark ? Colors.white : const Color(0xFF1A1A1A),
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             _buildFeatureItem('🌊 Marine Education Hub', isDark),
//             _buildFeatureItem('📊 Real-time Ocean Data', isDark),
//             _buildFeatureItem('🚫 Ban Period Monitoring', isDark),
//             _buildFeatureItem('📱 User-friendly Interface', isDark),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             style: TextButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             ),
//             child: Text(
//               'Close',
//               style: TextStyle(
//                 color: isDark ? Colors.white70 : const Color(0xFF424242),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFeatureItem(String text, bool isDark) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Text(
//         text,
//         style: TextStyle(
//           color: isDark ? Colors.white70 : const Color(0xFF424242),
//           fontSize: 14,
//         ),
//       ),
//     );
//   }

//   void _showTermsAndConditions() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: Theme.of(context).brightness == Brightness.dark
//             ? const Color(0xFF1A237E)
//             : Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Text(
//           'Terms & Conditions',
//           style: TextStyle(
//             color: Theme.of(context).brightness == Brightness.dark
//                 ? Colors.white
//                 : const Color(0xFF1A237E),
//             fontWeight: FontWeight.bold,
//             fontSize: 24,
//           ),
//         ),
//         content: Container(
//           width: double.maxFinite,
//           constraints: const BoxConstraints(maxHeight: 500),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildPrivacySection(
//                   'Last Updated: December 2024',
//                   isDate: true,
//                   context: context,
//                 ),
//                 const SizedBox(height: 16),
//                 _buildPrivacySection(
//                   '1. Acceptance of Terms',
//                   content: [
//                     'By accessing and using Marine Guard, you agree to be bound by these terms and conditions. If you disagree with any part of these terms, you may not access the application.',
//                   ],
//                   context: context,
//                 ),
//                 _buildPrivacySection(
//                   '2. User Responsibilities',
//                   content: [
//                     'You must provide accurate and complete information when creating an account',
//                     'You are responsible for maintaining the confidentiality of your account',
//                     'You agree to use the app in compliance with local fishing and marine protection laws',
//                     'You must not use the app for any illegal or unauthorized purpose',
//                   ],
//                   context: context,
//                 ),
//                 _buildPrivacySection(
//                   '3. Ban Period Compliance',
//                   content: [
//                     'You agree to respect and comply with all fishing ban periods',
//                     'You acknowledge that ban periods are enforced to protect marine life',
//                     'Violation of ban periods may result in account suspension',
//                   ],
//                   context: context,
//                 ),
//                 _buildPrivacySection(
//                   '4. Privacy & Data',
//                   content: [
//                     'We collect and process your data as described in our Privacy Policy',
//                     'Your location data may be used to provide relevant marine information',
//                     'We may share aggregated, non-personal data for research purposes',
//                   ],
//                   context: context,
//                 ),
//                 _buildPrivacySection(
//                   '5. Modifications',
//                   content: [
//                     'We reserve the right to modify these terms at any time. We will notify users of any changes through the app.',
//                   ],
//                   context: context,
//                 ),
//                 _buildPrivacySection(
//                   '6. Disclaimer',
//                   content: [
//                     'Marine Guard is provided "as is" without any warranties. We do not guarantee the accuracy of marine data or weather information.',
//                   ],
//                   context: context,
//                 ),
//                 _buildPrivacySection(
//                   '7. Contact',
//                   content: [
//                     'Email: marineguard.ph@gmail.com',
//                     'Website: https://marineguard-admin.website/',
//                     'Address: Marine Guard Team',
//                   ],
//                   context: context,
//                 ),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Close',
//               style: TextStyle(
//                 color: Theme.of(context).brightness == Brightness.dark
//                     ? Colors.white
//                     : const Color(0xFF1A237E),
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showPrivacyPolicy() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: Theme.of(context).brightness == Brightness.dark
//             ? const Color(0xFF1A237E)
//             : Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Text(
//           'Privacy Policy',
//           style: TextStyle(
//             color: Theme.of(context).brightness == Brightness.dark
//                 ? Colors.white
//                 : const Color(0xFF1A237E),
//             fontWeight: FontWeight.bold,
//             fontSize: 24,
//           ),
//         ),
//         content: Container(
//           width: double.maxFinite,
//           constraints: const BoxConstraints(maxHeight: 500),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildPrivacySection(
//                   'Last Updated: December 2024',
//                   isDate: true,
//                   context: context,
//                 ),
//                 const SizedBox(height: 16),
//                 _buildPrivacySection(
//                   'Information We Collect',
//                   content: [
//                     'Personal Information (name, email, profile picture)',
//                     'Location Data for marine conditions',
//                     'Device information and app usage statistics',
//                     'Fishing activity and ban period compliance data',
//                   ],
//                   context: context,
//                 ),
//                 _buildPrivacySection(
//                   'How We Use Your Information',
//                   content: [
//                     'Provide marine protection services and updates',
//                     'Monitor and enforce ban period compliance',
//                     'Improve app features and user experience',
//                     'Send important notifications about marine conditions',
//                   ],
//                   context: context,
//                 ),
//                 _buildPrivacySection(
//                   'Data Security',
//                   content: [
//                     'End-to-end encryption for personal data',
//                     'Regular security audits and updates',
//                     'Secure cloud storage with Firebase',
//                     'Limited employee access to user data',
//                   ],
//                   context: context,
//                 ),
//                 _buildPrivacySection(
//                   'Information Sharing',
//                   content: [
//                     'We never sell your personal information',
//                     'Data may be shared with marine protection authorities',
//                     'Anonymous analytics for app improvement',
//                     'Third-party service providers (storage, analytics)',
//                   ],
//                   context: context,
//                 ),
//                 _buildPrivacySection(
//                   'Your Rights',
//                   content: [
//                     'Access your personal data',
//                     'Request data correction or deletion',
//                     'Opt-out of non-essential communications',
//                     'Data portability options',
//                   ],
//                   context: context,
//                 ),
//                 _buildPrivacySection(
//                   'Contact Us',
//                   content: [
//                     'Email: marineguard.ph@gmail.com',
//                     'Website: https://marineguard-admin.website/',
//                     'Address: Marine Guard Team',
//                   ],
//                   context: context,
//                 ),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Close',
//               style: TextStyle(
//                 color: Theme.of(context).brightness == Brightness.dark
//                     ? Colors.white
//                     : const Color(0xFF1A237E),
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showFullScreenProfile(String? imageUrl) {
//     if (imageUrl == null || imageUrl.isEmpty) return;

//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => FullScreenProfileView(
//           imageUrl: imageUrl,
//           username: _settingsProvider?.username ?? '',
//         ),
//       ),
//     );
//   }

//   Widget _buildPrivacySection(
//     String title, {
//     List<String>? content,
//     bool isDate = false,
//     required BuildContext context,
//   }) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: isDark
//             ? Colors.white.withOpacity(0.1)
//             : const Color(0xFF1A237E).withOpacity(0.05),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               color: isDark ? Colors.white : const Color(0xFF1A237E),
//               fontWeight: isDate ? FontWeight.normal : FontWeight.bold,
//               fontSize: isDate ? 14 : 18,
//               fontStyle: isDate ? FontStyle.italic : FontStyle.normal,
//             ),
//           ),
//           if (content != null) ...[
//             const SizedBox(height: 8),
//             ...content
//                 .map((item) => Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             '•',
//                             style: TextStyle(
//                               color: isDark
//                                   ? Colors.white70
//                                   : const Color(0xFF1A237E),
//                               fontSize: 16,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               item,
//                               style: TextStyle(
//                                 color: isDark ? Colors.white70 : Colors.black87,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ))
//                 .toList(),
//           ],
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//       statusBarBrightness: Theme.of(context).brightness,
//       statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
//       systemNavigationBarColor: isDark
//           ? ThemeConfig.darkBackground
//           : Provider.of<SettingsProvider>(context).whiteWater,
//       systemNavigationBarIconBrightness:
//           isDark ? Brightness.light : Brightness.dark,
//     ));

//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.of(context).pop();
//         return false;
//       },
//       child: Scaffold(
//         backgroundColor: isDark ? ThemeConfig.darkBackground : Colors.grey[50],
//         extendBody: true,
//         body: Consumer<SettingsProvider>(
//           builder: (context, provider, child) {
//             if (provider.isLoading) {
//               return _buildLoadingState(isDark, provider);
//             }

//             return CustomScrollView(
//               physics: const BouncingScrollPhysics(),
//               slivers: [
//                 _buildModernAppBar(context, provider, isDark),
//                 SliverToBoxAdapter(
//                   child: _buildSettingsContent(context, provider, isDark),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildLoadingState(bool isDark, SettingsProvider provider) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(
//               isDark ? ThemeConfig.darkBlueAccent : provider.deepBlue,
//             ),
//             strokeWidth: 3,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Loading settings...',
//             style: TextStyle(
//               color: isDark ? Colors.white70 : Colors.grey[600],
//               fontSize: 16,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildModernAppBar(
//       BuildContext context, SettingsProvider provider, bool isDark) {
//     return SliverAppBar(
//       expandedHeight: 180,
//       floating: false,
//       pinned: true,
//       backgroundColor: isDark ? ThemeConfig.darkBackground : Colors.white,
//       elevation: 0,
//       automaticallyImplyLeading: false, // Remove back button
//       flexibleSpace: FlexibleSpaceBar(
//         background: Container(
//           decoration: BoxDecoration(
//             gradient: isDark
//                 ? LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [
//                       ThemeConfig.darkBackground,
//                       ThemeConfig.darkSurface,
//                     ],
//                   )
//                 : LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [
//                       provider.deepBlue,
//                       provider.deepBlue.withOpacity(0.8),
//                     ],
//                   ),
//           ),
//           child: Stack(
//             children: [
//               // Decorative background elements
//               Positioned(
//                 top: -30,
//                 right: -30,
//                 child: Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.white.withOpacity(0.06),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 bottom: -20,
//                 left: -20,
//                 child: Container(
//                   width: 60,
//                   height: 60,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.white.withOpacity(0.04),
//                   ),
//                 ),
//               ),
//               // Additional decorative circles
//               Positioned(
//                 top: 20,
//                 left: -15,
//                 child: Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.white.withOpacity(0.03),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 bottom: 40,
//                 right: -10,
//                 child: Container(
//                   width: 35,
//                   height: 35,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.white.withOpacity(0.05),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 top: 60,
//                 right: 20,
//                 child: Container(
//                   width: 25,
//                   height: 25,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.white.withOpacity(0.04),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 bottom: 20,
//                 left: 30,
//                 child: Container(
//                   width: 30,
//                   height: 30,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.white.withOpacity(0.03),
//                   ),
//                 ),
//               ),
//               // Main content
//               SafeArea(
//                 child: Padding(
//                   padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 6),
//                       Text(
//                         'Settings',
//                         style: UserDashboardFonts.largeHeadingText.copyWith(
//                           color: isDark ? Colors.white : Colors.white,
//                           fontSize: 20,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         'Manage your account and preferences',
//                         style: UserDashboardFonts.bodyText.copyWith(
//                           color: isDark ? Colors.white70 : Colors.white70,
//                           fontSize: 13,
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       _buildProfileCard(context, provider, isDark),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileCard(
//       BuildContext context, SettingsProvider provider, bool isDark) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: isDark ? ThemeConfig.darkSurface : Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: isDark
//                 ? Colors.black.withOpacity(0.2)
//                 : Colors.grey.withOpacity(0.15),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: () => _showFullScreenProfile(provider.profilePictureUrl),
//             child: Container(
//               width: 44,
//               height: 44,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: isDark
//                       ? ThemeConfig.darkBlueAccent.withOpacity(0.3)
//                       : provider.deepBlue.withOpacity(0.2),
//                   width: 2,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: isDark
//                         ? Colors.black.withOpacity(0.3)
//                         : Colors.grey.withOpacity(0.2),
//                     blurRadius: 6,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: ClipOval(
//                 child: provider.profilePictureUrl != null &&
//                         provider.profilePictureUrl!.isNotEmpty
//                     ? Image.network(
//                         provider.profilePictureUrl!,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) =>
//                             _buildDefaultAvatar(isDark),
//                       )
//                     : _buildDefaultAvatar(isDark),
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   provider.username,
//                   style: UserDashboardFonts.bodyText.copyWith(
//                     color: isDark ? Colors.white : Colors.black87,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   provider.email,
//                   style: UserDashboardFonts.smallText.copyWith(
//                     color: isDark ? Colors.white70 : Colors.grey[600],
//                     fontSize: 13,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//           GestureDetector(
//             onTap: _showImageSourceSelection,
//             child: Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: isDark
//                     ? ThemeConfig.darkBlueAccent.withOpacity(0.1)
//                     : provider.deepBlue.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(
//                   color: isDark
//                       ? ThemeConfig.darkBlueAccent.withOpacity(0.3)
//                       : provider.deepBlue.withOpacity(0.3),
//                   width: 1,
//                 ),
//               ),
//               child: Icon(
//                 Icons.camera_alt_rounded,
//                 color: isDark ? ThemeConfig.darkBlueAccent : provider.deepBlue,
//                 size: 16,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDefaultAvatar(bool isDark) {
//     return Container(
//       decoration: BoxDecoration(
//         color: isDark ? ThemeConfig.darkBlueAccent : Colors.blue[400],
//         shape: BoxShape.circle,
//       ),
//       child: Icon(
//         Icons.person,
//         color: Colors.white,
//         size: 35,
//       ),
//     );
//   }

//   Widget _buildSettingsContent(
//       BuildContext context, SettingsProvider provider, bool isDark) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 24, 16, 60),
//       child: Column(
//         children: [
//           // Account & Security Section
//           _buildEnhancedSettingsSection(
//             context: context,
//             title: 'Account & Security',
//             icon: Icons.security_rounded,
//             color: Colors.blue,
//             items: [
//               _buildEnhancedSettingsTile(
//                 context: context,
//                 icon: Icons.edit_rounded,
//                 title: 'Edit Profile',
//                 subtitle: 'Update your personal information',
//                 onTap: () => _showEditProfile(context, provider, isDark),
//                 isDark: isDark,
//                 provider: provider,
//                 showArrow: true,
//               ),
//               _buildDivider(isDark),
//               _buildEnhancedSettingsTile(
//                 context: context,
//                 icon: Icons.lock_outline_rounded,
//                 title: 'Change Password',
//                 subtitle: 'Update your account password',
//                 onTap: _changePassword,
//                 isDark: isDark,
//                 provider: provider,
//                 showArrow: true,
//               ),
//               _buildDivider(isDark),
//               _buildTwoFactorAuthTile(context, isDark, provider),
//               _buildDivider(isDark),
//               _buildEnhancedSettingsTile(
//                 context: context,
//                 icon: Icons.notifications_active_rounded,
//                 title: 'Notifications',
//                 subtitle: 'Manage notification preferences',
//                 onTap: () => _showNotificationSettings(context, isDark),
//                 isDark: isDark,
//                 provider: provider,
//                 showArrow: true,
//               ),
//             ],
//             isDark: isDark,
//             provider: provider,
//           ),
//           const SizedBox(height: 16),

//           // App Preferences Section
//           _buildEnhancedSettingsSection(
//             context: context,
//             title: 'App Preferences',
//             icon: Icons.tune_rounded,
//             color: Colors.purple,
//             items: [
//               _buildThemeSelectionTile(context, isDark, provider),
//               _buildDivider(isDark),
//               Consumer<SettingsProvider>(
//                 builder: (context, settingsProvider, child) {
//                   return _buildEnhancedSettingsTile(
//                     context: context,
//                     icon: Icons.language_rounded,
//                     title: 'Language',
//                     subtitle: settingsProvider
//                         .getLanguageName(settingsProvider.selectedLanguage),
//                     onTap: () => _showLanguageSettings(context, isDark),
//                     isDark: isDark,
//                     provider: provider,
//                     showArrow: true,
//                   );
//                 },
//               ),
//               _buildDivider(isDark),
//               _buildEnhancedSettingsTile(
//                 context: context,
//                 icon: Icons.storage_rounded,
//                 title: 'Storage',
//                 subtitle: 'Manage app storage',
//                 onTap: () => _showStorageSettings(context, isDark),
//                 isDark: isDark,
//                 provider: provider,
//                 showArrow: true,
//               ),
//             ],
//             isDark: isDark,
//             provider: provider,
//           ),
//           const SizedBox(height: 16),

//           // Support & Info Section
//           _buildEnhancedSettingsSection(
//             context: context,
//             title: 'Support & Information',
//             icon: Icons.help_outline_rounded,
//             color: Colors.green,
//             items: [
//               _buildEnhancedSettingsTile(
//                 context: context,
//                 icon: Icons.info_outline_rounded,
//                 title: 'About Marine Guard',
//                 subtitle: 'Version 1.0.0 • Learn more',
//                 onTap: _showAboutApp,
//                 isDark: isDark,
//                 provider: provider,
//                 showArrow: true,
//               ),
//               _buildDivider(isDark),
//               _buildEnhancedSettingsTile(
//                 context: context,
//                 icon: Icons.description_outlined,
//                 title: 'Terms & Conditions',
//                 subtitle: 'Read our terms of service',
//                 onTap: _showTermsAndConditions,
//                 isDark: isDark,
//                 provider: provider,
//                 showArrow: true,
//               ),
//               _buildDivider(isDark),
//               _buildEnhancedSettingsTile(
//                 context: context,
//                 icon: Icons.privacy_tip_outlined,
//                 title: 'Privacy Policy',
//                 subtitle: 'How we protect your data',
//                 onTap: _showPrivacyPolicy,
//                 isDark: isDark,
//                 provider: provider,
//                 showArrow: true,
//               ),
//               _buildDivider(isDark),
//               _buildEnhancedSettingsTile(
//                 context: context,
//                 icon: Icons.contact_support_rounded,
//                 title: 'Contact Support',
//                 subtitle: 'Get help and support',
//                 onTap: () => _showContactSupport(context, isDark),
//                 isDark: isDark,
//                 provider: provider,
//                 showArrow: true,
//               ),
//             ],
//             isDark: isDark,
//             provider: provider,
//           ),
//           const SizedBox(height: 24),

//           // Logout Button
//           _buildEnhancedLogoutButton(context, isDark, provider),
//         ],
//       ),
//     );
//   }

//   // Enhanced Settings Section
//   Widget _buildEnhancedSettingsSection({
//     required BuildContext context,
//     required String title,
//     required IconData icon,
//     required Color color,
//     required List<Widget> items,
//     required bool isDark,
//     required SettingsProvider provider,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: isDark ? ThemeConfig.darkSurface : Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: isDark
//                 ? Colors.black.withOpacity(0.1)
//                 : Colors.grey.withOpacity(0.08),
//             blurRadius: 12,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         color.withOpacity(0.1),
//                         color.withOpacity(0.05),
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(
//                     icon,
//                     color: color,
//                     size: 22,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   title,
//                   style: UserDashboardFonts.bodyText.copyWith(
//                     color: isDark ? Colors.white : Colors.black87,
//                     fontWeight: FontWeight.w700,
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           ...items,
//         ],
//       ),
//     );
//   }

//   // Enhanced Settings Tile
//   Widget _buildEnhancedSettingsTile({
//     required BuildContext context,
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//     required bool isDark,
//     required SettingsProvider provider,
//     bool showArrow = true,
//   }) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color:
//                       (isDark ? ThemeConfig.darkBlueAccent : provider.deepBlue)
//                           .withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   icon,
//                   color:
//                       isDark ? ThemeConfig.darkBlueAccent : provider.deepBlue,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: UserDashboardFonts.bodyText.copyWith(
//                         color: isDark ? Colors.white : Colors.black87,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 15,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       subtitle,
//                       style: UserDashboardFonts.smallText.copyWith(
//                         color: isDark ? Colors.white70 : Colors.grey[600],
//                         fontSize: 13,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               if (showArrow)
//                 Icon(
//                   Icons.arrow_forward_ios,
//                   color: isDark ? Colors.white54 : const Color(0xFF757575),
//                   size: 16,
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Divider
//   Widget _buildDivider(bool isDark) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       height: 1,
//       color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200],
//     );
//   }

//   // Enhanced Logout Button
//   Widget _buildEnhancedLogoutButton(
//       BuildContext context, bool isDark, SettingsProvider provider) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.red.withOpacity(0.1),
//             Colors.red.withOpacity(0.05),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: Colors.red.withOpacity(0.2),
//           width: 1,
//         ),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: _signOut,
//           borderRadius: BorderRadius.circular(16),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.logout_rounded,
//                   color: Colors.red,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Sign Out',
//                   style: UserDashboardFonts.bodyText.copyWith(
//                     color: Colors.red,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                   ),
//                 ),
//                 if (_isSigningOut) ...[
//                   const SizedBox(width: 12),
//                   const SizedBox(
//                     width: 16,
//                     height: 16,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Compact settings section for mobile
//   Widget _buildCompactSettingsSection({
//     required BuildContext context,
//     required String title,
//     required IconData icon,
//     required List<Widget> items,
//     required bool isDark,
//     required SettingsProvider provider,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: isDark ? ThemeConfig.darkSurface : Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: isDark
//                 ? Colors.black.withOpacity(0.05)
//                 : Colors.grey.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(6),
//                   decoration: BoxDecoration(
//                     color: (isDark
//                             ? ThemeConfig.darkBlueAccent
//                             : provider.deepBlue)
//                         .withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(
//                     icon,
//                     color:
//                         isDark ? ThemeConfig.darkBlueAccent : provider.deepBlue,
//                     size: 20,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   title,
//                   style: UserDashboardFonts.extraLargeTextSemiBold.copyWith(
//                     color: isDark ? Colors.white : Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           ...items,
//         ],
//       ),
//     );
//   }

//   Widget _buildModernSettingsTile({
//     required BuildContext context,
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//     required bool isDark,
//     required SettingsProvider provider,
//   }) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color:
//                       (isDark ? ThemeConfig.darkBlueAccent : provider.deepBlue)
//                           .withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Icon(
//                   icon,
//                   color:
//                       isDark ? ThemeConfig.darkBlueAccent : provider.deepBlue,
//                   size: 22,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: UserDashboardFonts.largeTextMedium.copyWith(
//                         color: isDark ? Colors.white : Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       subtitle,
//                       style: UserDashboardFonts.bodyText.copyWith(
//                         color: isDark ? Colors.white70 : Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.arrow_forward_ios,
//                 color: isDark ? Colors.white54 : const Color(0xFF757575),
//                 size: 16,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildThemeToggleTile(
//       BuildContext context, bool isDark, SettingsProvider provider) {
//     return Consumer<ThemeProvider>(
//       builder: (context, themeProvider, child) {
//         return Material(
//           color: Colors.transparent,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: (isDark
//                             ? ThemeConfig.darkBlueAccent
//                             : provider.deepBlue)
//                         .withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(
//                     themeProvider.isDarkMode
//                         ? Icons.dark_mode_rounded
//                         : Icons.light_mode_rounded,
//                     color:
//                         isDark ? ThemeConfig.darkBlueAccent : provider.deepBlue,
//                     size: 22,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Dark Mode',
//                         style: TextStyle(
//                           color:
//                               isDark ? Colors.white : const Color(0xFF1A1A1A),
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         'Switch between light and dark themes',
//                         style: TextStyle(
//                           color:
//                               isDark ? Colors.white70 : const Color(0xFF424242),
//                           fontSize: 14,
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Switch.adaptive(
//                   value: themeProvider.isDarkMode,
//                   onChanged: (_) => themeProvider.toggleTheme(),
//                   activeColor:
//                       isDark ? ThemeConfig.darkBlueAccent : provider.deepBlue,
//                   activeTrackColor:
//                       (isDark ? ThemeConfig.darkBlueAccent : provider.deepBlue)
//                           .withOpacity(0.3),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // Compact settings tile for mobile
//   Widget _buildCompactSettingsTile({
//     required BuildContext context,
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//     required bool isDark,
//     required SettingsProvider provider,
//   }) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(8),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color:
//                       (isDark ? ThemeConfig.darkBlueAccent : provider.deepBlue)
//                           .withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   icon,
//                   color:
//                       isDark ? ThemeConfig.darkBlueAccent : provider.deepBlue,
//                   size: 18,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: UserDashboardFonts.bodyText.copyWith(
//                         color: isDark ? Colors.white : Colors.black87,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 14,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       subtitle,
//                       style: UserDashboardFonts.smallText.copyWith(
//                         color: isDark ? Colors.white70 : Colors.grey[600],
//                         fontSize: 12,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.arrow_forward_ios,
//                 color: isDark ? Colors.white54 : const Color(0xFF757575),
//                 size: 14,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Theme selection tile
//   Widget _buildThemeSelectionTile(
//       BuildContext context, bool isDark, SettingsProvider provider) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () => _showThemeSelection(context, isDark, provider),
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color:
//                       (isDark ? ThemeConfig.darkBlueAccent : provider.deepBlue)
//                           .withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   provider.getCurrentThemeIcon(),
//                   color:
//                       isDark ? ThemeConfig.darkBlueAccent : provider.deepBlue,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Theme',
//                       style: UserDashboardFonts.bodyText.copyWith(
//                         color: isDark ? Colors.white : const Color(0xFF1A1A1A),
//                         fontWeight: FontWeight.w600,
//                         fontSize: 15,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       provider.getCurrentThemeName(),
//                       style: UserDashboardFonts.smallText.copyWith(
//                         color:
//                             isDark ? Colors.white70 : const Color(0xFF424242),
//                         fontSize: 13,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.arrow_forward_ios,
//                 color: isDark ? Colors.white54 : const Color(0xFF757575),
//                 size: 16,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Theme selection modal
//   void _showThemeSelection(
//       BuildContext context, bool isDark, SettingsProvider provider) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         height: MediaQuery.of(context).size.height * 0.7,
//         decoration: BoxDecoration(
//           color: isDark ? ThemeConfig.darkSurface : Colors.white,
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: Column(
//           children: [
//             // Handle bar
//             Container(
//               margin: const EdgeInsets.only(top: 12),
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: isDark ? Colors.white24 : Colors.grey[300],
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             // Header
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.palette_rounded,
//                     color:
//                         isDark ? ThemeConfig.darkBlueAccent : provider.deepBlue,
//                     size: 24,
//                   ),
//                   const SizedBox(width: 12),
//                   Text(
//                     'Choose Theme',
//                     style: UserDashboardFonts.titleText.copyWith(
//                       color: isDark ? Colors.white : const Color(0xFF1A1A1A),
//                       fontSize: 20,
//                     ),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: Icon(
//                       Icons.close,
//                       color: isDark ? Colors.white70 : const Color(0xFF424242),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Theme grid
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: GridView.builder(
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     childAspectRatio: 1.4, // Increased to make cards shorter
//                     crossAxisSpacing: 12,
//                     mainAxisSpacing: 12,
//                   ),
//                   itemCount: ThemeConfig.getAllThemes().length,
//                   itemBuilder: (context, index) {
//                     final theme = ThemeConfig.getAllThemes()[index];
//                     final isSelected = provider.selectedTheme == theme;
//                     final colors = ThemeConfig.getThemeColors(theme, isDark);

//                     return _buildThemeCard(
//                       context: context,
//                       theme: theme,
//                       colors: colors,
//                       isSelected: isSelected,
//                       isDark: isDark,
//                       onTap: () {
//                         provider.setTheme(theme);
//                         Navigator.pop(context);
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Theme card widget
//   Widget _buildThemeCard({
//     required BuildContext context,
//     required ThemeType theme,
//     required Map<String, Color> colors,
//     required bool isSelected,
//     required bool isDark,
//     required VoidCallback onTap,
//   }) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: theme == ThemeType.ocean
//                   ? [
//                       const Color(0xFF1976D2),
//                       const Color(0xFF0D47A1)
//                     ] // Original darker blue gradient for ocean theme
//                   : [
//                       colors['gradientStart']!,
//                       colors['gradientEnd']!,
//                     ],
//             ),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: isSelected
//                   ? (isDark ? ThemeConfig.darkBlueAccent : colors['primary']!)
//                   : Colors.transparent,
//               width: 2,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: (isSelected ? colors['primary']! : Colors.black)
//                     .withOpacity(isSelected ? 0.3 : 0.1),
//                 blurRadius: isSelected ? 12 : 6,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Stack(
//             children: [
//               // Theme preview circles
//               Positioned(
//                 top: 12,
//                 right: 12,
//                 child: Container(
//                   width: 20,
//                   height: 20,
//                   decoration: BoxDecoration(
//                     color: colors['primary']!.withOpacity(0.3),
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ),
//               Positioned(
//                 top: 20,
//                 right: 20,
//                 child: Container(
//                   width: 12,
//                   height: 12,
//                   decoration: BoxDecoration(
//                     color: colors['accent']!.withOpacity(0.4),
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ),
//               Positioned(
//                 bottom: 16,
//                 left: 12,
//                 child: Container(
//                   width: 16,
//                   height: 16,
//                   decoration: BoxDecoration(
//                     color: colors['blueAccent']!.withOpacity(0.3),
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ),
//               // Content
//               Padding(
//                 padding: const EdgeInsets.all(12), // Reduced padding
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Icon(
//                       ThemeConfig.getThemeIcon(theme),
//                       color: theme == ThemeType.ocean
//                           ? Colors.white
//                           : colors['text'],
//                       size: 20, // Reduced icon size
//                     ),
//                     const SizedBox(height: 6), // Reduced spacing
//                     Text(
//                       ThemeConfig.getThemeName(theme),
//                       style: TextStyle(
//                         color: theme == ThemeType.ocean
//                             ? Colors.white
//                             : colors['text'],
//                         fontSize: 14, // Reduced font size
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 2), // Reduced spacing
//                     Text(
//                       ThemeConfig.getThemeDescription(theme),
//                       style: TextStyle(
//                         color: theme == ThemeType.ocean
//                             ? Colors.white.withOpacity(0.9)
//                             : colors['text']!.withOpacity(0.7),
//                         fontSize: 10, // Reduced font size
//                       ),
//                       maxLines: 1, // Reduced to 1 line
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     if (isSelected) ...[
//                       const SizedBox(height: 4), // Reduced spacing
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.check_circle,
//                             color: colors['primary'],
//                             size: 14, // Reduced icon size
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             'Selected',
//                             style: TextStyle(
//                               color: colors['primary'],
//                               fontSize: 10, // Reduced font size
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Compact logout button
//   Widget _buildCompactLogoutButton(
//       BuildContext context, bool isDark, SettingsProvider provider) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: isDark ? ThemeConfig.darkSurface : Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: isDark
//                 ? Colors.black.withOpacity(0.05)
//                 : Colors.grey.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: _signOut,
//           borderRadius: BorderRadius.circular(12),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.red.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(
//                     Icons.logout_rounded,
//                     color: Colors.red,
//                     size: 18,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     'Sign Out',
//                     style: UserDashboardFonts.bodyText.copyWith(
//                       color: Colors.red,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//                 if (_isSigningOut)
//                   const SizedBox(
//                     width: 16,
//                     height: 16,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLogoutButton(
//       BuildContext context, bool isDark, SettingsProvider provider) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: isDark ? ThemeConfig.darkSurface : Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: isDark
//                 ? Colors.black.withOpacity(0.1)
//                 : Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: _isSigningOut ? null : () => _showLogoutDialog(context),
//           borderRadius: BorderRadius.circular(16),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: Colors.red.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(
//                     Icons.logout_rounded,
//                     color: Colors.red,
//                     size: 22,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Sign Out',
//                         style: TextStyle(
//                           color: Colors.red,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         'Securely sign out of your account',
//                         style: TextStyle(
//                           color: isDark ? Colors.white70 : Colors.grey[600],
//                           fontSize: 14,
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (_isSigningOut)
//                   const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
//                     ),
//                   )
//                 else
//                   Icon(
//                     Icons.arrow_forward_ios,
//                     color: Colors.red.withOpacity(0.7),
//                     size: 16,
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         final isDark = Theme.of(context).brightness == Brightness.dark;
//         return AlertDialog(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           backgroundColor: isDark ? ThemeConfig.darkSurface : Colors.white,
//           title: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.red.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   Icons.logout_rounded,
//                   color: Colors.red,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 'Sign Out',
//                 style: TextStyle(
//                   color: isDark ? Colors.white : Colors.black87,
//                   fontSize: 20,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//           content: Text(
//             'Are you sure you want to sign out? You\'ll need to sign in again to access your account.',
//             style: TextStyle(
//               color: isDark ? Colors.white70 : Colors.grey[600],
//               fontSize: 16,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(dialogContext).pop(),
//               child: Text(
//                 'Cancel',
//                 style: TextStyle(
//                   color: isDark ? Colors.white70 : Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: _isSigningOut
//                   ? null
//                   : () {
//                       Navigator.of(dialogContext).pop();
//                       _signOut();
//                     },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               ),
//               child: _isSigningOut
//                   ? const SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                       ),
//                     )
//                   : const Text(
//                       'Sign Out',
//                       style: TextStyle(fontWeight: FontWeight.w600),
//                     ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _changePassword() async {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           backgroundColor: isDark ? ThemeConfig.darkSurface : Colors.white,
//           title: Row(
//             children: [
//               Icon(
//                 Icons.lock_outline_rounded,
//                 color: isDark ? ThemeConfig.darkBlueAccent : Colors.blue,
//                 size: 24,
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 'Change Password',
//                 style: UserDashboardFonts.bodyText.copyWith(
//                   color: isDark ? Colors.white : Colors.black87,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'We will send a password reset link to your email address.',
//                 style: UserDashboardFonts.bodyText.copyWith(
//                   color: isDark ? Colors.white70 : Colors.grey[600],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Email: ${_auth.currentUser?.email ?? 'Not available'}',
//                 style: UserDashboardFonts.smallText.copyWith(
//                   color: isDark ? Colors.white60 : Colors.grey[500],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text(
//                 'Cancel',
//                 style: UserDashboardFonts.bodyText.copyWith(
//                   color: isDark ? Colors.white70 : Colors.grey[600],
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.pop(context); // Close dialog first
//                 await _sendPasswordResetEmail(isDark);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor:
//                     isDark ? ThemeConfig.darkBlueAccent : Colors.blue,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: Text(
//                 'Send Reset Link',
//                 style: UserDashboardFonts.bodyText.copyWith(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _sendPasswordResetEmail(bool isDark) async {
//     try {
//       final email = _auth.currentUser?.email;
//       if (email != null) {
//         await _auth.sendPasswordResetEmail(email: email);

//         // Show success dialog
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               backgroundColor: isDark ? ThemeConfig.darkSurface : Colors.white,
//               title: Row(
//                 children: [
//                   Icon(
//                     Icons.check_circle,
//                     color: Colors.green,
//                     size: 24,
//                   ),
//                   const SizedBox(width: 12),
//                   Text(
//                     'Email Sent!',
//                     style: UserDashboardFonts.bodyText.copyWith(
//                       color: isDark ? Colors.white : Colors.black87,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//               content: Text(
//                 'Password reset link has been sent to your email address. Please check your inbox and follow the instructions.',
//                 style: UserDashboardFonts.bodyText.copyWith(
//                   color: isDark ? Colors.white70 : Colors.grey[600],
//                 ),
//               ),
//               actions: [
//                 ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: Text(
//                     'OK',
//                     style: UserDashboardFonts.bodyText.copyWith(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       }
//     } catch (e) {
//       // Show error dialog
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             backgroundColor: isDark ? ThemeConfig.darkSurface : Colors.white,
//             title: Row(
//               children: [
//                 Icon(
//                   Icons.error,
//                   color: Colors.red,
//                   size: 24,
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Error',
//                   style: UserDashboardFonts.bodyText.copyWith(
//                     color: isDark ? Colors.white : Colors.black87,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//             content: Text(
//               'Failed to send password reset email: $e',
//               style: UserDashboardFonts.bodyText.copyWith(
//                 color: isDark ? Colors.white70 : Colors.grey[600],
//               ),
//             ),
//             actions: [
//               ElevatedButton(
//                 onPressed: () => Navigator.pop(context),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: Text(
//                   'OK',
//                   style: UserDashboardFonts.bodyText.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }

//   // New methods for enhanced functionality
//   void _showEditProfile(
//       BuildContext context, SettingsProvider provider, bool isDark) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => _buildEditProfileModal(context, provider, isDark),
//     );
//   }

//   Widget _buildEditProfileModal(
//       BuildContext context, SettingsProvider provider, bool isDark) {
//     return _PremiumEditProfileForm(provider: provider, isDark: isDark);
//   }

//   void _showNotificationSettings(BuildContext context, bool isDark) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => _buildNotificationSettingsSheet(context, isDark),
//     );
//   }

//   // Enhanced notification settings with clean white design
//   Widget _buildNotificationSettingsSheet(BuildContext context, bool isDark) {

//     return Container(
//       height: MediaQuery.of(context).size.height * 0.85,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: isDark 
//             ? [
//                 const Color(0xFF1A1A1A),
//                 const Color(0xFF2A2A2A),
//               ]
//             : [
//                 Colors.white,
//                 const Color(0xFFF8FAFC),
//               ],
//           stops: const [0.0, 1.0],
//         ),
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 15,
//             offset: const Offset(0, -3),
//             spreadRadius: 1,
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Handle bar
//           Container(
//             margin: const EdgeInsets.only(top: 12),
//             width: 50,
//             height: 5,
//             decoration: BoxDecoration(
//               color: isDark ? Colors.white.withOpacity(0.3) : Colors.grey[400],
//               borderRadius: BorderRadius.circular(3),
//             ),
//           ),

          
//           // Header
//           Container(
//             margin: const EdgeInsets.all(20),
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: isDark 
//                 ? Colors.white.withOpacity(0.05)
//                 : Colors.grey[50],
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: isDark 
//                   ? Colors.white.withOpacity(0.1)
//                   : Colors.grey[200]!,
//                 width: 1,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: isDark 
//                       ? Colors.white.withOpacity(0.1)
//                       : Colors.grey[100],
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(
//                     Icons.notifications_active_rounded,
//                     color: isDark ? Colors.white : Colors.grey[700],
//                     size: 28,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Notification Settings',
//                         style: UserDashboardFonts.largeTextSemiBold.copyWith(
//                           color: isDark ? Colors.white : Colors.grey[800],
//                           fontSize: 20,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'Customize your notification preferences',
//                         style: UserDashboardFonts.smallText.copyWith(
//                           color: isDark 
//                             ? Colors.white.withOpacity(0.7)
//                             : Colors.grey[600],
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: isDark 
//                       ? Colors.white.withOpacity(0.1)
//                       : Colors.grey[100],
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: Icon(
//                       Icons.close_rounded,
//                       color: isDark ? Colors.white : Colors.grey[700],
//                       size: 24,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Content
//           Expanded(
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 20),
//               decoration: BoxDecoration(
//                 color: isDark 
//                   ? Colors.white.withOpacity(0.03)
//                   : Colors.grey[25],
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(
//                   color: isDark 
//                     ? Colors.white.withOpacity(0.05)
//                     : Colors.grey[100]!,
//                   width: 1,
//                 ),
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(16),
//                     child: SingleChildScrollView(
//                       padding: const EdgeInsets.all(20),
//                       child: Consumer<SettingsProvider>(
//                         builder: (context, provider, child) {
//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Master Toggle
//                               _buildCleanNotificationCard(
//                                 context: context,
//                                 isDark: isDark,
//                                 provider: provider,
//                                 title: 'All Notifications',
//                                 subtitle:
//                                     'Master control for all notifications',
//                                 value: provider.notificationsEnabled,
//                                 onChanged: (value) =>
//                                     provider.updateNotificationSettings(
//                                   notificationsEnabled: value,
//                                 ),
//                                 icon: Icons.notifications_active_rounded,
//                                 accentColor: Colors.blue,
//                                 isMaster: true,
//                               ),
//                               const SizedBox(height: 20),

//                               // Notification Types Section
//                               _buildCleanSectionHeader('Notification Types', isDark),
//                               const SizedBox(height: 16),

//                               // Ban Period Notifications
//                               _buildCleanNotificationCard(
//                                 context: context,
//                                 isDark: isDark,
//                                 provider: provider,
//                                 title: 'Ban Period Updates',
//                                 subtitle: 'Fishing ban period notifications',
//                                 value: provider.banPeriodNotifications,
//                                 onChanged: (value) =>
//                                     provider.updateNotificationSettings(
//                                   banPeriodNotifications: value,
//                                 ),
//                                 icon: Icons.block_rounded,
//                                 accentColor: Colors.red,
//                                 enabled: provider.notificationsEnabled,
//                               ),
//                               const SizedBox(height: 12),

//                               // Marine Conditions Notifications
//                               _buildCleanNotificationCard(
//                                 context: context,
//                                 isDark: isDark,
//                                 provider: provider,
//                                 title: 'Marine Conditions',
//                                 subtitle: 'Weather and sea condition alerts',
//                                 value: provider.marineConditionsNotifications,
//                                 onChanged: (value) =>
//                                     provider.updateNotificationSettings(
//                                   marineConditionsNotifications: value,
//                                 ),
//                                 icon: Icons.water_drop_rounded,
//                                 accentColor: Colors.cyan,
//                                 enabled: provider.notificationsEnabled,
//                               ),
//                               const SizedBox(height: 12),

//                               // Education Notifications
//                               _buildCleanNotificationCard(
//                                 context: context,
//                                 isDark: isDark,
//                                 provider: provider,
//                                 title: 'Education Updates',
//                                 subtitle:
//                                     'New educational content and resources',
//                                 value: provider.educationNotifications,
//                                 onChanged: (value) =>
//                                     provider.updateNotificationSettings(
//                                   educationNotifications: value,
//                                 ),
//                                 icon: Icons.school_rounded,
//                                 accentColor: Colors.purple,
//                                 enabled: provider.notificationsEnabled,
//                               ),
//                               const SizedBox(height: 12),

//                               // Complaint Notifications
//                               _buildCleanNotificationCard(
//                                 context: context,
//                                 isDark: isDark,
//                                 provider: provider,
//                                 title: 'Complaint Updates',
//                                 subtitle: 'Status updates on your reports',
//                                 value: provider.complaintNotifications,
//                                 onChanged: (value) =>
//                                     provider.updateNotificationSettings(
//                                   complaintNotifications: value,
//                                 ),
//                                 icon: Icons.report_problem_rounded,
//                                 accentColor: Colors.orange,
//                                 enabled: provider.notificationsEnabled,
//                               ),
//                               const SizedBox(height: 20),

//                               // Delivery Methods Section
//                               _buildCleanSectionHeader('Delivery Method', isDark),
//                               const SizedBox(height: 16),

//                               // Push Notifications
//                               _buildCleanNotificationCard(
//                                 context: context,
//                                 isDark: isDark,
//                                 provider: provider,
//                                 title: 'Push Notifications',
//                                 subtitle:
//                                     'Receive notifications on your device',
//                                 value: provider.pushNotificationsEnabled,
//                                 onChanged: (value) =>
//                                     provider.updateNotificationSettings(
//                                   pushNotificationsEnabled: value,
//                                 ),
//                                 icon: Icons.phone_android_rounded,
//                                 accentColor: Colors.green,
//                                 enabled: provider.notificationsEnabled,
//                               ),
//                               const SizedBox(height: 20),
//                             ],
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // Build decorative bubbles for the background
//   List<Widget> _buildDecorativeBubbles(
//       bool isDark, Map<String, Color> themeColors) {
//     return [
//       // Top right bubble
//       Positioned(
//         top: -80,
//         right: -80,
//         child: Container(
//           width: 200,
//           height: 200,
//           decoration: BoxDecoration(
//             gradient: RadialGradient(
//               colors: [
//                 Colors.white.withOpacity(0.1),
//                 Colors.transparent,
//               ],
//               stops: const [0.0, 1.0],
//             ),
//             shape: BoxShape.circle,
//           ),
//         ),
//       ),
//       // Bottom left bubble
//       Positioned(
//         bottom: -100,
//         left: -100,
//         child: Container(
//           width: 250,
//           height: 250,
//           decoration: BoxDecoration(
//             gradient: RadialGradient(
//               colors: [
//                 Colors.white.withOpacity(0.08),
//                 Colors.transparent,
//               ],
//               stops: const [0.0, 1.0],
//             ),
//             shape: BoxShape.circle,
//           ),
//         ),
//       ),
//       // Center small bubble
//       Positioned(
//         top: 200,
//         right: 20,
//         child: Container(
//           width: 80,
//           height: 80,
//           decoration: BoxDecoration(
//             gradient: RadialGradient(
//               colors: [
//                 Colors.white.withOpacity(0.06),
//                 Colors.transparent,
//               ],
//               stops: const [0.0, 1.0],
//             ),
//             shape: BoxShape.circle,
//           ),
//         ),
//       ),
//     ];
//   }

//   // Build section header
//   Widget _buildSectionHeader(String title, bool isDark) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.white.withOpacity(0.1),
//             Colors.white.withOpacity(0.05),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: Colors.white.withOpacity(0.2),
//           width: 1,
//         ),
//       ),
//       child: Text(
//         title,
//         style: UserDashboardFonts.bodyText.copyWith(
//           color: Colors.white,
//           fontWeight: FontWeight.w600,
//           fontSize: 16,
//         ),
//       ),
//     );
//   }

//   // Enhanced notification card with gradients
//   Widget _buildEnhancedNotificationCard({
//     required BuildContext context,
//     required bool isDark,
//     required SettingsProvider provider,
//     required String title,
//     required String subtitle,
//     required bool value,
//     required ValueChanged<bool> onChanged,
//     required IconData icon,
//     required List<Color> gradientColors,
//     bool enabled = true,
//     bool isMaster = false,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: enabled
//             ? LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.white.withOpacity(0.15),
//                   Colors.white.withOpacity(0.05),
//                 ],
//               )
//             : LinearGradient(
//                 colors: [
//                   Colors.white.withOpacity(0.05),
//                   Colors.white.withOpacity(0.02),
//                 ],
//               ),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: enabled
//               ? Colors.white.withOpacity(0.3)
//               : Colors.white.withOpacity(0.1),
//           width: 1,
//         ),
//         boxShadow: enabled
//             ? [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ]
//             : null,
//       ),
//       child: Row(
//         children: [
//           // Icon container with gradient
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               gradient: enabled
//                   ? LinearGradient(
//                       colors: gradientColors,
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     )
//                   : LinearGradient(
//                       colors: [
//                         Colors.white.withOpacity(0.1),
//                         Colors.white.withOpacity(0.05),
//                       ],
//                     ),
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: enabled
//                   ? [
//                       BoxShadow(
//                         color: gradientColors.first.withOpacity(0.3),
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ]
//                   : null,
//             ),
//             child: Icon(
//               icon,
//               color: enabled ? Colors.white : Colors.white.withOpacity(0.4),
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: UserDashboardFonts.bodyText.copyWith(
//                     color:
//                         enabled ? Colors.white : Colors.white.withOpacity(0.6),
//                     fontWeight: isMaster ? FontWeight.w700 : FontWeight.w600,
//                     fontSize: isMaster ? 16 : 15,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   subtitle,
//                   style: UserDashboardFonts.smallText.copyWith(
//                     color: enabled
//                         ? Colors.white.withOpacity(0.8)
//                         : Colors.white.withOpacity(0.4),
//                     fontSize: 13,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Enhanced switch
//           Container(
//             decoration: BoxDecoration(
//               gradient: enabled && value
//                   ? LinearGradient(
//                       colors: gradientColors,
//                     )
//                   : LinearGradient(
//                       colors: [
//                         Colors.white.withOpacity(0.2),
//                         Colors.white.withOpacity(0.1),
//                       ],
//                     ),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Switch(
//               value: enabled ? value : false,
//               onChanged: enabled ? onChanged : null,
//               activeColor: Colors.white,
//               inactiveThumbColor: Colors.white.withOpacity(0.6),
//               inactiveTrackColor: Colors.white.withOpacity(0.2),
//               materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showLanguageSettings(BuildContext context, bool isDark) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         backgroundColor: isDark ? ThemeConfig.darkSurface : Colors.white,
//         title: Row(
//           children: [
//             Icon(Icons.language_rounded,
//                 color: isDark ? ThemeConfig.darkBlueAccent : Colors.purple),
//             const SizedBox(width: 12),
//             Text(
//               'Language Settings',
//               style: UserDashboardFonts.bodyText.copyWith(
//                 color: isDark ? Colors.white : Colors.black87,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: SupportedLanguage.values.map((language) {
//             final settingsProvider =
//                 Provider.of<SettingsProvider>(context, listen: false);
//             final isSelected = settingsProvider.selectedLanguage == language;
//             return ListTile(
//               leading: Icon(
//                 isSelected
//                     ? Icons.radio_button_checked
//                     : Icons.radio_button_unchecked,
//                 color: isSelected
//                     ? (isDark ? ThemeConfig.darkBlueAccent : Colors.purple)
//                     : (isDark ? Colors.white70 : Colors.grey[600]),
//               ),
//               title: Text(
//                 settingsProvider.getLanguageName(language),
//                 style: UserDashboardFonts.bodyText.copyWith(
//                   color: isDark ? Colors.white : Colors.black87,
//                   fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//                 ),
//               ),
//               subtitle: Text(
//                 settingsProvider.getLanguageNativeName(language),
//                 style: UserDashboardFonts.smallText.copyWith(
//                   color: isDark ? Colors.white70 : Colors.grey[600],
//                 ),
//               ),
//               onTap: () {
//                 settingsProvider.setLanguage(language);
//                 Navigator.pop(context);

//                 // Show success message
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('Language updated successfully'),
//                     backgroundColor: Colors.green,
//                     behavior: SnackBarBehavior.floating,
//                   ),
//                 );
//               },
//             );
//           }).toList(),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: UserDashboardFonts.bodyText.copyWith(
//                 color: isDark ? ThemeConfig.darkBlueAccent : Colors.purple,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showStorageSettings(BuildContext context, bool isDark) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         backgroundColor: isDark ? ThemeConfig.darkSurface : Colors.white,
//         title: Row(
//           children: [
//             Icon(Icons.storage_rounded,
//                 color: isDark ? ThemeConfig.darkBlueAccent : Colors.purple),
//             const SizedBox(width: 12),
//             Text(
//               'Storage Settings',
//               style: UserDashboardFonts.bodyText.copyWith(
//                 color: isDark ? Colors.white : Colors.black87,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//         content: Text(
//           'Storage management functionality coming soon!',
//           style: UserDashboardFonts.bodyText.copyWith(
//             color: isDark ? Colors.white70 : Colors.grey[600],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Close',
//               style: UserDashboardFonts.bodyText.copyWith(
//                 color: isDark ? ThemeConfig.darkBlueAccent : Colors.purple,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showContactSupport(BuildContext context, bool isDark) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         backgroundColor: isDark ? ThemeConfig.darkSurface : Colors.white,
//         title: Row(
//           children: [
//             Icon(Icons.contact_support_rounded,
//                 color: isDark ? ThemeConfig.darkBlueAccent : Colors.green),
//             const SizedBox(width: 12),
//             Text(
//               'Contact Support',
//               style: UserDashboardFonts.bodyText.copyWith(
//                 color: isDark ? Colors.white : Colors.black87,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Get help and support for Marine Guard',
//               style: UserDashboardFonts.bodyText.copyWith(
//                 color: isDark ? Colors.white70 : Colors.grey[600],
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: () {
//                       Navigator.pop(context);
//                       // Open email client
//                     },
//                     icon: Icon(Icons.email, size: 16),
//                     label: Text('Email'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor:
//                           isDark ? ThemeConfig.darkBlueAccent : Colors.green,
//                       foregroundColor: Colors.white,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: () {
//                       Navigator.pop(context);
//                       // Open phone dialer
//                     },
//                     icon: Icon(Icons.phone, size: 16),
//                     label: Text('Call'),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor:
//                           isDark ? ThemeConfig.darkBlueAccent : Colors.green,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Close',
//               style: UserDashboardFonts.bodyText.copyWith(
//                 color: isDark ? ThemeConfig.darkBlueAccent : Colors.green,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _signOut() async {
//     // Note: GoogleSignIn constructor has changed, using alternative approach
//     // final googleSignIn = GoogleSignIn();

//     if (!mounted) return;
//     setState(() {
//       _isSigningOut = true;
//     });

//     try {
//       await IntroCardManager.resetIntroCards();

//       User? currentUser = FirebaseAuth.instance.currentUser;
//       bool signedInWithGoogle = false;
//       if (currentUser != null) {
//         for (UserInfo userInfo in currentUser.providerData) {
//           if (userInfo.providerId == GoogleAuthProvider.PROVIDER_ID) {
//             signedInWithGoogle = true;
//             break;
//           }
//         }
//       }

//       if (signedInWithGoogle) {
//         // Note: GoogleSignIn API has changed, skipping signOut
//         // await googleSignIn.signOut();
//       }

//       await FirebaseAuth.instance.signOut();

//       if (mounted) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => const LoginPage()),
//         );
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error signing out: $e');
//       }
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error signing out: ${e.toString()}')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSigningOut = false;
//         });
//       }
//     }
//   }

//   // Two-Factor Authentication Tile
//   Widget _buildTwoFactorAuthTile(
//       BuildContext context, bool isDark, SettingsProvider provider) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () => _show2FASettings(context, isDark, provider),
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color:
//                       (isDark ? ThemeConfig.darkBlueAccent : provider.deepBlue)
//                           .withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   provider.get2FAMethodIcon(),
//                   color:
//                       isDark ? ThemeConfig.darkBlueAccent : provider.deepBlue,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Two-Factor Authentication',
//                       style: UserDashboardFonts.bodyText.copyWith(
//                         color: isDark ? Colors.white : Colors.black87,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 15,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       provider.is2FAEnabled
//                           ? 'Enabled via ${provider.get2FAMethodDisplayName()}'
//                           : 'Add an extra layer of security',
//                       style: UserDashboardFonts.smallText.copyWith(
//                         color: isDark ? Colors.white70 : Colors.grey[600],
//                         fontSize: 13,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Row(
//                 children: [
//                   if (provider.is2FAEnabled)
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.green.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(12),
//                         border:
//                             Border.all(color: Colors.green.withOpacity(0.3)),
//                       ),
//                       child: Text(
//                         'ON',
//                         style: UserDashboardFonts.smallText.copyWith(
//                           color: Colors.green,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 11,
//                         ),
//                       ),
//                     ),
//                   const SizedBox(width: 8),
//                   Icon(
//                     Icons.arrow_forward_ios,
//                     color: isDark ? Colors.white54 : const Color(0xFF757575),
//                     size: 14,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Show 2FA Settings Dialog
//   void _show2FASettings(
//       BuildContext context, bool isDark, SettingsProvider provider) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => _build2FASettingsSheet(context, isDark, provider),
//     );
//   }

//   // 2FA Settings Bottom Sheet
//   Widget _build2FASettingsSheet(
//       BuildContext context, bool isDark, SettingsProvider provider) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.7,
//       decoration: BoxDecoration(
//         color: isDark ? ThemeConfig.darkSurface : Colors.white,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         children: [
//           // Handle bar
//           Container(
//             margin: const EdgeInsets.only(top: 12),
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: isDark ? Colors.white24 : Colors.grey[300],
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           // Header
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.security_rounded,
//                   color:
//                       isDark ? ThemeConfig.darkBlueAccent : provider.deepBlue,
//                   size: 24,
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Two-Factor Authentication',
//                   style: UserDashboardFonts.largeTextSemiBold.copyWith(
//                     color: isDark ? Colors.white : Colors.black87,
//                     fontSize: 18,
//                   ),
//                 ),
//                 const Spacer(),
//                 IconButton(
//                   onPressed: () => Navigator.pop(context),
//                   icon: Icon(
//                     Icons.close,
//                     color: isDark ? Colors.white70 : Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Content
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Current Status
//                   _build2FAStatusCard(context, isDark, provider),
//                   const SizedBox(height: 20),

//                   // Method Selection
//                   Text(
//                     'Authentication Method',
//                     style: UserDashboardFonts.bodyText.copyWith(
//                       color: isDark ? Colors.white : Colors.black87,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 16,
//                     ),
//                   ),
//                   const SizedBox(height: 12),

//                   // SMS Only
//                   _build2FAMethodCard(
//                     context: context,
//                     isDark: isDark,
//                     provider: provider,
//                     method: TwoFactorMethod.sms,
//                     title: 'SMS Authentication',
//                     subtitle: 'Receive verification codes via text message',
//                     icon: Icons.sms,
//                     color: Colors.green,
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // 2FA Status Card
//   Widget _build2FAStatusCard(
//       BuildContext context, bool isDark, SettingsProvider provider) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: provider.is2FAEnabled
//             ? Colors.green.withOpacity(0.1)
//             : Colors.orange.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: provider.is2FAEnabled
//               ? Colors.green.withOpacity(0.3)
//               : Colors.orange.withOpacity(0.3),
//         ),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             provider.is2FAEnabled ? Icons.check_circle : Icons.warning,
//             color: provider.is2FAEnabled ? Colors.green : Colors.orange,
//             size: 24,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   provider.is2FAEnabled ? '2FA Enabled' : '2FA Disabled',
//                   style: UserDashboardFonts.bodyText.copyWith(
//                     color: isDark ? Colors.white : Colors.black87,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 15,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   provider.is2FAEnabled
//                       ? 'Your account is protected with ${provider.get2FAMethodDisplayName()}'
//                       : 'Add an extra layer of security to your account',
//                   style: UserDashboardFonts.smallText.copyWith(
//                     color: isDark ? Colors.white70 : Colors.grey[600],
//                     fontSize: 13,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // 2FA Method Card
//   Widget _build2FAMethodCard({
//     required BuildContext context,
//     required bool isDark,
//     required SettingsProvider provider,
//     required TwoFactorMethod method,
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required Color color,
//   }) {
//     final isSelected = provider.selected2FAMethod == method;
//     final isEnabled = provider.is2FAEnabled && isSelected;

//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () =>
//             _handle2FAMethodSelection(context, isDark, provider, method),
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: isSelected
//                 ? color.withOpacity(0.1)
//                 : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50]),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: isSelected
//                   ? color.withOpacity(0.3)
//                   : (isDark
//                       ? Colors.white.withOpacity(0.1)
//                       : Colors.grey[200]!),
//             ),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   icon,
//                   color: color,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: UserDashboardFonts.bodyText.copyWith(
//                         color: isDark ? Colors.white : Colors.black87,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 15,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       subtitle,
//                       style: UserDashboardFonts.smallText.copyWith(
//                         color: isDark ? Colors.white70 : Colors.grey[600],
//                         fontSize: 13,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               if (isEnabled)
//                 Icon(
//                   Icons.check_circle,
//                   color: Colors.green,
//                   size: 20,
//                 )
//               else if (isSelected)
//                 Icon(
//                   Icons.radio_button_checked,
//                   color: color,
//                   size: 20,
//                 )
//               else
//                 Icon(
//                   Icons.radio_button_unchecked,
//                   color: isDark ? Colors.white30 : Colors.grey[400],
//                   size: 20,
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Handle 2FA Method Selection
//   void _handle2FAMethodSelection(BuildContext context, bool isDark,
//       SettingsProvider provider, TwoFactorMethod method) {
//     if (provider.is2FAEnabled && provider.selected2FAMethod == method) {
//       // Disable 2FA
//       _showDisable2FADialog(context, isDark, provider);
//     } else {
//       // Enable 2FA with selected method
//       if (method == TwoFactorMethod.sms) {
//         _UsersettingsPageState._showSMSPhoneNumberDialog(
//             context, isDark, provider);
//       } else {
//         _showEnable2FADialog(context, isDark, provider, method);
//       }
//     }
//   }

//   // Show Enable 2FA Dialog
//   void _showEnable2FADialog(BuildContext context, bool isDark,
//       SettingsProvider provider, TwoFactorMethod method) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: isDark ? ThemeConfig.darkSurface : Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text(
//           'Enable Two-Factor Authentication',
//           style: UserDashboardFonts.bodyText.copyWith(
//             color: isDark ? Colors.white : Colors.black87,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         content: Text(
//           'Are you sure you want to enable ${provider.get2FAMethodDisplayName()} for two-factor authentication?',
//           style: UserDashboardFonts.smallText.copyWith(
//             color: isDark ? Colors.white70 : Colors.grey[600],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style:
//                   TextStyle(color: isDark ? Colors.white70 : Colors.grey[600]),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               provider.enable2FA(method);
//               Navigator.pop(context);
//               Navigator.pop(context); // Close the bottom sheet too
//               FloatingMessageService().showSuccess(
//                 context,
//                 '2FA enabled with ${provider.get2FAMethodDisplayName()}',
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: provider.deepBlue,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8)),
//             ),
//             child: const Text('Enable'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Show Disable 2FA Dialog
//   void _showDisable2FADialog(
//       BuildContext context, bool isDark, SettingsProvider provider) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: isDark ? ThemeConfig.darkSurface : Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text(
//           'Disable Two-Factor Authentication',
//           style: UserDashboardFonts.bodyText.copyWith(
//             color: isDark ? Colors.white : Colors.black87,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         content: Text(
//           'Are you sure you want to disable two-factor authentication? This will make your account less secure.',
//           style: UserDashboardFonts.smallText.copyWith(
//             color: isDark ? Colors.white70 : Colors.grey[600],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style:
//                   TextStyle(color: isDark ? Colors.white70 : Colors.grey[600]),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               provider.disable2FA();
//               Navigator.pop(context);
//               Navigator.pop(context); // Close the bottom sheet too
//               FloatingMessageService().showWarning(
//                 context,
//                 '2FA disabled',
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8)),
//             ),
//             child: const Text('Disable'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Show SMS Phone Number Dialog - User Dashboard Style
//   static void _showSMSPhoneNumberDialog(
//       BuildContext context, bool isDark, SettingsProvider provider) {
//     final phoneController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (dialogContext) => Dialog(
//         backgroundColor: Colors.transparent,
//         child: Container(
//           constraints: const BoxConstraints(maxWidth: 400),
//           decoration: BoxDecoration(
//             color: isDark ? ThemeConfig.darkSurface : Colors.white,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: isDark
//                     ? Colors.black.withOpacity(0.1)
//                     : Colors.grey.withOpacity(0.08),
//                 blurRadius: 12,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Header Section - User Dashboard Style
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
//                 child: Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [
//                             (isDark
//                                     ? ThemeConfig.darkBlueAccent
//                                     : provider.deepBlue)
//                                 .withOpacity(0.1),
//                             (isDark
//                                     ? ThemeConfig.darkBlueAccent
//                                     : provider.deepBlue)
//                                 .withOpacity(0.05),
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Icon(
//                         Icons.sms_rounded,
//                         color: isDark
//                             ? ThemeConfig.darkBlueAccent
//                             : provider.deepBlue,
//                         size: 22,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         'SMS Two-Factor Authentication',
//                         style: UserDashboardFonts.bodyText.copyWith(
//                           color: isDark ? Colors.white : Colors.black87,
//                           fontWeight: FontWeight.w700,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () => Navigator.pop(dialogContext),
//                       icon: Icon(
//                         Icons.close,
//                         color: isDark ? Colors.white70 : Colors.grey[600],
//                         size: 20,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Divider
//               Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 20),
//                 height: 1,
//                 color:
//                     isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200],
//               ),

//               // Content Area
//               Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//                     // Description Text
//                     Text(
//                       'Enter your phone number to receive verification codes',
//                       textAlign: TextAlign.center,
//                       style: UserDashboardFonts.bodyText.copyWith(
//                         color: isDark ? Colors.white70 : Colors.grey[600],
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     // Phone Number Input - User Dashboard Style
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         color: isDark
//                             ? Colors.white.withOpacity(0.05)
//                             : Colors.grey[50],
//                         border: Border.all(
//                           color: isDark
//                               ? Colors.white.withOpacity(0.1)
//                               : Colors.grey[200]!,
//                           width: 1,
//                         ),
//                       ),
//                       child: TextField(
//                         controller: phoneController,
//                         keyboardType: TextInputType.phone,
//                         maxLength: 11,
//                         textAlign: TextAlign.center,
//                         style: UserDashboardFonts.bodyText.copyWith(
//                           fontSize: 16,
//                           letterSpacing: 1.5,
//                           fontWeight: FontWeight.w600,
//                           color: isDark ? Colors.white : Colors.black87,
//                         ),
//                         decoration: InputDecoration(
//                           hintText: '09xxxxxxxxx',
//                           hintStyle: UserDashboardFonts.bodyText.copyWith(
//                             fontSize: 16,
//                             letterSpacing: 1.5,
//                             color: isDark ? Colors.white30 : Colors.grey[400],
//                             fontWeight: FontWeight.w500,
//                           ),
//                           prefixIcon: Icon(
//                             Icons.phone_rounded,
//                             color: isDark
//                                 ? ThemeConfig.darkBlueAccent
//                                 : provider.deepBlue,
//                             size: 20,
//                           ),
//                           counterText: '',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(
//                               color: isDark
//                                   ? ThemeConfig.darkBlueAccent
//                                   : provider.deepBlue,
//                               width: 2,
//                             ),
//                           ),
//                           filled: true,
//                           fillColor: Colors.transparent,
//                           contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 16,
//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 8),

//                     // Info Note - User Dashboard Style
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 8),
//                       decoration: BoxDecoration(
//                         color: (isDark
//                                 ? ThemeConfig.darkBlueAccent
//                                 : provider.deepBlue)
//                             .withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(
//                           color: (isDark
//                                   ? ThemeConfig.darkBlueAccent
//                                   : provider.deepBlue)
//                               .withOpacity(0.2),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             Icons.info_outline_rounded,
//                             color: isDark
//                                 ? ThemeConfig.darkBlueAccent
//                                 : provider.deepBlue,
//                             size: 16,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             'Example: 09123456789',
//                             style: UserDashboardFonts.smallText.copyWith(
//                               color: isDark ? Colors.white70 : Colors.grey[600],
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 24),

//                     // Action Buttons - User Dashboard Style
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Container(
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12),
//                               color: isDark
//                                   ? Colors.white.withOpacity(0.1)
//                                   : Colors.grey[100],
//                               border: Border.all(
//                                 color: isDark
//                                     ? Colors.white.withOpacity(0.2)
//                                     : Colors.grey[300]!,
//                               ),
//                             ),
//                             child: TextButton(
//                               onPressed: () => Navigator.pop(dialogContext),
//                               style: TextButton.styleFrom(
//                                 padding:
//                                     const EdgeInsets.symmetric(vertical: 14),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                               child: Text(
//                                 'Cancel',
//                                 style: UserDashboardFonts.bodyText.copyWith(
//                                   color: isDark
//                                       ? Colors.white70
//                                       : Colors.grey[600],
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Container(
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12),
//                               gradient: LinearGradient(
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                                 colors: [
//                                   isDark
//                                       ? ThemeConfig.darkBlueAccent
//                                       : provider.deepBlue,
//                                   (isDark
//                                           ? ThemeConfig.darkBlueAccent
//                                           : provider.deepBlue)
//                                       .withOpacity(0.8),
//                                 ],
//                               ),
//                             ),
//                             child: ElevatedButton(
//                               onPressed: () async {
//                                 if (phoneController.text.isEmpty) {
//                                   FloatingMessageService().showError(
//                                     dialogContext,
//                                     'Please enter a phone number',
//                                   );
//                                   return;
//                                 }

//                                 // Close the phone number dialog first
//                                 Navigator.pop(dialogContext);

//                                 // Get the root context for proper navigation
//                                 final rootContext =
//                                     Navigator.of(context, rootNavigator: true)
//                                         .context;

//                                 // Show loading dialog
//                                 showDialog(
//                                   context: rootContext,
//                                   barrierDismissible: false,
//                                   builder: (loadingContext) => AlertDialog(
//                                     backgroundColor: isDark
//                                         ? ThemeConfig.darkSurface
//                                         : Colors.white,
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(16)),
//                                     content: Row(
//                                       children: [
//                                         CircularProgressIndicator(
//                                           valueColor:
//                                               AlwaysStoppedAnimation<Color>(
//                                             isDark
//                                                 ? ThemeConfig.darkBlueAccent
//                                                 : provider.deepBlue,
//                                           ),
//                                         ),
//                                         const SizedBox(width: 16),
//                                         Text(
//                                           'Sending verification code...',
//                                           style: UserDashboardFonts.bodyText
//                                               .copyWith(
//                                             color: isDark
//                                                 ? Colors.white
//                                                 : Colors.black87,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 );

//                                 try {
//                                   // Enable 2FA with SMS method
//                                   provider.enable2FA(TwoFactorMethod.sms);

//                                   Navigator.pop(
//                                       rootContext); // Close loading dialog

//                                   FloatingMessageService().showSuccess(
//                                     rootContext,
//                                     'SMS Two-Factor Authentication enabled successfully!',
//                                     duration: const Duration(seconds: 3),
//                                   );
//                                 } catch (e) {
//                                   Navigator.pop(
//                                       rootContext); // Close loading dialog
//                                   FloatingMessageService().showError(
//                                     rootContext,
//                                     'Error enabling SMS 2FA: ${e.toString()}',
//                                   );
//                                 }
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.transparent,
//                                 shadowColor: Colors.transparent,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 padding:
//                                     const EdgeInsets.symmetric(vertical: 14),
//                               ),
//                               child: Text(
//                                 'Enable 2FA',
//                                 style: UserDashboardFonts.bodyText.copyWith(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w700,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//   // Build clean section header
//   Widget _buildCleanSectionHeader(String title, bool isDark) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: isDark 
//           ? Colors.white.withOpacity(0.05)
//           : Colors.grey[100],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isDark 
//             ? Colors.white.withOpacity(0.1)
//             : Colors.grey[200]!,
//           width: 1,
//         ),
//       ),
//       child: Text(
//         title,
//         style: UserDashboardFonts.bodyText.copyWith(
//           color: isDark ? Colors.white : Colors.grey[800],
//           fontWeight: FontWeight.w600,
//           fontSize: 16,
//         ),
//       ),
//     );
//   }

//   // Clean notification card with simple design
//   Widget _buildCleanNotificationCard({
//     required BuildContext context,
//     required bool isDark,
//     required SettingsProvider provider,
//     required String title,
//     required String subtitle,
//     required bool value,
//     required ValueChanged<bool> onChanged,
//     required IconData icon,
//     required Color accentColor,
//     bool enabled = true,
//     bool isMaster = false,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: enabled
//             ? (isDark 
//                 ? Colors.white.withOpacity(0.05)
//                 : Colors.white)
//             : (isDark 
//                 ? Colors.white.withOpacity(0.02)
//                 : Colors.grey[50]),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: enabled
//               ? (isDark 
//                   ? Colors.white.withOpacity(0.1)
//                   : Colors.grey[200]!)
//               : (isDark 
//                   ? Colors.white.withOpacity(0.05)
//                   : Colors.grey[100]!),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           // Icon container with accent color
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: enabled
//                   ? accentColor.withOpacity(0.1)
//                   : (isDark 
//                       ? Colors.white.withOpacity(0.05)
//                       : Colors.grey[100]),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               icon,
//               color: enabled 
//                   ? accentColor
//                   : (isDark 
//                       ? Colors.white.withOpacity(0.4)
//                       : Colors.grey[400]),
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: UserDashboardFonts.bodyText.copyWith(
//                     color: enabled 
//                         ? (isDark ? Colors.white : Colors.grey[800])
//                         : (isDark 
//                             ? Colors.white.withOpacity(0.5)
//                             : Colors.grey[500]),
//                     fontWeight: isMaster ? FontWeight.w700 : FontWeight.w600,
//                     fontSize: isMaster ? 16 : 15,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   subtitle,
//                   style: UserDashboardFonts.smallText.copyWith(
//                     color: enabled
//                         ? (isDark 
//                             ? Colors.white.withOpacity(0.7)
//                             : Colors.grey[600])
//                         : (isDark 
//                             ? Colors.white.withOpacity(0.4)
//                             : Colors.grey[400]),
//                     fontSize: 13,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Clean switch
//           Switch(
//             value: enabled ? value : false,
//             onChanged: enabled ? onChanged : null,
//             activeColor: accentColor,
//             inactiveThumbColor: isDark 
//                 ? Colors.white.withOpacity(0.3)
//                 : Colors.grey[300],
//             inactiveTrackColor: isDark 
//                 ? Colors.white.withOpacity(0.1)
//                 : Colors.grey[200],
//             materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class FullScreenProfileView extends StatelessWidget {
//   final String imageUrl;
//   final String username;

//   const FullScreenProfileView({
//     Key? key,
//     required this.imageUrl,
//     required this.username,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: isDark ? ThemeConfig.darkBackground : Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: Container(
//           margin: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Colors.black.withOpacity(0.3),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: IconButton(
//             icon: const Icon(
//               Icons.arrow_back_ios_new,
//               color: Colors.white,
//               size: 20,
//             ),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//         ),
//         title: Text(
//           username,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: InteractiveViewer(
//           minScale: 0.5,
//           maxScale: 4.0,
//           child: Container(
//             margin: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.3),
//                   blurRadius: 20,
//                   offset: const Offset(0, 10),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(20),
//               child: Image.network(
//                 imageUrl,
//                 fit: BoxFit.contain,
//                 loadingBuilder: (context, child, loadingProgress) {
//                   if (loadingProgress == null) return child;
//                   return Container(
//                     width: 200,
//                     height: 200,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[800],
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           CircularProgressIndicator(
//                             value: loadingProgress.expectedTotalBytes != null
//                                 ? loadingProgress.cumulativeBytesLoaded /
//                                     loadingProgress.expectedTotalBytes!
//                                 : null,
//                             valueColor: AlwaysStoppedAnimation<Color>(
//                               isDark
//                                   ? ThemeConfig.darkBlueAccent
//                                   : Colors.white,
//                             ),
//                             strokeWidth: 3,
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             'Loading image...',
//                             style: TextStyle(
//                               color: Colors.white70,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//                 errorBuilder: (context, error, stackTrace) {
//                   return Container(
//                     width: 200,
//                     height: 200,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[800],
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.error_outline_rounded,
//                           color: Colors.red[300],
//                           size: 48,
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'Error loading image',
//                           style: TextStyle(
//                             color: Colors.white70,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Tap to retry',
//                           style: TextStyle(
//                             color: Colors.white54,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Two-Factor Authentication Tile
//   Widget _buildTwoFactorAuthTile(
//       BuildContext context, bool isDark, SettingsProvider provider) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () => _show2FASettings(context, isDark, provider),
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color:
//                       (isDark ? ThemeConfig.darkBlueAccent : provider.deepBlue)
//                           .withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   provider.get2FAMethodIcon(),
//                   color:
//                       isDark ? ThemeConfig.darkBlueAccent : provider.deepBlue,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Two-Factor Authentication',
//                       style: UserDashboardFonts.bodyText.copyWith(
//                         color: isDark ? Colors.white : Colors.black87,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 15,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       provider.is2FAEnabled
//                           ? 'Enabled via ${provider.get2FAMethodDisplayName()}'
//                           : 'Add an extra layer of security',
//                       style: UserDashboardFonts.smallText.copyWith(
//                         color: isDark ? Colors.white70 : Colors.grey[600],
//                         fontSize: 13,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Row(
//                 children: [
//                   if (provider.is2FAEnabled)
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.green.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(12),
//                         border:
//                             Border.all(color: Colors.green.withOpacity(0.3)),
//                       ),
//                       child: Text(
//                         'ON',
//                         style: UserDashboardFonts.smallText.copyWith(
//                           color: Colors.green,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 11,
//                         ),
//                       ),
//                     ),
//                   const SizedBox(width: 8),
//                   Icon(
//                     Icons.arrow_forward_ios,
//                     color: isDark ? Colors.white54 : const Color(0xFF757575),
//                     size: 14,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Show 2FA Settings Dialog
//   void _show2FASettings(
//       BuildContext context, bool isDark, SettingsProvider provider) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => _build2FASettingsSheet(context, isDark, provider),
//     );
//   }

//   // 2FA Settings Bottom Sheet
//   Widget _build2FASettingsSheet(
//       BuildContext context, bool isDark, SettingsProvider provider) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.7,
//       decoration: BoxDecoration(
//         color: isDark ? ThemeConfig.darkSurface : Colors.white,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         children: [
//           // Handle bar
//           Container(
//             margin: const EdgeInsets.only(top: 12),
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: isDark ? Colors.white24 : Colors.grey[300],
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           // Header
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.security_rounded,
//                   color:
//                       isDark ? ThemeConfig.darkBlueAccent : provider.deepBlue,
//                   size: 24,
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Two-Factor Authentication',
//                   style: UserDashboardFonts.largeTextSemiBold.copyWith(
//                     color: isDark ? Colors.white : Colors.black87,
//                     fontSize: 18,
//                   ),
//                 ),
//                 const Spacer(),
//                 IconButton(
//                   onPressed: () => Navigator.pop(context),
//                   icon: Icon(
//                     Icons.close,
//                     color: isDark ? Colors.white70 : Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Content
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Current Status
//                   _build2FAStatusCard(context, isDark, provider),
//                   const SizedBox(height: 20),

//                   // Method Selection
//                   Text(
//                     'Authentication Method',
//                     style: UserDashboardFonts.bodyText.copyWith(
//                       color: isDark ? Colors.white : Colors.black87,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 16,
//                     ),
//                   ),
//                   const SizedBox(height: 12),

//                   // SMS Only
//                   _build2FAMethodCard(
//                     context: context,
//                     isDark: isDark,
//                     provider: provider,
//                     method: TwoFactorMethod.sms,
//                     title: 'SMS Authentication',
//                     subtitle: 'Receive verification codes via text message',
//                     icon: Icons.sms,
//                     color: Colors.green,
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // 2FA Status Card
//   Widget _build2FAStatusCard(
//       BuildContext context, bool isDark, SettingsProvider provider) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: provider.is2FAEnabled
//             ? Colors.green.withOpacity(0.1)
//             : Colors.orange.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: provider.is2FAEnabled
//               ? Colors.green.withOpacity(0.3)
//               : Colors.orange.withOpacity(0.3),
//         ),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             provider.is2FAEnabled ? Icons.check_circle : Icons.warning,
//             color: provider.is2FAEnabled ? Colors.green : Colors.orange,
//             size: 24,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   provider.is2FAEnabled ? '2FA Enabled' : '2FA Disabled',
//                   style: UserDashboardFonts.bodyText.copyWith(
//                     color: isDark ? Colors.white : Colors.black87,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 15,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   provider.is2FAEnabled
//                       ? 'Your account is protected with ${provider.get2FAMethodDisplayName()}'
//                       : 'Add an extra layer of security to your account',
//                   style: UserDashboardFonts.smallText.copyWith(
//                     color: isDark ? Colors.white70 : Colors.grey[600],
//                     fontSize: 13,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // 2FA Method Card
//   Widget _build2FAMethodCard({
//     required BuildContext context,
//     required bool isDark,
//     required SettingsProvider provider,
//     required TwoFactorMethod method,
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required Color color,
//   }) {
//     final isSelected = provider.selected2FAMethod == method;
//     final isEnabled = provider.is2FAEnabled && isSelected;

//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () =>
//             _handle2FAMethodSelection(context, isDark, provider, method),
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: isSelected
//                 ? color.withOpacity(0.1)
//                 : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50]),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: isSelected
//                   ? color.withOpacity(0.3)
//                   : (isDark
//                       ? Colors.white.withOpacity(0.1)
//                       : Colors.grey[200]!),
//             ),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   icon,
//                   color: color,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: UserDashboardFonts.bodyText.copyWith(
//                         color: isDark ? Colors.white : Colors.black87,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 15,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       subtitle,
//                       style: UserDashboardFonts.smallText.copyWith(
//                         color: isDark ? Colors.white70 : Colors.grey[600],
//                         fontSize: 13,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               if (isEnabled)
//                 Icon(
//                   Icons.check_circle,
//                   color: Colors.green,
//                   size: 20,
//                 )
//               else if (isSelected)
//                 Icon(
//                   Icons.radio_button_checked,
//                   color: color,
//                   size: 20,
//                 )
//               else
//                 Icon(
//                   Icons.radio_button_unchecked,
//                   color: isDark ? Colors.white30 : Colors.grey[400],
//                   size: 20,
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Handle 2FA Method Selection
//   void _handle2FAMethodSelection(BuildContext context, bool isDark,
//       SettingsProvider provider, TwoFactorMethod method) {
//     if (provider.is2FAEnabled && provider.selected2FAMethod == method) {
//       // Disable 2FA
//       _showDisable2FADialog(context, isDark, provider);
//     } else {
//       // Enable 2FA with selected method
//       if (method == TwoFactorMethod.sms) {
//         _UsersettingsPageState._showSMSPhoneNumberDialog(
//             context, isDark, provider);
//       } else {
//         _showEnable2FADialog(context, isDark, provider, method);
//       }
//     }
//   }

//   // Show Enable 2FA Dialog
//   void _showEnable2FADialog(BuildContext context, bool isDark,
//       SettingsProvider provider, TwoFactorMethod method) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: isDark ? ThemeConfig.darkSurface : Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text(
//           'Enable Two-Factor Authentication',
//           style: UserDashboardFonts.bodyText.copyWith(
//             color: isDark ? Colors.white : Colors.black87,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         content: Text(
//           'Are you sure you want to enable ${provider.get2FAMethodDisplayName()} for two-factor authentication?',
//           style: UserDashboardFonts.smallText.copyWith(
//             color: isDark ? Colors.white70 : Colors.grey[600],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style:
//                   TextStyle(color: isDark ? Colors.white70 : Colors.grey[600]),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               provider.enable2FA(method);
//               Navigator.pop(context);
//               Navigator.pop(context); // Close the bottom sheet too
//               FloatingMessageService().showSuccess(
//                 context,
//                 '2FA enabled with ${provider.get2FAMethodDisplayName()}',
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: provider.deepBlue,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8)),
//             ),
//             child: const Text('Enable'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Show Disable 2FA Dialog
//   void _showDisable2FADialog(
//       BuildContext context, bool isDark, SettingsProvider provider) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: isDark ? ThemeConfig.darkSurface : Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text(
//           'Disable Two-Factor Authentication',
//           style: UserDashboardFonts.bodyText.copyWith(
//             color: isDark ? Colors.white : Colors.black87,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         content: Text(
//           'Are you sure you want to disable two-factor authentication? This will make your account less secure.',
//           style: UserDashboardFonts.smallText.copyWith(
//             color: isDark ? Colors.white70 : Colors.grey[600],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style:
//                   TextStyle(color: isDark ? Colors.white70 : Colors.grey[600]),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               provider.disable2FA();
//               Navigator.pop(context);
//               Navigator.pop(context); // Close the bottom sheet too
//               FloatingMessageService().showWarning(
//                 context,
//                 '2FA disabled',
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8)),
//             ),
//             child: const Text('Disable'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _PremiumEditProfileForm extends StatefulWidget {
//   final SettingsProvider provider;
//   final bool isDark;

//   const _PremiumEditProfileForm({
//     required this.provider,
//     required this.isDark,
//   });

//   @override
//   State<_PremiumEditProfileForm> createState() =>
//       _PremiumEditProfileFormState();
// }

// class _PremiumEditProfileFormState extends State<_PremiumEditProfileForm> {
//   late TextEditingController _nameController;
//   late TextEditingController _emailController;
//   late TextEditingController _phoneController;
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//   String? _selectedImageUrl;

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: widget.provider.username);
//     _emailController = TextEditingController(text: widget.provider.email);
//     _phoneController =
//         TextEditingController(text: widget.provider.phoneNumber ?? '');
//     _selectedImageUrl = widget.provider.profilePictureUrl;
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }

//   Future<void> _selectImage() async {
//     try {
//       final ImagePicker picker = ImagePicker();
//       final XFile? image = await picker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1024,
//         maxHeight: 1024,
//         imageQuality: 85,
//       );

//       if (image != null) {
//         setState(() {
//           _selectedImageUrl = image.path;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error selecting image: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _saveProfile() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       String? finalImageUrl = _selectedImageUrl;

//       // If a new image was selected, upload it first
//       if (_selectedImageUrl != null &&
//           _selectedImageUrl != widget.provider.profilePictureUrl &&
//           !_selectedImageUrl!.startsWith('http')) {
//         // Here you would typically upload to Firebase Storage
//         // For now, we'll use the local path as a placeholder
//         // In a real app, you'd upload to Firebase Storage and get the download URL
//         finalImageUrl = _selectedImageUrl;
//       }

//       final success = await widget.provider.updateUserProfile(
//         displayName: _nameController.text.trim(),
//         email: _emailController.text.trim(),
//         phoneNumber: _phoneController.text.trim().isNotEmpty
//             ? _phoneController.text.trim()
//             : null,
//         photoURL: finalImageUrl,
//       );

//       if (success && mounted) {
//         Navigator.pop(context);
//         FloatingMessageService().showSuccess(
//           context,
//           'Profile updated successfully!',
//           duration: const Duration(seconds: 3),
//         );
//       } else if (mounted) {
//         FloatingMessageService().showError(
//           context,
//           'Failed to update profile. Please try again.',
//           duration: const Duration(seconds: 4),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         FloatingMessageService().showError(
//           context,
//           'Error updating profile: $e',
//           duration: const Duration(seconds: 4),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeColors = widget.provider.getCurrentThemeColors(widget.isDark);
//     final primaryColor = themeColors['primary']!;
//     final cardColor = themeColors['card']!;
//     final textColor = themeColors['text']!;
//     final accentColor = themeColors['blueAccent']!;

//     return Container(
//       height: MediaQuery.of(context).size.height * 0.9,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: widget.isDark
//               ? [
//                   const Color(0xFF1A1A1A),
//                   const Color(0xFF2C2C2C),
//                   const Color(0xFF1A1A1A),
//                 ]
//               : [
//                   const Color(0xFFF8FAFC),
//                   const Color(0xFFF1F5F9),
//                   const Color(0xFFE2E8F0),
//                 ],
//           stops: const [0.0, 0.5, 1.0],
//         ),
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
//         boxShadow: [
//           BoxShadow(
//             color: primaryColor.withOpacity(0.15),
//             blurRadius: 30,
//             offset: const Offset(0, -10),
//             spreadRadius: 5,
//           ),
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 20,
//             offset: const Offset(0, -5),
//             spreadRadius: 0,
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           // Decorative background elements
//           if (!widget.isDark) ...[
//             Positioned(
//               top: -50,
//               right: -50,
//               child: Container(
//                 width: 150,
//                 height: 150,
//                 decoration: BoxDecoration(
//                   gradient: RadialGradient(
//                     colors: [
//                       accentColor.withOpacity(0.1),
//                       accentColor.withOpacity(0.05),
//                       Colors.transparent,
//                     ],
//                     stops: const [0.0, 0.5, 1.0],
//                   ),
//                   shape: BoxShape.circle,
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: -30,
//               left: -30,
//               child: Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   gradient: RadialGradient(
//                     colors: [
//                       primaryColor.withOpacity(0.08),
//                       primaryColor.withOpacity(0.03),
//                       Colors.transparent,
//                     ],
//                     stops: const [0.0, 0.6, 1.0],
//                   ),
//                   shape: BoxShape.circle,
//                 ),
//               ),
//             ),
//           ],

//           // Main content
//           Padding(
//             padding: EdgeInsets.fromLTRB(
//                 24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
//             child: Form(
//               key: _formKey,
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     // Premium handle bar
//                     Container(
//                       width: 50,
//                       height: 5,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             primaryColor.withOpacity(0.3),
//                             primaryColor.withOpacity(0.6),
//                             primaryColor.withOpacity(0.3),
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(3),
//                       ),
//                     ),
//                     const SizedBox(height: 24),

//                     // Premium title with icon
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 20, vertical: 12),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [
//                             primaryColor.withOpacity(0.1),
//                             accentColor.withOpacity(0.05),
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: primaryColor.withOpacity(0.2),
//                           width: 1,
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [primaryColor, accentColor],
//                               ),
//                               borderRadius: BorderRadius.circular(12),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: primaryColor.withOpacity(0.3),
//                                   blurRadius: 8,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: const Icon(
//                               Icons.person_rounded,
//                               color: Colors.white,
//                               size: 20,
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Text(
//                             'Edit Profile',
//                             style: UserDashboardFonts.largeHeadingText.copyWith(
//                               color: textColor,
//                               fontSize: 22,
//                               fontWeight: FontWeight.w700,
//                               letterSpacing: 0.5,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20),

//                     // Premium Profile Picture Section
//                     Container(
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [
//                             cardColor,
//                             cardColor.withOpacity(0.8),
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(24),
//                         border: Border.all(
//                           color: primaryColor.withOpacity(0.1),
//                           width: 1,
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: primaryColor.withOpacity(0.08),
//                             blurRadius: 20,
//                             offset: const Offset(0, 8),
//                             spreadRadius: 0,
//                           ),
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 10,
//                             offset: const Offset(0, 2),
//                             spreadRadius: 0,
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         children: [
//                           GestureDetector(
//                             onTap: _selectImage,
//                             child: Container(
//                               width: 120,
//                               height: 120,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 gradient: LinearGradient(
//                                   begin: Alignment.topLeft,
//                                   end: Alignment.bottomRight,
//                                   colors: [
//                                     primaryColor.withOpacity(0.1),
//                                     accentColor.withOpacity(0.05),
//                                   ],
//                                 ),
//                                 border: Border.all(
//                                   color: primaryColor.withOpacity(0.3),
//                                   width: 3,
//                                 ),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: primaryColor.withOpacity(0.2),
//                                     blurRadius: 15,
//                                     offset: const Offset(0, 5),
//                                   ),
//                                 ],
//                                 image: _selectedImageUrl != null
//                                     ? DecorationImage(
//                                         image: _selectedImageUrl!
//                                                 .startsWith('http')
//                                             ? NetworkImage(_selectedImageUrl!)
//                                             : FileImage(
//                                                     File(_selectedImageUrl!))
//                                                 as ImageProvider,
//                                         fit: BoxFit.cover,
//                                       )
//                                     : null,
//                               ),
//                               child: _selectedImageUrl == null
//                                   ? Icon(
//                                       Icons.person_rounded,
//                                       size: 60,
//                                       color: primaryColor.withOpacity(0.6),
//                                     )
//                                   : null,
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 16, vertical: 8),
//                             decoration: BoxDecoration(
//                               color: primaryColor.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(20),
//                               border: Border.all(
//                                 color: primaryColor.withOpacity(0.2),
//                                 width: 1,
//                               ),
//                             ),
//                             child: Text(
//                               'Tap to change photo',
//                               style: UserDashboardFonts.bodyText.copyWith(
//                                 color: primaryColor,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                                 letterSpacing: 0.3,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20),

//                     // Premium Form Fields Container
//                     Container(
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [
//                             cardColor,
//                             cardColor.withOpacity(0.9),
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(24),
//                         border: Border.all(
//                           color: primaryColor.withOpacity(0.1),
//                           width: 1,
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: primaryColor.withOpacity(0.08),
//                             blurRadius: 20,
//                             offset: const Offset(0, 8),
//                             spreadRadius: 0,
//                           ),
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 10,
//                             offset: const Offset(0, 2),
//                             spreadRadius: 0,
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         children: [
//                           // Name Field
//                           _buildPremiumTextField(
//                             controller: _nameController,
//                             label: 'Full Name',
//                             icon: Icons.person_outline_rounded,
//                             validator: (value) {
//                               if (value == null || value.trim().isEmpty) {
//                                 return 'Please enter your full name';
//                               }
//                               if (value.trim().length < 2) {
//                                 return 'Name must be at least 2 characters';
//                               }
//                               return null;
//                             },
//                           ),
//                           const SizedBox(height: 16),

//                           // Email Field
//                           _buildPremiumTextField(
//                             controller: _emailController,
//                             label: 'Email Address',
//                             icon: Icons.email_outlined,
//                             keyboardType: TextInputType.emailAddress,
//                             validator: (value) {
//                               if (value == null || value.trim().isEmpty) {
//                                 return 'Please enter your email';
//                               }
//                               if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
//                                   .hasMatch(value.trim())) {
//                                 return 'Please enter a valid email address';
//                               }
//                               return null;
//                             },
//                           ),
//                           const SizedBox(height: 16),

//                           // Phone Field
//                           _buildPremiumTextField(
//                             controller: _phoneController,
//                             label: 'Phone Number (Optional)',
//                             icon: Icons.phone_outlined,
//                             keyboardType: TextInputType.phone,
//                             validator: (value) {
//                               if (value != null && value.trim().isNotEmpty) {
//                                 if (!RegExp(r'^\+?[\d\s\-\(\)]{10,}$')
//                                     .hasMatch(value.trim())) {
//                                   return 'Please enter a valid phone number';
//                                 }
//                               }
//                               return null;
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20),

//                     // Premium Action Buttons
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _buildPremiumOutlinedButton(
//                             text: 'Cancel',
//                             onPressed: _isLoading
//                                 ? null
//                                 : () => Navigator.pop(context),
//                             isSecondary: true,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: _buildPremiumElevatedButton(
//                             text: 'Save Changes',
//                             onPressed: _isLoading ? null : _saveProfile,
//                             isLoading: _isLoading,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPremiumTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//   }) {
//     final themeColors = widget.provider.getCurrentThemeColors(widget.isDark);
//     final primaryColor = themeColors['primary']!;
//     final textColor = themeColors['text']!;
//     final cardColor = themeColors['card']!;

//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             cardColor,
//             cardColor.withOpacity(0.7),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: primaryColor.withOpacity(0.1),
//           width: 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: primaryColor.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: keyboardType,
//         style: UserDashboardFonts.bodyText.copyWith(
//           color: textColor,
//           fontSize: 16,
//           fontWeight: FontWeight.w500,
//         ),
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: UserDashboardFonts.bodyText.copyWith(
//             color: textColor.withOpacity(0.7),
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//           ),
//           prefixIcon: Container(
//             margin: const EdgeInsets.all(8),
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   primaryColor.withOpacity(0.1),
//                   primaryColor.withOpacity(0.05),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               icon,
//               color: primaryColor,
//               size: 20,
//             ),
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide.none,
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide(
//               color: primaryColor.withOpacity(0.3),
//               width: 2,
//             ),
//           ),
//           filled: true,
//           fillColor: Colors.transparent,
//           contentPadding:
//               const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         ),
//         validator: validator,
//       ),
//     );
//   }

//   Widget _buildPremiumOutlinedButton({
//     required String text,
//     required VoidCallback? onPressed,
//     bool isSecondary = false,
//   }) {
//     final themeColors = widget.provider.getCurrentThemeColors(widget.isDark);
//     final primaryColor = themeColors['primary']!;

//     return Container(
//       height: 56,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: isSecondary
//               ? [
//                   Colors.transparent,
//                   primaryColor.withOpacity(0.05),
//                 ]
//               : [
//                   primaryColor.withOpacity(0.1),
//                   primaryColor.withOpacity(0.05),
//                 ],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: primaryColor.withOpacity(0.3),
//           width: 1.5,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: primaryColor.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onPressed,
//           borderRadius: BorderRadius.circular(16),
//           child: Center(
//             child: Text(
//               text,
//               style: UserDashboardFonts.bodyText.copyWith(
//                 color: primaryColor,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//                 letterSpacing: 0.5,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPremiumElevatedButton({
//     required String text,
//     required VoidCallback? onPressed,
//     bool isLoading = false,
//   }) {
//     final themeColors = widget.provider.getCurrentThemeColors(widget.isDark);
//     final primaryColor = themeColors['primary']!;
//     final accentColor = themeColors['blueAccent']!;

//     return Container(
//       height: 56,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             primaryColor,
//             accentColor,
//             primaryColor,
//           ],
//           stops: const [0.0, 0.5, 1.0],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: primaryColor.withOpacity(0.4),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//             spreadRadius: 0,
//           ),
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//             spreadRadius: 0,
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onPressed,
//           borderRadius: BorderRadius.circular(16),
//           child: Center(
//             child: isLoading
//                 ? SizedBox(
//                     height: 24,
//                     width: 24,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2.5,
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     ),
//                   )
//                 : Text(
//                     text,
//                     style: UserDashboardFonts.bodyText.copyWith(
//                       color: Colors.white,
//                       fontSize: 16,
//   // Build clean section header
//   Widget _buildCleanSectionHeader(String title, bool isDark) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: isDark 
//           ? Colors.white.withOpacity(0.05)
//           : Colors.grey[100],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isDark 
//             ? Colors.white.withOpacity(0.1)
//             : Colors.grey[200]!,
//           width: 1,
//         ),
//       ),
//       child: Text(
//         title,
//         style: UserDashboardFonts.bodyText.copyWith(
//           color: isDark ? Colors.white : Colors.grey[800],
//           fontWeight: FontWeight.w600,
//           fontSize: 16,
//         ),
//       ),
//     );
//   }

//   // Clean notification card with simple design
//   Widget _buildCleanNotificationCard({
//     required BuildContext context,
//     required bool isDark,
//     required SettingsProvider provider,
//     required String title,
//     required String subtitle,
//     required bool value,
//     required ValueChanged<bool> onChanged,
//     required IconData icon,
//     required Color accentColor,
//     bool enabled = true,
//     bool isMaster = false,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: enabled
//             ? (isDark 
//                 ? Colors.white.withOpacity(0.05)
//                 : Colors.white)
//             : (isDark 
//                 ? Colors.white.withOpacity(0.02)
//                 : Colors.grey[50]),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: enabled
//               ? (isDark 
//                   ? Colors.white.withOpacity(0.1)
//                   : Colors.grey[200]!)
//               : (isDark 
//                   ? Colors.white.withOpacity(0.05)
//                   : Colors.grey[100]!),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           // Icon container with accent color
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: enabled
//                   ? accentColor.withOpacity(0.1)
//                   : (isDark 
//                       ? Colors.white.withOpacity(0.05)
//                       : Colors.grey[100]),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               icon,
//               color: enabled 
//                   ? accentColor
//                   : (isDark 
//                       ? Colors.white.withOpacity(0.4)
//                       : Colors.grey[400]),
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: UserDashboardFonts.bodyText.copyWith(
//                     color: enabled 
//                         ? (isDark ? Colors.white : Colors.grey[800])
//                         : (isDark 
//                             ? Colors.white.withOpacity(0.5)
//                             : Colors.grey[500]),
//                     fontWeight: isMaster ? FontWeight.w700 : FontWeight.w600,
//                     fontSize: isMaster ? 16 : 15,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   subtitle,
//                   style: UserDashboardFonts.smallText.copyWith(
//                     color: enabled
//                         ? (isDark 
//                             ? Colors.white.withOpacity(0.7)
//                             : Colors.grey[600])
//                         : (isDark 
//                             ? Colors.white.withOpacity(0.4)
//                             : Colors.grey[400]),
//                     fontSize: 13,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Clean switch
//           Switch(
//             value: enabled ? value : false,
//             onChanged: enabled ? onChanged : null,
//             activeColor: accentColor,
//             inactiveThumbColor: isDark 
//                 ? Colors.white.withOpacity(0.3)
//                 : Colors.grey[300],
//             inactiveTrackColor: isDark 
//                 ? Colors.white.withOpacity(0.1)
//                 : Colors.grey[200],
//             materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//           ),
//         ],
//       ),
//     );
//   }
// }
