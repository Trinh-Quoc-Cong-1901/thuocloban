import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../../../config/assets_path.dart';
import '../controllers/thuoc_lo_ban_controller.dart';
import '../models/ruler_model.dart';
// Removed haptic helper import - haptic feedback disabled

class ThuocLoBanScreen extends StatefulWidget {
  const ThuocLoBanScreen({super.key});

  @override
  State<ThuocLoBanScreen> createState() => _ThuocLoBanScreenState();
}

class _ThuocLoBanScreenState extends State<ThuocLoBanScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDragging = false;
  double _lastKhoangPosition = -1; // Track khoang boundary crossings
  DateTime? _lastBoundaryHaptic; // Throttle boundary haptics
  double get _labelWidth => 100.w; // Keep title column width consistent
  
  // Cache expensive calculations
  double _cachedScreenWidth = 0;
  double _cachedRulerAreaWidth = 0;
  double _cachedPixelsPerMm = 0;
  
  @override
  void initState() {
    super.initState();
    _setLandscapeOrientation();
    // Pre-calculate after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCachedDimensions();
    });
  }
  
  void _updateCachedDimensions() {
    _cachedScreenWidth = MediaQuery.of(context).size.width;
    _cachedRulerAreaWidth = _cachedScreenWidth - _labelWidth;
    _cachedPixelsPerMm = _cachedRulerAreaWidth / 100;
  }
  
  Future<void> _setLandscapeOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _restoreOrientation();
    super.dispose();
  }
  
  Future<void> _restoreOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF030D4C),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(12.r),
              child: Row(
                children: [
                  Icon(Icons.menu, color: Colors.white, size: 12.sp),
                  SizedBox(width: 12.w),
                  Text(
                    'MENU',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white24),

            // Menu items
            ListTile(
              leading: Icon(Icons.psychology, color: Colors.white, size: 12.sp),
              title: Text('Hỏi Thiên Thước', style: TextStyle(color: Colors.white, fontSize: 8.sp)),
            onTap: () {
              Navigator.pop(context);
              _openChat();
            },
          ),

            ListTile(
              leading: Icon(Icons.help_outline, color: Colors.white, size: 12.sp),
              title: Text('Hướng dẫn', style: TextStyle(color: Colors.white, fontSize: 8.sp)),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed('/thuoc-lo-ban/guide');
              },
            ),

            ListTile(
              leading: Icon(Icons.share, color: Colors.white, size: 12.sp),
              title: Text('Chia sẻ ứng dụng', style: TextStyle(color: Colors.white, fontSize: 8.sp)),
              onTap: () {
                Navigator.pop(context);
                _shareApp();
              },
            ),

            ListTile(
              leading: Icon(Icons.star_rate, color: Colors.white, size: 12.sp),
              title: Text('Đánh giá ứng dụng', style: TextStyle(color: Colors.white, fontSize: 8.sp)),
              onTap: () {
                Navigator.pop(context);
                _rateApp();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareApp() {
    final String shareText = '''🏠 Thước Lỗ Ban - Ứng dụng phong thủy chính xác

📏 Đo đạc chính xác với 3 loại thước:
• Thông thủy (52.2 cm)
• Dương trạch (42.9 cm)
• Âm trạch (38.8 cm)

✨ Tính năng nổi bật:
• Giao diện trực quan, dễ sử dụng
• Hỗ trợ đơn vị mm và inch
• Kết quả chi tiết theo từng thước cung và khoảng

📱 Tải ngay để có những quyết định phong thủy tốt nhất!

#ThuocLoBan #FengShui #PhongThuy''';

    _showShareDialog(shareText);
  }

  void _showShareDialog(String shareText) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(maxWidth: 500.w, maxHeight: 320.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF030D4C), // Main navy
                  Color(0xFF0A1B5C), // Lighter navy
                ],
              ),
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10.h),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient accent
                Container(
                  height: 60.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFCD45), Color(0xFFFF8C45)],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.r),
                      topRight: Radius.circular(24.r),
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.share_outlined,
                          color: const Color(0xFF030D4C),
                          size: 12.sp,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Chia sẻ ứng dụng',
                          style: TextStyle(
                            color: const Color(0xFF030D4C),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Giúp bạn bè khám phá ứng dụng',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Chia sẻ Thước Lỗ Ban để cùng nhau\nra quyết định phong thủy tốt nhất',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 8.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24.h),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: _buildShareButton(
                                icon: Icons.share,
                                label: 'Chia sẻ',
                                color: const Color(0xFF00E8E8),
                                onTap: () {
                                  Navigator.pop(context);
                                  Share.share(shareText);
                                },
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _buildShareButton(
                                icon: Icons.copy,
                                label: 'Sao chép',
                                color: const Color(0xFFFFCD45),
                                onTap: () {
                                  Navigator.pop(context);
                                  Clipboard.setData(ClipboardData(text: shareText));
                                  Get.snackbar(
                                    'Đã sao chép',
                                    'Nội dung đã được sao chép vào clipboard',
                                    backgroundColor: const Color(0xFF00E8E8),
                                    colorText: const Color(0xFF030D4C),
                                    snackPosition: SnackPosition.BOTTOM,
                                    margin: EdgeInsets.all(8.r),
                                    duration: const Duration(seconds: 2),
                                    borderRadius: 12.r,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShareButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          height: 50.h,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1.w,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 10.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _rateApp() {
    _showLandscapeDialog(
      title: 'Đánh giá ứng dụng',
      content: 'Bạn có hài lòng với ứng dụng Thước Lỗ Ban?\nĐánh giá 5 sao để ủng hộ nhà phát triển nhé! ⭐',
      actions: [
        TextButton.icon(
          onPressed: () {
            Navigator.pop(context);
            _launchAppStore();
          },
          icon: const Icon(Icons.star, color: Colors.orange),
          label: const Text('Đánh giá 5⭐', style: TextStyle(color: Colors.orange)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Để sau', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }

  void _showLandscapeDialog({
    required String title,
    required String content,
    required List<Widget> actions,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Container(
          constraints: BoxConstraints(maxWidth: 400.w, maxHeight: 200.h),
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF030D4C),
                ),
              ),
              SizedBox(height: 8.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: TextStyle(
                      fontSize: 6.sp,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions.map((action) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: action,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchAppStore() async {
    String url;
    if (Platform.isIOS) {
      url = 'https://apps.apple.com/app/idYOUR_APP_ID'; // Replace with actual App Store ID
    } else {
      url = 'https://play.google.com/store/apps/details?id=YOUR_PACKAGE_NAME'; // Replace with actual package name
    }

    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Lỗi',
          'Không thể mở cửa hàng ứng dụng',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(8),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể mở liên kết: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(8),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF030D4C), // Figma design color
      resizeToAvoidBottomInset: false, // Prevent content from being pushed up when keyboard appears
      drawer: _buildDrawer(),
      body: SafeArea(
        // Only apply SafeArea to top and sides, not bottom
        // This prevents UI from resizing when keyboard appears on iOS
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(),
            _buildRulerSection(),
            _buildBottomInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. Drawer button
          IconButton(
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            icon: const Icon(Icons.menu, color: Colors.white),
          ),

          // 2. Title
          Text(
            'THƯỚC LỖ BAN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 6.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(width: 2.w),

          // 3. Input field with unit label
          GetBuilder<ThuocLoBanController>(
            id: 'input-field',
            builder: (controller) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: 40.w,
                      maxWidth: 130.w,
                    ),
                    child: IntrinsicWidth(
                      child: TextFormField(
                        controller: controller.inputController,
                        textAlign: TextAlign.center,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(fontSize: 6.sp, fontWeight: FontWeight.bold),
                        inputFormatters: [
                          // Allow both dot and comma for decimal input
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d*')),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            if (newValue.text.isEmpty) return newValue;

                            // Replace comma with dot for parsing (iOS users may have comma on keyboard)
                            final normalizedText = newValue.text.replaceAll(',', '.');

                            // Validate it's a proper number
                            final value = double.tryParse(normalizedText);
                            if (value == null) return oldValue;

                            // Limit based on unit
                            final maxValue = controller.selectedUnit == Unit.mm ? 1000000.0 : 39370.0;
                            if (value > maxValue) {
                              return oldValue; // Block input if exceeds limit
                            }

                            // Return normalized text with dot instead of comma
                            return TextEditingValue(
                              text: normalizedText,
                              selection: newValue.selection,
                            );
                          }),
                        ],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: '0',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 6.sp, fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.only(top: 4,bottom: 4,left: 4),
                          isDense: true,
                        ),
                        onFieldSubmitted: (_) => controller.onInputSubmitted(),
                        onTapOutside: (_) => controller.onInputUnfocused(),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  GetBuilder<ThuocLoBanController>(
                    id: 'unit-selector',
                    builder: (controller) {
                      return Text(controller.unitLabel, style: TextStyle(color: Colors.white, fontSize: 6.sp));
                    },
                  ),
                ],
              );
            },
          ),

          // 4. mm radio button
          GetBuilder<ThuocLoBanController>(
            id: 'unit-selector',
            builder: (controller) {
              return _buildUnitRadio('mm', controller.selectedUnit == Unit.mm, controller);
            },
          ),

          // 5. inch radio button
          GetBuilder<ThuocLoBanController>(
            id: 'unit-selector',
            builder: (controller) {
              return _buildUnitRadio('inch', controller.selectedUnit == Unit.inch, controller);
            },
          ),

          // 6. Help button
          GestureDetector(
            onTap: () => Get.toNamed('/thuoc-lo-ban/guide'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  IconsPath.guideIcon,
                  width: 12.w,
                  height: 12.h,
                  color: Colors.white,
                ),
                Text('Hướng dẫn', style: TextStyle(color: Colors.white, fontSize: 6.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitRadio(String unit, bool isSelected, ThuocLoBanController controller) {
    return GestureDetector(
      onTap: () {
        final newUnit = unit == 'mm' ? Unit.mm : Unit.inch;
        if (controller.selectedUnit != newUnit) {
          // Removed haptic feedback
          controller.updateUnit(newUnit);
        }
      },
      // Add transparent padding to increase hit area
      behavior: HitTestBehavior.opaque,
      child: Container(
        // Minimum 44x44 hit area for better UX
        padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 8.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,  // Reduced from 14 to 10 for landscape
              height: 12.h, // Reduced from 14 to 10 for landscape
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 0.5.w),
                color: Colors.transparent, // Always transparent background
              ),
              child: isSelected 
                  ? Center(
                      child: Container(
                        width: 6.w,  // Reduced from 10 to 6 for landscape
                        height: 6.h, // Reduced from 10 to 6 for landscape
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white, // White dot on transparent background
                        ),
                      ),
                    )
                  : null,
            ),
            Text(unit, style: TextStyle(color: Colors.white, fontSize: 6.sp)), // Slightly larger
          ],
        ),
      ),
    );
  }

  Widget _buildRulerSection() {
    return Expanded(
      child: GetBuilder<ThuocLoBanController>(
        id: 'ruler-canvas',
        builder: (controller) {
          return GestureDetector(
            onPanStart: (details) {
              _isDragging = true;
              controller.startDrag();
              _lastKhoangPosition = -1; // Reset khoang tracking
              _lastBoundaryHaptic = null; // Reset boundary haptic throttle
              // Removed haptic feedback for drag start
            },
            onPanUpdate: (details) {
              if (!_isDragging) return;
              
              // Remove throttling for max responsiveness
              // Use cached dimensions for performance
              final deltaX = details.delta.dx;
              final deltaMm = -deltaX / _cachedPixelsPerMm;
              
              final newMm = math.max(0.0, controller.currentInput + deltaMm);
              
              // Check for khoang boundary crossing for haptic feedback
              _checkKhoangBoundaryCrossing(controller, newMm);
              
              controller.updateInput(newMm, updateTextField: false, smooth: false);
            },
            onPanEnd: (details) {
              _isDragging = false;
              controller.endDrag();
              // Removed haptic feedback for drag end
              
              final velocity = details.velocity.pixelsPerSecond.dx;
              
              if (velocity.abs() > 100) {
                // Physics-based momentum calculation
                final speed = velocity.abs();
                
                // Dynamic factor based on velocity (0.3 to 1.2)
                final velocityFactor = (speed / 1000).clamp(0.0, 1.0);
                final factor = 0.3 + (velocityFactor * 0.9); // Range: 0.3 - 1.2
                
                // Calculate momentum distance
                final momentumMm = -velocity / _cachedPixelsPerMm * factor;
                final finalMm = math.max(0.0, controller.currentInput + momentumMm);
                
                // Dynamic duration based on distance (400ms to 1600ms)
                final distance = momentumMm.abs();
                final duration = (400 + distance * 0.8).clamp(400, 1600).toInt();
                
                // Update momentum controller duration
                controller.setMomentumDuration(duration);
                controller.startMomentumScroll(finalMm);
              } else {
                controller.inputController.text = controller.displayValueString;
              }
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Column(
                      children: [
                        // Ruler scale
                        _buildRulerScale(controller),
                        
                        // Ruler strips
                        Expanded(
                          child: Column(
                            children: [
                              _buildRulerStrip(
                                title: 'Thông thủy',
                                size: '(52.2 cm)',
                                color: const Color(0xFFFFFFFF), // #FFFFFF - White
                                rulerType: RulerType.thongThuy,
                                controller: controller,
                                hasBottomMargin: true, // Add margin for spacing
                              ),
                              _buildRulerStrip(
                                title: 'Dương trạch',
                                size: '(42.9 cm)',
                                color: const Color(0xFF00E8E8), // #00E8E8 - Cyan
                                rulerType: RulerType.duongTrach,
                                controller: controller,
                                hasBottomMargin: true, // Add margin for spacing
                              ),
                              _buildRulerStrip(
                                title: 'Âm trạch',
                                size: '(38.8 cm)',
                                color: const Color(0xFFD4D3D3), // #D4D3D3 - Light Grey
                                rulerType: RulerType.amTrach,
                                controller: controller,
                                hasBottomMargin: false, // No margin for last strip
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    // Center line - FIXED: Use LayoutBuilder constraints for precise alignment
                    _buildCenterLine(constraints),
                    
                    // Remove performance overlay to reduce overhead
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRulerScale(ThuocLoBanController controller) {
    return Container(
      height: 45.h,
      decoration: const BoxDecoration(
        color: Color(0xFF030D4C), // Main background color
        border: Border(
          top: BorderSide(color: Colors.white, width: 1), // White border top
          bottom: BorderSide(color: Colors.white, width: 1), // White border bottom
        ),
      ),
      child: Stack(
        children: [
          // Ruler marks - Wrapped in ClipRect to prevent overflow
          ClipRect(
            child: RepaintBoundary(
              key: const ValueKey('ruler-scale'),
              child: CustomPaint(
                size: Size(double.infinity, 40.h),
                painter: RulerScalePainter(
                  currentMm: controller.currentInput,
                  selectedUnit: controller.selectedUnit,
                  fontSize: 4.sp,
                  labelWidth: _labelWidth,
                ),
              ),
            ),
          ),
          
          // Fixed overlay
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: _labelWidth,
            child: Container(
              color: const Color(0xFF030D4C),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: controller.selectedUnit == Unit.mm ? 30.w : 40.w,
                  height: 20.h,
                  color: Colors.transparent,
                  child: Center(
                    child: Text(
                      controller.selectedUnit == Unit.mm ? 'cm' : 'inch',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 6.sp,  // Reduced from 12 to 8 for landscape
                        fontWeight: FontWeight.bold  // Bold as requested
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulerStrip({
    required String title,
    required String size,
    required Color color,
    required RulerType rulerType,
    required ThuocLoBanController controller,
    bool hasBottomMargin = false,
  }) {
    return Expanded(
      child: Container(
        margin: hasBottomMargin ? EdgeInsets.only(bottom: 2.h) : EdgeInsets.zero, // Reduced margin for landscape
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white, width: 1), // White border top
            bottom: BorderSide(color: Colors.white, width: 1), // White border bottom
          ),
        ),
        child: Row(
          children: [
            // Title section
            Container(
              width: 100.w,
              color: color,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 6.sp, // Reduced from 8 to 6 for landscape
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      size,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 5.sp, // Reduced from 7 to 5 for landscape
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Ruler content
            Expanded(
              child: RepaintBoundary(
                key: ValueKey('ruler-strip-$rulerType'),
                child: ClipRect(
                  child: Container(
                    color: const Color(0xFF030D4C),
                    child: CustomPaint(
                      size: const Size(double.infinity, double.infinity),
                      painter: RulerStripPainter(
                        ruler: controller.rulers[rulerType]!,
                        currentMm: controller.currentInput,
                        khoangFontSize: 6.sp,
                        cungFontSize: 5.sp,
                        labelWidth: _labelWidth,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterLine(BoxConstraints constraints) {
    return GetBuilder<ThuocLoBanController>(
      builder: (controller) {
        // FIXED: Match EXACTLY with RulerScalePainter's fixedPosition calculation
        // RulerScalePainter uses: fixedPosition = size.width / 2
        // Where size.width is the paint area width (constraints.maxWidth)
        final centerPosition = constraints.maxWidth / 2;
        
        return Positioned(
          left: centerPosition - 1,
          top: 0,
          bottom: 0,
          child: Container(
            width: 2,
            color: const Color(0xFFFFCD45), // #FFCD45 - yellow/gold
            child: Column(
              children: [
                Container(
                  width: 0,
                  height: 0,
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(width: 6, color: Colors.transparent),
                      right: BorderSide(width: 6, color: Colors.transparent),
                      bottom: BorderSide(width: 8, color: Color(0xFFFF1616)), // #FF1616 - red
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomInfo() {
    return GetBuilder<ThuocLoBanController>(
      id: 'bottom-info', // Add specific ID for bottom info updates
      builder: (controller) {
        return Container(
          height: 80.h, // Increased back to 65 to show all 3 lines
          padding: EdgeInsets.only(left: 60.w, right: 8.w, top: 4.h, bottom: 4.h), // Reduced padding
          color: const Color(0xFF030D4C), // Match scale background
          child: Row(
            children: [
              // Results column
              Expanded(
                child: Column(
                  children: controller.results.map((result) {
                    final color = _getRulerColor(result.ruler.type);
                    return Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 6.w, // Reduced from 10 to 6 for landscape
                            height: 6.h, // Reduced from 10 to 6 for landscape
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                            ),
                          ),
                          SizedBox(width: 4.w), // Reduced from 6 to 4 for landscape
                          Expanded(
                            child: Text(
                              '${_getRulerName(result.ruler.type)}: Thước cung ${result.cung.name} - nằm trong khoảng ${result.khoang.name} - ${result.typeText}',
                              style: TextStyle(
                                color: result.khoang.isGood ? const Color(0xFFFF6560) : Colors.white, // #FF6560 for good, white for bad
                                fontSize: 6.sp, // Increased from 6 to 8 for better readability
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              

            ],
          ),
        );
      },
    );
  }

  Color _getRulerColor(RulerType type) {
    switch (type) {
      case RulerType.duongTrach:
        return const Color(0xFF00E8E8); // #00E8E8 - Cyan
      case RulerType.amTrach:
        return const Color(0xFFD4D3D3); // #D4D3D3 - Light Grey
      case RulerType.thongThuy:
        return const Color(0xFFFFFFFF); // #FFFFFF - White
    }
  }

  String _getRulerName(RulerType type) {
    switch (type) {
      case RulerType.duongTrach:
        return 'Dương trạch';
      case RulerType.amTrach:
        return 'Âm trạch';
      case RulerType.thongThuy:
        return 'Thông thủy';
    }
  }

  // Check for khoang boundary crossing and trigger haptic feedback
  void _checkKhoangBoundaryCrossing(ThuocLoBanController controller, double newMm) {
    if (!_isDragging) return;
    
    // Get ruler to calculate khoang boundaries
    final ruler = controller.rulers[RulerType.thongThuy]!; // Use primary ruler for feedback
    final cycleLengthMm = ruler.totalLengthMm;
    final khoangWidth = cycleLengthMm / ruler.khoang.length;
    
    // Calculate current khoang position
    final currentKhoangPosition = (newMm % cycleLengthMm) / khoangWidth;
    final currentKhoangIndex = currentKhoangPosition.floor();
    
    // Check if we crossed a khoang boundary
    if (_lastKhoangPosition >= 0) {
      final lastKhoangIndex = _lastKhoangPosition.floor();
      if (currentKhoangIndex != lastKhoangIndex) {
        // Removed haptic feedback for boundary crossing
        final now = DateTime.now();
        if (_lastBoundaryHaptic == null || 
            now.difference(_lastBoundaryHaptic!).inMilliseconds > 100) {
          // Haptic feedback removed
          _lastBoundaryHaptic = now;
        }
      }
    }
    
    _lastKhoangPosition = currentKhoangPosition;
  }
}

class RulerScalePainter extends CustomPainter {
  final double currentMm;
  final Unit selectedUnit;
  final double fontSize;
  final double labelWidth;

  RulerScalePainter({
    required this.currentMm,
    required this.selectedUnit,
    this.fontSize = 10.0,
    required this.labelWidth,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;

    final rulerAreaWidth = size.width - labelWidth;
    final pixelsPerMm = rulerAreaWidth / 100;
    final screenCenter = size.width / 2;
    final fixedPosition = screenCenter;
    
    final visibleRangeMm = rulerAreaWidth / pixelsPerMm;
    final halfRange = visibleRangeMm / 2;
    final startMm = currentMm - halfRange;
    final endMm = currentMm + halfRange;
    
    if (selectedUnit == Unit.mm) {
      // Draw cm scale marks - OPTIMIZED: reduced loop range
      for (double mm = (startMm / 10).floor() * 10.0; mm <= endMm + 10; mm += 10) {
        if (mm < 0) continue;
        
        final cmValue = mm / 10;
        final xPosition = fixedPosition + (mm - currentMm) * pixelsPerMm;
        
        if (xPosition < -20 || xPosition > size.width + 20) continue;
        
        canvas.drawLine(Offset(xPosition, 0), Offset(xPosition, 20), paint);
        
        final textPainter = TextPainter(
          text: TextSpan(
            text: cmValue.toStringAsFixed(cmValue % 1 == 0 ? 0 : 1),
            style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.bold),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(xPosition - textPainter.width / 2, size.height - 15));
        
        // OPTIMIZED: Skip sub-marks if too small
        if (pixelsPerMm > 2) {
          for (int subMm = 1; subMm < 10; subMm++) {
            final mmPosition = xPosition + (subMm * pixelsPerMm);
            if (mmPosition >= -10 && mmPosition <= size.width + 10) {
              canvas.drawLine(
                Offset(mmPosition, 0),
                Offset(mmPosition, subMm == 5 ? 15 : 10),
                paint..strokeWidth = subMm == 5 ? 1 : 0.5,
              );
            }
          }
        }
      }
    } else {
      // Inch scale - OPTIMIZED
      const double mmPerInch = 25.4;
      final startInch = startMm / mmPerInch;
      final endInch = endMm / mmPerInch;
      
      for (double inch = (startInch * 4).floor() / 4.0; inch <= endInch + 0.25; inch += 0.25) {
        if (inch < 0) continue;
        
        final mmValue = inch * mmPerInch;
        final xPosition = fixedPosition + (mmValue - currentMm) * pixelsPerMm;
        
        if (xPosition < -20 || xPosition > size.width + 20) continue;
        
        final fraction = (inch * 4) % 4;
        final isWhole = fraction == 0;
        final isHalf = fraction == 2;
        
        final markHeight = isWhole ? 20.0 : (isHalf ? 15.0 : 10.0);
        final strokeWidth = isWhole ? 1.5 : (isHalf ? 1.0 : 0.5);
        
        canvas.drawLine(Offset(xPosition, 0), Offset(xPosition, markHeight), paint..strokeWidth = strokeWidth);
        
        if (isWhole) {
          final textPainter = TextPainter(
            text: TextSpan(text: inch.toInt().toString(), style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.bold)),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(canvas, Offset(xPosition - textPainter.width / 2, size.height - 15));
        }
      }
    }
  }

  @override
  bool shouldRepaint(RulerScalePainter oldDelegate) {
    const threshold = 0.1;
    return (oldDelegate.currentMm - currentMm).abs() > threshold || 
           oldDelegate.selectedUnit != selectedUnit ||
           oldDelegate.labelWidth != labelWidth;
  }
}

class RulerStripPainter extends CustomPainter {
  final RulerModel ruler;
  final double currentMm;
  final double khoangFontSize;
  final double cungFontSize;
  final double labelWidth;

  RulerStripPainter({
    required this.ruler,
    required this.currentMm,
    this.khoangFontSize = 12.0,
    this.cungFontSize = 10.0,
    required this.labelWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pixelsPerMm = size.width / 100;
    final cycleLengthMm = ruler.totalLengthMm;
    final screenWidth = size.width + labelWidth;
    final screenCenter = screenWidth / 2;
    final fixedOffsetPx = screenCenter - labelWidth;
    final visibleRangeMm = size.width / pixelsPerMm;
    final halfRange = visibleRangeMm / 2;
    final startMm = math.max(0.0, currentMm - halfRange); // Start from 0, not before 0
    final endMm = currentMm + halfRange; // FIXED: Symmetric range around center
    
    // Calculate cycle range - ensure cycle 0 is included when currentMm is near 0
    final startCycle = math.min(0, (startMm / cycleLengthMm).floor());
    final endCycle = (endMm / cycleLengthMm).ceil() + 1;
    
    for (int cycle = startCycle; cycle <= endCycle; cycle++) {
      final cycleStartMm = cycle * cycleLengthMm;
      // Always draw cycle 0, skip only truly negative cycles
      if (cycle < 0 && cycleStartMm + cycleLengthMm <= 0) continue;
      
      final cycleStartX = fixedOffsetPx + (cycleStartMm - currentMm) * pixelsPerMm;
      _drawCycle(canvas, size, cycleStartX, pixelsPerMm);
    }
    
    // OPTIMIZED: Draw boundaries separately for better performance
    for (int cycle = startCycle; cycle <= endCycle; cycle++) {
      final cycleStartMm = cycle * cycleLengthMm;
      // Always draw cycle 0, skip only truly negative cycles
      if (cycle < 0 && cycleStartMm + cycleLengthMm <= 0) continue;
      
      final cycleStartX = fixedOffsetPx + (cycleStartMm - currentMm) * pixelsPerMm;
      _drawMajorBoundaries(canvas, size, cycleStartX, pixelsPerMm);
    }
  }

  void _drawCycle(Canvas canvas, Size size, double startX, double pixelsPerMm) {
    final cycleLengthMm = ruler.totalLengthMm;
    final khoangWidth = cycleLengthMm / ruler.khoang.length;
    
    for (int i = 0; i < ruler.khoang.length; i++) {
      final khoang = ruler.khoang[i];
      final khoangStartX = startX + (i * khoangWidth * pixelsPerMm);
      final khoangWidthPixels = khoangWidth * pixelsPerMm;
      
      // FIXED: Only skip if completely outside screen bounds (not based on center position)
      if (khoangStartX + khoangWidthPixels < -50 || khoangStartX > size.width + 50) continue;
      
      // Draw khoang background
      final khoangPaint = Paint()..color = khoang.isGood ? const Color(0xFFFF1616) : const Color(0xFF00062B);
      
      final clampedStartX = khoangStartX.clamp(0.0, size.width);
      final clampedWidth = (khoangStartX + khoangWidthPixels).clamp(0.0, size.width) - clampedStartX;
      
      if (clampedWidth > 0) {
        canvas.drawRect(Rect.fromLTWH(clampedStartX, 0, clampedWidth, size.height), khoangPaint);
      }
      
      // Draw khoang details when reasonably visible
      if (khoangWidthPixels > 20) {
        _drawKhoangDetails(canvas, size, khoang, khoangStartX, khoangWidthPixels, khoangWidth, pixelsPerMm);
      }
    }
  }
  
  void _drawKhoangDetails(Canvas canvas, Size size, khoang, double khoangStartX, double khoangWidthPixels, double khoangWidth, double pixelsPerMm) {
    // Draw khoang name
    final khoangTextPainter = TextPainter(
      text: TextSpan(
        text: khoang.name.toUpperCase(),
        style: TextStyle(color: Colors.white, fontSize: khoangFontSize, fontWeight: FontWeight.w800),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    khoangTextPainter.layout(maxWidth: khoangWidthPixels);
    
    // Center the text properly, even if truncated - fix clamp bounds
    final maxTextX = khoangStartX + khoangWidthPixels - khoangTextPainter.width;
    final textX = maxTextX > khoangStartX 
        ? (khoangStartX + (khoangWidthPixels - khoangTextPainter.width) / 2).clamp(khoangStartX, maxTextX)
        : khoangStartX; // If text is wider than khoang, align to start
    khoangTextPainter.paint(canvas, Offset(textX, 8));
    
    // Draw separator
    final separatorY = size.height * 0.5;
    canvas.drawLine(
      Offset(khoangStartX, separatorY),
      Offset(khoangStartX + khoangWidthPixels, separatorY),
      Paint()..color = Colors.white.withValues(alpha: 0.8)..strokeWidth = 1.5,
    );
    
    // Draw cung details when khoang is reasonably wide
    if (khoangWidthPixels > 40) {
      final cungWidth = khoangWidth / khoang.cung.length;
      for (int j = 0; j < khoang.cung.length; j++) {
        final cung = khoang.cung[j];
        final cungStartX = khoangStartX + (j * cungWidth * pixelsPerMm);
        final cungWidthPixels = cungWidth * pixelsPerMm;
        
        if (cungWidthPixels > 15) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: cung.name,
              style: TextStyle(color: Colors.white, fontSize: cungFontSize, fontWeight: FontWeight.w600),
            ),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
          );
          textPainter.layout(maxWidth: cungWidthPixels);
          
          final cungAreaHeight = size.height - separatorY;
          // Ensure text stays within cung bounds - fix clamp bounds
          final maxX = cungStartX + cungWidthPixels - textPainter.width;
          final textX = maxX > cungStartX 
              ? (cungStartX + (cungWidthPixels - textPainter.width) / 2).clamp(cungStartX, maxX)
              : cungStartX; // If text is wider than cung, align to start
          final textOffset = Offset(
            textX,
            separatorY + (cungAreaHeight - textPainter.height) / 2,
          );
          textPainter.paint(canvas, textOffset);
        }
        
        // Draw cung borders
        if (j < khoang.cung.length - 1) {
          canvas.drawLine(
            Offset(cungStartX + cungWidthPixels, separatorY),
            Offset(cungStartX + cungWidthPixels, size.height),
            Paint()..color = Colors.white.withValues(alpha: 0.7)..strokeWidth = 1.0,
          );
        }
      }
    }
  }
  
  void _drawMajorBoundaries(Canvas canvas, Size size, double startX, double pixelsPerMm) {
    final cycleLengthMm = ruler.totalLengthMm;
    final khoangWidth = cycleLengthMm / ruler.khoang.length;
    
    for (int i = 0; i <= ruler.khoang.length; i++) {
      final khoangBoundaryX = startX + (i * khoangWidth * pixelsPerMm);
      if (khoangBoundaryX < -10 || khoangBoundaryX > size.width + 10) continue;
      
      canvas.drawLine(
        Offset(khoangBoundaryX, 0),
        Offset(khoangBoundaryX, size.height),
        Paint()..color = Colors.white.withValues(alpha: 0.9)..strokeWidth = 2.0,
      );
    }
  }

  @override
  bool shouldRepaint(RulerStripPainter oldDelegate) {
    const threshold = 0.1;
    return (oldDelegate.currentMm - currentMm).abs() > threshold || 
           oldDelegate.ruler != ruler ||
           oldDelegate.labelWidth != labelWidth;
  }
}
  Future<void> _openChat({Map<String, dynamic>? arguments}) async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await Get.toNamed('/chat', arguments: arguments);
  }
