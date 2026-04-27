import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../auth/models/user_model.dart';
import 'full_screen_media_view.dart';

class ProfileScreen extends ConsumerWidget {
  final String uid;
  final String name;

  const ProfileScreen({
    super.key,
    required this.uid,
    required this.name,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestore = ref.watch(firestoreProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.grey[100]
          : Colors.black,
      body: FutureBuilder<DocumentSnapshot>(
        future: firestore.collection('users11').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data != null && snapshot.data!.exists
              ? UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>)
              : null;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 350.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (userData?.profilePic != null && userData!.profilePic.isNotEmpty)
                        Image.network(
                          userData.profilePic,
                          fit: BoxFit.cover,
                        )
                      else
                        Container(
                          color: Theme.of(context).primaryColor,
                          child: Icon(
                            Icons.person,
                            size: 150,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  _buildStatusSection(context, userData),
                  _buildActionButtons(context),
                  const SizedBox(height: 10),
                  _buildMediaSection(context),
                  const SizedBox(height: 10),
                  _buildSettingsSection(context),
                  const SizedBox(height: 10),
                  _buildDangerousActionsSection(context),
                  const SizedBox(height: 100),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, UserModel? user) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bio & Email',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user?.email ?? 'No email available',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            'Hey there! I am using ChatApp.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCircleAction(context, Icons.message, 'Message'),
          _buildCircleAction(context, Icons.call, 'Audio'),
          _buildCircleAction(context, Icons.videocam, 'Video'),
        ],
      ),
    );
  }

  Widget _buildCircleAction(BuildContext context, IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMediaSection(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Media, links, and docs',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Row(
                children: [
                  const Text('14', style: TextStyle(color: Colors.grey)),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Container(
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.image, color: Colors.grey[400]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          _buildSettingsTile(context, Icons.notifications, 'Mute notifications'),
          _buildSettingsTile(context, Icons.music_note, 'Custom notifications'),
          _buildSettingsTile(context, Icons.photo_library, 'Media visibility'),
          const Divider(height: 1, indent: 56),
          _buildSettingsTile(context, Icons.lock, 'Encryption',
              subtitle: 'Messages and calls are end-to-end encrypted. Tap to verify.'),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, IconData icon, String title,
      {String? subtitle}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      onTap: () {},
    );
  }

  Widget _buildDangerousActionsSection(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.block, color: Colors.red),
            title: Text('Block $name', style: const TextStyle(color: Colors.red)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.thumb_down, color: Colors.red),
            title: Text('Report $name', style: const TextStyle(color: Colors.red)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

