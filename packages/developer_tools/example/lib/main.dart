import 'package:developer_tools/developer_tools.dart';
import 'package:developer_tools_console/developer_tools_console.dart';
import 'package:flutter/material.dart';

void main() {
  DeveloperToolsConsole.installErrorHandlers();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      home: const HomePage(),
      builder: DeveloperTools.builder(
        navigatorKey: _navigatorKey,
        extensions: const [DeveloperToolsConsole()],
        dockConfig: DeveloperToolsDockConfig(
          enabled: true,
          position: DeveloperToolsDockPosition.bottom,
          enabledLogSourceIds: ['console'],
          maxVisibleEntries: 8,
        ),
        entries: [
          DeveloperToolEntry(
            title: 'Trigger error',
            description: 'Throws an error to test the console log.',
            icon: Icons.bug_report,
            pinned: true, // Pinned entries appear at the top of their section
            onTap: (_) => throw Exception('Test error from developer tools'),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Tap the bug icon to open developer tools.'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => throw Exception('Manual test error'),
              icon: const Icon(Icons.error_outline),
              label: const Text('Throw test error'),
            ),
          ],
        ),
      ),
    );
  }
}
