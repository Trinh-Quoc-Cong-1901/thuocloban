import 'package:get/get.dart';
import '../controllers/thuoc_lo_ban_controller.dart';

class ThuocLoBanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ThuocLoBanController>(
      () => ThuocLoBanController(),
    );
  }
}