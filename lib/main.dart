import 'dart:async';

import 'flash_dash/screens/home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:team_3_f25_project/screens/story_builder.dart';
import 'package:team_3_f25_project/screens/dashboard.dart';
import 'package:team_3_f25_project/screens/login.dart';
import 'package:team_3_f25_project/screens/progress_screen.dart';
import 'package:team_3_f25_project/screens/signup.dart';
import 'package:team_3_f25_project/screens/word_practice_page.dart';
import 'package:team_3_f25_project/services/user_db.dart';
import 'package:team_3_f25_project/utils/platform_stub.dart'
    if (dart.library.io) 'package:team_3_f25_project/utils/platform_io.dart';

const supabaseUrl = 'https://ewtkteekwuphxgeksiiy.supabase.co';
const supabaseKey =
    'sb_publishable_s34XGOlJoDeP1juZMIDz8Q_VVSWuJQw';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (isDesktopPlatform) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  try {
    final sync = await DatabaseHelper.instance.syncService;
    await sync.fullSync(tableName: 'users', primaryKey: 'id');
    await sync.fullSync(tableName: 'attempts', primaryKey: 'id');
    await sync.fullSync(tableName: 'currentList', primaryKey: 'id');

    Timer.periodic(const Duration(minutes: 1), (timer) {
      sync.fullSync(tableName: 'users', primaryKey: 'id');
      sync.fullSync(tableName: 'attempts', primaryKey: 'id');
      sync.fullSync(tableName: 'currentList', primaryKey: 'id');
    });
  } catch (e, stackTrace) {
    debugPrint('Startup sync failed (app will still load): $e');
    debugPrintStack(stackTrace: stackTrace);
  }

  runApp(const ReadRightApp());
}

class ReadRightApp extends StatefulWidget {
  const ReadRightApp({super.key});

  @override
  State<ReadRightApp> createState() => _ReadRightAppState();
}

class _ReadRightAppState extends State<ReadRightApp> {
  Widget _home = const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

Future<void> _loadSession() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');

    if (savedEmail == null) {
      if (!mounted) return;
      setState(() => _home = const LoginScreen());
      return;
    }

    final user =
        await DatabaseHelper.instance.getUserByEmail(savedEmail);

    if (user == null) {
      await prefs.remove('email');
      await prefs.remove('userId');

      if (!mounted) return;
      setState(() => _home = const LoginScreen());
      return;
    }

    final role = user.role.trim().toLowerCase();

    debugPrint('Loaded user: $savedEmail');
    debugPrint('User role: $role');
    debugPrint('User ID: ${user.id}');

    if (role == 'teacher') {
      if (!mounted) return;
      setState(() => _home = const DashboardScreen());
      return;
    }

    final userId = user.id;

    if (userId == null) {
      debugPrint('User ID is null');

      if (!mounted) return;
      setState(() => _home = const LoginScreen());
      return;
    }

    if (role == 'student') {
      final currentListId =
          await DatabaseHelper.instance.getUserListId(userId);

      debugPrint('Current list ID: $currentListId');

      if (!mounted) return;

      if (currentListId == null) {
        setState(
          () => _home = const Scaffold(
            body: Center(
              child: Text(
                'No word list has been assigned to this student.',
              ),
            ),
          ),
        );
        return;
      }

      setState(
        () => _home = ProgressScreen(listId: currentListId),
      );
      return;
    }

    debugPrint('Unknown user role: ${user.role}');

    if (!mounted) return;
    setState(() => _home = const LoginScreen());
  } catch (e, stackTrace) {
    debugPrint('Error loading session: $e');
    debugPrintStack(stackTrace: stackTrace);

    if (!mounted) return;
    setState(() => _home = const LoginScreen());
  }
}

@override
Widget build(BuildContext context) {
  return MaterialApp(
    title: 'ReadRight',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.indigo,
      useMaterial3: false,
    ),
    home: _home,
    routes: {
      '/dashboard': (context) => const DashboardScreen(),

      '/story-builder': (context) => const StoryBuilderScreen(),

      '/progress_screen': (context) {
        final args =
            ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;

        final listId = args?['listId'] as int?;

        if (listId == null) {
          return const Scaffold(
            body: Center(
              child: Text('No word list was provided.'),
            ),
          );
        }

        return ProgressScreen(listId: listId);
      },

      '/practice': (context) => WordPracticeScreen(),

      '/signup': (context) => const SignupScreen(),
    },
  );
}
}
