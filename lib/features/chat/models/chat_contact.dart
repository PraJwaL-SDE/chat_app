import 'package:equatable/equatable.dart';

class ChatContact extends Equatable {
  final String name;
  final String profilePic;
  final String contactId;
  final DateTime timeSent;
  final String lastMessage;
  final bool isGroup;
  final int unreadCount;

  const ChatContact({
    required this.name,
    required this.profilePic,
    required this.contactId,
    required this.timeSent,
    required this.lastMessage,
    this.isGroup = false,
    this.unreadCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profilePic': profilePic,
      'contactId': contactId,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'lastMessage': lastMessage,
      'isGroup': isGroup,
      'unreadCount': unreadCount,
    };
  }

  factory ChatContact.fromMap(Map<String, dynamic> map) {
    return ChatContact(
      name: map['name'] ?? '',
      profilePic: map['profilePic'] ?? '',
      contactId: map['contactId'] ?? '',
      timeSent: DateTime.fromMillisecondsSinceEpoch(
          map['timeSent'] ?? DateTime.now().millisecondsSinceEpoch),
      lastMessage: map['lastMessage'] ?? '',
      isGroup: map['isGroup'] ?? false,
      unreadCount: map['unreadCount'] ?? 0,
    );
  }

  @override
  List<Object?> get props =>
      [name, profilePic, contactId, timeSent, lastMessage, isGroup, unreadCount];
}
