import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';

import 'app.dart';
import 'data/local/local_storage_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
} else {
  await Firebase.initializeApp();
}

  // Set preferred orientations for phones & tablets
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Local Storage Service (SharedPreferences seed data & state)
  final prefs = await SharedPreferences.getInstance();
  final storageService = await LocalStorageService.init();

  // Initialize Local Authentication Service
  final authService = LocalAuthService(prefs);

  runApp(
    TravelExplorerApp(storageService: storageService, authService: authService),
  );
}
