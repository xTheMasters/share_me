import 'dart:async';
import 'package:flutter/services.dart';

class ShareMe {
  static const MethodChannel _channel = MethodChannel('share_me');

  static Future<void> system({
    required String title,
    required String url,
    String? description,
    String? subject,
  }) async {
    Map<String, dynamic> args = {
      'title': title,
      'url': url,
      'description': description,
      'subject': subject,
    };

    await _channel.invokeMethod('share_me_system', args);
  }

  static Future<void> file({
    required String name,
    required String mimeType,
    required Uint8List file,
  }) async {
    assert(name.isNotEmpty, "El nombre del archivo no puede ser nulo o vacío.");
    assert(mimeType.isNotEmpty, "El tipo MIME no puede ser nulo o vacío.");

    Map<String, dynamic> args = {
      'name': name,
      'mimeType': mimeType,
      'file': file,
    };

    await _channel.invokeMethod('share_me_file', args);
  }
}
