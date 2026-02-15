/// Definition of data holder of form data file.
class NetworkFormDataFile {
  const NetworkFormDataFile(this.fileName, this.contentType, this.length);

  final String? fileName;
  final String contentType;
  final int length;
}
