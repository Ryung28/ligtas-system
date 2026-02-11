import 'package:flutter/material.dart';
import 'package:mobileapplication/services/chatbot_service.dart';
import 'package:provider/provider.dart';
import 'package:mobileapplication/providers/navigation_provider.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  String _currentMenu = 'menu';

  @override
  void initState() {
    super.initState();
    _addBotMessage(
        "Hello! I'm Marine Guard's assistant. How can I help you today?");
    _showMainMenu();
  }

  void _showMainMenu() {
    setState(() {
      _messages.add(ChatMessage(
        text: '',
        isUser: false,
        timestamp: DateTime.now(),
        widgets: ChatbotService.getMainMenuButtons(_handleOptionSelected),
      ));
    });
  }

  void _handleOptionSelected(String option) {
    if (option == '5' || option.toLowerCase() == 'menu') {
      _currentMenu = 'menu';
      _showMainMenu();
      return;
    }

    setState(() {
      _messages.add(ChatMessage(
        text: option,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    String response = ChatbotService.getResponse(option);
    _addBotMessage(response);

    if (option == '2' || option.startsWith('sub2')) {
      setState(() {
        _messages.add(ChatMessage(
          text: '',
          isUser: false,
          timestamp: DateTime.now(),
          widget: ChatbotService.buildAdminContactButton(context),
        ));
      });
    }

    _scrollToBottom();
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    _messageController.clear();

    // Add user message first
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    // Handle numeric input
    if (text.length == 1 && RegExp(r'[1-5]').hasMatch(text)) {
      String response = ChatbotService.getResponse(text);
      _addBotMessage(response);

      // Show submenu buttons if needed
      if (text == "1") {
        setState(() {
          _messages.add(ChatMessage(
            text: '',
            isUser: false,
            timestamp: DateTime.now(),
            widgets:
                ChatbotService.getComplaintMenuButtons(_handleOptionSelected),
          ));
        });
      } else if (text == "2") {
        setState(() {
          _messages.add(ChatMessage(
            text: '',
            isUser: false,
            timestamp: DateTime.now(),
            widget: ChatbotService.buildAdminContactButton(context),
          ));
        });
      } else if (text == "3") {
        setState(() {
          _messages.add(ChatMessage(
            text: '',
            isUser: false,
            timestamp: DateTime.now(),
            widgets: ChatbotService.getSafetyInfoButtons(_handleOptionSelected),
          ));
        });
      } else if (text == "5") {
        _showMainMenu();
      }
    } else {
      // Handle non-numeric input
      _addBotMessage(
          "Please select an option from the menu or type a number between 1-5.");
      _showMainMenu();
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.support_agent, size: 24),
            SizedBox(width: 12),
            Text(
              'Marine Guard Assistant',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF48A7FF),
        elevation: 0,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // Show navbar on any interaction
          Provider.of<NavigationProvider>(context, listen: false).showNavbar();
        },
        onPanDown: (_) {
          // Show navbar on pan down
          Provider.of<NavigationProvider>(context, listen: false).showNavbar();
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF48A7FF),
                const Color(0xFF9EC9FD).withOpacity(0.8),
              ],
            ),
          ),
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              // Show navbar when user starts scrolling
              if (notification is ScrollStartNotification) {
                Provider.of<NavigationProvider>(context, listen: false)
                    .showNavbar();
              }
              return false; // Don't stop notification propagation
            },
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessage(message);
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, -2),
                        blurRadius: 12,
                        color: Colors.black.withOpacity(0.06),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: 'Type a number (1-5) or message...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 15,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                                onSubmitted: _handleSubmitted,
                                onTap: () {
                                  // Show navbar when user taps text field
                                  Provider.of<NavigationProvider>(context,
                                          listen: false)
                                      .showNavbar();
                                },
                                onChanged: (text) {
                                  // Show navbar when user types
                                  Provider.of<NavigationProvider>(context,
                                          listen: false)
                                      .showNavbar();
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF48A7FF).withOpacity(0.9),
                                  const Color(0xFF48A7FF).withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF48A7FF).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(25),
                                onTap: () =>
                                    _handleSubmitted(_messageController.text),
                                child: const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildMessage(ChatMessage message) {
    if (message.widgets != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: message.widgets!,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF48A7FF),
                child: const Icon(Icons.support_agent,
                    color: Colors.white, size: 18),
              ),
            ),
          ],
          Flexible(
            child: message.widget ??
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        message.isUser ? const Color(0xFF48A7FF) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(message.isUser ? 20 : 5),
                      bottomRight: Radius.circular(message.isUser ? 5 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 15,
                      color: message.isUser ? Colors.white : Colors.black87,
                    ),
                    softWrap: true,
                  ),
                ),
          ),
          if (message.isUser)
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, color: Colors.white, size: 14),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final Widget? widget;
  final List<Widget>? widgets;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.widget,
    this.widgets,
  });
}
