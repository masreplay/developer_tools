import 'dart:typed_data';

/// Definition of data holder of form data file.
class NetworkFormDataFile {
  const NetworkFormDataFile(
    this.fileName,
    this.contentType,
    this.length, {
    this.fieldName,
    this.bytes,
  });

  final String? fileName;
  final String contentType;
  final int length;

  /// The multipart field the file was sent under (e.g. `front_image`).
  final String? fieldName;

  /// The uploaded content, so an export can carry the real file.
  /// Null when it could not be read without consuming the request's stream.
  final Uint8List? bytes;
}
