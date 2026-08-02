## 0.0.4

- Fix response headers being captured as `[value]` (Dart list `toString`) —
  join multi-value headers with `, ` so they read cleanly in the inspector and
  the exported Postman collection.
- Add a **Copy** button next to Share in the inspector: copies the raw Postman
  collection JSON to the clipboard for pasting straight into Postman
  (Import › Raw text).
- Emit the Postman collection as plain JSON (drop the `postman_collection`
  dependency) so the package resolves on any toolchain, including projects on
  `freezed_annotation` 3.x. Output and behaviour are unchanged.

## 0.0.3

- Add **Export Postman collection**: a share button in the inspector calls list builds a Postman Collection (v2.1) from all captured calls and opens the share sheet.
- Each request item carries the full captured data — method, URL (protocol/host/path/query), headers, request cookies, raw/multipart body — plus the captured response as a saved example (status, headers, body) and extra metadata (client, duration, sizes, timestamps) in the request description.

## 0.0.2

- Add NetworkDioAdapter for HTTP call logging; integrate NetworkInspector with search and sorting.
- Refactor network inspector (exports, translations, UI) for readability and consistency.
- Bump `developer_tools_core` to `^0.0.4`.

## 0.0.1

- Initial release.
- Network (HTTP) Developer Tools extension.
- Open HTTP Inspector and Inspector Status Overview entries.
- Inlined fork of Alice HTTP inspector; rebranded as "Network" with no external alice dependency.
