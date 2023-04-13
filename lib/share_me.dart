import 'dart:async';
import 'package:flutter/services.dart';

class ShareMe {
  static const MethodChannel _channel = MethodChannel('share_me');

  static Future<void> system({
    required String title,
    required String url,
    String? description,
    String? subject,
    List<String>? files,
  }) async {
    Map<String, dynamic> args = {
      'title': title,
      'url': url,
      'description': description,
      'subject': subject,
      'files': files,
    };

    await _channel.invokeMethod('share_me', args);
  }
}
