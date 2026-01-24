import 'dart:io';

import 'package:auto_updater/auto_updater.dart';
import 'package:flutter/material.dart';
import 'package:samar_trading_quotation/home_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only run updater on Desktop (Windows/MacOS) - auto_updater doesn't support Linux
  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS)) {
    // Using GitHub Pages or raw GitHub content for the updates.json
    // The CI/CD workflow uploads this to the latest release
    String feedURL = 'https://raw.githubusercontent.com/samartiwari/samar-trading-quotation-app/main/updates.json';

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


