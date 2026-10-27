## 0.0.7

- Postman export carries the uploaded files. The Dio adapter keeps a copy of each multipart file (up to 15 MB, read from a clone so the request is untouched) and its form field name. Share now sends the collection plus every upload, named as the form-data `src`, so Postman finds the files on replay.
- Images, videos and PDFs sent or received as base64 inside JSON bodies (e.g. a selfie or a signature) are shared as raw files next to the collection.
- Form-data file entries use the field name as the key, not the file name.

## 0.0.6

- Migrate from `package:flutter/material.dart` to `package:material_ui` (Flutter 3.47 decoupled Material library). Requires Dart 3.13 / Flutter 3.47.
- Require `flutter_local_notifications` ^22.3.1 and migrate to its named-parameter `initialize`/`show` API.
- Require `permission_handler` ^13.0.2, `package_info_plus` ^10.2.2, `sensors_plus` ^7.1.1, `share_plus` ^13.3.1.
- Require `developer_tools_core` ^0.0.6.

## 0.0.5

- Point `repository`, `homepage` and `issue_tracker` at the real
  repository (github.com/masreplay/developer_tools). The previous
  URLs referenced a non-existent org, so every package page on
  pub.dev showed broken links.

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
