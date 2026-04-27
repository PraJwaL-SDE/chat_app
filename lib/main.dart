import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/chat/screens/chat_list_screen.dart';
import 'features/chat/screens/search_user_screen.dart';
import 'features/profile/screens/settings_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'core/providers/shared_prefs_provider.dart';

import 'features/splash/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBakxfLmqbBmsNs7Vncplz59Xjs61KKyIA',
        appId: '1:793875814500:android:b1cb4c9f122f3b8f01a771',
        messagingSenderId: '793875814500',
        projectId: 'chatting-app-2-8e7d4',
        storageBucket: 'chatting-app-2-8e7d4.appspot.com',
      ),
    );
  } catch (e) {
    debugPrint('Firebase initialization failed (probably missing config). $e');
  }

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const ChatApp(),
    ),
  );
}

class ChatApp extends ConsumerWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Flutter Chat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routes: {
        '/search': (context) => const SearchUserScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      home: const SplashScreen(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return authState.when(
      data: (user) {
        if (user != null) {
          return const ChatListScreen();
        }
        return const LoginScreen();
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, trace) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}

