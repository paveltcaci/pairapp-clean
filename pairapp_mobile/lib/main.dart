import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/firebase/firebase_setup.dart';
import 'features/auth/auth_gate.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await connectFirebaseEmulatorsIfNeeded();

  runApp(const PairApp());
}

class PairApp extends StatelessWidget {
  const PairApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PairApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AuthGate(),
    );
  }
}