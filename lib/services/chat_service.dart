import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../features/chat/models/suggested_question.dart';

class ChatService extends GetxService {
  static ChatService get to => Get.find();

  final Dio _dio = Dio();

  // Observables
  final RxList<SuggestedQuestion> suggestedQuestions = <SuggestedQuestion>[].obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    _loadSuggestedQuestions();
    _setupDio();
  }

  void _setupDio() {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add interceptors for logging (optional)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => print(object),
    ));
  }

  void _loadSuggestedQuestions() {
    suggestedQuestions.value = SuggestedQuestion.getDefaultQuestions();
  }

  Future<String?> sendSimpleMessage({
    required String message,
    Map<String, dynamic>? context,
  }) async {
    try {
      // Prepare context-aware message
      String contextualMessage = message;
      if (context != null) {
        contextualMessage = _addContextToMessage(message, context);
      }

      // Send to AI and return response directly
      return await _callAI(contextualMessage, 'simple_chat');
    } catch (e) {
      print('Error sending simple message: $e');
      return null;
    }
  }

  String _addContextToMessage(String message, Map<String, dynamic> context) {
    String contextualMessage = message;

    // Add measurement context if available
    if (context.containsKey('measurement')) {
      final measurement = context['measurement'];
      final meaningData = context['meaningData'];

      contextualMessage += """

--- Thông tin đo đạc hiện tại ---
Kích thước: ${measurement}mm
Kết quả thước Lô Ban: ${meaningData?.toString() ?? 'Không có thông tin'}
--- Hết thông tin ---

Hãy giải thích chi tiết về kết quả này và đưa ra lời khuyên phong thủy phù hợp.""";
    }

    // Add current date context
    final now = DateTime.now();
    contextualMessage += """

--- Thông tin thời gian ---
Thời gian hiện tại: ${now.day}/${now.month}/${now.year}
--- Hết thông tin ---""";

    return contextualMessage;
  }

  Future<String?> _callAI(String message, String conversationId) async {
    try {
      // TODO: Replace with actual AI endpoint
      // For now, return a mock response
      await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

      return _getMockResponse(message);

      /* When you have actual AI endpoint, use this:
      final response = await _dio.post(
        'YOUR_AI_ENDPOINT',
        data: {
          'message': message,
          'model': 'thien_thuoc_ai',
          'conversationId': conversationId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['response'] ?? data['content'];
      }
      */
    } catch (e) {
      print('Error calling AI: $e');
      return 'Xin lỗi, Thiên Thước gặp sự cố khi xử lý yêu cầu của bạn. Vui lòng thử lại sau.';
    }
  }

  String _getMockResponse(String message) {
    // Mock responses for different types of questions
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('thước lô ban') || lowerMessage.contains('thước lỗ ban')) {
      return '''**Thước Lô Ban** (thước Lỗ Ban) là một công cụ đo lường truyền thống trong phong thủy Trung Quốc, được sử dụng để xác định các kích thước hợp phong thủy cho kiến trúc và nội thất.

**Các loại thước:**
• **Thông thủy (52.2cm)**: Dùng cho cửa chính, cửa sổ
• **Dương trạch (42.9cm)**: Dùng cho nhà ở, không gian sống
• **Âm trạch (38.8cm)**: Dùng cho mộ phần, không gian tâm linh

**8 vạch chính:**
• **Tài** (길): Tài lộc, thịnh vượng
• **Bệnh** (病): Bệnh tật, không tốt
• **Ly** (離): Xa lìa, chia cắt
• **Nghĩa** (義): Đạo nghĩa, công lý
• **Quan** (官): Quan lộc, thăng tiến
• **Kiếp** (劫): Tai họa, mất mát
• **Hại** (害): Tổn hại, nguy hiểm
• **Cát** (吉): May mắn, thuận lợi

Trong đó **Tài, Nghĩa, Quan, Cát** là các vạch tốt, còn lại là vạch xấu.''';
    }

    if (lowerMessage.contains('cửa') || lowerMessage.contains('cửa chính')) {
      return '''**Kích thước cửa chính hợp phong thủy:**

**Chiều rộng cửa:**
• 81-87cm: Vạch Tài - Tài lộc thịnh vượng
• 108-114cm: Vạch Nghĩa - Gia đình hòa thuận
• 135-141cm: Vạch Quan - Thăng tiến trong sự nghiệp
• 162-168cm: Vạch Cát - May mắn, bình an

**Chiều cao cửa:**
• 195-201cm: Kích thước lý tưởng cho cửa chính
• 208-214cm: Phù hợp cho nhà có trần cao

**Lưu ý:**
- Cửa chính không nên quá nhỏ (dưới 70cm) hoặc quá lớn (trên 180cm)
- Tỷ lệ chiều rộng:chiều cao nên là 1:2.3 đến 1:2.5
- Cửa nên mở vào trong để thu hút tài khí''';
    }

    if (lowerMessage.contains('giường') || lowerMessage.contains('giường ngủ')) {
      return '''**Kích thước giường ngủ theo thước Lô Ban:**

**Giường đôi (1.8m):**
• Chiều rộng: 180cm (vạch Cát)
• Chiều dài: 200cm hoặc 210cm (vạch Tài)

**Giường đơn:**
• 120cm x 200cm (phù hợp cho trẻ em)
• 150cm x 200cm (giường đơn lớn)

**Chiều cao giường:**
• 45-50cm từ sàn đến mặt nệm
• Không quá thấp (dưới 40cm) hoặc quá cao (trên 60cm)

**Nguyên tắc:**
- Giường phải có đầu giường dựa vào tường vững chắc
- Không đặt giường trực diện cửa ra vào
- Kích thước phải thuộc các vạch tốt: Tài, Nghĩa, Quan, Cát''';
    }

    // Default response
    return '''Thiên Thước rất vui được hỗ trợ bạn!

Tôi có thể giúp bạn:
• Giải thích về thước Lô Ban và cách sử dụng
• Tư vấn kích thước hợp phong thủy cho cửa, giường, bàn, tủ
• Hướng dẫn đo đạc và ý nghĩa các vạch thước
• Lời khuyên phong thủy cho kiến trúc và nội thất

Bạn có thể hỏi cụ thể về kích thước nào đó hoặc cần tư vấn về một vật dụng particular nào không?''';
  }


  List<SuggestedQuestion> getSuggestedQuestionsByCategory(QuestionCategory category) {
    return suggestedQuestions
        .where((question) => question.category == category)
        .toList();
  }

}