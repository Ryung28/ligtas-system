import 'package:flutter/material.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({Key? key}) : super(key: key);

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'What is Marine Guard?',
      answer: 'Marine Guard is a comprehensive mobile application designed to assist in marine safety and monitoring. It provides real-time information, safety alerts, and educational resources for marine activities.',
      category: 'General',
    ),
    FAQItem(
      question: 'How do I report an incident?',
      answer: 'To report an incident, go to the dashboard and click on the "Report Incident" button. Fill in the required details including location, type of incident, and any additional information. You can also attach photos if needed.',
      category: 'Safety',
    ),
    FAQItem(
      question: 'What should I do in case of an emergency?',
      answer: '1. Stay calm\n2. Use the emergency button in the app\n3. Follow the safety instructions provided\n4. Contact local authorities if necessary\n5. Keep your location services enabled',
      category: 'Safety',
    ),
    FAQItem(
      question: 'How do I update my profile information?',
      answer: 'You can update your profile information by going to Settings > Profile. Here you can modify your personal details, contact information, and preferences.',
      category: 'Account',
    ),
    FAQItem(
      question: 'Is my data secure?',
      answer: 'Yes, we take data security seriously. All your personal information is encrypted and stored securely. We follow industry-standard security protocols and regularly update our security measures.',
      category: 'Security',
    ),
    FAQItem(
      question: 'What are the system requirements?',
      answer: 'Marine Guard requires iOS 12.0 or later for Apple devices, and Android 8.0 or later for Android devices. Location services and internet connection are recommended for full functionality.',
      category: 'Technical',
    ),
    FAQItem(
      question: 'How do I contact support?',
      answer: 'You can contact our support team through:\n1. In-app Email Support\n2. Help Center\n3. Community Forums\n4. Social Media Channels',
      category: 'Support',
    ),
  ];

  final List<String> _categories = [
    'All',
    'General',
    'Safety',
    'Account',
    'Security',
    'Features',
    'Technical',
    'Support',
  ];

  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<FAQItem> get filteredFAQs {
    if (_selectedCategory == 'All') {
      return _faqItems;
    }
    return _faqItems.where((item) => item.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Frequently Asked Questions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromARGB(255, 72, 167, 255),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildSearchTip(),
                  const SizedBox(height: 16),
                  _buildCategoryFilter(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.grey[50],
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: filteredFAQs.map((faq) => _buildFAQCard(faq)).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTip() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 72, 167, 255).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 72, 167, 255).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.lightbulb_outline,
                color: Color.fromARGB(255, 72, 167, 255),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Tip',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 72, 167, 255),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Use categories to filter questions or browse all FAQs below',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.6),
                      height: 1.3,
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

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black.withOpacity(0.7),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: const Color.fromARGB(255, 72, 167, 255),
              checkmarkColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 0,
              pressElevation: 0,
              shadowColor: Colors.transparent,
              side: BorderSide(
                color: isSelected
                    ? const Color.fromARGB(255, 72, 167, 255)
                    : Colors.grey.withOpacity(0.3),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFAQCard(FAQItem faq) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              title: Text(
                faq.question,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 72, 167, 255).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.help_outline,
                  color: Color.fromARGB(255, 72, 167, 255),
                  size: 20,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 72, 167, 255).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color.fromARGB(255, 72, 167, 255),
                  size: 20,
                ),
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Text(
                    faq.answer,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.7),
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;
  final String category;

  FAQItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}
