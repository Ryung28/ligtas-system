// // ignore_for_file: library_private_types_in_public_api

// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:mobileapplication/userdashboard/components/wave_animation.dart';
// import 'package:mobileapplication/userdashboard/ocean_education.dart';
// import 'package:provider/provider.dart';
// import 'package:mobileapplication/userdashboard/userdashboardpage/userdashboard_provider.dart';
// import 'package:mobileapplication/utils/page_transition.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:mobileapplication/providers/navigation_provider.dart';
// import 'package:mobileapplication/userdashboard/config/user_dashboard_fonts.dart';
// import 'package:mobileapplication/userdashboard/usersettingspage/usersettings_provider.dart';

// class OceanEducationHub extends StatefulWidget {
//   const OceanEducationHub({super.key});

//   @override
//   _OceanEducationHubState createState() => _OceanEducationHubState();
// }

// class _OceanEducationHubState extends State<OceanEducationHub>
//     with TickerProviderStateMixin {
//   late AnimationController _contentFadeController;
//   late Animation<double> _fadeAnimation;
//   final ScrollController _scrollController = ScrollController();
//   bool _showScrollToTop = false;

//   // Featured articles - now as a constant for better performance
//   static const List<Map<String, dynamic>> _featuredArticles = [
//     {
//       'title': 'Protecting Coral Reefs',
//       'image': 'assets/EducationalInfoBackground.jpg',
//       'description': 'Learn how we can protect these vital ecosystems'
//     },
//     {
//       'title': 'Marine Biodiversity',
//       'image': 'assets/MarineGaurdBackground.jpg',
//       'description': 'Discover the incredible diversity of ocean life'
//     },
//     {
//       'title': 'Sustainable Fishing',
//       'image': 'assets/EducationalInfoBackground.jpg',
//       'description': 'Best practices for ocean conservation'
//     },
//   ];

//   // Educational categories - now as a constant for better performance
//   static const List<Map<String, dynamic>> _educationCategories = [
//     {
//       'title': 'Marine Life',
//       'icon': CupertinoIcons.sparkles,
//       'subtitle': 'Learn about local marine species',
//       'description': 'Discover the diverse marine life in our oceans',
//     },
//     {
//       'title': 'Conservation',
//       'icon': CupertinoIcons.shield_lefthalf_fill,
//       'subtitle': 'Discover ways to protect our ocean',
//       'description': 'Learn about marine conservation efforts',
//     },
//     {
//       'title': 'Regulations',
//       'icon': CupertinoIcons.doc_text_search,
//       'subtitle': 'Know your marine laws',
//       'description': 'Understand marine regulations and compliance',
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _contentFadeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//         CurvedAnimation(
//             parent: _contentFadeController, curve: Curves.easeOutCirc));

//     _contentFadeController.forward();
//     _scrollController.addListener(_handleScroll);

//     // Initialize navigation provider
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         final navigationProvider =
//             Provider.of<NavigationProvider>(context, listen: false);
//         navigationProvider.initialize();
//       }
//     });
//   }

//   void _handleScroll() {
//     if (mounted) {
//       final bool shouldShowButton = _scrollController.offset > 300;

//       if (shouldShowButton != _showScrollToTop) {
//         setState(() {
//           _showScrollToTop = shouldShowButton;
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _contentFadeController.dispose();
//     _scrollController.removeListener(_handleScroll);
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Provider.of<UserDashboardProvider>(context, listen: false);
//     final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
//     final bool isWebPlatform = kIsWeb;
//     final Size screenSize = MediaQuery.of(context).size;
//     final bool isLargeScreen = screenSize.width > 1024;
//     final bool isMediumScreen =
//         screenSize.width > 768 && screenSize.width <= 1024;

//     final settingsProvider =
//         Provider.of<SettingsProviderV2>(context, listen: true);
//     final themeColors = settingsProvider.getCurrentThemeColors(!isLightTheme);

//     final Color primaryBlue = themeColors['primary']!;
//     final Color deepNavyBlue = themeColors['deepBlue']!;
//     final Color pureWhite = themeColors['card']!;
//     final Color darkBackground = themeColors['background']!;
//     final Color lightPageBackground = themeColors['gradientStart']!;
//     final Color darkPageBackground = themeColors['background']!;

//     final Color navBackgroundColor = isLightTheme
//         ? pureWhite.withOpacity(0.9)
//         : darkBackground.withOpacity(0.9);

//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness:
//           isLightTheme ? Brightness.dark : Brightness.light,
//       statusBarBrightness: isLightTheme ? Brightness.light : Brightness.dark,
//       systemNavigationBarColor: navBackgroundColor,
//       systemNavigationBarIconBrightness:
//           isLightTheme ? Brightness.dark : Brightness.light,
//     ));

//     return Scaffold(
//       extendBody: true,
//       backgroundColor: Colors.transparent,
//       floatingActionButton: _showScrollToTop
//           ? FloatingActionButton(
//               mini: !isWebPlatform,
//               backgroundColor: primaryBlue,
//               onPressed: () {
//                 _scrollController.animateTo(
//                   0,
//                   duration: const Duration(milliseconds: 500),
//                   curve: Curves.easeOutQuad,
//                 );
//               },
//               child: const Icon(Icons.arrow_upward, color: Colors.white),
//             )
//           : null,
//       body: Stack(
//         children: [
//           // Background color - Fixed gray instead of theme colors
//           Container(
//             height: screenSize.height,
//             width: screenSize.width,
//             color: isLightTheme
//                 ? const Color(0xFFF5F5F5)
//                 : const Color(0xFF2C2C2C),
//           ),

//           // Use our new wave animation component
//           WaveAnimationBackground(
//               isDark: !isLightTheme, screenSize: screenSize),

//           // Content with fade animation
//           FadeTransition(
//             opacity: _fadeAnimation,
//             child: _buildMainContent(
//               isLightTheme,
//               isWebPlatform,
//               isLargeScreen,
//               isMediumScreen,
//               screenSize,
//               deepNavyBlue,
//               primaryBlue,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Main content extracted to its own method for better organization
//   Widget _buildMainContent(
//     bool isLightTheme,
//     bool isWebPlatform,
//     bool isLargeScreen,
//     bool isMediumScreen,
//     Size screenSize,
//     Color deepNavyBlue,
//     Color primaryBlue,
//   ) {
//     return CustomScrollView(
//       controller: _scrollController,
//       physics: const BouncingScrollPhysics(),
//       slivers: [
//         _buildAppBar(isLightTheme, isWebPlatform, isLargeScreen, deepNavyBlue),
//         if (isWebPlatform && (isLargeScreen || isMediumScreen))
//           _buildFeaturedContentSlider(),
//         SliverToBoxAdapter(
//           child: Padding(
//             padding: EdgeInsets.symmetric(
//               horizontal: isWebPlatform ? (isLargeScreen ? 50.0 : 30.0) : 16.0,
//               vertical: isWebPlatform ? 30.0 : 24.0,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Explore Marine Knowledge',
//                   style: UserDashboardFonts.largeHeadingText.copyWith(
//                     fontSize: isWebPlatform ? 28 : 22,
//                     color: isLightTheme
//                         ? const Color(0xFF073763)
//                         : Colors.white.withOpacity(0.95),
//                     letterSpacing: 0.2,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Discover the wonders of our oceans and learn how to protect them.',
//                   style: UserDashboardFonts.bodyText.copyWith(
//                     fontSize: isWebPlatform ? 15 : 13,
//                     color: isLightTheme
//                         ? Colors.blueGrey.shade700
//                         : Colors.white.withOpacity(0.75),
//                     height: 1.5,
//                   ),
//                 ),
//                 SizedBox(height: isWebPlatform ? 30 : 20),
//                 isWebPlatform && isLargeScreen
//                     ? _buildEducationCardsGrid(isLightTheme)
//                     : _buildEducationCardsList(isLightTheme),
//                 SizedBox(height: 80 + MediaQuery.of(context).padding.bottom),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // App bar extracted to its own method
//   Widget _buildAppBar(
//     bool isLightTheme,
//     bool isWebPlatform,
//     bool isLargeScreen,
//     Color deepNavyBlue,
//   ) {
//     final settingsProvider =
//         Provider.of<SettingsProviderV2>(context, listen: true);
//     final themeColors = settingsProvider.getCurrentThemeColors(!isLightTheme);
    
//     return SliverAppBar(
//       automaticallyImplyLeading: true,
//       expandedHeight: isWebPlatform ? 380.0 : 240.0,
//       floating: false,
//       pinned: true,
//       backgroundColor: themeColors['primary']!.withOpacity(0.85),
//       elevation: 4.0,
//       flexibleSpace: FlexibleSpaceBar(
//         titlePadding: EdgeInsets.only(
//             left: isWebPlatform ? 50 : 20, bottom: 16, right: 20),
//         title: Text(
//           'Ocean Education Hub',
//           style: UserDashboardFonts.largeHeadingText.copyWith(
//             color: Colors.white,
//             fontSize: isWebPlatform ? 26 : 18,
//             letterSpacing: 0.3,
//             shadows: [
//               Shadow(
//                 blurRadius: 4,
//                 color: Colors.black.withOpacity(0.4),
//                 offset: const Offset(1, 1),
//               )
//             ],
//           ),
//         ),
//         background: Stack(
//           fit: StackFit.expand,
//           children: [
//             // Optimized image loading with caching parameters
//             Image.asset(
//               'assets/EducationalInfoBackground.jpg',
//               fit: BoxFit.cover,
//               color: Colors.black.withOpacity(0.15),
//               colorBlendMode: BlendMode.darken,
//               cacheHeight: isWebPlatform ? 800 : 400,
//               cacheWidth: isWebPlatform ? 1600 : 800,
//             ),
//             Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       themeColors['gradientStart']!.withOpacity(0.2),
//                       themeColors['primary']!.withOpacity(0.6),
//                       themeColors['gradientEnd']!.withOpacity(0.85),
//                     ],
//                     stops: const [
//                       0.0,
//                       0.5,
//                       1.0
//                     ]),
//               ),
//             ),
//             if (isWebPlatform)
//               Positioned(
//                 bottom: 70,
//                 left: 50,
//                 right: 50,
//                 child: Text(
//                   'Dive deeper into ocean knowledge and conservation',
//                   textAlign: TextAlign.center,
//                   style: UserDashboardFonts.bodyText.copyWith(
//                     color: Colors.white.withOpacity(0.9),
//                     fontSize: 17,
//                     shadows: [
//                       Shadow(
//                         blurRadius: 2,
//                         color: Colors.black.withOpacity(0.5),
//                         offset: const Offset(0, 1),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         centerTitle: isWebPlatform ? true : false,
//       ),
//     );
//   }

//   Widget _buildFeaturedContentSlider() {
//     return SliverToBoxAdapter(
//       child: Container(
//         height: 300,
//         margin: const EdgeInsets.only(top: 24, bottom: 16),
//         child: PageView.builder(
//           controller: PageController(
//               viewportFraction: kIsWeb ? 0.85 : 0.9, keepPage: true),
//           itemCount: _featuredArticles.length,
//           itemBuilder: (context, index) {
//             final article = _featuredArticles[index];
//             return Container(
//               margin: const EdgeInsets.symmetric(horizontal: 8),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.15),
//                     spreadRadius: 0,
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(20),
//                 child: Stack(
//                   fit: StackFit.expand,
//                   children: [
//                     // Optimized image loading with caching
//                     Image.asset(
//                       article['image'],
//                       fit: BoxFit.cover,
//                       color: Colors.black.withOpacity(0.1),
//                       colorBlendMode: BlendMode.darken,
//                       cacheHeight: 600,
//                       cacheWidth: 1000,
//                     ),
//                     Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                             begin: Alignment.topCenter,
//                             end: Alignment.bottomCenter,
//                             colors: [
//                               Colors.transparent,
//                               Colors.black.withOpacity(0.8),
//                             ],
//                             stops: const [
//                               0.4,
//                               1.0
//                             ]),
//                       ),
//                     ),
//                     Positioned(
//                       bottom: 0,
//                       left: 0,
//                       right: 0,
//                       child: Container(
//                         padding: const EdgeInsets.all(20),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               article['title'],
//                               style: UserDashboardFonts.titleTextBold.copyWith(
//                                 color: Colors.white,
//                                 fontSize: 22,
//                               ),
//                             ),
//                             const SizedBox(height: 6),
//                             Text(
//                               article['description'],
//                               style: UserDashboardFonts.bodyText.copyWith(
//                                 color: Colors.white.withOpacity(0.85),
//                                 fontSize: 15,
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             Row(
//                               children: [
//                                 ElevatedButton(
//                                   onPressed: () {},
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor:
//                                         Colors.white.withOpacity(0.9),
//                                     foregroundColor: const Color(0xFF073763),
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 20,
//                                       vertical: 10,
//                                     ),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(25),
//                                     ),
//                                     elevation: 2,
//                                   ),
//                                   child: Text('Read More',
//                                       style: UserDashboardFonts.buttonText),
//                                 ),
//                                 const Spacer(),
//                                 if (kIsWeb)
//                                   _buildSocialShareButtons(article['title']),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildEducationCardsGrid(bool isLightTheme) {
//     return GridView.count(
//       crossAxisCount: 3,
//       childAspectRatio: 1.1,
//       crossAxisSpacing: 18,
//       mainAxisSpacing: 18,
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       children: _educationCategories
//           .map((category) => _buildEducationCardContent(
//               category['title'],
//               category['icon'],
//               category['subtitle'],
//               category['description'],
//               isLightTheme))
//           .toList(),
//     );
//   }

//   Widget _buildEducationCardsList(bool isLightTheme) {
//     return Column(
//       children: _educationCategories.map((category) {
//         final index = _educationCategories.indexOf(category);
//         return Column(
//           children: [
//             _buildEducationCardContent(category['title'], category['icon'],
//                 category['subtitle'], category['description'], isLightTheme),
//             // Add spacing between cards, except after the last one
//             if (index < _educationCategories.length - 1)
//               const SizedBox(height: 16),
//           ],
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildEducationCardContent(
//     String title,
//     IconData icon,
//     String subtitle,
//     String description,
//     bool isLightTheme,
//   ) {
//     final settingsProvider =
//         Provider.of<SettingsProviderV2>(context, listen: true);
//     final themeColors = settingsProvider.getCurrentThemeColors(!isLightTheme);
    
//     final Color cardBgColor = themeColors['card']!;
//     final Color titleColor = themeColors['text']!;
//     final Color subtitleColor = themeColors['text']!.withOpacity(0.7);
//     final Color iconBgColor = themeColors['primary']!.withOpacity(0.12);
//     final Color iconColor = themeColors['primary']!;
//     final Color borderColor = themeColors['divider']!;
//     final Color gradientStart = themeColors['gradientStart']!.withOpacity(0.05);
//     final Color gradientEnd = themeColors['gradientEnd']!.withOpacity(0.1);

//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [cardBgColor, gradientStart, gradientEnd],
//           stops: const [0.0, 0.3, 1.0],
//         ),
//         border: Border.all(
//           color: borderColor,
//           width: 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: themeColors['primary']!.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//             spreadRadius: 1,
//           ),
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 12,
//             offset: const Offset(0, 2),
//             spreadRadius: 0,
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () => Navigator.push(
//             context,
//             PageTransition(
//               page: MarineEducationPage(
//                 isAdmin: false,
//                 category: title,
//               ),
//               transitionType: TransitionType.scale,
//               alignment: Alignment.center,
//               curve: Curves.fastOutSlowIn,
//               duration: const Duration(milliseconds: 450),
//             ),
//           ),
//           borderRadius: BorderRadius.circular(20),
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         iconBgColor,
//                         themeColors['primary']!.withOpacity(0.2),
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: themeColors['primary']!.withOpacity(0.3),
//                       width: 1,
//                     ),
//                   ),
//                   child: Icon(
//                     icon,
//                     size: kIsWeb ? 32 : 28,
//                     color: iconColor,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   title,
//                   style: UserDashboardFonts.largeTextSemiBold.copyWith(
//                     fontSize: kIsWeb ? 20 : 18,
//                     color: titleColor,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   subtitle,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: UserDashboardFonts.smallText.copyWith(
//                     fontSize: kIsWeb ? 14 : 13,
//                     color: subtitleColor,
//                     height: 1.4,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 if (kIsWeb) const Spacer(),
//                 if (kIsWeb) const SizedBox(height: 12),
//                 Row(
//                   mainAxisAlignment: kIsWeb
//                       ? MainAxisAlignment.spaceBetween
//                       : MainAxisAlignment.end,
//                   children: [
//                   if (kIsWeb)
//                     Text(
//                       'Explore',
//                       style: UserDashboardFonts.bodyTextMedium.copyWith(
//                         fontSize: 13,
//                         color: themeColors['primary']!,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   if (kIsWeb) const Spacer(),
//                   Icon(
//                     kIsWeb
//                         ? CupertinoIcons.arrow_right_circle
//                         : CupertinoIcons.chevron_right,
//                     color: themeColors['primary']!,
//                     size: kIsWeb ? 20 : 18,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSocialShareButtons(String content) {
//     Future<void> shareToSocialMedia(String platform) async {
//       String pageUrl =
//           'https://marineguard.app/education/${Uri.encodeComponent(content)}';
//       String shareText = Uri.encodeComponent(
//           'Check out "$content" on Marine Guard Education Hub! $pageUrl #OceanConservation #MarineGuardApp');
//       String url = '';

//       switch (platform) {
//         case 'twitter':
//           url = 'https://twitter.com/intent/tweet?text=$shareText';
//           break;
//         case 'facebook':
//           url =
//               'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(pageUrl)}&quote=$shareText';
//           break;
//         case 'copy':
//           await Clipboard.setData(ClipboardData(text: pageUrl));
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//               content: Text('Link to "$content" copied!',
//                   style: UserDashboardFonts.bodyText),
//               behavior: SnackBarBehavior.floating,
//               backgroundColor: const Color(0xFF073763),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//               margin: const EdgeInsets.all(10),
//             ));
//           }
//           return;
//       }

//       if (await canLaunchUrl(Uri.parse(url))) {
//         await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//       } else {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Could not open $platform.')),
//           );
//         }
//       }
//     }

//     final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
//     final Color iconColor =
//         isLightTheme ? Colors.blueGrey.shade600 : Colors.blueGrey.shade300;
//     final Color buttonBgColor = isLightTheme
//         ? Colors.white.withOpacity(0.7)
//         : const Color(0xFF2C3A47).withOpacity(0.8);

//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         _buildSocialButton(buttonBgColor, CupertinoIcons.link, iconColor,
//             () => shareToSocialMedia('copy')),
//         const SizedBox(width: 8),
//         _buildSocialButton(
//             const Color(0xFF1DA1F2),
//             const IconData(0xf099, fontFamily: 'FontAwesomeBrands'),
//             Colors.white,
//             () => shareToSocialMedia('twitter')),
//         const SizedBox(width: 8),
//         _buildSocialButton(
//             const Color(0xFF1877F2),
//             const IconData(0xf39e, fontFamily: 'FontAwesomeBrands'),
//             Colors.white,
//             () => shareToSocialMedia('facebook')),
//       ],
//     );
//   }

//   Widget _buildSocialButton(
//     Color backgroundColor,
//     IconData icon,
//     Color iconColor,
//     VoidCallback onPressed,
//   ) {
//     return Container(
//       height: 30,
//       width: 30,
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 3,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: IconButton(
//         padding: EdgeInsets.zero,
//         icon: Icon(icon, size: 14, color: iconColor),
//         onPressed: onPressed,
//         splashRadius: 15,
//       ),
//     );
//   }
// }
