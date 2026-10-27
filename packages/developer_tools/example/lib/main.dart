import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:developer_tools/developer_tools.dart';
import 'package:developer_tools_console/developer_tools_console.dart';
import 'package:developer_tools_network/developer_tools_network.dart';
import 'package:developer_tools_network/network_inspector/model/network_configuration.dart';
import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

final _networkInspector = NetworkInspector(
  configuration: NetworkInspectorConfiguration(
    navigatorKey: _navigatorKey,
    showNotification: false,
  ),
);

// Answers locally so the demo needs no server.
class _DemoServer implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await requestStream?.drain<void>();
    return ResponseBody.fromString(
      '{"ok":true}',
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

final _dio = () {
  final adapter = NetworkDioAdapter();
  _networkInspector.addAdapter(adapter);
  return Dio(BaseOptions(baseUrl: 'https://ekyc.dev.example/api'))
    ..httpClientAdapter = _DemoServer()
    ..interceptors.add(adapter);
}();

void main() {
  DeveloperToolsConsole.installErrorHandlers();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      home: const HomePage(),
      builder: DeveloperTools.builder(
        navigatorKey: _navigatorKey,
        extensions: [
          const DeveloperToolsConsole(),
          DeveloperToolsNetwork(instance: _networkInspector),
        ],
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

/// A small picture made on the device, standing in for a camera photo.
Future<Uint8List> _demoPhoto(String label, Color color) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  const size = Size(480, 300);
  canvas.drawRRect(
    RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(24)),
    Paint()..color = color,
  );
  final text = TextPainter(
    text: TextSpan(
      text: label,
      style: const TextStyle(color: Colors.white, fontSize: 40),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  text.paint(canvas, const Offset(32, 120));
  final image = await recorder.endRecording().toImage(480, 300);
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  return png!.buffer.asUint8List();
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _uploadDocument() async {
    await _dio.post(
      '/core/documents',
      data: FormData.fromMap({
        'Key': 'IQ_NATIONAL_CARD',
        'front_image': MultipartFile.fromBytes(
          await _demoPhoto('ID front', Colors.indigo),
          filename: 'front_image.png',
        ),
        'back_image': MultipartFile.fromBytes(
          await _demoPhoto('ID back', Colors.teal),
          filename: 'back_image.png',
        ),
      }),
    );
  }

  Future<void> _sendSelfie() async {
    final selfie = await _demoPhoto('Selfie', Colors.deepOrange);
    await _dio.post(
      '/core/liveness/verify/passive',
      data: {'selfie_base64': base64Encode(selfie)},
    );
  }

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
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _uploadDocument,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload document (multipart)'),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _sendSelfie,
              icon: const Icon(Icons.face),
              label: const Text('Send selfie (base64)'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _networkInspector.showInspector,
              icon: const Icon(Icons.http),
              label: const Text('Open network inspector'),
            ),
          ],
        ),
      ),
    );
  }
}
