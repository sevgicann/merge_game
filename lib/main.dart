import 'package:flutter/material.dart';
import 'ui/game_screen.dart';

void main() {
  runApp(const MergeApp());
}

class MergeApp extends StatelessWidget {
  const MergeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Merge 2048',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}