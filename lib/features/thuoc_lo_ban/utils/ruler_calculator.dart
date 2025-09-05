import 'dart:math' as math;
import '../models/ruler_model.dart';
import '../models/khoang_model.dart';
import '../models/cung_model.dart';

class RulerResult {
  final RulerModel ruler;
  final KhoangModel khoang;
  final CungModel cung;
  final double inputMm;
  final double normalizedMm;
  final int khoangIndex;
  final int cungIndex;

  const RulerResult({
    required this.ruler,
    required this.khoang,
    required this.cung,
    required this.inputMm,
    required this.normalizedMm,
    required this.khoangIndex,
    required this.cungIndex,
  });

  double get inputCm => inputMm / 10;
  String get inputCmFormatted => inputCm.toStringAsFixed(1);
  
  bool get isGood => khoang.isGood;
  bool get isBad => khoang.isBad;
  
  String get typeText => khoang.typeDisplayText;
  
  String get detailText => 
      'Độ dài $inputCmFormatted cm thuộc Cung ${cung.name} '
      'nằm trong khoảng ${khoang.name} - $typeText. '
      '(${cung.description})';

  @override
  String toString() {
    return 'RulerResult(ruler: ${ruler.type}, khoang: ${khoang.name}, cung: ${cung.name}, inputMm: $inputMm)';
  }
}

class RulerCalculator {
  static const double pixelsPerMm = 8.0;
  // Remove limit - support unlimited input
  static const double maxRulerLengthCm = double.maxFinite;

  static RulerResult? calculate(RulerModel ruler, double inputMm) {
    if (inputMm < 0) return null;

    final cycleLengthMm = ruler.totalLengthMm;
    if (cycleLengthMm <= 0) return null;

    // Chuẩn hóa vị trí theo chu kỳ thước
    double normalizedMm = inputMm % cycleLengthMm;
    
    // Xử lý trường hợp đặc biệt: nếu inputMm > 0 và normalizedMm == 0, 
    // thì nó nằm ở cuối chu kỳ
    if (inputMm > 0 && normalizedMm == 0) {
      normalizedMm = cycleLengthMm;
    }

    // FIXED: Tính kích thước mỗi cung dựa trên tổng số cung thực tế
    final totalCung = ruler.khoang.fold<int>(0, (sum, khoang) => sum + khoang.cung.length);
    final cungSizeMm = cycleLengthMm / totalCung;
    
    // Tìm cung theo vị trí tuyệt đối
    double currentPosition = 0;
    int khoangIndex = 0;
    int cungIndex = 0;
    
    for (int i = 0; i < ruler.khoang.length; i++) {
      final khoang = ruler.khoang[i];
      final khoangSizeMm = khoang.cung.length * cungSizeMm;
      
      if (normalizedMm <= currentPosition + khoangSizeMm) {
        khoangIndex = i;
        final positionInKhoang = normalizedMm - currentPosition;
        
        // FIX: Xử lý trường hợp boundary để cung đầu tiên bắt đầu từ 0
        if (positionInKhoang == 0 && i > 0) {
          // Nếu đúng ở boundary và không phải khoảng đầu tiên, thuộc khoảng trước
          khoangIndex = i - 1;
          final prevKhoang = ruler.khoang[khoangIndex];
          cungIndex = prevKhoang.cung.length - 1;
        } else {
          cungIndex = math.min(
            (positionInKhoang / cungSizeMm).floor(),
            khoang.cung.length - 1
          );
        }
        break;
      }
      currentPosition += khoangSizeMm;
    }
    
    final selectedKhoang = ruler.getKhoangByIndex(khoangIndex);
    if (selectedKhoang == null) return null;
    
    final selectedCung = ruler.getCungByIndex(khoangIndex, cungIndex);
    if (selectedCung == null) return null;

    return RulerResult(
      ruler: ruler,
      khoang: selectedKhoang,
      cung: selectedCung,
      inputMm: inputMm,
      normalizedMm: normalizedMm,
      khoangIndex: khoangIndex,
      cungIndex: cungIndex,
    );
  }

  static List<RulerResult> calculateForAllRulers(
    Map<RulerType, RulerModel> rulers, 
    double inputMm
  ) {
    final results = <RulerResult>[];
    
    for (final ruler in rulers.values) {
      final result = calculate(ruler, inputMm);
      if (result != null) {
        results.add(result);
      }
    }
    
    return results;
  }

  // Utility functions cho UI
  static double mmToPixels(double mm) => mm * pixelsPerMm;
  static double pixelsToMm(double pixels) => pixels / pixelsPerMm;
  static double cmToPixels(double cm) => mmToPixels(cm * 10);
  static double pixelsToCm(double pixels) => pixelsToMm(pixels) / 10;

  // Validation
  static bool isValidInput(double mm) {
    // Only check for negative and valid number
    return mm >= 0 && mm.isFinite && !mm.isNaN;
  }

  static String? validateInput(String input) {
    if (input.isEmpty) return 'Vui lòng nhập kích thước';
    
    final value = double.tryParse(input);
    if (value == null) return 'Vui lòng nhập số hợp lệ';
    
    if (value < 0) return 'Kích thước phải lớn hơn hoặc bằng 0';
    // Remove max limit check - allow unlimited
    if (!value.isFinite) return 'Vui lòng nhập số hợp lệ';
    
    return null;
  }

  // Tính toán cho việc vẽ thước (UI rendering)
  static double calculateKhoangWidth(RulerModel ruler, double totalWidthPixels) {
    return totalWidthPixels / ruler.khoang.length;
  }

  static double calculateCungWidth(RulerModel ruler, double totalWidthPixels, int khoangIndex) {
    final khoang = ruler.getKhoangByIndex(khoangIndex);
    if (khoang == null) return 0;
    
    final khoangWidth = calculateKhoangWidth(ruler, totalWidthPixels);
    return khoangWidth / khoang.cung.length;
  }

  // Tính position từ mm input
  static double calculateScrollPosition(double inputMm, double viewportWidth) {
    final targetPixels = mmToPixels(inputMm);
    return math.max(0, targetPixels - (viewportWidth / 2));
  }

  // Tính mm từ scroll position
  static double calculateMmFromScroll(double scrollPosition, double viewportWidth) {
    final centerPixels = scrollPosition + (viewportWidth / 2);
    return math.max(0, pixelsToMm(centerPixels));
  }
}