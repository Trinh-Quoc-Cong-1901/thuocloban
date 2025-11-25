import 'package:equatable/equatable.dart';

enum QuestionCategory {
  thuocLoBan,   // Thước Lô Ban
  phongThuy,    // Phong thủy
  doLuong,      // Đo lường
  kienTruc,     // Kiến trúc
  noiThat,      // Nội thất
  congCu,       // Công cụ
  tongQuat,     // Tổng quát
}

class SuggestedQuestion extends Equatable {
  final String id;
  final String question;
  final QuestionCategory category;

  const SuggestedQuestion({
    required this.id,
    required this.question,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'category': category.name,
    };
  }

  static SuggestedQuestion fromJson(Map<String, dynamic> json) {
    return SuggestedQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      category: QuestionCategory.values.firstWhere(
        (cat) => cat.name == json['category'],
        orElse: () => QuestionCategory.tongQuat,
      ),
    );
  }

  // Suggested questions cho Thước Lô Ban
  static List<SuggestedQuestion> getDefaultQuestions() {
    return [
      // Thước Lô Ban
      const SuggestedQuestion(
        id: 'q1',
        question: 'Thước Lỗ Ban là gì và có tác dụng như thế nào?',
        category: QuestionCategory.thuocLoBan,
      ),
      const SuggestedQuestion(
        id: 'q2',
        question: 'Phân biệt các loại thước: Thông thủy, Dương trạch, Âm trạch?',
        category: QuestionCategory.thuocLoBan,
      ),
      const SuggestedQuestion(
        id: 'q3',
        question: 'Ý nghĩa của các vạch Tài, Bệnh, Ly, Nghĩa, Quan, Kiếp, Hại, Cát?',
        category: QuestionCategory.thuocLoBan,
      ),

      // Phong thủy
      const SuggestedQuestion(
        id: 'q4',
        question: 'Kích thước cửa chính hợp phong thủy là bao nhiêu?',
        category: QuestionCategory.phongThuy,
      ),
      const SuggestedQuestion(
        id: 'q5',
        question: 'Chiều cao bàn thờ tổ tiên nên làm như thế nào cho tốt?',
        category: QuestionCategory.phongThuy,
      ),

      // Đo lường
      const SuggestedQuestion(
        id: 'q6',
        question: 'Cách đo giường ngủ theo thước Lỗ Ban?',
        category: QuestionCategory.doLuong,
      ),
      const SuggestedQuestion(
        id: 'q7',
        question: 'Quy tắc đo đạc cho tủ quần áo và tủ bếp?',
        category: QuestionCategory.doLuong,
      ),

      // Kiến trúc
      const SuggestedQuestion(
        id: 'q8',
        question: 'Thiết kế nhà theo thước Lỗ Ban có những lưu ý gì?',
        category: QuestionCategory.kienTruc,
      ),

      // Nội thất
      const SuggestedQuestion(
        id: 'q9',
        question: 'Kích thước bàn làm việc hợp phong thủy?',
        category: QuestionCategory.noiThat,
      ),

      // Tổng quát
      const SuggestedQuestion(
        id: 'q10',
        question: 'Cách sử dụng app Thước Lỗ Ban hiệu quả nhất?',
        category: QuestionCategory.tongQuat,
      ),
    ];
  }

  @override
  List<Object?> get props => [id, question, category];
}
