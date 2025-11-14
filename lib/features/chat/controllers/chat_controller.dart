import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/chat_message.dart';
import '../models/suggested_question.dart';
import '../../../services/chat_service.dart';

class ChatController extends GetxController {
  // Services
  ChatService get _chatService => ChatService.to;

  // Controllers
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isInitialized = false.obs;
  final RxList<ChatMessage> currentMessages = <ChatMessage>[].obs;

  // UI state
  final RxBool showSuggestions = true.obs;
  final RxBool keyboardVisible = false.obs;
  final RxString messageText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    print('🎯 ChatController onInit called');
    // Listen to text changes
    messageController.addListener(_onTextChanged);
    _initialize();
  }

  void _onTextChanged() {
    messageText.value = messageController.text;
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> _initialize() async {
    try {
      print('🎯 ChatController initializing...');

      // Debug: Check ChatService state
      _debugChatServiceState();

      // Check if we have initial arguments
      final args = Get.arguments as Map<String, dynamic>?;

      if (args != null) {
        await _handleInitialArguments(args);
      } else {
        _loadSuggestedQuestions();
      }

      isInitialized.value = true;
      print('🎯 ChatController initialized successfully');
    } catch (e) {
      print('❌ Error initializing ChatController: $e');
      isInitialized.value = true;
    }
  }

  void _debugChatServiceState() {
    try {
      final chatService = _chatService;
      print('🔍 ChatService state check:');
      print('  - Suggested questions: ${chatService.suggestedQuestions.length}');
    } catch (e) {
      print('❌ Error checking ChatService state: $e');
    }
  }

  Future<void> _handleInitialArguments(Map<String, dynamic> args) async {
    final String? initialMessage = args['initialMessage'];
    final bool autoSend = args['autoSend'] ?? false;
    final Map<String, dynamic>? context = args['context'];

    if (initialMessage != null) {
      messageController.text = initialMessage;
      messageText.value = initialMessage;
      showSuggestions.value = false;

      if (autoSend) {
        await sendMessage(context: context);
      }
    }
  }

  void _loadSuggestedQuestions() {
    showSuggestions.value = true;
  }

  Future<void> sendMessage({Map<String, dynamic>? context}) async {
    final message = messageController.text.trim();
    if (message.isEmpty || isLoading.value) return;

    try {
      isLoading.value = true;
      showSuggestions.value = false;

      // Add user message to current chat
      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: message,
        role: MessageRole.user,
        timestamp: DateTime.now(),
      );
      currentMessages.add(userMessage);

      // Clear input
      messageController.clear();
      messageText.value = '';
      _scrollToBottom();

      // Send message to AI service and get response
      final response = await _chatService.sendSimpleMessage(
        message: message,
        context: context,
      );

      if (response != null) {
        // Add AI response
        final aiMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: response,
          role: MessageRole.assistant,
          timestamp: DateTime.now(),
        );
        currentMessages.add(aiMessage);
        _scrollToBottom();
      } else {
        Get.snackbar(
          'Lỗi',
          'Không thể gửi tin nhắn. Vui lòng thử lại.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      print('Error sending message: $e');
      Get.snackbar(
        'Lỗi',
        'Đã xảy ra lỗi khi gửi tin nhắn',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }


  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void onSuggestedQuestionTap(SuggestedQuestion question) {
    messageController.text = question.question;
    messageText.value = question.question;
    showSuggestions.value = false;
    sendMessage();
  }

  void startNewConversation() {
    currentMessages.clear();
    showSuggestions.value = true;
    messageController.clear();
    messageText.value = '';
  }


  void onKeyboardVisibilityChanged(bool visible) {
    keyboardVisible.value = visible;
    if (visible) {
      _scrollToBottom();
    }
  }

  // Get suggested questions from chat service
  List<SuggestedQuestion> get suggestedQuestions => _chatService.suggestedQuestions;

  // Get conversation title
  String get conversationTitle {
    return 'Trò chuyện cùng Thiên Thước';
  }

  // Check if we can send message
  bool get canSendMessage => !isLoading.value && messageText.value.trim().isNotEmpty;
}