import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../../core/repositories/cloudinary_repository.dart';
import '../../auth/models/user_model.dart';
import '../models/chat_contact.dart';
import '../models/message_model.dart';
import '../models/group_model.dart';
import '../../../../core/providers/message_reply_provider.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(
    firestore: ref.read(firestoreProvider),
    auth: ref.read(firebaseAuthProvider),
  );
});

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ChatRepository({required this.firestore, required this.auth});

  Stream<List<UserModel>> getUsers() {
    return firestore.collection('users11').snapshots().map((event) {
      List<UserModel> users = [];
      for (var doc in event.docs) {
        if (doc.id != auth.currentUser?.uid) {
          users.add(UserModel.fromMap(doc.data()));
        }
      }
      return users;
    });
  }

  Stream<List<ChatContact>> getChatContacts() {
    return firestore
        .collection('users11')
        .doc(auth.currentUser!.uid)
        .collection('chats11')
        .orderBy('timeSent', descending: true)
        .snapshots()
        .asyncMap((event) async {
      List<ChatContact> contacts = [];
      for (var document in event.docs) {
        var chatContact = ChatContact.fromMap(document.data());
        int unreadCount = 0;

        if (chatContact.isGroup) {
          var groupData = await firestore
              .collection('groups11')
              .doc(chatContact.contactId)
              .get();

          if (groupData.data() != null) {
            var group = GroupModel.fromMap(groupData.data()!);

            // Count unread messages in group
            var unreadMessagesSnapshot = await firestore
                .collection('groups11')
                .doc(chatContact.contactId)
                .collection('messages11')
                .where('isSeen', isEqualTo: false)
                .get();

            for (var doc in unreadMessagesSnapshot.docs) {
              if (doc.data()['senderId'] != auth.currentUser!.uid) {
                unreadCount++;
              }
            }

            contacts.add(
              ChatContact(
                name: group.name,
                profilePic: group.profilePic,
                contactId: chatContact.contactId,
                timeSent: chatContact.timeSent,
                lastMessage: chatContact.lastMessage,
                isGroup: true,
                unreadCount: unreadCount,
              ),
            );
          }
        } else {
          var userData = await firestore
              .collection('users11')
              .doc(chatContact.contactId)
              .get();

          if (userData.data() != null) {
            var user = UserModel.fromMap(userData.data()!);

            // Count unread messages in 1-on-1 chat
            var unreadMessagesSnapshot = await firestore
                .collection('users11')
                .doc(auth.currentUser!.uid)
                .collection('chats11')
                .doc(chatContact.contactId)
                .collection('messages11')
                .where('isSeen', isEqualTo: false)
                .where('senderId', isNotEqualTo: auth.currentUser!.uid)
                .get();

            unreadCount = unreadMessagesSnapshot.docs.length;

            contacts.add(
              ChatContact(
                name: user.name,
                profilePic: user.profilePic,
                contactId: chatContact.contactId,
                timeSent: chatContact.timeSent,
                lastMessage: chatContact.lastMessage,
                isGroup: false,
                unreadCount: unreadCount,
              ),
            );
          }
        }
      }
      return contacts;
    });
  }

  Stream<List<UserModel>> searchUsers(String query) {
    final lowerCaseQuery = query.toLowerCase();
    return firestore.collection('users11').snapshots().map((event) {
      List<UserModel> users = [];
      for (var doc in event.docs) {
        if (doc.id != auth.currentUser?.uid) {
          final user = UserModel.fromMap(doc.data());
          if (user.name.toLowerCase().contains(lowerCaseQuery) ||
              user.email.toLowerCase().contains(lowerCaseQuery)) {
            users.add(user);
          }
        }
      }
      return users;
    });
  }

  Stream<List<MessageModel>> getChatStream(String receiverUserId) {
    if (receiverUserId.isEmpty) return Stream.value([]);
    return firestore
        .collection('users11')
        .doc(auth.currentUser!.uid)
        .collection('chats11')
        .doc(receiverUserId)
        .collection('messages11')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
          List<MessageModel> messages = [];
          for (var doc in event.docs) {
            messages.add(MessageModel.fromMap(doc.data()));
          }
          return messages;
        });
  }

  Stream<List<MessageModel>> getGroupChatStream(String groupId) {
    return firestore
        .collection('groups11')
        .doc(groupId)
        .collection('messages11')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<MessageModel> messages = [];
      for (var doc in event.docs) {
        messages.add(MessageModel.fromMap(doc.data()));
      }
      return messages;
    });
  }

  Future<void> createGroup(
    String name,
    File? profilePicFile,
    List<UserModel> selectedContacts,
    Ref ref,
  ) async {
    try {
      var groupId = const Uuid().v1();
      String profilePicUrl = '';
      if (profilePicFile != null) {
        profilePicUrl = await ref
            .read(cloudinaryRepositoryProvider)
            .uploadFile(profilePicFile, 'group/$groupId');
      }

      List<String> uids = selectedContacts.map((e) => e.uid).toList();
      uids.add(auth.currentUser!.uid);

      var group = GroupModel(
        groupId: groupId,
        name: name,
        profilePic: profilePicUrl,
        membersUid: uids,
        lastMessage: '',
        timeSent: DateTime.now(),
      );

      await firestore.collection('groups11').doc(groupId).set(group.toMap());

      for (var uid in uids) {
        await firestore
            .collection('users11')
            .doc(uid)
            .collection('chats11')
            .doc(groupId)
            .set(ChatContact(
              name: name,
              profilePic: profilePicUrl,
              contactId: groupId,
              timeSent: DateTime.now(),
              lastMessage: '',
              isGroup: true,
            ).toMap());
      }
    } catch (e) {
      // Handle error
    }
  }

  void _saveDataToContactsSubcollection(
    UserModel senderUserData,
    UserModel? receiverUserData,
    String text,
    DateTime timeSent,
    String receiverUserId, {
    bool isGroupChat = false,
  }) async {
    if (isGroupChat) {
      var groupData =
          await firestore.collection('groups11').doc(receiverUserId).get();
      if (groupData.data() != null) {
        var group = GroupModel.fromMap(groupData.data()!);
        await firestore.collection('groups11').doc(receiverUserId).update({
          'lastMessage': text,
          'timeSent': timeSent.millisecondsSinceEpoch,
        });

        for (var memberUid in group.membersUid) {
          await firestore
              .collection('users11')
              .doc(memberUid)
              .collection('chats11')
              .doc(receiverUserId)
              .update({
            'lastMessage': text,
            'timeSent': timeSent.millisecondsSinceEpoch,
          });
        }
      }
    } else {
      var receiverChatContact = ChatContact(
        name: senderUserData.name,
        profilePic: senderUserData.profilePic,
        contactId: senderUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
      );
      await firestore
          .collection('users11')
          .doc(receiverUserId)
          .collection('chats11')
          .doc(senderUserData.uid)
          .set(receiverChatContact.toMap());

      if (receiverUserData != null) {
        var senderChatContact = ChatContact(
          name: receiverUserData.name,
          profilePic: receiverUserData.profilePic,
          contactId: receiverUserData.uid,
          timeSent: timeSent,
          lastMessage: text,
        );
        await firestore
            .collection('users11')
            .doc(senderUserData.uid)
            .collection('chats11')
            .doc(receiverUserId)
            .set(senderChatContact.toMap());
      }
    }
  }

  void _saveMessageToMessageSubcollection({
    required String receiverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String senderUsername,
    required String receiverUsername,
    required MessageType messageType,
    required bool isGroupChat,
    required MessageReply? messageReply,
  }) async {
    final message = MessageModel(
      senderId: auth.currentUser!.uid,
      receiverId: receiverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
      repliedMessage: messageReply?.message ?? '',
      repliedTo: messageReply != null ? (messageReply.isMe ? senderUsername : receiverUsername) : '',
      repliedMessageType: messageReply?.messageType ?? MessageType.text,
    );


    if (isGroupChat) {
      await firestore
          .collection('groups11')
          .doc(receiverUserId)
          .collection('messages11')
          .doc(messageId)
          .set(message.toMap());
    } else {
      await firestore
          .collection('users11')
          .doc(auth.currentUser!.uid)
          .collection('chats11')
          .doc(receiverUserId)
          .collection('messages11')
          .doc(messageId)
          .set(message.toMap());

      await firestore
          .collection('users11')
          .doc(receiverUserId)
          .collection('chats11')
          .doc(auth.currentUser!.uid)
          .collection('messages11')
          .doc(messageId)
          .set(message.toMap());
    }
  }

  Future<void> sendTextMessage({
    required String text,
    required String receiverUserId,
    required UserModel senderUser,
    required MessageReply? messageReply,
    bool isGroupChat = false,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      UserModel? receiverUserData;
      if (!isGroupChat) {
        var userDataMap =
            await firestore.collection('users11').doc(receiverUserId).get();
        if (userDataMap.data() != null) {
          receiverUserData = UserModel.fromMap(userDataMap.data()!);
        }
      }

      _saveDataToContactsSubcollection(
        senderUser,
        receiverUserData,
        text,
        timeSent,
        receiverUserId,
        isGroupChat: isGroupChat,
      );

      _saveMessageToMessageSubcollection(
        receiverUserId: receiverUserId,
        text: text,
        timeSent: timeSent,
        messageType: MessageType.text,
        messageId: messageId,
        receiverUsername: receiverUserData?.name ?? '',
        senderUsername: senderUser.name,
        isGroupChat: isGroupChat,
        messageReply: messageReply,
      );
    } catch (e) {
      // Handle error
    }
  }

  Future<void> sendFileMessage({
    required File file,
    required String receiverUserId,
    required UserModel senderUser,
    required Ref ref,
    required MessageType messageType,
    required MessageReply? messageReply,
    bool isGroupChat = false,
    void Function(int, int)? onProgress,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      String imageUrl = await ref
          .read(cloudinaryRepositoryProvider)
          .uploadFile(
            file,
            'chat/${messageType.name}/${senderUser.uid}/$receiverUserId',
            onProgress: onProgress,
          );

      UserModel? receiverUserData;
      if (!isGroupChat) {
        var userDataMap =
            await firestore.collection('users11').doc(receiverUserId).get();
        if (userDataMap.data() != null) {
          receiverUserData = UserModel.fromMap(userDataMap.data()!);
        }
      }

      String contactMsg;
      switch (messageType) {
        case MessageType.image:
          contactMsg = '📷 Photo';
          break;
        case MessageType.video:
          contactMsg = '📸 Video';
          break;
        case MessageType.audio:
          contactMsg = '🎵 Audio';
          break;
        default:
          contactMsg = '📁 File';
      }

      _saveDataToContactsSubcollection(
        senderUser,
        receiverUserData,
        contactMsg,
        timeSent,
        receiverUserId,
        isGroupChat: isGroupChat,
      );

      _saveMessageToMessageSubcollection(
        receiverUserId: receiverUserId,
        text: imageUrl,
        timeSent: timeSent,
        messageId: messageId,
        messageType: messageType,
        receiverUsername: receiverUserData?.name ?? '',
        senderUsername: senderUser.name,
        isGroupChat: isGroupChat,
        messageReply: messageReply,
      );
    } catch (e) {
      // Handle error
    }
  }
  Future<void> forwardMessage({
    required String text,
    required MessageType messageType,
    required String receiverUserId,
    required UserModel senderUser,
    bool isGroupChat = false,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      UserModel? receiverUserData;
      if (!isGroupChat) {
        var userDataMap =
            await firestore.collection('users11').doc(receiverUserId).get();
        if (userDataMap.data() != null) {
          receiverUserData = UserModel.fromMap(userDataMap.data()!);
        }
      }

      String contactMsg = text;
      if (messageType != MessageType.text) {
        switch (messageType) {
          case MessageType.image:
            contactMsg = '📷 Photo';
            break;
          case MessageType.video:
            contactMsg = '📸 Video';
            break;
          case MessageType.audio:
            contactMsg = '🎵 Audio';
            break;
          default:
            contactMsg = '📁 File';
        }
      }

      _saveDataToContactsSubcollection(
        senderUser,
        receiverUserData,
        contactMsg,
        timeSent,
        receiverUserId,
        isGroupChat: isGroupChat,
      );

      _saveMessageToMessageSubcollection(
        receiverUserId: receiverUserId,
        text: text, // This is the original text or URL
        timeSent: timeSent,
        messageType: messageType,
        messageId: messageId,
        receiverUsername: receiverUserData?.name ?? '',
        senderUsername: senderUser.name,
        isGroupChat: isGroupChat,
        messageReply: null,
      );
    } catch (e) {
      // Handle error
    }
  }

  Future<void> setChatMessageSeen(
    String receiverUserId,
    String messageId,
    bool isGroupChat,
  ) async {
    try {
      if (isGroupChat) {
        await firestore
            .collection('groups11')
            .doc(receiverUserId)
            .collection('messages11')
            .doc(messageId)
            .update({'isSeen': true});
      } else {
        await firestore
            .collection('users11')
            .doc(auth.currentUser!.uid)
            .collection('chats11')
            .doc(receiverUserId)
            .collection('messages11')
            .doc(messageId)
            .update({'isSeen': true});

        await firestore
            .collection('users11')
            .doc(receiverUserId)
            .collection('chats11')
            .doc(auth.currentUser!.uid)
            .collection('messages11')
            .doc(messageId)
            .update({'isSeen': true});
      }
    } catch (e) {
      // Handle error
    }
  }

  String _getChatId(String receiverUserId) {
    List<String> ids = [auth.currentUser!.uid, receiverUserId];
    ids.sort();
    return ids.join('_');
  }

  Future<void> setUserTypingStatus(
    String receiverUserId,
    bool isTyping,
    bool isGroupChat,
  ) async {
    try {
      String chatId = isGroupChat ? receiverUserId : _getChatId(receiverUserId);
      await firestore.collection('typing_status11').doc(chatId).set({
        'typingUsers': {
          auth.currentUser!.uid: isTyping,
        }
      }, SetOptions(merge: true));
    } catch (e) {
      // Handle error
    }
  }

  Stream<List<String>> getTypingStatusStream(
    String receiverUserId,
    bool isGroupChat,
  ) {
    String chatId = isGroupChat ? receiverUserId : _getChatId(receiverUserId);
    return firestore
        .collection('typing_status11')
        .doc(chatId)
        .snapshots()
        .map((event) {
      if (!event.exists || event.data() == null) return [];
      Map<String, dynamic> typingUsers = event.data()!['typingUsers'] ?? {};
      List<String> typingList = [];
      typingUsers.forEach((uid, isTyping) {
        if (isTyping == true && uid != auth.currentUser!.uid) {
          typingList.add(uid);
        }
      });
      return typingList;
    });
  }
}
