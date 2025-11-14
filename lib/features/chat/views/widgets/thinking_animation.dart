import 'package:flutter/material.dart';

class ThinkingAnimation extends StatefulWidget {
  final String text;
  final Color color;

  const ThinkingAnimation({
    super.key,
    this.text = 'Thiên Thước đang suy nghĩ...',
    this.color = Colors.white,
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

    _dotAnimations = _dotControllers.map((controller) {
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // AI Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFCD45),
            ),
            child: const Icon(
              Icons.psychology,
              color: Color(0xFF030D4C),
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // Thinking text and dots
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.text,
                style: TextStyle(
                  color: widget.color,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 4),

              // Animated dots
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _dotAnimations[index],
                    builder: (context, child) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Opacity(
                          opacity: _dotAnimations[index].value,
                          child: Container(
                            width: 6,
                            height: 6,
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}