import 'package:example/get.dart';
import 'package:developer_tools/developer_tools.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: HomePage(),
      builder: DeveloperTools.builder(
        entries: [
          DeveloperToolEntry(
            title: 'Open debug page',
            description: 'Navigate to the Other page with toast button.',
            icon: Icons.developer_mode,
            onTap: (context) {
              Get.to(Other.new);
            },
          ),
        ],
      ),
    );
  }
}
