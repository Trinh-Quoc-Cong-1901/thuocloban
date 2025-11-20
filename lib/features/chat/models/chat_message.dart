import 'package:equatable/equatable.dart';

enum MessageRole {
  user,
  assistant,
}

class ChatMessage extends Equatable {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isLoading;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isLoading = false,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    bool? isLoading,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role.name,
      'timestamp': timestamp.toIso8601String(),
      'isLoading': isLoading,
    };
  }

  static ChatMessage fromJson(Map<String, dynamic> json) {
    final idValue = json['id'];
    final contentValue = json['content'];
    final roleValue = json['role'];
    final timestampValue = json['timestamp'];

    final timestamp = () {
      if (timestampValue is String) {
        return DateTime.tryParse(timestampValue) ?? DateTime.now();
      }
      if (timestampValue is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestampValue);
      }
      if (timestampValue is double) {
        return DateTime.fromMillisecondsSinceEpoch(timestampValue.toInt());
      }
      return DateTime.now();
    }();

    final roleString = roleValue?.toString();

    return ChatMessage(
      id: idValue?.toString() ?? '',
      content: contentValue?.toString() ?? '',
      role: MessageRole.values.firstWhere(
        (role) => role.name == roleString,
        orElse: () => MessageRole.user,
      ),
      timestamp: timestamp,
      isLoading: json['isLoading'] == true,
    );
  }

  @override
  List<Object?> get props => [id, content, role, timestamp, isLoading];
}
