import 'package:flutter/material.dart';

import 'ads/ad_manager.dart';
import 'game/progress.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Progress.instance.load();
  AdManager.instance.init();
  runApp(const ColorSortApp());
}

class ColorSortApp extends StatelessWidget {
  const ColorSortApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'فرز الألوان',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF5B3CC4), brightness: Brightness.dark),
        useMaterial3: true,
      ),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const HomeScreen(),
    );
  }
}
