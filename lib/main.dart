import 'dart:io';

import 'package:auto_updater/auto_updater.dart';
import 'package:flutter/material.dart';
import 'package:samar_trading_quotation/home_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only run updater on Desktop (Windows/MacOS) - auto_updater doesn't support Linux
  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS)) {
    String feedURL = 'https://github.com/samartiwari/samar-trading-quotation-app/releases/latest/download/updates.json';

    await autoUpdater.setFeedURL(feedURL);
    await autoUpdater.setScheduledCheckInterval(3600); // Check every hour
    await autoUpdater.checkForUpdates();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}


