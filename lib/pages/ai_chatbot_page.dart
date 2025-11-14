import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../utils/styles.dart';

/// AI Chatbot Page for Customer Support
/// Customers can ask questions about services, bookings, pet care, etc.
class AIChatbotPage extends StatefulWidget {
  const AIChatbotPage({Key? key}) : super(key: key);

  @override
  State<AIChatbotPage> createState() => _AIChatbotPageState();
}

class _AIChatbotPageState extends State<AIChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(ChatMessage(
        text: "👋 Hi! I'm PawGoda AI Assistant. How can I help you today?\n\nYou can ask me about:\n• Hotel packages & pricing\n• Daycare services\n• Pet care activities\n• Booking process\n• Our facilities\n• And more!",
        isUser: false,
        timestamp: DateTime.now(),
      ));
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

    // Simulate AI response delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Generate AI response
    final response = _generateAIResponse(text);

    setState(() {
      _messages.add(ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _isTyping = false;
    });

    _scrollToBottom();
  }

  String _generateAIResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    // Hotel packages
    if (message.contains('package') || message.contains('price') || message.contains('pricing') || message.contains('cost')) {
      return "🏨 We offer 3 hotel packages:\n\n"
          "💙 Normal Package (RM 80/day)\n"
          "• Standard room\n"
          "• Basic care\n"
          "• Daily feeding\n"
          "• 1 playtime session\n\n"
          "💜 Deluxe Package (RM 150/day)\n"
          "• Spacious suite\n"
          "• Premium care\n"
          "• Custom feeding schedule\n"
          "• 2 playtime sessions\n"
          "• Daily grooming\n\n"
          "⭐ VIP Package (RM 250/day)\n"
          "• Luxury suite\n"
          "• VIP care\n"
          "• Personalized menu\n"
          "• Unlimited playtime\n"
          "• Daily grooming & spa\n"
          "• 24/7 camera access\n"
          "• Dedicated caretaker\n\n"
          "Which package interests you?";
    }

    // Daycare
    if (message.contains('daycare') || message.contains('day care')) {
      return "🌞 Our Daycare Service (RM 60/day):\n\n"
          "• Drop-off in the morning\n"
          "• Pick-up in the evening\n"
          "• Supervised playtime\n"
          "• Feeding included\n"
          "• Activity updates with photos\n"
          "• Perfect for working pet owners!\n\n"
          "No checkout date needed - just select the service date when booking.";
    }

    // Activities
    if (message.contains('activit') || message.contains('care') || message.contains('service')) {
      return "🎯 We offer 4 main care activities:\n\n"
          "🍽️ Feeding\n"
          "Regular feeding according to your pet's schedule\n\n"
          "🚶 Walking\n"
          "Daily walks and outdoor exercise\n\n"
          "🎮 Playtime\n"
          "Interactive play sessions\n\n"
          "💊 Medication\n"
          "Medication administration if needed\n\n"
          "You can select which activities you want during booking, and our staff will update you with photos!";
    }

    // Booking
    if (message.contains('book') || message.contains('reserve') || message.contains('how to')) {
      return "📝 Booking is easy! Here's how:\n\n"
          "1️⃣ Select your pet type (Cat/Dog/Rabbit)\n"
          "2️⃣ Choose service (Hotel or Daycare)\n"
          "3️⃣ Pick your package (for hotel stays)\n"
          "4️⃣ Enter pet details and dates\n"
          "5️⃣ Select care activities you want\n"
          "6️⃣ Confirm and pay\n"
          "7️⃣ Track updates in real-time!\n\n"
          "Need help with any specific step?";
    }

    // Real-time updates
    if (message.contains('update') || message.contains('photo') || message.contains('track')) {
      return "📸 Real-time Updates:\n\n"
          "• Our staff updates selected activities daily\n"
          "• Each update includes photos of your pet\n"
          "• View updates anytime in the app\n"
          "• Get notifications for new updates\n"
          "• See what your pet is doing throughout the day\n\n"
          "You'll never miss a moment! 🐾";
    }

    // Pet types
    if (message.contains('cat') || message.contains('dog') || message.contains('rabbit') || message.contains('pet type')) {
      return "🐾 We welcome:\n\n"
          "🐱 Cats - All breeds\n"
          "🐶 Dogs - Small to large breeds\n"
          "🐰 Rabbits - All breeds\n\n"
          "Each pet gets personalized care based on their needs. Tell us about any special requirements during booking!";
    }

    // Facilities
    if (message.contains('facilit') || message.contains('room') || message.contains('suite')) {
      return "🏢 Our Facilities:\n\n"
          "✨ Climate-controlled rooms\n"
          "🎥 24/7 CCTV monitoring\n"
          "🏃 Indoor & outdoor play areas\n"
          "🛁 Professional grooming station\n"
          "🏥 Veterinary support on-call\n"
          "🍽️ Hygienic feeding areas\n"
          "🛏️ Comfortable bedding\n\n"
          "Your pet's comfort is our priority!";
    }

    // Safety
    if (message.contains('safe') || message.contains('secure') || message.contains('monitor')) {
      return "🔒 Safety & Security:\n\n"
          "✅ 24/7 staff supervision\n"
          "✅ CCTV monitoring\n"
          "✅ Secure entry/exit\n"
          "✅ Emergency vet on-call\n"
          "✅ Separate areas for different pet sizes\n"
          "✅ Regular health checks\n"
          "✅ Climate-controlled environment\n\n"
          "Your pet's safety is our top priority!";
    }

    // Contact
    if (message.contains('contact') || message.contains('call') || message.contains('phone') || message.contains('email')) {
      return "📞 Contact Us:\n\n"
          "🏢 PawGoda Pet Hotel\n"
          "📍 Johor Bahru, Johor, Malaysia\n"
          "📧 support@pawgoda.com\n"
          "📱 +60 12-345 6789\n"
          "⏰ Operating Hours: 8AM - 8PM\n\n"
          "We're here to help! 💚";
    }

    // Operating hours
    if (message.contains('hour') || message.contains('time') || message.contains('open') || message.contains('close')) {
      return "⏰ Operating Hours:\n\n"
          "📅 Monday - Sunday\n"
          "🕐 8:00 AM - 8:00 PM\n\n"
          "Check-in: 8:00 AM - 12:00 PM\n"
          "Check-out: 4:00 PM - 8:00 PM\n\n"
          "We're open every day to serve you and your pets!";
    }

    // Payment
    if (message.contains('payment') || message.contains('pay') || message.contains('method')) {
      return "💳 Payment Methods:\n\n"
          "✅ Credit/Debit Cards\n"
          "✅ Online Banking\n"
          "✅ Digital Wallets (Apple Pay, Google Pay)\n"
          "✅ Bank Transfer\n\n"
          "💰 Payment is processed securely after booking confirmation.\n\n"
          "Need help with payment? Let me know!";
    }

    // Cancellation
    if (message.contains('cancel') || message.contains('refund') || message.contains('change')) {
      return "🔄 Booking Changes & Cancellation:\n\n"
          "✅ Free cancellation up to 24 hours before check-in\n"
          "✅ Change dates anytime (subject to availability)\n"
          "✅ Full refund for cancellations made 24+ hours in advance\n"
          "⚠️ 50% charge for cancellations within 24 hours\n\n"
          "Need to modify your booking? Contact support or use the app!";
    }

    // Vaccination
    if (message.contains('vaccin') || message.contains('medical') || message.contains('health')) {
      return "💉 Health Requirements:\n\n"
          "✅ Up-to-date vaccinations required\n"
          "✅ Recent health check recommended\n"
          "✅ Flea/tick treatment advised\n"
          "📋 Please bring vaccination records\n\n"
          "We can coordinate with your vet if needed. Your pet's health matters to us!";
    }

    // Food
    if (message.contains('food') || message.contains('feed') || message.contains('meal') || message.contains('diet')) {
      return "🍽️ Feeding Options:\n\n"
          "✅ Premium pet food provided\n"
          "✅ Custom feeding schedules\n"
          "✅ Special diets accommodated\n"
          "✅ Bring your own food (if preferred)\n"
          "✅ Dietary restrictions supported\n\n"
          "Just let us know your pet's food preferences during booking!";
    }

    // Grooming
    if (message.contains('groom') || message.contains('bath') || message.contains('nail') || message.contains('spa')) {
      return "✨ Grooming Services:\n\n"
          "Included in Deluxe & VIP packages:\n"
          "🛁 Professional bathing\n"
          "✂️ Haircut & styling\n"
          "💅 Nail trimming\n"
          "👂 Ear cleaning\n"
          "🦷 Teeth brushing\n\n"
          "Add-on grooming available for Normal package holders!";
    }

    // Emergency
    if (message.contains('emergency') || message.contains('urgent') || message.contains('help') || message.contains('problem')) {
      return "🚨 Emergency Support:\n\n"
          "For urgent matters:\n"
          "📞 Call: +60 12-345 6789\n"
          "📧 Email: emergency@pawgoda.com\n\n"
          "🏥 We have 24/7 emergency vet support\n"
          "🚑 Immediate response team\n\n"
          "Your pet's wellbeing is our priority. Don't hesitate to reach out!";
    }

    // Thanks
    if (message.contains('thank') || message.contains('appreciate')) {
      return "💚 You're very welcome!\n\n"
          "Is there anything else you'd like to know about PawGoda Pet Hotel? I'm here to help!";
    }

    // Greeting
    if (message.contains('hello') || message.contains('hi') || message.contains('hey')) {
      return "👋 Hello! How can I assist you today?\n\n"
          "I can help you with:\n"
          "• Packages & pricing\n"
          "• Booking process\n"
          "• Services & facilities\n"
          "• Pet care information\n\n"
          "What would you like to know?";
    }

    // Default response
    return "I'd be happy to help! 🐾\n\n"
        "You can ask me about:\n"
        "🏨 Hotel packages & pricing\n"
        "🌞 Daycare services\n"
        "🎯 Pet care activities\n"
        "📝 Booking process\n"
        "🏢 Our facilities\n"
        "💳 Payment methods\n"
        "⏰ Operating hours\n"
        "📞 Contact information\n\n"
        "What would you like to know more about?";
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
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Styles.highlightColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy,
                color: Styles.highlightColor,
                size: 24,
              ),
            ),
            const Gap(12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PawGoda AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Online • AI Assistant',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              _showOptionsMenu();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),
          ),

          // Typing indicator
          if (_isTyping)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey.shade100,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.smart_toy,
                      color: Styles.highlightColor,
                      size: 20,
                    ),
                  ),
                  const Gap(8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
            ),

          // Quick replies (shown initially)
          if (_messages.length == 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey.shade100,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildQuickReply('📦 Packages'),
                    const Gap(8),
                    _buildQuickReply('🌞 Daycare'),
                    const Gap(8),
                    _buildQuickReply('📝 How to book'),
                    const Gap(8),
                    _buildQuickReply('💳 Payment'),
                  ],
                ),
              ),
            ),

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
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.emoji_emotions_outlined,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            // Emoji picker can be added here
                          },
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: _sendMessage,
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
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () => _sendMessage(_messageController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy,
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
                    borderRadius: BorderRadius.circular(20),
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
                      color: message.isUser ? Colors.white : Styles.blackColor,
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

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(
            0,
            -4 * (value - 0.5).abs() * 2,
          ),
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

  Widget _buildQuickReply(String text) {
    return InkWell(
      onTap: () => _sendMessage(text.substring(2)), // Remove emoji
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Styles.highlightColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          text,
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
            ListTile(
              leading: Icon(Icons.contact_support, color: Styles.highlightColor),
              title: const Text('Contact Human Support'),
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
              leading: Icon(Icons.help_outline, color: Styles.highlightColor),
              title: const Text('Help & FAQ'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
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