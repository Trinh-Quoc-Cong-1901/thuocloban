import 'cung_model.dart';

enum KhoangType { good, bad }

class KhoangModel {
  final String name;
  final KhoangType type;
  final List<CungModel> cung;

  const KhoangModel({
    required this.name,
    required this.type,
    required this.cung,
  });

  factory KhoangModel.fromJson(Map<String, dynamic> json) {
    return KhoangModel(
      name: json['name'] as String,
      type: json['type'] == 'good' ? KhoangType.good : KhoangType.bad,
      cung: (json['cung'] as List<dynamic>)
          .map((cungJson) => CungModel.fromJson(cungJson as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type == KhoangType.good ? 'good' : 'bad',
      'cung': cung.map((c) => c.toJson()).toList(),
    };
  }

  bool get isGood => type == KhoangType.good;
  bool get isBad => type == KhoangType.bad;

  String get typeDisplayText => isGood ? 'TỐT' : 'XẤU';

  @override
  String toString() {
    return 'KhoangModel(name: $name, type: $type, cung: ${cung.length} items)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KhoangModel &&
        other.name == name &&
        other.type == type &&
        _listEquals(other.cung, cung);
  }

  @override
  int get hashCode => name.hashCode ^ type.hashCode ^ cung.hashCode;
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (int index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) return false;
  }
  return true;
}