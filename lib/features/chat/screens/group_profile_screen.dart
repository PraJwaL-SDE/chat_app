import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../auth/models/user_model.dart';
import '../models/group_model.dart';

class GroupProfileScreen extends ConsumerWidget {
  final String groupId;
  final String groupName;

  const GroupProfileScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestore = ref.watch(firestoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: firestore.collection('groups11').doc(groupId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(child: Text('Group not found'));
          }

          var group = GroupModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

          return Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 60,
                backgroundImage: group.profilePic.isNotEmpty
                    ? NetworkImage(group.profilePic)
                    : null,
                child: group.profilePic.isEmpty
                    ? Text(
                        group.name.isNotEmpty
                            ? group.name.substring(0, 1).toUpperCase()
                            : '?',
                        style: const TextStyle(fontSize: 40),
                      )
                    : null,
              ),
              const SizedBox(height: 10),
              Text(
                group.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Members',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: group.membersUid.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<DocumentSnapshot>(
                      future: firestore.collection('users11').doc(group.membersUid[index]).get(),
                      builder: (context, memberSnapshot) {
                        if (memberSnapshot.connectionState == ConnectionState.waiting) {
                          return const ListTile(
                            leading: CircleAvatar(child: CircularProgressIndicator()),
                            title: Text('Loading...'),
                          );
                        }

                        if (!memberSnapshot.hasData || memberSnapshot.data!.data() == null) {
                          return const SizedBox.shrink();
                        }

                        var user = UserModel.fromMap(memberSnapshot.data!.data() as Map<String, dynamic>);

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user.profilePic.isNotEmpty
                                ? NetworkImage(user.profilePic)
                                : null,
                            child: user.profilePic.isEmpty
                                ? Text(user.name.substring(0, 1).toUpperCase())
                                : null,
                          ),
                          title: Text(user.name),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
