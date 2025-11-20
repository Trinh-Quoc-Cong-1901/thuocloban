import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../../../services/chat_service.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    // ChatService is already initialized globally in main.dart
    // Just ensure it's accessible
    final chatService = Get.find<ChatService>();
    print(
      '✅ ChatBinding: Found ChatService with ${chatService.getSuggestedQuestions().length} suggested questions',
    );

    // Initialize ChatController
    Get.lazyPut<ChatController>(() => ChatController());
  }
}
