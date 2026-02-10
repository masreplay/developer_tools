import 'package:developer_tools/developer_tools.dart';
import 'package:developer_tools_riverpod/developer_tools_riverpod.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      builder: DeveloperTools.builder(
        extensions: const [
          DeveloperToolsRiverpod(),
        ],
        entries: [
          DeveloperToolEntry(
            title: 'Open debug page',
            description: 'Navigate to the Other page with toast button.',
            icon: Icons.developer_mode,
            onTap: (context) {},
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
    );
  }
}
