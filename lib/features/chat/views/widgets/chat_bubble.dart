import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import '../../models/chat_message.dart';
import 'thinking_animation.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final isLoading = message.isLoading;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(),
          if (!isUser) const SizedBox(width: 12),

          Flexible(
            child: isLoading
                ? const ThinkingAnimation()
                : _buildMessageBubble(isUser),
          ),

          if (isUser) const SizedBox(width: 12),
          if (isUser) _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFFCD45), Color(0xFFFF8C45)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFCD45).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.psychology,
        color: Color(0xFF030D4C),
        size: 20,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF00E8E8), Color(0xFF00B8B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E8E8).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildMessageBubble(bool isUser) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isUser
            ? const LinearGradient(
                colors: [Color(0xFF00E8E8), Color(0xFF00B8B8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF030D4C), Color(0xFF0A1B5C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
          bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
        ),
        border: Border.all(
          color: isUser
              ? Colors.transparent
              : const Color(0xFF00E8E8).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isUser)
            _buildUserMessage()
          else
            _buildAiMessage(),

          const SizedBox(height: 8),

          _buildTimestamp(isUser),
        ],
      ),
    );
  }

  Widget _buildUserMessage() {
    return Text(
      message.content,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        height: 1.4,
      ),
    );
  }

  Widget _buildAiMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Markdown content
        MarkdownBody(
          data: message.content,
          styleSheet: MarkdownStyleSheet(
            p: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.4,
            ),
            strong: const TextStyle(
              color: Color(0xFFFFCD45),
              fontWeight: FontWeight.bold,
            ),
            h1: const TextStyle(
              color: Color(0xFFFFCD45),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            h2: const TextStyle(
              color: Color(0xFFFFCD45),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            h3: const TextStyle(
              color: Color(0xFFFFCD45),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            listBullet: const TextStyle(
              color: Color(0xFF00E8E8),
            ),
            blockquote: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontStyle: FontStyle.italic,
            ),
            code: TextStyle(
              backgroundColor: Colors.white.withOpacity(0.1),
              color: const Color(0xFF00E8E8),
              fontFamily: 'monospace',
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Copy button
        Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _copyMessage(),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF00E8E8).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.copy,
                      size: 14,
                      color: const Color(0xFF00E8E8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Sao chép',
                      style: TextStyle(
                        color: const Color(0xFF00E8E8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimestamp(bool isUser) {
    final timeString = _formatTime(message.timestamp);

    return Text(
      timeString,
      style: TextStyle(
        color: isUser
            ? Colors.white.withOpacity(0.8)
            : Colors.white.withOpacity(0.6),
        fontSize: 12,
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inHours < 1) {
      return '\${difference.inMinutes} phút trước';
    } else if (difference.inDays < 1) {
      return '\${difference.inHours} giờ trước';
    } else {
      return '\${timestamp.day}/\${timestamp.month}/\${timestamp.year}';
    }
  }

  void _copyMessage() {
    Clipboard.setData(ClipboardData(text: message.content));
    Get.snackbar(
      'Đã sao chép',
      'Nội dung đã được sao chép vào clipboard',
      backgroundColor: const Color(0xFF00E8E8),
      colorText: const Color(0xFF030D4C),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
      borderRadius: 12,
    );
  }
}