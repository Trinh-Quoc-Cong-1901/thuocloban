import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/suggested_question_chip.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();

    return Scaffold(
      backgroundColor: const Color(0xFF030D4C),
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(controller),
      body: SafeArea(
        child: Obx(() {
          if (!controller.isInitialized.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFFCD45),
              ),
            );
          }

          return Column(
            children: [
              Expanded(child: _buildChatContent(controller)),
              _buildInputSection(controller),
            ],
          );
        }),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ChatController controller) {
    return AppBar(
      backgroundColor: const Color(0xFF030D4C),
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFCD45), Color(0xFFFF8C45)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.psychology,
              color: Color(0xFF030D4C),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              controller.conversationTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        // Menu button
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: const Color(0xFF030D4C),
          onSelected: (value) => _handleMenuAction(controller, value),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'new_chat',
              child: Row(
                children: [
                  Icon(Icons.add_comment, color: Color(0xFF00E8E8)),
                  SizedBox(width: 12),
                  Text('Cuộc trò chuyện mới', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChatContent(ChatController controller) {
    return Obx(() {
      if (controller.showSuggestions.value && controller.currentMessages.isEmpty) {
        return _buildEmptyState(controller);
      }

      return ListView.builder(
        controller: controller.scrollController,
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: controller.currentMessages.length,
        itemBuilder: (context, index) {
          final message = controller.currentMessages[index];
          return ChatBubble(message: message);
        },
      );
    });
  }

  Widget _buildEmptyState(ChatController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32), // Top spacing

          // Welcome text
          const Text(
            'Chào bạn! Tôi là Thiên Thước',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          Text(
            'Tôi có thể giúp bạn hiểu về thước Lô Ban và tư vấn các kích thước hợp phong thủy.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Suggested questions
          const Text(
            'Câu hỏi gợi ý:',
            style: TextStyle(
              color: Color(0xFFFFCD45),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          // Suggested questions list - always visible
          Obx(() => SizedBox(
            height: 120, // Fixed height to ensure visibility
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: controller.suggestedQuestions.length,
              itemBuilder: (context, index) {
                final question = controller.suggestedQuestions[index];
                return Container(
                  width: 240,
                  margin: const EdgeInsets.only(right: 12),
                  child: SuggestedQuestionChip(
                    question: question,
                    onTap: () => controller.onSuggestedQuestionTap(question),
                  ),
                );
              },
            ),
          )),

          const SizedBox(height: 32), // Bottom spacing
        ],
      ),
    );
  }

  Widget _buildInputSection(ChatController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8), // Reduced padding
      decoration: BoxDecoration(
        color: const Color(0xFF030D4C),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 40, // Ensure minimum height for input field
                maxHeight: 100, // Limit max height to prevent expansion
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12), // Reduced padding
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(22), // Slightly reduced
                border: Border.all(
                  color: const Color(0xFF00E8E8).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: controller.messageController,
                style: const TextStyle(color: Colors.white),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => controller.sendMessage(),
                decoration: const InputDecoration(
                  hintText: 'Hỏi về thước Lô Ban...',
                  hintStyle: TextStyle(
                    color: Color(0xFFBBBBBB),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10), // Reduced padding
                ),
              ),
            ),
          ),
          const SizedBox(width: 10), // Reduced spacing
          Obx(() => GestureDetector(
            onTap: controller.canSendMessage ? () => controller.sendMessage() : null,
            child: Container(
              width: 44, // Slightly smaller
              height: 44, // Slightly smaller
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: controller.canSendMessage
                    ? const LinearGradient(
                        colors: [Color(0xFF00E8E8), Color(0xFF00B8B8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: controller.canSendMessage ? null : Colors.grey,
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 18, // Slightly smaller
                      height: 18, // Slightly smaller
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18, // Slightly smaller
                    ),
            ),
          )),
        ],
      ),
    );
  }


  void _handleMenuAction(ChatController controller, String action) {
    switch (action) {
      case 'new_chat':
        controller.startNewConversation();
        break;
    }
  }


}