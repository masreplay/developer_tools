import 'package:developer_tools_riverpod/developer_tools_riverpod.dart';
import 'package:developer_tools/developer_tools.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      home: HomePage(),
      builder: DeveloperTools.builder(
        extensions: const [DeveloperToolsRiverpod()],
        navigatorKey: _navigatorKey,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Home')));
  }
}
