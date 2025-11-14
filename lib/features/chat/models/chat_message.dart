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
    return ChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      role: MessageRole.values.firstWhere(
        (role) => role.name == json['role'],
        orElse: () => MessageRole.user,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isLoading: json['isLoading'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, content, role, timestamp, isLoading];
}