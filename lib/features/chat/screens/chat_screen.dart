import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/utils/common_utils.dart';
import '../models/message_model.dart';
import '../controllers/chat_controller.dart';
import '../widgets/chat_bubble.dart';
import 'profile_screen.dart';
import 'group_profile_screen.dart';
import '../../../../core/providers/message_reply_provider.dart';
import '../../../../core/providers/shared_prefs_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String uid;
  final String name;
  final bool isGroupChat;

  const ChatScreen({
    super.key,
    required this.uid,
    required this.name,
    this.isGroupChat = false,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool isRecording = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onMessageChanged);
  }

  void _onMessageChanged() {
    if (_messageController.text.isNotEmpty) {
      if (_typingTimer?.isActive ?? false) _typingTimer!.cancel();

      ref.read(chatControllerProvider).setUserTypingStatus(widget.uid, true, widget.isGroupChat);

      _typingTimer = Timer(const Duration(seconds: 3), () {
        ref.read(chatControllerProvider).setUserTypingStatus(widget.uid, false, widget.isGroupChat);
      });
    } else {
      ref.read(chatControllerProvider).setUserTypingStatus(widget.uid, false, widget.isGroupChat);
    }
  }

  @override
  void dispose() {
    _messageController.removeListener(_onMessageChanged);
    ref.read(chatControllerProvider).setUserTypingStatus(widget.uid, false, widget.isGroupChat);
    _messageController.dispose();
    _audioRecorder.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void sendTextMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      ref.read(chatControllerProvider).sendTextMessage(
            _messageController.text.trim(),
            widget.uid,
            isGroupChat: widget.isGroupChat,
          );
      _messageController.clear();
    }
  }

  void sendFileMessage(File file, MessageType messageType) {
    ref.read(chatControllerProvider).sendFileMessage(
          file: file,
          receiverUserId: widget.uid,
          messageType: messageType,
          isGroupChat: widget.isGroupChat,
        );
  }

  void selectImage() async {
    File? image = await pickImageFromGallery();
    if (image != null) {
      sendFileMessage(image, MessageType.image);
    }
  }

  void selectVideo() async {
    File? video = await pickVideoFromGallery();
    if (video != null) {
      sendFileMessage(video, MessageType.video);
    }
  }

  void toggleRecording() async {
    if (isRecording) {
      final path = await _audioRecorder.stop();
      setState(() {
        isRecording = false;
      });
      if (path != null) {
        sendFileMessage(File(path), MessageType.audio);
      }
    } else {
      final status = await Permission.microphone.request();
      if (status == PermissionStatus.granted) {
        var tempDir = await getTemporaryDirectory();
        var path = '${tempDir.path}/flutter_sound.m4a';
        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() {
          isRecording = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            if (widget.isGroupChat) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupProfileScreen(
                    groupId: widget.uid,
                    groupName: widget.name,
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(uid: widget.uid, name: widget.name),
                ),
              );
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.name, style: const TextStyle(fontSize: 18)),
              StreamBuilder<List<String>>(
                stream: ref.read(chatControllerProvider).getTypingStatusStream(widget.uid, widget.isGroupChat),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return const Text(
                      'typing...',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Colors.white70,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: widget.isGroupChat
                  ? ref.read(chatControllerProvider).getGroupChatStream(widget.uid)
                  : ref.read(chatControllerProvider).getChatStream(widget.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                return ListView.builder(
                  reverse: false,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final messageData = snapshot.data![index];
                    final isMe =
                        messageData.senderId ==
                        FirebaseAuth.instance.currentUser?.uid;

                    if (!isMe && !messageData.isSeen) {
                      final readReceiptsEnabled = ref.read(settingsProvider)['read_receipts'] ?? true;
                      if (readReceiptsEnabled) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ref.read(chatControllerProvider).setChatMessageSeen(
                                widget.uid,
                                messageData.messageId,
                                widget.isGroupChat,
                              );
                        });
                      }
                    }

                    return ChatBubble(
                      message: messageData.text,
                      isMe: isMe,
                      time: messageData.timeSent.toString().substring(11, 16),
                      type: messageData.type,
                      isSeen: messageData.isSeen,
                      repliedMessage: messageData.repliedMessage,
                      repliedTo: messageData.repliedTo,
                      repliedMessageType: messageData.repliedMessageType,
                      onSwipeReply: () {
                        ref.read(messageReplyProvider.notifier).state = MessageReply(
                          messageData.text,
                          isMe,
                          messageData.type,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Consumer(
            builder: (context, ref, child) {
              final uploadProgress = ref.watch(uploadProgressProvider);
              if (uploadProgress != null) {
                return LinearProgressIndicator(value: uploadProgress);
              }
              return const SizedBox.shrink();
            },
          ),
          Consumer(
            builder: (context, ref, child) {
              final messageReply = ref.watch(messageReplyProvider);
              if (messageReply == null) {
                return const SizedBox.shrink();
              }

              String replyText = messageReply.message;
              if (messageReply.messageType != MessageType.text) {
                replyText = 'Media';
              }

              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.08),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            messageReply.isMe ? 'Replying to yourself' : 'Replying to message',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            replyText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: scheme.onSurface.withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        ref.read(messageReplyProvider.notifier).state = null;
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => SafeArea(
                              child: Wrap(
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.photo),
                                    title: const Text('Photo'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      selectImage();
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.videocam),
                                    title: const Text('Video'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      selectVideo();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(isRecording ? Icons.stop : Icons.mic),
                        color: isRecording ? Colors.red : null,
                        onPressed: toggleRecording,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: scheme.primary,
                  radius: 25,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendTextMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
