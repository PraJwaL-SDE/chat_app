import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../features/chat/models/message_model.dart';

class MessageReply {
  final String message;
  final bool isMe;
  final MessageType messageType;

  MessageReply(this.message, this.isMe, this.messageType);
}

final messageReplyProvider = StateProvider<MessageReply?>((ref) => null);
