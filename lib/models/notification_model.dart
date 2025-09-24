class NotificationModel {
  final int id;
  final String title;
  final String body;
  final int hour;
  final int minute;
  final bool isEnabled;
  final String channelId;
  final String channelName;
  
  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
    required this.channelId,
    required this.channelName,
  });
  
  // Convert to/from JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'hour': hour,
      'minute': minute,
      'isEnabled': isEnabled,
      'channelId': channelId,
      'channelName': channelName,
    };
  }
  
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      hour: json['hour'],
      minute: json['minute'],
      isEnabled: json['isEnabled'] ?? true,
      channelId: json['channelId'],
      channelName: json['channelName'],
    );
  }
  
  // Copy with changes
  NotificationModel copyWith({
    int? id,
    String? title,
    String? body,
    int? hour,
    int? minute,
    bool? isEnabled,
    String? channelId,
    String? channelName,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isEnabled: isEnabled ?? this.isEnabled,
      channelId: channelId ?? this.channelId,
      channelName: channelName ?? this.channelName,
    );
  }
  
  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, time: $hour:$minute, enabled: $isEnabled)';
  }
}