import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_contact.dart';
import '../models/message_model.dart';

class ForwardScreen extends ConsumerStatefulWidget {
  final String messageText;
  final MessageType messageType;

  const ForwardScreen({
    super.key,
    required this.messageText,
    required this.messageType,
  });

  @override
  ConsumerState<ForwardScreen> createState() => _ForwardScreenState();
}

class _ForwardScreenState extends ConsumerState<ForwardScreen> {
  final List<ChatContact> selectedContacts = [];

  void forwardMessages() {
    if (selectedContacts.isNotEmpty) {
      ref.read(chatControllerProvider).forwardMessage(
            text: widget.messageText,
            messageType: widget.messageType,
            selectedContacts: selectedContacts,
          );
      Navigator.pop(context); // Close ForwardScreen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message forwarded')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forward to...'),
      ),
      body: StreamBuilder<List<ChatContact>>(
        stream: ref.watch(chatControllerProvider).getChatContacts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No recent chats found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var chatContact = snapshot.data![index];
              bool isSelected = selectedContacts.contains(chatContact);

              return ListTile(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedContacts.remove(chatContact);
                    } else {
                      selectedContacts.add(chatContact);
                    }
                  });
                },
                leading: Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      backgroundImage: chatContact.profilePic.isNotEmpty
                          ? NetworkImage(chatContact.profilePic)
                          : null,
                      child: chatContact.profilePic.isEmpty
                          ? Text(chatContact.name.isNotEmpty
                              ? chatContact.name.substring(0, 1).toUpperCase()
                              : '?')
                          : null,
                    ),
                    if (isSelected)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle,
                            color: Theme.of(context).primaryColor,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(
                  chatContact.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  chatContact.isGroup ? 'Group' : 'User',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_box, color: Theme.of(context).primaryColor)
                    : const Icon(Icons.check_box_outline_blank),
              );
            },
          );
        },
      ),
      floatingActionButton: selectedContacts.isNotEmpty
          ? FloatingActionButton(
              onPressed: forwardMessages,
              child: const Icon(Icons.send),
            )
          : null,
    );
  }
}
