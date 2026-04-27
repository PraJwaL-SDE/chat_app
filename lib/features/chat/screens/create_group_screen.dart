import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/common_utils.dart';
import '../../auth/models/user_model.dart';
import '../controllers/chat_controller.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  File? profilePic;
  List<UserModel> selectedContacts = [];
  bool isLoading = false;

  void selectImage() async {
    profilePic = await pickImageFromGallery();
    setState(() {});
  }

  void createGroup() {
    if (groupNameController.text.trim().isNotEmpty && selectedContacts.isNotEmpty) {
      ref.read(chatControllerProvider).createGroup(
            groupNameController.text.trim(),
            profilePic,
            selectedContacts,
          );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    groupNameController.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Stack(
              children: [
                profilePic == null
                    ? const CircleAvatar(
                        radius: 64,
                        child: Icon(Icons.group, size: 64),
                      )
                    : CircleAvatar(
                        radius: 64,
                        backgroundImage: FileImage(profilePic!),
                      ),
                Positioned(
                  bottom: -10,
                  left: 80,
                  child: IconButton(
                    onPressed: selectImage,
                    icon: const Icon(
                      Icons.add_a_photo,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: groupNameController,
                decoration: const InputDecoration(
                  hintText: 'Enter Group Name',
                ),
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(8),
              child: const Text(
                'Select Contacts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: TextField(
                controller: searchController,
                onChanged: (val) {
                  setState(() {});
                },
                decoration: const InputDecoration(
                  hintText: 'Search contacts...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: ref.watch(searchUsersProvider(searchController.text)).when(
                data: (data) {
                  if (data.isEmpty) {
                    return const Center(child: Text('No users found.'));
                  }
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      var user = data[index];
                      bool isSelected = selectedContacts.contains(user);

                      return ListTile(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedContacts.remove(user);
                            } else {
                              selectedContacts.add(user);
                            }
                          });
                        },
                        leading: CircleAvatar(
                          backgroundImage: user.profilePic.isNotEmpty
                              ? NetworkImage(user.profilePic)
                              : null,
                          child: user.profilePic.isEmpty
                              ? Text(user.name.substring(0, 1).toUpperCase())
                              : null,
                        ),
                        title: Text(user.name),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
                            : const Icon(Icons.circle_outlined),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => const Center(child: Text('Error loading users')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createGroup,
        child: const Icon(Icons.done),
      ),
    );
  }
}
