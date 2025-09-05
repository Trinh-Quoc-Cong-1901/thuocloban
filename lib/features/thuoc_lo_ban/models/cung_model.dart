class CungModel {
  final String name;
  final String description;

  const CungModel({
    required this.name,
    required this.description,
  });

  factory CungModel.fromJson(Map<String, dynamic> json) {
    return CungModel(
      name: json['name'] as String,
      description: json['desc'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'desc': description,
    };
  }

  @override
  String toString() {
    return 'CungModel(name: $name, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CungModel &&
        other.name == name &&
        other.description == description;
  }

  @override
  int get hashCode => name.hashCode ^ description.hashCode;
}