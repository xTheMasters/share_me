import 'dart:typed_data';

class FileData {
  final String name;
  final String mimeType;
  final Uint8List file;

  FileData({
    required this.name,
    required this.mimeType,
    required this.file,
  });
}
