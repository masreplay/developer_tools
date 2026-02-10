import 'package:example/developer_tools/developer_tools.dart';
import 'package:example/get.dart';
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
      builder: (context, child) {
        return child!;
      },
    );
  }
}
