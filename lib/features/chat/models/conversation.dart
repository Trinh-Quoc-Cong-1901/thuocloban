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

  static Conversation fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String,
      messages: (json['messages'] as List)
          .map((msg) => ChatMessage.fromJson(msg))
          .toList(),
      model: json['model'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [id, title, messages, model, userId, createdAt, updatedAt];
}