import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030D4C), // Match thuoc lo ban background
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5), // 5h từ app bar
                    _buildTitle(),
                    const SizedBox(height: 24), // 24h dưới title chung
                    _buildSection1(),
                    const SizedBox(height: 24), // 24h giữa các section
                    _buildSection2(),
                    const SizedBox(height: 20), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),

          const SizedBox(width: 8),

          // Title
          const Text(
            'HƯỚNG DẪN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Center(
      child: Text(
        'HƯỚNG DẪN SỬ DỤNG THƯỚC LỖ BAN',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSection1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. CÁC LOẠI THƯỚC LỖ BAN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16), // 16h từ title đến nội dung

        // 1.1 Dương Trạch
        RichText(
          text: const TextSpan(
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
            children: [
              TextSpan(
                text: '1.1 Dương Trạch ',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: '(kích thước 42.9 cm): ',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              TextSpan(
                text:
                    'Đây là thước dùng để đo các khối xây dựng hoặc nội thất như bậc, bếp, giường tủ, bàn ghế... (đo phủ bì)',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12), // 12h giữa các mục

        // 1.2 Âm Trạch
        RichText(
          text: const TextSpan(
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
            children: [
              TextSpan(
                text: '1.2 Âm Trạch ',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: '(kích thước 38.8 cm): ',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              TextSpan(
                text:
                    'Đây là thước dùng để đo các công trình tâm linh như mồ mả, am, miếu, tiểu quách, bàn thờ...',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12), // 12h giữa các mục

        // 1.3 Thông thủy
        RichText(
          text: const TextSpan(
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
            children: [
              TextSpan(
                text: '1.3 Thông thủy ',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: '(kích thước 52.2 cm): ',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              TextSpan(
                text:
                    'Đây là thước dùng để đo các khoảng thông thủy của chính ra vào, cửa sổ, cửa thông phòng... (đo lọt lòng)',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '2. HƯỚNG DẪN DÙNG THƯỚC',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16), // 16h từ title đến nội dung

        // Bước 1
        _buildStep(
          'Bước 1:',
          'Nhập kích thước vật cần đo (có thể là chiều rộng, chiều dài hoặc chiều cao của vật)',
          [
            '• Nhập kích thước cần đo vào ô nhập, bạn có thể chọn đơn vị đo là mm hoặc inch',
            '• Hoặc có thể dùng tay để kéo sang trái hay kéo sang phải để hướng tới kích thước cần đo',
          ],
        ),
        const SizedBox(height: 12), // 12h giữa các bước

        // Bước 2
        _buildStep(
          'Bước 2:',
          'Xác định thước cần đo',
          [
            '• Tùy theo vật bạn cần đo là gì, đối chiếu lên danh sách thước để xác định chính xác loại thước cần đo: Dương trạch, Âm trạch hay Thông thủy',
          ],
        ),
        const SizedBox(height: 12), // 12h giữa các bước

        // Bước 3
        _buildStep(
          'Bước 3:',
          'Xem kết quả',
          [
            '• Kích thước bạn cần đo sẽ được hiển thị thuộc cung/ khoảng ở phía dưới thước. Bạn có thể dùng nó làm căn cứ trước khi quyết định cho công việc',
            '• Lưu ý: Màu đỏ - là khoảng/ cung tốt; Màu đen - là khoảng/ cung xấu',
          ],
        ),
      ],
    );
  }

  Widget _buildStep(
      String stepTitle, String stepDescription, List<String> bulletPoints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
            children: [
              TextSpan(
                text: stepTitle,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: ' '),
              TextSpan(text: stepDescription),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...bulletPoints.map((point) => Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: Text(
                point,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            )),
      ],
    );
  }
}
