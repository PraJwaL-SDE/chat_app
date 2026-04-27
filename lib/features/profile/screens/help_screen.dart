import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.help_center),
            title: const Text('Help Center'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help Center coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_support),
            title: const Text('Contact Us'),
            subtitle: const Text('Questions? Need help?'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contact Support coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy Policy coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('App Info'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Chat App',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.chat, size: 40),
                children: [
                  const Text('A beautiful and functional chat application built with Flutter and Firebase.'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
