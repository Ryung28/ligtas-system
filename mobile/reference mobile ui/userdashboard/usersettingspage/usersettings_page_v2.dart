// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:mobileapplication/userdashboard/config/user_dashboard_fonts.dart';
// import 'package:mobileapplication/userdashboard/usersettingspage/usersettings_provider_v2.dart';
// import 'package:mobileapplication/userdashboard/usersettingspage/settings_ui_components.dart';
// import 'package:mobileapplication/userdashboard/usersettingspage/settings_dialogs.dart';
// import 'package:mobileapplication/config/theme_config.dart';

// /// Clean, refactored user settings page following clean architecture principles
// /// Maintains exact functionality and design while improving code structure
// class UserSettingsPageV2 extends StatefulWidget {
//   const UserSettingsPageV2({super.key});

//   @override
//   State<UserSettingsPageV2> createState() => _UserSettingsPageV2State();
// }

// class _UserSettingsPageV2State extends State<UserSettingsPageV2> {
//   late SettingsProviderV2 _provider;

//   @override
//   void initState() {
//     super.initState();
//     _provider = SettingsProviderV2();
//     _provider.initialize();
//   }

//   @override
//   void dispose() {
//     _provider.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     // Set system UI overlay style
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//       statusBarBrightness: Theme.of(context).brightness,
//       statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
//       systemNavigationBarColor:
//           isDark ? ThemeConfig.darkBackground : _provider.whiteWater,
//       systemNavigationBarIconBrightness:
//           isDark ? Brightness.light : Brightness.dark,
//     ));

//     return ChangeNotifierProvider.value(
//       value: _provider,
//       child: WillPopScope(
//         onWillPop: () async {
//           Navigator.of(context).pop();
//           return false;
//         },
//         child: Scaffold(
//           backgroundColor:
//               isDark ? ThemeConfig.darkBackground : Colors.grey[50],
//           extendBody: true,
//           body: Consumer<SettingsProviderV2>(
//             builder: (context, provider, child) {
//               if (provider.isLoading) {
//                 return SettingsUIComponents.buildLoadingState(isDark);
//               }

//               return CustomScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 slivers: [
//                   _buildAppBar(context, provider, isDark),
//                   SliverToBoxAdapter(
//                     child: _buildSettingsContent(context, provider, isDark),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   /// Build modern app bar with profile header
//   Widget _buildAppBar(
//       BuildContext context, SettingsProviderV2 provider, bool isDark) {
//     return SliverAppBar(
//       expandedHeight: 280,
//       floating: false,
//       pinned: true,
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       flexibleSpace: FlexibleSpaceBar(
//         background: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: isDark
//                   ? [
//                       const Color(0xFF1A1A1A),
//                       const Color(0xFF2A2A2A),
//                     ]
//                   : [
//                       provider.deepBlue,
//                       provider.lightBlue,
//                     ],
//             ),
//           ),
//           child: SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const SizedBox(height: 40),
//                   SettingsUIComponents.buildProfileHeader(
//                     username: provider.username,
//                     email: provider.email,
//                     profilePictureUrl: provider.profilePictureUrl,
//                     onImageTap: () =>
//                         _showImageOptions(context, provider, isDark),
//                     onCameraTap: () =>
//                         _pickImageFromCamera(context, provider, isDark),
//                     isDark: isDark,
//                     accentColor: Colors.white,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   /// Build main settings content
//   Widget _buildSettingsContent(
//       BuildContext context, SettingsProviderV2 provider, bool isDark) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 24, 16, 60),
//       child: Column(
//         children: [
//           // Account & Security Section
//           SettingsUIComponents.buildSectionHeader(
//             title: 'Account & Security',
//             icon: Icons.security_rounded,
//             accentColor: Colors.blue,
//             isDark: isDark,
//           ),

//           SettingsUIComponents.buildSettingsTile(
//             title: 'Edit Profile',
//             subtitle: 'Update your personal information',
//             icon: Icons.edit_rounded,
//             accentColor: Colors.blue,
//             isDark: isDark,
//             onTap: () => SettingsDialogs.showEditProfileDialog(
//               context: context,
//               provider: provider,
//               isDark: isDark,
//             ),
//           ),

//           SettingsUIComponents.buildDivider(isDark),

//           SettingsUIComponents.buildSettingsTile(
//             title: 'Change Password',
//             subtitle: 'Update your account password',
//             icon: Icons.lock_outline_rounded,
//             accentColor: Colors.blue,
//             isDark: isDark,
//             onTap: () => SettingsDialogs.showChangePasswordDialog(
//               context: context,
//               provider: provider,
//               isDark: isDark,
//             ),
//           ),

//           SettingsUIComponents.buildDivider(isDark),

//           SettingsUIComponents.buildSettingsTile(
//             title: 'Two-Factor Authentication',
//             subtitle: provider.is2FAEnabled
//                 ? 'SMS authentication enabled'
//                 : 'Secure your account with 2FA',
//             icon: Icons.security_rounded,
//             accentColor: provider.is2FAEnabled ? Colors.green : Colors.orange,
//             isDark: isDark,
//             onTap: () => SettingsDialogs.show2FASettingsDialog(
//               context: context,
//               provider: provider,
//               isDark: isDark,
//             ),
//             trailing: provider.is2FAEnabled
//                 ? Icon(
//                     Icons.check_circle,
//                     color: Colors.green,
//                     size: 20,
//                   )
//                 : null,
//           ),

//           SettingsUIComponents.buildDivider(isDark),

//           SettingsUIComponents.buildSettingsTile(
//             title: 'Notifications',
//             subtitle: 'Manage notification preferences',
//             icon: Icons.notifications_active_rounded,
//             accentColor: Colors.blue,
//             isDark: isDark,
//             onTap: () => SettingsDialogs.showNotificationSettingsDialog(
//               context: context,
//               provider: provider,
//               isDark: isDark,
//             ),
//           ),

//           const SizedBox(height: 24),

//           // App Preferences Section
//           SettingsUIComponents.buildSectionHeader(
//             title: 'App Preferences',
//             icon: Icons.tune_rounded,
//             accentColor: Colors.purple,
//             isDark: isDark,
//           ),

//           SettingsUIComponents.buildSettingsTile(
//             title: 'Theme',
//             subtitle: provider.getCurrentThemeName(),
//             icon: Icons.palette_rounded,
//             accentColor: Colors.purple,
//             isDark: isDark,
//             onTap: () => SettingsDialogs.showThemeSelectionDialog(
//               context: context,
//               provider: provider,
//               isDark: isDark,
//             ),
//           ),

//           SettingsUIComponents.buildDivider(isDark),

//           SettingsUIComponents.buildSettingsTile(
//             title: 'Language',
//             subtitle: provider.getLanguageName(provider.selectedLanguage),
//             icon: Icons.language_rounded,
//             accentColor: Colors.purple,
//             isDark: isDark,
//             onTap: () => SettingsDialogs.showLanguageSelectionDialog(
//               context: context,
//               provider: provider,
//               isDark: isDark,
//             ),
//           ),

//           SettingsUIComponents.buildDivider(isDark),

//           SettingsUIComponents.buildSettingsTile(
//             title: 'Storage',
//             subtitle: 'Manage app storage',
//             icon: Icons.storage_rounded,
//             accentColor: Colors.purple,
//             isDark: isDark,
//             onTap: () => _showStorageSettings(context, isDark),
//           ),

//           const SizedBox(height: 24),

//           // Support Section
//           SettingsUIComponents.buildSectionHeader(
//             title: 'Support',
//             icon: Icons.help_rounded,
//             accentColor: Colors.green,
//             isDark: isDark,
//           ),

//           SettingsUIComponents.buildSettingsTile(
//             title: 'Help & Support',
//             subtitle: 'Get help and contact support',
//             icon: Icons.help_outline_rounded,
//             accentColor: Colors.green,
//             isDark: isDark,
//             onTap: () => _showHelpSupport(context, isDark),
//           ),

//           SettingsUIComponents.buildDivider(isDark),

//           SettingsUIComponents.buildSettingsTile(
//             title: 'About',
//             subtitle: 'App version and information',
//             icon: Icons.info_outline_rounded,
//             accentColor: Colors.green,
//             isDark: isDark,
//             onTap: () => _showAboutDialog(context, isDark),
//           ),

//           SettingsUIComponents.buildDivider(isDark),

//           SettingsUIComponents.buildSettingsTile(
//             title: 'Logout',
//             subtitle: 'Sign out of your account',
//             icon: Icons.logout_rounded,
//             accentColor: Colors.red,
//             isDark: isDark,
//             onTap: () => _showLogoutDialog(context, provider, isDark),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Show image picker options
//   Future<void> _showImageOptions(
//       BuildContext context, SettingsProviderV2 provider, bool isDark) async {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         decoration: BoxDecoration(
//           color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               margin: const EdgeInsets.only(top: 12),
//               width: 50,
//               height: 5,
//               decoration: BoxDecoration(
//                 color:
//                     isDark ? Colors.white.withOpacity(0.3) : Colors.grey[400],
//                 borderRadius: BorderRadius.circular(3),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ListTile(
//               leading: Icon(
//                 Icons.camera_alt,
//                 color: isDark ? Colors.white : Colors.grey[700],
//               ),
//               title: Text(
//                 'Take Photo',
//                 style: UserDashboardFonts.bodyText.copyWith(
//                   color: isDark ? Colors.white : Colors.grey[800],
//                 ),
//               ),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickImageFromCamera(context, provider, isDark);
//               },
//             ),
//             ListTile(
//               leading: Icon(
//                 Icons.photo_library,
//                 color: isDark ? Colors.white : Colors.grey[700],
//               ),
//               title: Text(
//                 'Choose from Gallery',
//                 style: UserDashboardFonts.bodyText.copyWith(
//                   color: isDark ? Colors.white : Colors.grey[800],
//                 ),
//               ),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickImageFromGallery(context, provider, isDark);
//               },
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Pick image from camera
//   Future<void> _pickImageFromCamera(
//       BuildContext context, SettingsProviderV2 provider, bool isDark) async {
//     try {
//       // Implementation for camera picker
//       // This would use ImagePicker to take a photo
//       // For now, we'll show a placeholder message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Camera functionality would be implemented here'),
//           backgroundColor: Colors.blue,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error accessing camera: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   /// Pick image from gallery
//   Future<void> _pickImageFromGallery(
//       BuildContext context, SettingsProviderV2 provider, bool isDark) async {
//     try {
//       // Implementation for gallery picker
//       // This would use ImagePicker to select from gallery
//       // For now, we'll show a placeholder message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Gallery functionality would be implemented here'),
//           backgroundColor: Colors.blue,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error accessing gallery: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   /// Show storage settings
//   void _showStorageSettings(BuildContext context, bool isDark) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: Text(
//           'Storage Settings',
//           style: UserDashboardFonts.largeTextSemiBold.copyWith(
//             color: isDark ? Colors.white : Colors.grey[800],
//           ),
//         ),
//         content: Text(
//           'Storage management features would be implemented here.',
//           style: UserDashboardFonts.bodyText.copyWith(
//             color: isDark ? Colors.white.withOpacity(0.8) : Colors.grey[600],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'OK',
//               style: UserDashboardFonts.bodyText.copyWith(
//                 color: Colors.blue,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Show help and support
//   void _showHelpSupport(BuildContext context, bool isDark) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: Text(
//           'Help & Support',
//           style: UserDashboardFonts.largeTextSemiBold.copyWith(
//             color: isDark ? Colors.white : Colors.grey[800],
//           ),
//         ),
//         content: Text(
//           'Help and support features would be implemented here.',
//           style: UserDashboardFonts.bodyText.copyWith(
//             color: isDark ? Colors.white.withOpacity(0.8) : Colors.grey[600],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'OK',
//               style: UserDashboardFonts.bodyText.copyWith(
//                 color: Colors.blue,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Show about dialog
//   void _showAboutDialog(BuildContext context, bool isDark) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: Text(
//           'About Marine Guard',
//           style: UserDashboardFonts.largeTextSemiBold.copyWith(
//             color: isDark ? Colors.white : Colors.grey[800],
//           ),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Version: 1.0.0',
//               style: UserDashboardFonts.bodyText.copyWith(
//                 color:
//                     isDark ? Colors.white.withOpacity(0.8) : Colors.grey[600],
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Marine Guard is a comprehensive marine management application designed to help protect and monitor marine resources.',
//               style: UserDashboardFonts.bodyText.copyWith(
//                 color:
//                     isDark ? Colors.white.withOpacity(0.8) : Colors.grey[600],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'OK',
//               style: UserDashboardFonts.bodyText.copyWith(
//                 color: Colors.blue,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Show logout confirmation dialog
//   void _showLogoutDialog(
//       BuildContext context, SettingsProviderV2 provider, bool isDark) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: Row(
//           children: [
//             Icon(
//               Icons.logout_rounded,
//               color: Colors.red,
//               size: 24,
//             ),
//             const SizedBox(width: 12),
//             Text(
//               'Logout',
//               style: UserDashboardFonts.largeTextSemiBold.copyWith(
//                 color: isDark ? Colors.white : Colors.grey[800],
//                 fontSize: 18,
//               ),
//             ),
//           ],
//         ),
//         content: Text(
//           'Are you sure you want to logout?',
//           style: UserDashboardFonts.bodyText.copyWith(
//             color: isDark ? Colors.white.withOpacity(0.8) : Colors.grey[600],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: UserDashboardFonts.bodyText.copyWith(
//                 color:
//                     isDark ? Colors.white.withOpacity(0.7) : Colors.grey[600],
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               // Implement logout functionality
//               // This would typically involve:
//               // 1. Sign out from Firebase Auth
//               // 2. Clear local data
//               // 3. Navigate to login screen
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content:
//                       Text('Logout functionality would be implemented here'),
//                   backgroundColor: Colors.blue,
//                 ),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             child: Text(
//               'Logout',
//               style: UserDashboardFonts.bodyText.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
