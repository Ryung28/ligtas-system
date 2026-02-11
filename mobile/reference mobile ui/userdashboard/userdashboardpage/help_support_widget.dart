import 'package:flutter/material.dart';
import 'package:mobileapplication/config/theme_config.dart';
import 'package:mobileapplication/userdashboard/userdashboardpage/faq_page.dart';
import 'package:mobileapplication/userdashboard/userdashboardpage/userdashboard_provider.dart';
import 'package:mobileapplication/userdashboard/userdashboardpage/chatbot_page.dart';
import 'package:mobileapplication/userdashboard/userdashboardpage/email_support_page.dart';
import 'package:provider/provider.dart';

class HelpSupportWidget extends StatelessWidget {
  const HelpSupportWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDashboardProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 100.0),
          child: FloatingActionButton(
            onPressed: () => _showHelpSupportDialog(context, provider),
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? const Color.fromARGB(255, 72, 167, 255)
                : ThemeConfig.darkCard,
            elevation: 4,
            child: const Icon(
              Icons.support_agent,
              color: Colors.white,
              size: 28,
            ),
          ),
        );
      },
    );
  }

  void _showHelpSupportDialog(
      BuildContext context, UserDashboardProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: 400,
              ),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : ThemeConfig.darkCard,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 72, 167, 255)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.support_agent,
                                color: Color.fromARGB(255, 72, 167, 255),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                'Help & Support',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.black.withOpacity(0.8)
                                      : Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black.withOpacity(0.5)
                                  : Colors.white.withOpacity(0.5),
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSupportOption(
                    context,
                    'Chat with Assistant',
                    Icons.chat_bubble_outline,
                    'Get instant help from our AI assistant',
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChatbotPage()),
                      );
                    },
                    provider,
                  ),
                  const SizedBox(height: 16),
                  _buildSupportOption(
                    context,
                    'Email Support',
                    Icons.email_outlined,
                    'Send us an email for detailed assistance',
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EmailSupportPage()),
                      );
                    },
                    provider,
                  ),
                  const SizedBox(height: 16),
                  _buildSupportOption(
                    context,
                    'FAQs',
                    Icons.help_outline,
                    'Browse frequently asked questions',
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FAQPage()),
                      );
                    },
                    provider,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSupportOption(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
    UserDashboardProvider provider,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.grey[50]
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey[200]!
                  : Colors.white.withOpacity(0.1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 72, 167, 255)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: const Color.fromARGB(255, 72, 167, 255),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black.withOpacity(0.8)
                                  : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black.withOpacity(0.5)
                                  : Colors.white.withOpacity(0.5),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black.withOpacity(0.3)
                      : Colors.white.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
