import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobileapplication/userdashboard/config/user_dashboard_fonts.dart';

/// A provider class that creates and caches formatted content widgets
/// to avoid rebuilding them on every state change.
class FormattedContentProvider with ChangeNotifier {
  // Caches the formatted content for different categories
  final Map<String, List<Widget>> _formattedContentCache = {};

  /// Clear the cache for a specific category, or all categories if null.
  /// This should be called when content changes.
  void clearCache([String? category]) {
    if (category != null) {
      _formattedContentCache.remove(category);
    } else {
      _formattedContentCache.clear();
    }
    notifyListeners();
  }

  /// Get formatted content widgets for the given text.
  /// Uses cached content if available and content hasn't changed.
  List<Widget> getFormattedContent({
    required String category,
    required String content,
    required bool isLightTheme,
  }) {
    // Create a unique key for the cache that includes the theme mode
    final String cacheKey =
        '$category-${isLightTheme ? 'light' : 'dark'}-${content.hashCode}';

    // Return from cache if available
    if (_formattedContentCache.containsKey(cacheKey)) {
      return _formattedContentCache[cacheKey]!;
    }

    // Create the formatted content
    final List<Widget> result = _buildFormattedContent(content, isLightTheme);

    // Cache the result
    _formattedContentCache[cacheKey] = result;

    return result;
  }

  /// Builds the formatted content widgets from the raw text content
  List<Widget> _buildFormattedContent(String content, bool isLightTheme) {
    final Color textColor =
        isLightTheme ? const Color(0xFF0A192F) : Colors.white.withOpacity(0.9);
    final Color headingColor =
        isLightTheme ? const Color(0xFF1A73E8) : const Color(0xFF00ACC1);
    final Color bulletColor =
        isLightTheme ? Colors.grey.shade700 : Colors.grey.shade400;

    List<String> lines = content.split('\n');
    List<Widget> contentWidgets = [];

    for (String line in lines) {
      line = line.trim(); // Trim whitespace
      if (line.isEmpty) {
        contentWidgets.add(const SizedBox(height: 10));
      } else if (line.startsWith('#')) {
        int level = 0;
        while (line.startsWith('#')) {
          level++;
          line = line.substring(1).trim();
        }
        double fontSize = kIsWeb ? (28.0 - level * 2) : (24.0 - level * 2);
        FontWeight fontWeight = level == 1 ? FontWeight.w700 : FontWeight.w600;
        contentWidgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              line,
              style: UserDashboardFonts.custom(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: headingColor,
                height: 1.3,
              ),
            ),
          ),
        );
      } else if (line.startsWith('•') ||
          line.startsWith('-') ||
          line.startsWith('*')) {
        contentWidgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 2, bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    color: bulletColor,
                    fontSize: kIsWeb ? 16 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    line.substring(1).trim(),
                    style: UserDashboardFonts.bodyText.copyWith(
                      color: textColor,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (RegExp(r'^\d+\.').hasMatch(line)) {
        contentWidgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 2, bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${line.substring(0, line.indexOf('.') + 1)} ',
                  style: TextStyle(
                    color: bulletColor,
                    fontSize: kIsWeb ? 16 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    line.substring(line.indexOf('.') + 1).trim(),
                    style: UserDashboardFonts.bodyText.copyWith(
                      color: textColor,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        contentWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              line,
              style: UserDashboardFonts.bodyText.copyWith(
                color: textColor,
                height: 1.6,
              ),
            ),
          ),
        );
      }
    }

    return contentWidgets;
  }
}
