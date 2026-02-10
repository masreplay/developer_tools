import 'package:developer_tools/developer_tools.dart';
import 'package:developer_tools_riverpod/developer_tools_riverpod.dart';
import 'package:example/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      observers: [DeveloperToolsRiverpod.observer()],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        home: const HomePage(),
        builder: DeveloperTools.builder(
          navigatorKey: _navigatorKey,
          extensions: const [DeveloperToolsRiverpod()],
        ),
      ),
    );
  }
}
