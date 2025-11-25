import 'dart:math';

import 'package:get/get.dart';
import 'package:thuoc_lo_ban_app/features/chat/models/chat_message.dart';
import 'package:thuoc_lo_ban_app/features/chat/models/conversation.dart';
import 'package:thuoc_lo_ban_app/features/chat/models/suggested_question.dart';
import 'package:thuoc_lo_ban_app/services/providers/api_provider.dart';
import 'package:thuoc_lo_ban_app/services/providers/database_provider.dart';
import 'package:thuoc_lo_ban_app/services/providers/storage_provider.dart';
import 'package:thuoc_lo_ban_app/utils/logger_utils.dart';
import 'package:uuid/uuid.dart';

class ChatService extends GetxService {
  @override
  void onInit() {
    super.onInit();
    LoggerUtils.debug('ChatService initialized');
    // Don't call init() here - it will be called asynchronously
  }

  @override
  void onReady() {
    super.onReady();
    LoggerUtils.debug('ChatService is ready');
  }

  // >>> START NEW METHOD - getAiCompletionForPrompt
  /// Gửi một prompt đến AI và chỉ trả về nội dung phản hồi của AI.
  /// Không lưu cuộc hội thoại này vào lịch sử chat chính thức.
  Future<String> getAiCompletionForPrompt({
    required String prompt,
    String model = 'lao_dai', // Model mặc định
    String tempUserId = 'prompt_only_user', // ID người dùng tạm thời
  }) async {
    LoggerUtils.debug(
      "ChatService: getAiCompletionForPrompt called with prompt: ${prompt.substring(0, min(50, prompt.length))}...",
    );
    try {
      final Map<String, dynamic> data = {
        'message': prompt,
        'model': model,
        'userId':
            tempUserId, // Sử dụng một userId tạm thời, không nên trùng với userId thật
        // 'conversationId': null, // Luôn tạo conversation mới cho mục đích này
      };

      final response = await _apiProvider.post('/api/chat', data: data);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true &&
            responseData['responseObject'] != null) {
          final conversation = Conversation.fromJson(
            responseData['responseObject'],
          );

          // Lấy message cuối cùng từ assistant
          if (conversation.messages.isNotEmpty) {
            // >>> START MODIFICATION
            ChatMessage? lastAssistantMessage;
            for (int i = conversation.messages.length - 1; i >= 0; i--) {
              if (conversation.messages[i].role == MessageRole.assistant &&
                  !conversation.messages[i].isLoading) {
                lastAssistantMessage = conversation.messages[i];
                break;
              }
            }
            // >>> END MODIFICATION
            if (lastAssistantMessage != null) {
              LoggerUtils.debug(
                "ChatService: AI completion received successfully.",
              );
              return lastAssistantMessage.content;
            }
          }
          LoggerUtils.warning(
            "ChatService: AI response parsed, but no assistant message found.",
          );
          return "Linh Chiêm không có phản hồi cho yêu cầu này.";
        } else {
          LoggerUtils.error(
            "ChatService: AI API call was not successful. Message: ${responseData['message']}",
          );
          return "Lỗi từ Linh Chiêm: ${responseData['message'] ?? 'Không rõ lỗi'}";
        }
      }
      LoggerUtils.error(
        "ChatService: AI API call failed with status code ${response.statusCode}. Body: ${response.data}",
      );
      return "Lỗi kết nối đến Linh Chiêm (Code: ${response.statusCode}).";
    } catch (e) {
      LoggerUtils.error(
        'ChatService: Exception in getAiCompletionForPrompt',
        e,
      );
      return "Đã xảy ra lỗi khi giao tiếp với Linh Chiêm: ${e.toString()}";
    }
  }
  // >>> END NEW METHOD - getAiCompletionForPrompt

  final ApiProvider _apiProvider = ApiProvider();
  final DatabaseProvider _databaseProvider = DatabaseProvider();
  final StorageProvider _storageProvider = StorageProvider();
  final Uuid _uuid = const Uuid();
  String? _cachedUserId;
  Future<String>? _userIdFuture;
  String? _cachedDeviceId;

  // Box names for Hive database
  static const String _conversationsBoxName = 'conversations';
  static const String _suggestedQuestionsBoxName = 'suggested_questions';
  static const String _deviceIdKey = 'chat_device_id';

  // Version control for suggested questions
  static const int _suggestedQuestionsVersion =
      3; // Updated to use questions from model instead of hardcoding

  // Singleton pattern
  static ChatService get to => Get.find<ChatService>();

  Future<ChatService> init() async {
    await _databaseProvider.openBox<String>(_conversationsBoxName);
    await _databaseProvider.openBox<String>(_suggestedQuestionsBoxName);

    // Check version and update suggested questions if needed
    final storedVersion =
        _databaseProvider.getValue<int>(
          _suggestedQuestionsBoxName,
          'version',
        ) ??
        0;
    final hasQuestions =
        _databaseProvider.getValue(_suggestedQuestionsBoxName, 'questions') !=
        null;

    if (!hasQuestions || storedVersion < _suggestedQuestionsVersion) {
      await _initializeSuggestedQuestions();
      await _databaseProvider.putValue<int>(
        _suggestedQuestionsBoxName,
        'version',
        _suggestedQuestionsVersion,
      );
    }

    return this;
  }

  // Initialize default suggested questions from model
  Future<void> _initializeSuggestedQuestions() async {
    // Use questions from SuggestedQuestion model instead of hardcoding here
    final questions = SuggestedQuestion.getDefaultQuestions();

    // Save to database
    await _databaseProvider.putJsonList(
      _suggestedQuestionsBoxName,
      'questions',
      questions.map((q) => q.toJson()).toList(),
    );
  }

  QuestionCategory _categoryFromName(String categoryName) {
    return QuestionCategory.values.firstWhere(
      (category) => category.name == categoryName,
      orElse: () => QuestionCategory.tongQuat,
    );
  }

  // Get suggested questions
  List<SuggestedQuestion> getSuggestedQuestions({String? category}) {
    final jsonList = _databaseProvider.getJsonList(
      _suggestedQuestionsBoxName,
      'questions',
    );
    if (jsonList == null) return [];

    final allQuestions =
        jsonList.map((json) => SuggestedQuestion.fromJson(json)).toList();

    if (category != null) {
      return allQuestions.where((q) => q.category.name == category).toList();
    }

    return allQuestions;
  }

  // Get suggested questions by category
  Map<String, List<SuggestedQuestion>> getSuggestedQuestionsByCategory() {
    final allQuestions = getSuggestedQuestions();
    final Map<String, List<SuggestedQuestion>> categorizedQuestions = {};

    for (final question in allQuestions) {
      final categoryKey = question.category.name;
      categorizedQuestions.putIfAbsent(categoryKey, () => []);
      categorizedQuestions[categoryKey]!.add(question);
    }

    return categorizedQuestions;
  }

  // Add a custom suggested question
  Future<void> addSuggestedQuestion(String question, String category) async {
    final newQuestion = SuggestedQuestion(
      id: _uuid.v4(),
      question: question,
      category: _categoryFromName(category),
    );

    final existingList = getSuggestedQuestions();
    existingList.add(newQuestion);

    await _databaseProvider.putJsonList(
      _suggestedQuestionsBoxName,
      'questions',
      existingList.map((q) => q.toJson()).toList(),
    );
  }

  // Get all conversations for a user
  List<Conversation> getAllConversations(String userId) {
    final jsonList = _databaseProvider.getJsonList(
      _conversationsBoxName,
      userId,
    );
    if (jsonList == null) return [];

    final conversations =
        jsonList.map((json) => Conversation.fromJson(json)).toList();

    // Sort conversations by updatedAt in descending order (newest first)
    conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return conversations;
  }

  // Get a specific conversation
  Conversation? getConversation(String userId, String conversationId) {
    final conversations = getAllConversations(userId);
    return conversations.firstWhereOrNull((conv) => conv.id == conversationId);
  }

  // Save a conversation
  Future<void> saveConversation(
    String userId,
    Conversation conversation,
  ) async {
    final List<Conversation> conversations = getAllConversations(userId);

    // Check if conversation already exists
    final index = conversations.indexWhere(
      (conv) => conv.id == conversation.id,
    );
    if (index >= 0) {
      // Update existing conversation
      conversations[index] = conversation;
    } else {
      // Add new conversation
      conversations.add(conversation);
    }

    await _databaseProvider.putJsonList(
      _conversationsBoxName,
      userId,
      conversations.map((conv) => conv.toJson()).toList(),
    );
  }

  // Delete a conversation
  Future<void> deleteConversation(String userId, String conversationId) async {
    final List<Conversation> conversations = getAllConversations(userId);
    conversations.removeWhere((conv) => conv.id == conversationId);

    await _databaseProvider.putJsonList(
      _conversationsBoxName,
      userId,
      conversations.map((conv) => conv.toJson()).toList(),
    );
  }

  // Clear all conversations for a user
  Future<void> clearAllConversations(String userId) async {
    await _databaseProvider.deleteValue(_conversationsBoxName, userId);
  }

  /// Ensure there's a registered user on the API side and cache its ID.
  Future<String> getOrCreateUserId() async {
    if (_cachedUserId != null && _cachedUserId!.isNotEmpty) {
      return _cachedUserId!;
    }

    final storedUserId = _storageProvider.getUserId();
    if (storedUserId != null && storedUserId.isNotEmpty) {
      _cachedUserId = storedUserId;
      return storedUserId;
    }

    if (_userIdFuture != null) {
      return _userIdFuture!;
    }

    _userIdFuture = _ensureUserId();
    try {
      return await _userIdFuture!;
    } finally {
      _userIdFuture = null;
    }
  }

  Future<String> _ensureUserId() async {
    final deviceId = await _ensureDeviceId();
    final existingUserId = await _getUserIdByDeviceId(deviceId);
    if (existingUserId != null && existingUserId.isNotEmpty) {
      return existingUserId;
    }
    return await _createGuestUser(deviceId);
  }

  Future<String> _ensureDeviceId() async {
    if (_cachedDeviceId != null && _cachedDeviceId!.isNotEmpty) {
      return _cachedDeviceId!;
    }

    final storedDeviceId = _storageProvider.read(_deviceIdKey);
    if (storedDeviceId != null && storedDeviceId.isNotEmpty) {
      _cachedDeviceId = storedDeviceId;
      return storedDeviceId;
    }

    final newDeviceId = _uuid.v4();
    final saved = await _storageProvider.write(_deviceIdKey, newDeviceId);
    if (!saved) {
      LoggerUtils.warning(
        'ChatService: Failed to persist generated device ID for chat user.',
      );
    }
    _cachedDeviceId = newDeviceId;
    return newDeviceId;
  }

  Future<void> _storeUserId(String userId) async {
    _cachedUserId = userId;
    final saved = await _storageProvider.setUserId(userId);
    if (!saved) {
      LoggerUtils.warning(
        'ChatService: Failed to persist the chat user ID: $userId',
      );
    }
  }

  Future<String?> _getUserIdByDeviceId(String deviceId) async {
    try {
      final response = await _apiProvider.get('/users/device/$deviceId');
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true) {
        final responseObject = response.data['responseObject'];
        if (responseObject is Map<String, dynamic>) {
          final String? id = responseObject['id'];
          if (id != null && id.isNotEmpty) {
            await _storeUserId(id);
            return id;
          }
        }
      }
    } catch (e, stackTrace) {
      LoggerUtils.error(
        'ChatService: Failed to lookup user by device ID: $deviceId',
        e,
        stackTrace,
      );
    }
    return null;
  }

  Future<String> _createGuestUser(String deviceId) async {
    final payload = {
      'name': 'Thiên Thước',
      'birthDate': '1990-01-01',
      'birthDateLunar': false,
      'gender': 'male',
      'deviceId': deviceId,
    };

    final response = await _apiProvider.post('/users', data: payload);
    if ((response.statusCode == 201 || response.statusCode == 200) &&
        response.data != null &&
        response.data['success'] == true) {
      final responseObject = response.data['responseObject'];
      if (responseObject is Map<String, dynamic>) {
        final String? id = responseObject['id'];
        if (id != null && id.isNotEmpty) {
          await _storeUserId(id);
          return id;
        }
      }
    }

    final errorMessage =
        response.data?['message'] ??
        'Unknown error while creating chat participant';
    LoggerUtils.error('ChatService: Failed to create chat user: $errorMessage');
    throw Exception('Failed to create chat user: $errorMessage');
  }

  // Get available AI models
  Future<List<Map<String, dynamic>>> getAvailableModels() async {
    try {
      final response = await _apiProvider.get('/api/models');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['responseObject'] != null) {
          final responseList = data['responseObject'] as List;
          return responseList
              .map((item) => item as Map<String, dynamic>)
              .toList();
        }
      }

      return [];
    } catch (e) {
      LoggerUtils.error('[ChatService] Failed to get available models', e);
      // Default models if API fails
      return [
        {'id': 'openai', 'name': 'gpt-3.5-turbo', 'maxContextLength': 4096},
        {'id': 'gemini', 'name': 'gemini-2.0-flash', 'maxContextLength': 30000},
      ];
    }
  }

  // Send a message to the AI
  Future<Conversation> sendMessage({
    required String userId,
    required String message,
    required String model,
    String? conversationId,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'message': message,
        'model': model,
        'userId': userId,
      };

      if (conversationId != null) {
        data['conversationId'] = conversationId;
      }

      final response = await _apiProvider.post('/api/chat', data: data);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true &&
            responseData['responseObject'] != null) {
          final conversation = Conversation.fromJson(
            responseData['responseObject'],
          );

          // Save to local database
          await saveConversation(userId, conversation);

          return conversation;
        } else {
          final errorMessage = responseData['message'] ?? 'API error';
          LoggerUtils.error('API returned error: $errorMessage');
          throw Exception('API Error: $errorMessage');
        }
      } else {
        LoggerUtils.error('HTTP Error: ${response.statusCode}');
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      LoggerUtils.error('[ChatService] Failed to send message', e);

      // Re-throw the error to be handled by the UI layer
      rethrow;
    }
  }

  // Helper to create a local conversation with error message
  Future<Conversation> _createLocalErrorConversation(
    String userId,
    String message,
    String model,
    String? conversationId,
  ) async {
    final now = DateTime.now();
    final String newConvId = conversationId ?? _uuid.v4();

    // Get the existing conversation if it exists
    Conversation? existingConversation;
    if (conversationId != null) {
      existingConversation = getConversation(userId, conversationId);
    }

    final List<ChatMessage> messages =
        existingConversation?.messages.toList() ?? [];

    // Add user message if it doesn't already exist
    if (!messages.any(
      (msg) => msg.content == message && msg.role == MessageRole.user,
    )) {
      messages.add(
        ChatMessage(
          id: _uuid.v4(),
          content: message,
          role: MessageRole.user,
          timestamp: now,
        ),
      );
    }

    // Add assistant error message
    messages.add(
      ChatMessage(
        id: _uuid.v4(),
        content: 'Đã xảy ra lỗi kết nối. Vui lòng kiểm tra mạng và thử lại.',
        role: MessageRole.assistant,
        timestamp: now.add(const Duration(seconds: 1)),
      ),
    );

    final conversation = Conversation(
      id: newConvId,
      title: _generateTitle(message),
      messages: messages,
      model: model,
      userId: userId,
      createdAt: existingConversation?.createdAt ?? now,
      updatedAt: now,
    );

    // Save the conversation to local database
    await saveConversation(userId, conversation);

    return conversation;
  }

  // Generate a title for a new conversation
  String _generateTitle(String message) {
    // Use the first 5 words of the message or fewer if the message is shorter
    final words = message.split(' ');
    if (words.length <= 5) {
      return message;
    }
    return '${words.take(5).join(' ')}...';
  }
}
