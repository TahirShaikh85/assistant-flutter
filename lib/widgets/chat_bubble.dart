import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String humanMessage;
  final String assistantMessage;

  const ChatBubble({
    super.key,
    required this.humanMessage,
    required this.assistantMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (humanMessage.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(humanMessage),
          ),
        if (assistantMessage.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(assistantMessage),
          ),
      ],
    );
  }
}
