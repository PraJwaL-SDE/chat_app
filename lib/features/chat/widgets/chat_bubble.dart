import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/message_model.dart';
import '../screens/forward_screen.dart';
import '../screens/full_screen_media_view.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String time;
  final MessageType type;
  final String repliedMessage;
  final String repliedTo;
  final MessageType repliedMessageType;
  final VoidCallback? onSwipeReply;
  final bool isSeen;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.time,
    required this.type,
    required this.isSeen,
    this.repliedMessage = '',
    this.repliedTo = '',
    this.repliedMessageType = MessageType.text,
    this.onSwipeReply,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return SafeArea(
                child: Wrap(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.forward),
                      title: const Text('Forward'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForwardScreen(
                              messageText: message,
                              messageType: type,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            onSwipeReply?.call();
            return false;
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: isMe ? scheme.primary : scheme.surface,
              border: Border.all(
                color: isMe ? Colors.transparent : scheme.outlineVariant,
              ),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                bottomRight: isMe ? Radius.zero : const Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (repliedMessage.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMe
                          ? scheme.onPrimary.withValues(alpha: 0.12)
                          : scheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          repliedTo,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isMe ? scheme.onPrimary : scheme.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          repliedMessageType == MessageType.text
                              ? repliedMessage
                              : 'Media',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isMe
                                ? scheme.onPrimary.withValues(alpha: 0.8)
                                : scheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (type == MessageType.text)
                  Text(
                    message,
                    style: TextStyle(
                      color: isMe ? scheme.onPrimary : scheme.onSurface,
                      fontSize: 15.5,
                      height: 1.25,
                    ),
                  )
                else if (type == MessageType.image)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenMediaView(
                            url: message,
                            type: MessageType.image,
                          ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: message,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: message,
                          width: 220,
                          placeholder: (context, url) => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
                  )
                else if (type == MessageType.video)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenMediaView(
                            url: message,
                            type: MessageType.video,
                          ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: message,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe
                              ? scheme.onPrimary.withValues(alpha: 0.14)
                              : scheme.onSurface.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isMe
                                ? Colors.transparent
                                : scheme.outlineVariant,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.play_circle_fill,
                              color:
                                  isMe ? scheme.onPrimary : scheme.onSurface,
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Video',
                              style: TextStyle(
                                color: isMe
                                    ? scheme.onPrimary
                                    : scheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (type == MessageType.audio)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.mic,
                        color: isMe ? scheme.onPrimary : scheme.onSurface,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Audio',
                        style: TextStyle(
                          color: isMe ? scheme.onPrimary : scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        color: isMe
                            ? scheme.onPrimary.withValues(alpha: 0.75)
                            : scheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        isSeen ? Icons.done_all : Icons.done,
                        size: 14,
                        color: scheme.onPrimary.withValues(
                          alpha: isSeen ? 1.0 : 0.75,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
