import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ThinkingAnimation extends StatefulWidget {
  final String text;
  final Color color;

  const ThinkingAnimation({
    super.key,
    this.text = 'Thiên Thước đang suy nghĩ...',
    this.color = Colors.black,
  });

  @override
  State<ThinkingAnimation> createState() => _ThinkingAnimationState();
}

class _ThinkingAnimationState extends State<ThinkingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<AnimationController> _dotControllers;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Create 3 dot animations with different delays
    _dotControllers = List.generate(3, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );
    });

    _dotAnimations =
        _dotControllers.map((controller) {
          return Tween<double>(begin: 0.4, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          );
        }).toList();

    // Start animations with delays
    for (int i = 0; i < _dotControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _dotControllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var controller in _dotControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.text,
            style: TextStyle(
              color: widget.color,
              fontSize: 13.sp, // Tăng từ 14 lên 18.sp cho dễ đọc hơn
              fontStyle: FontStyle.italic,
            ),
          ),

          SizedBox(width: 10.w),

          _buildDots(),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _dotAnimations[index],
          builder: (context, child) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Opacity(
                opacity: _dotAnimations[index].value,
                child: Container(
                  width: 8.w, // Tăng từ 6 lên 8.w để phù hợp với text lớn hơn
                  height: 8.h, // Tăng từ 6 lên 8.h để phù hợp với text lớn hơn
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
