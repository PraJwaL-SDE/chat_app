import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String profilePic;
  final bool isOnline;
  final DateTime lastSeen;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.profilePic,
    required this.isOnline,
    required this.lastSeen,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profilePic': profilePic,
      'isOnline': isOnline,
      'lastSeen': lastSeen.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    DateTime lastSeen;
    var rawLastSeen = map['lastSeen'];
    if (rawLastSeen is Timestamp) {
      lastSeen = rawLastSeen.toDate();
    } else if (rawLastSeen is int) {
      lastSeen = DateTime.fromMillisecondsSinceEpoch(rawLastSeen);
    } else {
      lastSeen = DateTime.now();
    }

    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profilePic: map['profilePic'] ?? '',
      isOnline: map['isOnline'] ?? false,
      lastSeen: lastSeen,
    );
  }

  @override
  List<Object?> get props => [uid, name, email, profilePic, isOnline, lastSeen];
}
