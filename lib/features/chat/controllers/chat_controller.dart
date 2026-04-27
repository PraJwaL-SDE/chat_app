import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../auth/models/user_model.dart';
import '../models/chat_contact.dart';
import '../models/message_model.dart';
import '../repositories/chat_repository.dart';
import '../../../../core/providers/message_reply_provider.dart';

final chatControllerProvider = Provider((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return ChatController(chatRepository: chatRepository, ref: ref);
});

final searchUsersProvider = StreamProvider.family<List<UserModel>, String>((
  ref,
  query,
) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return chatRepository.searchUsers(query);
});

final uploadProgressProvider = StateProvider<double?>((ref) => null);

class ChatController {
  final ChatRepository chatRepository;
  final Ref ref;

  ChatController({required this.chatRepository, required this.ref});

  Stream<List<UserModel>> getUsers() {
    return chatRepository.getUsers();
  }

  Stream<List<ChatContact>> getChatContacts() {
    return chatRepository.getChatContacts();
  }

  Stream<List<UserModel>> searchUsers(String query) {
    return chatRepository.searchUsers(query);
  }

  Stream<List<MessageModel>> getChatStream(String receiverUserId) {
    return chatRepository.getChatStream(receiverUserId);
  }

  Stream<List<MessageModel>> getGroupChatStream(String groupId) {
    return chatRepository.getGroupChatStream(groupId);
  }

  void createGroup(
    String name,
    File? profilePicFile,
    List<UserModel> selectedContacts,
  ) {
    chatRepository.createGroup(name, profilePicFile, selectedContacts, ref);
  }

  void sendTextMessage(String text, String receiverUserId, {bool isGroupChat = false}) async {
    final firestore = ref.read(firestoreProvider);
    final auth = ref.read(firebaseAuthProvider);
    final userDoc = await firestore.collection('users11').doc(auth.currentUser!.uid).get();
    final senderUser = UserModel.fromMap(userDoc.data()!);
    final messageReply = ref.read(messageReplyProvider);

    chatRepository.sendTextMessage(
      text: text,
      receiverUserId: receiverUserId,
      senderUser: senderUser,
      messageReply: messageReply,
      isGroupChat: isGroupChat,
    );

    ref.read(messageReplyProvider.notifier).state = null;
  }

  void sendFileMessage({
    required File file,
    required String receiverUserId,
    required MessageType messageType,
    bool isGroupChat = false,
  }) async {
    final firestore = ref.read(firestoreProvider);
    final auth = ref.read(firebaseAuthProvider);
    final userDoc = await firestore.collection('users11').doc(auth.currentUser!.uid).get();
    final senderUser = UserModel.fromMap(userDoc.data()!);
    final messageReply = ref.read(messageReplyProvider);

    ref.read(uploadProgressProvider.notifier).state = 0.0;

    await chatRepository.sendFileMessage(
      file: file,
      receiverUserId: receiverUserId,
      senderUser: senderUser,
      ref: ref,
      messageType: messageType,
      messageReply: messageReply,
      isGroupChat: isGroupChat,
      onProgress: (count, total) {
        if (total > 0) {
          ref.read(uploadProgressProvider.notifier).state = count / total;
        }
      },
    );

    ref.read(uploadProgressProvider.notifier).state = null;
    ref.read(messageReplyProvider.notifier).state = null;
  }

  void forwardMessage({
    required String text,
    required MessageType messageType,
    required List<ChatContact> selectedContacts,
  }) async {
    final firestore = ref.read(firestoreProvider);
    final auth = ref.read(firebaseAuthProvider);
    final userDoc = await firestore.collection('users11').doc(auth.currentUser!.uid).get();
    final senderUser = UserModel.fromMap(userDoc.data()!);

    for (var contact in selectedContacts) {
      chatRepository.forwardMessage(
        text: text,
        messageType: messageType,
        receiverUserId: contact.contactId,
        senderUser: senderUser,
        isGroupChat: contact.isGroup,
      );
    }
  }

  void setChatMessageSeen(
    String receiverUserId,
    String messageId,
    bool isGroupChat,
  ) {
    chatRepository.setChatMessageSeen(
      receiverUserId,
      messageId,
      isGroupChat,
    );
  }

  void setUserTypingStatus(
    String receiverUserId,
    bool isTyping,
    bool isGroupChat,
  ) {
    chatRepository.setUserTypingStatus(
      receiverUserId,
      isTyping,
      isGroupChat,
    );
  }

  Stream<List<String>> getTypingStatusStream(
    String receiverUserId,
    bool isGroupChat,
  ) {
    return chatRepository.getTypingStatusStream(
      receiverUserId,
      isGroupChat,
    );
  }
}


