import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum MessageType { text, image, video, audio }

class MessageModel extends Equatable {
  final String senderId;
  final String receiverId;
  final String text;
  final MessageType type;
  final DateTime timeSent;
  final String messageId;
  final bool isSeen;
  final String repliedMessage;
  final String repliedTo;
  final MessageType repliedMessageType;

  const MessageModel({
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.type,
    required this.timeSent,
    required this.messageId,
    required this.isSeen,
    required this.repliedMessage,
    required this.repliedTo,
    required this.repliedMessageType,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'type': type.name,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'messageId': messageId,
      'isSeen': isSeen,
      'repliedMessage': repliedMessage,
      'repliedTo': repliedTo,
      'repliedMessageType': repliedMessageType.name,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    DateTime timeSent;
    var rawTimeSent = map['timeSent'];
    if (rawTimeSent is Timestamp) {
      timeSent = rawTimeSent.toDate();
    } else if (rawTimeSent is int) {
      timeSent = DateTime.fromMillisecondsSinceEpoch(rawTimeSent);
    } else {
      timeSent = DateTime.now();
    }

    return MessageModel(
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      text: map['text'] ?? '',
      type: MessageType.values.firstWhere(
          (e) => e.name == map['type'],
          orElse: () => MessageType.text),
      timeSent: timeSent,
      messageId: map['messageId'] ?? '',
      isSeen: map['isSeen'] ?? false,
      repliedMessage: map['repliedMessage'] ?? '',
      repliedTo: map['repliedTo'] ?? '',
      repliedMessageType: MessageType.values.firstWhere(
          (e) => e.name == map['repliedMessageType'],
          orElse: () => MessageType.text),
    );
  }

  @override
  List<Object?> get props => [
    senderId,
    receiverId,
    text,
    type,
    timeSent,
    messageId,
    isSeen,
    repliedMessage,
    repliedTo,
    repliedMessageType,
  ];
}
