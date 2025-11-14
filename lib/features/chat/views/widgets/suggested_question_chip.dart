import 'package:flutter/material.dart';
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
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          height: double.infinity, // Fill the container height
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF030D4C),
                Color(0xFF0A1B5C),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF00E8E8).withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E8E8).withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getCategoryIcon(question.category),
                    size: 18,
                    color: const Color(0xFF00E8E8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.question,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3, // Allow more lines for better readability
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
      case QuestionCategory.tongQuat:
        return Icons.help_outline;
    }
  }
}