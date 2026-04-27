import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/shared_prefs_provider.dart';

class NotificationsSettingsScreen extends ConsumerWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Messages',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          SwitchListTile(
            title: const Text('Message Tones'),
            subtitle: const Text('Play sounds for incoming and outgoing messages.'),
            value: settings['message_tones'] ?? true,
            onChanged: (val) {
              ref.read(settingsProvider.notifier).updateSetting('message_tones', val);
            },
          ),
          SwitchListTile(
            title: const Text('Vibrate'),
            value: settings['vibrate'] ?? true,
            onChanged: (val) {
              ref.read(settingsProvider.notifier).updateSetting('vibrate', val);
            },
          ),
          const Divider(),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Media',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          SwitchListTile(
            title: const Text('High Quality Media'),
            subtitle: const Text('Always download/upload media in high quality.'),
            value: settings['high_quality_media'] ?? false,
            onChanged: (val) {
              ref.read(settingsProvider.notifier).updateSetting('high_quality_media', val);
            },
          ),
        ],
      ),
    );
  }
}
