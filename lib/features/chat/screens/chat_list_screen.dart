import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/chat_controller.dart';
import 'chat_screen.dart';
import 'create_group_screen.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/search');
        },
        child: const Icon(Icons.search),
      ),
      body: StreamBuilder(
        stream: ref.watch(chatControllerProvider).getChatContacts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text('No chats yet. Search to start one!'));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: snapshot.data!.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 80,
              endIndent: 16,
              color: scheme.outlineVariant.withValues(alpha: 0.6),
            ),
            itemBuilder: (context, index) {
              var chatContact = snapshot.data![index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: CircleAvatar(
                  backgroundColor: scheme.primary,
                  backgroundImage: chatContact.profilePic.isNotEmpty
                      ? NetworkImage(chatContact.profilePic)
                      : null,
                  child: chatContact.profilePic.isEmpty
                      ? Text(chatContact.name.isNotEmpty
                          ? chatContact.name.substring(0, 1).toUpperCase()
                          : '?')
                      : null,
                ),
                title: Text(
                  chatContact.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  chatContact.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat.Hm().format(chatContact.timeSent),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: chatContact.unreadCount > 0
                                ? scheme.primary
                                : scheme.onSurface.withValues(alpha: 0.55),
                            fontWeight: chatContact.unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                    ),
                    if (chatContact.unreadCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(top:6),
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: scheme.primary,
                          child: Text(
                            chatContact.unreadCount.toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        uid: chatContact.contactId,
                        name: chatContact.name,
                        isGroupChat: chatContact.isGroup,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
