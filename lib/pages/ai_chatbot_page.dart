import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/ai_service.dart';
import '../utils/styles.dart';


class AIChatbotPage extends StatefulWidget {
  final bool isStaffMode;
  
  const AIChatbotPage({
    Key? key,
    this.isStaffMode = false,
  }) : super(key: key);

  @override
  State<AIChatbotPage> createState() => _AIChatbotPageState();
}

class _AIChatbotPageState extends State<AIChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  
  late final AIService _aiService;

  @override
  void initState() {
    super.initState();
    
    final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    
    if (apiKey.isEmpty) {
      print('❌ GROQ_API_KEY not found in .env file!');
      print('💡 Add GROQ_API_KEY=your-key to .env file');
      print('💡 Get free key at: https://console.groq.com/');
    } else {
      print('✅ Groq API key loaded');
    }
    
    _aiService = AIService(
      apiKey: apiKey,
      isStaffMode: widget.isStaffMode,
    );
    
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    setState(() {
      if (widget.isStaffMode) {
        _messages.add(ChatMessage(
          text: "👋 Hi! I'm PawGoda Staff AI Assistant.\n\n"
              "I can help you with:\n\n"
              "📋 Today's schedule and tasks\n"
              "📅 Booking management\n"
              "✅ Activity updates\n"
              "🐾 Pet information\n"
              "📊 Statistics and reports\n\n"
              "What do you need help with?",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      } else {
        _messages.add(ChatMessage(
          text: "👋 Hi! I'm PawGoda AI Assistant.\n\n"
              "I have access to your information and can help with:\n\n"
              "🐾 Your pets\n"
              "📅 Your bookings\n"
              "💰 Hotel packages & pricing\n"
              "🎯 Services we offer\n"
              "📸 Activity updates\n\n"
              "How can I help you today?",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Get AI response with Firebase context
      final response = await _aiService.getAIResponse(text);

      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        _messages.add(ChatMessage(
          text: "I apologize, but I'm having trouble right now. "
              "Please try again or contact support.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Styles.highlightColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.isStaffMode ? Icons.work_outline : Icons.smart_toy,
                color: Styles.highlightColor,
                size: 24,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isStaffMode ? 'Staff AI Assistant' : 'PawGoda AI',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Gap(6),
                      Text(
                        'Powered by Groq',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.grey.shade700),
            onPressed: _showOptionsMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Styles.highlightColor.withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Styles.highlightColor,
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    widget.isStaffMode 
                        ? 'Connected to staff database for real-time information'
                        : 'AI responses use your personal data from our system',
                    style: TextStyle(
                      fontSize: 12,
                      color: Styles.highlightColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Quick action suggestions
          if (_messages.length <= 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _getQuickActions(),
                ),
              ),
            ),

          const Gap(8),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: widget.isStaffMode 
                            ? 'Ask about tasks, bookings...' 
                            : 'Ask me anything...',
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: _sendMessage,
                      enabled: !_isTyping,
                      maxLines: null,
                    ),
                  ),
                ),
                const Gap(8),
                Container(
                  decoration: BoxDecoration(
                    color: Styles.highlightColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: _isTyping 
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                    onPressed: _isTyping 
                        ? null 
                        : () => _sendMessage(_messageController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getQuickActions() {
    if (widget.isStaffMode) {
      return [
        _buildQuickAction('📋 Today\'s tasks', 'What are my tasks for today?'),
        const Gap(8),
        _buildQuickAction('📅 Bookings', 'Show me today\'s bookings'),
        const Gap(8),
        _buildQuickAction('🐾 Checked-in pets', 'Which pets are currently checked in?'),
        const Gap(8),
        _buildQuickAction('✅ Pending', 'What activities are pending?'),
      ];
    } else {
      return [
        _buildQuickAction('🐾 My pets', 'Show me my pets'),
        const Gap(8),
        _buildQuickAction('📅 Bookings', 'What are my bookings?'),
        const Gap(8),
        _buildQuickAction('💰 Packages', 'Tell me about packages'),
        const Gap(8),
        _buildQuickAction('📸 Updates', 'Any recent activity updates?'),
      ];
    }
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Styles.highlightColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.isStaffMode ? Icons.work_outline : Icons.smart_toy,
                color: Styles.highlightColor,
                size: 20,
              ),
            ),
            const Gap(8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? Styles.highlightColor
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                      bottomRight: Radius.circular(message.isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                const Gap(4),
                Text(
                  DateFormat('HH:mm').format(message.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser) ...[
            const Gap(8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Styles.highlightColor.withOpacity(0.2),
              child: Icon(
                Icons.person,
                color: Styles.highlightColor,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Styles.highlightColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.isStaffMode ? Icons.work_outline : Icons.smart_toy,
              color: Styles.highlightColor,
              size: 20,
            ),
          ),
          const Gap(8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const Gap(4),
                _buildTypingDot(1),
                const Gap(4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 100)),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -4 * (value - 0.5).abs() * 2),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickAction(String label, String message) {
    return InkWell(
      onTap: () => _sendMessage(message),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Styles.highlightColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Styles.highlightColor,
          ),
        ),
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(20),
            ListTile(
              leading: Icon(Icons.refresh, color: Styles.highlightColor),
              title: const Text('Start New Chat'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _messages.clear();
                  _addWelcomeMessage();
                });
              },
            ),
            if (!widget.isStaffMode)
              ListTile(
                leading: Icon(Icons.contact_support, color: Styles.highlightColor),
                title: const Text('Contact Support'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Redirecting to support...'),
                      backgroundColor: Styles.highlightColor,
                    ),
                  );
                },
              ),
            ListTile(
              leading: Icon(Icons.info_outline, color: Styles.highlightColor),
              title: const Text('About AI Assistant'),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About AI Assistant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Powered by Groq AI (FREE)'),
            const Gap(10),
            const Text('This AI assistant has access to:'),
            const Gap(10),
            if (widget.isStaffMode) ...[
              const Text('• All bookings'),
              const Text('• Activity schedules'),
              const Text('• Checked-in pets'),
              const Text('• Task management'),
            ] else ...[
              const Text('• Your pet information'),
              const Text('• Your bookings'),
              const Text('• Activity updates'),
              const Text('• Hotel packages'),
              const Text('• Services'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}