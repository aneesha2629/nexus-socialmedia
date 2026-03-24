import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/providers.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await db.init();
  
  // Check for persistent login
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  if (isLoggedIn) {
    // Restore session from SharedPreferences
    final name = prefs.getString('name') ?? '';
    final username = prefs.getString('username') ?? '';
    final bio = prefs.getString('bio') ?? '';
    final initials = prefs.getString('initials') ?? '';
    final profilePic = prefs.getString('profilePic');
    final age = prefs.getInt('age');
    
    if (name.isNotEmpty && username.isNotEmpty) {
      await db.restoreSession(name, username, bio, initials, profilePic, age);
    }
  }
  
  runApp(const ProviderScope(child: NexusApp()));
}

class NexusApp extends ConsumerWidget {
  const NexusApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final dark = ref.watch(settingsProvider).darkMode;
    return MaterialApp(
      title: 'Nexus',
      debugShowCheckedModeBanner: false,
      theme: T.light, darkTheme: T.dark,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: auth.loggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
