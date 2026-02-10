import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

class Controller extends GetxController {
  var count = 0.obs;

  RxInt increment() => count++;
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(context) {
    final Controller c = Get.put(Controller());
    return Scaffold(
      appBar: AppBar(title: Obx(() => Text('Clicks: ${c.count}'))),
      body: Center(
        child: ElevatedButton(
          child: Text('Go to Other'),
          onPressed: () => Get.to(Other.new),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: c.increment,
        child: Icon(Icons.add),
      ),
    );
  }
}

class Other extends StatelessWidget {
  final Controller c = Get.find();
  @override
  Widget build(context) {
    return Scaffold(
      body: Center(
        child: Text('${c.count}'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          toastification.show(
            title: Text('Hello'),
            description: Text('This is a toast'),
            type: ToastificationType.success,
            autoCloseDuration: Duration(seconds: 1),
          );
        },
        child: Icon(Icons.show_chart),
      ),
    );
  }
}
