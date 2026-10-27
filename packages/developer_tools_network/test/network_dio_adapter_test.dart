import 'dart:convert' show base64Decode, base64Encode;
import 'dart:typed_data';

import 'package:developer_tools_network/developer_tools_network.dart';
import 'package:developer_tools_network/network_dio_adapter.dart';
import 'package:developer_tools_network/network_inspector/helper/network_postman_export_helper.dart';
import 'package:developer_tools_network/network_inspector/model/network_configuration.dart';
import 'package:developer_tools_network/network_inspector/model/network_http_call.dart';
import 'package:developer_tools_network/network_inspector/ui/call_details/widget/network_call_request_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Answers every request with 200 and keeps the bytes the server received.
class _RecordingServer implements HttpClientAdapter {
  final List<int> received = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await for (final chunk in requestStream ?? const Stream<Uint8List>.empty()) {
      received.addAll(chunk);
    }
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

// A real 1x1 PNG, so the preview decodes an actual image.
final Uint8List _png = Uint8List.fromList(
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late NetworkInspectorConfiguration configuration;
  late Dio dio;
  late _RecordingServer server;

  setUp(() {
    configuration = NetworkInspectorConfiguration(
      showNotification: false,
      showInspectorOnShake: false,
    );
    final inspector = NetworkInspector(configuration: configuration);
    final adapter = NetworkDioAdapter();
    inspector.addAdapter(adapter);
    server = _RecordingServer();
    dio = Dio(BaseOptions(baseUrl: 'https://kyc.example'))
      ..httpClientAdapter = server
      ..interceptors.add(adapter);
  });

  NetworkHttpCall lastCall() => configuration.networkStorage.getCalls().last;

  test('keeps the uploaded file and still sends it whole', () async {
    final photo = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, ...List.filled(5000, 9)]);

    await dio.post(
      '/api/core/documents',
      data: FormData.fromMap({
        'Key': 'IQ_NATIONAL_CARD',
        'front_image': MultipartFile.fromBytes(photo, filename: 'front.jpg'),
      }),
    );

    final file = lastCall().request!.formDataFiles!.single;
    expect(file.fieldName, 'front_image');
    expect(file.bytes, photo);
    // The server got the full upload: reading the copy did not eat the stream.
    expect(server.received.length, greaterThan(photo.length));
    expect(
      NetworkPostmanExportHelper.buildAttachments([lastCall()]).single.name,
      '000_front_image_front.jpg',
    );
  });

  test('turns a base64 selfie in a JSON body into a file', () async {
    await dio.post(
      '/api/core/liveness/verify/passive',
      data: {'selfie_base64': base64Encode([..._png, ...List.filled(1200, 0)])},
    );

    final files = NetworkPostmanExportHelper.buildAttachments([lastCall()]);
    expect(files.single.name, '000_request_selfie_base64.png');
  });

  testWidgets('request screen previews the uploaded photo', (tester) async {
    final photo = Uint8List.fromList([..._png, ...List.filled(1200, 0)]);
    await tester.runAsync(
      () => dio.post(
        '/api/core/documents',
        data: FormData.fromMap({
          'front_image': MultipartFile.fromBytes(photo, filename: 'front.png'),
        }),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: NetworkCallRequestScreen(call: lastCall()))),
    );

    expect(find.textContaining('000_front_image_front.png'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  test('labels a base64 image in the body instead of showing it', () {
    final body = {'selfie_base64': base64Encode([..._png, ...List.filled(1200, 0)]), 'uid': 'u1'};

    final labelled = NetworkPostmanExportHelper.labelBase64Media(body) as Map;

    expect(labelled['selfie_base64'], startsWith('<png file,'));
    expect(labelled['uid'], 'u1');
  });
}
