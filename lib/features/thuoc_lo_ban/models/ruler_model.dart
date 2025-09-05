import 'khoang_model.dart';
import 'cung_model.dart';

enum RulerType {
  thongThuy('thong_thuy', 'Thước Lỗ Ban 52.2cm', 'Khoảng thông thủy (cửa, cửa sổ...)', 52.2),
  duongTrach('duong_trach', 'Thước Lỗ Ban 42.9cm (Dương trạch)', 'Khối xây dựng (bếp, bệ, bậc...)', 42.9),
  amTrach('am_trach', 'Thước Lỗ Ban 38.8cm (Âm phần)', 'Đồ nội thất (bàn thờ, tủ...)', 38.8);

  const RulerType(this.key, this.titleShort, this.descriptionTitle, this.totalLength);

  final String key;
  final String titleShort;
  final String descriptionTitle;
  final double totalLength;
}

class RulerModel {
  final String name;
  final String titleShort;
  final String descriptionTitle;
  final double totalLength;
  final List<KhoangModel> khoang;
  final RulerType type;

  const RulerModel({
    required this.name,
    required this.titleShort,
    required this.descriptionTitle,
    required this.totalLength,
    required this.khoang,
    required this.type,
  });

  factory RulerModel.fromJson(Map<String, dynamic> json, RulerType type) {
    return RulerModel(
      name: json['name'] as String,
      titleShort: json['title_short'] as String,
      descriptionTitle: json['description_title'] as String,
      totalLength: (json['total_length'] as num).toDouble(),
      khoang: (json['khoang'] as List<dynamic>)
          .map((khoangJson) => KhoangModel.fromJson(khoangJson as Map<String, dynamic>))
          .toList(),
      type: type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'title_short': titleShort,
      'description_title': descriptionTitle,
      'total_length': totalLength,
      'khoang': khoang.map((k) => k.toJson()).toList(),
    };
  }

  // Tính toán các thuộc tính có ích
  double get totalLengthMm => totalLength * 10;
  
  // FIXED: Tính kích thước dựa trên tổng số cung thực tế
  int get totalCung => khoang.fold<int>(0, (sum, k) => sum + k.cung.length);
  double get cungSizeMm => totalLengthMm / totalCung;
  
  // Helper: Lấy kích thước khoảng theo số cung thực tế
  double getKhoangSizeMm(int khoangIndex) {
    if (khoangIndex < 0 || khoangIndex >= khoang.length) return 0;
    return khoang[khoangIndex].cung.length * cungSizeMm;
  }
  
  // Lấy khoảng theo index
  KhoangModel? getKhoangByIndex(int index) {
    if (index < 0 || index >= khoang.length) return null;
    return khoang[index];
  }

  // Lấy cung theo index khoảng và index cung
  CungModel? getCungByIndex(int khoangIndex, int cungIndex) {
    final selectedKhoang = getKhoangByIndex(khoangIndex);
    if (selectedKhoang == null) return null;
    
    if (cungIndex < 0 || cungIndex >= selectedKhoang.cung.length) return null;
    return selectedKhoang.cung[cungIndex];
  }

  @override
  String toString() {
    return 'RulerModel(name: $name, totalLength: $totalLength, khoang: ${khoang.length} items)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RulerModel &&
        other.name == name &&
        other.titleShort == titleShort &&
        other.descriptionTitle == descriptionTitle &&
        other.totalLength == totalLength &&
        other.type == type &&
        _listEquals(other.khoang, khoang);
  }

  @override
  int get hashCode {
    return name.hashCode ^
        titleShort.hashCode ^
        descriptionTitle.hashCode ^
        totalLength.hashCode ^
        type.hashCode ^
        khoang.hashCode;
  }
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (int index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) return false;
  }
  return true;
}