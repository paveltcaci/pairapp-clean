import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

Future<void> connectFirebaseEmulatorsIfNeeded() async {
  if (!kDebugMode) return;

  final host = defaultTargetPlatform == TargetPlatform.android
      ? '10.0.2.2'
      : '127.0.0.1';

  try {
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);

    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);

    FirebaseFunctions.instanceFor(region: 'us-central1')
        .useFunctionsEmulator(host, 5001);

    FirebaseStorage.instance.useStorageEmulator(host, 9199);

    debugPrint('Firebase emulators connected at $host');
  } catch (e) {
    debugPrint('Firebase emulators not available: $e');
  }
}