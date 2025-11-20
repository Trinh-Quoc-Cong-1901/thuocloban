import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5.h), // 5h từ app bar
                    _buildTitle(),
                    SizedBox(height: 24.h), // 24h dưới title chung
                    _buildSection1(),
                    SizedBox(height: 24.h), // 24h giữa các section
                    _buildSection2(),
                    SizedBox(height: 20.h), // Bottom padding
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
      height: 60.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 10.sp),
          ),

          SizedBox(width: 8.w),

          // Title
          Text(
            'HƯỚNG DẪN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Center(
      child: Text(
        'HƯỚNG DẪN SỬ DỤNG THƯỚC LỖ BAN',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.sp,
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
        Text(
          '1. CÁC LOẠI THƯỚC LỖ BAN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 12.h), // 16h từ title đến nội dung

        // 1.1 Dương Trạch
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
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
        SizedBox(height: 12.h), // 12h giữa các mục

        // 1.2 Âm Trạch
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
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
        SizedBox(height: 12.h), // 12h giữa các mục

        // 1.3 Thông thủy
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
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
        Text(
          '2. HƯỚNG DẪN DÙNG THƯỚC',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 16.h), // 16h từ title đến nội dung

        // Bước 1
        _buildStep(
          'Bước 1:',
          'Nhập kích thước vật cần đo (có thể là chiều rộng, chiều dài hoặc chiều cao của vật)',
          [
            '• Nhập kích thước cần đo vào ô nhập, bạn có thể chọn đơn vị đo là mm hoặc inch',
            '• Hoặc có thể dùng tay để kéo sang trái hay kéo sang phải để hướng tới kích thước cần đo',
          ],
        ),
        SizedBox(height: 12.h), // 12h giữa các bước

        // Bước 2
        _buildStep(
          'Bước 2:',
          'Xác định thước cần đo',
          [
            '• Tùy theo vật bạn cần đo là gì, đối chiếu lên danh sách thước để xác định chính xác loại thước cần đo: Dương trạch, Âm trạch hay Thông thủy',
          ],
        ),
        SizedBox(height: 12.h), // 12h giữa các bước

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
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
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
        SizedBox(height: 8.h),
        ...bulletPoints.map((point) => Padding(
              padding: EdgeInsets.only(left: 16.w, bottom: 4.h),
              child: Text(
                point,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  height: 1.5,
                ),
              ),
            )),
      ],
    );
  }
}
