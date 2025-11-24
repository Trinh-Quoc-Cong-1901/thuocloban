import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import 'package:thuoc_lo_ban_app/services/chat_service.dart';
import 'package:thuoc_lo_ban_app/utils/logger_utils.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../models/suggested_question.dart';

class ChatController extends GetxController {
  ChatService get _chatService => Get.find<ChatService>();

  // Controllers
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode messageFocusNode = FocusNode();

  final Rx<String?> _pendingContextInfo = Rx<String?>(null);

  final Uuid _uuid = const Uuid();

  // State
  final Rx<bool> isLoading = false.obs;
  final Rx<bool> isTyping = false.obs;
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxList<SuggestedQuestion> suggestedQuestions =
      <SuggestedQuestion>[].obs;
  final Rx<String?> currentConversationId = Rx<String?>(null);
  final Rx<String> selectedModel = 'openai'.obs;

  // Thêm biến observable để lưu trữ danh sách conversation
  final RxList<Conversation> conversationHistory = <Conversation>[].obs;

  final RxList<Map<String, dynamic>> availableModels =
      <Map<String, dynamic>>[].obs;

  // For tracking loading state when sending a message
  final Rx<ChatMessage?> loadingMessage = Rx<ChatMessage?>(null);

  // Track if we have initialMessage to control autofocus
  final Rx<bool> hasInitialMessage = false.obs;

  // Listen to message controller text changes
  final Rx<String> messageText = ''.obs;

  Future<String> _resolveUserId() => _chatService.getOrCreateUserId();

  String get userName => 'Người dùng';

  @override
  void onInit() {
    super.onInit();

    // Initialize controller properly with async/await
    _initializeController();

    // Listen to text changes
    messageController.addListener(() {
      messageText.value = messageController.text;
    });

    if (Get.arguments != null && Get.arguments is Map) {
      final Map args = Get.arguments as Map;
      if (args['initialMessage'] != null &&
          args['context'] != null &&
          args['autoSend'] == true) {
        String initialMessage = args['initialMessage'] as String;

        // Convert context to a string format to be sent
        final contextData = args['context'] as Map<String, dynamic>;
        String contextInfo = """

--- Thông tin đo đạc hiện tại ---
Kích thước: ${contextData['measurement']}mm
Kết quả thước Lô Ban: ${contextData['meaningData']?.toString() ?? 'Không có thông tin'}
--- Hết thông tin ---

Hãy giải thích chi tiết về kết quả này và đưa ra lời khuyên phong thủy phù hợp.""" ;

        hasInitialMessage.value = true;

        _pendingContextInfo.value = contextInfo;

        Future.delayed(const Duration(milliseconds: 100), () {
          sendMessage(text: initialMessage);
        });
        messageController.text = '';
      } else if (args['initialMessage'] != null) {
        String prompt = args['initialMessage'] as String;
        hasInitialMessage.value = true;

        if (args['autoSend'] == true) {
          Future.delayed(const Duration(milliseconds: 100), () {
            sendMessage(text: prompt);
          });
        } else {
          messageController.text = prompt;
          Future.delayed(const Duration(milliseconds: 100), () {
            messageFocusNode.requestFocus();
          });
        }
      }
    }
  }

  Future<void> _initializeController() async {
    try {
      LoggerUtils.debug('ChatController: Starting initialization');

      // Wait for ChatService to be ready before loading data
      await _initializeWithChatService();

      LoggerUtils.debug('ChatController: ChatService initialized, now loading suggested questions');

      // Only load suggested questions after ChatService is ready
      _loadSuggestedQuestions();

      LoggerUtils.debug('ChatController: Initialization completed');
    } catch (e) {
      LoggerUtils.error('ChatController: Error during initialization', e);

      // Fallback: load hardcoded questions if service initialization fails
      _loadHardcodedQuestions();
    }
  }

  void _loadHardcodedQuestions() {
    // Fallback hardcode questions for when service is not ready
    final debugQuestions = [
      SuggestedQuestion(
        id: '1',
        question: 'Thước Lô Ban là gì?',
        category: QuestionCategory.tongQuat,
      ),
      SuggestedQuestion(
        id: '2',
        question: 'Cách sử dụng thước Lô Ban cho cửa chính?',
        category: QuestionCategory.congCu,
      ),
      SuggestedQuestion(
        id: '3',
        question: 'Kích thước giường ngủ hợp phong thủy?',
        category: QuestionCategory.phongThuy,
      ),
      SuggestedQuestion(
        id: '4',
        question: 'Xem kích thước 81cm có tốt không?',
        category: QuestionCategory.doLuong,
      ),
    ];

    LoggerUtils.debug('ChatController: Loading hardcoded fallback questions');
    suggestedQuestions.assignAll(debugQuestions);
  }

  Future<void> _initializeWithChatService() async {
    try {
      final chatService = Get.find<ChatService>();
      // Đảm bảo ChatService đã hoàn thành khởi tạo database
      await chatService.init();
      _loadAvailableModels();
      _loadSuggestedQuestions();
      await _loadConversationHistory();
    } catch (e) {
      LoggerUtils.debug('ChatService not ready yet, retrying...');
      await Future.delayed(const Duration(milliseconds: 500));
      await _initializeWithChatService();
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    messageFocusNode.dispose();
    super.onClose();
  }

  Future<void> _loadConversationHistory() async {
    try {
      final userId = await _resolveUserId();
      final conversations = _chatService.getAllConversations(userId);
      conversationHistory.value = conversations;
    } catch (e) {
      LoggerUtils.error('Error loading conversation history', e);
    }
  }

  Future<void> _loadAvailableModels() async {
    try {
      final models = await _chatService.getAvailableModels();
      availableModels.assignAll(models);
      if (models.isNotEmpty) {
        selectedModel.value = models.first['id'].toString();
      }
    } catch (e) {
      LoggerUtils.error('Failed to load available models', e);
    }
  }

  void _loadSuggestedQuestions() {
    try {
      LoggerUtils.debug('ChatController: Loading suggested questions from ChatService');

      final allQuestions = _chatService.getSuggestedQuestions();

      if (allQuestions.isEmpty) {
        LoggerUtils.debug('ChatController: No questions found in ChatService, using fallback');
        _loadHardcodedQuestions();
        return;
      }

      LoggerUtils.debug('ChatController: Found ${allQuestions.length} questions in ChatService');

      // Shuffle để random hóa câu hỏi và chỉ lấy 4 câu đầu
      final shuffledQuestions = List<SuggestedQuestion>.from(allQuestions);
      shuffledQuestions.shuffle();
      final selectedQuestions = shuffledQuestions.take(4).toList();

      suggestedQuestions.assignAll(selectedQuestions);
      LoggerUtils.debug('ChatController: Successfully loaded ${selectedQuestions.length} suggested questions');
    } catch (e) {
      LoggerUtils.error('ChatController: Error loading suggested questions from service', e);
      // Fallback to hardcoded questions if service fails
      _loadHardcodedQuestions();
    }
  }

  Future<void> sendMessage({String? text}) async {
    final messageFromInput = text ?? messageController.text.trim();
    if (messageFromInput.isEmpty) return;

    if (text == null) {
      messageController.clear();
    }

    if (!_isThuocLoBanRelated(messageFromInput)) {
      final userMessage = ChatMessage(
        id: _uuid.v4(),
        content: messageFromInput,
        role: MessageRole.user,
        timestamp: DateTime.now(),
      );
      final nonRelatedResponse = ChatMessage(
        id: _uuid.v4(),
        content:
            'Xin lỗi, tôi chỉ có thể trả lời các câu hỏi liên quan đến Thước Lô Ban và phong thủy. Vui lòng đặt câu hỏi về chủ đề này nhé!',
        role: MessageRole.assistant,
        timestamp: DateTime.now().add(const Duration(milliseconds: 500)),
      );

      messages.addAll([userMessage, nonRelatedResponse]);
      isLoading.value = false;
      isTyping.value = false;
      Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
      return;
    }

    try {
      isLoading.value = true;
      String messageToSendToAI = messageFromInput;

      final now = DateTime.now();
      final dateTimeContext =
          "\n\n--- Thông tin thời gian hiện tại ---" 
          "Ngày giờ: ${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}"
          "--- Hết thông tin thời gian ---";

      messageToSendToAI = "$messageToSendToAI$dateTimeContext";

      if (_pendingContextInfo.value != null) {
        messageToSendToAI = "$messageToSendToAI\n\n${_pendingContextInfo.value}";
        _pendingContextInfo.value = null;
      }

      final userMessage = ChatMessage(
        id: _uuid.v4(),
        content: messageFromInput,
        role: MessageRole.user,
        timestamp: DateTime.now(),
      );

      final loadingResponseMessage = ChatMessage(
        id: _uuid.v4(),
        content: '',
        role: MessageRole.assistant,
        timestamp: DateTime.now().add(const Duration(milliseconds: 500)),
        isLoading: true,
      );

      messages.add(userMessage);
      messages.add(loadingResponseMessage);

      loadingMessage.value = loadingResponseMessage;

      messageFocusNode.unfocus();
      Future.delayed(const Duration(milliseconds: 450), _scrollToBottom);

      isTyping.value = true;

      try {
        final userId = await _resolveUserId();
        final conversation = await _chatService.sendMessage(
          userId: userId,
          message: messageToSendToAI,
          model: selectedModel.value,
          conversationId: currentConversationId.value,
        );

        currentConversationId.value = conversation.id;
        
        final cleanedMessages = _cleanMessagesForDisplay(
          conversation.messages,
          latestUserInput: messageFromInput,
        );
        messages.assignAll(cleanedMessages);

        await _loadConversationHistory();
        _loadSuggestedQuestions();
      } catch (e) {
        LoggerUtils.error('Error sending message', e);
        final updatedMessages = messages.where((msg) => !msg.isLoading).toList();
        updatedMessages.add(
          ChatMessage(
            id: _uuid.v4(),
            content: 'Đã xảy ra lỗi khi gửi tin nhắn: ${e.toString()}',
            role: MessageRole.assistant,
            timestamp: DateTime.now(),
          ),
        );
        messages.assignAll(updatedMessages);
      } finally {
        loadingMessage.value = null;
        isLoading.value = false;
        isTyping.value = false;
        Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
      }
    } catch (e) {
      LoggerUtils.error('Unexpected error in sendMessage', e);
      loadingMessage.value = null;
      isLoading.value = false;
      isTyping.value = false;
      final updatedMessages = messages.where((msg) => !msg.isLoading).toList();
      updatedMessages.add(
        ChatMessage(
          id: _uuid.v4(),
          content: 'Đã xảy ra lỗi không mong muốn: ${e.toString()}',
          role: MessageRole.assistant,
          timestamp: DateTime.now(),
        ),
      );
      messages.assignAll(updatedMessages);
    }
  }

  void useSuggestedQuestion(String question) {
    sendMessage(text: question);
  }

  Future<void> loadConversation(String conversationId) async {
    try {
      isLoading.value = true;
      final userId = await _resolveUserId();
      final conversation = _chatService.getConversation(userId, conversationId);
      if (conversation != null) {
        currentConversationId.value = conversationId;
        final cleanedMessages =
            _cleanMessagesForDisplay(conversation.messages);
        messages.assignAll(cleanedMessages);
        hasInitialMessage.value = false;
        _loadSuggestedQuestions();
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      }
    } catch (e) {
      LoggerUtils.error('Error loading conversation', e);
    } finally {
      isLoading.value = false;
    }
  }
  
  List<ChatMessage> _cleanMessagesForDisplay(
    List<ChatMessage> apiMessages, {
    String? latestUserInput,
  }) {
    final lastUserIndex = apiMessages.lastIndexWhere(
      (msg) => msg.role == MessageRole.user,
    );

    return apiMessages.asMap().entries.map((entry) {
      final index = entry.key;
      final msg = entry.value;

      if (msg.role != MessageRole.user) {
        return msg;
      }

      final hasTimeBlock = _hasTimeContext(msg.content);
      final cleanedContent = _stripTimeContext(msg.content);

      if (latestUserInput != null &&
          latestUserInput.isNotEmpty &&
          index == lastUserIndex &&
          hasTimeBlock) {
        return msg.copyWith(content: latestUserInput);
      }

      return msg.copyWith(content: cleanedContent);
    }).toList();
  }

  String _stripTimeContext(String content) {
    final startMarker = '--- Thông tin thời gian hiện tại ---';
    final endMarker = '--- Hết thông tin thời gian ---';
    final startIndex = content.indexOf(startMarker);

    if (startIndex == -1) {
      return content.trim();
    }

    final endIndex = content.indexOf(endMarker, startIndex);
    final cutIndex =
        endIndex == -1 ? content.length : endIndex + endMarker.length;
    final replaced = content.replaceRange(startIndex, cutIndex, '');
    return replaced.trim();
  }

  bool _hasTimeContext(String content) {
    return content.contains('--- Thông tin thời gian hiện tại ---') &&
        content.contains('--- Hết thông tin thời gian ---');
  }

  void startNewConversation() {
    currentConversationId.value = null;
    messages.clear();
    _pendingContextInfo.value = null;
    hasInitialMessage.value = false;
    _loadSuggestedQuestions();
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      final userId = await _resolveUserId();
      await _chatService.deleteConversation(userId, conversationId);
      final index = conversationHistory.indexWhere((conv) => conv.id == conversationId);
      if (index >= 0) {
        conversationHistory.removeAt(index);
      }
      if (conversationId == currentConversationId.value) {
        startNewConversation();
      }
    } catch (e) {
      LoggerUtils.error('Error deleting conversation', e);
    }
  }

  Future<void> clearAllConversations() async {
    try {
      final userId = await _resolveUserId();
      await _chatService.clearAllConversations(userId);
      startNewConversation();
      conversationHistory.clear();
    } catch (e) {
      LoggerUtils.error('Error clearing all conversations', e);
    }
  }

  List<Conversation> getConversationHistory() {
    return conversationHistory;
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
      );
    }
  }

  bool _isThuocLoBanRelated(String message) {
    // For thuocloban, we can assume most questions are related.
    // This can be expanded with more sophisticated keyword checking if needed.
    return true;
  }
}
