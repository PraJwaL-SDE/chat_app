import 'package:equatable/equatable.dart';

class GroupModel extends Equatable {
  final String groupId;
  final String name;
  final String profilePic;
  final List<String> membersUid;
  final String lastMessage;
  final DateTime timeSent;

  const GroupModel({
    required this.groupId,
    required this.name,
    required this.profilePic,
    required this.membersUid,
    required this.lastMessage,
    required this.timeSent,
  });

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'name': name,
      'profilePic': profilePic,
      'membersUid': membersUid,
      'lastMessage': lastMessage,
      'timeSent': timeSent.millisecondsSinceEpoch,
    };
  }

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      groupId: map['groupId'] ?? '',
      name: map['name'] ?? '',
      profilePic: map['profilePic'] ?? '',
      membersUid: List<String>.from(map['membersUid'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent'] ?? DateTime.now().millisecondsSinceEpoch),
    );
  }

  @override
  List<Object?> get props => [groupId, name, profilePic, membersUid, lastMessage, timeSent];
}
