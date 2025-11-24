import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/suggested_question.dart';

class SuggestedQuestionChip extends StatelessWidget {
  final SuggestedQuestion question;
  final VoidCallback onTap;

  const SuggestedQuestionChip({
    super.key,
    required this.question,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: _getBorderColor(),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _getBorderColor().withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                _getCategoryIcon(question.category),
                size: 20.sp,
                color: _getIconColor(),
              ),
              SizedBox(height: 8.h),
              Text(
                question.question,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _getTextColor(),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBorderColor() {
    switch (question.category) {
      case QuestionCategory.thuocLoBan:
        return const Color(0xFF030D4C);
      case QuestionCategory.phongThuy:
        return Colors.green;
      case QuestionCategory.doLuong:
        return Colors.blue;
      case QuestionCategory.kienTruc:
        return Colors.orange;
      case QuestionCategory.noiThat:
        return Colors.purple;
      case QuestionCategory.congCu:
        return Colors.teal;
      case QuestionCategory.tongQuat:
        return Colors.grey;
    }
  }

  Color _getTextColor() {
    return _getBorderColor();
  }

  Color _getIconColor() {
    return _getBorderColor();
  }

  IconData _getCategoryIcon(QuestionCategory category) {
    switch (category) {
      case QuestionCategory.thuocLoBan:
        return Icons.straighten;
      case QuestionCategory.phongThuy:
        return Icons.nature_people;
      case QuestionCategory.doLuong:
        return Icons.architecture;
      case QuestionCategory.kienTruc:
        return Icons.home;
      case QuestionCategory.noiThat:
        return Icons.weekend;
      case QuestionCategory.congCu:
        return Icons.construction;
      case QuestionCategory.tongQuat:
        return Icons.help_outline;
    }
  }
}
