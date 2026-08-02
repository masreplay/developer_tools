# developer_tools_network

Network HTTP inspector for [`developer_tools`](https://pub.dev/packages/developer_tools). Inspect HTTP requests and responses from the in-app debug overlay — an inlined, rebranded fork of Alice with no external `alice` dependency.

## Features

- Capture HTTP calls via `NetworkDioAdapter` (Dio interceptor).
- Browse requests/responses, search and sort, view stats.
- Shake-to-open and notification entry points.
- **Export Postman collection** — share all captured calls as a Postman Collection (v2.1) file.

## Install

```yaml
dependencies:
  developer_tools_network: ^0.0.4
```

## Usage

Register the extension with `developer_tools` and attach the Dio adapter:

```dart
final networkInspector = NetworkInspector(
  configuration: NetworkInspectorConfiguration(navigatorKey: navigatorKey),
);

dio.interceptors.add(NetworkDioAdapter(inspector: networkInspector));

MaterialApp(
  navigatorKey: navigatorKey,
  builder: DeveloperTools.builder(
    extensions: [DeveloperToolsNetwork(instance: networkInspector)],
  ),
);
```

Open the inspector (overlay entry, notification, or shake), then use the tools in the
calls-list app bar.

## Export to Postman

Tap the **share** icon in the inspector calls list to turn every captured call into a
Postman Collection (v2.1) and open the share sheet. The resulting
`*.postman_collection.json` file imports directly into Postman.

Each request item preserves the full captured data:

- HTTP method and full URL (protocol, host, path, query params)
- Request headers (request cookies are folded into a `Cookie` header)
- Request body — raw JSON/text, or multipart `form-data` (fields and files)
- The captured response as a saved example (status code + reason, headers, body)
- Extra metadata with no native Postman field (client, duration, sizes, timestamps)
  preserved in the request description

The collection is emitted as plain JSON (no extra dependencies) and can also be
built programmatically from a list of captured
`NetworkHttpCall`s:

```dart
final collection = NetworkPostmanExportHelper.buildCollection(
  name: 'My App Network',
  calls: calls,
);
final json = NetworkPostmanExportHelper.encode(collection);
```

## License

MIT
