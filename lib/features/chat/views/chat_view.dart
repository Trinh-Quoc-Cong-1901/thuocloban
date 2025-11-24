import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thuoc_lo_ban_app/features/chat/models/conversation.dart';
import '../controllers/chat_controller.dart';
import 'widgets/chat_bubble.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return _ChatOrientationWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Thiên Thước', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: const Color(0xFF030D4C),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
            tooltip: 'Back',
          ),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.history, color: Colors.white),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                tooltip: 'Lịch sử',
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () => controller.startNewConversation(),
              tooltip: 'Trò chuyện mới',
            ),
          ],
        ),
        drawer: _buildDrawer(context),
        body: SafeArea(
          bottom: true,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 16.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32.r),
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(child: _buildChatList()),
                      _buildSuggestedQuestions(),
                      _buildInputField(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final appBarHeight = AppBar().preferredSize.height;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            height: appBarHeight + MediaQuery.of(context).padding.top,
            color: const Color(0xFF030D4C),
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  'Lịch sử trò chuyện',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Divider(color: Colors.grey[300], thickness: 1, height: 0),
          SizedBox(height: 8.h),
          Expanded(
            child: Obx(() {
              final conversations = controller.conversationHistory;
              return conversations.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.grey.withAlpha((0.6 * 255).round()),
                          size: 48.sp,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Không có lịch sử trò chuyện',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18.sp,
                          ),
                        ),
                      ],
                    ),
                  )
                  : _buildConversationList(conversations, context);
            }),
          ),
          SafeArea(child: Container()),
        ],
      ),
    );
  }

  Widget _buildConversationList(
    List<Conversation> conversations,
    BuildContext context,
  ) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return _buildConversationTile(conversation, context);
      },
    );
  }

  Widget _buildConversationTile(
    Conversation conversation,
    BuildContext context,
  ) {
    return GestureDetector(
      onLongPress: () {
        _showDeleteMenu(context, conversation);
      },
      child: ListTile(
        title: Text(
          conversation.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          _formatDate(conversation.updatedAt),
          style: TextStyle(color: Colors.grey, fontSize: 12.sp),
        ),
        onTap: () {
          controller.loadConversation(conversation.id);
          Get.back();
        },
      ),
    );
  }

  void _showDeleteMenu(BuildContext context, Conversation conversation) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                title: const Text('Xóa cuộc trò chuyện'),
                onTap: () {
                  Navigator.pop(context);
                  controller.deleteConversation(conversation.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel_outlined),
                title: const Text('Huỷ'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final dateTime = date.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateToCheck == today) {
      return 'Hôm nay, ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (dateToCheck == today.subtract(const Duration(days: 1))) {
      return 'Hôm qua, ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const Spacer(),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icons/thien_thuoc.png',
                height: 100.w,
                width: 100.w,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 16.h),
              Text(
                'Thiên Thước',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF030D4C),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Hôm nay Thiên Thước\ncó thể giúp gì cho bạn?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildChatList() {
    return Obx(() {
      if (controller.messages.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        controller: controller.scrollController,
        padding: EdgeInsets.zero,
        itemCount: controller.messages.length,
        itemBuilder: (context, index) {
          final message = controller.messages[index];
          return ChatBubble(message: message);
        },
      );
    });
  }

  Widget _buildSuggestedQuestions() {
    return Obx(() {
      // Ẩn suggested questions nếu không có questions hoặc đã có messages
      if (controller.suggestedQuestions.isEmpty || controller.messages.isNotEmpty) {
        return const SizedBox.shrink();
      }

      // Layout horizontal scroll như thansohoc
      return Container(
        height: 100.h, // Tăng height để chứa đủ 2 dòng text
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        color: Colors.transparent, // Remove debug background
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
              child: Text(
                'Gợi ý cho bạn',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.suggestedQuestions.length,
                itemBuilder: (context, index) {
                  final question = controller.suggestedQuestions[index];
                  return Container(
                    margin: EdgeInsets.only(
                      left: index == 0 ? 12.w : 4.w,
                      right: index == controller.suggestedQuestions.length - 1 ? 12.w : 8.w,
                    ),
                    width: 160.w, // Giảm width để tránh overflow
                    child: Card(
                      elevation: 2,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        side: BorderSide(
                          color: const Color(0xFF030D4C).withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16.r),
                        onTap: () => controller.useSuggestedQuestion(question.question),
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          child: Center(
                            child: Text(
                              question.question,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                                height: 1.3, // Tăng line height để text 2 dòng dễ đọc hơn
                              ),
                              maxLines: 2, // Đảm bảo hiển thị đúng 2 dòng
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }


  Widget _buildInputField() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Obx(
                () => TextField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: controller.messageController,
                  focusNode: controller.messageFocusNode,
                  maxLines: 5,
                  minLines: 1,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.sp,
                  ),
                  autofocus: !controller.hasInitialMessage.value,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Hỏi Thiên Thước...',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 18.sp,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    isCollapsed: true,
                  ),
                  onSubmitted: (_) {
                    if (controller.messageController.text.trim().isNotEmpty) {
                      controller.sendMessage();
                    }
                  },
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Obx(
            () => Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24.r),
                onTap: controller.messageText.value.trim().isEmpty || controller.isLoading.value
                    ? null
                    : controller.sendMessage,
                child: Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: controller.messageText.value.trim().isEmpty ? Colors.grey : const Color(0xFF030D4C),
                    shape: BoxShape.circle,
                  ),
                  child: controller.isLoading.value
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        )
                      : Icon(
                          Icons.send,
                          size: 24.sp,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _ChatOrientationWrapper extends StatefulWidget {
  final Widget child;

  const _ChatOrientationWrapper({
    required this.child,
  });

  @override
  State<_ChatOrientationWrapper> createState() =>
      _ChatOrientationWrapperState();
}

class _ChatOrientationWrapperState extends State<_ChatOrientationWrapper> {
  @override
  void initState() {
    super.initState();
    _setPortraitOrientation();
  }

  @override
  void dispose() {
    _restoreLandscapeOrientation();
    super.dispose();
  }

  void _setPortraitOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _restoreLandscapeOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
