import 'package:flutter/material.dart';
import 'services/ai_service.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {

  final TextEditingController controller = TextEditingController();
  List<Map<String, String>> messages = [];

  bool isLoading = false;

  static const Color bgColor = Color(0xFFF5F2EF);
  static const Color primaryText = Color(0xFF2E2E2E);

  /// 🔥 SUGGESTED QUESTIONS
  final List<String> suggestions = [
    "How much should I feed my dog?",
    "Best food for puppies?",
    "How often should I refill water?",
    "Why is my pet not eating?",
  ];

  /// 🔥 SEND MESSAGE
  void sendMessage([String? input]) async {
    final text = input ?? controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": text});
      isLoading = true;
    });

    controller.clear();

    try {
      final reply = await AIService.sendMessage(
        "You are a professional pet care expert. Answer clearly and helpfully: $text",
      );

      setState(() {
        messages.add({"role": "ai", "text": reply});
      });

    } catch (e) {
      setState(() {
        messages.add({"role": "ai", "text": "Error: $e"});
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 5),

          /// HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "Pet AI ",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: "Assistant",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC9A66B),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// SUGGESTIONS
          if (messages.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: suggestions.map((q) {
                      return GestureDetector(
                        onTap: () => sendMessage(q),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.9),
                                offset: const Offset(-3, -3),
                                blurRadius: 6,
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                offset: const Offset(3, 3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Text(q, style: const TextStyle(fontSize: 13)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

          /// CHAT
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {

                final msg = messages[index];
                final isUser = msg["role"] == "user";

                return Align(
                  alignment:
                  isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFFC9A66B)
                          : bgColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: isUser
                          ? []
                          : [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.9),
                          offset: const Offset(-3, -3),
                          blurRadius: 6,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(3, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),

                    /// 🔥 TYPEWRITER HERE
                    child: isUser
                        ? Text(
                      msg["text"] ?? "",
                      style: const TextStyle(color: Colors.white),
                    )
                        : TypewriterText(
                      text: msg["text"] ?? "",
                    ),
                  ),
                );
              },
            ),
          ),

          /// TYPING INDICATOR
          if (isLoading)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.9),
                          offset: const Offset(-3, -3),
                          blurRadius: 6,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(3, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Text("Typing..."),
                  )
                ],
              ),
            ),

          /// INPUT
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.9),
                  offset: const Offset(-3, -3),
                  blurRadius: 6,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(3, 3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: primaryText),
                    decoration: const InputDecoration(
                      hintText: "Ask something...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => sendMessage(),
                  icon: const Icon(Icons.send, color: Color(0xFFC9A66B)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// 🔥 TYPEWRITER WIDGET
class TypewriterText extends StatefulWidget {
  final String text;

  const TypewriterText({super.key, required this.text});

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String displayedText = "";

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() async {
    for (int i = 0; i < widget.text.length; i++) {
      await Future.delayed(const Duration(milliseconds: 3));
      if (!mounted) return;
      setState(() {
        displayedText = widget.text.substring(0, i + 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      displayedText,
      style: const TextStyle(color: Color(0xFF2E2E2E)),
    );
  }
}