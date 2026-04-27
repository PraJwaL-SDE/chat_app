import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/shared_prefs_provider.dart';

class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Privacy',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          SwitchListTile(
            title: const Text('Read Receipts'),
            subtitle: const Text('If turned off, you won\'t send or receive read receipts.'),
            value: settings['read_receipts'] ?? true,
            onChanged: (val) {
              ref.read(settingsProvider.notifier).updateSetting('read_receipts', val);
            },
          ),
          SwitchListTile(
            title: const Text('Show Last Seen'),
            subtitle: const Text('Allow others to see your last seen time.'),
            value: settings['show_last_seen'] ?? true,
            onChanged: (val) {
              ref.read(settingsProvider.notifier).updateSetting('show_last_seen', val);
            },
          ),
          const Divider(),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Security',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Security Notifications'),
            subtitle: const Text('Show security notifications on this phone'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Security notifications enabled')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Change Email'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Change email flow not implemented yet')),
              );
            },
          ),
        ],
      ),
    );
  }
}
