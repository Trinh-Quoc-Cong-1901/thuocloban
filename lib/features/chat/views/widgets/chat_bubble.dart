import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:thuoc_lo_ban_app/features/chat/models/chat_message.dart';

import 'thinking_animation.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    return Container(
      width: double.infinity,
      color: isUser ? Colors.blue[50] : Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(isUser),
              SizedBox(width: 16.w),
              Expanded(
                child:
                    message.isLoading
                        ? const ThinkingAnimation()
                        : _buildMessageContent(
                          message.content,
                          isUser,
                          context,
                        ),
              ),
            ],
          ),
          if (!isUser && !message.isLoading)
            Row(children: [_buildCopyButton(context)]),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isUser ? Colors.blue : const Color.fromARGB(255, 255, 255, 227),
      ),
      child:
          isUser
              ? Icon(Icons.person, color: Colors.white, size: 18.sp)
              : ClipOval(
                child: Image.asset(
                  'assets/icons/thien_thuoc.png',
                  width: 32.w,
                  height: 32.w,
                  fit: BoxFit.cover,
                ),
              ),
    );
  }

  Widget _buildMessageContent(
    String content,
    bool isUser,
    BuildContext context,
  ) {
    final baseStyle = TextStyle(
      fontSize: 16.sp,
      color: Colors.black,
      height: 1.5,
    );

    if (isUser) {
      return SelectableText(content, style: baseStyle);
    }

    return MarkdownBody(
      data: content,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        p: baseStyle,
        strong: baseStyle.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCopyButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 44.w, top: 12.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(4.r),
        onTap: () => _copyToClipboard(context),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(color: Colors.grey.withOpacity(0.3), width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.copy_outlined, size: 14.sp, color: Colors.grey[700]),
              SizedBox(width: 6.w),
              Text(
                'Sao chép',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: message.content));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Văn bản đã được sao chép vào bộ nhớ tạm.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
