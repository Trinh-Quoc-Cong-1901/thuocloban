import 'package:equatable/equatable.dart';

import 'chat_message.dart';

class Conversation extends Equatable {
  final String id;
  final String title;
  final List<ChatMessage> messages;
  final String model;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Conversation({
    required this.id,
    required this.title,
    required this.messages,
    required this.model,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? '',
      title: json['title'] ?? 'New Conversation',
      messages: (json['messages'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(ChatMessage.fromJson)
              .toList() ??
          [],
      model: json['model'] ?? 'openai',
      userId: json['userId'] ?? '',
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'model': model,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Conversation copyWith({
    String? id,
    String? title,
    List<ChatMessage>? messages,
    String? model,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      model: model ?? this.model,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    messages,
    model,
    userId,
    createdAt,
    updatedAt,
  ];
}
