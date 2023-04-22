import 'dart:async';
import 'dart:convert';
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
    required Uint8List imageData,
  }) async {
    assert(name.isNotEmpty, "El nombre del archivo no puede ser nulo o vacío.");
    assert(mimeType.isNotEmpty, "El tipo MIME no puede ser nulo o vacío.");

    Map<String, dynamic> args = {
      'name': name,
      'mimeType': mimeType,
      'imageData': imageData,
    };

    await _channel.invokeMethod('share_me_file', args);
  }

  static Future<void> files({
    required String name,
    required String mimeType,
    required List<Uint8List> imageDataList,
  }) async {
    assert(name.isNotEmpty, "El nombre del archivo no puede ser nulo o vacío.");
    assert(mimeType.isNotEmpty, "El tipo MIME no puede ser nulo o vacío.");

    List<Uint8List> imageDataListCopy = List.from(imageDataList);
    List<String> imageDataListBase64 = [];

    for (Uint8List imageData in imageDataListCopy) {
      String imageDataBase64 = base64Encode(imageData);
      imageDataListBase64.add(imageDataBase64);
    }

    Map<String, dynamic> args = {
      'name': name,
      'mimeType': mimeType,
      'imageData': imageDataListBase64,
    };

    await _channel.invokeMethod('share_me_files', args);
  }
}
